-- Simple implementation of a Huffman coding algorithm
-- For compressing the map layers when sending the gamestate to joiners
--
-- Currently assumes the table indexes are indexed
-- and the values range from 0 to 65535 at most


local bs = ljrequire "bytestream"


local maxcodelen = 16


local function countUsedValues(values)
	-- Count how many times each value is used
	local uses = {}
	local usedvalues = {}
	for i = 0, #values do
		local value = values[i]

		if not uses[value] then
			uses[value] = 0
			usedvalues[#usedvalues + 1] = value
		end

		uses[value] = $ + 1
	end

	-- Sort values by number of uses
	local function sortValues(value1, value2)
		return uses[value1] > uses[value2]
	end
	table.sort(usedvalues, sortValues)

	return usedvalues, uses
end

-- Generates a binary probability tree
local function generateEncodingTree(usedvalues, uses, numvalues, valuelen)
	local valuecode = {}
	local valuecodelen = {}
	local code = 0
	local codelen = 0
	local maxcodelenmask = (1 << maxcodelen) - 1
	--local usedbits = 0 -- !!!

	local function split(i1, i2, range)
		if i1 == i2 then
			local value = usedvalues[i1]
			if codelen < maxcodelen or codelen == maxcodelen and code ~= maxcodelenmask then
				valuecode[value] = code
				valuecodelen[value] = codelen
				--usedbits = $ + uses[usedvalues[i1]] * codelen -- !!!
			else
				valuecode[value] = (maxcodelenmask << valuelen) | value
				valuecodelen[value] = maxcodelen + valuelen
				--usedbits = $ + uses[usedvalues[i1]] * (maxcodelen + valuelen) -- !!!
			end
			return
		end

		local half = range / 2
		local sum = 0
		for i = i1, i2 do
			sum = $ + uses[usedvalues[i]]
			if sum >= half then
				code = $ << 1
				codelen = $ + 1

				split(i1, i, sum)

				code = $ | 1
				split(i + 1, i2, range - sum)

				codelen = $ - 1
				code = $ >> 1

				break
			end
		end
	end

	split(1, #usedvalues, numvalues)

	return valuecode, valuecodelen
end

local function writeUsedValues(stream, usedvalues, uses)
	local writeUInt16 = bs.writeUInt16

	for i = 1, #usedvalues do
		local value = usedvalues[i]
		writeUInt16(stream, uses[value])
		writeUInt16(stream, value)
	end

	writeUInt16(stream, 0)
end

function maps.writeHuffman(stream, values, valuelen)
	local usedvalues, uses = countUsedValues(values)

	writeUsedValues(stream, usedvalues, uses)

	local valuecode, valuecodelen = generateEncodingTree(usedvalues, uses, #values + 1, valuelen)

	--usedbits = $ + #compressedvalues * 8
	--print(usedbits.." bits used VS "..(numvalues * 12).." bits uncompressed ("..((numvalues * 12 - usedbits) * 100 / (numvalues * 12)).."% compression)")

	local writeUInt = bs.writeUInt
	for i = 0, #values do
		local value = values[i]
		writeUInt(stream, valuecodelen[value], valuecode[value])
	end
end


-- Retrieves how many times each value is used
local function readUsedValues(stream)
	local usedvalues, uses = {}, {}

	local i = 1
	local readUInt16 = bs.readUInt16
	while true do
		local numuses = readUInt16(stream)
		if numuses == 0 then break end
		uses[i] = numuses
		usedvalues[i] = readUInt16(stream)
		i = i + 1
	end

	return usedvalues, uses
end

-- Generates a binary probability tree
local function generateDecodingTree(usedvalues, uses, numvalues)
	local codes = {}
	local code = 0
	local codelen = 0
	local maxcodelenmask = (1 << maxcodelen) - 1

	local function split(i1, i2, range, tree)
		if codelen > maxcodelen
		or codelen == maxcodelen and code == maxcodelenmask then
			tree[1] = false
			return
		elseif i1 == i2 then
			tree[1] = usedvalues[i1]
			return
		end

		local half = range / 2
		local sum = 0
		for i = i1, i2 do
			sum = $ + uses[i]
			if sum >= half then
				code = $ << 1
				codelen = $ + 1

				tree[1] = {}
				split(i1, i, sum, tree[1])

				code = $ | 1
				tree[2] = {}
				split(i + 1, i2, range - sum, tree[2])

				codelen = $ - 1
				code = $ >> 1

				break
			end
		end
	end

	split(1, #usedvalues, numvalues, codes)

	return codes
end

function maps.readHuffman(stream, numvalues, valuelen, values)
	values = $ or {}

	local usedvalues, uses = readUsedValues(stream)

	local codes = generateDecodingTree(usedvalues, uses, numvalues)

	local readBit = bs.readBit
	local readUInt = bs.readUInt
	for i = 0, numvalues - 1 do
		local tree = codes
		local codelen = 0

		while #tree ~= 1 do
			codelen = $ + 1
			tree = tree[readBit(stream) + 1]
		end

		local value = tree[1]
		if value ~= false then
			values[i] = value
		else
			values[i] = readUInt(stream, valuelen)
		end
	end

	return values
end
