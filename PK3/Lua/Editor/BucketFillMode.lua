local custominput = ljrequire "custominput"
local bs = ljrequire "bytestream"
local gui = ljrequire "ljgui"


local function isPosFillable(map, pos)
	for layernum = 1, 4 do
		if map[layernum][pos] ~= 1 then
			return false
		end
	end
	return true
end

local function bucketFill(map, p)
	if p.buildertile == nil then
		return
	end

	-- !!!
	if p.buildertile == 1 then
		return
	end

	local w, h = map.w, map.h

	local xs = { p.builderx }
	local ys = { p.buildery }
	local n = 1
	local i = 1
	local numfilled = 0

	while i <= n and numfilled <= 4096 do
		local x, y = xs[i], ys[i]
		local pos = x + y * w

		if isPosFillable(map, pos) then
			maps.setTile(p.builderlayer, pos, p.buildertile)
			numfilled = $ + 1

			if x > 0 then
				n = n + 1
				xs[n] = x - 1
				ys[n] = y
			end

			if x < w - 1 then
				n = n + 1
				xs[n] = x + 1
				ys[n] = y
			end

			if y > 0 then
				n = n + 1
				xs[n] = x
				ys[n] = y - 1
			end

			if y < h - 1 then
				n = n + 1
				xs[n] = x
				ys[n] = y + 1
			end
		end

		i = i + 1
	end
end


maps.addEditorMode{
	id = "bucket_fill",

	on_client_update = function(p, cmd)
		local cl = maps.client

		if not cl.inputeaten then
			if (cmd.buttons & BT_ATTACK and not (cl.prevbuttons & BT_ATTACK))
			or (cmd.buttons & BT_JUMP and not (cl.prevbuttons & BT_JUMP)) then
				bucketFill(cl.map, p)
				custominput.send(maps.prepareEditorCommand("bucket_fill"))
			end
		end

		local oldx, oldy = p.builderx, p.buildery
		if maps.handleClientEditorMovement(p, cmd)
		and (p.builderx ~= oldx or p.buildery ~= oldy) then
			local input = bs.create()
			bs.writeUInt(input, 2, 0) -- !!!
			maps.writeClientCursorMovement(input, p.builderx - oldx, p.buildery - oldy)
			custominput.send(input)
		end
	end,

	on_input_received = function(input, p)
		local inputtype = bs.readUInt(input, 2) -- !!!

		if inputtype == 3 then
			maps.receiveEditorCommand(input, p)
		else
			maps.readCursorMovement(input, p)
		end
	end,
}

maps.addEditorCommand("bucket_fill_mode", function(p)
	maps.enterEditorMode(p, "bucket_fill")
end)

maps.addEditorCommand("bucket_fill", function(input, p)
	bucketFill(maps.map, p)
end)
