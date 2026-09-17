local copySpawnPoints = true
local map_a = "test map"
local map_b = "test map"
local new_name = "combined map"

local AMatch = false
local BMatch = false

local mapAData = "\0"
local mapBData = "\0"

function CombineMaps()
	tm.playerUI.ClearUI(0)

	tm.playerUI.AddUILabel(0, 0, "<align=left>Combine 2 Exported Maps")
	tm.playerUI.AddUILabel(0, 0, "<align=left>Settings will be taken from Map A")
	tm.playerUI.AddUILabel(0, 0, "<align=left>Both Maps Should be in:")
	tm.playerUI.AddUILabel(0, 0, "<align=left>data_dynamic/<map_name>")
	tm.playerUI.AddUILabel(0, 0, "---------------------------------------------")
	if mapAData == "" then
		tm.playerUI.AddUILabel(0, 0, "<color=orange>Could not find map: " .. map_a)
	end
	tm.playerUI.AddUILabel(0, 0, "<align=left>Map A:")
	tm.playerUI.AddUIText(0, "map a", map_a, SetMapA)
	tm.playerUI.AddUILabel(0, 0, "<align=left>Map B:")
	if mapBData == "" then
		tm.playerUI.AddUILabel(0, 0, "<color=orange>Could not find map: " .. map_b)
	end
	tm.playerUI.AddUIText(0, "map b", map_b, SetMapB)
	tm.playerUI.AddUILabel(0, 0, "<align=left>New Name:")
	tm.playerUI.AddUIText(0, "name", new_name, SetNewName)
	if AMatch then
		tm.playerUI.AddUILabel(0, 0, "<color=orange>Note: Map A will be overwriten")
	end
	if BMatch then
		tm.playerUI.AddUILabel(0, 0, "<color=orange>Note: Map B will be overwriten")
	end
	tm.playerUI.AddUILabel(0, 0, "---------------------------------------------")
	AddToggleButton(0, "spawn", "Copy Spawn Points", copySpawnPoints, OnCopySpawnPointsSet)
	tm.playerUI.AddUIButton(0, "combine", "Combine Maps", SetupCombine)
end

---@param data ToggleCallbackData
function OnCopySpawnPointsSet(data)
	copySpawnPoints = data.state
end

---@param data UICallbackData
function SetMapA(data)
	map_a = MakeFileName(data.value)
	tm.playerUI.SetUIValue(0, "map a", map_a)
	if map_a == "" then
		return
	end
	local equal = map_a == new_name
	if AMatch != equal then
		AMatch = equal
		CombineMaps()
	end
end

---@param data UICallbackData
function SetMapB(data)
	map_b = MakeFileName(data.value)
	tm.playerUI.SetUIValue(0, "map b", map_b)
	if map_b == "" then
		return
	end
	local equal = map_b == new_name
	if BMatch != equal then
		BMatch = equal
		CombineMaps()
	end
end

---@param data UICallbackData
function SetNewName(data)
	new_name = MakeFileName(data.value)
	tm.playerUI.SetUIValue(0, "name", new_name)
	if map_a ~= "" then
		local equal = map_a == new_name
		if AMatch != equal then
			AMatch = equal
			CombineMaps()
		end
	end
	if map_b ~= "" then
		local equal = map_b == new_name
		if BMatch != equal then
			BMatch = equal
			CombineMaps()
		end
	end
end

---@param s string
---@return string
function MakeFileName(s)
	s = s:gsub("/", "")
	s = s:gsub("'", "")
	s = s:gsub('"', "")
	return s
end

function SetupCombine()
	mapAData = tm.os.ReadAllText_Dynamic(map_a .. "/data_static/map.json")
	mapBData = tm.os.ReadAllText_Dynamic(map_b .. "/data_static/map.json")

	if mapAData == "" or mapBData == "" then
		CombineMaps()
		return
	end
	tm.playerUI.ClearUI(0)

	if new_name == "" then
		new_name = "combined map"
	end

	local mapA = json.parse(mapAData)
	local mapB = json.parse(mapBData)

	local meshes = #mapA["custom meshes"]
	local textures = #mapA["custom textures"]
	Print(meshes, textures)

	mapA["custom meshes"] = AppendTable(mapA["custom meshes"], mapB["custom meshes"])
	mapA["custom textures"] = AppendTable(mapA["custom textures"], mapB["custom textures"])
	mapA["materials"] = AppendTable(mapA["materials"], mapB["materials"])

	for index, value in ipairs(mapB["objects"]) do
		Print(value)
		if index < mapB["custom objects physics indice"] then
			value["i"]["modelId"] = value["i"]["modelId"] + meshes
			value["i"]["textureId"] = value["i"]["textureId"] + textures
		end
		table.insert(mapA["objects"], value)
	end

	tm.os.WriteAllText_Dynamic(new_name .. "/data_static/map.json", json.serialize(mapA))
end
