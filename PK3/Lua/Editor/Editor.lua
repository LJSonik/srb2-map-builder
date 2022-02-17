--#region modules
local custominput = ljrequire "custominput"
local bs = ljrequire "bytestream"
--#endregion


local map
maps.addLocalsRefresher(function()
	map = maps.map
end)


--#region classes
---@class maps.EditorMode
---@field id string

---@class maps.EditorModeDef
---@field id string
---@field on_enter function
---@field on_client_update function
---@field on_input_received function
---@field on_key_down function
---@field on_key_up function

---@class maps.EditorCommand
---@field name string
---@field id integer
---@field func function
--#endregion


--#region variables
---@type table<string, maps.EditorModeDef>
maps.editormodes = {}

---@type table<integer|string, maps.EditorCommand>
local editorcommands = {}
--#endregion


--#region functions

---@param map maps.Map
---@param pos integer
---@return boolean
function maps.isStackFull(map, pos)
	local n = 0
	for layer = 1, 4 do
		if map[layer][pos] ~= 1 then
			n = n + 1
		end
	end
	return n >= 2
end

---@param map maps.Map
---@param tile integer
---@param pos integer
---@param p maps.Player
function maps.placeTile(map, tile, pos, p)
	local oldtile = map[p.builderlayer][pos]

	if oldtile == 1 and maps.isStackFull(map, pos) then
		return
	end

	if (p.builderlayer == 2 or p.builderlayer == 3) and map.bothsolid then
		if not maps.tiledefs_empty[tile] then
			map.bothsolid[pos] = p.bothsolid
		elseif not maps.tiledefs_empty[oldtile] then
			map.bothsolid[pos] = true
		end
	end

	maps.setTile(p.builderlayer, pos, tile)

	/*if p.builderlayer == 1
		if not maps.objectsAtPosition(p.builderx, p.buildery)
			maps.setTile(1, pos, tile)
			maps.tileinfo[pos] = $ & ~240 | (tiletype << 4)

			-- !!!
			--if maps.tiledefs_type[tile] == 25 -- Enemy spawner
				--maps.checkSpawner(pos, p.builderx, p.buildery)
			--end
		end
	end*/

	if maps.tiledefs_empty[map[2][pos]] == maps.tiledefs_empty[map[3][pos]]
	and map.bothsolid then
		map.bothsolid[pos] = false
	end
end

---@param map maps.Map
---@param p maps.Player
---@param tile integer
---@param x1 fixed_t
---@param y1 fixed_t
---@param x2 fixed_t
---@param y2 fixed_t
function maps.placeTilesInLine(map, p, tile, x1, y1, x2, y2)
	tile = maps.tiledefs[tile].index

	local length = R_PointToDist2(x1, y1, x2, y2)
	local dx = (x2 - x1) / 32
	local dy = (y2 - y1) / 32

	local x, y = x1, y1
	local prevtx, prevty
	for step = 1, 32 do
		local tx = x / maps.TILESIZE
		local ty = y / maps.TILESIZE

		if tx ~= prevtx or ty ~= prevty then
			local pos = tx + ty * map.w
			maps.placeTile(map, tile, pos, p)
			prevtx, prevty = tx, ty
		end

		x = x + dx
		y = y + dy
	end
end

---@param map maps.Map
---@param p maps.Player
---@return boolean
function maps.tileLayoutConflictsWithMap(map, p)
	local layoutx1 = p.buildertilelayoutx1
	local layouty1 = p.buildertilelayouty1
	local layoutx2 = p.buildertilelayoutx2
	local layouty2 = p.buildertilelayouty2

	local mapx1 = p.builderx + (layoutx1 - p.buildertilelayoutanchorx)
	local mapy1 = p.buildery + (layouty1 - p.buildertilelayoutanchory)
	local layer = map[p.builderlayer]

	local mapy = mapy1
	for layouty = layouty1, layouty2 do
		local mapx = mapx1
		for layoutx = layoutx1, layoutx2 do
			local pos = mapx + mapy * map.w
			if layer[pos] ~= 1 or maps.isStackFull(map, pos) then
				return true
			end

			mapx = $ + 1
		end

		mapy = $ + 1
	end

	return false
end

---@param map maps.Map
---@param p maps.Player
function maps.placeTileLayout(map, p)
	local layout = maps.tilelayouts[p.buildertilelayoutindex]
	local layoutx1 = p.buildertilelayoutx1
	local layouty1 = p.buildertilelayouty1
	local layoutx2 = p.buildertilelayoutx2
	local layouty2 = p.buildertilelayouty2

	local mapx1 = p.builderx + (layoutx1 - p.buildertilelayoutanchorx)
	local mapy1 = p.buildery + (layouty1 - p.buildertilelayoutanchory)

	local mapy = mapy1
	for layouty = layouty1, layouty2 do
		local mapx = mapx1
		for layoutx = layoutx1, layoutx2 do
			local slot = layout:get(layoutx, layouty)
			local tile = maps.tiledefs[slot.tiledefid].index

			maps.placeTile(map, tile, mapx + mapy * map.w, p)

			mapx = $ + 1
		end

		mapy = $ + 1
	end
end

---@param p maps.Player
---@param dx integer
---@param dy integer
local function moveBuilder(p, dx, dy)
	/*p.builderx = $ + dx
	if p.builderx < 0
		p.builderx = map.w - 1
	end
	if p.builderx >= map.w
		p.builderx = 0
	end

	p.buildery = $ + dy
	if p.buildery < 0
		p.buildery = map.h - 1
	end
	if p.buildery >= map.h
		p.buildery = 0
	end*/

	p.builderx = min(max($ + dx, 0), map.w - 1)
	p.buildery = min(max($ + dy, 0), map.h - 1)
end

/*local function handleMovement(p, t, left, right, up, down)
	if left
		if t.prevleft
			if t.hkeyrepeat == 1
				t.hkeyrepeat = p.builderspeed
				moveBuilder(p, -1, 0)
			else
				t.hkeyrepeat = $ - 1
			end
		else
			t.hkeyrepeat = 8
			moveBuilder(p, -1, 0)
		end
	end

	if right
		if t.prevright
			if t.hkeyrepeat == 1
				t.hkeyrepeat = p.builderspeed
				moveBuilder(p, 1, 0)
			else
				t.hkeyrepeat = $ - 1
			end
		else
			t.hkeyrepeat = 8
			moveBuilder(p, 1, 0)
		end
	end

	if up
		if t.prevup
			if t.vkeyrepeat == 1
				t.vkeyrepeat = p.builderspeed
				moveBuilder(p, 0, -1)
			else
				t.vkeyrepeat = $ - 1
			end
		else
			t.vkeyrepeat = 8
			moveBuilder(p, 0, -1)
		end
	end

	if down
		if t.prevdown
			if t.vkeyrepeat == 1
				t.vkeyrepeat = p.builderspeed
				moveBuilder(p, 0, 1)
			else
				t.vkeyrepeat = $ - 1
			end
		else
			t.vkeyrepeat = 8
			moveBuilder(p, 0, 1)
		end
	end
end*/

function maps.addEditorCommand(name, func)
	local command = {
		name = name,
		id = #editorcommands + 1,
		func = func
	}

	editorcommands[name] = command
	editorcommands[command.id] = command
end

function maps.prepareEditorCommand(name)
	local input = bs.create()
	bs.writeUInt(input, 2, 3)
	bs.writeByte(input, editorcommands[name].id)

	return input
end

function maps.addEditorMode(mode)
	maps.editormodes[mode.id] = mode
end

function maps.receiveEditorCommand(input, p)
	local command = editorcommands[bs.readByte(input)]
	command.func(input, p)
end

-- !!! Handle invalid inputs (EOS, unknown command, etc)
function maps.receiveEditorInput(input, p)
	local mode = maps.editormodes[p.buildermode.id]
	if mode.on_input_received then
		mode.on_input_received(input, p)
	end
end

function maps.readCursorMovement(input, p)
	local dx = bs.readUInt(input, 6) - 31
	local dy = bs.readUInt(input, 6) - 31

	p.builderx = min(max($ + dx, 0), maps.map.w - 1)
	p.buildery = min(max($ + dy, 0), maps.map.h - 1)
end

function maps.updateEditor(p)
end

/*function maps.updateEditor(p)
	local owner = p.owner ~= nil and players[p.owner] or nil
	local t

	local left, right, up, down
	local bt
	if owner and not owner.menu
		t = owner.maps
		bt = owner.cmd.buttons
		left, right, up, down = maps.getKeys(owner)
	else
		bt = 0
		left, right, up, down = false, false, false, false
	end

	if p.pickingtile
		maps.handleTilePicker(p, t, bt, left, right, up, down)
	elseif p.editormenu
		maps.handleOldEditorWheelMenu(owner, t, bt, left, right, up, down)
	else
		maps.handleBuilding(p, owner, t, bt, left, right, up, down)

		if bt & BT_CUSTOM3 and not (t.prevbuttons & BT_CUSTOM3)
			p.editormenu = maps.openWheelMenu(owner)
		end
	end

	if bt & BT_TOSSFLAG and not (t.prevbuttons & BT_TOSSFLAG)
		local admin = (owner == server or IsPlayerAdmin(owner))
		menulib.open(owner, admin and "mainhost" or "mainplayer", "maps")
	end

	if t and not owner.menu
		t.prevleft, t.prevright, t.prevup, t.prevdown = left, right, up, down
		t.prevbuttons = owner.cmd.buttons
	end
end*/

---@param p maps.Player
function maps.enterEditor(p)
	if p.obj then
		p.builderx = min(p.obj.l / maps.TILESIZE, maps.map.w - 1)
		p.buildery = min(p.obj.b / maps.TILESIZE, maps.map.h - 1)
	end

	maps.leavePlayMode(p)

	p.builder = true

	maps.enterEditorMode(p, "pen")

	--p.fillremove = nil
	--p.fillx, p.filly = nil, nil

	p.renderscale = p.editorrenderscale

	local owner = maps.getOwner(p)
	if owner then
		custominput.start(owner)

		if owner == consoleplayer then
			maps.enterClientEditor()
		end
	end

	-- !!!!!
	p.buildertile = 59
end

function maps.leaveEditor(p)
	if p.pickingtile then
		maps.closeTilePicker(p)
	end

	p.renderscale = 16

	p.builder = nil

	local owner = maps.getOwner(p)
	if owner then
		custominput.stop(owner)

		if owner == consoleplayer then
			maps.leaveClientEditor()
		end
	end
end

---Changes the editor mode for a player
---@param p maps.Player
---@param modeid string
function maps.enterEditorMode(p, modeid)
	local mode = maps.editormodes[modeid]

	p.buildermode = { id = modeid }

	if mode.on_enter then
		mode.on_enter(p)
	end
end

--#endregion


--#region editor commands
maps.addEditorCommand("play", function(_, p)
	maps.spawnPlayer(p)
end)

-- !!! Check invalid input
maps.addEditorCommand("set_cursor_position", function(cmd, p)
	p.builderx = bs.readUInt16(cmd)
	p.buildery = bs.readUInt16(cmd)
end)

maps.addEditorCommand("set_cursor_tile", function(cmd, p)
	local tile = bs.readUInt16(cmd)
	if not maps.tiledefs[tile] then
		-- !!! error
		return
	end

	p.buildertile = tile
	p.buildertilelayoutindex = nil
end)

maps.addEditorCommand("set_cursor_tile_layout", function(cmd, p)
	local index = bs.readUInt16(cmd)
	local x1 = bs.readByte(cmd)
	local y1 = bs.readByte(cmd)
	local x2 = bs.readByte(cmd)
	local y2 = bs.readByte(cmd)
	local anchorx = bs.readByte(cmd)
	local anchory = bs.readByte(cmd)

	local layout = maps.tilelayouts[index]
	if not layout
	or x1 < 1 or x1 > layout.width
	or y1 < 1 or y1 > layout.height
	or x2 < 1 or x2 > layout.width
	or y2 < 1 or y2 > layout.height
	or anchorx < x1 or anchorx > x2
	or anchory < y1 or anchory > y2 then
		-- !!! error
		return
	end

	p.buildertile = nil
	p.buildertilelayoutindex = index
	p.buildertilelayoutx1 = x1
	p.buildertilelayouty1 = y1
	p.buildertilelayoutx2 = x2
	p.buildertilelayouty2 = y2
	p.buildertilelayoutanchorx = anchorx
	p.buildertilelayoutanchory = anchory
end)

maps.addEditorCommand("set_cursor_layer", function(cmd, p)
	p.builderlayer = bs.readUInt(cmd, 2) + 1
end)
--#endregion
