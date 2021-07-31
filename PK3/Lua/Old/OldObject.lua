if true return end


local FU = FRACUNIT

maps.GRAVITY = FU / 4

-- !!!
maps.MAX_OBJECT_DIST = 40 * maps.BLOCK_SIZE

-- !!!
maps.OBJ_PLAYER = 1
maps.OBJ_SPILLEDRING = 2
maps.OBJ_BLUECRAWLA = 3
maps.OBJ_REDCRAWLA = 4
maps.OBJ_ROBOFISH = 5
maps.OBJ_GREENSPRINGSHELL = 6
maps.OBJ_YELLOWSPRINGSHELL = 7
maps.OBJ_GOLDBUZZ = 8
maps.OBJ_REDBUZZ = 9
maps.OBJ_GREENSNAPPER = 10
maps.OBJ_SHARP = 11
maps.OBJ_THOK = 12


-- Objects
--maps.objtype     -- Type
--maps.objx        -- Position
--maps.objy
--maps.objw        -- Size
--maps.objh
--maps.objdx       -- Speed
--maps.objdy
--maps.objdir      -- Direction (1 = left, 2 = right)
--maps.objanim     -- Animation
--maps.objspr      -- Animation state
--maps.objcolor    -- Color
--maps.objspawn    -- Spawn location
--maps.objblockmap -- Is in blockmap
--maps.objextra    -- Extra information

-- Object properties
-- Yeah I know it's empty


local function setObjectAnimation(o, anim)
	maps.objanim[o], maps.objspr[o] = anim, maps.objectproperties[maps.objtype[o]].anim[anim].spd
end

-- ...
local function loopObjectAnimation(o)
	local objanim = maps.objanim
	local objspr = maps.objspr

	if maps.objtype[o] ~= maps.OBJ_PLAYER -- !!!
		local a = maps.objectproperties[maps.objtype[o]].anim[objanim[o]] -- !!! -- !!! BUG?

		objspr[o] = $ + 1
		if objspr[o] >= a.spd * (#a + 1)
			objspr[o] = a.spd
		end
	else
		-- !!!!
		local p = maps.pp[maps.objextra[o]]
		local a = maps.skininfo[p.skin].anim[objanim[o]]
		local spr = a[objspr[o] / a.spd]

		if objanim[o] == "walk"
			objspr[o] = ($ + 4 * abs(maps.objdx[o]) / FU - a.spd) % (a.spd * #a) + a.spd
		else
			objspr[o] = $ + 1
			if objspr[o] >= a.spd * (#a + 1)
				objspr[o] = a.spd
			end
		end
	end
end

function maps.setObjectHeight(o, h)
	-- Keep feet at the same height
	maps.removeObjectFromBlockmap(o)
	maps.objy[o] = $ + maps.objh[o] - h
	maps.insertObjectInBlockmap(o)

	maps.objh[o] = h
end

local function landObject(o)
	local t = maps.objtype[o]

	if t == maps.OBJ_PLAYER
		local p = maps.pp[maps.objextra[o]]

		if (p.spin or p.spindash ~= false) and maps.objdy[o] > maps.GRAVITY
			maps.unspinPlayer(p)
		elseif p.jump or p.thok
			p.jump = false
			if p.thok
				p.thok = false
			end

			maps.setObjectHeight(o, maps.PLAYER_HEIGHT)

			if maps.playerColliding(p)
				maps.spinPlayer(p)
			else
				maps.setPlayerAnimation(p, maps.objdx[o] == 0 and "std" or abs(maps.objdx[o]) < maps.skininfo[p.skin].run and "walk" or "run")
			end
		elseif p.fly ~= nil or p.glide
			p.fly = nil
			p.glide = nil

			maps.setObjectHeight(o, maps.PLAYER_HEIGHT)

			if maps.playerColliding(p)
				maps.spinPlayer(p)
			else
				maps.setPlayerAnimation(p, maps.objdx[o] == 0 and "std" or abs(maps.objdx[o]) < maps.skininfo[p.skin].run and "walk" or "run")
			end
		elseif p.climb
			p.climb = nil

			maps.setPlayerAnimation(p, "std")
		-- !!!
		elseif p.spring
			p.spring = nil
			maps.setPlayerAnimation(p, maps.objdx[o] == 0 and "std" or abs(maps.objdx[o]) < maps.skininfo[p.skin].run and "walk" or "run")
		elseif p.carry
			maps.pp[maps.objextra[p.carry]].carried = nil
			p.carry = nil
			maps.setPlayerAnimation(p, maps.objdx[o] == 0 and "std" or abs(maps.objdx[o]) < maps.skininfo[p.skin].run and "walk" or "run")
		elseif p.carried
			maps.pp[maps.objextra[p.carried]].carry = nil
			p.carried = nil
			maps.setPlayerAnimation(p, maps.objdx[o] == 0 and "std" or abs(maps.objdx[o]) < maps.skininfo[p.skin].run and "walk" or "run")
		elseif p.flash == 3 * TICRATE
			p.flash = $ - 1
			maps.setPlayerAnimation(p, maps.objdx[o] == 0 and "std" or abs(maps.objdx[o]) < maps.skininfo[p.skin].run and "walk" or "run")
		elseif maps.objanim[o] == "carry"
			maps.setPlayerAnimation(p, maps.objdx[o] == 0 and "std" or abs(maps.objdx[o]) < maps.skininfo[p.skin].run and "walk" or "run")
		end

		maps.objdy[o] = 0
	elseif t == maps.OBJ_SPILLEDRING
		maps.objdy[o] = -$ * 7 / 8
		if maps.objdx[o] < 0
			maps.objdx[o] = min($ + FU / 8, 0)
		elseif maps.objdx[o] > 0
			maps.objdx[o] = max($ - FU / 8, 0)
		end
	else
		maps.objdy[o] = 0
	end
end

local function hitObjectWall(o)
	local t = maps.objtype[o]

	if t == maps.OBJ_PLAYER
		local p = maps.pp[maps.objextra[o]]

		if p.glide
			p.glide = nil

			maps.setObjectHeight(o, maps.PLAYER_HEIGHT)

			if maps.playerColliding(p)
				local y = maps.objy[o]
				maps.objy[o] = ($ / maps.BLOCK_SIZE + 1) * maps.BLOCK_SIZE
				if maps.playerColliding(p)
					maps.objy[o] = y + maps.objh[o]
					maps.objh[o] = maps.PLAYER_SPIN_HEIGHT
					maps.objy[o] = $ - maps.objh[o]
					p.spin = true
					return
				end
			end

			p.climb = true
			maps.objdy[o] = 0

			maps.setPlayerAnimation(p, "climbstd")
		end

		maps.objdx[o] = 0
	elseif t == maps.OBJ_SPILLEDRING
		maps.objdx[o] = -$ * 7 / 8
	else
		maps.objdx[o] = 0
		maps.objdir[o] = $ == 1 and 2 or 1
	end
end

local function hitObjectCeiling(o)
	if maps.objtype[o] ~= maps.OBJ_SPILLEDRING
		maps.objdy[o] = 0
	else
		maps.objdy[o] = -$ * 7 / 8
		if maps.objdx[o] < 0
			maps.objdx[o] = min($ + FU / 8, 0)
		elseif maps.objdx[o] > 0
			maps.objdx[o] = max($ - FU / 8, 0)
		end
	end
end

function maps.spawnObject(t, x, y)
	-- Find free object number
	local o
	for i = 1, #maps.objtype
		if not maps.objtype[i]
			o = i
			break
		end
	end
	if not o
		o = #maps.objtype + 1
	end

	-- Initialise object
	local info = maps.objectproperties[t]
	maps.objtype[o] = t
	maps.objx[o], maps.objy[o] = x, y
	maps.objw[o], maps.objh[o] = info.w, info.h -- !!!
	maps.objdx[o], maps.objdy[o] = 0, 0
	maps.objdir[o] = 1
	if t ~= 1
		maps.objanim[o] = 1
		maps.objspr[o] = info.anim[maps.objanim[o]].spd -- !!!
	else
		maps.objanim[o] = "std"
		maps.objspr[o] = false
	end
	maps.objcolor[o] = nil
	maps.objspawn[o] = false
	maps.objblockmap[o] = t ~= maps.OBJ_THOK -- !!!
	maps.objextra[o] = false

	maps.insertObjectInBlockmap(o)

	return o
end

function maps.removeObject(o)
	if maps.objtype[o] == maps.OBJ_PLAYER
		local p = maps.pp[maps.objextra[o]]

		if p.carry -- Free carried player
			maps.pp[maps.objextra[p.carry]].carried = nil
			p.carry = nil
		elseif p.carried -- Free carrying player
			maps.pp[maps.objextra[p.carried]].carry = nil
			p.carried = nil
		end

		-- Unlink chasers
		for o2 = 1, #maps.objtype
			local t2 = maps.objtype[o2]
			if (t2 == maps.OBJ_GOLDBUZZ or t2 == maps.OBJ_REDBUZZ) and maps.objextra[o2] == o
				local target = maps.findTarget(o2)
				if target
					maps.objextra[o2] = target
				else
					maps.removeObject(o2)
				end
			end
		end
	end

	maps.removeObjectFromBlockmap(o)

	maps.objtype[o] = false

	-- Avoid holes in the table
	if o == #maps.objtype
		while o ~= 0 and not maps.objtype[o]
			maps.objtype[o] = nil
			maps.objx[o], maps.objy[o] = nil, nil
			maps.objw[o], maps.objh[o] = nil, nil
			maps.objdx[o], maps.objdy[o] = nil, nil
			maps.objdir[o] = nil
			maps.objanim[o] = nil
			maps.objspr[o] = nil
			maps.objcolor[o] = nil
			maps.objspawn[o] = nil
			maps.objblockmap[o] = nil
			maps.objextra[o] = nil

			o = $ - 1
		end
	end
end

function maps.findTarget(o)
	local nearestdist = INT32_MAX
	local target

	for i = 1, #maps.pp
		local p = maps.pp[i]
		if p.builder or p.dead continue end

		local o2 = p.obj
		local dist = P_AproxDistance(maps.objx[o2] - maps.objx[o], maps.objy[o2] - maps.objy[o])
		if dist <= nearestdist
			nearestdist = dist
			target = o2
		end
	end

	return target
end

local function hitPlayerObject(p, po, o, dy, prevy, prevh)
	local t = maps.objtype[o]

	if t == maps.OBJ_PLAYER
		-- Tails pickup
		if p.fly and not p.carry
			local p2 = maps.pp[maps.objextra[o]]

			if not p2.carried
			--and maps.objy[po] + maps.objh[po] / 2 < maps.objy[o] + maps.objh[o] / 2 -- !!!
			and maps.objy[po] + maps.objh[po] * 2 / 3 <= maps.objy[o]
			and P_AproxDistance(maps.objdx[po] - maps.objdx[o], maps.objdy[po] - maps.objdy[o]) <= 2 * FU
				local prevx, prevy = maps.objx[o], maps.objy[o]

				-- Center Sonic at Tails
				maps.objx[o] = maps.objx[po] + maps.objw[po] / 2 - maps.objw[o] / 2

				-- Stick Sonic at Tails' feet
				maps.objy[o] = maps.objy[po] + maps.objh[po] * 2 / 3

				if playerColliding(p2)
					maps.objx[o], maps.objy[o] = prevx, prevy
					return
				end

				p.carry = o
				p2.carried = po

				-- Stop Sonic
				maps.objdx[o], maps.objdy[o] = 0, 0

				maps.setPlayerAnimation(p2, "carry")
			end
		end
	elseif t == maps.OBJ_SPILLEDRING
		-- !!!
		if p.flash <= TICRATE * 3 / 4 * 3 or p.flash > 3 * TICRATE
			p.rings = min($ + 1, 9999)
			maps.startSound(sfx_itemup, p)
			maps.removeObject(o)
		end
	elseif t == maps.OBJ_BLUECRAWLA or t == maps.OBJ_REDCRAWLA
	or t == maps.OBJ_GOLDBUZZ or t == maps.OBJ_REDBUZZ
	or t == maps.OBJ_ROBOFISH
		if p.jump or p.spin or p.spindash ~= false or p.glide or p.invincibility
			if maps.objdy[po] > maps.GRAVITY
				maps.objdy[po] = -$
			end
			maps.removeObject(o)
			maps.startSound(sfx_pop, p)
		elseif not p.flash
			maps.damagePlayer(p)
		end
	elseif t == maps.OBJ_GREENSPRINGSHELL or t == maps.OBJ_YELLOWSPRINGSHELL
		if prevy ~= nil and prevy + prevh <= maps.objy[o]
			maps.objy[po] = maps.objy[o] - maps.objh[po]
			maps.springPlayer(p, nil, t == maps.OBJ_GREENSPRINGSHELL and 4 * FU or 6 * FU)
			setObjectAnimation(o, 2)
		elseif p.jump or p.spin or p.spindash ~= false or p.glide or p.invincibility
			if maps.objdy[po] > maps.GRAVITY
				maps.objdy[po] = -$
			end
			maps.removeObject(o)
			maps.startSound(sfx_pop, p)
		elseif not p.flash
			maps.damagePlayer(p)
		end
	elseif t == maps.OBJ_GREENSNAPPER
		if dy
			if p.jump or p.spin or p.spindash ~= false or p.glide or p.invincibility
				if maps.objdy[po] > maps.GRAVITY
					maps.objdy[po] = -$
				end
				maps.removeObject(o)
				maps.startSound(sfx_pop, p)
			elseif not p.flash
				maps.damagePlayer(p)
			end
		elseif not (p.flash or p.invincibility)
			maps.damagePlayer(p)
		elseif p.jump or p.spin or p.spindash ~= false or p.glide or p.invincibility
			if maps.objdy[po] > maps.GRAVITY
				maps.objdy[po] = -$
			end
			maps.removeObject(o)
			maps.startSound(sfx_pop, p)
		end
	elseif t == maps.OBJ_SHARP
		if dy and prevy ~= nil and prevy + prevh <= maps.objy[o]
			if not (p.flash or p.invincibility)
				maps.damagePlayer(p)
			elseif p.jump or p.spin or p.spindash ~= false or p.glide or p.invincibility
				if maps.objdy[po] > maps.GRAVITY
					maps.objdy[po] = -$
				end
				maps.removeObject(o)
				maps.startSound(sfx_pop, p)
			end
		elseif p.jump or p.spin or p.spindash ~= false or p.glide or p.invincibility
			if maps.objdy[po] > maps.GRAVITY
				maps.objdy[po] = -$
			end
			maps.removeObject(o)
			maps.startSound(sfx_pop, p)
		elseif not p.flash
			maps.damagePlayer(p)
		end
	end
end

local function checkObjectCollisions(o, dy, prevy, prevh)
	local objx, objy = maps.objx, maps.objy
	local objw, objh = maps.objw, maps.objh

	local t = maps.objtype[o]
	local p
	if t == 1
		p = maps.pp[maps.objextra[o]]
	end

	local bx, by = objx[o] / maps.BLOCKMAP_SIZE, objy[o] / maps.BLOCKMAP_SIZE
	local bx1, by1 = bx - 1, by - 1
	local bx2, by2 = bx + 1, by + 1

	if bx1 < 0
		bx1 = 0
	end
	if by1 < 0
		by1 = 0
	end
	if bx2 >= maps.blockmapw
		bx2 = maps.blockmapw - 1
	end
	if by2 >= maps.blockmaph
		by2 = maps.blockmaph - 1
	end

	-- !!!
	for by = by1, by2
		for bx = bx1, bx2
			local block = maps.blockmap[bx + by * maps.blockmapw + 1]
			for i = 1, #block
				local o2 = block[i]
				if not o2 continue end -- Object removed

				local x = objx[o]
				local x2 = objx[o2]

				if x + objw[o] > x2
				and x < x2 + objw[o2]
				and objy[o] + objh[o] > objy[o2]
				and objy[o] < objy[o2] + objh[o2]
					if p -- !!!
						hitPlayerObject(p, o, o2, dy, prevy, prevh)
						if not maps.objtype[o] return end -- Object removed
					elseif maps.objtype[o2] == maps.OBJ_PLAYER -- !!!
						hitPlayerObject(maps.pp[maps.objextra[o2]], o2, o, dy, prevy, prevh)
						if not maps.objtype[o] return end -- Object removed
					end
				end
			end
		end
	end
end

local function moveObjectHorizontally(o, dx)
	local t = maps.objtype[o]

	local p
	local prevx
	local prevw
	if t == 1
		p = maps.pp[maps.objextra[o]]
		prevx = maps.objx[o]
		prevw = maps.objw[o]
	end

	maps.objx[o] = $ + dx

	if maps.objx[o] < 0
		maps.objx[o] = 0
		maps.objdx[o] = 0
		if not p
			maps.objdir[o] = 2
		end
		return
	elseif maps.objx[o] > maps.map.w * maps.BLOCK_SIZE - maps.objw[o]
		maps.objx[o] = maps.map.w * maps.BLOCK_SIZE - maps.objw[o]
		maps.objdx[o] = 0
		if not p
			maps.objdir[o] = 1
		end
		return
	end

	for x = maps.objx[o] / maps.BLOCK_SIZE + 1, (maps.objx[o] + maps.objw[o] - 1) / maps.BLOCK_SIZE + 1
		for y = maps.objy[o] / maps.BLOCK_SIZE + 1, min((maps.objy[o] + maps.objh[o] - 1) / maps.BLOCK_SIZE + 1, maps.map.h)
			local i = x + (y - 1) * maps.map.w
			local tile = maps.tiletype[maps.map1[i]]
			if tile == 1
				if maps.tileinfo[i] >> 4 == 1 -- Solid
					if dx < 0
						maps.objx[o] = x * maps.BLOCK_SIZE
					else
						maps.objx[o] = (x - 1) * maps.BLOCK_SIZE - maps.objw[o]
					end
					hitObjectWall(o)
					return
				end
				continue
			elseif tile == 6 or tile == 7 -- Spikes -- !!! Spikes are shitty
			or tile == 23 -- Ice
				if dx < 0
					maps.objx[o] = x * maps.BLOCK_SIZE
				else
					maps.objx[o] = (x - 1) * maps.BLOCK_SIZE - maps.objw[o]
				end
				hitObjectWall(o)
				return
			elseif tile == 12 -- Monitor -- !!! Monitors too =p
				if p and (p.jump or p.spin or p.glide)
					maps.playerBreakMonitor(p, i)
					if not maps.objtype[o] return true end -- Object removed
				elseif dx < 0
					maps.objx[o] = x * maps.BLOCK_SIZE
					hitObjectWall(o)
					return
				else
					maps.objx[o] = (x - 1) * maps.BLOCK_SIZE - maps.objw[o]
					hitObjectWall(o)
					return
				end
			end
		end
	end

	checkObjectCollisions(o)
	if not maps.objtype[o] return true end -- Object removed

	-- Object spawn
	if p
		if dx < 0
			local x = (maps.objx[o] - maps.MAX_OBJECT_DIST) / maps.BLOCK_SIZE + 1
			if x >= 1 and x < (prevx - maps.MAX_OBJECT_DIST) / maps.BLOCK_SIZE + 1
				maps.checkSpawnersInColumn(x,
					(maps.objy[o] - maps.MAX_OBJECT_DIST) / maps.BLOCK_SIZE + 1,
					(maps.objy[o] + maps.objh[o] - 1 + maps.MAX_OBJECT_DIST) / maps.BLOCK_SIZE + 1)
			end
		else
			local x = (maps.objx[o] + maps.objw[o] - 1 + maps.MAX_OBJECT_DIST) / maps.BLOCK_SIZE + 1
			if x <= maps.map.w and x > (prevx + prevw - 1 + maps.MAX_OBJECT_DIST) / maps.BLOCK_SIZE + 1
				maps.checkSpawnersInColumn(x,
					(maps.objy[o] - maps.MAX_OBJECT_DIST) / maps.BLOCK_SIZE + 1,
					(maps.objy[o] + maps.objh[o] - 1 + maps.MAX_OBJECT_DIST) / maps.BLOCK_SIZE + 1)
			end
		end
	end
end

local function moveObjectVertically(o, dy)
	local t = maps.objtype[o]

	local prevy = maps.objy[o]
	local prevh = maps.objh[o]

	local p
	if t == maps.OBJ_PLAYER
		p = maps.pp[maps.objextra[o]]
	end

	maps.objy[o] = $ + dy

	if maps.objy[o] < 0
		maps.objy[o] = 0
		maps.objdy[o] = 0
		return
	end

	for x = maps.objx[o] / maps.BLOCK_SIZE + 1, (maps.objx[o] + maps.objw[o] - 1) / maps.BLOCK_SIZE + 1
		for y = maps.objy[o] / maps.BLOCK_SIZE + 1, (maps.objy[o] + maps.objh[o] - 1) / maps.BLOCK_SIZE + 1
			local i = x + (y - 1) * maps.map.w
			local tile = maps.tiletype[maps.map1[i]]
			if tile == 1 -- Decoration, solid or platform
				local info = maps.tileinfo[i] >> 4
				if info == 1 -- Solid
					if dy < 0
						maps.objy[o] = y * maps.BLOCK_SIZE
						hitObjectCeiling(o)
					else
						maps.objy[o] = (y - 1) * maps.BLOCK_SIZE - maps.objh[o]
						landObject(o)
					end
					return
				elseif info == 2 and dy > 0
				and prevy + prevh <= (y - 1) * maps.BLOCK_SIZE -- Platform
				and t ~= maps.OBJ_ROBOFISH -- !!!
					maps.objy[o] = (y - 1) * maps.BLOCK_SIZE - maps.objh[o]
					landObject(o)
					return
				end
				continue
			elseif tile == 23 -- Ice
				if dy < 0
					maps.objy[o] = y * maps.BLOCK_SIZE
					hitObjectCeiling(o)
				else
					maps.objy[o] = (y - 1) * maps.BLOCK_SIZE - maps.objh[o]
					landObject(o)
				end
				return
			elseif tile == 24 -- Ice platform
				if dy > 0 and maps.objy[o] + maps.objh[o] - dy <= (y - 1) * maps.BLOCK_SIZE
					maps.objy[o] = (y - 1) * maps.BLOCK_SIZE - maps.objh[o]
					landObject(o)
					return
				end
			-- !!!
			-- Spikes are shitty
			elseif tile == 6 -- Floor damages
				if dy < 0
					maps.objy[o] = y * maps.BLOCK_SIZE
					hitObjectCeiling(o)
				else
					maps.objy[o] = (y - 1) * maps.BLOCK_SIZE - maps.objh[o]
					if p
						if p.flash or p.invincibility
							landObject(o)
						else
							maps.damagePlayer(p, "spikes")
							if not maps.objtype[o] return true end -- Object removed
						end
					else
						landObject(o)
					end
				end
				return
			elseif tile == 7 -- Ceiling damages
				if dy > 0
					maps.objy[o] = (y - 1) * maps.BLOCK_SIZE - maps.objh[o]
					landObject(o)
				else
					maps.objy[o] = y * maps.BLOCK_SIZE
					if p
						if p.flash or p.invincibility
							landObject(o)
						else
							maps.damagePlayer(p, "spikes")
							if not maps.objtype[o] return true end -- Object removed
						end
					else
						landObject(o)
					end
				end
				return
			elseif tile == 8 -- Bouncing platform
				if dy > 0 and maps.objy[o] + maps.objh[o] - dy <= (y - 1) * maps.BLOCK_SIZE
					maps.objy[o] = (y - 1) * maps.BLOCK_SIZE - maps.objh[o]
					maps.objdy[o] = min(-$, -3 * FU)
					if p
						if p.spin and abs(maps.objdx[o]) < FU / 2
							maps.unspinPlayer(p)
						end
						maps.startSound(sfx_bnce2, p) -- !!! Sound for objects too?
					end
				end
			elseif tile == 12 -- Monitor -- !!! Monitors are shitty, too...
				if p and (p.jump or p.spin or p.spindash ~= false or p.glide)
					maps.playerBreakMonitor(p, i)
					if not maps.objtype[o] return true end -- Object removed
				elseif dy < 0
					maps.objy[o] = y * maps.BLOCK_SIZE
					hitObjectCeiling(o)
					return
				else
					maps.objy[o] = (y - 1) * maps.BLOCK_SIZE - maps.objh[o]
					landObject(o)
					return
				end
			end
		end
	end

	checkObjectCollisions(o, dy, prevy, prevh)
	if not maps.objtype[o] return true end -- Object removed

	-- Death pit
	if maps.objy[o] + maps.objh[o] > maps.map.h * maps.BLOCK_SIZE
		maps.objy[o] = maps.map.h * maps.BLOCK_SIZE - maps.objh[o]
		if p
			maps.killPlayer(p)
		else
			maps.removeObject(o)
		end
		return true
	end

	-- Object spawn
	if p
		if dy < 0
			local y = (maps.objy[o] - maps.MAX_OBJECT_DIST) / maps.BLOCK_SIZE + 1
			if y >= 1 and y < (prevy - maps.MAX_OBJECT_DIST) / maps.BLOCK_SIZE + 1
				maps.checkSpawnersInLine(y,
					(maps.objx[o] - maps.MAX_OBJECT_DIST) / maps.BLOCK_SIZE + 1,
					(maps.objx[o] + maps.objw[o] - 1 + maps.MAX_OBJECT_DIST) / maps.BLOCK_SIZE + 1)
			end
		else
			local y = (maps.objy[o] + maps.objh[o] - 1 + maps.MAX_OBJECT_DIST) / maps.BLOCK_SIZE + 1
			if y <= maps.map.h and y > (prevy + prevh - 1 + maps.MAX_OBJECT_DIST) / maps.BLOCK_SIZE + 1
				maps.checkSpawnersInLine(y,
					(maps.objx[o] - maps.MAX_OBJECT_DIST) / maps.BLOCK_SIZE + 1,
					(maps.objx[o] + maps.objw[o] - 1 + maps.MAX_OBJECT_DIST) / maps.BLOCK_SIZE + 1)
			end
		end
	end
end

-- !!!!
-- ...
function maps.handleObjects()
	local objtype = maps.objtype
	--local objx, objy = maps.objx, maps.objy
	--local objw, objh = maps.objw, maps.objh
	local objdx, objdy = maps.objdx, maps.objdy
	local objdir = maps.objdir
	--local objanim = maps.objanim
	--local objspr = maps.objspr
	local objextra = maps.objextra
	-- ...

	for o = 1, #objtype
		local t = objtype[o]
		if not t continue end

		-- !!!
		if t == maps.OBJ_PLAYER
			local p = maps.pp[objextra[o]]

			local prevx, prevy = maps.objx[o], maps.objy[o]

			if not p.carried
				maps.removeObjectFromBlockmap(o)
				maps.objblockmap[o] = false

				local dx = objdx[o]
				if dx and moveObjectHorizontally(o, dx) continue end

				local dy = objdy[o]
				if dy and moveObjectVertically(o, dy) continue end

				maps.objblockmap[o] = true
				maps.insertObjectInBlockmap(o)
			end

			local o2 = p.carry
			if o2
				maps.removeObjectFromBlockmap(o2)
				maps.objblockmap[o2] = false

				local dx = maps.objx[o] - prevx
				local newx = maps.objx[o2] + dx
				if dx and moveObjectHorizontally(o2, dx) continue end

				local dy = maps.objy[o] - prevy
				local newy = maps.objy[o2] + dy
				if dy and moveObjectVertically(o2, dy) continue end

				maps.objblockmap[o2] = true
				maps.insertObjectInBlockmap(o2)

				if not (maps.objx[o2] == newx and maps.objy[o2] == newy)
					p.carry = nil
					maps.pp[objextra[o2]].carried = nil
				end
			end

			-- Friction
			if maps.playerOnGround(p)
				if maps.playerOnIce(p)
					if not p.spin
						if objdx[o] < 0
							objdx[o] = min($ + FU / 64, 0)
						elseif objdx[o] > 0
							objdx[o] = max($ - FU / 64, 0)
						end
					end
				elseif p.spin
					if objdx[o] < 0
						objdx[o] = min($ + FU / 16, 0)
					elseif objdx[o] > 0
						objdx[o] = max($ - FU / 16, 0)
					end
				else
					if objdx[o] < 0
						objdx[o] = min($ + FU / 8, 0)
					elseif objdx[o] > 0
						objdx[o] = max($ - FU / 8, 0)
					end
				end

				-- Stop spinning if the player is too slow
				if p.spin and abs(objdx[o]) < FU / 4
					maps.unspinPlayer(p)
				end
			end

			if p.fly ~= nil
				-- Flight gravity
				if p.fly ~= nil
					if p.fly ~= 0
						p.fly = $ - 1
						if p.fly == 0
							maps.setPlayerAnimation(p, "tired")
						end
					end
				end

				objdy[o] = min($ + maps.GRAVITY / 8, 6 * FU)
			elseif p.glide and objdy[o] >= 0
				-- Glide gravity
				if objdy[o] < maps.GRAVITY / 4
					objdy[o] = maps.GRAVITY / 4
				elseif objdy[o] > maps.GRAVITY / 4
					objdy[o] = max($ - maps.GRAVITY / 2, maps.GRAVITY / 4)
				end
			elseif not (p.climb or p.carried)
				-- Regular gravity
				objdy[o] = min($ + maps.GRAVITY, 6 * FU)
			end
		elseif t == maps.OBJ_BLUECRAWLA or t == maps.OBJ_REDCRAWLA
		or t == maps.OBJ_GREENSPRINGSHELL or t == maps.OBJ_YELLOWSPRINGSHELL
		or t == maps.OBJ_GREENSNAPPER
		or t == maps.OBJ_SHARP
			maps.removeObjectFromBlockmap(o)
			maps.objblockmap[o] = false

			local speed =
				t == maps.OBJ_BLUECRAWLA and FU / 4
				or t == maps.OBJ_REDCRAWLA and FU / 2
				or t == maps.OBJ_GREENSPRINGSHELL and FU / 2
				or t == maps.OBJ_YELLOWSPRINGSHELL and FU / 2
				or t == maps.OBJ_GREENSNAPPER and FU / 4
				or t == maps.OBJ_SHARP and FU / 4
			local dir = objdir[o] == 1 and -1 or 1
			if moveObjectHorizontally(o, speed * dir) continue end

			maps.objblockmap[o] = true
			maps.insertObjectInBlockmap(o)

			if (t == maps.OBJ_GREENSPRINGSHELL or t == maps.OBJ_YELLOWSPRINGSHELL) and maps.objanim[o] == 2
				local a = maps.objectproperties[t].anim[2]
				if maps.objspr[o] == (#a + 1) * a.spd - 1 -- Last frame
					setObjectAnimation(o, 1)
				end
			end

			-- Check ground borders
			if (maps.objy[o] + maps.objh[o]) % maps.BLOCK_SIZE == 0 -- Feet exactly on tile bottom
			and maps.objy[o] < maps.map.h * maps.BLOCK_SIZE - maps.objh[o] -- Feet not at bottom of the map
				local x = (maps.objx[o] + maps.objw[o] / 2) / maps.BLOCK_SIZE
				local y = (maps.objy[o] + maps.objh[o]) / maps.BLOCK_SIZE

				local i = x + y * maps.map.w + 1
				local tile = maps.map1[i]
				if not maps.tileground[tile]
					local t = maps.tiletype[tile]
					if t == 1 and maps.tileinfo[i] >> 4 == 0
						objdir[o] = $ == 1 and 2 or 1
					end
				end
			end
		elseif t == maps.OBJ_GOLDBUZZ or t == maps.OBJ_REDBUZZ
			maps.removeObjectFromBlockmap(o)
			maps.objblockmap[o] = false

			local dx = objdx[o]
			if dx and moveObjectHorizontally(o, dx) continue end

			local dy = objdy[o]
			if dy and moveObjectVertically(o, dy) continue end

			maps.objblockmap[o] = true
			maps.insertObjectInBlockmap(o)

			-- Chase target
			local speed = t == maps.OBJ_GOLDBUZZ and FU or FU * 2
			local target = objextra[o]
			local dist = max(P_AproxDistance(maps.objx[target] - maps.objx[o], maps.objy[target] - maps.objy[o]), 1)
			objdx[o] = FixedMul(FixedDiv(maps.objx[target] - maps.objx[o], dist), speed)
			objdy[o] = FixedMul(FixedDiv(maps.objy[target] - maps.objy[o], dist), speed)
			objdir[o] = objdx[o] < 0 and 1 or 2
		elseif t == maps.OBJ_ROBOFISH -- !!!
			maps.removeObjectFromBlockmap(o)
			maps.objblockmap[o] = false

			local dx = objdx[o]
			if dx and moveObjectHorizontally(o, dx) continue end

			local dy = objdy[o]
			if dy and moveObjectVertically(o, dy) continue end

			maps.objblockmap[o] = true
			maps.insertObjectInBlockmap(o)

			objdy[o] = min($ + maps.GRAVITY, 6 * FU) -- Gravity

			if objdy[o] < 0
				if maps.objanim[o] ~= 1
					setObjectAnimation(o, 1)
				end
			else
				if maps.objanim[o] ~= 2
					setObjectAnimation(o, 2)
				end

				if objdy[o] > 5 * FU
					objdy[o] = -5 * FU
				end
			end
		elseif t == maps.OBJ_SPILLEDRING
			maps.removeObjectFromBlockmap(o)
			maps.objblockmap[o] = true

			local dx = objdx[o]
			if dx and moveObjectHorizontally(o, dx) continue end

			local dy = objdy[o]
			if dy and moveObjectVertically(o, dy) continue end

			maps.objblockmap[o] = true
			maps.insertObjectInBlockmap(o)

			objdy[o] = min($ + maps.GRAVITY, 6 * FU) -- Gravity

			-- Disappear after some time
			if objextra[o] > 1
				objextra[o] = $ - 1
			else
				maps.removeObject(o)
				continue -- Object removed
			end
		elseif t == maps.OBJ_THOK
			-- Disappear after some time
			if objextra[o] > 1
				objextra[o] = $ - 1
			else
				maps.removeObject(o)
				continue -- Object removed
			end
		else
			print("Unknown object type "..t.."!") -- !!!
		end

		loopObjectAnimation(o)
	end
end

function maps.objectsInArea(x1, y1, x2, y2)
	local objx, objy = maps.objx, maps.objy
	local objw, objh = maps.objw, maps.objh

	for o = 1, #maps.objtype
		if maps.objtype[o]
		and objx[o] + objw[o] > x1
		and objx[o] <= x2
		and objy[o] + objh[o] > y1
		and objy[o] <= y2
			return true
		end
	end
end

function maps.objectsAtPosition(x, y)
	return maps.objectsInArea(
		(x - 1) * maps.BLOCK_SIZE,
		(y - 1) * maps.BLOCK_SIZE,
		x * maps.BLOCK_SIZE - 1,
		y * maps.BLOCK_SIZE - 1)
end

function maps.handleObjectDespawn()
	if maps.objectticker > #maps.objtype
		maps.objectticker = 1
	end
	if maps.objectticker <= #maps.objtype and maps.objtype[maps.objectticker] and maps.objtype[maps.objectticker] ~= 1
		local objx, objy = maps.objx, maps.objy
		local objw, objh = maps.objw, maps.objh
		local x1, y1 = objx[maps.objectticker] - maps.MAX_OBJECT_DIST, objy[maps.objectticker] - maps.MAX_OBJECT_DIST
		local x2, y2 = objx[maps.objectticker] + objw[maps.objectticker] + maps.MAX_OBJECT_DIST, objy[maps.objectticker] + objh[maps.objectticker] + maps.MAX_OBJECT_DIST

		local unused = true
		for i = 1, #maps.pp
			local p = maps.pp[i]
			if p.builder continue end

			local px, py
			local pw, ph
			if p.dead
				px, py = p.x, p.y
				pw, ph = maps.PLAYER_WIDTH, maps.PLAYER_HEIGHT
			else
				local o = p.obj
				px, py = objx[o], objy[o]
				pw, ph = objw[o], objh[o]
			end

			if px + pw > x1
			and px < x2
			and py + ph > y1
			and py < y2
				unused = false
				break
			end
		end

		if unused
			maps.removeObject(maps.objectticker)
		end
	end
	maps.objectticker = $ + 1
	if maps.objectticker > #maps.objtype
		maps.objectticker = 1
	end
end

addHook("NetVars", function(n)
	maps.objectticker = n($)

	maps.objtype = n($)
	maps.objx = n($)
	maps.objy = n($)
	maps.objw = n($)
	maps.objh = n($)
	maps.objdx = n($)
	maps.objdy = n($)
	maps.objdir = n($)
	maps.objanim = n($)
	maps.objspr = n($)
	maps.objspawn = n($)
	maps.objcolor = n($)
	maps.objblockmap = n($) -- !!!
	maps.objextra = n($)
	-- !!!!
	-- ...
end)
