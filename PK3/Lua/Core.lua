-- The Map Builder by LJ Sonic

-- Todo (important):
-- Handle gamestate resend
-- Fix chasecam off screwing up controls
-- Fix clientside bug where player can't move

-- Todo:
-- Don't reset when resizing map
-- Remove objects when builders build on them?
-- Prevent players from spawning in a solid block
-- Improve help menu?
-- Improve springs (better collision box, ...)
-- Change music for playing players when changed?
-- Fix/Improve layer erasing?
-- Improve sound handling
-- More tips in menus
-- Delay before allowing player respawn? (1 second? Or maybe not at all...)
-- Improve handling of map changes
-- Handle AFK players? (host.wad?)
-- Check for desynch?

-- Todo (fixes):
-- Remove player.maps when leaving app without leaving server?
-- Check case where 2 players leave at the same tic
-- Don't let border/tile collisions prevent object collisions
-- Fix player leaving potentially skipping next player's turn?
-- Fix players walking when moving against walls
-- Fix objects disappearing on borders
-- Fix braking sound happening sometimes
-- Check both Sonic and Tails for Tails pickup
-- Fix death animation and direction?
-- Fix player input?

-- Todo (features):
-- Add monitors
-- Ring toss
-- Conveyor belts?
-- Handle end signs correctly
-- Warps?
-- Brake?
-- Handle water/lava/goop? (if possible...)
-- Enemy wall?
-- Add spring falling animation?
-- Server-protected areas?
-- Teetering?
-- Ladders? (Alyssa)
-- Flowerpot? (forgot who wanted this lel)

-- Todo (optimisations):
-- Disable HUD for joiners
-- Improve object/blockmap hole handling
-- Compress objects in gamestate?
-- Variables for screen distance
-- Cache object sprites?
-- Add tile type optimisation tables?
-- Use blockmap to draw objects? (may cause drawing order problems)


local menulib = ljrequire "menulib"
local custominput = ljrequire "custominput"
local bs = ljrequire "bytestream"


local FU = FRACUNIT

maps.SCREEN_WIDTH = 320 * FU
maps.SCREEN_HEIGHT = 200 * FU


-- Variables
--maps.pp -- List of "fake" players
maps.time = 0
maps.mapchanged = true
--maps.mapticker, maps.maptickerspeed -- For respawning rings and other shit
--maps.objectticker -- For despawning far away enemies
--maps.app -- For integration with the Computers library
local localsrefreshers = {}

-- Options
maps.allowmusicpreview = true
maps.allowediting = true


function maps.copyTable(t)
	local t2 = {}

	for k, v in pairs(t) do
		if type(k) == "table" then
			k = maps.copyTable(k)
		end
		if type(v) == "table" then
			v = maps.copyTable(v)
		end

		t2[k] = v
	end

	return t2
end

function maps.addLocalsRefresher(callback)
	table.insert(localsrefreshers, callback)
end

function maps.refreshLocals()
	for _, callback in ipairs(localsrefreshers) do
		callback()
	end
end

function maps.getPlayer(owner)
	return maps.pp[owner.maps.player]
end

function maps.getOwner(p)
	return p.owner ~= nil and players[p.owner] or nil
end

function maps.getKeys(p)
	local cmd = p.cmd

	local left, right = false, false
	if cmd.sidemove < 0 then
		left = true
	elseif cmd.sidemove > 0 then
		right = true
	end

	local up, down = false, false
	if cmd.forwardmove > 0 then
		up = true
	elseif cmd.forwardmove < 0 then
		down = true
	end

	return left, right, up, down
end

function maps.getLocalKeys(cmd)
	local left, right = false, false
	if cmd.sidemove < 0 then
		left = true
	elseif cmd.sidemove > 0 then
		right = true
	end

	local up, down = false, false
	if cmd.forwardmove > 0 then
		up = true
	elseif cmd.forwardmove < 0 then
		down = true
	end

	return left, right, up, down
end


-- !!!
rawset(_G, "getMap", function()
	return maps.map
end)

-- !!!
rawset(_G, "getMapPlayers", function()
	return maps.pp
end)

-- !!!
function maps.getMap()
	return maps.map
end

function maps.changeMusic(n, p)
	S_StopMusic(p)
	if n ~= nil then
		S_ChangeMusic(n, true, p)
	end
end

function maps.startSound(n, o)
	if not o then
		S_StartSound(nil, n)
		return
	end

	o = o.obj -- !!!!

	local x, y = o.l + o.w / 2, o.t + o.h / 2
	local d = 32 * FU

	for i = 1, #maps.pp do
		local p = maps.pp[i]
		local owner = maps.getOwner(p)
		if not owner then continue end

		local px, py
		if p.builder then
			px, py = (p.builderx - 1) * maps.TILESIZE, (p.buildery - 1) * maps.TILESIZE
		elseif p.dead then
			px, py = p.x, p.y
		else
			px, py = p.obj.l + p.obj.w / 2, p.obj.b + p.obj.h / 2
		end

		if R_PointToDist2(x, y, px, py) < d then
			S_StartSound(nil, n, owner)
		end
	end
end

local function joinGame(owner)
	local i = #maps.pp + 1
	local p = {}
	maps.pp[i] = p

	p.owner = #owner

	p.tile = nil
	p.builderlayer = 2
	p.bothsolid = true
	--p.tiletype = 0
	p.builderx = maps.map.spawnx / maps.TILESIZE
	p.buildery = min(maps.map.spawny / maps.TILESIZE + 1, maps.map.h - 1)
	-- !!!
	p.scrollx = 0
	p.scrolly = 0
	p.renderscale = 16
	p.editorrenderscale = p.renderscale
	p.builderspeed = 2
	p.erasebothlayers = false
	p.camera = 1
	p.scrolldistance = 9

	-- !!!
	maps.spawnPlayer(p)
	--maps.enterEditor(p)

	owner.pflags = $ | PF_FORCESTRAFE

	owner.maps = {}
	local t = owner.maps

	t.player = i
	t.prevbuttons = owner.cmd.buttons
	t.prevleft, t.prevright, t.prevup, t.prevdown = maps.getKeys(owner)
	t.hkeyrepeat = 8
	t.vkeyrepeat = 8

	--menulib.open(owner, "help1", "maps")

	if owner == consoleplayer then
		maps.initialiseClient()
	end

	COM_BufInsertText(owner, "chasecam 1")
end

local function leaveGame(i)
	local p = maps.pp[i]

	-- Remove the player's body
	if p.obj then
		maps.removeObject(p.obj)
	end

	-- Remove the player
	table.remove(maps.pp, i)

	-- Relink players to their owners
	if cpulib then
		for _, p in ipairs(maps.app.users) do
			if p.maps.player > i then
				p.maps.player = $ - 1
			end
		end
	else
		for p in players.iterate do
			if p.maps.player > i then
				p.maps.player = $ - 1
			end
		end
	end
end

local function initialiseGame()
	maps.pp = {}

	maps.map = {}
	maps.map.w, maps.map.h = 384, 48
	--maps.map.w, maps.map.h = 512, 64 -- !!!
	maps.map.backgroundtype = 1
	maps.map.background = 1
	maps.map.music = "mp_ghz"

	maps.clearMap()

	if not cpulib then
		for p in players.iterate do
			joinGame(p)
		end
	end
end

local function startGame()
	if not cpulib then
		for p in players.iterate do
			p.pflags = $ | PF_FORCESTRAFE
		end

		hud.disable("score")
		hud.disable("time")
		hud.disable("rings")
		hud.disable("lives")
		--hud.disable("rankings")
		--hud.disable("coopemeralds")
	end
end

local function updateGame()
	maps.time = $ + 1

	-- Look for mid-game joiners
	if not cpulib then
		for p in players.iterate do
			if not p.maps then
				joinGame(p)
			end
		end
	end

	-- !!!
	-- Placeholder to handle player leaves
	-- Or maybe it's just the normal code...
	/*for i = #maps.pp, 1, -1
		local p = maps.pp[i]
		local owner = p.owner ~= nil and players[p.owner] or nil
		if not owner then
		or owner.maps.player ~= i -- !!! Check for this in joinGame?
			leaveGame(i)
		end
	end*/

	if cpulib then
		for i = 1, #maps.app.users do
			local p = maps.app.users[i]

			-- Handle menu
			if p.menu then
				menulib.handle(p, "maps")

				-- If the menu just closed
				if not p.menu then
					p.maps.prevbuttons = $ | BT_JUMP | BT_SPIN | BT_TOSSFLAG
				end
			end
		end
	else
		for p in players.iterate do
			-- Handle menu
			if p.menu then
				menulib.handle(p, "maps")

				-- If the menu just closed
				if not p.menu then
					p.maps.prevbuttons = $ | BT_JUMP | BT_SPIN | BT_TOSSFLAG
				end
			end
		end
	end

	-- Handle players
	for i = 1, #maps.pp do
		local p = maps.pp[i]
		if p.builder then
			maps.updateEditor(p)
		else
			maps.handlePlayer(p, i)
		end
	end

	maps.handleTileRespawn()
	--maps.handleMapTicker()
	maps.handleObjects()
	maps.handleObjectDespawn()
end


if not cpulib then
	addHook("PlayerCmd", function(owner, cmd)
		if maps.compressedgamestate then
			maps.decompressGamestate()
		end

		maps.switchEditorStateToClientSide()

		-- Hack due to consoleplayer being incorrectly set for joiners
		--if #consoleplayer == 0 and not isserver return end

		local client = maps.client

		if client then
			client.cmd = $ or {}
			local clcmd = client.cmd

			/*clcmd.forwardmove = cmd.forwardmove
			clcmd.sidemove = cmd.sidemove
			clcmd.buttons = cmd.buttons

			if client.sentangleturn ~= nil then
				clcmd.angleturn = $ + cmd.angleturn - client.sentangleturn
				clcmd.aiming = $ + cmd.aiming - client.sentaiming
			else
				clcmd.angleturn = cmd.angleturn
				clcmd.aiming = cmd.aiming
			end*/

			clcmd.forwardmove = cmd.forwardmove
			clcmd.sidemove = cmd.sidemove
			clcmd.buttons = cmd.buttons
			clcmd.angleturn = cmd.angleturn
			clcmd.aiming = cmd.aiming
		end

		custominput.handleSending(owner, cmd)

		if client then
			client.sentangleturn = cmd.angleturn
			client.sentaiming = cmd.aiming
		end
	end)

	addHook("KeyDown", function(key)
		maps.switchEditorStateToClientSide()
		maps.handleKeyDown(key)
	end)

	addHook("KeyUp", function(key)
		maps.switchEditorStateToClientSide()
		maps.handleKeyUp(key)
	end)

	addHook("PreThinkFrame", function()
		if maps.compressedgamestate then
			maps.decompressGamestate()
		end

		maps.switchEditorStateToServerSide()

		for owner in players.iterate do
			custominput.handleReception(owner)
		end
	end)

	function custominput.receive(input, owner)
		maps.switchEditorStateToServerSide()
		maps.receiveEditorInput(input, maps.getPlayer(owner))
	end

	addHook("ThinkFrame", function()
		if gamemap ~= 557 then return end

		if maps.compressedgamestate then
			maps.decompressGamestate()
		end

		maps.switchEditorStateToServerSide()

		if maps.mapchanged then
			maps.mapchanged = false
			if not maps.map then
				initialiseGame()
			end
			startGame()
		end

		// !!!!
		if not (maps.cv_slow and maps.cv_slow.value) or not (leveltime % (TICRATE / 1)) then
			updateGame()
		end
	end)

	addHook("PlayerQuit", function(owner)
		maps.switchEditorStateToServerSide()

		if owner.maps then
			leaveGame(owner.maps.player)
		end
	end)

	addHook("GameQuit", function()
		maps.client = nil
	end)

	hud.add(function(v, owner)
		if gamemap == 557
		and not (splitscreen and #owner == 1) then
			local cl = maps.client
			if cl and cl.player and cl.player.builder then
				maps.switchEditorStateToClientSide()
				maps.updateClient(v)
			end

			maps.drawGame(v, owner)
		end
	end, "game")
end

addHook("MapChange", function()
	if gamemap ~= 557 then return end

	maps.switchEditorStateToServerSide()

	maps.mapchanged = true

	for p in players.iterate do
		if p.menu then
			menulib.close(p)
		end
	end

	hud.enable("score")
	hud.enable("time")
	hud.enable("rings")
	hud.enable("lives")
	hud.enable("rankings")
	hud.enable("coopemeralds")
end)

addHook("NetVars", function(n)
	maps.mapchanged = n($)

	--maps.mapticker = n($)
	--maps.maptickerspeed = n($)

	maps.tiledata = n($)

	maps.pp = n($)

	maps.allowmusicpreview = n($)
	maps.allowediting = n($)

	if maps.map then
		maps.compressGamestate()
	end
	maps.compressedgamestate = n($)
end)

addHook("JumpSpecial", function()
	if gamemap == 557 then return true end
end)

addHook("SpinSpecial", function()
	if gamemap == 557 then return true end
end)


-- Commands

function maps.addCommand(name, func, ...)
	COM_AddCommand(name, function(...)
		if maps.compressedgamestate then
			maps.decompressGamestate()
		end

		maps.switchEditorStateToServerSide()

		func(...)
	end, ...)
end

function maps.stringToPlayer(s)
	if not s then return nil end

	if tonumber(s) == nil then
		s = s:lower()
		for p in players.iterate do
			if s == p.name:lower() then return p end
		end
	else
		local p = players[tonumber(s)]
		if p and p.valid then return p end
	end
end

maps.addCommand("helpmaps", function(p)
	if not p.maps then
		return
	end

	if p.editormenu then
		maps.closeWheelMenu(p)
		p.editormenu = nil
	end
	if p.menu then
		menulib.close(p)
	end
	menulib.open(p, "help1", "maps")
end)

maps.addCommand("mapshelp", function(p)
	if not p.maps then
		return
	end

	if p.editormenu then
		maps.closeWheelMenu(p)
		p.editormenu = nil
	end
	if p.menu then
		menulib.close(p)
	end
	menulib.open(p, "help1", "maps")
end)


if cpulib then
	cpulib.addApplication{
		name = "The Map Builder",
		dontopen = true,

		open = function(runningapp)
			maps.app = runningapp

			if maps.compressedgamestate then
				maps.decompressGamestate()
			end

			initialiseGame()
			startGame()
		end,

		join = function(p, runningapp)
			maps.app = runningapp
			joinGame(p)
		end,

		leave = function(p, runningapp)
			maps.app = runningapp
			leaveGame(p.maps.player)
		end,

		handle = function(runningapp)
			maps.app = runningapp

			if maps.compressedgamestate then
				maps.decompressGamestate()
			end

			updateGame()
		end,

		draw = drawGame
	}

	cpulib.openApplication(#cpulib.apps) -- !!!!
end
