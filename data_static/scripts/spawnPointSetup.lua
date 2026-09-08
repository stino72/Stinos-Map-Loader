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
	instance.position = position
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

---@param map table
function SetupSpawnPoints(map)
	local s = SpawnPointDataNewV(map["name"], map["spawn"]["p"], map["spawn"]["r"])
	table.insert(SpawnPoints, s)

	for i = 1, 8, 1 do
		local m = tm.physics.SpawnObject(tm.vector3.Create(), "PFB_Beacon")
		m.GetTransform().SetScale(0.3, 0.02, 0.3)
		spawnPointMakers[i] = m
	end
	tm.physics.AddMesh("data_static/assets/arrow.obj", "spawnpointarrow")
	arrow = tm.physics.SpawnCustomObject(tm.vector3.Create(), "spawnpointarrow", "")

	LoadSpawnPointConfigureUi()
end

function LoadSpawnPointConfigureUi()
	tm.playerUI.ClearUI(0)
	local s = SpawnPoints[current]

	ShowSpawnPointMakers()

	tm.playerUI.AddUIButton(0, "tp", "teleport to spawn point", TeleportToSpawn)
	tm.playerUI.AddUIButton(0, "move", "move to player", MoveToPlayer)
	tm.playerUI.AddUILabel(0, 0, "---------------------------------------------")
	tm.playerUI.AddUILabel(0, 0, "name")
	tm.playerUI.AddUIText(0, "name", s.name, NULL)
	tm.playerUI.AddUILabel(0, 0, "pos x y z")
	tm.playerUI.AddUIText(0, "x", s.position.x, NULL)
	tm.playerUI.AddUIText(0, "y", s.position.y, NULL)
	tm.playerUI.AddUIText(0, "z", s.position.z, NULL)
	tm.playerUI.AddUILabel(0, 0, "rotation")
	tm.playerUI.AddUIText(0, "r", s.rotation, NULL)
	tm.playerUI.AddUILabel(0, 0, "---------------------------------------------")
	if current < #SpawnPoints then
		tm.playerUI.AddUIButton(0, "next", "> next >", Next, 1)
	end
	if current > 1 then
		tm.playerUI.AddUIButton(0, "previous", "< previous <", Next, -1)
	end

	tm.playerUI.AddUIButton(0, "new", "+ new +", Add)
	if #SpawnPoints > 1 then
		tm.playerUI.AddUIButton(0, "remove", "- remove -", Remove)
	end
end

-- TODO: correct of spawn point rotation
-- TODO: read the spawn point radius
function ShowSpawnPointMakers()
	---@type ModVector3
	local spawnPos = TableToVector(SpawnPoints[current].position)
	arrow.GetTransform().SetPosition(spawnPos + tm.vector3.Create(0, 0.1, 0))
	arrow.GetTransform().SetRotation(0, SpawnPoints[current].rotation - 90, 0)
	arrow.SetIsTrigger(true)
	for i = 0, 7, 1 do
		local pos = spawnPos + CreateDirectionVector(i * 45) * 6.5
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

function NULL()
	
end

---@param angle number
---@return ModVector3
function CreateDirectionVector(angle)
	local r = angle / 180 * math.pi
	return tm.vector3.Create(math.sin(r), 0, math.cos(r))
end
