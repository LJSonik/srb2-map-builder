maps.TILEPICKER_TILESIZE = 8
maps.TILEPICKER_GAP_SIZE = maps.TILEPICKER_TILESIZE / 2


maps.tilelayoutdefs = {}
local addedlayouts
maps.tilepickerdirty = false


local function handleKeyRepeat(t, counter, waspressed, delay)
	if not waspressed
		t[counter] = 8
		return true
	elseif t[counter] == 1
		t[counter] = delay
		return true
	else
		t[counter] = $ - 1
		return false
	end
end

local function tilesPerLine()
	local screensize = maps.SCREEN_WIDTH - maps.TILEPICKER_GAP_SIZE * FRACUNIT
	local tilesize = (maps.TILEPICKER_TILESIZE + maps.TILEPICKER_GAP_SIZE) * FRACUNIT
	return screensize / tilesize
end

local function handleCategoryPicker(p, t, bt, left, right, up, down)
	local n = #maps.tilecategories
	local category = p.category

	if left and handleKeyRepeat(t, "hkeyrepeat", t.prevleft, p.builderspeed)
		/*local columns = tilesPerLine()
		repeat
			category = ($ - 1) % columns ~= 0 and $ - 1 or $ + columns - 1
		until category <= n*/
		category = $ ~= 1 and $ - 1 or n
	end

	if right and handleKeyRepeat(t, "hkeyrepeat", t.prevright, p.builderspeed)
		/*local columns = tilesPerLine()
		category = $ % columns ~= 0 and $ + 1 <= n and $ + 1 or ($ - 1) / columns * columns + 1*/
		category = $ ~= n and $ + 1 or 1
	end

	if up and handleKeyRepeat(t, "vkeyrepeat", t.prevup, p.builderspeed)
		local columns = tilesPerLine()
		repeat
			category = $ > columns and $ - columns or $ + (n - 1) / columns * columns
		until category <= n
	end

	if down and handleKeyRepeat(t, "vkeyrepeat", t.prevdown, p.builderspeed)
		local columns = tilesPerLine()
		category = $ + columns <= n and $ + columns or $ - ($ - 1) / columns * columns
	end

	-- Pick tile
	if bt & BT_JUMP and not (t.prevbuttons & BT_JUMP)
		/*p.pickertile = (
			category == p.prevcategory1 and p.prevpickertile1
			or category == p.prevcategory2 and p.prevpickertile2
			or 1
		)*/
		p.pickertile = 1
		p.pickerx, p.pickery = 1, 1
		p.pickingcategory = false
	end

	-- Close category picker
	if bt & BT_USE and not (t.prevbuttons & BT_USE)
		maps.closeTilePicker(p)
	end

	p.category = category
end

local function setSlot(grid, x, y, slot)
	while #grid < y
		table.insert(grid, {})
	end

	while #grid[y] < x
		table.insert(grid[y], 0)
	end

	grid[y][x] = slot
end

local function getLayoutUnderCursor(p)
	if p.quickpickingtile
		local tile = p.tilegrid[p.quickpickery][p.quickpickerx]
		if tile > 1
			local def = maps.tiledefs[tile]
			local category = maps.tilecategories[def.category]
			return maps.getLayoutInGrid(category.grid, def.pickerx, def.pickery)
		end
	else
		local grid = maps.tilecategories[p.category].grid
		return maps.getLayoutInGrid(grid, p.pickerx, p.pickery)
	end
end

local function isAreaFree(grid, l, t, r, b)
	if r > grid.tilesperline
		return false
	end

	for y = t, min(b, #grid)
		for x = l, r
			local slot = grid[y][x]
			if slot ~= nil and slot ~= 0
				return false
			end
		end
	end

	return true
end

local function findFreeArea(grid, w, h)
	local numlines = #grid

	for y = 1, numlines
		for x = 1, grid.tilesperline
			if isAreaFree(grid, x, y, x + w - 1, y + h - 1)
				return x, y
			end
		end
	end

	if numlines == 0
		return 1, 1
	--elseif #grid[numlines] + w <= grid.tilesperline
		--return #grid[numlines] + 1, numlines
	else
		return 1, numlines + 1
	end
end

function maps.getLayoutInGrid(grid, x, y)
	if grid.layouts and grid.layouts[y]
		local layout = grid.layouts[y][x]
		if layout
			return layout.parent
		end
	end

	return nil
end

/*local function addTileToEditor(tiledefid, categoryindex)
	local category = maps.tilecategories[categoryindex]
	local layoutdef = maps.tilelayoutdefs[addedlayout.def]

	for ly, line in ipairs(layoutdef)
		for lx, slot in ipairs(line)
			if slot == addedlayout.pos
				local x = addedlayout.l + lx - 1
				local y = addedlayout.t + ly - 1

				setSlot(category.grid, x, y, tiledefid)

				local tiledef = maps.tiledefs[tiledefid]
				if tiledef and tiledef.pickerx == nil
					tiledef.pickerx, tiledef.pickery = x, y
				end

				category.grid.layouts[y] = $ or {}
				category.grid.layouts[y][x] = addedlayout
			end
		end
	end

	if addedlayout.pos < layoutdef.numtiles
		addedlayout.pos = $ + 1
	else
		addedlayout = nil
	end
end*/

local function findNextRawTileDef(parser)
	while true
		parser.pos = $ + 1
		local rawtiledef = parser.rawtiledefs[parser.pos]

		if type(rawtiledef) ~= "table"
		or rawtiledef.layout
		or not maps.tiledefs[rawtiledef.id].noedit
			return rawtiledef
		end
	end
end

local function generateLayoutTree(parser)
	local rawtiledef = findNextRawTileDef(parser)
	if not rawtiledef return end

	-- Tile
	if type(rawtiledef) == "string" or not rawtiledef.layout
		local tiledefid
		if type(rawtiledef) == "string"
			tiledefid = rawtiledef
		else
			tiledefid = rawtiledef.id
		end

		local tiledef = maps.tiledefs[tiledefid]
		local spanw, spanh = tiledef.editspanw, tiledef.editspanh

		if spanw ~= 1 or spanh ~= 1
			local layouttype = "rectangle"..spanw.."x"..spanh
			local layoutdef = maps.tilelayoutdefs[layouttype]

			local tree = {
				w = spanw, h = spanh,
				layoutdef = layoutdef.id,
				span = true,
				columnwidths = {},
				lineheights = {}
			}
			table.insert(tree, {w = 1, h = 1, tiledef = tiledefid, parent = tree})
			for _ = 2, layoutdef.numtiles -- 1 is our tile, skip it
				table.insert(tree, {w = 1, h = 1, tiledef = "span", parent = tree})
			end

			for x = 1, spanw
				tree.columnwidths[x] = 1
			end
			for y = 1, spanh
				tree.lineheights[y] = 1
			end

			return tree
		else
			return {
				w = 1, h = 1,
				tiledef = tiledefid
			}
		end
	end

	-- Layout
	local layoutdef = maps.tilelayoutdefs[rawtiledef.layout]

	local tree = {
		w = 0, h = 0,
		layoutdef = layoutdef.id,
		columnwidths = {},
		lineheights = {}
	}
	for i = 1, layoutdef.numtiles
		tree[i] = generateLayoutTree(parser)
		tree[i].parent = tree
	end

	for y, line in ipairs(layoutdef)
		for x, slot in ipairs(line)
			if slot == 0
				slot = "air"
			end

			local w, h
			if type(slot) == "string" -- Tile ID
				w = maps.tiledefs[slot].editspanw
				h = maps.tiledefs[slot].editspanh
			else -- Placeholder for customisable tiles
				w = tree[slot].w
				h = tree[slot].h
			end

			tree.columnwidths[x] = max($ or 0, w)
			tree.lineheights [y] = max($ or 0, h)
		end
	end

	for _, w in ipairs(tree.columnwidths)
		tree.w = $ + w
	end
	for _, h in ipairs(tree.lineheights)
		tree.h = $ + h
	end

	return tree
end

local function addTilesFromLayoutTree(tree, left, top, category)
	local grid = category.grid

	tree.category = category
	tree.l, tree.t = left, top

	if tree.layoutdef
		local layoutdef = maps.tilelayoutdefs[tree.layoutdef]

		local childtop = top
		for y, line in ipairs(layoutdef)
			local childleft = left
			for x, slot in ipairs(line)
				if slot == 0
					slot = "air"
				end

				if type(slot) == "string" -- Tile ID
					setSlot(grid, childleft, childtop, slot)

					local tiledef = maps.tiledefs[slot]
					if tiledef and tiledef.pickerx == nil
						tiledef.pickerx, tiledef.pickery = childleft, childtop
					end

					grid.layouts[childtop] = $ or {}
					grid.layouts[childtop][childleft] = {
						parent = tree,
						w = 1, h = 1,
						tiledef = tiledef.index,
					}
				else -- Placeholder for customisable tiles
					addTilesFromLayoutTree(tree[slot], childleft, childtop, category)
				end

				childleft = $ + tree.columnwidths[x]
			end
			childtop = $ + tree.lineheights[y]
		end
	else
		setSlot(grid, left, top, tree.tiledef)

		local tiledef = maps.tiledefs[tree.tiledef]
		if tiledef and tiledef.pickerx == nil
			tiledef.pickerx, tiledef.pickery = left, top
		end

		grid.layouts[top] = $ or {}
		grid.layouts[top][left] = tree
	end
end

function maps.addTilesToEditor(rawtiledefs)
	local category = maps.tilecategories[rawtiledefs.category]

	local parser = {
		rawtiledefs = rawtiledefs,
		pos = 0
	}

	while parser.pos < #rawtiledefs
		local layouttree = generateLayoutTree(parser)
		if not layouttree break end

		local l, t = findFreeArea(category.grid, layouttree.w, layouttree.h)

		for y = t, t + layouttree.h - 1
			for x = l, l + layouttree.w - 1
				setSlot(category.grid, x, y, 1)
			end
		end

		addTilesFromLayoutTree(layouttree, l, t, category)

		/*local layoutdef = maps.tilelayoutdefs[layoutdefid]
		local l, t = findFreeArea(category.grid, layoutdef.w, layoutdef.h)

		addedlayout = {
			def = layoutdefid,
			category = category,
			pos = 1,

			l = l,
			t = t,
			r = l + layoutdef.w - 1,
			b = t + layoutdef.h - 1
		}

		for y, line in ipairs(layoutdef)
			for x, slot in ipairs(line)
				local gridslot
				if slot == 0 -- Air
					gridslot = 1
				elseif type(slot) == "string" -- Tile ID
					gridslot = maps.tiledefs[slot].index
				else -- Placeholder for customisable tiles
					gridslot = 1 -- Just put air for now
				end

				setSlot(category.grid, l + x - 1, t + y - 1, gridslot)
			end
		end*/
	end
end

/*function maps.addTilesToEditor(tiledefs)
	local layouttree

	for _, rawdef in ipairs(tiledefs)
		if type(rawdef) == "string" -- Reuse tile
			maps.addTileToEditor(rawdef, tiledefs.category)
		end

		local layoutdef = maps.tilelayoutdefs[]

		if rawdef.layout
			maps.startLayout(rawdef.layout, maps.tilecategories[tiledefs.category])
		end

		table.insert(addedlayouts, {
			columnwidths = layoutdef.w,
			lineheights = layoutdef.h
		})

		--if not def.noedit
		--end
	end
end*/

function maps.finaliseTilePicker()
	for _, category in ipairs(maps.tilecategories)
		for _, line in ipairs(category.grid)
			for x, slot in ipairs(line)
				if type(slot) == "string"
					line[x] = maps.tiledefs[slot].index
				end
			end
		end
	end

	maps.tilepickerdirty = false
end

/*function maps.addTileToEditor(tiledefid, categoryindex)
	local category = maps.tilecategories[categoryindex]

	maps.tilepickerdirty = true

	if addedlayout
		local layoutdef = maps.tilelayoutdefs[addedlayout.def]

		for ly, line in ipairs(layoutdef)
			for lx, slot in ipairs(line)
				if slot == addedlayout.pos
					local x = addedlayout.l + lx - 1
					local y = addedlayout.t + ly - 1

					setSlot(category.grid, x, y, tiledefid)

					local tiledef = maps.tiledefs[tiledefid]
					if tiledef and tiledef.pickerx == nil
						tiledef.pickerx, tiledef.pickery = x, y
					end

					category.grid.layouts[y] = $ or {}
					category.grid.layouts[y][x] = addedlayout
				end
			end
		end

		if addedlayout.pos < layoutdef.numtiles
			addedlayout.pos = $ + 1
		else
			addedlayout = nil
		end
	else
		local tiledef = maps.tiledefs[tiledefid]
		local spanw, spanh = tiledef.editspanw, tiledef.editspanh

		if spanw == 1 and spanh == 1
			local x, y = findFreeArea(category.grid, 1, 1)

			setSlot(category.grid, x, y, tiledefid)

			if tiledef and tiledef.pickerx == nil
				tiledef.pickerx, tiledef.pickery = x, y
			end
		else
			local layouttype = "rectangle"..spanw.."x"..spanh
			maps.startLayout(layouttype, category)
			addedlayout.span = true
			maps.addTileToEditor(tiledefid, categoryindex)
			for _ = 2, spanw * spanh -- 1 is our tile, skip it
				maps.addTileToEditor("span", categoryindex)
			end
		end
	end
end*/

function maps.addCategoryToEditor(category)
	category.grid = {
		tilesperline = tilesPerLine(),
		layouts = {}
	}
end

/*function maps.startLayout(layoutdefid, category)
	local layoutdef = maps.tilelayoutdefs[layoutdefid]
	local l, t = findFreeArea(category.grid, layoutdef.w, layoutdef.h)

	addedlayout = {
		def = layoutdefid,
		category = category,
		pos = 1,

		l = l,
		t = t,
		r = l + layoutdef.w - 1,
		b = t + layoutdef.h - 1
	}

	for y, line in ipairs(layoutdef)
		for x, slot in ipairs(line)
			local gridslot
			if slot == 0 -- Air
				gridslot = 1
			elseif type(slot) == "string" -- Tile ID
				gridslot = maps.tiledefs[slot].index
			else -- Placeholder for customisable tiles
				gridslot = 1 -- Just put air for now
			end

			setSlot(category.grid, l + x - 1, t + y - 1, gridslot)
		end
	end
end*/

local function findBestPositionInQuickPicker(p)
	local bestx, besty
	local bestscore = INT32_MAX
	local grid = p.tilegrid

	for y = 1, 3
		for x = 1, 3
			if grid[y][x] == p.tile
				return nil, nil
			elseif x == p.quickpickerx and y == p.quickpickery and grid[y][x] ~= 0
				continue
			end

			local score = p.tilecountgrid[y][x] + abs(2 - x) + abs(2 - y)
			if grid[y][x] ~= 0
				score = $ + 100
			end

			if score < bestscore
				bestscore = score
				bestx, besty = x, y
			end
		end
	end

	return bestx, besty
end

function maps.addTileToQuickPicker(p)
	if not p.tilegrid
		p.tilegrid = {
			tilesperline = 3,

			{0, 0, 0},
			{0, 0, 0},
			{0, 0, 0},
		}

		p.tilecountgrid = {
			{0, 0, 0},
			{0, 0, 0},
			{0, 0, 0},
		}

		p.quickpickerx, p.quickpickery = 2, 2
	end

	local x, y = findBestPositionInQuickPicker(p)
	if x == nil
		p.tilecountgrid[p.quickpickery][p.quickpickerx] = $ + 1
	else
		p.tilegrid[y][x] = p.tile
		p.tilecountgrid[y][x] = 0
		p.quickpickerx, p.quickpickery = x, y
	end
end

function maps.openTilePicker(p)
	if maps.tilepickerdirty
		maps.finaliseTilePicker()
	end

	p.pickingtile = true

	if not p.category
		p.category = 1
	end

	if p.tilegrid
		p.quickpickingtile = true

		-- Select the current tile by default
		for y = 1, 3
			for x = 1, 3
				if p.tilegrid[y][x] == p.tile
					p.quickpickerx, p.quickpickery = x, y
				end
			end
		end
	elseif not p.pickertile
		p.pickingcategory = true
	end
end

function maps.closeTilePicker(p)
	if maps.tilepickerdirty
		maps.finaliseTilePicker()
	end

	p.pickingtile = nil
	p.pickingcategory = nil
	p.quickpickingtile = nil
end

function maps.getLayoutPickInfo(layout, x, y)
	local layoutdef = maps.tilelayoutdefs[layout.layoutdef]

	local layoutinfo = {
		def = layout.layoutdef,
		category = layout.category.index,

		x = x,
		y = y
	}

	/*local partw = layoutdef.w / layoutdef.split
	local parth = layoutdef.h / layoutdef.split
	local partx = (x - layout.l) / partw
	local party = (y - layout.t) / parth

	layoutinfo.l = layout.l + partx * partw
	layoutinfo.t = layout.t + party * parth
	layoutinfo.r = layoutinfo.l + partw - 1
	layoutinfo.b = layoutinfo.t + parth - 1*/

	if x - layout.l < layoutdef.splitx
		layoutinfo.l = layout.l
		layoutinfo.r = layout.l + layoutdef.splitx - 1
	else
		layoutinfo.l = layout.l + layoutdef.splitx
		layoutinfo.r = layout.l + layoutdef.w - 1
	end

	if y - layout.t < layoutdef.splity
		layoutinfo.t = layout.t
		layoutinfo.b = layout.t + layoutdef.splity - 1
	else
		layoutinfo.t = layout.t + layoutdef.splity
		layoutinfo.b = layout.t + layoutdef.h - 1
	end

	return layoutinfo
end

local function getLayoutPickInfoUnderCursor(p)
	local layout = getLayoutUnderCursor(p)

	local x, y
	if p.quickpickingtile
		local tile = p.tilegrid[p.quickpickery][p.quickpickerx]
		if tile > 1
			local def = maps.tiledefs[tile]
			x, y = def.pickerx, def.pickery
		end
	else
		x, y = p.pickerx, p.pickery
	end

	return maps.getLayoutPickInfo(layout, x, y)
end

function maps.handleTilePicker(p, t, bt, left, right, up, down)
	if maps.tilepickerdirty
		maps.finaliseTilePicker()
	end

	if p.pickingcategory
		handleCategoryPicker(p, t, bt, left, right, up, down)
		return
	end

	local grid
	local x, y
	if p.quickpickingtile
		grid = p.tilegrid
		x, y = p.quickpickerx, p.quickpickery
	else
		grid = maps.tilecategories[p.category].grid
		x, y = p.pickerx, p.pickery
	end

	if left and handleKeyRepeat(t, "hkeyrepeat", t.prevleft, p.builderspeed)
		local layout = maps.getLayoutInGrid(grid, x, y)
		if layout and layout.span
			x, y = layout.l, layout.t
		end

		repeat
			if x > 1
				x = $ - 1
			else
				if not p.quickpickingtile
					if y > 1
						y = $ - 1
					else
						y = #grid
					end
				end
				x = #grid[y]
			end
		until grid[y][x] ~= nil
	end

	if right and handleKeyRepeat(t, "hkeyrepeat", t.prevright, p.builderspeed)
		local layout = maps.getLayoutInGrid(grid, x, y)
		if layout and layout.span
			x = layout.l + layout.w - 1
			y = layout.t
		end

		repeat
			if x < #grid[y]
				x = $ + 1
			else
				if not p.quickpickingtile
					if y < #grid
						y = $ + 1
					else
						y = 1
					end
				end
				x = 1
			end
		until grid[y][x] ~= nil
	end

	if up and handleKeyRepeat(t, "vkeyrepeat", t.prevup, p.builderspeed)
		local layout = maps.getLayoutInGrid(grid, x, y)
		if layout and layout.span
			x, y = layout.l, layout.t
		end

		repeat
			if y > 1
				y = $ - 1
			else
				y = #grid
			end
		until grid[y][x] ~= nil
	end

	if down and handleKeyRepeat(t, "vkeyrepeat", t.prevdown, p.builderspeed)
		local layout = maps.getLayoutInGrid(grid, x, y)
		if layout and layout.span
			x, y = layout.l, layout.t + layout.h - 1
		end

		repeat
			if y < #grid
				y = $ + 1
			else
				y = 1
			end
		until grid[y][x] ~= nil
	end

	local cursorlayout = maps.getLayoutInGrid(grid, x, y)
	if cursorlayout and cursorlayout.span
		x, y = cursorlayout.l, cursorlayout.t
	end

	if p.quickpickingtile
		p.quickpickerx, p.quickpickery = x, y
	else
		p.pickerx, p.pickery = x, y
	end

	-- Pick tile
	if bt & BT_JUMP and not (t.prevbuttons & BT_JUMP)
		local tile = grid[y][x]

		if tile ~= nil and tile > 1
			local tiledef = maps.tiledefs[tile]

			p.tile = tile

			p.layout = nil
			if tiledef.spanw ~= 1 or tiledef.spanh ~= 1
				local layout = getLayoutUnderCursor(p)
				if layout and layout.span
					p.layout = getLayoutPickInfoUnderCursor(p)
				end
			end

			maps.addTileToQuickPicker(p)

			/*p.tile = maps.tilecategories[p.category][tile]
			if maps.tiledefs_type[p.tile] == 1
				p.tiletype = maps.tiledefs_defaulttype[p.tile]
			end
			if p.category ~= p.prevcategory1
				p.prevcategory2 = p.prevcategory1
				p.prevpickertile2 = p.prevpickertile1
			end
			p.prevcategory1 = p.category
			p.prevpickertile1 = tile*/

			maps.closeTilePicker(p)
		end
	end

	-- Pick layout
	if bt & BT_CUSTOM1 and not (t.prevbuttons & BT_CUSTOM1)
		local tile = grid[y][x]
		local layout = getLayoutUnderCursor(p)

		if tile ~= nil and tile > 1 and layout and not layout.span
			p.layout = getLayoutPickInfoUnderCursor(p)
			p.tile = tile
			maps.addTileToQuickPicker(p)

			maps.closeTilePicker(p)
		end
	end

	if bt & BT_USE and not (t.prevbuttons & BT_USE)
		if p.quickpickingtile
			-- Open normal tile picker
			p.quickpickingtile = false
			local id = p.tilegrid[y][x]
			if id > 1
				local def = maps.tiledefs[id]
				p.category = def.category
				p.pickerx, p.pickery = def.pickerx, def.pickery
			end
		else
			-- Open category picker
			p.pickingcategory = true
		end
	end
end
