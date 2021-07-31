-- HIC SVNT LEONES


local maps = maps

local TILESIZE = maps.TILESIZE
local INT32_MAX, INT32_MIN = INT32_MAX, INT32_MIN

local map, map2, map3, bothsolid, mapw, maph
local tiledefs_heightmapv, tiledefs_flippedv
local tiledefs_heightmaph, tiledefs_flippedh
local tiledefs_full, tiledefs_empty

maps.addLocalsRefresher(function()
	map = maps.map
	map2, map3, bothsolid = map[2], map[3], map.bothsolid
	mapw, maph = map.w, map.h

	tiledefs_heightmapv, tiledefs_flippedv = maps.tiledefs_heightmapv, maps.tiledefs_flippedv
	tiledefs_heightmaph, tiledefs_flippedh = maps.tiledefs_heightmaph, maps.tiledefs_flippedh
	tiledefs_full, tiledefs_empty = maps.tiledefs_full, maps.tiledefs_empty
end)


function maps.areaContainsSolid(l, t, r, b, layer)
	local tl = l / TILESIZE
	local tr = (r - 1) / TILESIZE
	local tiletop = t / TILESIZE * TILESIZE

	for ty = t / TILESIZE, (b - 1) / TILESIZE do
		local i = tl + ty * mapw

		for tx = tl, tr do
			local tile = layer[i]

			if tiledefs_full[tile] then
				return true
			end

			local empty = tiledefs_empty[tile]
			if empty and bothsolid[i] then
				if layer == map2 then
					tile = map3[i]
				else
					tile = map2[i]
				end
				empty = tiledefs_empty[tile]
			end

			if not empty then
				local heightmap = tiledefs_heightmapv[tile]
				local flippedv = tiledefs_flippedv[tile]
				local flippedh = tiledefs_flippedh[tile]

				if flippedh then
					local height
					if tx == tl then -- Leftmost tile
						height = heightmap[l % TILESIZE / 2048 + 1]
					else
						height = heightmap[1]
					end

					if flippedv then
						if t < tiletop + height then
							return true
						end
					elseif b > tiletop + height then
						return true
					end
				else
					local height
					if tx == tr then -- Rightmost tile
						height = heightmap[(r - 1) % TILESIZE / 2048 + 1]
					else
						height = heightmap[32]
					end

					if flippedv then
						if t < tiletop + height then
							return true
						end
					elseif b > tiletop + height then
						return true
					end
				end
			end -- Not empty

			i = $ + 1
		end -- tx

		tiletop = $ + TILESIZE
	end -- ty
	return false
end

local function areaContainsEmptyLine(l, t, r, b, layer)
	local tl = l / TILESIZE
	local tt = t / TILESIZE
	local tr = (r - 1) / TILESIZE
	local tb = (b - 1) / TILESIZE

	for ty = tt, tb do
		local emptylinetop
		if ty == tt then -- Topmost tile
			emptylinetop = t % TILESIZE
		else
			emptylinetop = 0
		end

		local emptylinebottom
		if ty == tb then -- Bottommost tile
			emptylinebottom = (b - 1) % TILESIZE + 1
		else
			emptylinebottom = TILESIZE
		end

		local i = tl + ty * mapw

		for tx = tl, tr do
			local tile = layer[i]
			local empty = tiledefs_empty[tile]
			if empty and bothsolid[i] then
				if layer == map2 then
					tile = map3[i]
				else
					tile = map2[i]
				end
				empty = tiledefs_empty[tile]
			end

			if not empty then
				if tiledefs_full[tile] then
					emptylinebottom = 0
					break
				end

				local heightmap = tiledefs_heightmapv[tile]
				local flippedv = tiledefs_flippedv[tile]

				local y
				if tx == tl then -- Leftmost tile
					y = heightmap[l % TILESIZE / 2048 + 1]
				else
					y = heightmap[1]
				end

				if flippedv then
					if y > emptylinetop then
						emptylinetop = y
						if emptylinetop >= emptylinebottom then break end
					end
				elseif y < emptylinebottom then
					emptylinebottom = y
					if emptylinetop >= emptylinebottom then break end
				end

				if tx == tr then -- Rightmost tile
					y = heightmap[(r - 1) % TILESIZE / 2048 + 1]
				else
					y = heightmap[32]
				end

				if flippedv then
					if y > emptylinetop then
						emptylinetop = y
						if emptylinetop >= emptylinebottom then break end
					end
				elseif y < emptylinebottom then
					emptylinebottom = y
					if emptylinetop >= emptylinebottom then break end
				end
			end -- Not empty

			i = $ + 1
		end -- tx

		if emptylinetop < emptylinebottom then return true end
		-- !!!! dbg
		--if emptylinetop < emptylinebottom
		--	return ty * TILESIZE + emptylinetop, ty * TILESIZE + emptylinebottom
		--end
	end -- ty

	return false
end

local function areaContainsEmptyColumn(l, t, r, b, layer)
	local tl = l / TILESIZE
	local tt = t / TILESIZE
	local tr = (r - 1) / TILESIZE
	local tb = (b - 1) / TILESIZE

	for tx = tl, tr do
		local emptycolumnleft
		if tx == tl then -- Leftmost tile
			emptycolumnleft = l % TILESIZE
		else
			emptycolumnleft = 0
		end

		local emptycolumnright
		if tx == tr then -- Rightmost tile
			emptycolumnright = (r - 1) % TILESIZE + 1
		else
			emptycolumnright = TILESIZE
		end

		local i = tx + tt * mapw

		for ty = tt, tb do
			local tile = layer[i]
			local empty = tiledefs_empty[tile]
			if empty and bothsolid[i] then
				if layer == map2 then
					tile = map3[i]
				else
					tile = map2[i]
				end
				empty = tiledefs_empty[tile]
			end

			if not empty then
				if tiledefs_full[tile] then
					emptycolumnright = 0
					break
				end

				local heightmap = tiledefs_heightmaph[tile]
				local flippedh = tiledefs_flippedh[tile]

				local x
				if ty == tt then -- Topmost tile
					x = heightmap[t % TILESIZE / 2048 + 1]
				else
					x = heightmap[1]
				end

				if flippedh then
					if x > emptycolumnleft then
						emptycolumnleft = x
						if emptycolumnleft >= emptycolumnright then break end
					end
				elseif x < emptycolumnright then
					emptycolumnright = x
					if emptycolumnleft >= emptycolumnright then break end
				end

				if ty == tb then -- Bottommost tile
					x = heightmap[(b - 1) % TILESIZE / 2048 + 1]
				else
					x = heightmap[32]
				end

				if flippedh then
					if x > emptycolumnleft then
						emptycolumnleft = x
						if emptycolumnleft >= emptycolumnright then break end
					end
				elseif x < emptycolumnright then
					emptycolumnright = x
					if emptycolumnleft >= emptycolumnright then break end
				end
			end -- Not empty

			i = $ + mapw
		end -- ty

		if emptycolumnleft < emptycolumnright then return true end
		-- !!!! dbg
		--if emptycolumnleft < emptycolumnright
		--	return tx * TILESIZE + emptycolumnleft, tx * TILESIZE + emptycolumnright
		--end
	end -- tx

	return false
end

function maps.findTopmostSolidInArea(l, t, r, b, h, layer)
	local bestinarea = INT32_MAX
	local besttile
	local bestinareasloped

	local tl = l / TILESIZE
	local tt = t / TILESIZE
	local tr = (r - 1) / TILESIZE
	local tb = (b - 1) / TILESIZE
	local tiletop = tt * TILESIZE

	for ty = tt, tb do
		local i = tl + ty * mapw

		for tx = tl, tr do
			local tile = layer[i]
			local empty = tiledefs_empty[tile]
			if empty and bothsolid[i] then
				if layer == map2 then
					tile = map3[i]
				else
					tile = map2[i]
				end
				empty = tiledefs_empty[tile]
			end

			if not empty then
				if tiledefs_full[tile] then
					if t <= tiletop then
						local boundedleft, boundedright
						if tx == tl then -- Leftmost tile
							boundedleft = l
						else
							boundedleft = tx * TILESIZE
						end
						if tx == tr then -- Rightmost tile
							boundedright = r
						else
							boundedright = (tx + 1) * TILESIZE
						end

						if areaContainsEmptyColumn(
							boundedleft , tiletop - h,
							boundedright, tiletop,
							layer
						) then
							return tiletop, i
						end
					end
				else -- Not full
					local bestintile
					local bestintilesloped = false

					if tiledefs_flippedv[tile] then
						if tiledefs_flippedh[tile] then
							if tx ~= tl -- Not leftmost tile
							or tiledefs_heightmapv[tile][l % TILESIZE / 2048 + 1] > 0 then
								bestintile = tiletop
							else
								bestintile = INT32_MAX
							end
						elseif tx ~= tr -- Not rightmost tile
						or tiledefs_heightmapv[tile][(r - 1) % TILESIZE / 2048 + 1] > 0 then
							bestintile = tiletop
						else
							bestintile = INT32_MAX
						end
					else
						local heightmapv = tiledefs_heightmapv[tile]
						local flippedh = tiledefs_flippedh[tile]

						bestintilesloped = true

						if flippedh then
							if tx == tl then -- Leftmost tile
								bestintile = heightmapv[l % TILESIZE / 2048 + 1]
							else
								bestintile = heightmapv[1]
							end
							bestintile = $ + tiletop
						else
							if tx == tr then -- Rightmost tile
								bestintile = heightmapv[(r - 1) % TILESIZE / 2048 + 1]
							else
								bestintile = heightmapv[32]
							end
							bestintile = $ + tiletop
						end

						if t > bestintile then
							local heightmaph = tiledefs_heightmaph[tile]

							local relx
							if ty == tt then -- Topmost tile
								relx = heightmaph[(t - 1) % TILESIZE / 2048 + 1]
							else
								relx = heightmaph[1]
							end

							local absx = tx * TILESIZE + relx
							if flippedh then
								if r > absx and relx < TILESIZE then
									bestintile = heightmapv[relx / 2048 + 1]
									bestintile = $ + tiletop
								end
							else
								if l < absx and relx > 0 then
									-- The first one is more correct, but since heightmaps only contain
									-- discrete values, the simplified version works for our case
									--bestintile = heightmapv[(relx - 1) / 2048 + 1]
									bestintile = heightmapv[relx / 2048]
									bestintile = $ + tiletop
								end
							end
						end
					end -- Not flipped vertically

					if b > bestintile and t <= bestintile
					and bestintile < bestinarea then
						local boundedleft, boundedright
						if tx == tl then -- Leftmost tile
							boundedleft = l
						else
							boundedleft = tx * TILESIZE
						end
						if tx == tr then -- Rightmost tile
							boundedright = r
						else
							boundedright = (tx + 1) * TILESIZE
						end

						if areaContainsEmptyColumn(
							boundedleft , bestintile - h,
							boundedright, bestintile,
							layer
						) then
							if bestintile == t then
								return t, i
							end

							bestinarea = bestintile
							besttile = i
							bestinareasloped = bestintilesloped
						end
					end
				end -- Not full
			end

			i = $ + 1
		end -- tx

		if besttile ~= nil then
			return bestinarea, besttile, bestinareasloped
		end

		tiletop = $ + TILESIZE
	end -- ty

	return nil
end

function maps.findRightmostSolidInArea(l, t, r, b, w, layer)
	local bestinarea = INT32_MIN
	local besttile
	local bestinareasloped

	local tl = l / TILESIZE
	local tt = t / TILESIZE
	local tr = (r - 1) / TILESIZE
	local tb = (b - 1) / TILESIZE
	local tileleft = tr * TILESIZE
	local tileright = tileleft + TILESIZE

	for tx = tr, tl, -1 do
		local i = tx + tt * mapw

		for ty = tt, tb do
			local tile = layer[i]
			local empty = tiledefs_empty[tile]
			if empty and bothsolid[i] then
				if layer == map2 then
					tile = map3[i]
				else
					tile = map2[i]
				end
				empty = tiledefs_empty[tile]
			end

			if not empty then
				if tiledefs_full[tile] then
					if r >= tileright then
						local boundedtop, boundedbottom
						if ty == tt then -- Topmost tile
							boundedtop = t
						else
							boundedtop = ty * TILESIZE
						end
						if ty == tb then -- Bottommost tile
							boundedbottom = b
						else
							boundedbottom = (ty + 1) * TILESIZE
						end

						if areaContainsEmptyLine(
							tileright    , boundedtop,
							tileright + w, boundedbottom,
							layer
						) then
							return tileright, i
						end
					end
				else -- Not full
					local bestintile
					local bestintilesloped = false

					if not tiledefs_flippedh[tile] then
						if tiledefs_flippedv[tile] then
							if ty ~= tt -- Not topmost tile
							or tiledefs_heightmaph[tile][t % TILESIZE / 2048 + 1] < TILESIZE then
								bestintile = tileright
							else
								bestintile = INT32_MIN
							end
						elseif ty ~= tb -- Not bottommost tile
						or tiledefs_heightmaph[tile][(b - 1) % TILESIZE / 2048 + 1] < TILESIZE then
							bestintile = tileright
						else
							bestintile = INT32_MIN
						end
					else
						local heightmaph = tiledefs_heightmaph[tile]
						local flippedv = tiledefs_flippedv[tile]

						bestintilesloped = true

						if flippedv then
							if ty == tt then -- Topmost tile
								bestintile = heightmaph[t % TILESIZE / 2048 + 1]
							else
								bestintile = heightmaph[1]
							end
							bestintile = $ + tileleft
						else
							if ty == tb then -- Bottommost tile
								bestintile = heightmaph[(b - 1) % TILESIZE / 2048 + 1]
							else
								bestintile = heightmaph[32]
							end
							bestintile = $ + tileleft
						end

						if r <= bestintile then
							local heightmapv = tiledefs_heightmapv[tile]

							local rely
							if tx == tr then -- Rightmost tile
								rely = heightmapv[(r - 1) % TILESIZE / 2048 + 1]
							else
								rely = heightmapv[32]
							end

							local absy = ty * TILESIZE + rely
							if flippedv then
								if b > absy and rely < TILESIZE then
									bestintile = heightmaph[rely / 2048 + 1]
									bestintile = $ + tileleft
								end
							else
								if t < absy and rely > 0 then
									-- The first one is more correct, but since heightmaps only contain
									-- discrete values, the simplified version works for our case
									--bestintile = heightmaph[(rely - 1) / 2048 + 1]
									bestintile = heightmaph[rely / 2048]
									bestintile = $ + tileleft
								end
							end
						end
					end -- Not flipped horizontally

					if l < bestintile and r >= bestintile
					and bestintile > bestinarea then
						local boundedtop, boundedbottom
						if ty == tt then -- Topmost tile
							boundedtop = t
						else
							boundedtop = ty * TILESIZE
						end
						if ty == tb then -- Bottommost tile
							boundedbottom = b
						else
							boundedbottom = (ty + 1) * TILESIZE
						end

						if areaContainsEmptyLine(
							bestintile    , boundedtop,
							bestintile + w, boundedbottom,
							layer
						) then
							if bestintile == r then
								return r, i
							end

							bestinarea = bestintile
							besttile = i
							bestinareasloped = bestintilesloped
						end
					end
				end -- Not full
			end

			i = $ + mapw
		end -- ty

		if besttile ~= nil then
			return bestinarea, besttile, bestinareasloped
		end

		tileleft = $ - TILESIZE
		tileright = $ - TILESIZE
	end -- tx

	return nil
end

function maps.findBottommostSolidInArea(l, t, r, b, h, layer)
	local bestinarea = INT32_MIN
	local besttile
	local bestinareasloped

	local tl = l / TILESIZE
	local tt = t / TILESIZE
	local tr = (r - 1) / TILESIZE
	local tb = (b - 1) / TILESIZE
	local tiletop = tb * TILESIZE
	local tilebottom = tiletop + TILESIZE

	for ty = tb, tt, -1 do
		local i = tl + ty * mapw

		for tx = tl, tr do
			local tile = layer[i]
			local empty = tiledefs_empty[tile]
			if empty and bothsolid[i] then
				if layer == map2 then
					tile = map3[i]
				else
					tile = map2[i]
				end
				empty = tiledefs_empty[tile]
			end

			if not empty then
				if tiledefs_full[tile] then
					if b >= tilebottom then
						local boundedleft, boundedright
						if tx == tl then -- Leftmost tile
							boundedleft = l
						else
							boundedleft = tx * TILESIZE
						end
						if tx == tr then -- Rightmost tile
							boundedright = r
						else
							boundedright = (tx + 1) * TILESIZE
						end

						if areaContainsEmptyColumn(
							boundedleft , tilebottom,
							boundedright, tilebottom + h,
							layer
						) then
							return tilebottom, i
						end
					end
				else -- Not full
					local bestintile
					local bestintilesloped = false

					if not tiledefs_flippedv[tile] then
						if tiledefs_flippedh[tile] then
							if tx ~= tl -- Not leftmost tile
							or tiledefs_heightmapv[tile][l % TILESIZE / 2048 + 1] < TILESIZE then
								bestintile = tilebottom
							else
								bestintile = INT32_MIN
							end
						elseif tx ~= tr -- Not rightmost tile
						or tiledefs_heightmapv[tile][(r - 1) % TILESIZE / 2048 + 1] < TILESIZE then
							bestintile = tilebottom
						else
							bestintile = INT32_MIN
						end
					else
						local heightmapv = tiledefs_heightmapv[tile]
						local flippedh = tiledefs_flippedh[tile]

						bestintilesloped = true

						if flippedh then
							if tx == tl then -- Leftmost tile
								bestintile = heightmapv[l % TILESIZE / 2048 + 1]
							else
								bestintile = heightmapv[1]
							end
							bestintile = $ + tiletop
						else
							if tx == tr then -- Rightmost tile
								bestintile = heightmapv[(r - 1) % TILESIZE / 2048 + 1]
							else
								bestintile = heightmapv[32]
							end
							bestintile = $ + tiletop
						end

						if b < bestintile then
							local heightmaph = tiledefs_heightmaph[tile]

							local relx
							if ty == tb then -- Bottommost tile
								relx = heightmaph[(b - 1) % TILESIZE / 2048 + 1]
							else
								relx = heightmaph[32]
							end

							local absx = tx * TILESIZE + relx
							if flippedh then
								if r > absx and relx < TILESIZE then
									bestintile = heightmapv[relx / 2048 + 1]
									bestintile = $ + tiletop
								end
							else
								if l < absx and relx > 0 then
									-- The first one is more correct, but since heightmaps only contain
									-- discrete values, the simplified version works for our case
									--bestintile = heightmapv[(relx - 1) / 2048 + 1]
									bestintile = heightmapv[relx / 2048]
									bestintile = $ + tiletop
								end
							end
						end
					end -- Not flipped vertically

					if t < bestintile and b >= bestintile
					and bestintile > bestinarea then
						local boundedleft, boundedright
						if tx == tl then -- Leftmost tile
							boundedleft = l
						else
							boundedleft = tx * TILESIZE
						end
						if tx == tr then -- Rightmost tile
							boundedright = r
						else
							boundedright = (tx + 1) * TILESIZE
						end

						if areaContainsEmptyColumn(
							boundedleft , bestintile,
							boundedright, bestintile + h,
							layer
						) then
							if bestintile == b then
								return b, i
							end

							bestinarea = bestintile
							besttile = i
							bestinareasloped = bestintilesloped
						end
					end
				end -- Not full
			end

			i = $ + 1
		end -- tx

		if besttile ~= nil then
			return bestinarea, besttile, bestinareasloped
		end

		tiletop = $ - TILESIZE
		tilebottom = $ - TILESIZE
	end -- ty

	return nil
end

function maps.findLeftmostSolidInArea(l, t, r, b, w, layer)
	local bestinarea = INT32_MAX
	local besttile
	local bestinareasloped

	local tl = l / TILESIZE
	local tt = t / TILESIZE
	local tr = (r - 1) / TILESIZE
	local tb = (b - 1) / TILESIZE
	local tileleft = tl * TILESIZE
	local tileright = tileleft + TILESIZE

	for tx = tl, tr do
		local i = tx + tt * mapw

		for ty = tt, tb do
			local tile = layer[i]
			local empty = tiledefs_empty[tile]
			if empty and bothsolid[i] then
				if layer == map2 then
					tile = map3[i]
				else
					tile = map2[i]
				end
				empty = tiledefs_empty[tile]
			end

			if not empty then
				if tiledefs_full[tile] then
					if l <= tileleft then
						local boundedtop, boundedbottom
						if ty == tt then -- Topmost tile
							boundedtop = t
						else
							boundedtop = ty * TILESIZE
						end
						if ty == tb then -- Bottommost tile
							boundedbottom = b
						else
							boundedbottom = (ty + 1) * TILESIZE
						end

						if areaContainsEmptyLine(
							tileleft - w, boundedtop,
							tileleft    , boundedbottom,
							layer
						) then
							return tileleft, i, false
						end
					end
				else -- Not full
					local bestintile
					local bestintilesloped = false

					if tiledefs_flippedh[tile] then
						if tiledefs_flippedv[tile] then
							if ty ~= tt -- Not topmost tile
							or tiledefs_heightmaph[tile][t % TILESIZE / 2048 + 1] > 0 then
								bestintile = tileleft
							else
								bestintile = INT32_MAX
							end
						elseif ty ~= tb -- Not bottommost tile
						or tiledefs_heightmaph[tile][(b - 1) % TILESIZE / 2048 + 1] > 0 then
							bestintile = tileleft
						else
							bestintile = INT32_MAX
						end
					else
						local heightmaph = tiledefs_heightmaph[tile]
						local flippedv = tiledefs_flippedv[tile]

						bestintilesloped = true

						if flippedv then
							if ty == tt then -- Topmost tile
								bestintile = heightmaph[t % TILESIZE / 2048 + 1]
							else
								bestintile = heightmaph[1]
							end
							bestintile = $ + tileleft
						else
							if ty == tb then -- Bottommost tile
								bestintile = heightmaph[(b - 1) % TILESIZE / 2048 + 1]
							else
								bestintile = heightmaph[32]
							end
							bestintile = $ + tileleft
						end

						if l > bestintile then
							local heightmapv = tiledefs_heightmapv[tile]

							local rely
							if tx == tl then -- Leftmost tile
								rely = heightmapv[(l - 1) % TILESIZE / 2048 + 1]
							else
								rely = heightmapv[1]
							end

							local absy = ty * TILESIZE + rely
							if flippedv then
								if b > absy and rely < TILESIZE then
									bestintile = heightmaph[rely / 2048 + 1]
									bestintile = $ + tileleft
								end
							else
								if t < absy and rely > 0 then
									-- The first one is more correct, but since heightmaps only contain
									-- discrete values, the simplified version works for our case
									--bestintile = heightmaph[(rely - 1) / 2048 + 1]
									bestintile = heightmaph[rely / 2048]
									bestintile = $ + tileleft
								end
							end
						end
					end -- Not flipped horizontally

					if r > bestintile and l <= bestintile
					and bestintile < bestinarea then
						local boundedtop, boundedbottom
						if ty == tt then -- Topmost tile
							boundedtop = t
						else
							boundedtop = ty * TILESIZE
						end
						if ty == tb then -- Bottommost tile
							boundedbottom = b
						else
							boundedbottom = (ty + 1) * TILESIZE
						end

						if areaContainsEmptyLine(
							bestintile - w, boundedtop,
							bestintile    , boundedbottom,
							layer
						) then
							if bestintile == l then
								return l, i, true
							end

							bestinarea = bestintile
							besttile = i
							bestinareasloped = bestintilesloped
						end
					end
				end -- Not full
			end

			i = $ + mapw
		end -- ty

		if besttile ~= nil then
			return bestinarea, besttile, bestinareasloped
		end

		tileleft = $ + TILESIZE
		tileright = $ + TILESIZE
	end -- tx

	return nil
end
