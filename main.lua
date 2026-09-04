tm.os.DoFile("scripts/mapReparser")
tm.os.DoFile("libraries/debug")
tm.os.DoFile("scripts/preprocessor")

---@type ReparserSettings
local settings = NewReparserSettings()

tm.os.SetModTargetDeltaTime(1/60)

---@param player ModPlayer
function OnPlayerJoined(player)
	if player.playerId != 0 then
		return
	end

	tm.playerUI.AddUIButton(0, "reparser", "Create Map", CreateMap)
	tm.playerUI.AddUIButton(0, "spawn", "Setup Spawn Points", SetupSpawn)
	tm.playerUI.AddUIButton(0, "merger", "Merge Maps", MergeMaps)
end

function CreateMap()
	tm.playerUI.ClearUI(0)

	settings.newSpawnPoints = true

	tm.playerUI.AddUIButton(0, "spawnPoints", "newSpawnPoints", NULL)
	if settings.newSpawnPoints then
		tm.playerUI.AddUIButton(0, "respawnOnComplete", "respawn on complete", NULL)
		tm.playerUI.AddUIText(0, "spawnRadius", settings.spawnRadius, NULL)
		tm.playerUI.AddUIText(0, "spawnMenuHeader", settings.spawnMenuHeader, NULL)
		tm.playerUI.AddUIText(0, "credit", settings.credit, NULL)
	end

	tm.playerUI.AddUIButton(0, "0gloader", "0g loading", NULL)
	tm.playerUI.AddUIText(0, "timeOfDay", settings.defaultTimeOfDay, NULL)
	tm.playerUI.AddUIButton(0, "progressbar", "use progress bar", NULL)
end

function SetupSpawn()
	
end

function MergeMaps()
	
end

function NULL()
	
end

-- ReparseMap()

-- local s = ResolveMarcos(tm.os.ReadAllText_Static("scripts/mapLoader.lua"), {"SPAWN"})
-- s = SetVariable(s, "objectIndex", 2)
--
-- tm.os.Log(s)

tm.players.OnPlayerJoined.add(OnPlayerJoined)
