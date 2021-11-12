-- Todo:
-- Prevent edits while leaving editor mode
-- Full resend cursor when switching to mode (if needed)


local custominput = ljrequire "custominput"
local bs = ljrequire "bytestream"
local gui = ljrequire "ljgui"


local playerfieldstobackup = {
	"builderx",
	"buildery",

	"buildertile",

	"buildertilelayoutindex",
	"buildertilelayoutx1",
	"buildertilelayouty1",
	"buildertilelayoutx2",
	"buildertilelayouty2",
	"buildertilelayoutanchorx",
	"buildertilelayoutanchory",

	"builderlayer",
}


/*local function moveBuilder(p, dx, dy)
	p.builderx = min(max($ + dx, 0), maps.map.w - 1)
	p.buildery = min(max($ + dy, 0), maps.map.h - 1)
end*/

local function handleClientEditorKeyboardMovement(p, cmd)
	local cl = maps.client

	local dx, dy = 0, 0

	if cl.leftpressed then
		if cl.hkeyrepeat == 1 then
			cl.hkeyrepeat = p.builderspeed
			dx = -1
		else
			cl.hkeyrepeat = $ - 1
		end
	end

	if cl.rightpressed then
		if cl.hkeyrepeat == 1 then
			cl.hkeyrepeat = p.builderspeed
			dx = 1
		else
			cl.hkeyrepeat = $ - 1
		end
	end

	if cl.uppressed then
		if cl.vkeyrepeat == 1 then
			cl.vkeyrepeat = p.builderspeed
			dy = -1
		else
			cl.vkeyrepeat = $ - 1
		end
	end

	if cl.downpressed then
		if cl.vkeyrepeat == 1 then
			cl.vkeyrepeat = p.builderspeed
			dy = 1
		else
			cl.vkeyrepeat = $ - 1
		end
	end

	return dx, dy
end

local function handleClientEditorMouseMovement(p, cmd)
	local cl = maps.client
	local mouse = gui.root.mouse

	if mouse.x == mouse.oldX and mouse.y == mouse.oldY
	or gui.root.main.editorPanel then
		return 0, 0
	end

	local x = (cl.scrollx + mouse.x / maps.renderscale) / maps.TILESIZE
	local y = (cl.scrolly + mouse.y / maps.renderscale) / maps.TILESIZE

	return x - p.builderx, y - p.buildery
end

function maps.writeClientCursorMovement(input, dx, dy)
	-- Send position relative to previous position
	bs.writeUInt(input, 6, dx + 31)
	bs.writeUInt(input, 6, dy + 31)
end

function maps.handleClientEditorMovement(p, cmd)
	local cl = maps.client
	local mode = maps.editormodes[p.buildermode.id]
	local oldx, oldy = p.builderx, p.buildery

	local dx, dy = handleClientEditorKeyboardMovement(p, cmd)
	if dx == 0 and dy == 0 then
		dx, dy = handleClientEditorMouseMovement(p, cmd)
	end

	p.builderx = min(max($ + dx, 0), maps.map.w - 1)
	p.buildery = min(max($ + dy, 0), maps.map.h - 1)

	local dx = p.builderx - oldx
	local dy = p.buildery - oldy

	if abs(dx) > 31 or abs(dy) > 31 then
		cl.fullresendneeded = true
	end

	if not cl.fullresendneeded then
		return true
	else
		if cl.fullresendtime > 0 then
			cl.fullresendtime = $ - 1
		end

		if cl.fullresendtime == 0 then
			local command = maps.prepareEditorCommand("set_cursor_position")
			bs.writeUInt16(command, p.builderx)
			bs.writeUInt16(command, p.buildery)
			custominput.send(command)

			cl.fullresendneeded = false
			cl.fullresendtime = TICRATE / 4
		end

		return false
	end
end

local function handleClientEditorMovementKey(key, down)
	local cl = maps.client
	key = key.name

	if key == "LEFT ARROW" then
		cl.leftpressed = down
		cl.hkeyrepeat = TICRATE / 4
		return true
	elseif key == "RIGHT ARROW" then
		cl.rightpressed = down
		cl.hkeyrepeat = TICRATE / 4
		return true
	elseif key == "UP ARROW" then
		cl.uppressed = down
		cl.vkeyrepeat = TICRATE / 4
		return true
	elseif key == "DOWN ARROW" then
		cl.downpressed = down
		cl.vkeyrepeat = TICRATE / 4
		return true
	else
		return false
	end
end

function maps.handleClientEditorMovementKeyDown(key)
	handleClientEditorMovementKey(key, true)
end

function maps.handleClientEditorMovementKeyUp(key)
	handleClientEditorMovementKey(key, false)
end

function maps.updateClientEditorCamera(p)
	-- local cl = maps.client
	-- local mouse = gui.root.mouse
	-- local speed = 16 * maps.TILESIZE / p.renderscale

	-- if mouse.x <= 0 then
	-- 	cl.scrollx = max($ - speed, 0)
	-- elseif mouse.x >= maps.SCREEN_WIDTH - 1 then
	-- 	local limit = maps.map.w * maps.TILESIZE - maps.SCREEN_WIDTH / p.renderscale
	-- 	cl.scrollx = min($ + speed, limit)
	-- end

	-- if mouse.y <= 0 then
	-- 	cl.scrolly = max($ - speed, 0)
	-- elseif mouse.y >= maps.SCREEN_HEIGHT - 1 then
	-- 	local limit = maps.map.h * maps.TILESIZE - maps.SCREEN_HEIGHT / p.renderscale
	-- 	cl.scrolly = min($ + speed, limit)
	-- end
end

function maps.backupEditorState(p)
	local bk = {}

	for _, field in ipairs(playerfieldstobackup) do
		bk[field] = p[field]
	end

	bk.buildermode = maps.copyTable(p.buildermode)

	return bk
end

function maps.restoreEditorState(bk, p)
	for _, field in ipairs(playerfieldstobackup) do
		p[field] = bk[field]
	end

	p.buildermode = maps.copyTable(bk.buildermode)
end

function maps.switchEditorStateToSide(active)
	local cl = maps.client
	if not cl or cl.active == active then return end

	local p = cl.player
	if not (p and p.builder) then return end

	local backup = maps.backupEditorState(p)

	if cl.backup then
		maps.restoreEditorState(cl.backup, p)
	end

	cl.backup = backup

	cl.active = active
end

function maps.switchEditorStateToServerSide()
	maps.switchEditorStateToSide(false)
end

function maps.switchEditorStateToClientSide()
	maps.switchEditorStateToSide(true)
end

function maps.enterClientEditor()
	local cl = maps.client

	cl.backup = nil

	maps.centerClientCamera()

	cl.prevleft, cl.prevright, cl.prevup, cl.prevdown = false, false, false, false
	cl.prevbuttons = 0
	cl.inputeaten = true

	cl.fullresendneeded = false
	cl.fullresendtime = 0

	cl.panning = false

	maps.initialiseGui()
end

function maps.leaveClientEditor(p)
	local p = maps.getPlayer(consoleplayer)
	local cl = maps.client

	--cl.prevleft, cl.prevright, cl.prevup, cl.prevdown = false, false, false, false
	--cl.prevbuttons = 0

	cl.backup = nil

	maps.uninitialiseGui()
end

function maps.updateClientEditor(p, cmd, v)
	local cl = maps.client
	local mouse = gui.root.mouse
	local mode = maps.editormodes[p.buildermode.id]

	if cl.panning then
		cl.scrollx = $ - (mouse.x - mouse.oldX) / p.renderscale
		cl.scrolly = $ - (mouse.y - mouse.oldY) / p.renderscale

		local maxX = maps.map.w * maps.TILESIZE - maps.SCREEN_WIDTH  / p.renderscale
		local maxY = maps.map.h * maps.TILESIZE - maps.SCREEN_HEIGHT / p.renderscale

		cl.scrollx = min(max($, 0), maxX)
		cl.scrolly = min(max($, 0), maxY)
	end

	if not cl.inputeaten then
		if cmd.buttons & BT_WEAPONPREV and not (maps.client.prevbuttons & BT_WEAPONPREV) then
			if p.editorrenderscale ~= 16 then
				p.editorrenderscale = $ * 2

				if p.builder then
					p.renderscale = p.editorrenderscale
					maps.centerClientCamera()
				end
			end
		end

		if cmd.buttons & BT_WEAPONNEXT and not (maps.client.prevbuttons & BT_WEAPONNEXT) then
			if p.editorrenderscale ~= 4 then
				p.editorrenderscale = $ / 2

				if p.builder then
					p.renderscale = p.editorrenderscale
					maps.centerClientCamera()
				end
			end
		end

		maps.updateClientEditorCamera(p)

		if cmd.buttons & BT_SPIN and not (cl.prevbuttons & BT_SPIN) then
			maps.openEditorMenu()
		end
	end

	if mode.on_client_update then
		mode.on_client_update(p, cmd, v, oldx, oldy)
	end
end
