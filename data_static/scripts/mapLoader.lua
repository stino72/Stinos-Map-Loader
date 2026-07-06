---@class spawnPoint
---@field p table
---@field r table
local spawnPoint = {}
spawnPoint.__index = spawnPoint

---@class objectFlags
---@field isStatic boolean
---@field canCollide boolean
---@field isVisible boolean
---@field modelId integer
---@field textureId integer
---@field weight number
local objectFlags = {}
objectFlags.__index = objectFlags

local isLoading = false

---@type spawnPoint
local spawn

local objectBuffer = {}

local objectIndex = 0
local objectCount = 0

local customObjectIndice = 0
local customObjectCollisionIndice = 0
local customObjectPhysicsIndice = 0

local material = {}

tm.os.SetModTargetDeltaTime(1/60)

---@param player ModPlayer
function OnPlayerJoined(player)
    SetSpawnPoint(player)
end

function update()
    UpdateMapLoader()
end

function LoadMap()
    isLoading = true
    local map = json.parse(tm.os.ReadAllText_Static("map.json"))
    spawn = map["spawn"]

    objectBuffer = map["objects"]

    material = map["materials"]

    customObjectIndice = map["custom objects indice"]

    customObjectCollisionIndice = map["custom objects collision indice"]

    customObjectPhysicsIndice = map["custom objects physics indice"]

    objectCount = #objectBuffer

    LoadMeshes(map["custom meshes"])
    LoadTextures(map["custom textures"])
end

---@param meshes table
function LoadMeshes(meshes)
    for index, mesh in ipairs(meshes) do
        tm.physics.AddMesh(mesh, tostring(index))
    end
end


---@param textures table
function LoadTextures(textures)
    for index, texture in ipairs(textures) do
        tm.physics.AddTexture(texture, "t" .. tostring(index))
    end    
end


---@param player ModPlayer
function SetSpawnPoint(player)
    tm.players.SetSpawnPoint(player.playerId, "main", TableToVector(spawn.p), TableToVector(spawn.r))
    tm.players.SetPlayerSpawnLocation(player.playerId, "main");
    tm.players.TeleportPlayerToSpawnPoint(player.playerId, "main", true);
end 


function UpdateMapLoader()
    if not isLoading then
        return
    end

    local LoadAmount = math.min(#objectBuffer, 15)
    for i = 1, LoadAmount, 1 do
        objectIndex = objectIndex + 1

        local object = objectBuffer[1]

        ---@type objectFlags
        local flags = object["i"]
        
        ---@type ModGameObject
        local obj

        if objectIndex < customObjectIndice then
            obj = tm.physics.SpawnCustomObject(TableToVector(object["p"]), tostring(flags.modelId), "t" .. tostring(flags.textureId), material[flags.textureId])
        elseif objectIndex < customObjectCollisionIndice then
            obj = tm.physics.SpawnCustomObjectConcave(TableToVector(object["p"]), tostring(flags.modelId), "t" .. tostring(flags.textureId), material[flags.textureId])
        elseif objectIndex < customObjectPhysicsIndice then
            obj = tm.physics.SpawnCustomObjectRigidbody(TableToVector(object["p"]), tostring(flags.modelId), "t" .. tostring(flags.textureId), flags.weight == 0, flags.weight, material[flags.textureId])
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

    if objectIndex == objectCount then
        tm.playerUI.AddSubtleMessageForAllPlayers("Map Loaded")
        isLoading = false
    end
end


---@param table table
---@return ModVector3
function TableToVector(table)
    return tm.vector3.Create(table.x, table.y, table.z)
end 

tm.players.OnPlayerJoined.add(OnPlayerJoined)

LoadMap()
