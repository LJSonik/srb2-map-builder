local TILESIZE = maps.TILESIZE

local function checkEdge(o)
	local l = o.l
	if o.dir == 2 then
		l = $ + o.w / 2
	end

	if o.b + TILESIZE / 2 < maps.map.h * TILESIZE
	and not maps.areaContainsSolid(l, o.b, l + o.w / 2, o.b + TILESIZE / 2, maps.map[o.layer]) then
		o.dir = (o.dir == 1 and 2 or 1)
	end
end

local function on_tick(o)
	local def = maps.objectdefs[o.type]

	maps.handleObjectGravity(o, maps.GRAVITY)

	maps.removeObjectFromBlockmap(o)
	--maps.objblockmap[o] = false

	if o.grounded then
		o.groundspeed = def.speed * (o.dir == 1 and -1 or 1)
	end

	maps.handleObjectPhysics(o)
	checkEdge(o)

	--maps.objblockmap[o] = true
	maps.insertObjectInBlockmap(o)
end

local function on_hit_solid_tile(o)
	o.dir = (o.dir == 1 and 2 or 1)
end

local function on_hit_object(o, po)
	local def2 = maps.objectdefs[po.type]
	if def2.id == "player" then
		local p = po.player

		if po.state == "jump" or po.state == "roll" then
		--if p.spindash ~= false or p.glide or p.invincibility
			if po.speedy > 0 then
				po.speedy = -$
			end
			maps.removeObject(o)
			maps.startSound(sfx_pop, p)
		elseif not po.flashing then
			maps.damagePlayer(p)
		end
	end
end


maps.addObject{
	id = "blue_crawla",

	speed = TILESIZE / 32,

	w = TILESIZE,
	h = TILESIZE,
	anim = {spd = 3,"POSSB3B7","POSSC3C7","POSSD3D7","POSSE3E7","POSSF3F7"},

	on_tick = on_tick,
	on_hit_solid_tile = on_hit_solid_tile,
	on_hit_object = on_hit_object
}
