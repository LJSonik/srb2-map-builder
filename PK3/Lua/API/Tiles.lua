-- Todo:
-- Handle end statements properly


local class = ljrequire "ljclass"


local standardtilefields = {
	align    = true, anim = true, copy   = true, copyprev  = true,
	editonly = true, flip = true, h      = true, heightmap = true,
	hidden   = true, id   = true, noedit = true, offset    = true,
	scale    = true, w    = true,
}


local function addTile(rawdef)
	rawdef.anim = $ or rawdef[#rawdef]
	rawdef[#rawdef] = nil
	rawdef.id = $ or rawdef[1]
	rawdef[1] = nil
	rawdef.heightmap = $ or rawdef[2]
	rawdef[2] = nil

	if rawdef.copyprev then
		rawdef.copy = maps.tiledefs[#maps.tiledefs].id
		rawdef.copyprev = nil
	end
	if rawdef.copy then
		local copieddef = maps.tiledefs[rawdef.copy].raw
		for k, v in pairs(copieddef) do
			if rawdef[k] == nil and k ~= "copy" then
				rawdef[k] = v
			end
		end
	end

	local def = {}

	def.raw = rawdef
	def.index = #maps.tiledefs + 1
	maps.tiledefs[def.index] = def
	def.id = rawdef.id
	maps.tiledefs[def.id] = def

	--def.category = tiledefs.category
	--table.insert(maps.tilecategories[tiledefs.category], def.index)

	local heightmapid = rawdef.heightmap
	def.empty = (heightmapid == "empty")
	def.full = (heightmapid == "full")
	def.heightmap = maps.heightmaps[heightmapid]

	/*if type(def.pick) == "string"
		def.pick = maps.tiledefs[def.pick].index
	end
	if type(def.respawn) == "string" then
		def.respawn = maps.tiledefs[def.respawn].index
	end*/

	def.visible = not (rawdef.hidden or rawdef.editonly)
	def.visibleineditor = not rawdef.hidden

	def.spanw = rawdef.spanw or 1
	def.spanh = rawdef.spanh or 1
	def.editspanw = rawdef.editspanw or def.spanw
	def.editspanh = rawdef.editspanh or def.spanh

	-- Custom fields
	for k, v in pairs(rawdef) do
		if not standardtilefields[k] then
			def[k] = v
		end
	end

	maps.tiledefs_spawner   [def.index] = def.spawn or false
	maps.tiledefs_empty     [def.index] = def.empty
	maps.tiledefs_full      [def.index] = def.full
	maps.tiledefs_heightmapv[def.index] = def.heightmap.vertical
	maps.tiledefs_heightmaph[def.index] = def.heightmap.horizontal
	maps.tiledefs_flippedv  [def.index] = def.heightmap.vertical.flipped
	maps.tiledefs_flippedh  [def.index] = def.heightmap.horizontal.flipped

	def.noedit = rawdef.noedit

	return def
end

-- !!! Handle recursive layouts
local function addTileLayouts(tree)
	for _, node in ipairs(tree) do
		local nodetype = node.type
		if nodetype == "layout" then
			local layout = maps.TileGrid()
			local layoutdef = maps.tilelayoutdefs[node.layoutdefid]

			/*for tilenum = 1, layoutdef.numtiles
				if token.type == "tile" then
					table.insert(tileids, token.tileid)
				elseif token.type == "newtile"
					table.insert(tileids, token.tiledef.id)
				else
					error('invalid definition for layout "' .. layoutdef.id .. '"')
				end
			end

			if not (token and token.type == "end") then
				error('definition for layout "' .. layoutdef.id .. '" has no "end" statement')
			end*/

			for y = 1, layoutdef.h do
				for x = 1, layoutdef.w do
					local tileid
					local layoutslot = layoutdef[y][x]
					if type(layoutslot) == "string" then
						tileid = layoutslot
					elseif layoutslot == 0 then
						tileid = "air"
					else
						tileid = node[layoutslot].tiledefid
					end

					local slot = maps.TileGridSlot(x, y, tileid)
					layout:set(x, y, slot)
				end
			end

			table.insert(maps.tilelayouts, layout)
			layout.index = #maps.tilelayouts

			node.layout = layout
		elseif nodetype == "group" then
			addTileLayouts(node)
		end
	end
end

local function eatNextLine(parser)
	parser.pos = $ + 1
	parser.line = parser.lines[parser.pos]
	return parser.line
end

local function buildTree(tree, parser)
	while true do
		local line = eatNextLine(parser)

		local node
		if type(line) == "table" then
			node = {
				type = "tile",
				tiledefid = addTile(line).id
			}
		elseif type(line) == "string" then
			local _, _, id = line:find("^layout%s+(.+)")
			if id then
				node = {
					type = "layout",
					layoutdefid = id
				}
				buildTree(node, parser)
			elseif line == "group" then
				node = {
					type = "group"
				}
				buildTree(node, parser)
			elseif line == "end" then
				break
			else
				node = {
					type = "tile",
					tiledefid = line
				}
			end
		elseif line == nil then
			break
		else
			-- !!! error
		end

		tree[#tree + 1] = node
	end

	return tree
end

-- Parses tile properties
function maps.addTiles(lines)
	local parser = {
		lines = lines,
		pos = 0
	}

	local tree = {}
	buildTree(tree, parser)
	tree.categoryIndex = maps.tilecategories[lines.category].index

	addTileLayouts(tree)

	table.insert(maps.tiledeftrees, tree)

	maps.spritesnotloaded = true
end
