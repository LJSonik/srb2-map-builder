local FU = FRACUNIT

local map
maps.addLocalsRefresher(function()
	map = maps.map
end)


local function tileIsBig(tile)
	local def = maps.tiledefs[tile]
	return def.id == "span" or def.spanw ~= 1 or def.spanh ~= 1
end

local function findBigTileFromSpan(spanpos, layernum)
	local spanx, spany = spanpos % map.w, spanpos / map.w
	local layer = map[layernum]

	local maxspan = 4 - 1
	for y = max(spany - maxspan, 0), spany do
		for x = max(spanx - maxspan, 0), spanx do
			local pos = x + y * map.w
			local tile = layer[pos]
			local tiledef = maps.tiledefs[tile]

			if not (tiledef.spanw == 1 and tiledef.spanh == 1)
			and x + tiledef.spanw > spanx and y + tiledef.spanh > spany then
				return pos
			end
		end
	end
end

local function placeTile(tile, i, p)
	local oldtile = map[p.builderlayer][i]

	if oldtile == 1 and maps.isStackFull(map, i) or tileIsBig(oldtile) then
		return
	end

	if p.builderlayer == 2 or p.builderlayer == 3 then
		if not maps.tiledefs_empty[tile] then
			map.bothsolid[i] = p.bothsolid
		elseif not maps.tiledefs_empty[oldtile] then
			map.bothsolid[i] = true
		end
	end

	maps.setTile(p.builderlayer, i, tile)

	/*if p.builderlayer == 1
		if not maps.objectsAtPosition(p.builderx, p.buildery)
			maps.setTile(1, i, tile)
			maps.tileinfo[i] = $ & ~240 | (tiletype << 4)

			-- !!!
			--if maps.tiledefs_type[tile] == 25 -- Enemy spawner
				--maps.checkSpawner(i, p.builderx, p.buildery)
			--end
		end
	end*/

	if maps.tiledefs_empty[map[2][i]] == maps.tiledefs_empty[map[3][i]] then
		map.bothsolid[i] = false
	end
end

local function eraseTile(i, layernum, p)
	local layer = map[layernum]
	local oldtile = layer[i]

	local bigtilepos
	if tileIsBig(oldtile) then
		bigtilepos = findBigTileFromSpan(i, layernum)
	end

	local l, t, r, b
	if bigtilepos ~= nil then
		local bigtiledef = maps.tiledefs[layer[bigtilepos]]

		l, t = bigtilepos % map.w, bigtilepos / map.w
		r, b = l + bigtiledef.spanw - 1, t + bigtiledef.spanh - 1
	else
		-- Simply use cursor position
		l, t = i % map.w, i / map.w
		r, b = l, t
	end

	for y = t, b do
		for x = l, r do
			local i = x + y * map.w

			maps.setTile(layernum, i, 1)

			if (layernum == 2 or layernum == 3)
			and not maps.tiledefs_empty[layer[i]] then
				local otherlayer = (layernum == 2 and 3 or 2)
				map.bothsolid[i] = not maps.tiledefs_empty[map[otherlayer]]
			end

			if maps.tiledefs_empty[map[2][i]] == maps.tiledefs_empty[map[3][i]] then
				map.bothsolid[i] = false
			end
		end
	end
end

local function gridConflictsWithMap(grid, gridl, gridt, tl, tt, w, h, p)
	for gridy = gridt, gridt + h - 1 do
		local ty = tt + (gridy - gridt)

		if ty >= 0 and ty < map.h then
			for gridx = gridl, gridl + w - 1 do
				local tx = tl + (gridx - gridl)

				if tx >= 0 or tx < map.w then
					local tile = grid[gridy][gridx]
					local i = tx + ty * map.w

					if tile > 1 and map[p.builderlayer][i] > 1 then
						return true
					end
				end
			end
		end
	end

	return false
end

local function placeTilesFromGrid(grid, gridl, gridt, tl, tt, w, h, p)
	for gridy = gridt, gridt + h - 1 do
		local ty = tt + (gridy - gridt)

		if ty >= 0 and ty < map.h then
			for gridx = gridl, gridl + w - 1 do
				local tx = tl + (gridx - gridl)

				if tx >= 0 or tx < map.w then
					local tile = grid[gridy][gridx]
					local i = tx + ty * map.w

					if tile > 1 and map[p.builderlayer][i] == 1 then
						placeTile(tile, i, p)
					end
				end
			end
		end
	end
end

function maps.layoutConflictsWithMap(p)
	local grid = maps.tilecategories[p.layout.category].grid

	return gridConflictsWithMap(
		grid,
		p.layout.l,
		p.layout.t,
		p.builderx + (p.layout.l - p.layout.x),
		p.buildery + (p.layout.t - p.layout.y),
		p.layout.r - p.layout.l + 1,
		p.layout.b - p.layout.t + 1,
		p
	)
end

local function placeTilesFromLayout(p)
	local grid = maps.tilecategories[p.layout.category].grid

	placeTilesFromGrid(
		grid,
		p.layout.l,
		p.layout.t,
		p.builderx + (p.layout.l - p.layout.x),
		p.buildery + (p.layout.t - p.layout.y),
		p.layout.r - p.layout.l + 1,
		p.layout.b - p.layout.t + 1,
		p
	)
end

local function handleBuildOrRemove(p, owner, t)
	local i = p.builderx + p.buildery * map.w

	if not (t.prevbuttons & BT_JUMP) then
		if map[p.builderlayer][i] ~= 1 then -- Tile under the cursor
			p.erase = true
		elseif not maps.isStackFull(map, i) then
			p.erase = false
		end
	end

	if p.erase == nil then return end

	local oldtile1 = map[1][i]
	local oldtile2 = map[2][i]
	local oldtile3 = map[3][i]
	local oldtile4 = map[4][i]
	local oldbothsolid = map.bothsolid[i]

	if p.erase then -- Erasing
		if p.erasebothlayers then
			for layernum = 1, 4 do
				eraseTile(i, layernum, p)
			end
		else
			eraseTile(i, p.builderlayer, p)
		end
	elseif p.erase == false then -- Building
		if p.layout then
			if not tileIsBig(p.buildertile) or not maps.layoutConflictsWithMap(p) then
				placeTilesFromLayout(p)
			end
		else
			placeTile(p.buildertile, i, p)
		end
	end

	if p.erase ~= nil and owner and owner ~= server
	and (map[1][i] ~= oldtile1 or map[2][i] ~= oldtile2
	and map[3][i] ~= oldtile3 or map[4][i] ~= oldtile4
	or map.bothsolid[i] ~= oldbothsolid) then
		local text = owner.name.." (player "..#owner..")"
		maps.tilehistory[maps.tilehistoryposition] = {i, text, leveltime}
		maps.tilehistoryposition = ($ % 1024) + 1
	end
end

local function handleRectangleFill(p, t)
	local x1, y1 = min(p.builderx, p.fillx), min(p.buildery, p.filly)
	local x2, y2 = max(p.builderx, p.fillx), max(p.buildery, p.filly)
	local area = (x2 - x1 + 1) * (y2 - y1 + 1)

	if not (t.prevbuttons & BT_JUMP) and area <= 1024 then
		local tile = p.buildertile
		local ok = true

		if p.builderlayer == 1 then
			if not maps.objectsInArea(
				x1 * maps.TILESIZE,
				y1 * maps.TILESIZE,
				(x2 + 1) * maps.TILESIZE - 1,
				(y2 + 1) * maps.TILESIZE - 1
			) then
				local d = map.w - (x2 - x1 + 1)
				local i = x1 + y1 * map.w
				local currenttile = map[1][i]
				local currenttiletype = maps.tileinfo[i] & 240
				for y = y1, y2 do
					for x = x1, x2 do
						if map[1][i] ~= currenttile
						or maps.tileinfo[i] & 240 ~= currenttiletype then
							ok = false
						end
						i = $ + 1
					end
					i = $ + d
				end

				if ok then
					local t = p.tiletype

					d = map.w - (x2 - x1 + 1)
					i = x1 + y1 * map.w
					if p.fillremove then
						for y = y1, y2 do
							for x = x1, x2 do
								maps.setTile(1, i, 1)
								maps.tileinfo[i] = $ & ~240
								i = $ + 1
							end
							i = $ + d
						end
					else
						for y = y1, y2 do
							for x = x1, x2 do
								maps.setTile(1, i, tile)
								maps.tileinfo[i] = $ & ~240 | (t << 4)
								-- !!!
								--if maps.tiledefs_type[p.buildertile] == 25 -- Enemy spawner
									--maps.checkSpawner(i, p.builderx, p.buildery)
								--end
								i = $ + 1
							end
							i = $ + d
						end
					end
				end
			end
		else
			local d = map.w - (x2 - x1 + 1)
			local i = x1 + y1 * map.w
			local currenttile = map[2][i]
			local currentoverlay = maps.tileinfo[i] & 1
			for y = y1, y2 do
				for x = x1, x2 do
					if map[2][i] ~= currenttile
					or maps.tileinfo[i] & 1 ~= currentoverlay then
						ok = false
					end
					i = $ + 1
				end
				i = $ + d
			end

			if ok then
				d = map.w - (x2 - x1 + 1)
				i = x1 + y1 * map.w
				if p.fillremove then
					for y = y1, y2 do
						for x = x1, x2 do
							maps.setTile(2, i, 1)
							maps.tileinfo[i] = $ & ~1
							i = $ + 1
						end
						i = $ + d
					end
				else
					for y = y1, y2 do
						for x = x1, x2 do
							maps.setTile(2, i, tile)
							maps.tileinfo[i] = $ & ~1
							i = $ + 1
						end
						i = $ + d
					end
				end
			end
		end

		if ok then
			p.fillremove = nil
			p.fillx, p.filly = nil, nil
		end
	end
end

/*function maps.handleBuilding(p, owner, t, bt, left, right, up, down)
	handleMovement(p, t, left, right, up, down)

	if bt & BT_JUMP and (maps.allowediting or owner == server or IsPlayerAdmin(owner)) and p.buildertile
		if p.fillx == nil
			handleBuildOrRemove(p, owner, t)
		else
			--handleRectangleFill(p, t)
		end
	else
		p.erase = nil
	end

	-- Switch between layers
	if bt & BT_CUSTOM1 and not (t.prevbuttons & BT_CUSTOM1)
		p.builderlayer = ($ % 4) + 1
	end

	-- Toggle "both layers solid" option
	if bt & BT_CUSTOM2 and not (t.prevbuttons & BT_CUSTOM2)
		p.bothsolid = not $
	end

	-- Open tile picker
	if bt & BT_SPIN and not (t.prevbuttons & BT_SPIN)
		p.erase = nil
		maps.openTilePicker(p)
	end

	-- Copy
	if bt & BT_ATTACK and not (t.prevbuttons & BT_ATTACK)
		local tilepos = p.builderx + p.buildery * map.w
		local tile = map[p.builderlayer][tilepos]

		if tileIsBig(tile)
			tilepos = findBigTileFromSpan(tilepos, p.builderlayer)
			if tilepos
				tile = map[p.builderlayer][tilepos]
			end
		end

		if tilepos ~= nil and not maps.tiledefs[tile].noedit
			p.buildertile = tile
			p.layout = nil

			if tileIsBig(tile)
				local tiledef = maps.tiledefs[tile]
				local grid = maps.tilecategories[tiledef.category].grid
				local layout = maps.getLayoutInGrid(grid, tiledef.pickerx, tiledef.pickery)

				if layout
					p.layout = maps.getLayoutPickInfo(layout, tiledef.pickerx, tiledef.pickery)
				end
			end

			p.bothsolid = map.bothsolid[tilepos]
			maps.addTileToQuickPicker(p)
		end
	end

	maps.handleBuilderCamera(p)
end*/

function maps.handleClientBuilding(p, cmd)
end
