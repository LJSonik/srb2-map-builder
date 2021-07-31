local menulib = ljrequire "menulib"


local FU = FRACUNIT
local TILESIZE = maps.TILESIZE


local OFFSETX, OFFSETY = 0, 0


maps.spritesnotloaded = true
maps.renderscale = 16

-- Tile rendering properties
maps.tiledefs_visible         = {}
maps.tiledefs_visibleineditor = {}

maps.tiledefs_anim    = {}
maps.tiledefs_animspd = {}
maps.tiledefs_animlen = {}

maps.tiledefs_scale   = {}
maps.tiledefs_offsetx = {}
maps.tiledefs_offsety = {}

maps.tiledefs_flags = {}

maps.tiledefs_drawer = {}


function maps.setRenderScale(scale)
	-- Rescale the tile sprites if they are already loaded
	if not maps.spritesnotloaded then
		for i, def in ipairs(maps.tiledefs) do
			def.scale = $ / maps.renderscale * scale
			for frame = 1, #def.anim do
				def.offsetx[frame] = $ / maps.renderscale * scale
				def.offsety[frame] = $ / maps.renderscale * scale
			end

			maps.tiledefs_scale  [i] = def.scale
			maps.tiledefs_offsetx[i] = def.offsetx
			maps.tiledefs_offsety[i] = def.offsety
		end
	end

	maps.renderscale = scale
end

local function drawBox(v, x1, y1, x2, y2, p)
	local s1 = (y2 - y1) / p.height
	local s2 = (x2 - x1) / p.width

	if s2 > s1 then
		y1 = $ + p.topoffset * s1
		x2 = $ - p.width * s1 + FU + p.leftoffset * s1
		for x = x1 + p.leftoffset * s1, x2, p.width * s1 do
			v.drawScaled(x, y1, s1, p)
		end
		v.drawScaled(x2, y1, s1, p)
	else
		x1 = $ + p.leftoffset * s2
		y2 = $ - p.height * s2 + FU + p.topoffset * s2
		for y = y1 + p.topoffset * s2, y2, p.height * s2 do
			v.drawScaled(x1, y, s2, p)
		end
		v.drawScaled(x1, y2, s2, p)
	end
end

local function drawBlocksBox(v, x1, y1, x2, y2, size, p)
	local s = size / p.width

	for x = x1, x2 - size - size + FU, size do
		v.drawScaled(x, y1, s, p)
	end

	local x = x2 - size + FU
	for y = y1, y2 - size - size + FU, size do
		v.drawScaled(x, y, s, p)
	end

	local y = y2 - size + FU
	for x = x1 + size, x2 - size + FU, size do
		v.drawScaled(x, y, s, p)
	end

	for y = y1 + size, y2 - size + FU, size do
		v.drawScaled(x1, y, s, p)
	end
end

local function loadSprites(v)
	for _, def in ipairs(maps.tiledefs) do
		local rawdef = def.raw

		-- Sprite/animation
		def.anim = {}
		if type(rawdef.anim) == "string" then
			def.anim[1] = v.cachePatch(rawdef.anim)
			def.animspd = 1
		else
			local prefix = rawdef.anim.prefix or ""
			for i2, sprite in ipairs(rawdef.anim) do
				def.anim[i2] = v.cachePatch(prefix..sprite)
			end
			def.animspd = rawdef.anim.spd or 1
		end
		def.animlen = #def.anim * def.animspd
		local firstpatch = def.anim[1]

		-- Scale
		local scale = maps.renderscale
		if rawdef.scale ~= nil then
			scale = $ * rawdef.scale
		elseif rawdef.w ~= nil then
			scale = $ * rawdef.w / firstpatch.width
		elseif rawdef.h ~= nil then
			scale = $ * rawdef.h / firstpatch.height
		else
			scale = min(
				$ * TILESIZE * def.spanw / firstpatch.width,
				$ * TILESIZE * def.spanh / firstpatch.height
			)
		end
		def.scale = scale

		-- Flags
		def.flip = rawdef.flip
		def.flags = def.flip and V_FLIP or 0

		local align = rawdef.align or "bottom"
		def.align = align
		local bottomaligned = (align == "bottom" or align == "bottomleft"  or align == "bottomright")
		local    topaligned = (align == "top"    or align == "topleft"     or align == "topright"   )
		local   leftaligned = (align == "left"   or align == "bottomleft"  or align == "topleft"    )
		local  rightaligned = (align == "right"  or align == "bottomright" or align == "topright"   )

		-- Offset
		def.offsetx, def.offsety = {}, {}
		for frame = 1, #def.anim do
			local offsetx, offsety

			if rawdef.offset then
				if rightaligned then
					offsetx = (TILESIZE * def.spanw)
				elseif leftaligned then
					offsetx = 0
				else
					--offsetx = TILESIZE / 2
					offsetx = (TILESIZE * def.spanw) / 2
				end
				offsetx = $ * maps.renderscale

				if bottomaligned then
					offsety = (TILESIZE * def.spanh)
				elseif topaligned then
					offsety = 0
				else
					offsety = (TILESIZE * def.spanh) / 2
				end
				offsety = $ * maps.renderscale
			else
				local patch = def.anim[frame]

				if rightaligned then
					offsetx = (TILESIZE * def.spanw) * maps.renderscale - patch.width * scale
				elseif leftaligned then
					offsetx = 0
				else
					offsetx = ((TILESIZE * def.spanw) * maps.renderscale - patch.width * scale) / 2
				end
				if def.flip then
					offsetx = $ + (patch.width - patch.leftoffset + 1) * scale
				else
					offsetx = $ + patch.leftoffset * scale
				end

				if bottomaligned then
					offsety = (TILESIZE * def.spanh) * maps.renderscale - patch.height * scale
				elseif topaligned then
					offsety = 0
				else
					offsety = ((TILESIZE * def.spanh) * maps.renderscale - patch.height * scale) / 2
				end
				offsety = $ + patch.topoffset * scale
			end

			def.offsetx[frame] = offsetx
			def.offsety[frame] = offsety
		end

		def.on_draw = rawdef.on_draw

		maps.tiledefs_visible       [def.index] = def.visible
		maps.tiledefs_visibleineditor[def.index] = def.visibleineditor

		maps.tiledefs_anim   [def.index] = def.anim
		maps.tiledefs_animspd[def.index] = def.animspd
		maps.tiledefs_animlen[def.index] = def.animlen

		maps.tiledefs_scale  [def.index] = def.scale
		maps.tiledefs_offsetx[def.index] = def.offsetx
		maps.tiledefs_offsety[def.index] = def.offsety
		maps.tiledefs_flags  [def.index] = def.flags
		maps.tiledefs_drawer [def.index] = def.on_draw or false

		/*
		-- X-offset
		if tile[4] == nil
			maps.tiledefs_offsetx[def.index] = p.leftoffset * s + (TILESIZE * maps.renderscale - p.width * s) / 2
		elseif abs(tile[4]) < 256
			maps.tiledefs_offsetx[def.index] = tile[4] * maps.renderscale * FU / 8 + p.leftoffset * s
		else
			maps.tiledefs_offsetx[def.index] = tile[4] * maps.renderscale + p.leftoffset * s
		end

		-- Y-offset
		if tile[5] == nil
			maps.tiledefs_offsety[def.index] = p.topoffset * s + TILESIZE * maps.renderscale - p.height * s
		elseif abs(tile[5]) < 256
			maps.tiledefs_offsety[def.index] = tile[5] * maps.renderscale * FU / 8 + p.topoffset * s
		else
			maps.tiledefs_offsety[def.index] = tile[5] * maps.renderscale + p.topoffset * s
		end
		*/
	end

	for skinname, skin in pairs(maps.skindefs) do
		for _, anim in pairs(skin.anim) do
			for i = 1, anim.frames do
				anim[i] = v.getSprite2Patch(skinname, anim.sprite2, false, i - 1, 3)
			end
		end
		skin.icon = v.cachePatch($)
	end

	maps.spritesnotloaded = false
end

local function drawBackground(v, p, scrollx, scrolly)
	if maps.map.backgroundtype == 1 then -- Picture
		local background = maps.backgrounds[maps.map.background]

		if p.nobgpic then -- Show background option disabled
			if v.renderer() == "software" then
				local w, h = 320 * v.dupx(), 200 * v.dupy()
				v.drawFill((v.width() - w) / 2, (v.height() - h) / 2, w, h, (background.color or 0) | V_NOSCALESTART)
			else
				v.drawFill(nil, nil, nil, nil, background.color or 0)
			end
		else -- Enabled
			local pic = v.cachePatch(background.pic)
			local t = background.type
			if t == "centered" then
				local s = max(maps.SCREEN_WIDTH / pic.width, maps.SCREEN_HEIGHT / pic.height)
				v.drawScaled((maps.SCREEN_WIDTH - pic.width * s) / 2, 0, s, pic)
			elseif t == "tiled" then
				local s = background.scale or FU
				for y = 0, maps.SCREEN_HEIGHT - 1, pic.height * s do
					for x = 0, maps.SCREEN_WIDTH - 1, pic.width * s do
						v.drawScaled(x, y, s, pic)
					end
				end
			else -- Horizontally tiled by default
				local s = maps.SCREEN_HEIGHT / pic.height
				local offset = -((scrollx / 16 * maps.renderscale) % (pic.width * s))
				for x = offset, maps.SCREEN_WIDTH - 1, pic.width * s do
					v.drawScaled(x, 0, s, pic)
				end

				--local s = maps.SCREEN_HEIGHT / pic.height
				--for x = 0, maps.SCREEN_WIDTH - 1, pic.width * s do
				--	v.drawScaled(x, 0, s, pic)
				--end
			end
		end
	else -- Color
		if v.renderer() == "software" then
			local w, h = 320 * v.dupx(), 200 * v.dupy()
			v.drawFill((v.width() - w) / 2, (v.height() - h) / 2, w, h, maps.map.background | V_NOSCALESTART)
		else
			v.drawFill(nil, nil, nil, nil, maps.map.background)
		end
	end
end

local function drawBuilder(v, p, scrollx, scrolly)
	local owner = p.owner ~= nil and players[p.owner] or nil

	if p.builderx * TILESIZE < scrollx
	or p.builderx * TILESIZE >= scrollx + maps.SCREEN_WIDTH
	or p.buildery * TILESIZE < scrolly
	or p.buildery * TILESIZE >= scrolly + maps.SCREEN_HEIGHT then
		return
	end

	local drawx = OFFSETX + (p.builderx * TILESIZE - scrollx) * maps.renderscale
	local drawy = OFFSETY + (p.buildery * TILESIZE - scrolly) * maps.renderscale

	local cursorname = "MAPS_EDITOR_CURSOR"
	local tile = p.tile
	local i = p.builderx + p.buildery * maps.map.w
	if p.erase or p.erase == nil and maps.map[p.builderlayer][i] ~= 1 then
		cursorname = "MAPS_EDITOR_CURSOR_DELETE"
	else
		for layer = p.builderlayer + 1, 4 do
			if maps.map[layer][i] ~= 1 then
				cursorname = "MAPS_EDITOR_CURSOR_HIDE"
				break
			end
		end

		if tile ~= nil then
			local animframe = maps.time % maps.tiledefs_animlen[tile]
			animframe = $ / maps.tiledefs_animspd[tile] + 1

			v.drawScaled(
				drawx + maps.tiledefs_offsetx[tile][animframe],
				drawy + maps.tiledefs_offsety[tile][animframe],
				maps.tiledefs_scale[tile],
				maps.tiledefs_anim[tile][animframe],
				maps.tiledefs_flags[tile] | (maps.sinCycle(maps.time, 2, 8, TICRATE) << V_ALPHASHIFT)
			)
		end
	end

	local cursorsprite = v.cachePatch(cursorname)

	v.drawScaled(
		drawx,
		drawy,
		TILESIZE * maps.renderscale / cursorsprite.width,
		cursorsprite,
		0,
		v.getColormap(nil, owner and owner.skincolor or SKINCOLOR_RED)
	)
end

local function drawObjects(v, scrollx, scrolly)
	local objects = maps.objects
	local objectdefs = maps.objectdefs
	local renderscale = maps.renderscale

	for i = 1, #objects do
		local o = objects[i]
		if not o then continue end

		local t = o.type
		local def = objectdefs[t]
		local onDraw = def.on_draw

		if onDraw then
			onDraw(v, o, scrollx, scrolly)
		else
			local a = def.anim[o.anim] -- !!!
			local spr = v.cachePatch(a[o.spr / a.spd])

			local x = (o.l + o.w / 2 - scrollx) * renderscale
			local y = (o.b           - scrolly) * renderscale
			local leftoffset = spr.leftoffset
			local topoffset = spr.topoffset
			local scale = def.scale * renderscale

			-- !!!
			-- Objects seem to disappear too soon
			if x + (spr.width - leftoffset) * scale <= 0
			or x - leftoffset * scale >= maps.SCREEN_WIDTH
			or y + (spr.height - topoffset) * scale <= 0
			or y - topoffset * scale >= maps.SCREEN_HEIGHT then
				continue
			end

			local f = o.dir == 2 and V_FLIP or 0

			v.drawScaled(OFFSETX + x, OFFSETY + y, scale, spr, f, v.getColormap(nil, o.color))
		end
	end
end

local function drawDeadPlayers(v, scrollx, scrolly)
	for i = 1, #maps.pp do
		local p = maps.pp[i]
		if p.dead then
			local owner = p.owner ~= nil and players[p.owner] or nil

			local a = maps.skindefs[p.skin].anim["die"]
			local spr = a[1] -- !!! Death animations won't loop!

			local x = (p.x + maps.PLAYER_WIDTH / 2 - scrollx) * maps.renderscale
			local y = (p.y + maps.PLAYER_HEIGHT - scrolly) * maps.renderscale
			local leftoffset = spr.leftoffset
			local topoffset = spr.topoffset

			-- !!!
			-- Players seem to disappear too soon
			if x + (spr.width - leftoffset) * FU / 5 <= 0
			or x - leftoffset * FU / 5 >= maps.SCREEN_WIDTH
			or y + (spr.height - topoffset) * FU / 5 <= 0
			or y - topoffset * FU / 5 >= maps.SCREEN_HEIGHT then
				continue
			end

			-- !!! Direction isn't accounted for!
			v.drawScaled(OFFSETX + x, OFFSETY + y, FU / 5 * maps.renderscale, spr, 0, v.getColormap(nil, owner and owner.skincolor or SKINCOLOR_BLUE))
		end
	end
end

local function drawLayer(v, layernum, scrollx, scrolly, p)
	local cl = maps.client

	-- Let's use tons of locals so we speed up the renderer a little
	local TILESIZE = TILESIZE
	local tiledefs_visible = p.builder and maps.tiledefs_visibleineditor or maps.tiledefs_visible
	local tiledefs_anim    = maps.tiledefs_anim
	local tiledefs_animspd = maps.tiledefs_animspd
	local tiledefs_animlen = maps.tiledefs_animlen
	local tiledefs_scale   = maps.tiledefs_scale
	local tiledefs_offsetx = maps.tiledefs_offsetx
	local tiledefs_offsety = maps.tiledefs_offsety
	local tiledefs_flags   = maps.tiledefs_flags
	local tiledefs_anim    = maps.tiledefs_anim
	local tiledefs_drawer  = maps.tiledefs_drawer
	local map = cl and cl.map or maps.map
	local layer = map[layernum]
	local time = maps.time
	local drawScaled = v.drawScaled

	local x1 = scrollx / TILESIZE
	local leftmargin = min(1, x1)
	x1 = -(scrollx % TILESIZE + leftmargin * TILESIZE) * maps.renderscale

	local y1 = scrolly / TILESIZE
	local topmargin = min(1, y1)
	y1 = -(scrolly % TILESIZE + topmargin * TILESIZE) * maps.renderscale

	local x2 = (scrollx + maps.SCREEN_WIDTH / maps.renderscale - 1) / TILESIZE
	local rightmargin = min(1, map.w - 1 - x2)
	x2 = maps.SCREEN_WIDTH + rightmargin * TILESIZE * maps.renderscale

	local y2 = (scrolly + maps.SCREEN_HEIGHT / maps.renderscale - 1) / TILESIZE
	local bottommargin = min(1, map.h - 1 - y2)
	y2 = maps.SCREEN_HEIGHT + bottommargin * TILESIZE * maps.renderscale

	local i1 = scrollx / TILESIZE - leftmargin + (scrolly / TILESIZE - topmargin) * map.w
	local d = map.w - (x2 - x1 - 1) / (TILESIZE * maps.renderscale) - 1

	local i = i1
	for y = y1, y2 - 1, TILESIZE * maps.renderscale do
		for x = x1, x2 - 1, TILESIZE * maps.renderscale do
			local tile = layer[i]
			if tiledefs_visible[tile] then
				if tiledefs_drawer[tile] then
					tiledefs_drawer[tile](v, layer, x, y, i, layernum)
				else
					local animframe = time % tiledefs_animlen[tile]
					animframe = $ / tiledefs_animspd[tile] + 1

					drawScaled(
						x + tiledefs_offsetx[tile][animframe],
						y + tiledefs_offsety[tile][animframe],
						tiledefs_scale[tile],
						tiledefs_anim[tile][animframe],
						tiledefs_flags[tile]
					)
				end
			end
			i = $ + 1
		end
		i = $ + d
	end
end

local function drawMapBorders(v, scrollx, scrolly)
	-- Left
	if scrollx > 0 then
		local w = -scrollx * maps.renderscale / FU
		v.drawFill(0, 0, w, 200, 31)
	end

	-- Right
	local mapright = maps.map.w * maps.TILESIZE
	local camright = scrollx + maps.SCREEN_WIDTH / maps.renderscale
	if camright > mapright then
		local w = (camright - mapright) * maps.renderscale / FU
		v.drawFill(320 - w, 0, w, 200, 31)
	end

	-- Top
	if scrolly < 0 then
		local h = -scrolly * maps.renderscale / FU
		v.drawFill(0, 0, 320, h, 31)
	end

	-- Bottom
	local mapbottom = maps.map.h * maps.TILESIZE
	local cambottom = scrolly + maps.SCREEN_HEIGHT / maps.renderscale
	if cambottom > mapbottom then
		local h = (cambottom - mapbottom) * maps.renderscale / FU
		v.drawFill(0, 200 - h, 320, h, 31)
	end
end

local function drawMap(v, p)
	local cl = maps.client

	local scrollx, scrolly
	if p.builder and cl then
		scrollx, scrolly = cl.scrollx, cl.scrolly
	else
		scrollx, scrolly = p.scrollx, p.scrolly
	end

	local visiblelayer = p.builder and p.visiblelayer or nil

	drawBackground(v, p, scrollx, scrolly)

	-- Background layer
	if not visiblelayer or visiblelayer == 1 then
		drawLayer(v, 1, scrollx, scrolly, p)
	end

	-- Collision background layer
	if not visiblelayer or visiblelayer == 2 then
		drawLayer(v, 2, scrollx, scrolly, p)
	end

	-- Draw objects
	drawObjects(v, scrollx, scrolly)

	-- Collision foreground layer
	if not visiblelayer or visiblelayer == 3 then
		drawLayer(v, 3, scrollx, scrolly, p)
	end

	-- Foreground layer
	if not visiblelayer or visiblelayer == 4 then
		drawLayer(v, 4, scrollx, scrolly, p)
	end

	drawDeadPlayers(v, scrollx, scrolly)

	-- Draw builders
	for i = 1, #maps.pp do
		local p = maps.pp[i]
		if p.builder then
			drawBuilder(v, p, scrollx, scrolly)
		end
	end

	drawMapBorders(v, scrollx, scrolly)

	-- Draw "true" HUD
	if p.builder then
		-- Draw selected layer
		/*local s
		if p.builderlayer == 2 or not p.tile or maps.tiledefs_type[p.tile] ~= 1
			s = "Layer "..p.builderlayer
		else
			s = "Layer 1 - "..(
				p.tiletype == 0 and "decorative"
				or p.tiletype == 1 and "solid"
				or p.tiletype == 2 and "platform"
			)
		end
		v.drawString(2, 194, s, V_ALLOWLOWERCASE, "small")*/

		-- !!!
		local text = "Layer "..p.builderlayer
		if (p.builderlayer == 2 or p.builderlayer == 3)
		and not maps.tiledefs_empty[p.tile] and not p.bothsolid then
			local otherlayer = (p.builderlayer == 2 and 3 or 2)
			text = $.." - layer "..otherlayer.." passable"
		end
		v.drawString(2, 194, text, V_ALLOWLOWERCASE, "small")
	else
		-- Draw ring count (experimental?)
		local o = p.obj
		local patchname = o.rings <= 0 and (maps.time / 5) & 1 and "STTRRING" or "STTRINGS"
		v.draw(6, 6, v.cachePatch(patchname), V_HUDTRANS)
		v.drawNum(102, 6, o.rings)
	end
end

function maps.drawGame(v, owner)
	if maps.spritesnotloaded then
		loadSprites(v)
	end

	local p = owner.maps and maps.pp[owner.maps.player]

	local neededrenderscale
	if p.builder then
		neededrenderscale = p.editorrenderscale
	else
		neededrenderscale = 16
	end
	if maps.renderscale ~= neededrenderscale then
		maps.setRenderScale(neededrenderscale)
	end

	if p then
		if not p.pickingtile or p.quickpickingtile then
			drawMap(v, p)
		end

		if p.editormenu then
			maps.drawWheelMenu(v, owner, maps.editormenudef, p.editormenu)
		elseif p.pickingtile then
			maps.drawTilePicker(v, p)
		end
	end

	if owner.menu then
		menulib.draw(v, owner, "maps")
	end

	maps.drawGui(v)

	-- Draw borders
	local screenw, screenh = v.width(), v.height()
	local gamew, gameh = 320 * v.dupx(), 200 * v.dupy()
	local borderw, borderh = (screenw - gamew) / 2, (screenh - gameh) / 2
	local borderflags = 31 | V_NOSCALESTART
	if borderw ~= 0 then
		v.drawFill(borderw + gamew, borderh, borderw, gameh, borderflags) -- Right
		v.drawFill(0, borderh, borderw, gameh, borderflags) -- Left
	end
	if borderh ~= 0 then
		v.drawFill(0, 0, screenw, borderh, borderflags) -- Top
		v.drawFill(0, borderh + gameh, screenw, borderh, borderflags) -- Bottom
	end
end


/*if not cpulib
	hud.add(function(v)
		if gamemap ~= 557 return end

		v.drawFill()

		v.drawString(4, 192, "Custom map")

		v.drawFill(160, 26, 1, 154, 0)
		v.drawFill(1, 26, 318, 1, 0)
		v.drawFill(1, 180, 318, 1, 0)

		local x, y = 60, 32
		for owner in players.iterate
			local p = owner.maps and maps.pp[owner.maps.player]

			v.drawString(x, y, owner.name, V_ALLOWLOWERCASE | ((not p or p.dead) and V_50TRANS or p.builder and (maps.time & 8 and V_GREENMAP or V_ORANGEMAP) or 0))

			local icon = maps.skindefs[p and p.skin or "sonic"].icon
			local flags = (not p or p.dead) and V_50TRANS or 0
			local color = v.getColormap(nil, owner.skincolor or SKINCOLOR_BLUE)
			v.drawScaled((x - 20) * FU, (y - 4) * FU, FU / 2, icon, flags, color)

			y = $ + 16
			if y > 160
				y = 32
				x = $ + 160
			end
		end
	end, "scores")
end*/
