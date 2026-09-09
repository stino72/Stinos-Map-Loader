tm.os.DoFile("scripts/mapReparser")
tm.os.DoFile("libraries/debug")
tm.os.DoFile("libraries/timer")
tm.os.DoFile("scripts/preprocessor")
tm.os.DoFile("scripts/ui")
tm.os.DoFile("scripts/internal_map_loader")
tm.os.DoFile("scripts/spawnPointSetup")

---@class MapSave
---@field reparserSettings ReparserSettings
---@field spawnPoints SpawnPointData[]
local MapSave = {}
MapSave.__index = MapSave

---@return MapSave[]
function GetSaveFile()
	local s = tm.os.ReadAllText_Dynamic("settings.json")
	if s == "" then
		return {}
	end
	return json.parse(s)
end

---@type MapSave[]
SAVE_FILE = GetSaveFile()

MAP = json.parse(tm.os.ReadAllText_Static("map"))

---@type string
MAP_NAME = MAP["Name"]

---@type ReparserSettings
SETTINGS = NewReparserSettings()

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

	tm.os.Log(MAP_NAME)
	if SAVE_FILE[MAP_NAME] then
		SETTINGS = SAVE_FILE[MAP_NAME].reparserSettings
	else
		SAVE_FILE[MAP_NAME] = setmetatable({}, MapSave)
	end

	tm.playerUI.AddUIButton(0, "reparser", "Create Map", CreateMap)
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
	AddToggleButton(0, "spawnPoints", "Advanced Spawn Points", SETTINGS.newSpawnPoints, UseNewSpawnPoints)
	if SETTINGS.newSpawnPoints then
		tm.playerUI.AddUILabel(0, 0, "<align=left>if true respawns the player when")
		tm.playerUI.AddUILabel(0, 0, "<align=left>the map finished loading")
		AddToggleButton(0, "respawnOnComplete", "respawn on complete", SETTINGS.RespawnOnComplete, SetToggleSetting, "RespawnOnComplete")
		tm.playerUI.AddUILabel(0, 0, "<align=left> Spawn Point Radius (m)")
		tm.playerUI.AddUIText(0, "spawnRadius", SETTINGS.spawnRadius, SetNumberSetting, "spawnRadius")
		tm.playerUI.AddUILabel(0, 0, "<align=left>Teleport Menu Header")
		tm.playerUI.AddUILabel(0, 0, "<align=left>Leave empty to hide")
		tm.playerUI.AddUIText(0, "spawnMenuHeader", SETTINGS.spawnMenuHeader, SetTextSetting, "spawnMenuHeader")
		tm.playerUI.AddUILabel(0, 0, "<align=left>Teleport Menu credit")
		tm.playerUI.AddUILabel(0, 0, "<align=left>Leave empty to hide")
		tm.playerUI.AddUIText(0, "credit", SETTINGS.credit, SetTextSetting, "credit")
		tm.playerUI.AddUILabel(0, 0, "---------------------------------------------")
	end

	tm.playerUI.AddUILabel(0, 0, "<align=left>If true enables 0g while loading")
	AddToggleButton(0, "0gloader", "0g loading", SETTINGS.zeroG, SetToggleSetting, "zeroG")
	tm.playerUI.AddUILabel(0, 0, "<align=left>default Time Of day, -1 to disable")
	tm.playerUI.AddUIText(0, "timeOfDay", SETTINGS.defaultTimeOfDay, SetNumberSetting, "defaultTimeOfDay")
	tm.playerUI.AddUILabel(0, 0, "<align=left>If true shows a loading bar")
	AddToggleButton(0, "progressbar", "use progress bar", SETTINGS.progressBar, SetToggleSetting, "progressBar")

	tm.playerUI.AddUILabel(0, 0, "---------------------------------------------")
	tm.playerUI.AddUIButton(0, "reparse", "Create", SetupReparser)
end

function SetupReparser()
	tm.playerUI.ClearUI(0)
	tm.playerUI.AddUILabel(0, "l", "Loading material setup...")
	SAVE_FILE[MAP_NAME].reparserSettings = SETTINGS
	tm.os.WriteAllText_Dynamic("settings.json", json.serialize(SAVE_FILE))
	timer.Create(0.02, ReparseMap)
end

---@param data ToggleCallbackData
function UseNewSpawnPoints(data)
	SETTINGS.newSpawnPoints = data.state
	CreateMap()
end

---@param data ToggleCallbackData
function SetToggleSetting(data)
	SETTINGS[data.data] = data.state
end

---@param data UICallbackData
function SetTextSetting(data)
	Print(data.value)
	SETTINGS[data.data] = data.value
end

---@param data UICallbackData
function SetNumberSetting(data)
	if data.value == "" or data.value == "." or data.value == "-" then
		SETTINGS[data.data] = 0
		return
	end
	local n = tonumber(data.value)
	if n == nil then
		tm.playerUI.SetUIValue(0, data.id, SETTINGS[data.data])
		return
	end
	SETTINGS[data.data] = n
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
