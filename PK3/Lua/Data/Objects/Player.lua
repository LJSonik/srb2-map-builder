local TILESIZE = maps.TILESIZE

local map, map2, map3
maps.addLocalsRefresher(function()
	map = maps.map
	map2, map3 = map[2], map[3]
end)


local GLIDE_FALL_SPEED = TILESIZE / 32


local function handleGlideGravity(o)
	if o.speedy < GLIDE_FALL_SPEED then
		maps.handleObjectGravity(o, maps.GRAVITY)
	else
		o.speedy = max($ - 2 * GLIDE_FALL_SPEED, GLIDE_FALL_SPEED)
		o.speedy = min($, 16 * GLIDE_FALL_SPEED)
	end
end

local function startClimbing(o)
	maps.enterRollState(o.player)
	maps.setObjectState(o, "climb")

	if o.dir == 1 then
		maps.setObjectAngle(o, ANGLE_90)
	else
		maps.setObjectAngle(o, ANGLE_270)
	end

	o.grounded = true
	maps.setObjectGroundSpeed(o, 0)

	maps.setPlayerAnimation(o.player, "climbstatic")
end

local function getPatchPosAroundPivot(refpatch, angle, x, y, scale, flags)
	local pivotx = x - refpatch.leftoffset / scale
	local pivoty = y + refpatch.height * scale / 2 - refpatch.topoffset * scale

	local dist = scale * (refpatch.topoffset - refpatch.height / 2)
	local feetx = pivotx + FixedMul(dist, sin(angle))
	local feety = pivoty + FixedMul(dist, cos(angle))

	if flags & V_FLIP then
		angle = -$
	end

	if angle <= -93206 * 256
	or angle >  139811 * 256 then
		feety = $ - 4 * scale
	end

	x = x - (feetx - x)
	y = y - (feety - y)

	return x, y, angle
end


maps.addObject{
	id = "player",

	w = FRACUNIT * 3 / 4,
	h = FRACUNIT * 5 / 4,

	on_tick = function(o)
		if o.state == "glide" then
			handleGlideGravity(o)
		elseif o.state ~= "climb" then
			maps.handleObjectGravity(o, maps.GRAVITY)
		end

		maps.removeObjectFromBlockmap(o)

		maps.handleObjectPhysics(o)

		maps.insertObjectInBlockmap(o)

		local tiledefs = maps.tiledefs

		local l = o.l / TILESIZE
		for y = o.t / TILESIZE, (o.b - 1) / TILESIZE do
			local i = l + y * map.w
			for x = l, (o.r - 1) / TILESIZE do
				local def = tiledefs[map2[i]]
				local onHit = def.on_hit
				if onHit then
					onHit(i, 2, o)
				end

				def = tiledefs[map3[i]]
				onHit = def.on_hit
				if onHit then
					onHit(i, 3, o)
				end

				i = i + 1
			end
		end

		if o.state == "roll" and o.grounded
		and abs(o.groundspeed) < TILESIZE / 16 then
			if maps.leaveRollState(o.player) then
				maps.setObjectState(o, "stand")
				maps.switchToGroundAnimation(o.player)
			end
		end

		if o.state == "climb" then
			if not o.grounded then
				maps.enterRollState(o.player)
				maps.setObjectState(o, "roll")
				maps.setObjectAngle(o, 0)

				maps.setPlayerAnimation(o.player, "roll")
			elseif o.angle > -ANGLE_67h and o.angle < ANGLE_67h then
				maps.leaveRollState(o.player)
				maps.setObjectState(o, "stand")
				maps.setObjectAngle(o, 0)
				maps.setObjectGroundSpeed(o, 0)

				maps.switchToGroundAnimation(o.player)
			end
		end

		if o.flashing then
			if o.flashing ~= INT32_MAX then
				o.flashing = $ - 1
				if not o.flashing then
					o.flashing = nil
				end
			elseif o.grounded then
				o.flashing = 3 * TICRATE
			end
		end

		if o.grounded and o.state == "stand" then
			maps.switchToGroundAnimation(o.player)
		elseif o.state == "glide" then
			local anim
			if abs(o.speedx) < TILESIZE / 8 then
				anim = "glideveryslow"
			elseif abs(o.speedx) < TILESIZE / 4 then
				anim = "glideslow"
			else
				anim = "glide"
			end

			if o.anim ~= anim then
				maps.setPlayerAnimation(o.player, anim)
			end
		end
	end,

	on_hit_solid_tile = function(o, dir, solidpos, solidtileindex, solidsloped)
		maps.on_hit_solid_tile(o, dir, solidpos, solidtileindex, solidsloped)

		if o.state == "glide" then
			startClimbing(o)
		end
	end,

	on_hit_object = function(o, o2)
		local def2 = maps.objectdefs[o2.type]
		local onHit2 = def2.on_hit_object
		if onHit2 and not o2.player then
			onHit2(o2, o)
		end
	end,

	on_land_tile = function(o)
		o.grounded = true
		maps.setObjectGroundSpeed(o, maps.getLandingSpeed(o, o.angle))

		if not (o.state == "jump" or o.state == "roll" or o.state == "glide")
		or maps.leaveRollState(o.player) then
			maps.setObjectState(o, "stand")
			maps.switchToGroundAnimation(o.player)
		end
	end,

	on_draw = function(v, o, scrollx, scrolly)
		local p = o.player

		local owner = p.owner ~= nil and players[p.owner] or nil

		local anim = maps.skindefs[p.skin].anim[o.anim]
		local frame = o.spr / anim.spd - 1

		local scale = FRACUNIT / 40 * maps.renderscale
		local flags = o.dir == 2 and V_FLIP or 0
		local angle = o.angle

		if o.state == "climb" then
			if o.angle > 0 then
				angle = $ - ANGLE_90
			else
				angle = $ + ANGLE_90
			end
		end

		-- Calculate the position of the player's feet
		local x = o.l + o.w / 2
		local y = o.t + o.h / 2
		local h = (o.floormode % 2 and o.w or o.h) / 2
		x = x - FixedMul(h, sin(angle))
		y = y + FixedMul(h, cos(angle))

		x = (x - scrollx) * maps.renderscale
		y = (y - scrolly) * maps.renderscale

		local frameangle = 3
		if anim.angle then
			frameangle = anim.angle
		end

		local refspr = v.getSprite2Patch(p.skin, anim.sprite2, false, frame, frameangle)
		x, y, angle = getPatchPosAroundPivot(refspr, -angle, x, y, scale, flags)

		local spr = v.getSprite2Patch(p.skin, anim.sprite2, false, frame, frameangle, angle)

		local leftoffset = spr.leftoffset
		local topoffset = spr.topoffset

		-- !!!
		-- Objects seem to disappear too soon
		if x + (spr.width - leftoffset) * scale <= 0
		or x - leftoffset * scale >= maps.SCREEN_WIDTH
		or y + (spr.height - topoffset) * scale <= 0
		or y - topoffset * scale >= maps.SCREEN_HEIGHT
		or (o.flashing and o.flashing ~= INT32_MAX) and maps.time & 2 then
			return
		end

		v.drawScaled(
			x,
			y,
			scale,
			spr,
			flags,
			v.getColormap(nil, owner and owner.skincolor or SKINCOLOR_BLUE)
		)
	end,
}
