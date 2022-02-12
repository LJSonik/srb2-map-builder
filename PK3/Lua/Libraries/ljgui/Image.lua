---@class ljgui
local gui = ljrequire "ljgui.common"


---@class Image : ljgui.Item
---
---@field image  string
---@field style ljgui.ItemStyle
local Image, base = gui.extend(gui.Item)
gui.Image = Image


function Image:__init()
	base.__init(self)

	self.scale = FU
	self:ignoreMouse()
end

---@param image patch_t|string
function Image:setImage(image)
	self.image = image
end

---@param scale fixed_t
function Image:setScale(scale)
	self.scale = scale
end

---@param style ljgui.ItemStyle
function Image:setStyle(style)
	self.style = style
end

---@param v videolib
function Image:draw(v)
	self:drawStyle(v, self.style)

	local image = self.image
	if image then
		if type(image) == "string" then
			image = v.cachePatch(image)
			self.image = image
		end

		local x, y = self:getCenter()
		local scale = self.scale
		x = x - image.width  * scale / 2
		y = y - image.height * scale / 2

		v.drawScaled(x, y, scale, image)
	end

	self:drawChildren(v)
end
