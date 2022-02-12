---@class ljgui
local gui = ljrequire "ljgui.common"


---@class maps.LevelPropertiesWindow : ljgui.Item
---@field frameSize fixed_t
---@field frameColor integer
---@field content ljgui.Area
local Window, base = gui.extend(gui.Item)
gui.Window = Window


function Window:__init()
	base.__init(self)

	self.frameSize = 2 * FU
	self.frameColor = 31

	local content = gui.Area()
	self.content = self:attach(content)
end

function Window:setFrameSize(size)
	self.frameSize = size
end

function Window:setFrameColor(color)
	self.frameColor = color
end

function Window:onMove()
	self.content:move(self.left + self.frameSize, self.top + 8 * FU)
end

function Window:onResize()
	self.content:resize(self.width - 2 * self.frameSize, self.height - 8 - self.frameSize)
end

function Window:onLeftMousePress()
	self.dragged = true
end

function Window:onLeftMouseRelease()
	self.dragged = false
end

---@param mouse ljgui.Mouse
function Window:onMouseMove(mouse)
	if self.dragged then
		local dx = mouse.x - mouse.oldX
		local dy = mouse.y - mouse.oldY
		self:move(self.left + dx, self.top + dy)
	end
end

---@param v videolib
function Window:drawFrame(v)
	local l, t = self.left  / FU, self.top    / FU
	local w, h = self.width / FU, self.height / FU
	local bs = self.frameSize / FU
	local color = self.frameColor

	v.drawFill(l, t, w, 8, color) -- Top
	v.drawFill(l, t + bs, bs, h - bs, color) -- Left
	v.drawFill(l, t + h - bs, w, bs, color) -- Bottom
	v.drawFill(l + w - bs, t + bs, bs, h - bs, color) -- Right
end

---@param v videolib
function Window:draw(v)
	self:drawFrame(v)
	self:drawChildren(v)
end
