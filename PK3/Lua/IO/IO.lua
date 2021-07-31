-- Todo:
-- IMPORTANT: when updating map format, use uint32 for use count in Huffman encoder


-- When serialised, each location in the map is stored on 32 bits:
--     -  0-11: ID of the first tile
--     - 12-23: ID of the second tile
--     - 24-25: Layer on which the first tile is located
--     - 26-27: Layer on which the second tile is located
--     -    28: 1 if both tiles are solid
--     - 29-31: reserved for future use


local bs = ljrequire "bytestream"


local MAPVERSION = "0.4"


maps.mapfilename = nil


function maps.readMap(stream, map, fromfile)
	map = $ or {}

	if fromfile then
		local version = bs.readString(stream)
		if version ~= MAPVERSION then
			return nil, "Wrong version. Map version is "..version..", script version is "..MAPVERSION.."."
		end
	end

	map.w = bs.readInt32(stream)
	map.h = bs.readInt32(stream)

	map.backgroundtype = bs.readByte  (stream)
	map.background     = bs.readUInt16(stream)

	map.music = bs.readString(stream)

	map.spawnx   = bs.readInt32(stream)
	map.spawny   = bs.readInt32(stream)
	map.spawndir = bs.readInt32(stream)

	-- Fill all layers with default values
	for layer = 1, 4 do
		map[layer] = {}
		for i = 0, map.w * map.h - 1 do
			map[layer][i] = 1
		end
	end
	map.bothsolid = {}

	local serialisedids = {}
	if fromfile then
		while true do
			local id = bs.readString(stream)
			if id == "" then break end
			table.insert(serialisedids, maps.tiledefs[id].index)
		end
	end

	local tiles1 = maps.readHuffman(stream, map.w * map.h, 16)
	local tiles2 = maps.readHuffman(stream, map.w * map.h, 16)
	local extras = maps.readHuffman(stream, map.w * map.h, 8)

	for i = 0, map.w * map.h - 1 do
		local tile1 = tiles1[i]
		local tile2 = tiles2[i]
		local extra = extras[i]

		if fromfile then
			tile1 = serialisedids[tile1]
			tile2 = serialisedids[tile2]
		end

		map.bothsolid[i] = (extra & 16 ~= 0)

		if tile1 ~= 1 then
			local layer = ((extra >> 0) & 3) + 1
			map[layer][i] = tile1
		end
		if tile2 ~= 1 then
			local layer = ((extra >> 2) & 3) + 1
			map[layer][i] = tile2
		end
	end

	return map
end

function maps.writeMap(stream, map, fromfile)
	if fromfile then
		bs.writeString(stream, MAPVERSION)
	end

	bs.writeInt32(stream, map.w)
	bs.writeInt32(stream, map.h)

	bs.writeByte  (stream, map.backgroundtype)
	bs.writeUInt16(stream, map.background)

	bs.writeString(stream, map.music)

	bs.writeInt32(stream, map.spawnx)
	bs.writeInt32(stream, map.spawny)
	bs.writeInt32(stream, map.spawndir)

	local serialisedids = {}
	local serialisedid = 1
	for layernum = 1, 4 do
		local layer = map[layernum]
		for i = 0, map.w * map.h - 1 do
			local tile = layer[i]

			if not serialisedids[tile] then
				if fromfile then
					-- If it's a temporary tile (picked ring, extended spring, etc),
					-- store its original tile instead
					local def = maps.tiledefs[tile]
					if def.respawn then
						local origtile = tile - 1
						if not serialisedids[origtile] then
							serialisedids[origtile] = serialisedid
							bs.writeString(stream, maps.tiledefs[origtile].id)
							serialisedid = serialisedid + 1
						end
						serialisedids[tile] = serialisedids[origtile]
					else
						serialisedids[tile] = serialisedid
						bs.writeString(stream, maps.tiledefs[tile].id)
						serialisedid = serialisedid + 1
					end
				else
					serialisedids[tile] = tile
				end
			end
		end
	end
	if fromfile then
		bs.writeString(stream, "")
	end

	local tiles1 = {}
	local tiles2 = {}
	local extras = {}
	for i = 0, map.w * map.h - 1 do
		local tile1, tile2 = 1, 1
		local extra = 0

		if map.bothsolid[i] then
			extra = $ | 16
		end

		for layer = 1, 4 do
			if map[layer][i] ~= 1 then
				if tile1 == 1 then
					extra = $ | ((layer - 1) << 0)
					tile1 = serialisedids[map[layer][i]]
				else
					extra = $ | ((layer - 1) << 2)
					tile2 = serialisedids[map[layer][i]]
				end
			end
		end

		tiles1[i] = tile1
		tiles2[i] = tile2
		extras[i] = extra
	end

	maps.writeHuffman(stream, tiles1, 16)
	maps.writeHuffman(stream, tiles2, 16)
	maps.writeHuffman(stream, extras, 8)
end


function maps.readMapOld(stream, map)
	map = $ or {}

	if fromfile then
		local version = bs.readString(stream)
		if version ~= MAPVERSION then
			return nil, "Wrong version. Map version is "..version..", script version is "..MAPVERSION.."."
		end
	end

	map.w = bs.readInt32(stream)
	map.h = bs.readInt32(stream)

	map.backgroundtype = bs.readByte  (stream)
	map.background     = bs.readUInt16(stream)

	map.music = bs.readString(stream)

	map.spawnx   = bs.readInt32(stream)
	map.spawny   = bs.readInt32(stream)
	map.spawndir = bs.readInt32(stream)

	local serialisedids = {}
	while true do
		local id = bs.readString(stream)
		if id == "" then break end
		table.insert(serialisedids, maps.tiledefs[id].index)
	end

	-- Fill all layers with default values
	for layer = 1, 4 do
		map[layer] = {}
		for i = 0, map.w * map.h - 1 do
			map[layer][i] = 1
		end
	end
	map.bothsolid = {}

	for i = 0, map.w * map.h - 1 do
		local tile = bs.readInt32(stream)

		local tile1 = (tile      ) & 4095
		local tile2 = (tile >> 12) & 4095
		local extra = (tile >> 24) & 255

		map.bothsolid[i] = (extra & 16 ~= 0)

		if tile1 ~= 1 then
			local layer = ((extra >> 0) & 3) + 1
			map[layer][i] = serialisedids[tile1]
		end
		if tile2 ~= 1 then
			local layer = ((extra >> 2) & 3) + 1
			map[layer][i] = serialisedids[tile2]
		end
	end

	return map
end

function maps.writeMapOld(stream, map)
	if fromfile then
		bs.writeString(stream, MAPVERSION)
	end

	bs.writeInt32(stream, map.w)
	bs.writeInt32(stream, map.h)

	bs.writeByte  (stream, map.backgroundtype)
	bs.writeUInt16(stream, map.background)

	bs.writeString(stream, map.music)

	bs.writeInt32(stream, map.spawnx)
	bs.writeInt32(stream, map.spawny)
	bs.writeInt32(stream, map.spawndir)

	local serialisedids = {}
	local serialisedid = 1
	for i = 0, map.w * map.h - 1 do
		for layer = 1, 4 do
			local tile = map[layer][i]
			if not serialisedids[tile] then
				serialisedids[tile] = serialisedid
				bs.writeString(stream, maps.tiledefs[tile].id)
				serialisedid = serialisedid + 1
			end
		end
	end
	bs.writeString(stream, "")

	for i = 0, map.w * map.h - 1 do
		local tile1, tile2 = 1, 1
		local extra = 0

		if map.bothsolid[i] then
			extra = $ | 16
		end

		for layer = 1, 4 do
			if map[layer][i] ~= 1 then
				if tile1 == 1 then
					extra = $ | ((layer - 1) << 0)
					tile1 = serialisedids[map[layer][i]]
				else
					extra = $ | ((layer - 1) << 2)
					tile2 = serialisedids[map[layer][i]]
				end
			end
		end

		bs.writeInt32(stream, tile1 | (tile2 << 12) | (extra << 24))
	end
end

local function cleanupName(name)
	-- The duplicate is intentional
	for _, s in ipairs{"^Maps/", "^Maps/", "%.dat$", "%.map$"} do
 		name = $:gsub(s, "")
	end

	return "Maps/Maps/"..name..".map.dat"
end

local function concatCommandArgs(...)
	local s
	for _, word in ipairs({...}) do
		if s then
			s = s.." "..word
		else
			s = word
		end
	end
	return s
end

local function fileExists(filename)
	local file = io.openlocal(filename, "r")
	if file then
		file:close()
		return true
	else
		return false
	end
end


maps.addCommand("save", function(p, ...)
	local filename = concatCommandArgs(...)

	if filename then
		filename = cleanupName($)
		if filename == maps.mapfilename then
			CONS_Printf(p, "\x83NOTICE:\x80 you can omit the file name when saving.")
		end
	else
		filename = maps.mapfilename
		if not filename then
			CONS_Printf(p, "save [file name]: save the map")
			CONS_Printf(p, "Maps are saved in luafiles/Maps/Maps/ if you are the host,")
			CONS_Printf(p, "or in luafiles/client/Maps/Maps/ if you are a client.")
			CONS_Printf(p, "Note that this only saves the map on your end.")
			return
		end
	end

	local stream = bs.create()
	maps.writeMap(stream, maps.map, true)

	local realfilename = filename
	if p ~= server then
		realfilename = "client/"..$
	end

	if filename ~= maps.mapfilename and fileExists(realfilename) then
		CONS_Printf(p, "\x85".."ERROR:".."\x80 another map with the same name already exists.")
		CONS_Printf(p, "Remove the file manually if you actually want to override it.")
		return
	end

	local file = io.openlocal(realfilename, "wb")
	file:write(bs.bytesToString(stream.bytes))
	file:close()

	maps.mapfilename = filename
end, COM_LOCAL)

maps.addCommand("load", function(p, ...)
	local filename = concatCommandArgs(...)

	if not filename then
		CONS_Printf(p, "load <file name>: load a map")
		CONS_Printf(p, "Maps are saved in luafiles/Maps/Maps/ inside your SRB2 folder.")
		return
	end

	filename = cleanupName($)

	io.open(filename, "rb", function(file)
		if not file then
			CONS_Printf(p, "\x85".."ERROR:".."\x80 the map could not be opened.")
			return
		end

		local bytes = bs.stringToBytes(file:read(INT32_MAX))

		local stream = bs.create(bytes)
		local map, errormsg = maps.readMap(stream, nil, true)
		if not map then
			CONS_Printf(p, errormsg)
			return
		end

		maps.clearMap()

		maps.map = map
		maps.refreshMapShortcuts()
		if maps.client then
			maps.refreshClientMap()
		end

		maps.createBlockmap() -- !!!

		maps.mapticker = 1
		maps.maptickerspeed = min((maps.map.w * maps.map.h + 1) / (30 * TICRATE), 64) -- !!!

		for _, p in ipairs(maps.pp) do
			maps.spawnPlayer(p)
		end

		-- Only remember the name locally, as the name chosen by the server
		-- might already be used for something else in the clients' folders
		if p == consoleplayer then
			maps.mapfilename = filename
		end
	end)

	/*if #maps.maps == 0
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
	end*/
end, COM_ADMIN)
