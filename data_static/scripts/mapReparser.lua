local heightOffSet = 300

---@class objFlags
---@field IsStatic boolean
---@field CanCollide boolean
---@field IsVisible boolean
---@field DisplayName string
---@field CustomTexture string
---@field CustomModel boolean
---@field CustomWeight number
local objFlags = {}
objFlags.__index = objFlags

---@class ReparserSettings
---@field newSpawnPoints boolean
---@field RespawnOnComplete boolean
---@field spawnRadius number
---@field spawnMenuHeader string
---@field credit string
---@field zeroG boolean
---@field defaultTimeOfDay number
---@field progressBar boolean
local ReparserSettings = {}
ReparserSettings.__index = ReparserSettings

---@return ReparserSettings
function NewReparserSettings()
	local instance = setmetatable({}, ReparserSettings)

	instance.newSpawnPoints = false
	instance.RespawnOnComplete = true
	instance.spawnRadius = 6.5
	instance.spawnMenuHeader = "<b>- Teleport -"
	instance.credit = "<b>Map made by " .. tm.players.GetPlayerName(0)
	instance.zeroG = false
	instance.defaultTimeOfDay = -1
	instance.progressBar = true

	return instance
end

---@type ReparserSettings
local s = NewReparserSettings()

---@type table
local newMap = {}

local textureIndex = 1

local physicsMaterials = {
    "Metal",
    "Sand",
    "Stone",
    "Gravel",
    "Grass",
    "Mud",
    "Lava",
    "Asphalt",
    "Snow",
    "Wood",
    "YellowSand",
    "WitheredGrass",
    "IceSlippery",
    "Tundra",
    "SnowHard",
    "GrassYellow"
}

function SetupUI()
    tm.playerUI.AddUILabel(0, "textureName", "nil")
    tm.playerUI.AddUILabel(0, "Progress", "nil")
    for index, value in ipairs(physicsMaterials) do
        tm.playerUI.AddUIButton(0, index, value, SetMaterial, value)
    end
    tm.playerUI.AddUILabel(0, "info", "Preview Texture may take some")
    tm.playerUI.AddUILabel(0, "info", "time to load")
end


---@param data UICallbackData
function SetMaterial(data)
    newMap["materials"][textureIndex] = data.data
    textureIndex = textureIndex + 1
    GetMaterial()
end


function GetMaterial()
    tm.physics.ClearAllSpawns()

    if textureIndex > #newMap["custom textures"] then
        tm.playerUI.ClearUI(0)
        FinalizeMapFolder()
        return
    end

    local textureName = string.gsub(newMap["custom textures"][textureIndex], ".Custom Models.", "")
    tm.playerUI.SetUIValue(0, "textureName", textureName)

    tm.playerUI.SetUIValue(0, "Progress", tostring(textureIndex) .. "/" .. tostring(#newMap["custom textures"]))

    local PlayerPos = tm.players.GetPlayerTransform(0).GetPositionWorld()
    tm.physics.AddTexture("assets/" .. newMap["custom textures"][textureIndex], tostring(textureIndex))
    local obj = tm.physics.SpawnCustomObject(PlayerPos + tm.vector3.Create(0, 5, 0), "", tostring(textureIndex))
    obj.GetTransform().SetScale(3)
    obj.SetIsTrigger(true)
end


function FinalizeMapFolder()
	tm.os.WriteAllText_Dynamic(newMap["name"] .. "/data_static/map.json", Encode(newMap))
	Print(newMap["name"] .. "/map.json")

	local loader = tm.os.ReadAllText_Static("scripts/mapLoader.lua")
	local flags = {}

	if s.newSpawnPoints then
		table.insert(flags, "SPAWN")

		local spawnPoints = tm.os.ReadAllText_Static("scripts/spawn_points.lua")
		spawnPoints = SetVariable(spawnPoints, "spawnRadius", s.spawnRadius)
		spawnPoints = SetVariable(spawnPoints, "header", '"' .. s.spawnMenuHeader .. '"')
		spawnPoints = SetVariable(spawnPoints, "credit", '"' .. s.credit .. '"')
		tm.os.WriteAllText_Dynamic(newMap["name"] .. "/data_static/spawn_points.lua", spawnPoints)

		if s.RespawnOnComplete then
			table.insert(flags, "RESPAWN")
		end
	end

	if s.zeroG then
		table.insert(flags, "ZEROG")
	end

	if s.defaultTimeOfDay >= 0 and s.defaultTimeOfDay <= 100 then
		table.insert(flags, "TIME")
		loader = SetVariable(loader, "time", s.defaultTimeOfDay)
	end

	if s.progressBar then
		table.insert(flags, "LOAD")
	end

	loader = ResolveMarcos(loader, flags)
    tm.os.WriteAllText_Dynamic(newMap["name"] .. "/main.lua", loader)

	tm.playerUI.AddSubtleMessageForAllPlayers("Map Reparsing Complete", "Map.json saved in data_dynamic", 60)
end


---@param data UICallbackData
function ReparseMap(data)
	tm.playerUI.ClearUI(0)

	s = data.data

    local map = json.parse(tm.os.ReadAllText_Static("map"))

    newMap["name"] = map["Name"]

	if not s.newSpawnPoints then
		newMap["spawn"] = {}
		newMap["spawn"]["p"] = map["SpawnpointInfo"]["P"]
		newMap["spawn"]["p"].y = newMap["spawn"]["p"].y + heightOffSet
		newMap["spawn"]["r"] = map["SpawnpointInfo"]["R"]
	end

    newMap["custom meshes"] = {}
    newMap["custom textures"] = {}
    newMap["materials"] = {}

    newMap["objects"] = {}

    newMap["custom objects indice"] = 0
    newMap["custom objects collision indice"] = 0
    newMap["custom objects physics indice"] = 0

    local objects = {}
    local customObjects = {}
    local customObjectsCollision = {}
    local customObjectsPhysics = {}

    for index, value in ipairs(map["ObjectList"]) do
        ---@type objFlags
        local flags = value["I"]

        ---@type table
        local newObj = {}
        newObj["p"] = value["P"]
        newObj["p"].y = newObj["p"].y + heightOffSet
        newObj["r"] = value["R"]
        newObj["s"] = value["S"]


        if value["S"].x == 1 then
            newObj["s"].x = 1.00001
        end

        newObj["i"] = {}

        newObj["i"].isStatic = flags.IsStatic
        newObj["i"].canCollide = flags.CanCollide
        newObj["i"].isVisible = flags.IsVisible

        if not flags.CustomModel then
            newObj["n"] = value["N"]

            if string.match(value["N"], "Container") or string.match(value["N"], "Tire") then
                if not flags.IsStatic then
                    newObj["n"] = value["N"] .. "_Dynamic"
                end
            end

            table.insert(objects, newObj)

        else
            if not TableContains(newMap["custom meshes"], value["N"]) then
                table.insert(newMap["custom meshes"], value["N"])
            end

            if not TableContains(newMap["custom textures"], flags.CustomTexture) then
                if flags.CustomTexture != "" then
                    table.insert(newMap["custom textures"], flags.CustomTexture)
                end
            end

            newObj["i"].modelId = TableFind(newMap["custom meshes"], value["N"])
            newObj["i"].textureId = TableFind(newMap["custom textures"], flags.CustomTexture)

            if not flags.IsStatic then
                newObj["i"].weight = flags.CustomWeight
                table.insert(customObjectsPhysics, newObj)
            elseif flags.CanCollide then
                table.insert(customObjectsCollision, newObj)
            else
                table.insert(customObjects, newObj)
            end
        end
    end

    newMap["objects"] = customObjects
    newMap["custom objects indice"] = #newMap["objects"] + 1

    newMap["objects"] = AppendTable(newMap["objects"], customObjectsCollision)
    newMap["custom objects collision indice"] = #newMap["objects"] + 1

    newMap["objects"] = AppendTable(newMap["objects"], customObjectsPhysics)
    newMap["custom objects physics indice"] = #newMap["objects"] + 1

    newMap["objects"] = AppendTable(newMap["objects"], objects)

    SetupUI()
    GetMaterial()
	Print("test")
end


---@param table table
---@param value any
---@return boolean
function TableContains(table, value)
    for k, v in pairs(table) do
        if value == v then
            return true;
        end
    end
    return false;
end


---@param table table
---@param value any
---@return integer
function TableFind(table, value)
    for index, v in ipairs(table) do
        if value == v then
            return index;
        end
    end
    return -1;
end


---@param oldtable table
---@param newTable table
---@return table
function AppendTable(oldtable, newTable)
    for index, value in ipairs(newTable) do
        table.insert(oldtable, value)
    end
    return oldtable
end


local function escape_str(s)
    local replacements = {
        ['"']  = '\\"',
        ['\\'] = '\\\\',
        ['\b'] = '\\b',
        ['\f'] = '\\f',
        ['\n'] = '\\n',
        ['\r'] = '\\r',
        ['\t'] = '\\t',
    }

    return s:gsub('[%z\1-\31\\"]', function(c)
        return replacements[c] or string.format("\\u%04x", c:byte())
    end)
end


local function is_array(t)
    local i = 1
    for k, _ in pairs(t) do
        if k ~= i then
            return false
        end
        i = i + 1
    end
    return true
end


function Encode(value)
    local t = type(value)

    if t == "nil" then
        return "null"

    elseif t == "boolean" then
        return tostring(value)

    elseif t == "number" then
        return tostring(value)

    elseif t == "string" then
        return '"' .. escape_str(value) .. '"'

    elseif t == "table" then
        local result = {}

        if is_array(value) then
            for i = 1, #value do
                table.insert(result, Encode(value[i]))
            end
            return "[" .. table.concat(result, ",") .. "]"
        else
            for k, v in pairs(value) do
                table.insert(
                    result,
                    Encode(tostring(k)) .. ":" .. Encode(v)
                )
            end
            return "{" .. table.concat(result, ",") .. "}"
        end

    else
        Print("Unsupported type: " .. t)
    end
end
