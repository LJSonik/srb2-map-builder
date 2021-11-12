local gui = ljrequire "ljgui.common"


---@class ljgui.Area : ljgui.Item
---@field style ljgui.ItemStyle
local Area = gui.extend(gui.Item)
gui.Area = Area


---@param style ljgui.ItemStyle
function Area:setStyle(style)
	self.style = style
end

function Area:draw(v)
	self:drawStyle(v, self.style)
	self:drawChildren(v)
end
