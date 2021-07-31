local gui = ljrequire "ljgui"


local FU = FRACUNIT


local Picker, base = gui.extend(gui.Area)
maps.PaletteColorPicker = Picker


function Picker:setup()
	self.cellSize = 4 * FU
	self:setSize(16 * self.cellSize, 16 * self.cellSize)
end

function Picker:handleEvents(cmd)
	cmd.forwardmove = 0
	cmd.sidemove = 0
	cmd.buttons = 0
end

function Picker:onMouseMove(mouse)
	local x = (mouse.x - self.cache_left) / self.cellSize
	local y = (mouse.y - self.cache_top) / self.cellSize
	self.pointedColor = x + y * 16
end

function Picker:onMouseLeave()
	self.pointedColor = nil
end

function Picker:onLeftMousePress(mouse)
	local color = self.pointedColor
	if color ~= nil and self.onColorPicked then
		self:onColorPicked(color)
	end
end

local function drawRectangleBorders(v, l, t, w, h, borderSize, color)
	l, t = l / FU, t / FU
	w, h = w / FU, h / FU
	local bs = borderSize / FU

	v.drawFill(l, t, w, bs, color) -- Top
	v.drawFill(l, t, bs, h, color) -- Left
	v.drawFill(l, t + h - bs, w, bs, color) -- Bottom
	v.drawFill(l + w - bs, t, bs, h, color) -- Right
end

function Picker:draw(v)
	local l, t = self.cache_left, self.cache_top
	local w, h = self.width, self.height
	local cellSize = self.cellSize

	local color = 0
	for y = t, t + 15 * cellSize, cellSize do
		for x = l, l + 15 * cellSize, cellSize do
			v.drawFill(
				x / FU,
				y / FU,
				cellSize / FU,
				cellSize / FU,
				color
			)

			color = $ + 1
		end
	end

	if self.pointedColor ~= nil then
		drawRectangleBorders(
			v,
			l + self.pointedColor % 16 * cellSize,
			t + self.pointedColor / 16 * cellSize,
			cellSize,
			cellSize,
			1 * FU,
			color
		)
	end

	self:drawChildren(v)
end
