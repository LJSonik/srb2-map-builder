maps.BLOCKMAP_SIZE = 8 * maps.TILESIZE


-- Blockmap
--maps.blockmap -- For fast collision detection
--maps.blockmaplen -- Number of objects in each block (unused?)
--maps.blockmapw, maps.blockmaph -- Size in blocks


function maps.insertObjectInBlockmap(o)
	if o.inblockmap then return end
	o.inblockmap = true
	--if not o.blockmap return end

	local x, y = o.l / maps.BLOCKMAP_SIZE, o.t / maps.BLOCKMAP_SIZE
	local block = maps.blockmap[x + y * maps.blockmapw]

	--block[#block + 1] = o -- Add object to the end of the block

	-- Find a hole in the block
	for i = 1, #block do
		local o2 = block[i]
		if not o2 then
			block[i] = o -- Add object to the hole
			return
		end
	end
	block[#block + 1] = o -- Add object to the end of the block
end

function maps.removeObjectFromBlockmap(o)
	if not o.inblockmap then return end
	o.inblockmap = nil
	--if not o.blockmap return end

	local x, y = o.l / maps.BLOCKMAP_SIZE, o.t / maps.BLOCKMAP_SIZE
	local block = maps.blockmap[x + y * maps.blockmapw]
	local blocklen = #block

	/*for i = 1, blocklen
		local o2 = block[i]
		if o == o2
			block[i] = block[blocklen]
			block[blocklen] = nil
			return
		end
	end*/

	for i = 1, blocklen do
		local o2 = block[i]
		if o == o2 then
			if i == blocklen then -- Last object in the block
				block[i] = nil
			else -- Object in middle of the block
				block[i] = false
			end
			return
		end
	end
end

function maps.createBlockmap()
	maps.blockmap = {}
	maps.blockmapw = (maps.map.w * maps.TILESIZE + maps.BLOCKMAP_SIZE - 1) / maps.BLOCKMAP_SIZE
	maps.blockmaph = (maps.map.h * maps.TILESIZE + maps.BLOCKMAP_SIZE - 1) / maps.BLOCKMAP_SIZE

	local BLOCKMAP_SIZE = maps.BLOCKMAP_SIZE
	local blockmap = maps.blockmap
	local blockmapw = maps.blockmapw

	local numblocks = maps.blockmapw * maps.blockmaph
	for i = 0, numblocks - 1 do
		maps.blockmap[i] = {}
	end

	for i = 1, #maps.objects do
		local o = objects[i]

		if o and o.blockmap then
			local x, y = o.l / BLOCKMAP_SIZE, o.t / BLOCKMAP_SIZE
			local block = blockmap[x + y * blockmapw]
			block[#block + 1] = o -- Add object to the end of the block
		end
	end

	maps.refreshLocals()
end
