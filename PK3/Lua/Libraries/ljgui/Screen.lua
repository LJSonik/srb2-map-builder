local gui = ljrequire "ljgui.common"


local Screen, base = gui.extend(gui.Item)
gui.Screen = Screen


function Screen:__init(v)
	base.__init(self)

	self:move(0, 0)
	self:setSize(320 * FRACUNIT, 200 * FRACUNIT)

	self.focusedItem = nil

	self.mouse = gui.Mouse()
	self.mouse:move(self.width / 2, self.height / 2)
end

function Screen:update()
	local item = self.focusedItem
	if item and item.enabled and item.handleEvents then
		item:handleEvents()
	end

	self.mouse:update()
end

function Screen:draw(v)
	self:drawChildren(v)
	self.mouse:draw(v)
end
