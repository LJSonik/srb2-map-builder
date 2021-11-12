maps.TILESIZE = FRACUNIT


local map, map2, map3
maps.addLocalsRefresher(function()
	map = maps.map
	map2, map3 = map[2], map[3]
end)

local TILESIZE = maps.TILESIZE


maps.tilecategories = {}

-- Tile properties
maps.tiledefs             = {}

maps.tiledefs_spawner     = {}
--maps.tiledefs_type        = {}
--maps.tiledefs_defaulttype = {}

maps.tiledefs_heightmapv  = {}
maps.tiledefs_heightmaph  = {}
maps.tiledefs_flippedv    = {}
maps.tiledefs_flippedh    = {}
maps.tiledefs_empty       = {}
maps.tiledefs_full        = {}

--maps.tiledefs_tag         = {}
--maps.tiledefs_ground      = {}
--maps.tiledefs_extra       = {}
--maps.tiledefs_extra2      = {}

-- Tile history variables
maps.tilehistory = {}
maps.tilehistoryposition = 1

maps.heightmaps = {}

-- Map
--maps.map
--maps.map1 -- Shortcut for layer 1
--maps.map2 -- Shortcut for layer 2
--maps.map3 -- Shortcut for layer 3
--maps.map4 -- Shortcut for layer 4
--maps.bothsolid -- Shortcut for map.bothsolid

--maps.tiledata -- Optional extra data for individual tiles


function maps.refreshMapShortcuts()
	maps.map1      = maps.map[1]
	maps.map2      = maps.map[2]
	maps.map3      = maps.map[3]
	maps.map4      = maps.map[4]
	maps.bothsolid = maps.map.bothsolid

	maps.refreshLocals()
end

function maps.getTile(map, layernum, tilepos)
	return map[layernum][tilepos]
end

function maps.getTileXY(map, layernum, x, y)
	return map[layernum][x + y * map.w]
end

function maps.setTile(layernum, tilepos, tiletype)
	local cl = maps.client

	if not (cl and cl.active) then
		map[layernum][tilepos] = tiletype
	end

	if cl and cl.map then
		cl.map[layernum][tilepos] = tiletype
	end
end

function maps.setTileXY(layernum, x, y, tileindex)
	maps.setTile(layernum, x + y * map.w, tileindex)
end

function maps.clearMap()
	maps.mapfilename = nil

	-- Reset map
	maps.map[1] = {}
	maps.map[2] = {}
	maps.map[3] = {}
	maps.map[4] = {}
	maps.map.bothsolid = {}

	-- Reset extra tile data
	maps.tiledata = {{}, {}, {}, {}}

	maps.refreshMapShortcuts()

	local numtiles = maps.map.w * maps.map.h
	for i = 0, numtiles - 1 do
		maps.map1[i] = 1
		maps.map2[i] = 1
		maps.map3[i] = 1
		maps.map4[i] = 1
		maps.bothsolid[i] = false
	end

	if maps.client then
		maps.refreshClientMap()
		maps.client.backup = nil
	end

	-- Reset tickers
	--maps.mapticker = 1
	--maps.maptickerspeed = min((#maps.map1 + 1) / (30 * TICRATE), 64) -- !!!
	maps.objectticker = 1

	maps.tilestorespawn = {}
	maps.tilestorespawn[2] = {}
	maps.tilestorespawn[3] = {}
	--maps.numtilestorespawn = 0

	-- Reset map spawn
	maps.map.spawnx = 3 * TILESIZE + TILESIZE / 2
	maps.map.spawny = (maps.map.h - 4) * TILESIZE - 1
	maps.map.spawndir = 2

	-- Reset players
	for _, p in ipairs(maps.pp) do
		p.buildertile = nil
		p.builderx = maps.map.spawnx / TILESIZE
		p.buildery = maps.map.spawny / TILESIZE + 1
		p.tpx, p.tpy = nil, nil
		p.spawnx, p.spawny = nil, nil
		p.scrollx, p.scrolly = 0, 0 -- !!!
		maps.enterEditor(p)
	end

	-- Reset objects
	maps.objects = {}

	-- Reset blockmap
	maps.createBlockmap()

	-- !!!!
	--maps.objtype[1] = 1
	--maps.objw[1] = maps.OBJECT_WIDTH
	--maps.objh[1] = maps.OBJECT_HEIGHT
	--maps.objx[1] = 8 * TILESIZE
	--maps.objy[1] = (maps.map.h - 4) * TILESIZE - maps.objh[1]
	--maps.objdir[1] = 1
	--maps.objspr[1] = bluecrawlaanim.spd -- !!!

	--for i = 1, 1000
	--	maps.objtype[i] = 1
	--	maps.objw[i] = maps.OBJECT_WIDTH
	--	maps.objh[i] = maps.OBJECT_HEIGHT
	--	maps.objx[i] = P_RandomRange(8 * 8, 32 * 8) * FRACUNIT
	--	maps.objy[i] = (maps.map.h - 4) * TILESIZE - maps.objh[1]
	--	maps.objdir[i] = P_RandomRange(1, 2)
	--	maps.objspr[i] = bluecrawlaanim.spd -- !!!
	--end

	-- Reset tile history
	maps.tilehistory = {}
	maps.tilehistoryposition = 1
end

function maps.refreshClientMap()
	local clmap = {}
	local numtiles = maps.map.w * maps.map.h

	clmap.w, clmap.h = maps.map.w, maps.map.h

	for layernum, layer in ipairs(maps.map) do
		local cllayer = {}
		clmap[layernum] = cllayer

		for i = 0, numtiles - 1 do
			cllayer[i] = layer[i]
		end
	end

	maps.client.map = clmap
end

/*function maps.handleMapTicker()
	local numtiles = #maps.map1 + 1
	for i = 1, maps.maptickerspeed
		local tile = maps.tiledefs_type[maps.map1[maps.mapticker]]

		if tile == 13 or tile == 14 -- Got ring or monitor -- !!!
			maps.map1[maps.mapticker] = maps.tiledefs_tag[$]
		elseif tile == 18 -- Star post -- !!!
			local t = maps.map1[maps.mapticker]
			if maps.tiledefs_tag[t] < t
				maps.map1[maps.mapticker] = maps.tiledefs_tag[$]
			end
		end

		maps.mapticker = $ % numtiles
	end
end*/
