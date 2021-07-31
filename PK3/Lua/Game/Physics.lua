local FU = FRACUNIT
local ANGLE_11hh = ANGLE_11hh
local ANGLE_22h  = ANGLE_22h
local ANGLE_45   = ANGLE_45
local ANGLE_90   = ANGLE_90
local ANGLE_180  = ANGLE_180
local TILESIZE = maps.TILESIZE
local BLOCKMAP_SIZE

local map, map2, map3
local blockmap, blockmapw, blockmaph
maps.addLocalsRefresher(function()
	BLOCKMAP_SIZE = maps.BLOCKMAP_SIZE
	map = maps.map
	map2, map3 = map[2], map[3]
	blockmap = maps.blockmap
	blockmapw, blockmaph = maps.blockmapw, maps.blockmaph
end)


maps.GRAVITY = TILESIZE / TICRATE
maps.SLOPE_FRICTION = maps.GRAVITY * 7 / 8
maps.ROLL_UP_SLOPE_FRICTION = maps.SLOPE_FRICTION / 2
maps.ROLL_DOWN_SLOPE_FRICTION = maps.SLOPE_FRICTION * 3 / 2
maps.MIN_WALL_SPEED = TILESIZE * 3 / 8


function maps.setObjectAngle(o, angle)
	local oldangle = o.angle -- !!! rm
	local oldfloormode = o.floormode

	o.angle = angle

	angle = $ / 4
	if angle < 0 then
		angle = $ + ANGLE_90
	end
	o.floormode = (angle + ANGLE_11hh) / ANGLE_22h % 4
	/*if oldangle ~= o.angle
		local angle = AngleFixed(o.angle)
		if angle > 180 * FU
			angle = $ - 360 * FU
		end
		print("angle "..angle / FU)
	end
	if oldfloormode ~= o.floormode
		print("mode "..o.floormode)
	end*/

	if abs(oldfloormode - o.floormode) % 2 == 1 then
		o.w, o.h = $2, $1

		if oldfloormode == 0 or o.floormode == 0 then
			maps.setObjectBottom(o, o.b)
		end
		if oldfloormode == 1 or o.floormode == 1 then
			maps.setObjectLeft(o, o.l)
		end
		if oldfloormode == 2 or o.floormode == 2 then
			maps.setObjectTop(o, o.t)
		end
		if oldfloormode == 3 or o.floormode == 3 then
			maps.setObjectRight(o, o.r)
		end
	end
end

function maps.setObjectGroundSpeed(o, groundspeed)
	o.groundspeed = groundspeed
	o.speedx = FixedMul(groundspeed, cos(o.angle))
	o.speedy = FixedMul(groundspeed, sin(o.angle))
end

function maps.getLandingSpeed(o, angle)
	local speed = R_PointToDist2(0, 0, o.speedx, o.speedy)
	local speedangle = R_PointToAngle2(0, 0, o.speedx, o.speedy)
	return FixedMul(speed, cos(speedangle - angle))
end

local function landObject(o)
	local def = maps.objectdefs[o.type]
	local onLand = def.on_land_tile
	if onLand then
		onLand(o)
	end
end

function maps.on_hit_solid_tile(o, dir, solidpos, solidtileindex, solidsloped)
	if dir == "left" or dir == "right" then
		if o.grounded then
			maps.setObjectGroundSpeed(o, 0)
		else
			local solidtile = map[o.layer][solidtileindex]
			local tiledef = maps.tiledefs[solidtile]

			if solidsloped and abs(maps.getLandingSpeed(o, tiledef.heightmap.angle)) >= TILESIZE / 3 then
				maps.setObjectAngle(o, tiledef.heightmap.angle)
				if not o.grounded then
					landObject(o)
				end
			else
				o.speedx = 0
			end
		end
	elseif dir == "up" then
		if o.grounded then
			maps.setObjectGroundSpeed(o, 0)
		else
			local solidtile = map[o.layer][solidtileindex]
			local tiledef = maps.tiledefs[solidtile]

			if solidsloped and abs(maps.getLandingSpeed(o, tiledef.heightmap.angle)) >= TILESIZE / 3 then
				maps.setObjectAngle(o, tiledef.heightmap.angle)
				if not o.grounded then
					landObject(o)
				end
			else
				o.speedy = 0
			end
		end
	else
		local solidtile = map[o.layer][solidtileindex]
		local tiledef = maps.tiledefs[solidtile]

		maps.setObjectAngle(o, tiledef.heightmap.angle)
		if not o.grounded then
			landObject(o)
		end
	end
end

function maps.on_land_tile(o)
	o.grounded = true
	maps.setObjectGroundSpeed(o, maps.getLandingSpeed(o, o.angle))
end

local function checkGround(o)
	local extracheck
	if o.grounded then
		extracheck = TILESIZE * 5 / 8
	else
		extracheck = 0
	end

	local l, t, r, b, h, f
	local mode = o.floormode
	if mode == 0 then
		l = o.l
		t = o.t + o.h / 2
		r = o.r
		b = min(o.b + extracheck, map.h * TILESIZE)
		h = o.h
		f = maps.findTopmostSolidInArea
	elseif mode == 1 then
		l = o.l - max(extracheck, 0)
		t = o.t
		r = o.l + o.w / 2
		b = o.b
		h = o.w
		f = maps.findRightmostSolidInArea
	elseif mode == 2 then
		l = o.l
		t = o.t - max(extracheck, 0)
		r = o.r
		b = o.t + o.h / 2
		h = o.h
		f = maps.findBottommostSolidInArea
	else
		l = o.l + o.w / 2
		t = o.t
		r = min(o.r + extracheck, map.w * TILESIZE)
		b = o.b
		h = o.w
		f = maps.findLeftmostSolidInArea
	end

	local groundlayer = o.layer
	local groundpos, groundtileindex, groundsloped = f(l, t, r, b, h, map[groundlayer])

	if groundpos == nil and o.grounded then
		groundlayer = ($ == 2 and 3 or 2)
		groundpos, groundtileindex, groundsloped = f(l, t, r, b, h, map[groundlayer])
	end

	if groundpos ~= nil then
		local groundtile = map[groundlayer][groundtileindex]
		if maps.tiledefs_empty[groundtile] then
			groundlayer = ($ == 2 and 3 or 2)
			groundtile = map[groundlayer][groundtileindex]
		end

		local groundangle
		if groundsloped then
			groundangle = maps.tiledefs[groundtile].heightmap.angle
		else
			groundangle = o.floormode * ANGLE_90
		end

		-- !!! MAYBE WRONG
		do
			local mode = o.floormode
			if mode == 0 then
				maps.moveObjectBottom(o, groundpos)
			elseif mode == 1 then
				maps.moveObjectLeft(o, groundpos)
			elseif mode == 2 then
				maps.moveObjectTop(o, groundpos)
			else
				maps.moveObjectRight(o, groundpos)
			end

			local landable
			if o.grounded then
				-- Not too steep
				landable = (abs(o.angle - groundangle) <= ANGLE_45)
			elseif o.floormode == 0 and o.speedy < 0 then
				landable = false
			elseif groundangle < ANGLE_90 and groundangle > -ANGLE_90 then
				landable = true
			else
				local speed = R_PointToDist2(0, 0, o.speedx, o.speedy)
				landable = (speed >= maps.MIN_WALL_SPEED)
			end

			if landable then
				if not maps.areaContainsSolid(o.l, o.t, o.r, o.b, map[groundlayer]) then
					o.layer = groundlayer
				end

				maps.setObjectAngle(o, groundangle)

				if not o.grounded then
					landObject(o)
				end
			end
		end
		/*if landable
			local mode = o.floormode
			if mode == 0
				maps.moveObjectBottom(o, groundpos)
			elseif mode == 1
				maps.moveObjectLeft(o, groundpos)
			elseif mode == 2
				maps.moveObjectTop(o, groundpos)
			else
				maps.moveObjectRight(o, groundpos)
			end

			if not maps.areaContainsSolid(o.l, o.t, o.r, o.b, map[groundlayer])
				o.layer = groundlayer
			end

			maps.setObjectAngle(o, groundangle)

			if not o.grounded
				landObject(o)
			end
		end*/
	elseif o.grounded then
		o.grounded = false
		o.groundspeed = nil
	end
end

local function checkSolidTileCollisions(o, dir)
	if dir == 0 then -- Bottom
		local solidpos, solidtileindex, solidsloped = maps.findTopmostSolidInArea(
			o.l, o.t + o.h / 2,
			o.r, o.b,
			o.h,
			map[o.layer]
		)

		if solidpos ~= nil then
			maps.moveObjectBottom(o, solidpos)
			local def = maps.objectdefs[o.type]
			def.on_hit_solid_tile(o, "down", solidpos, solidtileindex, solidsloped)
		end
	elseif dir == 1 then -- Left
		local solidpos, solidtileindex, solidsloped = maps.findRightmostSolidInArea(
			o.l, o.t,
			o.r, o.b,
			o.w,
			map[o.layer]
		)

		if solidpos ~= nil then
			maps.moveObjectLeft(o, solidpos)

			--if o.speedx < 0
				local def = maps.objectdefs[o.type]
				def.on_hit_solid_tile(o, "left", solidpos, solidtileindex, solidsloped)
			--end
		end
	elseif dir == 2 then -- Top
		local solidpos, solidtileindex, solidsloped = maps.findBottommostSolidInArea(
			o.l, o.t,
			o.r, o.t + o.h / 2,
			o.h,
			map[o.layer]
		)

		if solidpos ~= nil then
			maps.moveObjectTop(o, solidpos)

			--if o.speedy < 0
				local def = maps.objectdefs[o.type]
				def.on_hit_solid_tile(o, "up", solidpos, solidtileindex, solidsloped)
			--end
		end
	elseif dir == 3 then -- Right
		local solidpos, solidtileindex, solidsloped = maps.findLeftmostSolidInArea(
			o.l, o.t,
			o.r, o.b,
			o.w,
			map[o.layer]
		)

		if solidpos ~= nil then
			maps.moveObjectRight(o, solidpos)

			--if o.speedx > 0
				local def = maps.objectdefs[o.type]
				def.on_hit_solid_tile(o, "right", solidpos, solidtileindex, solidsloped)
			--end
		end
	end
end

local function checkObjectCollisions(o)
	local objects = maps.objects

	local t = o.type
	local p
	if t == 1 then
		p = o.player
	end

	local bx, by = o.l / BLOCKMAP_SIZE, o.t / BLOCKMAP_SIZE
	local bl, bt = bx - 1, by - 1
	local br, bb = bx + 1, by + 1

	if bl < 0 then
		bl = 0
	end
	if bt < 0 then
		bt = 0
	end
	if br >= blockmapw then
		br = blockmapw - 1
	end
	if bb >= blockmaph then
		bb = blockmaph - 1
	end

	-- !!!
	for by = bt, bb do
		for bx = bl, br do
			local block = blockmap[bx + by * blockmapw]
			for i = 1, #block do
				local o2 = block[i]
				if not o2 then continue end -- Object removed from block

				if  o.r > o2.l and o.l < o2.r
				and o.b > o2.t and o.t < o2.b then
					local def = maps.objectdefs[o.type]
					local onHit = def.on_hit_object
					if onHit then
						onHit(o, o2)
						if o.removed then return end
					end
				end
			end
		end
	end
end

function maps.handleObjectGravity(o, gravity)
	if o.grounded then
		local friction
		if o.state == "roll" then
			if o.angle < 0 and o.groundspeed < 0
			or o.angle > 0 and o.groundspeed > 0 then
				friction = maps.ROLL_DOWN_SLOPE_FRICTION
			else
				friction = maps.ROLL_UP_SLOPE_FRICTION
			end
		else
			friction = maps.SLOPE_FRICTION
		end

		friction = FixedMul($, sin(o.angle))
		maps.setObjectGroundSpeed(o, o.groundspeed + friction)

		if (o.angle >= ANGLE_90 or o.angle <= -ANGLE_90)
		and abs(o.groundspeed) < maps.MIN_WALL_SPEED then
			o.grounded = false
			o.groundspeed = nil
		end
	else
		o.speedy = $ + gravity

		if o.angle ~= 0 then
			local ANGLE_SPEED = ANGLE_90 / TICRATE
			if o.angle < 0 then
				maps.setObjectAngle(o, min(o.angle + ANGLE_SPEED, 0))
			else
				maps.setObjectAngle(o, max(o.angle - ANGLE_SPEED, 0))
			end
		end
	end
end

function maps.handleObjectPhysics(o)
	local speedx, speedy = o.speedx, o.speedy
	local speed = R_PointToDist2(0, 0, speedx, speedy)
	local numsteps = speed / (TILESIZE / 3) + 1
	local stepdist = speed / numsteps

	local oldrefx, oldrefy
	if o.player then
		oldrefx, oldrefy = o.refx / TILESIZE, o.refy / TILESIZE
	end

	for i = 1, numsteps do
		-- !!!
		--local stepangle = R_PointToAngle2(0, 0, o.speedx, o.speedy)
		--local stepx = stepdist * cos(stepangle) / FU
		--local stepy = stepdist * sin(stepangle) / FU
		local stepx = speedx / numsteps
		local stepy = speedy / numsteps

		local newleft = o.l + stepx
		if newleft < 0 then
			newleft = 0
			o.speedx = 0
			if o.grounded then
				o.groundspeed = 0
			end
		elseif newleft + o.w >= map.w * TILESIZE then
			newleft = map.w * TILESIZE - o.w
			o.speedx = 0
			if o.grounded then
				o.groundspeed = 0
			end
		end
		maps.moveObjectLeft(o, newleft)

		local newtop = o.t + stepy
		if newtop < 0 then
			newtop = 0
			o.speedy = 0
			if o.grounded then
				o.groundspeed = 0
			end
		elseif newtop + o.h >= map.h * TILESIZE then
			newtop = map.h * TILESIZE - o.h
			o.speedy = 0
			if o.grounded then
				o.groundspeed = 0
			end
		end
		maps.moveObjectTop(o, newtop)

		checkGround(o)
		checkSolidTileCollisions(o, o.floormode)
		checkSolidTileCollisions(o, (o.floormode + 1) % 4)
		checkSolidTileCollisions(o, (o.floormode + 2) % 4)
		checkSolidTileCollisions(o, (o.floormode + 3) % 4)
		checkObjectCollisions(o)

		if o.player then
			local refx, refy = o.refx / TILESIZE, o.refy / TILESIZE

			if refx ~= oldrefx then
				local dist = maps.MAX_OBJECT_DIST / TILESIZE

				local checkx
				if stepx < 0 then
					checkx = refx - dist
				else
					checkx = refx + dist
				end

				maps.checkSpawnersInColumn(checkx, refy - dist, refy + dist)
				oldrefx = refx
			end

			if refy ~= oldrefy then
				local dist = maps.MAX_OBJECT_DIST / TILESIZE

				local checky
				if stepy < 0 then
					checky = refy - dist
				else
					checky = refy + dist
				end

				maps.checkSpawnersInLine(checky, refx - dist, refx + dist)
				oldrefy = refy
			end
		end
	end
end
