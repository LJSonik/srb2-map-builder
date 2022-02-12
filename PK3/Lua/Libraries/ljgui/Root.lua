---@class ljgui
local gui = ljrequire "ljgui.common"


---@class ljgui.Root : ljgui.Item
local Root, base = gui.extend(gui.Item)
gui.Root = Root


function Root:__init()
	base.__init(self)

	self:move(0, 0)
	self:resize(320*FU, 200*FU)

	local main = gui.Area()
	self.main = self:attach(main)
	main:move(0, 0)
	main:resize(320*FU, 200*FU)

	self.focusedItem = nil

	self.mouse = gui.Mouse()
	self.mouse:move(self.width / 2, self.height / 2)
end

function Root:update()
	local item = self.focusedItem
	if item and item.enabled and item.handleEvents then
		item:handleEvents()
	end

	self.mouse:update()
end

function Root:draw(v)
	self:drawChildren(v)
	self.mouse:draw(v)
end
