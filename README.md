# Stino's Map loader v0.2

## Map Re-Export:
1. Move the MAP file that is exported by trailmappers into `/data_static/`
2. Copy all textures into the mod folder (in the same place they are in a trailmappers export)
3. Load the Mod and select **Re-Export Map**
4. configure the Export settings and press **Re-Export** to continue
5. Select the material for each texture.
6. If **Advanced Spawn Points** is True, Wait for the map to load and setup all Spawn Points and press **Save Spawn Points** to save
7. Copy the `map.json` file in `/data_dynamic/<map name>/data_static/` to `/data_static/` in the trailmappers export
8. Replace the `main.lua` file in the trailmappers export with `data_dynamic/<map name>/main.lua`
9. If **Advanced Spawn Points** is True, copy `spawn_points.json` and `spawn_points.lua` to `/data_static` in the trailmappers export
10. (optional) Delete the old MAP file from the trailmappers export
11. (optional) Delete the `LoadIcon.png` since this map loader doesn't use into
12. Load the map

## Export Settings:
**Advanced Spawn Points:** Allows for multiple Spawn point and enables an teleportation menu when more then 1 Spawn Point is setup. Also makes sure players dont respawn inside each other in mulitplayer<br>
    **Respawn On Complete:** if true respawns all players when the Map finishes Loading<br>
    **Spawn Point Radius(m):** distance the multiplayer spawn points are away from the center<br>
    **Teleport Menu Header:** text shown at the top of the teleport menu, leave empty to hide<br>
    **Teleport Menu Credit:** text shown at the bottom of the teleport menu, leave empty to hide<br>
**0g Loading:** If true the player will be put in 0g while the map is loading<br>
**Default Time of Day:** Sets the time of day when the map is loaded, set to -1 to disable<br>
**Show Progress Bar:** If true shows a progress bar of how many object are loaded and still need to be loaded<br>

## Combine Maps:
1. Re-Export both Map A and Map B
2. Put the Name of the Base map in Map A (this will be the map the settings get taken from)
3. Put the Name of second map in Map B
4. Set the Name of the Combined Map (If its the Same as either Map that Map Will be overwriten)
5. Set **Copy Spawn Points**, if True the Spawn Points for Map B will be copied To Map A (Ignored if either Map doesn't have **Advanced Spawn Points** enabled)
6. The Map is Exported to `data_dynamic/<combined map name>` and copy it to the mods folder
7. Copy the Custom Models and Textures from both maps to the combined Map
