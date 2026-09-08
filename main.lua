tm.os.DoFile("scripts/mapReparser")
tm.os.DoFile("libraries/debug")
tm.os.DoFile("libraries/timer")
tm.os.DoFile("scripts/preprocessor")
tm.os.DoFile("scripts/ui")
tm.os.DoFile("scripts/internal_map_loader")
tm.os.DoFile("scripts/spawnPointSetup")

---@type ReparserSettings
local settings = NewReparserSettings()

tm.os.SetModTargetDeltaTime(1/60)

function update()
	timer.UpdateTimers()
	Update_map_loader()
end

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

	tm.playerUI.AddUILabel(0, 0, "<align=left>Advanced Spawn Points Allows")
	tm.playerUI.AddUILabel(0, 0, "<align=left>for multiple Spawn point and")
	tm.playerUI.AddUILabel(0, 0, "<align=left>enables an teleportation menu")
	tm.playerUI.AddUILabel(0, 0, "<align=left>when more then 1 Spawn Point is")
	tm.playerUI.AddUILabel(0, 0, "<align=left>setup also makes sure players")
	tm.playerUI.AddUILabel(0, 0, "<align=left>dont respawn inside each other")
	tm.playerUI.AddUILabel(0, 0, "<align=left>in mulitplayer")
	tm.playerUI.AddUILabel(0, 0, "<align=left>trailmappers behavour: [False]")
	AddToggleButton(0, "spawnPoints", "Advanced Spawn Points", settings.newSpawnPoints, UseNewSpawnPoints)
	if settings.newSpawnPoints then
		tm.playerUI.AddUILabel(0, 0, "<align=left>if true respawns the player when")
		tm.playerUI.AddUILabel(0, 0, "<align=left>the map finished loading")
		AddToggleButton(0, "respawnOnComplete", "respawn on complete", settings.RespawnOnComplete, SetToggleSetting, "RespawnOnComplete")
		tm.playerUI.AddUILabel(0, 0, "<align=left> Spawn Point Radius (m)")
		tm.playerUI.AddUIText(0, "spawnRadius", settings.spawnRadius, SetNumberSetting, "spawnRadius")
		tm.playerUI.AddUILabel(0, 0, "<align=left>Teleport Menu Header")
		tm.playerUI.AddUILabel(0, 0, "<align=left>Leave empty to hide")
		tm.playerUI.AddUIText(0, "spawnMenuHeader", settings.spawnMenuHeader, SetTextSetting, "spawnMenuHeader")
		tm.playerUI.AddUILabel(0, 0, "<align=left>Teleport Menu credit")
		tm.playerUI.AddUILabel(0, 0, "<align=left>Leave empty to hide")
		tm.playerUI.AddUIText(0, "credit", settings.credit, SetTextSetting, "credit")
		tm.playerUI.AddUILabel(0, 0, "---------------------------------------------")
	end

	tm.playerUI.AddUILabel(0, 0, "<align=left>If true enables 0g while loading")
	AddToggleButton(0, "0gloader", "0g loading", settings.zeroG, SetToggleSetting, "zeroG")
	tm.playerUI.AddUILabel(0, 0, "<align=left>default Time Of day, -1 to disable")
	tm.playerUI.AddUIText(0, "timeOfDay", settings.defaultTimeOfDay, SetNumberSetting, "defaultTimeOfDay")
	tm.playerUI.AddUILabel(0, 0, "<align=left>If true shows a loading bar")
	AddToggleButton(0, "progressbar", "use progress bar", settings.progressBar, SetToggleSetting, "progressBar")

	tm.playerUI.AddUILabel(0, 0, "---------------------------------------------")
	tm.playerUI.AddUIButton(0, "reparse", "Create", SetupReparser)
end

function SetupReparser()
	tm.playerUI.ClearUI(0)
	tm.playerUI.AddUILabel(0, "l", "Loading material setup...")
	timer.Create(0.02, ReparseMap, settings)
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
