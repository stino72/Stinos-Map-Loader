---@class SpawnPointData
---@field name string
---@field position ModVector3
---@field rotation number
local SpawnPointData = {}
SpawnPointData.__index = SpawnPointData

---@param name string
---@param position ModVector3
---@param rotation number
---@return SpawnPointData
function SpawnPointDataNew(name, position, rotation)
	local instance = setmetatable({}, SpawnPointData)

	instance.name = name
	instance.position = position
	instance.rotation = rotation

	return instance
end

---@param name string
---@param position ModVector3
---@param rotation ModVector3
---@return SpawnPointData
function SpawnPointDataNewV(name, position, rotation)
	local instance = setmetatable({}, SpawnPointData)

	instance.name = name
	instance.position = TableToVector(position)
	instance.rotation = math.atan2(rotation.x, rotation.y) / math.pi * 180

	return instance
end

---@type SpawnPointData[]
local SpawnPoints = {}

---@type integer
local current = 1

local spawnPointsMade = 1

---@type ModGameObject[]
local spawnPointMakers = {}
---@type ModGameObject
local arrow

local mapName = ""

---@param map table
function SetupSpawnPoints(map)
	if not SAVE_FILE[MAP_NAME].spawnPoints then
		local s = SpawnPointDataNewV(map["name"], map["spawn"]["p"], map["spawn"]["r"])
		table.insert(SpawnPoints, s)
	else
		for index, spawn in ipairs(SAVE_FILE[MAP_NAME].spawnPoints) do
			---@type SpawnPointData
			local s = {
				name = spawn.name,
				position = TableToVector(spawn.position),
				rotation = spawn.rotation
			}
			table.insert(SpawnPoints, s)
		end
	end

	for i = 1, 8, 1 do
		local m = tm.physics.SpawnObject(tm.vector3.Create(), "PFB_Beacon")
		m.GetTransform().SetScale(0.3, 0.02, 0.3)
		spawnPointMakers[i] = m
	end
	tm.physics.AddMesh("data_static/assets/arrow.obj", "spawnpointarrow")
	arrow = tm.physics.SpawnCustomObject(tm.vector3.Create(), "spawnpointarrow", "")

	mapName = map["name"]
	LoadSpawnPointConfigureUi()
end

function LoadSpawnPointConfigureUi()
	tm.playerUI.ClearUI(0)
	local s = SpawnPoints[current]

	ShowSpawnPointMakers()

	tm.playerUI.AddUILabel(0, 0, "<align=left> Spawn Point Radius (m)")
	tm.playerUI.AddUIText(0, "spawnRadius", SETTINGS.spawnRadius, SetRadius)
	tm.playerUI.AddUIButton(0, "tp", "Teleport to Spawn Point", TeleportToSpawn)
	tm.playerUI.AddUIButton(0, "move", "Move to Player", MoveToPlayer)
	tm.playerUI.AddUILabel(0, 0, "---------------------------------------------")
	tm.playerUI.AddUILabel(0, 0, "Spawn Point Name")
	tm.playerUI.AddUIText(0, "name", s.name, SetName)
	tm.playerUI.AddUILabel(0, 0, "Position: x y z")
	tm.playerUI.AddUIText(0, "x", s.position.x, SetPosition, "x")
	tm.playerUI.AddUIText(0, "y", s.position.y, SetPosition, "y")
	tm.playerUI.AddUIText(0, "z", s.position.z, SetPosition, "z")
	tm.playerUI.AddUILabel(0, 0, "Rotation")
	tm.playerUI.AddUIText(0, "r", s.rotation, SetRotation)
	tm.playerUI.AddUILabel(0, 0, "---------------------------------------------")

	tm.playerUI.AddUILabel(0, 0, "Spawn Point: " .. current .. "/" .. #SpawnPoints)
	if current < #SpawnPoints then
		tm.playerUI.AddUIButton(0, "next", "> Next >", Next, 1)
	end
	if current > 1 then
		tm.playerUI.AddUIButton(0, "previous", "< Previous <", Next, -1)
	end

	tm.playerUI.AddUIButton(0, "new", "+ New +", Add)
	if #SpawnPoints > 1 then
		tm.playerUI.AddUIButton(0, "remove", "- Remove -", Remove)
	end
	tm.playerUI.AddUILabel(0, 0, "---------------------------------------------")
	tm.playerUI.AddUIButton(0, "save", "Save Spawn Points", SaveSpawnPoints)
end

function ShowSpawnPointMakers()
	---@type ModVector3
	local spawnPos = SpawnPoints[current].position
	arrow.GetTransform().SetPosition(spawnPos + tm.vector3.Create(0, 0.1, 0))
	arrow.GetTransform().SetRotation(0, SpawnPoints[current].rotation - 90, 0)
	arrow.SetIsTrigger(true)
	for i = 0, 7, 1 do
		local pos = spawnPos + CreateDirectionVector(i * 45 + SpawnPoints[current].rotation) * SETTINGS.spawnRadius
		spawnPointMakers[i + 1].GetTransform().SetPosition(pos)
	end
end

---@param data UICallbackData
function Next(data)
	current = current + data.data
	LoadSpawnPointConfigureUi()
end

---@param data UICallbackData
function Add(data)
	local s = SpawnPointDataNew("spawn point " .. spawnPointsMade + 1, tm.players.GetPlayerTransform(0).GetPositionWorld(), 0)
	table.insert(SpawnPoints, s)
	current = #SpawnPoints
	spawnPointsMade = spawnPointsMade + 1
	LoadSpawnPointConfigureUi()
end

---@param data UICallbackData
function Remove(data)
	table.remove(SpawnPoints, current)
	current = math.max(current - 1, 1)
	LoadSpawnPointConfigureUi()
end

---@param data UICallbackData
function MoveToPlayer(data)
	SpawnPoints[current].position = tm.players.GetPlayerTransform(0).GetPositionWorld()
	LoadSpawnPointConfigureUi()
end

---@param data UICallbackData
function TeleportToSpawn(data)
	tm.players.GetPlayerTransform(0).SetPosition(SpawnPoints[current].position)
	tm.players.GetPlayerTransform(0).SetRotation(0, SpawnPoints[current].rotation, 0)
end

---@param data UICallbackData
function SetName(data)
	SpawnPoints[current].name = data.value
end

---@param data UICallbackData
function SetRotation(data)
	if data.value == "" or data.value == "." or data.value == "-" then
		SpawnPoints[current].rotation = 0
		ShowSpawnPointMakers()
		return
	end
	local n = tonumber(data.value)
	if n == nil then
		tm.playerUI.SetUIValue(0, data.id, SpawnPoints[current].rotation)
		return
	end
	SpawnPoints[current].rotation = n
	ShowSpawnPointMakers()
end

---@param data UICallbackData
function SetPosition(data)
	if data.value == "" or data.value == "." or data.value == "-" then
		SpawnPoints[current].position[data.data] = 0
		ShowSpawnPointMakers()
		return
	end
	local n = tonumber(data.value)
	if n == nil then
		tm.playerUI.SetUIValue(0, data.id, SpawnPoints[current].position[data.data])
		return
	end
	SpawnPoints[current].position[data.data] = n
	ShowSpawnPointMakers()
end

---@param data UICallbackData
function SetRadius(data)
	if data.value == "" or data.value == "." or data.value == "-" then
		SETTINGS.spawnRadius = 0
		ShowSpawnPointMakers()
		return
	end
	local n = tonumber(data.value)
	if n == nil then
		tm.playerUI.SetUIValue(0, data.id, SETTINGS.spawnRadius)
		return
	end
	SETTINGS.spawnRadius = n
	ShowSpawnPointMakers()
end

---@param data UICallbackData
function SaveSpawnPoints(data)
	local spawns = {}
	for index, spawn in ipairs(SpawnPoints) do
		local s = {}
		s["name"] = spawn.name
		s["position"] = {}
		s["position"]["x"] = spawn.position.x
		s["position"]["y"] = spawn.position.y
		s["position"]["z"] = spawn.position.z
		s["rotation"] = spawn.rotation

		table.insert(spawns, s)
	end
	SAVE_FILE[MAP_NAME].reparserSettings = SETTINGS
	SAVE_FILE[MAP_NAME].spawnPoints = spawns
	tm.os.WriteAllText_Dynamic("settings.json", json.serialize(SAVE_FILE))
	tm.os.WriteAllText_Dynamic(mapName .. "/data_static/spawn_points.json", json.serialize(spawns))
	tm.playerUI.ClearUI(0)
	FinalizeMapFolder()
end

function NULL()
	
end

---@param angle number
---@return ModVector3
function CreateDirectionVector(angle)
	local r = angle / 180 * math.pi
	return tm.vector3.Create(math.sin(r), 0, math.cos(r))
end
