local class = ljrequire "ljclass"


local Slot = class.localclass()
maps.TilePickerGridSlot = Slot


function Slot:__init(x, y, tiledefid)
	self.x, self.y = x, y
	self.tiledefid = tiledefid
end

function Slot:getTiledef()
	return maps.tiledefs[self.tiledefid]
end


local Grid = class.localclass()
maps.TilePickerGrid = Grid


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

function Grid:isAreaFree(self, l, t, r, b)
	for x = l, r do
		for y = t, b do
			if self:get(x, y) then
				return false
			end
		end
	end

	return true
end

function Grid:findFreeArea(w, h)
	for t = 1, self.height + 1 do
		for l = 1, 20 - w + 1 do
			if self:isAreaFree(self, l, t, l + w - 1, t + h - 1) then
				return l, t
			end
		end
	end
end

function Grid:addTilesFromLayout(layout)
	local l, t = self:findFreeArea(layout.width, layout.height)

	for layouty = 1, layout.height do
		for layoutx = 1, layout.width do
			local tileid = layout:get(layoutx, layouty).tiledefid

			local x, y = l + layoutx - 1, t + layouty - 1

			local slot = Slot(x, y, tileid)
			slot.layout = layout
			slot.layoutx, slot.layouty = layoutx, layouty

			self:set(x, y, slot)
		end
	end
end

function Grid:addTiles(tree)
	for _, node in ipairs(tree) do
		if node.type == "tile" then
			local tiledef = maps.tiledefs[node.tiledefid]

			if not tiledef.noedit then
				local x, y = self:findFreeArea(1, 1)
				local slot = Slot(x, y, tiledef.index)
				self:set(x, y, slot)
			end
		elseif node.type == "layout" then
			self:addTilesFromLayout(node.layout)
		elseif node.type == "group" then
			self:addTiles(node)
		end
	end
end
