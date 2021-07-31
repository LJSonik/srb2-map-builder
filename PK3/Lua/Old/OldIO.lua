if true return end


-- !!!

maps.addCommand("save", function(p)
	if maps.customSaveMap
		maps.customSaveMap(p)
		return
	end

	maps.compressMapOld()
	local map = maps.compressedgamestate.map

	CONS_Printf(p, "--- MAP START ---")
	CONS_Printf(p, 'rawset(_G, "maps", maps or {})')
	CONS_Printf(p, "maps.maps = maps.maps or {}")
	CONS_Printf(p, "table.insert(maps.maps, {")

	CONS_Printf(p, 'version = "'..maps.MAPVERSION..'",')
	CONS_Printf(p, "w = "..map.w..", h = "..map.h..",")
	CONS_Printf(p, "backgroundtype = "..map.backgroundtype..",")
	CONS_Printf(p, "background = "..map.background..",")
	if type(map.music) == "number"
		CONS_Printf(p, "music = "..map.music..",")
	else
		CONS_Printf(p, 'music = "'..map.music..'",')
	end
	CONS_Printf(p, "spawnx = "..map.spawnx..", spawny = "..map.spawny..", spawndir = "..map.spawndir..",")

	for i = 0, map.w * map.h - 1
		CONS_Printf(p, map[i]..",")
	end

	CONS_Printf(p, "})")
	CONS_Printf(p, "--- MAP END ---")

	maps.compressedgamestate = nil
end)

maps.addCommand("load", function(p, n)
	if not maps.customLoadMap
		if savedmap
			table.insert(maps.maps, savedmap)
			savedmap = nil
		end

		if #maps.maps == 0
			CONS_Printf(p, "No map found.")
			return
		end

		if #maps.maps == 1
			n = 1
		else
			n = tonumber($)
			if n
				if n < 1 or n > #maps.maps
					CONS_Printf(p, "This map doesn't exist. Try map numbers between 1 and "..#maps.maps..".")
					return
				end
			else
				CONS_Printf(p, "load <1-"..#maps.maps..">: load a maps.map saved in a wad")
				return
			end
		end

		if maps.maps[n].version ~= maps.MAPVERSION
			CONS_Printf(p, "Wrong version. Map version is "..(maps.maps[n].version or "0.1")..", script version is "..maps.MAPVERSION..".")
			return
		end
	end

	maps.clearMap()

	if maps.customLoadMap
		maps.map = {}
		maps.map1 = {}
		maps.map2 = {}
		maps.map3 = {}
		maps.map4 = {}
		maps.bothsolid = {}
		maps.tileinfo = {}

		maps.map[1] = maps[1]
		maps.map[2] = maps[2]
		maps.map[3] = maps[3]
		maps.map[4] = maps[4]
		maps.map.bothsolid = maps.bothsolid
		maps.map.tileinfo = maps.tileinfo

		maps.refreshLocals()

		maps.customLoadMap()
	else
		maps.compressedgamestate = {}
		maps.compressedgamestate.map = maps.maps[n]
		maps.decompressMapOld()
	end

	maps.mapticker = 1
	maps.maptickerspeed = min((#maps.map1 + 1) / (30 * TICRATE), 64) -- !!!
	maps.map.actions = {}

	for i = 1, #maps.pp
		maps.spawnPlayer(i)
	end
end, 1)

--maps.addCommand("save", function(p)
--	CONS_Printf(p, "--- MAP START ---")
--	CONS_Printf(p, "maps.map = {")
--
--	CONS_Printf(p, "w = "..maps.map.w..", h = "..maps.map.h..",")
--	CONS_Printf(p, "background = "..maps.map.background..",")
--	CONS_Printf(p, "music = "..maps.map.music..",")
--	CONS_Printf(p, "spawnx = "..maps.map.spawnx..", spawny = "..maps.map.spawny..", spawndir = "..maps.map.spawndir..",")
--
--	for i = 1, (#maps.map1 + 1) / 16 * 16 - 15, 16
--		local s = ""
--		for j = i, i + 15
--			s = $..maps.map[i]..","
--		end
--		CONS_Printf(p, s)
--	end
--
--	local s = ""
--	for i = (#maps.map1 + 1) / 16 * 16 + 1, (#maps.map1 + 1)
--		s = $..maps.map[i]..","
--	end
--	if s ~= ""
--		CONS_Printf(p, s)
--	end
--
--	CONS_Printf(p, "}")
--	CONS_Printf(p, "--- MAP END ---")
--end)

--maps.addCommand("save", function(p)
--	CONS_Printf(p, "--- MAP START ---")
--
--	CONS_Printf(p, "load "..maps.map.w.." "..maps.map.h)
--
--	for i = 1, (#maps.map1 + 1) / 16 * 16 - 15, 16
--		local s = "l"
--		for j = i, i + 15
--			s = $.." "..maps.map[j]
--		end
--		CONS_Printf(p, s)
--	end
--
--	local s = "l"
--	for i = (#maps.map1 + 1) / 16 * 16 + 1, (#maps.map1 + 1)
--		s = $.." "..maps.map[i]
--	end
--	if s ~= "l "
--		CONS_Printf(p, s)
--	end
--
--	CONS_Printf(p, "--- MAP END ---")
--end)
--
--
--local mapload = nil
--
--maps.addCommand("load", function(p, w, h)
--	maps.map.w, maps.map.h = w, h
--	while #maps.map1 + 1 > maps.map.w * maps.map.h
--		table.remove(maps.map)
--	end
--	mapload = 1
--end)
--
--maps.addCommand("l", function(p, ...)
--	if not mapload return end
--
--	for i, tile in ipairs({...})
--		maps.map[mapload] = tile
--		mapload = $ + 1
--	end
--
--	if mapload > maps.map.w * maps.map.h
--		mapload = nil
--	end
--end)
