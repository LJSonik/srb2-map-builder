local FU = FRACUNIT

local itempositions = {
	{ FU         ,   0    },
	{ FU * 7 / 10, -FU / 2},
	{  0         , -FU    },
	{-FU * 7 / 10, -FU / 2},
	{-FU         ,   0    },
	{-FU * 7 / 10,  FU / 2},
	{  0         ,  FU    },
	{ FU * 7 / 10,  FU / 2},
}


local function drawItem(v, owner, itemdef, menu, level, i, cx, cy)
	local x = cx + 48 * itempositions[i][1]
	local y = cy + 36 * itempositions[i][2]

	local seltime = menu.selectiontime
	local active = (level == menu.level)
	local selected = (menu.selecteditems[level] == i)
	local highlighted = selected and active and (not itemdef.instant or maps.time < seltime + TICRATE / 10)

	-- Draw bubble
	if active then
		local patch = v.cachePatch("MAPS_EDITOR_ACTIONBG")
		local hscale = FixedDiv(64, patch.width)
		local vscale = FixedDiv(16, patch.height)
		local color = SKINCOLOR_RED

		if highlighted then
			local selscale
			if itemdef.instant then
				selscale = FU * 5 / 4
			else
				selscale = maps.fadedInValueSin(FU, FU * 5 / 4, seltime, seltime + TICRATE / 2)
			end

			hscale = FixedMul($, selscale)
			vscale = FixedMul($, selscale)
			color = SKINCOLOR_KETCHUP
		end

		v.drawStretched(
			x + (patch.leftoffset - patch.width  / 2) * hscale,
			y + (patch. topoffset - patch.height / 2) * vscale,
			hscale,
			vscale,
			patch,
			0,
			v.getColormap(nil, color)
		)
	end

	-- Draw text
	local text = itemdef.text
	if type(text) == "function" then
		text = text(owner)
	end
	v.drawString(
		x / FU,
		y / FU - 3,
		text,
		(selected and V_YELLOWMAP or 0) | V_ALLOWLOWERCASE,
		"small-center"
	)

	-- Draw submenu
	if selected and not active and itemdef[1] then
		maps.drawWheelMenu(v, owner, itemdef, menu, level + 1, x, y)
	end
end

function maps.drawWheelMenu(v, owner, menudef, menu, level, cx, cy)
	level = $ or 1
	cx = $ or 160 * FU
	cy = $ or 100 * FU

	local sel = menu.selecteditems[level]

	if level == menu.level then
		for i, itempos in ipairs(itempositions) do
			if i ~= sel and menudef[i] then
				drawItem(v, owner, menudef[i], menu, level, i, cx, cy)
			end
		end
	end

	if sel then
		drawItem(v, owner, menudef[sel], menu, level, sel, cx, cy)
	end
end
