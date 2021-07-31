local map2, map3, mapw, maph
local tiledefs_spawner

maps.addLocalsRefresher(function()
	map2, map3 = maps.map[2], maps.map[3]
	mapw, maph = maps.map.w, maps.map.h
	tiledefs_spawner = maps.tiledefs_spawner
end)


maps.MAX_OBJECT_DIST = 40 * maps.TILESIZE


function maps.checkSpawner(x, y, layer)
	local i = x + y * mapw

	-- Check if the enemy is still alive
	for oi = 1, #maps.objects do
		local o = maps.objects[oi]
		if o and o.spawn == i then return end
	end

	local tile = maps.map[layer][i]
	local tiledef = maps.tiledefs[tile]
	local t = tiledef.spawn
	local def = maps.objectdefs[t]

	local o = maps.spawnObject(
		t,
		x * maps.TILESIZE + maps.TILESIZE / 2,
		(y + 1) * maps.TILESIZE
	)

	o.dir = tiledef.flip and 2 or 1
	o.spawn = i
end

function maps.checkSpawnersInColumn(x, t, b)
	-- Don't go off limits
	if x < 0 or x >= mapw then
		return
	end
	if t < 0 then
		t = 0
	end
	if b > maph - 1 then
		b = maph - 1
	end

	local i = x + t * mapw
	for y = t, b do
		if tiledefs_spawner[map2[i]] then
			maps.checkSpawner(x, y, 2)
		end
		if tiledefs_spawner[map3[i]] then
			maps.checkSpawner(x, y, 3)
		end
		i = $ + mapw
	end
end

function maps.checkSpawnersInLine(y, l, r)
	-- Don't go off limits
	if y < 0 or y >= maph then
		return
	end
	if l < 0 then
		l = 0
	end
	if r > mapw - 1 then
		r = mapw - 1
	end

	local i = l + y * mapw
	for x = l, r do
		if tiledefs_spawner[map2[i]] then
			maps.checkSpawner(x, y, 2)
		end
		if tiledefs_spawner[map3[i]] then
			maps.checkSpawner(x, y, 3)
		end
		i = $ + 1
	end
end

function maps.checkSpawnersInArea(l, t, r, b)
	-- Don't go off the limits
	if l < 0 then
		l = 0
	end
	if r > mapw - 1 then
		r = mapw - 1
	end
	if t < 0 then
		t = 0
	end
	if b > maph - 1 then
		b = maph - 1
	end

	local d = mapw - (r - l + 1)
	local i = l + t * mapw
	for y = t, b do
		for x = l, r do
			if tiledefs_spawner[map2[i]] then
				maps.checkSpawner(x, y, 2)
			end
			if tiledefs_spawner[map3[i]] then
				maps.checkSpawner(x, y, 3)
			end
			i = $ + 1
		end
		i = $ + d
	end
end
