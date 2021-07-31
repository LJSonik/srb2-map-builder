local standardtilefields = {
	align    = true, anim = true, copy   = true, copyprev  = true,
	editonly = true, flip = true, h      = true, heightmap = true,
	hidden   = true, id   = true, noedit = true, offset    = true,
	scale    = true, w    = true,
}


function maps.addPack()
end

function maps.endPack()
	/*for _, tiledefs in ipairs(addedtiledefs)
		--maps.addTilesToEditor(tiledefs)
		--maps.tilepickergrid = maps.TilePickerGrid()
		--maps.tilepickergrid:addTiles(tiledefs)
	end

	--maps.finaliseTilePicker()

	addedtiledefs = {}*/
end

function maps.addTileCategory(category)
	category.index = #maps.tilecategories + 1
	maps.tilecategories[category.index] = category
	maps.tilecategories[category.id] = category

	maps.addCategoryToEditor(category)
end

function maps.addHeightmap(heightmap)
	local heightmapv = {flipped = heightmap.ceiling}
	for i = 1, 32 do
		if heightmap.ceiling then
			heightmapv[i] = heightmap[i + 2]
		else
			heightmapv[i] = 32 - heightmap[i + 2]
		end
	end

	local heightmaph = {}
	if heightmapv[1] < heightmapv[32] then
		heightmaph.flipped = not heightmap.ceiling

		local highest = 32
		for x = 32 - 1, 0, -1 do
			local h = heightmapv[x + 1]
			for y = h, highest - 1 do
				heightmaph[y + 1] = x + 1
			end
			highest = h
		end

		for y = 0, highest - 1 do
			heightmaph[y + 1] = 0
		end
	else
		heightmaph.flipped = heightmap.ceiling

		local highest = 32
		for x = 0, 32 - 1 do
			local h = heightmapv[x + 1]
			for y = h, highest - 1 do
				heightmaph[y + 1] = x
			end
			highest = h
		end

		for y = 0, highest - 1 do
			heightmaph[y + 1] = 32
		end
	end

	for i = 1, 32 do
		heightmapv[i] = $ * maps.TILESIZE / 32
		heightmaph[i] = $ * maps.TILESIZE / 32

		if heightmapv.flipped then
			if heightmapv[i] == 0 then
				heightmapv[i] = INT32_MIN / 16 * 15
			end
		elseif heightmapv[i] == maps.TILESIZE then
			heightmapv[i] = INT32_MAX / 16 * 15
		end

		if heightmaph.flipped then
			if heightmaph[i] == 0 then
				heightmaph[i] = INT32_MIN / 16 * 15
			end
		elseif heightmaph[i] == maps.TILESIZE then
			heightmaph[i] = INT32_MAX / 16 * 15
		end
	end

	maps.heightmaps[heightmap[1]] = {
		id = heightmap[1],
		angle = FixedAngle(heightmap[2] * FRACUNIT),
		ceiling = heightmap.ceiling,

		vertical = heightmapv,
		horizontal = heightmaph
	}
end

function maps.addLayout(layoutdef)
	maps.tilelayoutdefs[layoutdef.id] = layoutdef

	layoutdef.w = #layoutdef[1]
	layoutdef.h = #layoutdef

	if layoutdef.splitx == nil then
		layoutdef.splitx = 0
	end
	if layoutdef.splity == nil then
		layoutdef.splity = 0
	end

	layoutdef.numtiles = 0
	for y, line in ipairs(layoutdef) do
		for x, slot in ipairs(line) do
			if type(slot) == "number" then
				layoutdef.numtiles = max($, slot)
			end
		end
	end
end

function maps.addSkin(skindef)
	maps.skindefs[skindef.id] = skindef
end
