if true return end


local FU = FRACUNIT

maps.PLAYER_WIDTH = 6 * FU
maps.PLAYER_HEIGHT = 10 * FU
maps.PLAYER_SPIN_HEIGHT = 6 * FU
maps.PLAYER_JUMP = FU * 7 / 2


function maps.playerOnGround(p)
	local o = p.obj

	if (maps.objy[o] + maps.objh[o]) % maps.BLOCK_SIZE ~= 0 -- Feet not exactly on tile bottom
	or maps.objy[o] >= maps.map.h * maps.BLOCK_SIZE - maps.objh[o] -- Feet at bottom of the map
		return false
	end

	local y = (maps.objy[o] + maps.objh[o]) / maps.BLOCK_SIZE * maps.map.w + 1
	for i = maps.objx[o] / maps.BLOCK_SIZE + y, (maps.objx[o] + maps.PLAYER_WIDTH - 1) / maps.BLOCK_SIZE + y
		local tile = maps.map1[i]
		if maps.tileground[tile]
			return true
		else
			local t = maps.tiletype[tile]
			if t == 1 and maps.tileinfo[i] >> 4 ~= 0
				return true
			elseif t == 6 and (p.flash or p.invincibility)
			or t == 12 and (p.jump or p.spin or p.spindash ~= nil) -- !!!
				return true
			end
		end
	end
end

function maps.playerOnIce(p)
	local o = p.obj

	if (maps.objy[o] + maps.objh[o]) % maps.BLOCK_SIZE ~= 0
	or maps.objy[o] >= maps.map.h * maps.BLOCK_SIZE - maps.objh[o]
		return false
	end

	local y = (maps.objy[o] + maps.objh[o]) / maps.BLOCK_SIZE * maps.map.w + 1
	for i = maps.objx[o] / maps.BLOCK_SIZE + y, (maps.objx[o] + maps.PLAYER_WIDTH - 1) / maps.BLOCK_SIZE + y
		local tile = maps.tiletype[maps.map1[i]]
		if tile == 23 or tile == 24 -- !!!
			return true
		end
	end
end

-- ...
local function playerCantClimb(p)
	local o = p.obj

	local w = maps.map.w
	local x = maps.objdir[o] == 1 and (maps.objx[o] - 1) / maps.BLOCK_SIZE + 1 or (maps.objx[o] + maps.PLAYER_WIDTH) / maps.BLOCK_SIZE + 1
	for i = x + maps.objy[o] / maps.BLOCK_SIZE * w, min(x + (maps.objy[o] + maps.objh[o] - 1) / maps.BLOCK_SIZE * w, w * maps.map.h), w
		local tile = maps.tiletype[maps.map1[i]]
		if tile == 1 and maps.tileinfo[i] >> 4 == 1 -- Solid
		or tile == 23 -- Ice
			return false
		end
	end

	return true
end

function maps.playerColliding(p)
	local o = p.obj

	if maps.objx[o] < 0 or maps.objx[o] + maps.PLAYER_WIDTH > maps.map.w * maps.BLOCK_SIZE or maps.objy[o] < 0
		return true
	end

	for x = maps.objx[o] / maps.BLOCK_SIZE + 1, (maps.objx[o] + maps.PLAYER_WIDTH - 1) / maps.BLOCK_SIZE + 1
		for y = maps.objy[o] / maps.BLOCK_SIZE + 1, min((maps.objy[o] + maps.objh[o] - 1) / maps.BLOCK_SIZE + 1, maps.map.h)
			local i = x + (y - 1) * maps.map.w
			local tile = maps.tiletype[maps.map1[i]]
			if tile == 1 and maps.tileinfo[i] >> 4 == 1 -- Solid
			or tile == 6 -- Floor damages
			or tile == 7 -- Ceiling damages
			or tile == 23 -- Ice
				return true
			end
		end
	end
end

function maps.setPlayerAnimation(p, anim)
	local o = p.obj
	maps.objanim[o], maps.objspr[o] = anim, maps.skininfo[p.skin].anim[anim].spd
end

local function loopPlayerAnimation(p)
	local a = maps.skininfo[p.skin].anim[p.anim]

	if p.anim == "walk"
		p.spr = ($ + 4 * abs(p.dx) / FU - a.spd) % (a.spd * #a) + a.spd
	else
		p.spr = $ + 1
		if p.spr >= a.spd * (#a + 1)
			p.spr = a.spd
		end
	end
end

local function setPlayerSkin(p, skin)
	p.skin = skin
	if p.obj
		maps.setPlayerAnimation(p, maps.objanim[p.obj])
	end
end

function maps.spinPlayer(p)
	local o = p.obj

	p.spin = true

	maps.setObjectHeight(o, maps.PLAYER_SPIN_HEIGHT)

	if p.anim ~= "spin"
		maps.setPlayerAnimation(p, "spin")
	end
	maps.startSound(sfx_spin, p)
end

function maps.unspinPlayer(p)
	local o = p.obj

	p.spindash = false

	maps.setObjectHeight(o, maps.PLAYER_HEIGHT)

	if maps.playerColliding(p)
		maps.setObjectHeight(o, maps.PLAYER_SPIN_HEIGHT)
		if abs(maps.objdx[o]) < FU / 2
			if maps.objdx[o] < 0
				maps.objdx[o] = $ - FU / 2
			elseif maps.objdx[o] > 0
				maps.objdx[o] = $ + FU / 2
			elseif maps.objdir[o] == 1
				maps.objdx[o] = $ - FU / 2
			else
				maps.objdx[o] = $ + FU / 2
			end
		end
		return false
	end

	p.spin = false

	if maps.objdx[o] == 0
		maps.setPlayerAnimation(p, "std")
	elseif abs(maps.objdx[o]) < maps.skininfo[p.skin].run
		maps.setPlayerAnimation(p, "walk")
	else
		maps.setPlayerAnimation(p, "run")
	end

	return true
end

local function jumpPlayer(p)
	if p.carried
		maps.pp[maps.objextra[p.carried]].carry = nil
		p.carried = nil
	end

	if p.spin
		if not maps.unspinPlayer(p)
			return
		end
	elseif p.spindash ~= false and not maps.unspinPlayer(p)
		return
	end

	local o = p.obj

	if p.thok
		p.thok = false
	end

	p.jump = true

	maps.objdy[o] = -maps.PLAYER_JUMP

	maps.setObjectHeight(o, maps.PLAYER_SPIN_HEIGHT)

	maps.setPlayerAnimation(p, "spin")
	maps.startSound(sfx_jump, p)
end

local function thokPlayer(p)
	local o = p.obj

	p.thok = true
	maps.objdx[o] = maps.objdir[o] == 1 and -maps.skininfo[p.skin].thok or maps.skininfo[p.skin].thok

	local thok = maps.spawnObject(maps.OBJ_THOK, maps.objx[o], maps.objy[o])
	maps.objcolor[thok] = p.owner ~= nil and players[p.owner] and players[p.owner].skincolor or SKINCOLOR_BLUE
	maps.objextra[thok] = 8 -- Vanish after 8 tics

	maps.startSound(sfx_thok, p)
end

function maps.spawnPlayer(n)
	local p = maps.pp[n]
	local owner = p.owner ~= nil and players[p.owner] or nil

	if p.builder
		p.builderx, p.buildery = p.x, p.y

		p.builder = nil
		p.choosingtile = nil
		p.choosingtheme = nil
	elseif p.obj
		-- Remove the old body
		maps.removeObject(p.obj)
	end

	p.dead = nil
	p.x, p.y = nil, nil
	p.dx, p.dy = nil, nil

	-- Find spawn location and direction
	local x, y
	local h = maps.PLAYER_HEIGHT
	local dir
	if p.starpostx ~= nil
		x = p.starpostx * maps.BLOCK_SIZE - maps.BLOCK_SIZE / 2
		y = p.starposty * maps.BLOCK_SIZE - h
		dir = p.starpostdir
	elseif p.spawnx == nil
		x = maps.map.spawnx
		y = maps.map.spawny - h + 1
		dir = maps.map.spawndir
	else
		x = p.spawnx
		y = p.spawny - h + 1
		dir = p.spawndir
	end

	p.jump = false
	p.spin = false
	p.spindash = false
	p.thok = nil
	p.fly = nil
	p.glide = nil
	p.climb = nil
	p.skin = owner and owner.mo and owner.mo.valid and owner.mo.skin or "sonic"
	p.scrollx = 0
	p.scrolly = 0 --(maps.map.h - 20) * maps.BLOCK_SIZE -- !!!
	--setPlayerAnimation(p, "std") -- !!!
	p.rings = 0
	p.flash = 3 * TICRATE
	--p.air = 30 * TICRATE
	p.carry = nil
	p.carried = nil
	p.shoes = nil
	p.invincibility = nil
	p.shield = nil

	-- Spawn player's body
	local o = maps.spawnObject(maps.OBJ_PLAYER, x - maps.objectproperties[maps.OBJ_PLAYER].w / 2, y) -- !!!
	p.obj = o
	maps.objdir[o] = dir
	maps.objspr[o] = maps.skininfo[p.skin].anim[maps.objanim[o]].spd
	maps.objextra[o] = n

	maps.centerCamera(p)

	-- Spawn enemies
	maps.checkSpawnersInArea(
		(maps.objx[o] - maps.MAX_OBJECT_DIST) / maps.BLOCK_SIZE + 1,
		(maps.objy[o] - maps.MAX_OBJECT_DIST) / maps.BLOCK_SIZE + 1,
		(maps.objx[o] + maps.objw[o] + maps.MAX_OBJECT_DIST) / maps.BLOCK_SIZE + 1,
		(maps.objy[o] + maps.objh[o] + maps.MAX_OBJECT_DIST) / maps.BLOCK_SIZE + 1
	)

	if owner
		maps.changeMusic(maps.map.music, owner)
	end
end

-- ...
function maps.killPlayer(p, cause)
	p.dead = true
	p.rings = 0
	--setPlayerAnimation(p, "die")
	p.x, p.y = maps.objx[p.obj], maps.objy[p.obj]
	p.dx, p.dy = 0, -3 * FU
	if cause == "drown"
		maps.startSound(sfx_drown, p)
	elseif cause ~= "spikes"
		maps.startSound(P_RandomRange(sfx_altdi1, sfx_altdi4), p)
	end

	maps.removeObject(p.obj)
	p.obj = nil
end

function maps.damagePlayer(p, cause)
	local o = p.obj

	if cause == "spikes"
		maps.startSound(sfx_spkdth, p)
	end

	if p.carry
		maps.pp[maps.objextra[p.carry]].carried = nil
		p.carry = nil
	elseif p.carried
		maps.pp[maps.objextra[p.carried]].carry = nil
		p.carried = nil
	end

	if p.shield
		p.shield = $ == "strongforce" and "weakforce" or nil
		if cause ~= "spikes"
			maps.startSound(sfx_shldls, p)
		end
	else
		if p.rings == 0
			maps.killPlayer(p, cause)
			return
		end

		-- Spill rings
		local ringnum = min(p.rings, 32)
		local ringx = maps.objx[o] + maps.objw[o] / 2 - maps.objectproperties[maps.OBJ_SPILLEDRING].w / 2
		local ringy = maps.objy[o] + maps.objh[o] / 2 - maps.objectproperties[maps.OBJ_SPILLEDRING].h / 2
		if ringy + maps.objectproperties[maps.OBJ_SPILLEDRING].h > maps.objy[o] + maps.objh[o]
			ringy = maps.objy[o] + maps.objh[o] - maps.objectproperties[maps.OBJ_SPILLEDRING].h
		end
		for i = 1, ringnum
			local angle = (-FU / 2 + (i - 1) * (FU / ringnum)) * FU
			local speed = 3

			local o = maps.spawnObject(maps.OBJ_SPILLEDRING, ringx, ringy)
			maps.objdx[o] = cos(angle) * speed
			maps.objdy[o] = sin(angle) * speed
			maps.objextra[o] = 8 * TICRATE
		end

		p.rings = 0

		maps.startSound(P_RandomRange(sfx_altow1, sfx_altow4), p)
	end

	maps.unspinPlayer(p)
	p.jump = false
	p.thok = nil
	p.fly = nil
	p.glide = nil
	p.climb = nil
	p.spring = nil

	p.flash = 3 * TICRATE
	maps.objdx[o] = FU * ((maps.objdx[o] < 0 or maps.objdx[o] == 0 and maps.objdir[o] == 1) and 3 or -3) / 2
	maps.objdy[o] = -2 * FU

	maps.setPlayerAnimation(p, "pain")
end

function maps.playerBreakMonitor(p, i)
	local o = p.obj

	-- Effect
	local t = maps.tileextra[maps.map1[i]]
	if t == "Ring"
		p.rings = min($ + 10, 9999)
	elseif t == "Shoes"
		p.shoes = min((p.shoes or 0) + 20 * TICRATE, 65535)
		maps.changeMusic("_shoes", players[p.owner])
	elseif t == "Invincibility"
		p.invincibility = min((p.invincibility or 0) + 20 * TICRATE, 65535)
		maps.changeMusic("_inv", players[p.owner])
	elseif t == "Pity Shield"
		p.shield = "pity"
		maps.startSound(sfx_shield, p)
	elseif t == "Force Shield"
		p.shield = "strongforce"
		maps.startSound(sfx_shield, p)
	elseif t == "Whirlwind Shield"
		p.shield = "wind"
		maps.startSound(sfx_shield, p)
	elseif t == "Eggman"
		if not (p.flash or p.invincibility)
			maps.damagePlayer(p)
		end
	end

	-- Bounce
	if maps.objtype[o] and maps.objdy[o] > maps.GRAVITY
		maps.objdy[o] = -$
	end

	-- Break
	maps.map1[i] = maps.tiletag[$]
	if maps.objtype[o] -- !!!!
		maps.startSound(sfx_pop, p)
	end
end

function maps.centerCameraAroundPoint(p, x, y)
	p.scrollx = x - maps.SCREEN_WIDTH / 2 / maps.renderscale
	local limit = maps.map.w * maps.BLOCK_SIZE - maps.SCREEN_WIDTH / maps.renderscale
	if p.scrollx > limit
		p.scrollx = limit
	elseif p.scrollx < 0
		p.scrollx = 0
	end

	p.scrolly = y - maps.SCREEN_HEIGHT / 2 / maps.renderscale
	limit = maps.map.h * maps.BLOCK_SIZE - maps.SCREEN_HEIGHT / maps.renderscale
	if p.scrolly > limit
		p.scrolly = limit
	elseif p.scrolly < 0
		p.scrolly = 0
	end
end

function maps.centerCamera(p)
	if p.builder
		maps.centerCameraAroundPoint(p,
			(p.x - 1) * maps.BLOCK_SIZE + maps.BLOCK_SIZE / 2,
			(p.y - 1) * maps.BLOCK_SIZE + maps.BLOCK_SIZE / 2)
	elseif p.dead
		maps.centerCameraAroundPoint(p, p.x, p.y)
	else
		local o = p.obj
		maps.centerCameraAroundPoint(p,
			maps.objx[o] + maps.objw[o] / 2,
			maps.objy[o] + maps.objh[o] / 2)
	end
end

-- ....
local function handlePlayerScrolling(p)
	local o = p.carried or p.obj
	if p.camera == 1 or p.camera == 4 -- Basic or speed
		local dx, dy = maps.objdx[o], maps.objdy[o]

		o = p.obj
		local baseviewh, baseviewv = (12 + (p.camera ~= 4 and p.scrolldistance or 0)) * maps.BLOCK_SIZE / maps.renderscale, 8 * maps.BLOCK_SIZE / maps.renderscale
		local extraviewh, extraviewv = dx * 16 / maps.renderscale, dy * 16 / maps.renderscale
		local basecameraspeedh, basecameraspeedv = 2 * FU / maps.renderscale, 4 * FU / maps.renderscale

		if dx < 0
			local view = baseviewh
			if p.camera == 4
				view = $ - extraviewh
			end
			local limit = (maps.SCREEN_WIDTH - 4 * maps.BLOCK_SIZE) / maps.renderscale
			if view > limit
				view = limit
			end

			limit = maps.objx[o] - view
			if p.scrollx > limit
				local scrolldx = limit - p.scrollx
				limit = dx - basecameraspeedh
				if scrolldx < limit
					scrolldx = limit
				end

				p.scrollx = $ + scrolldx

				if p.scrollx < 0
					p.scrollx = 0
				end
			end
		elseif dx > 0
			local view = baseviewh
			if p.camera == 4
				view = $ + extraviewh
			end
			local limit = (maps.SCREEN_WIDTH - 4 * maps.BLOCK_SIZE) / maps.renderscale
			if view > limit
				view = limit
			end

			limit = maps.objx[o] + maps.objw[o] - maps.SCREEN_WIDTH / maps.renderscale + view
			if p.scrollx < limit
				local scrolldx = limit - p.scrollx
				limit = dx + basecameraspeedh
				if scrolldx > limit
					scrolldx = limit
				end

				p.scrollx = $ + scrolldx

				limit = maps.map.w * maps.BLOCK_SIZE - maps.SCREEN_WIDTH / maps.renderscale
				if p.scrollx > limit
					p.scrollx = limit
				end
			end
		end

		if dy < 0
			local view = baseviewv
			if p.camera == 4 and not p.jump
				view = $ - extraviewv
			end
			local limit = (maps.SCREEN_HEIGHT - 4 * maps.BLOCK_SIZE) / maps.renderscale
			if view > limit
				view = limit
			end

			limit = maps.objy[o] - view
			if p.scrolly > limit
				local scrolldy = limit - p.scrolly
				limit = dy - basecameraspeedv
				if scrolldy < limit
					scrolldy = limit
				end

				p.scrolly = $ + scrolldy

				if p.scrolly < 0
					p.scrolly = 0
				end
			end
		elseif dy > 0
			local view = baseviewv
			if p.camera == 4 and not p.jump
				view = $ + extraviewv
			end
			local limit = (maps.SCREEN_HEIGHT - 4 * maps.BLOCK_SIZE) / maps.renderscale
			if view > limit
				view = limit
			end

			limit = maps.objy[o] + maps.objh[o] + view - maps.SCREEN_HEIGHT / maps.renderscale
			if p.scrolly < limit
				local scrolldy = limit - p.scrolly
				limit = dy + basecameraspeedv
				if scrolldy > limit
					scrolldy = limit
				end

				p.scrolly = $ + scrolldy

				limit = maps.map.h * maps.BLOCK_SIZE - maps.SCREEN_HEIGHT / maps.renderscale
				if p.scrolly > limit
					p.scrolly = limit
				end
			end
		end
	elseif p.camera == 2 -- Center
		maps.centerCameraAroundPoint(p,
			maps.objx[o] + maps.objw[o] / 2,
			maps.objy[o] + maps.objh[o] - maps.PLAYER_HEIGHT / 2)
	elseif p.camera == 3 -- Direction
		local view = 12 * maps.BLOCK_SIZE / maps.renderscale
		local cameraspeed = 4096
		--local cameraspeed = maps.BLOCK_SIZE / 4 + abs(maps.objdx[o]) * 5 / 4
		local minspeed = 2 * FU

		local srcx = p.scrollx + maps.SCREEN_WIDTH / maps.renderscale / 2

		local dstx
		if maps.objdx[o] < -minspeed -- Left
			dstx = maps.objx[o] + maps.objw[o] / 2 - view
		elseif maps.objdx[o] > minspeed or maps.objdir[o] == 2 -- Right
			dstx = maps.objx[o] + maps.objw[o] / 2 + view
		else -- Left
			dstx = maps.objx[o] + maps.objw[o] / 2 - view
		end

		local x = FixedMul(srcx + maps.objdx[o], FU - cameraspeed) + FixedMul(dstx, cameraspeed)
		--if srcx < dstx
		--	x = $ + cameraspeed
		--	if x > dstx
		--		x = dstx
		--	end
		--elseif srcx > dstx
		--	x = $ - cameraspeed
		--	if x < dstx
		--		x = dstx
		--	end
		--end

		maps.centerCameraAroundPoint(p,
			x,
			maps.objy[o] + maps.objh[o] - maps.PLAYER_HEIGHT / 2)
	end
end

-- !!! rm
--local function handlePlayerScrolling(p)
--	local o = p.carried or p.obj
--	local dx, dy = maps.objdx[o], maps.objdy[o]
--
--	o = p.obj
--	local baseviewh, baseviewv = (12 + (not p.dynamiccamera and p.scrolldistance or 0)) * maps.BLOCK_SIZE, 8 * maps.BLOCK_SIZE
--	local extraviewh, extraviewv = dx * 16, dy * 16
--	local basecameraspeedh, basecameraspeedv = 2 * FU, 4 * FU
--
--	if dx < 0
--		local view = baseviewh
--		if p.dynamiccamera
--			view = $ - extraviewh
--		end
--		local limit = maps.SCREEN_WIDTH - 4 * maps.BLOCK_SIZE
--		if view > limit
--			view = limit
--		end
--
--		limit = maps.objx[o] - view
--		if p.scrollx > limit
--			local scrolldx = limit - p.scrollx
--			limit = dx - basecameraspeedh
--			if scrolldx < limit
--				scrolldx = limit
--			end
--
--			p.scrollx = $ + scrolldx
--
--			if p.scrollx < 0
--				p.scrollx = 0
--			end
--		end
--	elseif dx > 0
--		local view = baseviewh
--		if p.dynamiccamera
--			view = $ + extraviewh
--		end
--		local limit = maps.SCREEN_WIDTH - 4 * maps.BLOCK_SIZE
--		if view > limit
--			view = limit
--		end
--
--		limit = maps.objx[o] + maps.objw[o] + view - maps.SCREEN_WIDTH
--		if p.scrollx < limit
--			local scrolldx = limit - p.scrollx
--			limit = dx + basecameraspeedh
--			if scrolldx > limit
--				scrolldx = limit
--			end
--
--			p.scrollx = $ + scrolldx
--
--			limit = maps.map.w * maps.BLOCK_SIZE - maps.SCREEN_WIDTH
--			if p.scrollx > limit
--				p.scrollx = limit
--			end
--		end
--	end
--
--	if dy < 0
--		local view = baseviewv
--		if p.dynamiccamera and not p.jump
--			view = $ - extraviewv
--		end
--		local limit = maps.SCREEN_HEIGHT - 4 * maps.BLOCK_SIZE
--		if view > limit
--			view = limit
--		end
--
--		limit = maps.objy[o] - view
--		if p.scrolly > limit
--			local scrolldy = limit - p.scrolly
--			limit = dy - basecameraspeedv
--			if scrolldy < limit
--				scrolldy = limit
--			end
--
--			p.scrolly = $ + scrolldy
--
--			if p.scrolly < 0
--				p.scrolly = 0
--			end
--		end
--	elseif dy > 0
--		local view = baseviewv
--		if p.dynamiccamera and not p.jump
--			view = $ + extraviewv
--		end
--		local limit = maps.SCREEN_HEIGHT - 4 * maps.BLOCK_SIZE
--		if view > limit
--			view = limit
--		end
--
--		limit = maps.objy[o] + maps.objh[o] + view - maps.SCREEN_HEIGHT
--		if p.scrolly < limit
--			local scrolldy = limit - p.scrolly
--			limit = dy + basecameraspeedv
--			if scrolldy > limit
--				scrolldy = limit
--			end
--
--			p.scrolly = $ + scrolldy
--
--			limit = maps.map.h * maps.BLOCK_SIZE - maps.SCREEN_HEIGHT
--			if p.scrolly > limit
--				p.scrolly = limit
--			end
--		end
--	end
--end

local function flyPlayer(p)
	if p.spin and not maps.unspinPlayer(p)
		return
	end

	p.fly = maps.skininfo[p.skin].fly
	p.jump = false

	maps.setPlayerAnimation(p, "fly")
end

local function releasePlayerClimb(p)
	local o = p.obj

	p.climb = nil
	p.jump = true

	maps.setObjectHeight(o, maps.PLAYER_HEIGHT)

	maps.setPlayerAnimation(p, "spin")
end

local function glidePlayer(p)
	local o = p.obj

	if p.spin and not maps.unspinPlayer(p)
		return
	end

	p.glide = true
	p.jump = false

	maps.objdx[o] = maps.objdir[o] == 1 and -2 * FU or 2 * FU

	maps.setPlayerAnimation(p, "glide")
end

local function releasePlayerGlide(p)
	--local o = p.obj
	--
	--maps.setObjectHeight(o, maps.PLAYER_HEIGHT)
	--
	--if maps.playerColliding(p)
	--	maps.setObjectHeight(o, maps.PLAYER_SPIN_HEIGHT)
	--	return
	--end

	p.glide = nil
	p.spin = true

	maps.setPlayerAnimation(p, "spin")
end

function maps.handlePlayer(p, n)
	local owner = p.owner ~= nil and players[p.owner] or nil
	local t
	local o = p.obj

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

	if p.dead
		-- !!! We need to wait for a short time before respawning... don't we?
		if bt & BT_JUMP and not (t.prevbuttons & BT_JUMP)
			maps.spawnPlayer(n)
		else
			if p.dy <= 0 or p.y < (maps.map.h + 1) * maps.BLOCK_SIZE
				p.y = $ + p.dy
				p.dy = min($ + FU / 8, 6 * FU)
				--loopPlayerAnimation(p)
			end
		end
	else
		local skin = maps.skininfo[p.skin]

		if p.climb
			if up
				maps.objdy[o] = -FU
				if maps.objanim[o] ~= "climb"
					maps.setPlayerAnimation(p, "climb")
				end
			elseif down
				maps.objdy[o] = FU
				if maps.objanim[o] ~= "climb"
					maps.setPlayerAnimation(p, "climb")
				end
			else
				maps.objdy[o] = 0
				if maps.objanim[o] ~= "climbstd"
					maps.setPlayerAnimation(p, "climbstd")
				end
			end

			if bt & BT_JUMP and not (t.prevbuttons & BT_JUMP)
				releasePlayerClimb(p)

				maps.objdir[o] = maps.objdir[o] == 1 and 2 or 1
				maps.objdx[o] = maps.objdir[o] == 1 and -maps.PLAYER_JUMP or maps.PLAYER_JUMP

				maps.startSound(sfx_jump, p)
			end

			if bt & BT_USE and not (t.prevbuttons & BT_USE) or right and maps.objdir[o] == 1 or left and maps.objdir[o] == 2
				releasePlayerClimb(p)
				maps.objdx[o] = maps.objdir[o] == 1 and FU or -FU
			end

			if playerCantClimb(p)
				releasePlayerClimb(p)
				if maps.objdy[o] < 0
					maps.objdy[o] = -maps.PLAYER_JUMP / 2
				end
			end
		else
			if left and p.spindash == false and p.flash ~= 3 * TICRATE
				if p.glide
					maps.objdx[o] = -2 * FU
					maps.objdir[o] = 1
				elseif not p.spin or maps.objdx[o] > 0
					local spd
					local acc
					if not p.shoes
						spd = skin.spd
						acc = skin.acc
					else
						spd = min(skin.spd + 3 * FU, 8 * FU)
						acc = skin.acc * 3 / 2
					end

					if maps.objdx[o] > -spd
						if p.spin or not maps.playerOnGround(p)
							acc = $ / 2
						end
						maps.objdx[o] = max($ - acc, -spd)
					end

					maps.objdir[o] = 1
					if maps.objdx[o] > -skin.run
						if maps.objanim[o] == "std" or maps.objanim[o] == "run"
							maps.setPlayerAnimation(p, "walk")
						end
					elseif maps.objanim[o] == "std" or maps.objanim[o] == "walk"
						maps.setPlayerAnimation(p, "run")
					end
				end
			end

			if right and p.spindash == false and p.flash ~= 3 * TICRATE
				if p.glide
					maps.objdx[o] = 2 * FU
					maps.objdir[o] = 2
				elseif not p.spin or maps.objdx[o] < 0
					local spd
					local acc
					if not p.shoes
						spd = skin.spd
						acc = skin.acc
					else
						spd = min(skin.spd + 3 * FU, 8 * FU)
						acc = skin.acc * 3 / 2
					end

					if maps.objdx[o] < spd
						if p.spin or not maps.playerOnGround(p)
							acc = $ / 2
						end
						maps.objdx[o] = min($ + acc, spd)
					end

					maps.objdir[o] = 2
					if maps.objdx[o] < skin.run
						if maps.objanim[o] == "std" or maps.objanim[o] == "run"
							maps.setPlayerAnimation(p, "walk")
						end
					elseif maps.objanim[o] == "std" or maps.objanim[o] == "walk"
						maps.setPlayerAnimation(p, "run")
					end
				end
			end

			if up or bt & BT_JUMP
				if up and not t.prevup or bt & BT_JUMP and not (t.prevbuttons & BT_JUMP)
					if p.jump or p.spin and not maps.playerOnGround(p)
						if p.jump and not p.thok and skin.thok
							thokPlayer(p)
						elseif skin.fly
							flyPlayer(p)
						elseif skin.glideandclimb
							glidePlayer(p)
						end
					elseif p.fly ~= nil and p.fly ~= 0
						if maps.objdy[o] > -FU * 3 / 2
							maps.objdy[o] = max($ - FU, -FU * 3 / 2)
						end
					elseif maps.objdy[o] >= 0 and maps.playerOnGround(p)
					or p.carried
						jumpPlayer(p)
					elseif p.shield == "wind" and not (p.jump or p.thok or p.glide or maps.playerOnGround(p))
						maps.objdy[o] = -maps.PLAYER_JUMP
						p.jump = false
						p.thok = true
						p.spin = false
						p.fly = nil
						maps.setPlayerAnimation(p, "fall")
						maps.startSound(sfx_wdjump, p)
					end
				end
			elseif p.glide
				releasePlayerGlide(p)
			end

			if down or bt & BT_USE -- Pressing spin
				if t.prevdown or t.prevbuttons & BT_USE -- Holding spin
					if p.spindash ~= false
						if leveltime % 5 == 0
							if p.spindash < skin.maxdash
								maps.startSound(sfx_spndsh, p)
							end

							local thok = maps.spawnObject(maps.OBJ_THOK, maps.objx[o], maps.objy[o])
							maps.objcolor[thok] = owner and owner.skincolor or SKINCOLOR_BLUE
							maps.objextra[thok] = 8 -- Vanish after 8 tics
						end
						p.spindash = min($ + FU / 8, skin.maxdash) -- !!!
					end
				else -- Spin just pressed
					--if not p.spin and maps.objdy[o] >= 0 and abs(maps.objdx[o]) > FU / 2 and maps.playerOnGround(p)
					--	maps.spinPlayer(p)
					--elseif p.fly ~= nil and p.fly ~= 0
					--	if maps.objdy[o] < 4 * FU
					--		maps.objdy[o] = min($ + FU, 4 * FU)
					--	end
					--end
					if p.fly ~= nil and p.fly ~= 0 -- Flying
						if maps.objdy[o] < 4 * FU
							maps.objdy[o] = min($ + FU, 4 * FU)
						end
					elseif not p.spin and maps.objdy[o] >= 0 and maps.playerOnGround(p)
						if abs(maps.objdx[o]) > FU / 2
							maps.spinPlayer(p)
						else
							p.spindash = skin.mindash
							maps.setObjectHeight(o, maps.PLAYER_SPIN_HEIGHT)
							maps.setPlayerAnimation(p, "spin")
						end
					elseif p.shield == "wind" and not (p.thok or p.glide or maps.playerOnGround(p))
						maps.objdy[o] = -maps.PLAYER_JUMP
						p.jump = false
						p.thok = true
						p.spin = false
						maps.setPlayerAnimation(p, "fall")
						maps.startSound(sfx_wdjump, p)
					end
				end
			elseif p.spindash ~= false -- Spindash released
				maps.objdx[o] = maps.objdir[o] == 1 and -p.spindash or p.spindash
				p.spindash = false
				p.spin = true
				maps.startSound(sfx_zoom, p)
			end

			-- Brake when not accelerating
			if not (left or right or p.spin) and maps.playerOnGround(p)
				if maps.objdx[o] < 0
					maps.objdx[o] = min($ + FU / 8, 0)
				elseif maps.objdx[o] > 0
					maps.objdx[o] = max($ - FU / 8, 0)
				end
			end
		end

		if maps.objanim[o] == "walk" and maps.objdx[o] == 0
			maps.setPlayerAnimation(p, "std")
		elseif maps.objanim[o] == "run" and abs(maps.objdx[o]) < skin.run
			maps.setPlayerAnimation(p, "walk")
		end

		if p.spin and P_AproxDistance(maps.objdx[o], maps.objdy[o]) > 2 * FU and leveltime & 1
			local thok = maps.spawnObject(maps.OBJ_THOK, maps.objx[o], maps.objy[o])
			maps.objcolor[thok] = owner and owner.skincolor or SKINCOLOR_BLUE
			maps.objextra[thok] = 8 -- Vanish after 8 tics
		end

		-- !!!
		-- Placeholder for springs, hazards, collectibles and other various stuff
		-- This needs serious handling
		-- !!!!
		for x = maps.objx[o] / maps.BLOCK_SIZE + 1, (maps.objx[o] + maps.PLAYER_WIDTH - 1) / maps.BLOCK_SIZE + 1
			for y = maps.objy[o] / maps.BLOCK_SIZE + 1, min((maps.objy[o] + maps.objh[o] - 1) / maps.BLOCK_SIZE + 1, maps.map.h)
				local i = x + (y - 1) * maps.map.w
				local tile = maps.tiletype[maps.map1[i]]
				if tile < 4
					continue
				elseif tile == 4 -- Weak spring
					maps.springPlayer(p, nil, 6 * FU)
				elseif tile == 5 -- Strong spring
					maps.springPlayer(p, nil, 8 * FU)
				elseif tile == 9 -- Damages
					if not (p.flash or p.invincibility)
						maps.damagePlayer(p)
						if not p.obj break 2 end -- !!!!
					end
				elseif tile == 10 -- Instant death
					maps.killPlayer(p)
					break 2 -- !!!!
				elseif tile == 11 -- Ring
					-- ...
					-- !!!
					p.rings = min($ + 1, 9999)
					maps.map1[i] = maps.tiletag[$]
					maps.startSound(sfx_itemup, p)
				elseif tile == 15 -- Left spring
					maps.objdx[o] = -8 * FU
					if maps.objanim[o] == "std"
						maps.setPlayerAnimation(p, -maps.objdx[o] < skin.run and "walk" or "run")
					end
					maps.startSound(sfx_spring, p)
				elseif tile == 16 -- Right spring
					maps.objdx[o] = 8 * FU
					if maps.objanim[o] == "std"
						maps.setPlayerAnimation(p, maps.objdx[o] < skin.run and "walk" or "run")
					end
					maps.startSound(sfx_spring, p)
				elseif tile == 17 -- Steam
					if leveltime & 31 == 0
						maps.springPlayer(p, nil, 6 * FU, P_RandomRange(sfx_steam1, sfx_steam2))
					end
				elseif tile == 18 -- Star post
					if p.starpostx ~= x or p.starposty ~= y
						p.starpostx, p.starposty, p.starpostdir = x, y, maps.objdir[o]
						maps.startSound(sfx_strpst, p)
					end

					-- !!!
					-- Make the starpost blink (beta)
					-- Wait no it blinks already, why did I write this? Then maybe it should rotate??
					local t = maps.map1[i]
					if maps.tiletag[t] > t
						maps.map1[i] = maps.tiletag[t]
					end
				elseif tile == 19 -- Weak left diagonal spring
					maps.springPlayer(p, -6 * FU, 6 * FU)
				elseif tile == 20 -- Weak right diagonal spring
					maps.springPlayer(p, 6 * FU, 6 * FU)
				elseif tile == 21 -- Strong left diagonal spring
					maps.springPlayer(p, -8 * FU, 8 * FU)
				elseif tile == 22 -- Strong right diagonal spring
					maps.springPlayer(p, 8 * FU, 8 * FU)
				end
			end
		end

		if p.flash and p.flash ~= 3 * TICRATE
			p.flash = $ - 1
		end

		if p.shoes
			p.shoes = $ - 1
			if p.shoes == 0
				p.shoes = nil
				if owner
					if p.invincibility
						S_ChangeMusic("_inv", nil, owner)
					else
						maps.changeMusic(maps.map.music, owner)
					end
				end
			end
		end

		if p.invincibility
			p.invincibility = $ - 1
			if p.invincibility == 0
				p.invincibility = nil
				if owner
					if p.shoes
						S_ChangeMusic("_shoes", nil, owner)
					else
						maps.changeMusic(maps.map.music, owner)
					end
				end
			end
		end

		if p.obj
			if maps.objanim[o] == "std" and owner and owner.mo and owner.mo.valid and owner.mo.skin ~= p.skin
				setPlayerSkin(p, owner.mo.skin)
			end

			handlePlayerScrolling(p)
		end
	end

	if bt & BT_TOSSFLAG and not (t.prevbuttons & BT_TOSSFLAG)
		local admin = (owner == server or IsPlayerAdmin(owner))
		menulib.open(owner, admin and "mainhost" or "mainplayer", "maps")
	end

	if t and not owner.menu
		t.prevup, t.prevdown = up, down
		t.prevbuttons = owner.cmd.buttons
	end
end

-- !!!
-- Needs better handling of jump/spin cases
function maps.springPlayer(p, dx, dy, sfx)
	local o = p.obj

	if p.carry
		maps.pp[maps.objextra[p.carry]].carried = nil
		p.carry = nil
	elseif p.carried
		maps.pp[maps.objextra[p.carried]].carry = nil
		p.carried = nil
	end

	if p.spin
		if not maps.unspinPlayer(p)
			return
		end
	elseif p.spindash ~= false and not maps.unspinPlayer(p)
		return
	end

	if p.jump or p.fly ~= nil or p.glide or p.climb
		p.jump = false
		p.fly = nil
		p.glide = nil
		p.climb = nil

		maps.setObjectHeight(o, maps.PLAYER_HEIGHT)

		if maps.playerColliding(p)
			maps.setObjectHeight(o, maps.PLAYER_SPIN_HEIGHT)
		end
	elseif p.spin
		maps.unspinPlayer(p)
	end

	p.thok = nil

	if p.flash == 3 * TICRATE
		p.flash = $ - 1
	end

	p.spring = true
	if dx ~= nil
		maps.objdx[o] = dx
		maps.objdir[o] = dx < 0 and 1 or dx > 0 and 2 or $
	end
	maps.objdy[o] = -dy
	maps.setPlayerAnimation(p, "spring")
	maps.startSound(sfx or sfx_spring, p)
end

maps.addCommand("suicide", function(p)
	if gamemap == 557
		local owner = p
		p = owner and owner.maps and maps.pp[owner.maps.player]
		if not p or p.dead
			return
		elseif p.builder
			CONS_Printf(owner, "You can't suicide while building!")
			return
		end
		maps.killPlayer(p)
		return
	elseif not G_PlatformGametype()
		CONS_Printf(p, "You may only use this in co-op, race, and competition!")
		return
	elseif not netgame and not multiplayer
		CONS_Printf(p, "You can't use this in Single Player! Use \"retry\" instead.")
		return
	elseif not (p and p.mo and p.mo.valid)
		return
	end

	P_DamageMobj(p.mo, nil, nil, 10000)
end)

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
