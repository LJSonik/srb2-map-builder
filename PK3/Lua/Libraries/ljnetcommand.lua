-- By LJ Sonic


local nc = {}


local bs = ljrequire "bytestream"


if ljnetcommandid == nil then
	rawset(_G, "ljnetcommandid", -1)
end


local netcommands = {}


function nc.add(func)
	ljnetcommandid = $ + 1
	netcommands[ljnetcommandid] = func
	return ljnetcommandid
end

function nc.prepare(id)
	local stream = bs.create()
	bs.writeUInt(stream, 12, id)
	return stream
end

function nc.send(sender, stream)
	local chars = {}
	bs.seekStart(stream)
	local left = bs.totalBitLen(stream) - bs.totalBitOffset(stream)

	-- Encode in base64
	while left > 0 do
		local b
		if left >= 6 then
			b = bs.readUInt(stream, 6)
			left = $ - 6
		else
			b = bs.readUInt(stream, left)
			b = b << (6 - left)
			left = 0
		end

		if b <= 25 then
			b = b + 65
		elseif b <= 51 then
			b = b + 71
		elseif b <= 61 then
			b = b - 4
		elseif b == 62 then
			b = 43
		elseif b == 63 then
			b = 47
		end
		table.insert(chars, b)
	end

	COM_BufInsertText(sender, "_ljnc " .. bs.bytesToString(chars))
end


COM_AddCommand("_ljnc", function(sender, s)
	-- Decode base64
	local stream = bs.create()
	for i = 1, #s do
		local c = s:sub(i, i):byte()

		if c >= 65 and c <= 90 then -- Uppercase
			bs.writeUInt(stream, 6, c - 65)
		elseif c >= 97 and c <= 122 then -- Lowercase
			bs.writeUInt(stream, 6, c - 71)
		elseif c >= 48 and c <= 57 then -- Digits
			bs.writeUInt(stream, 6, c + 4)
		elseif c == 43 then -- +
			bs.writeUInt(stream, 6, 62)
		elseif c == 47 then -- /
			bs.writeUInt(stream, 6, 63)
		end
	end

	--local gaplen = (bs.totalBitLen(stream) - 12) % 8
	--bs.writeUInt(stream, gaplen, 0)

	stream = bs.share($)
	bs.seekStart(stream)

	local id = bs.readUInt(stream, 12)

	netcommands[id](sender, stream)
end)


return nc
