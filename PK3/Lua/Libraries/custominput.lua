-- TCP over ticcmd by LJ Sonic
-- Well, not quite. But whatever.
--
-- To anyone trying to understand what's going on here: I am sorry.
-- To anyone trying to understand that thing's purpose: I am sorry.
-- To anyone trying to understand how that thing works: I am sorry.
-- To anyone trying to understand why that thing works: I am sorry.
--
-- But. IT WORKS (well, to some extent anyway)


-- Todo:
-- Handle KeepBody
-- Handle mid-joiners
-- Handle quits
-- Handle mode switching
-- Wrap input in pcall when receiving


local ci = {}


local bs = ljrequire "bytestream"
local netcommand = ljrequire "ljnetcommand"


local ID_LEN = 10
local NUM_IDS = (1 << ID_LEN) - 1
local MAX_IDS = NUM_IDS * 3 / 4

local TICCMD_LEN = 55
local TICCMD_RECEIVED = 1

local NETCMD_LEN = 512

local MAGIC_BUTTONS = 13 | BT_WEAPONNEXT | BT_WEAPONPREV
	| BT_ATTACK | BT_CAMLEFT | BT_CAMRIGHT
	| BT_FIRENORMAL | BT_CUSTOM1 | BT_CUSTOM3


local inputstosend
local totalinputlentosend
local sentpackets
local nextid
local packetresendtime
local time

local streamscompressed = false
local packetnc

ci.connections = {}


local function isTiccmdMagic(cmd)
	return cmd.forwardmove == -38
		and cmd.sidemove == 21
		and cmd.angleturn | TICCMD_RECEIVED == 27435
		and cmd.aiming == -14953
		and cmd.buttons == MAGIC_BUTTONS
end

local function enchantTiccmd(cmd)
	cmd.forwardmove = -38
	cmd.sidemove = 21
	cmd.angleturn = 27435
	cmd.aiming = -14953
	cmd.buttons = MAGIC_BUTTONS
end

/*local function cmpPacketIds(a, b)
	local d = a - b

	if d < -32
		return d + NUM_IDS
	elseif d > 32
		return d - NUM_IDS
	else
		return d
	end
end*/

local function idInRange(id, a, b)
	a = a % NUM_IDS
	b = b % NUM_IDS

	if a <= b then
		return (a <= id and id <= b)
	else
		return (a <= id or id <= b)
	end
end

local function copyStream(src, dst, numbytes, numbits)
	dst = dst or bs.create()

	if numbytes == nil and numbits == nil then
		numbits = 8 * src.bytelen + src.bitlen
		numbits = numbits - 8 * (src.byteoffset - 1) - src.bitoffset
	else
		numbits = numbits + 8 * numbytes
	end

	local n = 8 - src.bitoffset
	if n ~= 8 and n <= numbits then
		bs.writeUInt(dst, n, bs.readUInt(src, n))
		numbits = numbits - n
	end

	for _ = 1, numbits / 8 do
		bs.writeByte(dst, bs.readByte(src))
	end
	numbits = numbits % 8

	if numbits ~= 0 then
		bs.writeUInt(dst, numbits, bs.readUInt(src, numbits))
	end

	return dst
end

local function sliceStream(src, dst, startbyte, startbit, endbyte, endbit)
	local bitlen = 8 * src.bytelen + src.bitlen

	if startbyte == nil then
		startbyte = 1
	end
	if startbit == nil then
		startbit = 0
	end
	if endbyte ~= nil then
		endbyte = (bitlen + 7) / 8
	end
	if endbit == nil then
		endbit = bitlen % 8 - 1
	end

	src = bs.create(src.bytes)
	src.byteoffset = startbyte
	src.bitoffset = startbit

	startbit = startbit + 8 * (startbyte - 1)
	endbit = endbit + 8 * (endbyte - 1)
	local numbits = endbit - startbit + 1

	copyStream(src, dst, numbits / 8, numbits % 8)
end

local function storeStreamInTiccmd(stream, cmd)
	-- Ensure there are 8 bytes, to make things simpler
	--for _ = stream.bytelen + 1, TICCMD_LEN / 8 + 1
	--	bs.writeByte(stream, 0)
	--end
	for _ = bs.totalBitLen(stream) + 1, TICCMD_LEN do
		bs.writeBit(stream, 0)
	end

	bs.seekStart(stream)

	-- forwardmove and sidemove can only range from -50 to 50,
	-- so we can only store 6 bits in each, not 8.
	-- In addition, the lowest bit in angleturn is overridden by SRB2,
	-- so we can only use it to store 15 bits (14 due to a bug).
	cmd.forwardmove = bs.readUInt(stream, 6) - 32
	cmd.sidemove = bs.readUInt(stream, 6) - 32
	--cmd.angleturn = (bs.readUInt(stream, 15) << 1) - 32768
	cmd.angleturn = (bs.readUInt(stream, 14) << 2) - 32768
	--cmd.aiming = bs.readUInt16(stream) - 32768
	cmd.aiming = bs.readUInt(stream, 14) - 8192
	cmd.buttons = bs.readUInt(stream, 15) | 32768

	/*enterfunc "storeStreamInTiccmd"
		pr(cmd.forwardmove)
		pr(cmd.sidemove)
		pr(cmd.angleturn)
		pr(cmd.aiming)
		pr(cmd.buttons)
	exitfunc "end storeStreamInTiccmd"*/
end

local function retrieveStreamFromTiccmd(stream, cmd)
	local stream = bs.create()

	/*enterfunc "retrieveStreamFromTiccmd"
		pr(cmd.forwardmove)
		pr(cmd.sidemove)
		pr(cmd.angleturn)
		pr(cmd.aiming)
		pr(cmd.buttons)
	exitfunc "end retrieveStreamFromTiccmd"*/

	bs.writeUInt(stream, 6, cmd.forwardmove + 32)
	bs.writeUInt(stream, 6, cmd.sidemove + 32)
	--bs.writeUInt(stream, 15, (cmd.angleturn + 32768) >> 1)
	bs.writeUInt(stream, 14, (cmd.angleturn + 32768) >> 2)
	--bs.writeUInt16(stream, cmd.aiming + 32768)
	bs.writeUInt(stream, 14, cmd.aiming + 8192)
	bs.writeUInt(stream, 15, cmd.buttons & ~32768)

	bs.seekStart(stream)

	return stream
end

local function addInput(input, packet, maxpacketlen)
	local inputlen = bs.totalBitLen(input) - bs.totalBitOffset(input) + 1
	local freelen = maxpacketlen - bs.totalBitLen(packet)
	--pr()
	--pr("input len "..inputlen)
	--pr("free len "..freelen)

	if inputlen <= freelen then
		--pr("add whole input with len "..inputlen)
		--pr()

		bs.writeBit(packet, 0)

		-- Copy the whole input to the ticcmd
		copyStream(input, packet)
		totalinputlentosend = $ - (inputlen - 1)
		--pr("sub A " .. (inputlen - 1))
	else
		--pr("add split input with len "..freelen)
		--pr()

		bs.writeBit(packet, 1)
		freelen = $ - 1

		-- Copy a chunk from the input to the ticcmd
		copyStream(input, packet, freelen / 8, freelen % 8)
		totalinputlentosend = $ - freelen
		--pr("sub B " .. freelen)

		--local inputoffset = endbit + 1
		--input.byteoffset = inputoffset / 8 + 1
		--input.bitoffset = inputoffset % 8
	end
end

local function sendPacket(cmd)
	local packet
	local maxpacketlen
	if cmd then
		packet = bs.create()
		maxpacketlen = TICCMD_LEN
	else
		packet = netcommand.prepare(packetnc)
		maxpacketlen = NETCMD_LEN
	end

	bs.writeUInt(packet, ID_LEN, nextid)

	--local numshit = 0
	while inputstosend[1] and bs.totalBitLen(packet) + 2 < maxpacketlen do
		local input = inputstosend[1]

		local split = not (input.byteoffset == 1 and input.bitoffset == 0)
		if not split then
			bs.writeBit(packet, 1) -- Indicate there is more
		end

		--numshit = $ + 1
		addInput(input, packet, maxpacketlen)

		if bs.totalBitOffset(input) == bs.totalBitLen(input) then
			--pr("input sent")
			table.remove(inputstosend, 1)
		end

		--pr("inputs to send: " .. #inputstosend)
		--pr(totalinputlentosend)
		--pr()
	end
	--pr(numshit .. " inputs")

	if bs.totalBitLen(packet) < maxpacketlen then
		bs.writeBit(packet, 0) -- Indicate there is nothing more
	end

	if cmd then
		storeStreamInTiccmd(packet, cmd)
	else
		netcommand.send(consoleplayer, packet)
		packet.vianetcommand = true
	end

	packet.time = time
	sentpackets[nextid] = packet
	--pr("sent packet "..nextid.." at time "..time)
	--pstream(packet)
	nextid = ($ + 1) % NUM_IDS
end

local function sendNullTiccmd(cmd)
	local packet = bs.create()
	bs.writeUInt(packet, ID_LEN, NUM_IDS)
	storeStreamInTiccmd(packet, cmd)
end

local function tryResendPacket(cmd)
	local t = ci.connections[consoleplayer]

	if not idInRange(nextid, t.neededid, t.neededid + MAX_IDS - 1) then
		local packet = sentpackets[t.neededid]

		if packet.vianetcommand then
			if time > packet.time + TICRATE then
				netcommand.send(consoleplayer, packet)
				packet.time = time
			end

			sendNullTiccmd(cmd)
		else
			storeStreamInTiccmd(packet, cmd)
			packet.time = time
		end

		return true
	end

	if t.lastreceivedid == nil then return false end

	local id = t.neededid
	while true do
		local packet = sentpackets[id]

		if packet then
			if packet.vianetcommand then
				if time > packet.time + TICRATE then
					netcommand.send(consoleplayer, packet)
					packet.time = time

					sendNullTiccmd(cmd)

					return true
				end
			elseif packet.time <= packetresendtime then
				storeStreamInTiccmd(packet, cmd)
				packet.time = time

				return true
			end
		end

		if id == t.lastreceivedid then return false end
		id = ($ + 1) % NUM_IDS
	end
end

local function cleanupReceivedInput(t)
	local r = t.receivedinputreader
	local w = t.receivedinputwriter

	local n = r.byteoffset - 1

	local newbytes = {}
	local oldbytes = r.bytes
	for i = 1, #oldbytes - n do
		newbytes[i] = oldbytes[i + n]
	end

	r.bytes = newbytes
	w.bytes = newbytes
	r.byteoffset = 1
	w.byteoffset = $ - n
	r.bytelen = $ - n
	w.bytelen = $ - n
end

local function compressStreams()
	for _, t in pairs(ci.connections) do
		cleanupReceivedInput(t)

		t.receivedinputwriter.bytes = bs.bytesToString($)
		t.receivedinputreader.bytes = nil

		for _, packet in pairs(t.receivedpackets) do
			packet.bytes = bs.bytesToString($)
		end
	end

	streamscompressed = true
end

local function decompressStreams()
	for _, t in pairs(ci.connections) do
		t.receivedinputwriter.bytes = bs.stringToBytes($)
		t.receivedinputreader.bytes = t.receivedinputwriter.bytes

		for _, packet in pairs(t.receivedpackets) do
			packet.bytes = bs.stringToBytes($)
		end
	end

	streamscompressed = false
end

local function receivePacket(packet, p)
	if streamscompressed then
		decompressStreams()
	end

	local t = ci.connections[p]

	local w = t.receivedinputwriter
	local r = t.receivedinputreader

	local id = bs.readUInt(packet, ID_LEN)
	if id == NUM_IDS -- Null
	or t.receivedpackets[id] -- Duplicate
	or not idInRange(id, t.neededid, t.neededid + MAX_IDS - 1) then
		--pr "RECEIVED INVALID PACKET"
		return
	end

	t.receivedpackets[id] = packet
	--pr("received packet "..id)
	--pstream(packet)

	-- !!!!
	/*if p == consoleplayer and not sentpackets[id]
		error "FATAL ERROR: PACKET NOT SENT"
	end*/

	if t.lastreceivedid == nil
	or not idInRange(id, t.neededid, t.lastreceivedid) then
		--pr("last received id "..id)
		t.lastreceivedid = id
	end

	if p == consoleplayer then
		/*local xd = bs.share(packet)
		local lol = bs.share(sentpackets[id])
		bs.seekStart(xd)
		bs.seekStart(lol)
		xd = copyStream(xd)
		lol = copyStream(lol)
		if bs.bytesToString(xd.bytes) ~= bs.bytesToString(lol.bytes)
			pstream(xd)
			pstream(lol)
			--pr(string.byte(bs.bytesToString(xd.bytes)))
			--pr(bs.bytesToString(lol.bytes))
			pr 'OKAY WHAT THE FUCC??'
		end*/

		packetresendtime = max($, sentpackets[id].time - 1)
		--pr("resend time "..packetresendtime)
	end

	--pr()

	while t.receivedpackets[t.neededid] do
		--pr("appending packet "..t.neededid)

		local packet = t.receivedpackets[t.neededid]

		t.receivedpackets[t.neededid] = nil
		if p == consoleplayer then
			sentpackets[t.neededid] = nil
		end
		if t.neededid == t.lastreceivedid then
			t.lastreceivedid = nil
		end
		t.neededid = ($ + 1) % NUM_IDS

		if t.receivedinputsplit then
			t.receivedinputsplit = (bs.readBit(packet) == 1)
			/*if t.receivedinputsplit
				pr "continuing"
			else
				pr "finishing"
			end*/
			copyStream(packet, w)
			r.bytelen, r.bitlen = w.bytelen, w.bitlen
			if t.receivedinputsplit then return end
			/*if p == consoleplayer
				pr("inputs to send: " .. #inputstosend)
			end*/
			ci.receive(r, p)
		else
			copyStream(packet, w)
			r.bytelen, r.bitlen = w.bytelen, w.bitlen
		end

		-- !!!!
		--if r.byteoffset > 256 * 1024
		if r.byteoffset > 1024 then
			cleanupReceivedInput(t)
		end

		while not t.receivedinputsplit
		and not (r.byteoffset == w.byteoffset and r.bitoffset == w.bitoffset) do
			if bs.readBit(r) == 0 then -- Nothing after that?
				--pr "done reading"
				-- Anything we haven't read yet is garbage
				-- (ticcmds have fixed length)
				r.byteoffset = w.byteoffset
				r.bitoffset = w.bitoffset
			elseif bs.readBit(r) == 1 then
				--pr "input is split"
				t.receivedinputsplit = true
			else
				/*if p == consoleplayer
					("inputs to send: " .. #inputstosend)
				end*/
				ci.receive(r, p)
			end
		end
	end
end

function ci.start(p)
	if streamscompressed then
		decompressStreams()
	end

	local t = {}
	ci.connections[p] = t

	t.status = "waiting"

	t.receivedinputwriter = bs.create()
	t.receivedinputreader = bs.share(t.receivedinputwriter)
	t.receivedinputsplit = false

	t.receivedpackets = {}
	t.neededid = 0
	t.lastreceivedid = nil

	if p == consoleplayer then
		inputstosend = {}
		totalinputlentosend = 0
		sentpackets = {}
		nextid = 0
		packetresendtime = -1
		time = 0
	end
end

function ci.stop(p)
	if streamscompressed then
		decompressStreams()
	end

	ci.connections[p] = nil

	if p == consoleplayer then
		inputstosend = nil
		sentpackets = nil
	end
end

function ci.send(input)
	bs.seekStart(input)
	input.time = time
	table.insert(inputstosend, input)
	totalinputlentosend = $ + bs.totalBitLen(input)
end

-- Must be called from a PlayerCmd hook
function ci.handleSending(p, cmd)
	if not ci.connections[p] then return end
	local status = ci.connections[p].status
	if not status then return end

	--enterfunc "handleSending"

	cmd.forwardmove = 0
	cmd.sidemove = 0
	cmd.angleturn = 0
	cmd.aiming = 0
	cmd.buttons = 0

	if status == "ready" or status == "starting" then
		if not tryResendPacket(cmd) then
			sendPacket(cmd)
		end

		if inputstosend[1] and time > inputstosend[1].time + TICRATE / 2
		or totalinputlentosend > NETCMD_LEN then
			sendPacket()
		end
	elseif status == "waiting" then
		--pr "sent magic"
		enchantTiccmd(cmd)
	end

	time = $ + 1

	--exitfunc "handleSending end"
end

-- Must be called from a PreThinkFrame hook
function ci.handleReception(p)
	local t = ci.connections[p]
	if not (t and t.status) then return end
	local cmd = p.cmd

	if cmd.angleturn & TICCMD_RECEIVED == 1 then
		if t.status == "waiting" then
			if isTiccmdMagic(cmd) then
				t.status = "starting"
			end
		elseif t.status == "starting" then
			if not isTiccmdMagic(cmd) then
				t.status = "ready"
			end
		end

		if t.status == "ready" and cmd.buttons ~= 0 then
			local packet = retrieveStreamFromTiccmd(packet, cmd)
			receivePacket(packet, p)
		end
	end

	cmd.forwardmove = 0
	cmd.sidemove = 0
	cmd.angleturn = $ & TICCMD_RECEIVED
	cmd.aiming = 0
	cmd.buttons = 0
end


packetnc = netcommand.add(function(p, packet)
	local t = ci.connections[p]
	if t and t.status == "ready" then
		-- Truncate in case it's slightly too large
		if bs.totalBitLen(packet) > NETCMD_LEN then
			packet.bytelen = NETCMD_LEN / 8
			packet.bitlen = NETCMD_LEN % 8
		end
		/*for _ = bs.totalBitLen(packet) + 1, NETCMD_LEN
			bs.writeBit(packet, 0)
		end*/

		--pr "NETCMD"
		--pr("" .. (bs.totalBitLen(packet) - bs.totalBitOffset(packet)))

		--packet = copyStream($) -- !!!!
		--bs.seekStart(packet)

		receivePacket(packet, p)
	end
end)

addHook("PlayerQuit", ci.stop)

addHook("GameQuit", function()
	ci.connections = {}
	inputstosend = nil
	sentpackets = nil
end)

addHook("NetVars", function(n)
	compressStreams() -- Compress all streams to avoid gamestate bloat
	ci.connections = n($)
end)


return ci
