if true return end


function maps.objectsInArea(x1, y1, x2, y2)
	local objx, objy = maps.objx, maps.objy
	local objw, objh = maps.objw, maps.objh

	for o = 1, #maps.objtype
		if maps.objtype[o]
		and objx[o] + objw[o] > x1
		and objx[o] <= x2
		and objy[o] + objh[o] > y1
		and objy[o] <= y2
			return true
		end
	end
end

function maps.objectsAtPosition(x, y)
	return maps.objectsInArea(
		(x - 1) * maps.BLOCK_SIZE,
		(y - 1) * maps.BLOCK_SIZE,
		x * maps.BLOCK_SIZE - 1,
		y * maps.BLOCK_SIZE - 1)
end

-- Apparently unused
--function maps.playersInArea(x1, y1, x2, y2)
--	for i = 1, #maps.pp
--		local p = maps.pp[i]
--		if not (p.builder or p.dead)
--			local o = p.obj
--			if maps.objx[o] + maps.objw[o] > x1
--			and maps.objx[o] <= x2
--			and maps.objy[o] + maps.objh[o] > y1
--			and maps.objy[o] <= y2
--				return true
--			end
--		end
--	end
--end
--
--function maps.playersAtPosition(x, y)
--	return maps.playersInArea(
--		(x - 1) * maps.BLOCK_SIZE,
--		(y - 1) * maps.BLOCK_SIZE,
--		x * maps.BLOCK_SIZE - 1,
--		y * maps.BLOCK_SIZE - 1)
--end
