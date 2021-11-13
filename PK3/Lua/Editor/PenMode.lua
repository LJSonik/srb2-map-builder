local custominput = ljrequire "custominput"
local bs = ljrequire "bytestream"
local gui = ljrequire "ljgui"


maps.addEditorMode{
	id = "pen",

	on_enter = function(p)
		p.buildermode.penmode = 0
		p.buildermode.oldpenmode = 0
	end,

	on_client_update = function(p, cmd)
		local cl = maps.client
		local mode = p.buildermode

		updatePenMode(p, cmd)

		local oldx, oldy = p.builderx, p.buildery
		if maps.handleClientEditorMovement(p, cmd)
		and (p.builderx ~= oldx or p.buildery ~= oldy or mode.penmode ~= mode.oldpenmode) then
			local input = bs.create()
			bs.writeUInt(input, 2, mode.penmode)
			maps.writeClientCursorMovement(input, p.builderx - oldx, p.buildery - oldy)
			custominput.send(input)

			local tile
			if mode.penmode == 1 then
				if p.buildertilelayoutindex ~= nil then
					if not maps.tileLayoutConflictsWithMap(cl.map, p) then
						maps.placeTileLayout(cl.map, p)
					end
				elseif p.buildertile ~= nil then
					tile = p.buildertile
				end
			elseif mode.penmode == 2 then
				tile = 1
			else
				tile = nil
			end

			if tile ~= nil then
				maps.placeTilesInLine(
					cl.map,
					p,
					tile,
					oldx * maps.TILESIZE + maps.TILESIZE / 2,
					oldy * maps.TILESIZE + maps.TILESIZE / 2,
					p.builderx * maps.TILESIZE + maps.TILESIZE / 2,
					p.buildery * maps.TILESIZE + maps.TILESIZE / 2
				)
			end
		end

		if mode.penmode == 1 and p.buildertilelayoutindex ~= nil then
			mode.penmode = 0
		end

		mode.oldpenmode = mode.penmode
	end,

	on_input_received = function(input, p)
		local mode = p.buildermode
		local inputtype = bs.readUInt(input, 2)

		if inputtype == 3 then
			maps.receiveEditorCommand(input, p)
		else
			local oldx, oldy = p.builderx, p.buildery
			mode.penmode = inputtype

			maps.readCursorMovement(input, p)

			local tile
			if mode.penmode == 1 then
				if p.buildertilelayoutindex ~= nil then
					if not maps.tileLayoutConflictsWithMap(maps.map, p) then
						maps.placeTileLayout(maps.map, p)
					end
				elseif p.buildertile ~= nil then
					tile = p.buildertile
				end
			elseif mode.penmode == 2 then
				tile = 1
			else
				tile = nil
			end

			if tile ~= nil then
				maps.placeTilesInLine(
					maps.map,
					p,
					tile,
					oldx * maps.TILESIZE + maps.TILESIZE / 2,
					oldy * maps.TILESIZE + maps.TILESIZE / 2,
					p.builderx * maps.TILESIZE + maps.TILESIZE / 2,
					p.buildery * maps.TILESIZE + maps.TILESIZE / 2
				)
			end
		end
	end,

	---@param key keyevent_t
	---@param p maps.Player
	---@return boolean
	on_key_down = function(key, p)
		if maps.handleClientEditorMovementKeyDown(key) then
			return true
		elseif key.name == "MOUSE1" then
			local cl = maps.client
			local mode = p.buildermode
			local pos = p.builderx + p.buildery * cl.map.w

			if cl.map[p.builderlayer][pos] ~= 1 then -- Tile under the cursor
				mode.penmode = 2 -- Erase
			elseif not maps.isStackFull(cl.map, pos) then
				mode.penmode = 1 -- Build
			end

			return true
		end
	end,

	---@param key keyevent_t
	---@param p maps.Player
	---@return boolean
	on_key_up = function(key, p)
		if maps.handleClientEditorMovementKeyUp(key) then
			return true
		elseif key.name == "MOUSE1" then
			p.buildermode.penmode = 0
			return true
		end
	end
}

maps.addEditorCommand("pen_mode", function(p)
	maps.enterEditorMode(p, "pen")
end)
