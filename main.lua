tm.os.DoFile("scripts/mapReparser")
tm.os.DoFile("libraries/debug")
tm.os.DoFile("scripts/preprocessor")
tm.os.DoFile("scripts/ui")

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

	AddToggleButton(0, "spawnPoints", "newSpawnPoints", settings.newSpawnPoints, UseNewSpawnPoints)
	if settings.newSpawnPoints then
		AddToggleButton(0, "respawnOnComplete", "respawn on complete", settings.RespawnOnComplete, SetToggleSetting, "RespawnOnComplete")
		tm.playerUI.AddUIText(0, "spawnRadius", settings.spawnRadius, SetNumberSetting, "spawnRadius")
		tm.playerUI.AddUIText(0, "spawnMenuHeader", settings.spawnMenuHeader, SetTextSetting, "spawnMenuHeader")
		tm.playerUI.AddUIText(0, "credit", settings.credit, SetTextSetting, "credit")
	end

	AddToggleButton(0, "0gloader", "0g loading", settings.zeroG, SetToggleSetting, "zeroG")
	tm.playerUI.AddUIText(0, "timeOfDay", settings.defaultTimeOfDay, SetNumberSetting, "defaultTimeOfDay")
	AddToggleButton(0, "progressbar", "use progress bar", settings.progressBar, SetToggleSetting, "progressBar")

	tm.playerUI.AddUIButton(0, "reparse", "Create", ReparseMap, settings)
end

---@param data ToggleCallbackData
function UseNewSpawnPoints(data)
	settings.newSpawnPoints = data.state
	CreateMap()
end

---@param data ToggleCallbackData
function SetToggleSetting(data)
	settings[data.data] = data.state
end

---@param data UICallbackData
function SetTextSetting(data)
	Print(data.value)
	settings[data.data] = data.value
end

---@param data UICallbackData
function SetNumberSetting(data)
	local n = tonumber(data.value)
	if n == nil then
		return
	end
	settings[data.data] = n
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
