-- For reference:
--
--       3
--   4       2
-- 5           1
--   6       8
--       7
--


local FU = FRACUNIT


local function getSelectedItem(menudef, left, right, up, down)
	local sel

	if left then
		if up then
			sel = 4
		elseif down then
			sel = 6
		else
			sel = 5
		end
	elseif right then
		if up then
			sel = 2
		elseif down then
			sel = 8
		else
			sel = 1
		end
	elseif up then
		sel = 3
	elseif down then
		sel = 7
	end

	if not menudef[sel] then
		sel = nil
	end

	return sel
end

local function getSelectedSubmenuDef(menudef, menu)
	for level = 2, menu.level do
		menudef = menudef[menu.selecteditems[level - 1]]
	end
	return menudef
end

function maps.openWheelMenu(owner)
	return {level = 1, selecteditems = {}}
end

function maps.closeWheelMenu(owner)
end

function maps.handleWheelMenu(menudef, menu, owner, t, bt, left, right, up, down)
	menudef = getSelectedSubmenuDef(menudef, menu)
	local sel = getSelectedItem(menudef, left, right, up, down)

	if not sel then
		menu.waituntilnoinput = nil
	elseif menu.waituntilnoinput then
		sel = nil
	end

	if menu.selecteditems[menu.level] ~= sel then
		menu.selecteditems[menu.level] = sel
		menu.selectiontime = maps.time
	end

	if bt & BT_SPIN and not (t.prevbuttons & BT_SPIN) then
		if menu.level == 1 then
			return true
		else
			menu.selecteditems[menu.level] = nil
			menu.level = $ - 1
			menu.selecteditems[menu.level] = nil
			menu.selectiontime = nil
			menu.waituntilnoinput = true
			return false
		end
	end

	if bt & BT_CUSTOM3 and not (t.prevbuttons & BT_CUSTOM3) then
		return true
	end

	if sel and menudef[sel].instant and maps.time >= menu.selectiontime + TICRATE / 2 then
		menu.selectiontime = maps.time
	end

	if sel then
		if menudef[sel].instant and maps.time == menu.selectiontime
		or maps.time >= menu.selectiontime + TICRATE / 2
		or bt & BT_JUMP and not (t.prevbuttons & BT_JUMP) then
			if menudef[sel].action then
				return menudef[sel].action(owner)
			elseif menudef[sel][1] then
				menu.selectiontime = nil
				menu.waituntilnoinput = true
				menu.level = $ + 1
			end
		end
	end

	return false
end
