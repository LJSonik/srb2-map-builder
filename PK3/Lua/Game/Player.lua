local menulib = ljrequire "menulib"


local FU = FRACUNIT
local TILESIZE = maps.TILESIZE


---@class maps.Player
---@field buildermode maps.EditorMode


maps.PLAYER_WIDTH       = TILESIZE *  6 / 8
maps.PLAYER_HEIGHT      = TILESIZE * 10 / 8
maps.PLAYER_ROLL_HEIGHT = TILESIZE *  6 / 8
maps.PLAYER_JUMP        = TILESIZE *  4 / 8
maps.PLAYER_DEC         = TILESIZE / (3 * TICRATE)


maps.skindefs = {}


function maps.setPlayerAnimation(p, anim)
	local o = p.obj
	o.anim = anim
	o.spr = maps.skindefs[p.skin].anim[anim].spd
end

local function loopPlayerAnimation(p)
	local a = maps.skindefs[p.skin].anim[p.anim]

	p.spr = $ + 1
	if p.spr >= a.spd * (a.frames + 1) then
		p.spr = a.spd
	end
end

local function setPlayerSkin(p, skin)
	p.skin = skin
	if p.obj then
		maps.setPlayerAnimation(p, p.obj.anim)
	end
end

local function areaAboveHeadContainsSolid(o, h)
	if o.floormode == 0 then
		return maps.areaContainsSolid(o.l, o.t - h, o.r, o.t, maps.map[o.layer])
	elseif o.floormode == 1 then
		return maps.areaContainsSolid(o.r, o.t, o.r + h, o.b, maps.map[o.layer])
	elseif o.floormode == 2 then
		return maps.areaContainsSolid(o.l, o.b, o.r, o.b + h, maps.map[o.layer])
	elseif o.floormode == 3 then
		return maps.areaContainsSolid(o.l - h, o.t, o.l, o.b, maps.map[o.layer])
	end
end

function maps.switchToGroundAnimation(p)
	local anim
	if p.obj.groundspeed == 0 then
		anim = "stand"
	elseif abs(p.obj.groundspeed) < maps.skindefs[p.skin].runspeed then
		anim = "walk"
	else
		anim = "run"
	end

	if p.obj.anim ~= anim then
		maps.setPlayerAnimation(p, anim)
	end
end

function maps.enterRollState(p)
	local o = p.obj

	local wasinblockmap = o.inblockmap
	if wasinblockmap then
		maps.removeObjectFromBlockmap(o)
	end

	if o.floormode % 2 == 0 then
		o.h = maps.PLAYER_ROLL_HEIGHT
	else
		o.w = maps.PLAYER_ROLL_HEIGHT
	end

	if o.floormode == 0 then
		maps.setObjectBottom(o, o.b)
	elseif o.floormode == 1 then
		maps.setObjectLeft(o, o.l)
	elseif o.floormode == 2 then
		maps.setObjectTop(o, o.t)
	elseif o.floormode == 3 then
		maps.setObjectRight(o, o.r)
	end

	if wasinblockmap then
		maps.insertObjectInBlockmap(o)
	end
end

function maps.leaveRollState(p)
	local o = p.obj

	if not areaAboveHeadContainsSolid(o, maps.PLAYER_HEIGHT - maps.PLAYER_ROLL_HEIGHT) then
		local wasinblockmap = o.inblockmap
		if wasinblockmap then
			maps.removeObjectFromBlockmap(o)
		end

		if o.floormode % 2 == 0 then
			o.h = maps.PLAYER_HEIGHT
		else
			o.w = maps.PLAYER_HEIGHT
		end

		if o.floormode == 0 then
			maps.setObjectBottom(o, o.b)
		elseif o.floormode == 1 then
			maps.setObjectLeft(o, o.l)
		elseif o.floormode == 2 then
			maps.setObjectTop(o, o.t)
		elseif o.floormode == 3 then
			maps.setObjectRight(o, o.r)
		end

		if wasinblockmap then
			maps.insertObjectInBlockmap(o)
		end

		return true
	else
		local minspeed = TILESIZE / 8
		if o.grounded and abs(o.groundspeed) < minspeed then
			if o.groundspeed < 0 then
				o.groundspeed = $ - minspeed
			elseif o.groundspeed > 0 then
				o.groundspeed = $ + minspeed
			elseif o.dir == 1 then
				o.groundspeed = $ - minspeed
			else
				o.groundspeed = $ + minspeed
			end
		end

		return false
	end
end

local function doPlayerJump(p)
	local o = p.obj

	o.grounded = false
	o.groundspeed = nil

	o.speedx = $ + FixedMul(maps.PLAYER_JUMP, sin(o.angle))
	o.speedy = $ - FixedMul(maps.PLAYER_JUMP, cos(o.angle))

	if o.state == "climb" then
		o.dir = o.speedx < 0 and 1 or 2
	end

	maps.enterRollState(p)
	maps.setObjectState(o, "jump")

	maps.setPlayerAnimation(p, "roll")
	maps.startSound(sfx_jump, p)
end

local function doPlayerSpin(p)
	maps.enterRollState(p)
	maps.setObjectState(p.obj, "roll")

	maps.setPlayerAnimation(p, "roll")
	maps.startSound(sfx_spin, p)
end

local function startSpindash(p)
	maps.enterRollState(p)
	maps.setObjectState(p.obj, "spindash")
	p.obj.spindashcharge = maps.skindefs[p.skin].minspindashspeed

	maps.setPlayerAnimation(p, "spindash")
end

local function releaseSpindash(p)
	local o = p.obj

	maps.setObjectState(o, "roll")

	if o.grounded then
		maps.setObjectGroundSpeed(o, o.spindashcharge * (o.dir == 1 and -1 or 1))
	end

	maps.setPlayerAnimation(p, "roll")
	maps.startSound(sfx_zoom, p)
end

local function startGliding(p)
	local o = p.obj

	maps.setObjectState(o, "glide")
	maps.setObjectAngle(o, 0)

	if o.dir == 1 then
		o.speedx = min($, -TILESIZE / 4)
	else
		o.speedx = max($, TILESIZE / 4)
	end

	maps.setPlayerAnimation(p, "glide")
end

function maps.killPlayer(p, cause)
	p.dead = true
	p.x, p.y = maps.objx[p.obj], maps.objy[p.obj]
	p.dx, p.dy = 0, -3 * FU
	maps.startSound(P_RandomRange(sfx_altdi1, sfx_altdi4), p)

	maps.removeObject(p.obj)
	p.obj = nil
end

function maps.damagePlayer(p, cause)
	local o = p.obj

	if o.flashing then return end

	-- Spill rings
	/*local ringnum = min(p.rings, 32)
	local ringx = o.r / 2 - maps.objectproperties[maps.OBJ_SPILLEDRING].w / 2
	local ringy = o.b / 2 - maps.objectproperties[maps.OBJ_SPILLEDRING].h / 2
	if ringy + maps.objectproperties[maps.OBJ_SPILLEDRING].h > o.b then
		ringy = o.b - maps.objectproperties[maps.OBJ_SPILLEDRING].h
	end
	for i = 1, ringnum do
		local angle = (-FU / 2 + (i - 1) * (FU / ringnum)) * FU
		local speed = 3

		local o = maps.spawnObject(maps.OBJ_SPILLEDRING, ringx, ringy)
		o.speedx = cos(angle) * speed
		o.speedy = sin(angle) * speed
		o.extra = 8 * TICRATE
	end*/

	--p.rings = 0

	--maps.unspinPlayer(p)

	o.flashing = INT32_MAX
	maps.setObjectState(o, "pain")

	o.grounded = false
	o.groundspeed = nil
	if o.speedx < 0 or o.speedx == 0 and o.dir == 1 then
		o.speedx = TILESIZE * 3 / 16
	else
		o.speedx = TILESIZE * -3 / 16
	end
	o.speedy = -TILESIZE / 4

	maps.setPlayerAnimation(p, "pain")
	maps.startSound(P_RandomRange(sfx_altow1, sfx_altow4), p)
end

function maps.spawnPlayer(p)
	local owner = p.owner ~= nil and players[p.owner] or nil

	if p.builder then
		maps.leaveEditor(p)
	elseif p.obj then
		-- Remove the old body
		maps.removeObject(p.obj)
	end

	p.dead = nil
	p.x, p.y = nil, nil
	--p.dx, p.dy = nil, nil

	-- Find spawn location and direction
	local x, y
	local h = maps.PLAYER_HEIGHT
	local dir
	if p.starpostx ~= nil then
		x = p.starpostx * TILESIZE + TILESIZE / 2
		y = (p.starposty + 1) * TILESIZE
		dir = p.starpostdir
	elseif p.spawnx == nil then
		x = maps.map.spawnx
		y = maps.map.spawny + 1
		dir = maps.map.spawndir
	else
		x = p.spawnx
		y = p.spawny + 1
		dir = p.spawndir
	end

	p.skin = owner and owner.mo and owner.mo.valid and owner.mo.skin or "sonic"
	p.scrollx = 0
	p.scrolly = 0 --(maps.map.h - 20) * TILESIZE -- !!!

	-- Spawn player's body
	--local o = maps.spawnObject(maps.OBJ_PLAYER, x, y) -- !!!
	local o = maps.spawnObject(1, x, y) -- !!!
	p.obj = o
	o.dir = dir
	-- !!! dbg
	assert(o.anim ~= nil, "o.anim is nil")
	assert(p.skin ~= nil, "p.skin is nil")
	assert(maps.skindefs[p.skin] ~= nil, "maps.skindefs[p.skin] is nil")
	assert(maps.skindefs[p.skin].anim ~= nil, "maps.skindefs[p.skin].anim is nil")
	o.spr = maps.skindefs[p.skin].anim[o.anim].spd
	o.player = p
	maps.setObjectState(o, "stand")
	o.rings = 0

	maps.centerCamera(p)

	-- Spawn enemies around player
	maps.checkSpawnersInArea(
		(o.l - maps.MAX_OBJECT_DIST) / TILESIZE,
		(o.t - maps.MAX_OBJECT_DIST) / TILESIZE,
		(o.r + maps.MAX_OBJECT_DIST) / TILESIZE,
		(o.b + maps.MAX_OBJECT_DIST) / TILESIZE
	)

	if owner then
		maps.changeMusic(maps.map.music, owner)
	end
end

function maps.leavePlayMode(p)
	local owner = p.owner ~= nil and players[p.owner] or nil

	p.starpostx, p.starposty = nil, nil
	p.starpostdir = nil

	p.dead = nil
	--p.dx, p.dy = nil, nil

	-- Remove the old body
	if p.obj then
		maps.removeObject(p.obj)
		p.obj = nil
	end

	if owner then
		S_StopMusic(owner)
	end
end

local function handleClimbControls(p, t, bt, left, right, up, down)
	local o = p.obj

	local climbspeed = TILESIZE / 8
	if o.angle > 0 then
		climbspeed = -$
	end

	local anim
	if up then
		maps.setObjectGroundSpeed(o, climbspeed)
		anim = "climb"
	elseif down then
		maps.setObjectGroundSpeed(o, -climbspeed)
		anim = "climb"
	else
		maps.setObjectGroundSpeed(o, 0)
		anim = "climbstatic"
	end

	if o.anim ~= anim then
		maps.setPlayerAnimation(p, anim)
	end

	if bt & BT_JUMP and not (t.prevbuttons & BT_JUMP) then
		doPlayerJump(p)
	end
end

local function handleControls(p, t, bt, left, right, up, down)
	local skindef = maps.skindefs[p.skin]
	local o = p.obj

	if o.state == "climb" then
		handleClimbControls(p, t, bt, left, right, up, down)
		return
	end

	if o.state == "spindash" then
		if o.grounded then
			local speed = o.groundspeed
			if speed < 0 then
				speed = min(speed + maps.PLAYER_DEC, 0)
			else
				speed = max(speed - maps.PLAYER_DEC, 0)
			end
			maps.setObjectGroundSpeed(o, speed)
		end
	else
		local speed
		if o.state == "roll" and o.grounded then
			local acc = skindef.acc * 2
			speed = o.groundspeed

			if left and speed > 0 then
				speed = $ - acc
				o.dir = 1
			elseif right and speed < 0 then
				speed = $ + acc
				o.dir = 2
			else
				if speed < 0 then
					speed = min($ + maps.PLAYER_DEC / 4, 0)
				else
					speed = max($ - maps.PLAYER_DEC / 4, 0)
				end
			end
		elseif o.state == "glide" then
			local acc = skindef.acc
			speed = o.speedx

			if left then
				if -speed < skindef.speed and o.floormode ~= 2 then
					speed = max($ - acc, -skindef.speed)
				end
			elseif right then
				if speed < skindef.speed and o.floormode ~= 2 then
					speed = min($ + acc, skindef.speed)
				end
			end

			o.dir = speed < 0 and 1 or 2
		else
			local acc
			if o.grounded then
				speed = o.groundspeed
				acc = skindef.acc
			else
				speed = o.speedx
				acc = skindef.acc / 2
			end

			if left then
				if speed > 0 and abs(o.angle) < ANGLE_22h then
					acc = $ * 4
				end
				if -speed < skindef.speed and o.floormode ~= 2 then
					speed = max($ - acc, -skindef.speed)
				end

				o.dir = 1
			elseif right then
				if speed < 0 and abs(o.angle) < ANGLE_22h then
					acc = $ * 4
				end
				if speed < skindef.speed and o.floormode ~= 2 then
					speed = min($ + acc, skindef.speed)
				end

				o.dir = 2
			elseif o.grounded then
				if speed < 0 then
					speed = min($ + maps.PLAYER_DEC, 0)
				else
					speed = max($ - maps.PLAYER_DEC, 0)
				end
			end
		end

		if o.grounded then
			maps.setObjectGroundSpeed(o, speed)
		else
			o.speedx = speed
		end
	end

	if bt & BT_JUMP then
		if not (t.prevbuttons & BT_JUMP) then
			if o.grounded then
				doPlayerJump(p)
			elseif o.state == "jump" or o.state == "roll" then
				local skindef = maps.skindefs[o.player.skin]
				if skindef.glideandclimb then
					startGliding(p)
				end
			end
		end
	else
		if o.state == "jump" then
			o.speedy = max($, -maps.PLAYER_JUMP / 2)
		elseif o.state == "glide" then
			maps.setObjectState(o, "jump")
			maps.setPlayerAnimation(p, "roll")
		end
	end

	if bt & BT_SPIN then
		if t.prevbuttons & BT_SPIN then
			if o.state == "spindash" then
				if leveltime % 5 == 0 then
					if o.spindashcharge < maps.skindefs[p.skin].maxspindashspeed then
						maps.startSound(sfx_spndsh, p)
					end
				end

				o.spindashcharge = min($ + TILESIZE / 128, maps.skindefs[p.skin].maxspindashspeed)
			end
		else
			if o.state == "stand" and o.grounded then
				if abs(o.groundspeed) >= TILESIZE / 16 then
					doPlayerSpin(p)
				else
					startSpindash(p)
				end
			end
		end
	else
		if o.state == "spindash" then
			releaseSpindash(p)
		end
	end
end

local function handleDeadPlayer(p, bt)
	-- !!! We need to wait for a short time before respawning... don't we?
	if bt & BT_JUMP and not (t.prevbuttons & BT_JUMP) then
		maps.spawnPlayer(p)
	else
		if p.dy <= 0 or p.y < (maps.map.h + 1) * TILESIZE then
			p.y = $ + p.dy
			p.dy = min($ + FU / 8, 6 * FU)
			--loopPlayerAnimation(p)
		end
	end
end

function maps.handlePlayer(p, n)
	local owner = p.owner ~= nil and players[p.owner] or nil
	local t
	local o = p.obj

	local left, right, up, down
	local bt
	if owner and not owner.menu then
		t = owner.maps
		bt = owner.cmd.buttons
		left, right, up, down = maps.getKeys(owner)
	else
		bt = 0
		left, right, up, down = false, false, false, false
	end

	if p.dead then
		handleDeadPlayer(p, bt)
	else
		if o then
			if o.anim == "stand"
			and owner and owner.mo and owner.mo.valid
			and owner.mo.skin ~= p.skin
			and maps.skindefs[owner.mo.skin] then
				setPlayerSkin(p, owner.mo.skin)
			end

			handleControls(p, t, bt, left, right, up, down)
			maps.handlePlayerCamera(p)
		end
	end

	if bt & BT_TOSSFLAG and not (t.prevbuttons & BT_TOSSFLAG) then
		local admin = (owner == server or IsPlayerAdmin(owner))
		menulib.open(owner, admin and "mainhost" or "mainplayer", "maps")
	end

	if t and not owner.menu then
		t.prevup, t.prevdown = up, down
		t.prevbuttons = owner.cmd.buttons
	end
end

-- Apparently unused
--function maps.playersInArea(x1, y1, x2, y2)
--	for i = 1, #maps.pp
--		local p = maps.pp[i]
--		if not (p.builder or p.dead)
--			local o = p.obj
--			if o.speedx + o.w > x1
--			and o.speedx <= x2
--			and o.speedy + o.h > y1
--			and o.speedy <= y2
--				return true
--			end
--		end
--	end
--end
--
--function maps.playersAtPosition(x, y)
--	return maps.playersInArea(
--		x * TILESIZE,
--		y * TILESIZE,
--		(x + 1) * TILESIZE - 1,
--		(y + 1) * TILESIZE - 1
--	)
--end
