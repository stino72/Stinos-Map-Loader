local copySpawnPoints = true
local map_a = ""
local map_b = ""
local new_name = "Combined Map"

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

	mapA["custom meshes"] = AppendTable(mapA["custom meshes"], mapB["custom meshes"])
	mapA["custom textures"] = AppendTable(mapA["custom textures"], mapB["custom textures"])
	mapA["materials"] = AppendTable(mapA["materials"], mapB["materials"])

	local new_objects = {}
	for i = 1, mapA["custom objects indice"] - 1, 1 do
		table.insert(new_objects, mapA["objects"][i])
	end

	for i = 1, mapB["custom objects indice"] - 1, 1 do
		local obj = mapB["objects"][i]
		obj["i"]["modelId"] = obj["i"]["modelId"] + meshes
		obj["i"]["textureId"] = obj["i"]["textureId"] + textures
		table.insert(new_objects, obj)
	end

	for i = mapA["custom objects indice"], mapA["custom objects collision indice"] - 1, 1 do
		table.insert(new_objects, mapA["objects"][i])
	end

	for i = mapB["custom objects indice"], mapB["custom objects collision indice"] - 1, 1 do
		local obj = mapB["objects"][i]
		obj["i"]["modelId"] = obj["i"]["modelId"] + meshes
		obj["i"]["textureId"] = obj["i"]["textureId"] + textures
		table.insert(new_objects, obj)
	end

	for i = mapA["custom objects collision indice"], mapA["custom objects physics indice"] - 1, 1 do
		table.insert(new_objects, mapA["objects"][i])
	end

	for i = mapB["custom objects collision indice"], mapB["custom objects physics indice"] - 1, 1 do
		local obj = mapB["objects"][i]
		obj["i"]["modelId"] = obj["i"]["modelId"] + meshes
		obj["i"]["textureId"] = obj["i"]["textureId"] + textures
		table.insert(new_objects, obj)
	end

	for i = mapA["custom objects physics indice"], #mapA["objects"], 1 do
		table.insert(new_objects, mapA["objects"][i])
	end

	for i = mapB["custom objects physics indice"], #mapB["objects"], 1 do
		table.insert(new_objects, mapB["objects"][i])
	end

	mapA["objects"] = new_objects

	mapA["custom objects indice"] = mapA["custom objects indice"] + mapB["custom objects indice"] - 1
	mapA["custom objects collision indice"] = mapA["custom objects collision indice"] + mapB["custom objects collision indice"] - 1
	mapA["custom objects physics indice"] = mapA["custom objects physics indice"] + mapB["custom objects physics indice"] - 1

	tm.os.WriteAllText_Dynamic(new_name .. "/data_static/map.json", Encode(mapA))
	tm.os.WriteAllText_Dynamic(new_name .. "/main.lua", tm.os.ReadAllText_Dynamic(map_a .. "/main.lua"))

	local spawnPointLoader = tm.os.ReadAllText_Dynamic(map_a .. "/data_static/spawn_points.lua")
	if spawnPointLoader == "" then
		return
	end

	local spawnPointsA = tm.os.ReadAllText_Dynamic(map_a .. "/data_static/spawn_points.json")
	if spawnPointsA == "" then
		return
	end

	tm.os.WriteAllText_Dynamic(new_name .. "/data_static/spawn_points.lua", spawnPointLoader)
	if copySpawnPoints == false then
		tm.os.WriteAllText_Dynamic(new_name .. "/data_static/spawn_points.json", spawnPointsA)
		return
	end

	local spawnPointsB = tm.os.ReadAllText_Dynamic(map_b .. "/data_static/spawn_points.json")
	if spawnPointsB == "" then
		tm.os.WriteAllText_Dynamic(new_name .. "/data_static/spawn_points.json", spawnPointsA)
		return
	end

	local newSpawnPoints = AppendTable(json.parse(spawnPointsA), json.parse(spawnPointsB))
	tm.os.WriteAllText_Dynamic(new_name .. "/data_static/spawn_points.json", json.serialize(newSpawnPoints))
end
