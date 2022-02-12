---@class ljgui
local gui = ljrequire "ljgui.common"


---@class ljgui.Grid : ljgui.Area
---@field style ljgui.ItemStyle
local Grid, base = gui.extend(gui.Area)
gui.Grid = Grid


function Grid:__init()
	base.__init(self)

	self.numSlots = 0
	self.numColumns, self.numRows = 1, 0
	self.columnWidth, self.rowHeight = FU, FU
end

---@param slotIndex integer
---@return integer
---@return integer
function Grid:indexToGridPos(slotIndex)
	slotIndex = $ - 1
	local columns = self.numColumns

	return
		slotIndex % columns + 1,
		slotIndex / columns + 1
end

---@param num integer
function Grid:setNumColumns(num)
	self.numColumns = num
end

---@param width fixed_t
function Grid:setColumnWidth(width)
	self.columnWidth = width
end

---@param height fixed_t
function Grid:setRowHeight(height)
	self.rowHeight = height
end

---@param size fixed_t
function Grid:setSlotSize(size)
	self.columnWidth = size
	self.rowHeight = size
end

function Grid:setMargin()
end

---@param item ljgui.Item
function Grid:add(item)
	self.numRows = self.numSlots / self.numColumns + 1
	self.numSlots = $ + 1
	self:attach(item)

	local x, y = self:indexToGridPos(self.numSlots)
	x = self.left + (x - 1) * self.columnWidth
	y = self.top  + (y - 1) * self.rowHeight
	item:move(x, y)
end

function Grid:resizeToFit()
	self:resize(self.columnWidth * self.numColumns, self.rowHeight * self.numRows)
end
