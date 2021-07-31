-- For compressing the gamestate when sending it to joiners


local bytestream = ljrequire "bytestream"


maps.compressedgamestate = nil


local function compressBlockmap()
	local blockmap = maps.blockmap

	local compressedblockmap = {}
	local compressedblockmappositions = {}
	for i = 0, maps.blockmapw * maps.blockmaph - 1 do
		local block = blockmap[i]

		local empty = true
		for j = 1, #block do
			if block[j] then
				empty = false
				break
			end
		end

		--if block[1]
		if not empty then
			local compressedblock = {}
			for j = 1, #block do
				compressedblock[#compressedblock + 1] = block[j]
			end
			compressedblockmap[#compressedblockmap + 1] = compressedblock
			compressedblockmappositions[#compressedblockmappositions + 1] = i
		end
	end

	maps.compressedgamestate.blockmap = compressedblockmap
	maps.compressedgamestate.blockmappositions = compressedblockmappositions
	maps.compressedgamestate.blockmapw = maps.blockmapw
	maps.compressedgamestate.blockmaph = maps.blockmaph
end

local function decompressBlockmap()
	maps.blockmap = {}
	maps.blockmapw = maps.compressedgamestate.blockmapw
	maps.blockmaph = maps.compressedgamestate.blockmaph

	local compressedblockmap = maps.compressedgamestate.blockmap
	local compressedblockmappositions = maps.compressedgamestate.blockmappositions
	local blockmap = maps.blockmap

	local numblocks = maps.blockmapw * maps.blockmaph
	for i = 0, numblocks - 1 do
		blockmap[i] = {}
	end

	for i = 1, #compressedblockmap do
		local compressedblock = compressedblockmap[i]
		local block = blockmap[compressedblockmappositions[i]]
		for j = 1, #compressedblock do
			block[j] = compressedblock[j]
		end
	end
end

-- !!!!
local cv_altgs = CV_RegisterVar{"altgs", "Off", CV_NETVAR, CV_OnOff}

function maps.compressGamestate()
	maps.compressedgamestate = {}

	local stream = bytestream.create()

	if cv_altgs.value then
		maps.writeMapOld(stream, maps.map)
	else
		maps.writeMap(stream, maps.map)
	end

	compressBlockmap()

	maps.compressedgamestate.stream = bytestream.bytesToString(stream.bytes)
end

function maps.decompressGamestate()
	local bytes = bytestream.stringToBytes(maps.compressedgamestate.stream)
	local stream = bytestream.create(bytes)

	if cv_altgs.value then
		maps.map = maps.readMapOld(stream)
	else
		maps.map = maps.readMap(stream)
	end
	maps.refreshMapShortcuts()

	decompressBlockmap()
	maps.refreshLocals()

	maps.compressedgamestate = nil
end
