local class = ljrequire "ljclass"


local Slot = class.localclass()
maps.TileGridSlot = Slot


function Slot:__init(x, y, tiledefid)
	self.x, self.y = x, y
	self.tiledefid = tiledefid
end

function Slot:getTiledef()
	return maps.tiledefs[self.tiledefid]
end


local Grid = class.localclass()
maps.TileGrid = Grid


function Grid:__init()
	self.width, self.height = 0, 0
end

function Grid:get(x, y)
	if self[x] then
		return self[x][y]
	else
		return nil
	end
end

function Grid:set(x, y, slot)
	self[x] = $ or {}
	self[x][y] = slot

	self.width = max($, x)
	self.height = max($, y)
end
