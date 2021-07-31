-- Todo:
-- Do not remove objects which spawner is in view
-- Compress objects in gamestate


local FU = FRACUNIT


maps.objectdefs = {}

maps.objects = {}
--maps.objectticker -- For despawning enemies

function maps.addObject(def)
	def.index = #maps.objectdefs + 1
	maps.objectdefs[def.index] = def
	maps.objectdefs[def.id] = def

	def.on_hit_solid_tile = $ or maps.on_hit_solid_tile
	def.on_land_tile = $ or maps.on_land_tile

	def.scale = $ or FU / 40

	local anim = def.anim
	if anim and anim[1] and type(anim[1]) ~= "table" then
		def.anim = {$}
	end
end

local function setObjectAnimation(o, anim)
	o.anim, o.spr = anim, maps.objectdefs[o.type].anim[anim].spd
end

-- ...
local function loopObjectAnimation(o)
	--if o.type ~= maps.OBJ_PLAYER -- !!!
	if o.type ~= 1 then -- !!!
		local anim = maps.objectdefs[o.type].anim[o.anim] -- !!! -- !!! BUG?

		o.spr = $ + 1
		if o.spr >= anim.spd * (#anim + 1) then
			o.spr = anim.spd
		end
	else
		-- !!!!
		--local p = maps.pp[o.player]
		local p = o.player
		local anim = maps.skindefs[p.skin].anim[o.anim]
		local spr = anim[o.spr / anim.spd]

		if o.anim == "walk" then
			local speed
			if o.grounded then
				speed = o.groundspeed
			else
				speed = o.speedx
			end

			local animspeed = abs(speed) * 32 / maps.TILESIZE
			animspeed = max($, 3)
			o.spr = $ + animspeed - anim.spd
			o.spr = $ % (anim.spd * anim.frames) + anim.spd
		else
			o.spr = $ + 1
			if o.spr >= anim.spd * (anim.frames + 1) then
				o.spr = anim.spd
			end
		end
	end
end

function maps.setObjectLeft(o, l)
	o.l = l
	o.r = o.l + o.w
	--o.pl = o.l / FU
	--o.pr = o.r / FU
end

function maps.setObjectTop(o, t)
	o.t = t
	o.b = o.t + o.h
	--o.pt = o.t / FU
	--o.pb = o.b / FU
end

function maps.setObjectRight(o, r)
	maps.setObjectLeft(o, r - o.w)
end

function maps.setObjectBottom(o, b)
	maps.setObjectTop(o, b - o.h)
end

function maps.moveObjectLeft(o, l)
	if o.type == 1 then
		o.refx = $ + (l - o.l)
	end

	maps.setObjectLeft(o, l)
end

function maps.moveObjectTop(o, t)
	if o.type == 1 then
		o.refy = $ + (t - o.t)
	end

	maps.setObjectTop(o, t)
end

function maps.moveObjectRight(o, r)
	maps.moveObjectLeft(o, r - o.w)
end

function maps.moveObjectBottom(o, b)
	maps.moveObjectTop(o, b - o.h)
end

function maps.setObjectState(o, state)
	o.state = state
end

function maps.spawnObject(t, x, y)
	local objects = maps.objects
	local objectdef = maps.objectdefs[t]

	local o = {}

	-- Find free object number
	for i = 1, #objects + 1 do
		if not objects[i] then
			o.id = i
			objects[i] = o
			break
		end
	end

	o.type = t

	o.w, o.h = objectdef.w, objectdef.h -- !!!
	--o.dir = 1

	o.layer = 3

	o.speedx = 0
	o.speedy = 0
	o.groundspeed = 0

	o.angle = 0
	o.floormode = 0
	o.grounded = false

	maps.setObjectLeft(o, x - o.w / 2)
	maps.setObjectBottom(o, y)

	if objectdef.id ~= "player" then
		o.anim = 1
		o.spr = objectdef.anim[o.anim].spd -- !!!
	else
		o.anim = "stand"
		o.spr = false

		o.refx = o.l + o.w / 2
		o.refy = o.t + o.h / 2
	end

	maps.insertObjectInBlockmap(o)

	return o
end

function maps.removeObject(o)
	if o.inblockmap then
		maps.removeObjectFromBlockmap(o)
	end

	o.removed = true

	-- Avoid holes in the table
	local objects = maps.objects
	local i = o.id
	if i == #objects then
		objects[i] = nil
		for i = i - 1, 1, -1 do
			if objects[i] then break end
			objects[i] = nil
		end
	else
		objects[i] = false
	end
end

-- !!!!
-- ...
function maps.handleObjects()
	local objects = maps.objects
	local objectdefs = maps.objectdefs

	for i = 1, #objects do
		local o = objects[i]
		if not o then continue end

		local def = objectdefs[o.type]

		local on_tick = def.on_tick
		if on_tick then
			on_tick(o)
		end

		loopObjectAnimation(o)
	end
end

local function areaContainsPlayerRefs(l, t, r, b)
	for i = 1, #maps.pp do
		local p = maps.pp[i]
		if p.builder then continue end

		local px, py
		if p.dead then
			px = p.x + maps.PLAYER_WIDTH  / 2
			py = p.y + maps.PLAYER_HEIGHT / 2
		else
			local o = p.obj
			px, py = o.refx, o.refy
		end

		if  px > l and px < r
		and py > t and py < b then
			return true
		end
	end

	return false
end

function maps.handleObjectDespawn()
	local ticker = maps.objectticker

	if ticker > #maps.objects then
		ticker = 1
	end

	local o = maps.objects[ticker]

	if o and maps.objectdefs[o.type].id ~= "player" then
		local dist = maps.MAX_OBJECT_DIST + maps.TILESIZE

		if not areaContainsPlayerRefs(
			o.l - dist, o.t - dist,
			o.r + dist, o.b + dist
		) then
			if o.spawn ~= nil then
				local mapw = maps.map.w
				local spawnx = o.spawn % mapw * maps.TILESIZE
				local spawny = o.spawn / mapw * maps.TILESIZE

				if not areaContainsPlayerRefs(
					spawnx - dist, spawny - dist,
					spawnx + dist, spawny + dist
				) then
					maps.removeObject(o)
				end
			end
		end
	end

	ticker = $ + 1
	if ticker > #maps.objects then
		ticker = 1
	end

	maps.objectticker = ticker
end

/*function maps.objectsInArea(x1, y1, x2, y2)
	local objects = maps.objects

	for i = 1, #maps.objects
		local o = maps.objects[i]
		if o
		and o.r >= x1 and o.l <= x2
		and o.b >= y1 and o.t <= y2
			return true
		end
	end
end

function maps.objectsAtPosition(x, y)
	return maps.objectsInArea(
		x * maps.TILESIZE,
		y * maps.TILESIZE,
		(x + 1) * maps.TILESIZE - 1,
		(y + 1) * maps.TILESIZE - 1
	)
end*/


addHook("NetVars", function(n)
	maps.objects = n($)
	maps.objectticker = n($)
end)
