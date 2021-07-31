local gui = ljrequire "ljgui.common"


local Area = gui.extend(gui.Item)
gui.Area = Area


function Area:draw(v)
	self:drawChildren(v)
end
