local function extendSpring(tilepos, layernum, def, p)
	if def.respawn then return end

	maps.setTile(layernum, tilepos, maps.map[layernum][tilepos] + 1)
	maps.addTileToRespawnList(tilepos, layernum, 7)
	maps.tiledata[layernum][tilepos] = maps.time

	maps.startSound(sfx_spring, p)
end

function maps.on_spring_hit(tilepos, layernum, o)
	local p = o.player
	if not p then return end

	local tile = maps.map[layernum][tilepos]
	local def = maps.tiledefs[tile]

	if o.grounded and def.angle % 180 == o.floormode * 90 % 180 then
		local launchangle = FixedAngle(def.angle * FRACUNIT)
		o.speedx = FixedMul(def.strength, cos(launchangle))
		o.speedy = FixedMul(def.strength, sin(launchangle))
		o.groundspeed = maps.getLandingSpeed(o, o.angle)
	else
		if o.state == "roll" or o.state == "jump" then
			maps.leaveRollState(p)
		end

		if o.flashing == INT32_MAX then
			o.flashing = 3 * TICRATE
		end

		maps.setObjectState(o, "spring")
		o.grounded = false
		o.groundspeed = nil

		if def.angle == 0 then
			o.speedx = max(def.strength, $)
			o.dir = 2
		elseif def.angle == 90 then
			o.speedy = max(def.strength, $)
		elseif def.angle == 180 then
			o.speedx = min(-def.strength, $)
			o.dir = 1
		elseif def.angle == 270 then
			o.speedy = min(-def.strength, $)
		end

		maps.setPlayerAnimation(p, "spring")
	end

	o.dir = o.speedx < 0 and 1 or 2

	extendSpring(tilepos, layernum, def, p)
end

function maps.on_diagonal_spring_hit(tilepos, layernum, o)
	local p = o.player
	if not p then return end

	local tile = maps.map[layernum][tilepos]
	local def = maps.tiledefs[tile]

	if o.state == "roll" or o.state == "jump" then
		maps.leaveRollState(p)
	end

	if o.flashing == INT32_MAX then
		o.flashing = 3 * TICRATE
	end

	maps.setObjectState(o, "spring")
	o.grounded = false
	o.groundspeed = nil

	local launchangle = FixedAngle(def.angle * FRACUNIT)
	o.speedx = FixedMul(def.strength, cos(launchangle))
	o.speedy = FixedMul(def.strength, sin(launchangle))

	maps.setPlayerAnimation(p, "spring")

	extendSpring(tilepos, layernum, def, p)
end

function maps.on_spring_draw(v, layer, x, y, tilepos, layernum)
	local tile = layer[tilepos]

	--print(maps.tiledefs[maps.map[layernum][tilepos]].respawn)
	local animframe = maps.time - maps.tiledata[layernum][tilepos]
	animframe = $ % maps.tiledefs_animlen[tile]
	animframe = $ / maps.tiledefs_animspd[tile] + 1

	v.drawScaled(
		x + maps.tiledefs_offsetx[tile][animframe],
		y + maps.tiledefs_offsety[tile][animframe],
		maps.tiledefs_scale[tile],
		maps.tiledefs_anim[tile][animframe],
		maps.tiledefs_flags[tile]
	)
end
