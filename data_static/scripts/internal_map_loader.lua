---@class i_spawnPoint
---@field p table
---@field r table
local i_spawnPoint = {}
i_spawnPoint.__index = i_spawnPoint

---@class i_objectFlags
---@field isStatic boolean
---@field canCollide boolean
---@field isVisible boolean
---@field modelId integer
---@field textureId integer
---@field weight number
local i_objectFlags = {}
i_objectFlags.__index = i_objectFlags

local isLoading = false

---@type i_spawnPoint
local spawn

local objectBuffer = {}

local objectIndex = 0
local objectCount = 0

local customObjectIndice = 0
local customObjectCollisionIndice = 0
local customObjectPhysicsIndice = 0

local material = {}

local loadmsg

tm.os.SetModTargetDeltaTime(1/60)

---@param map table
function LoadMap(map)
	isLoading = true
	spawn = map["spawn"]

	objectBuffer = map["objects"]

	material = map["materials"]

	customObjectIndice = map["custom objects indice"]

	customObjectCollisionIndice = map["custom objects collision indice"]

	customObjectPhysicsIndice = map["custom objects physics indice"]

	objectCount = #objectBuffer

	SetSpawnPoint(0)
	loadmsg = tm.playerUI.AddSubtleMessageForPlayer(0, "Loading Map, Please Wait", "Loading Assets", 9999)
	tm.physics.SetGravityMultiplier(0)

	LoadMeshes(map["custom meshes"])
	LoadTextures(map["custom textures"])
end

---@param meshes table
function LoadMeshes(meshes)
	for index, mesh in ipairs(meshes) do
		tm.physics.AddMesh("assets/" .. mesh, "m" .. tostring(index))
	end
end


---@param textures table
function LoadTextures(textures)
	for index, texture in ipairs(textures) do
		tm.physics.AddTexture("assets/" .. texture, "t" .. tostring(index))
	end
end


function Update_map_loader()
	if not isLoading then
		return
	end

	local LoadAmount = math.min(#objectBuffer, 15)
	for i = 1, LoadAmount, 1 do
		objectIndex = objectIndex + 1

		local object = objectBuffer[1]

		---@type i_objectFlags
		local flags = object["i"]

		---@type ModGameObject
		local obj

		if objectIndex < customObjectIndice then
			obj = tm.physics.SpawnCustomObject(TableToVector(object["p"]), "m" .. tostring(flags.modelId), "t" .. tostring(flags.textureId), material[flags.textureId])
		elseif objectIndex < customObjectCollisionIndice then
			obj = tm.physics.SpawnCustomObjectConcave(TableToVector(object["p"]), "m" .. tostring(flags.modelId), "t" .. tostring(flags.textureId), material[flags.textureId])
		elseif objectIndex < customObjectPhysicsIndice then
			obj = tm.physics.SpawnCustomObjectRigidbody(TableToVector(object["p"]), "m" .. tostring(flags.modelId), "t" .. tostring(flags.textureId), flags.weight == 0, flags.weight, material[flags.textureId])
		else
			obj = tm.physics.SpawnObject(TableToVector(object["p"]), object["n"])
		end

		obj.GetTransform().SetRotation(TableToVector(object["r"]))
		obj.GetTransform().SetScale(TableToVector(object["s"]))

		obj.SetIsStatic(flags.isStatic)
		if not flags.canCollide then
			obj.SetIsTrigger(true);
		end
		obj.SetIsVisible(flags.isVisible)

		table.remove(objectBuffer, 1)
	end
	tm.playerUI.SubtleMessageUpdateMessageForPlayer(0, loadmsg, "Placing Objects " .. objectIndex .. "/" .. objectCount)

	if objectIndex == objectCount then
		tm.playerUI.AddSubtleMessageForAllPlayers("Map Loaded")
		tm.playerUI.RemoveSubtleMessageForPlayer(0, loadmsg)
		tm.physics.SetGravityMultiplier(1)
		isLoading = false
	end
end

---@param playerId PlayerID
function SetSpawnPoint(playerId)
	tm.players.SetSpawnPoint(playerId, "main", TableToVector(spawn.p), TableToVector(spawn.r))
	tm.players.SetPlayerSpawnLocation(playerId, "main");
	tm.players.TeleportPlayerToSpawnPoint(playerId, "main", true);
end

---@param table table
---@return ModVector3
function TableToVector(table)
	return tm.vector3.Create(table.x, table.y, table.z)
end
