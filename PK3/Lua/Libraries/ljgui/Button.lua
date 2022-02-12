---@class ljgui
local gui = ljrequire "ljgui.common"


local FU = FRACUNIT


local defaultNormalStyle = {
	background = { type = "color", color = 31 },
	border = { type = "color", size = 1 * FU, color = 0 }
}

local defaultPointedStyle = {
	background = { type = "color", color = 16 },
	border = { type = "color", size = 1 * FU, color = 0 }
}

local defaultPressedStyle = {
	background = { type = "color", color = 0 },
	border = { type = "color", size = 1 * FU, color = 0 }
}


---@class Button : ljgui.Item
---
---@field pointed boolean
---@field pressed boolean
---@field text    string
---
---@field normalStyle  ljgui.ItemStyle
---@field pointedStyle ljgui.ItemStyle
---@field pressedStyle ljgui.ItemStyle
---
---@field onPress   function
---@field onRelease function
---@field onTrigger function
local Button, base = gui.extend(gui.Item)
gui.Button = Button


function Button:__init()
	base.__init(self)

	self.pointed = false
	self.pressed = false

	self.normalStyle = defaultNormalStyle
	self.pointedStyle = defaultPointedStyle
	self.pressedStyle = defaultPressedStyle
end

---@param style ljgui.ItemStyle
function Button:setNormalStyle(style)
	self.normalStyle = style
end

---@param style ljgui.ItemStyle
function Button:setPointedStyle(style)
	self.pointedStyle = style
end

---@param style ljgui.ItemStyle
function Button:setPressedStyle(style)
	self.pressedStyle = style
end

function Button:setText(text)
	self.text = text
end

function Button:press()
	self.pressed = true

	if self.onPress then
		self:onPress()
	end
end

function Button:release()
	self.pressed = false

	if self.onRelease then
		self:onRelease()
	end
end

function Button:trigger()
	if self.onTrigger then
		self:onTrigger()
	end
end

function Button:onLeftMousePress()
	self.pressed = true
end

function Button:onLeftMouseRelease()
	if self.pressed then
		self:trigger()
		self.pressed = false
	end
end

function Button:onMouseEnter()
	self.pointed = true
end

function Button:onMouseLeave()
	self.pointed = false
	self.pressed = false
end

function Button:draw(v)
	local style
	if self.pressed then
		style = self.pressedStyle
	elseif self.pointed then
		style = self.pointedStyle
	else
		style = self.normalStyle
	end
	self:drawStyle(v, style)

	local text = self.text
	if text then
		local x = self.left + self.width  / 2
		local y = self.top  + self.height / 2 - 2 * FU
		v.drawString(x, y, text, f, "small-fixed-center")
	end

	self:drawChildren(v)
end
