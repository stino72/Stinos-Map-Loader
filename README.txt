Stino's Map loader v0.1

Setup:
1. Move the MAP file that is exported by trailmappers into /data_static/
2. (optional but recommend) Copy all textures into the mod folder (in the same place they are in a trailmappers export)
3. Load the Mod and select the material for each texture.
4. Move the map.json file in /data_dynamic/<map name>/ to /data_static/ in the trailmappers export
5. (optional) Delete the old MAP file from the trailmappers export
6. Replace the main.lua file in the trailmappers export with the main.lua file in /data_dynamic/<map name>/
7. (optional) Delete the LoadIcon.png since this map loader doesn't use into
8. Load the map

Might not fully work for all hardware/maps yet, it just needs more testing rn.