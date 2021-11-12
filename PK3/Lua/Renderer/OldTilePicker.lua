local FU = FRACUNIT
local TILESIZE = maps.TILEPICKER_TILESIZE
local GAP_SIZE = maps.TILEPICKER_GAP_SIZE


local HIGHLIGHT_SCALE = 2 * FU


local function drawTileCategoryPicker(v, p)
	v.drawFill()

	local n = #maps.tilecategories
	local category = p.category

	local i = 1
	local stepsize = (TILESIZE + GAP_SIZE) * FU
	for y = TILESIZE / 2 * FU, maps.SCREEN_HEIGHT - stepsize, stepsize do
		for x = TILESIZE / 2 * FU, maps.SCREEN_WIDTH - stepsize, stepsize do
			if i > n then break end

			local icon = v.cachePatch(maps.tilecategories[i].icon)
			local scale = TILESIZE * FU / max(icon.width, icon.height)
			if category ~= i then
				v.drawScaled(
					x + (TILESIZE * FU - icon.width  * scale) / 2 + icon.leftoffset * scale,
					y + (TILESIZE * FU - icon.height * scale) / 2 + icon.topoffset  * scale,
					scale,
					icon,
					V_50TRANS
				)
			else
				local highlightscale = maps.sinCycle(maps.time, FU, HIGHLIGHT_SCALE, TICRATE)
				local extrasize = (TILESIZE * highlightscale - TILESIZE * FU) / 2
				scale = FixedMul($, highlightscale)

				v.drawScaled(
					x + (TILESIZE * highlightscale - icon.width  * scale) / 2 - extrasize + icon.leftoffset * scale,
					y + (TILESIZE * highlightscale - icon.height * scale) / 2 - extrasize + icon.topoffset  * scale,
					scale,
					icon,
					maps.sinCycle(maps.time, 5, 0, TICRATE) << V_ALPHASHIFT
				)
			end

			i = $ + 1
		end
		if i > n then break end
	end

	local s = maps.tilecategories[category].name
	v.drawString(160 - v.stringWidth(s, V_ALLOWLOWERCASE) / 2, 188, s, V_ALLOWLOWERCASE)
end

function maps.drawTilePicker(v, p)
	if maps.tilepickerdirty then
		maps.finaliseTilePicker()
	end

	if p.pickingcategory then
		drawTileCategoryPicker(v, p)
		return
	end

	local boxleft, boxtop
	local boxwidth, boxheight
	local grid
	if p.quickpickingtile then
		grid = p.tilegrid

		boxwidth = GAP_SIZE + 3 * (TILESIZE + GAP_SIZE)
		boxheight = boxwidth
	else
		grid = maps.tilecategories[p.category].grid

		boxwidth  = maps.SCREEN_WIDTH  / FU
		boxheight = maps.SCREEN_HEIGHT / FU
	end

	boxleft = (maps.SCREEN_WIDTH  / FU - boxwidth ) / 2
	boxtop  = (maps.SCREEN_HEIGHT / FU - boxheight) / 2

	v.drawFill(boxleft, boxtop, boxwidth, boxheight, 31)

	local cursorx, cursory
	if p.quickpickingtile then
		cursorx, cursory = p.quickpickerx, p.quickpickery
	else
		cursorx, cursory = p.pickerx, p.pickery
	end

	for y = 1, #grid do
		for x = 1, #grid[y] do
			local defindex = grid[y][x]
			local def = maps.tiledefs[defindex]

			local drawx = (boxleft + GAP_SIZE + (x - 1) * (TILESIZE + GAP_SIZE)) * FU
			local drawy = (boxtop  + GAP_SIZE + (y - 1) * (TILESIZE + GAP_SIZE)) * FU

			if not (def and def.visibleineditor) then
				if x == cursorx and y == cursory then
					v.drawFill(drawx / FU, drawy / FU, TILESIZE, TILESIZE, 24)
				end

				continue
			end

			local animframe = (maps.time % def.animlen) / def.animspd + 1
			local sprite = def.anim[animframe]
			local flags = def.flags

			local offsetx = def.offsetx[animframe] * TILESIZE / maps.renderscale
			local offsety = def.offsety[animframe] * TILESIZE / maps.renderscale

			local scale = TILESIZE * def.scale / maps.renderscale

			if p.quickpickingtile then
				scale = $ / max(def.editspanw, def.editspanh)
			else
				drawx = $ + def.editspanw * GAP_SIZE * FU / 2
				drawy = $ + def.editspanh * GAP_SIZE * FU / 2

				drawx = $ + (def.editspanw - def.spanw) * (TILESIZE + GAP_SIZE) * FU / 2
				drawy = $ + (def.editspanh - def.spanh) * (TILESIZE + GAP_SIZE) * FU / 2
			end

			--drawx = $ + (TILESIZE * FU - sprite.width  * scale) / 2
			--drawy = $ + (TILESIZE * FU - sprite.height * scale) / 2

			if x == cursorx and y == cursory then
				local highlightscale = maps.sinCycle(maps.time, HIGHLIGHT_SCALE, FU, TICRATE)
				scale = FixedMul($, highlightscale)
				flags = $ | (maps.sinCycle(maps.time, 0, 5, TICRATE) << V_ALPHASHIFT)

				local extrasize = (highlightscale - FU) * TILESIZE / 2
				drawx = $ - extrasize + FixedMul(offsetx, highlightscale)
				drawy = $ - extrasize + FixedMul(offsety, highlightscale)
			else
				drawx = $ + offsetx
				drawy = $ + offsety

				flags = $ | V_50TRANS
			end

			v.drawScaled(drawx, drawy, scale, sprite, flags)
		end
	end

	/*local i = 1
	for y = 4 * FU, maps.SCREEN_HEIGHT - 12 * FU, 12 * FU
		for x = 4 * FU, maps.SCREEN_WIDTH - 12 * FU, 12 * FU
			if i > n break end

			local tile = category[i]
			local offsetx = 8 * maps.tiledefs_offsetx[tile] / maps.renderscale
			local offsety = 8 * maps.tiledefs_offsety[tile] / maps.renderscale
			local scale = 8 * maps.tiledefs_scale[tile] / maps.renderscale
			local sprite = maps.tiledefs_anim[tile][(maps.time % maps.tiledefs_animlen[tile]) / maps.tiledefs_animspd[tile] + 1]
			if pickertile ~= i
				drawScaled(
					x + offsetx,
					y + offsety,
					scale,
					sprite,
					maps.tiledefs_flags[tile] | V_50TRANS
				)
			else
				drawScaled(
					x - 2 * FU + offsetx * 3 / 2,
					y - 2 * FU + offsety * 3 / 2,
					scale * 3 / 2,
					sprite,
					maps.tiledefs_flags[tile]
				)
			end

			i = $ + 1
		end
		if i > n break end
	end

	local tile = category[pickertile]
	local s = maps.tiledefs_type[tile] ~= 1 and maps.tiletypenames[maps.tiledefs_type[tile]]
		or maps.tiledefs_defaulttype[tile] == 0 and "Decorative"
		or maps.tiledefs_defaulttype[tile] == 1 and "Solid"
		or maps.tiledefs_defaulttype[tile] == 2 and "Platform"
	v.drawString(160 - v.stringWidth(s, V_ALLOWLOWERCASE) / 2, 188, s, V_ALLOWLOWERCASE)*/
end
