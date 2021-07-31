local gui = ljrequire "ljgui.common"


local Window, base = gui.extend(gui.Item)
gui.Window = Window


function Window:draw(v)
	base.__init(self)

	v.drawFill(self.l, self.t, self.w, self.h, self.color)
	self:drawChildren(v)
end
