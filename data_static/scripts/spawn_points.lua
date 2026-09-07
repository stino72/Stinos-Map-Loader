---@type string[]
local spawnPoints = {}

local spawnRadius = 6.5
--[HEADER]~
local header = "<b>- Teleport -"
--END
--[CREDIT]~
local credit = "<b>Map made by ?"
--END

function SetSpawnPoints()
	local sp = json.parse(tm.os.ReadAllText_Static("spawn_points.json"))

	for index, value in ipairs(sp) do
		local position = TableToVector(value["position"])
		local rotation = CreateDirectionVector(value["rotation"])
		local name = value["name"]

		table.insert(spawnPoints, name)

		if tm.os.IsSingleplayer() then
			tm.players.SetSpawnPoint(0, name, position, rotation)
			goto continue
		end

		for i = 0, 7, 1 do
			local pos = position + CreateDirectionVector(i * 45) * spawnRadius
			tm.players.SetSpawnPoint(i, name, pos, rotation)
		end

	    ::continue::
	end
end


---@param angle number
---@return ModVector3
function CreateDirectionVector(angle)
	local r = angle / 180 * math.pi
	return tm.vector3.Create(math.sin(r), 0, math.cos(r))
end


---@param table table
---@return ModVector3
function TableToVector(table)
	return tm.vector3.Create(table.x, table.y, table.z)
end


---@param player ModPlayer
function OnPlayerJoined(player)
--[HEADER]~
	tm.playerUI.AddUILabel(player.playerId, 0, header)
--END
	tm.players.SetPlayerIsInvincible(player.playerId, true)

	for index, value in ipairs(spawnPoints) do
		tm.playerUI.AddUIButton(player.playerId, value, value, OnTeleportButtonPressed, value)
	end
--[CREDIT]~
	tm.playerUI.AddUILabel(player.playerId, 0, credit)
--END
	tm.players.SetPlayerSpawnLocation(player.playerId, spawnPoints[1])
	tm.players.TeleportPlayerToSpawnPoint(player.playerId, spawnPoints[1], true)
end


function Respawn_all_players()
	for index, player in ipairs(tm.players.CurrentPlayers()) do
		tm.players.SetPlayerSpawnLocation(player.playerId, spawnPoints[1])
		tm.players.TeleportPlayerToSpawnPoint(player.playerId, spawnPoints[1], true)
	end
end


---@param data UICallbackData
function OnTeleportButtonPressed(data)
	tm.players.SetPlayerSpawnLocation(data.playerId, data.data)
	tm.players.TeleportPlayerToSpawnPoint(data.playerId, data.data, true)
end


SetSpawnPoints()
tm.players.OnPlayerJoined.add(OnPlayerJoined)
