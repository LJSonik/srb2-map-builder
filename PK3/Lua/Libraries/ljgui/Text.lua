local gui = ljrequire "ljgui.common"


---@class Text : ljgui.Item
---
---@field text  string
---@field style ljgui.ItemStyle
local Text, base = gui.extend(gui.Item)
gui.Text = Text


function Text:__init()
	base.__init(self)

	self:ignoreMouse()
end

---@param text string
function Text:setText(text)
	self.text = text
end

---@param style ljgui.ItemStyle
function Text:setStyle(style)
	self.style = style
end

---@param v videolib
function Text:draw(v)
	self:drawStyle(v, self.style)

	local text = self.text
	if text then
		local x, y = self:getCenter()
		y = y - 2 * FU
		v.drawString(x, y, text, f, "small-fixed-center")
	end

	self:drawChildren(v)
end
