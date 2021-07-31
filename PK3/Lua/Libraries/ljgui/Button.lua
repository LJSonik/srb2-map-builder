local gui = ljrequire "ljgui.common"


local FU = FRACUNIT


local Button, base = gui.extend(gui.Item)
gui.Button = Button


function Button:__init()
	base.__init(self)

	self.pressed = false

	self.borderSize = 1 * FU

	self.normalBackgroundColor = 31
	self.normalBorderColor = 0
	self.pressedBackgroundColor = 0
	self.pressedBorderColor = 0

	self.backgroundColor = self.normalBackgroundColor
	self.borderColor = self.normalBorderColor
end

function Button:setBackgroundColor(color)
	self.backgroundColor = color
end

function Button:setNormalBackgroundColor(color)
	self.normalBackgroundColor = color

	if not self.pressed then
		self.backgroundColor = color
	end
end

function Button:setPressedBackgroundColor(color)
	self.pressedBackgroundColor = color

	if self.pressed then
		self.backgroundColor = color
	end
end

function Button:setBorderSize(size)
	self.borderSize = size
end

function Button:setBorderColor(color)
	self.borderColor = color
end

function Button:setNormalBorderColor(color)
	self.normalBorderColor = color

	if not self.pressed then
		self.borderColor = color
	end
end

function Button:setPressedBorderColor(color)
	self.pressedBorderColor = color
	if self.pressed then
		self.borderColor = color
	end
end

function Button:setText(text)
	self.text = text
end

function Button:press()
	self.pressed = true

	self:setBackgroundColor(self.pressedBackgroundColor)
	self:setBorderColor(self.pressedBorderColor)

	if self.onPress then
		self:onPress()
	end
end

function Button:release()
	self.pressed = false

	self:setBackgroundColor(self.normalBackgroundColor)
	self:setBorderColor(self.normalBorderColor)

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
	self:trigger()
end

function Button:draw(v)
	local l, t = self.cache_left, self.cache_top
	local w, h = self.width, self.height

	local bgColor, borderColor
	if self.pressed then
		bgColor, borderColor = self.pressedBackgroundColor, self.pressedBorderColor
	else
		bgColor, borderColor = self.backgroundColor, self.borderColor
	end

	local bs = self.borderSize
	v.drawFill(l / FU, t / FU, w / FU, h / FU, self.borderColor)
	v.drawFill(
		(l + bs) / FU,
		(t + bs) / FU,
		(w - bs - bs) / FU,
		(h - bs - bs) / FU,
		self.backgroundColor
	)

	local text = self.text
	if text then
		local x = self.cache_left + self.width  / 2
		local y = self.cache_top  + self.height / 2 - 2 * FU
		v.drawString(x, y, text, f, "small-fixed-center")
	end

	self:drawChildren(v)
end
