-- Todo:
-- Keyboard support
-- Layout support
-- Span


local gui = ljrequire "ljgui"
local custominput = ljrequire "custominput"
local bs = ljrequire "bytestream"


local TILE_SIZE = 8
local TILE_GAP = 2
local HIGHLIGHT_SCALE = 2 * FU

local CAT_SIZE = 16
local CAT_GAP = 8
local CAT_HIGHLIGHT_SCALE = 2 * FU


local function closeTilePicker()
	local picker = gui.screen.tilePicker
	picker:unfocus()
	picker:detach()
	gui.screen.tilePicker = nil

	maps.closeEditorMenu()
end


-- One for each visible tile in the picker
local TileButton = gui.extend(gui.Item)


function TileButton:onMouseEnter(mouse)
	local picker = self.parent
	local slot = self.slot

	picker.cursorX, picker.cursorY = self.tileGridX, self.tileGridY

	if picker.selectingLayout and mouse.leftPressed then
		local firstSlot = picker.tileGrid:get(picker.selX1, picker.selY1)
		if firstSlot and slot and firstSlot.layout == slot.layout then
			picker.selX2, picker.selY2 = self.tileGridX, self.tileGridY
		end
	else
		picker.pointedButton = self
	end
end

function TileButton:onMouseLeave()
end

function TileButton:onLeftMousePress()
	local picker = self.parent
	local slot = self.slot
	local p = maps.client.player

	if not slot then return end

	picker.pointedButton = nil

	if slot.layout then
		local selX1, selY1
		local selX2, selY2
		if picker.selectingLayout then
			selX1 = min(picker.selX1, picker.selX2)
			selY1 = min(picker.selY1, picker.selY2)
			selX2 = max(picker.selX1, picker.selX2)
			selY2 = max(picker.selY1, picker.selY2)
		end

		if picker.selectingLayout
		and self.tileGridX >= selX1 and self.tileGridX <= selX2
		and self.tileGridY >= selY1 and self.tileGridY <= selY2 then
			p.buildertile = nil
			p.buildertilelayoutindex = slot.layout.index

			local translatex = slot.layoutx - self.tileGridX
			local translatey = slot.layouty - self.tileGridY
			p.buildertilelayoutx1 = selX1 + translatex
			p.buildertilelayouty1 = selY1 + translatey
			p.buildertilelayoutx2 = selX2 + translatex
			p.buildertilelayouty2 = selY2 + translatey

			p.buildertilelayoutanchorx = slot.layoutx
			p.buildertilelayoutanchory = slot.layouty

			local command = maps.prepareEditorCommand("set_cursor_tile_layout")
			bs.writeUInt16(command, p.buildertilelayoutindex)
			bs.writeByte(command, p.buildertilelayoutx1)
			bs.writeByte(command, p.buildertilelayouty1)
			bs.writeByte(command, p.buildertilelayoutx2)
			bs.writeByte(command, p.buildertilelayouty2)
			bs.writeByte(command, p.buildertilelayoutanchorx)
			bs.writeByte(command, p.buildertilelayoutanchory)
			custominput.send(command)

			closeTilePicker()
		else
			-- Start selection
			local x, y = self.tileGridX, self.tileGridY
			picker.selectingLayout = true
			picker.selX1, picker.selY1 = x, y
			picker.selX2, picker.selY2 = x, y
		end
	else
		p.buildertile = maps.tiledefs[slot.tiledefid].index
		p.buildertilelayoutindex = nil

		local command = maps.prepareEditorCommand("set_cursor_tile")
		bs.writeUInt16(command, p.buildertile)
		custominput.send(command)

		closeTilePicker()
	end
end

function TileButton:onLeftMouseRelease()
	local picker = self.parent
	local p = maps.client.player

	if picker.selectingLayout and self.slot
	and picker.selX1 == picker.selX2 and picker.selY1 == picker.selY2 then
		p.buildertile = maps.tiledefs[self.slot.tiledefid].index
		p.buildertilelayoutindex = nil

		local command = maps.prepareEditorCommand("set_cursor_tile")
		bs.writeUInt16(command, p.buildertile)
		custominput.send(command)

		closeTilePicker()
	end
end

function TileButton:draw(v)
	if not self.slot or self.slot:getTiledef().noedit then
		return
	end

	local picker = self.parent

	local def = maps.tiledefs[self.slot.tiledefid]

	local drawx = self.left + TILE_GAP * FU / 2
	local drawy = self.top + TILE_GAP * FU / 2

	local animframe = (maps.time % def.animlen) / def.animspd + 1
	local sprite = def.anim[animframe]
	local flags = def.flags

	local offsetx = def.offsetx[animframe] * TILE_SIZE / maps.renderscale
	local offsety = def.offsety[animframe] * TILE_SIZE / maps.renderscale

	local scale = TILE_SIZE * def.scale / maps.renderscale

	/*drawx = $ + def.editspanw * TILE_GAP * FU / 2
	drawy = $ + def.editspanh * TILE_GAP * FU / 2

	drawx = $ + (def.editspanw - def.spanw) * (TILE_SIZE + TILE_GAP) * FU / 2
	drawy = $ + (def.editspanh - def.spanh) * (TILE_SIZE + TILE_GAP) * FU / 2*/

	--drawx = $ + (TILE_SIZE * FU - sprite.width  * scale) / 2
	--drawy = $ + (TILE_SIZE * FU - sprite.height * scale) / 2

	if self == picker.pointedButton then
		local highlightscale = maps.sinCycle(maps.time, HIGHLIGHT_SCALE, FU, TICRATE)
		scale = FixedMul($, highlightscale)
		flags = $ | (maps.sinCycle(maps.time, 0, 5, TICRATE) << V_ALPHASHIFT)

		local extrasize = (highlightscale - FU) * TILE_SIZE / 2
		drawx = $ - extrasize + FixedMul(offsetx, highlightscale)
		drawy = $ - extrasize + FixedMul(offsety, highlightscale)
	else
		drawx = $ + offsetx
		drawy = $ + offsety

		flags = $ | V_50TRANS
	end

	v.drawScaled(drawx, drawy, scale, sprite, flags)
end


-- One for each available category
local CategoryButton = gui.extend(gui.Item)


function CategoryButton:onMouseEnter()
	self.parent.selectedCategoryIndex = self.categoryIndex
end

function CategoryButton:onMouseLeave()
	self.parent.selectedCategoryIndex = nil
end

function CategoryButton:onLeftMousePress()
	maps.client.buildertilecategoryindex = self.categoryIndex
	self.parent:setupTilePicker()
end

function CategoryButton:draw(v)
	local highlightscale
	local flags
	if self.categoryIndex ~= self.parent.selectedCategoryIndex then
		highlightscale = FU
		flags = V_50TRANS
	else
		highlightscale = maps.sinCycle(maps.time, FU, HIGHLIGHT_SCALE, TICRATE)
		flags = maps.sinCycle(maps.time, 5, 0, TICRATE) << V_ALPHASHIFT
	end

	local category = maps.tilecategories[self.categoryIndex]
	local icon = v.cachePatch(category.icon)
	local scale = FixedMul(CAT_SIZE * FU / max(icon.width, icon.height), highlightscale)
	local extrasize = (CAT_SIZE * highlightscale - CAT_SIZE * FU) / 2

	v.drawScaled(
		self.left + (CAT_SIZE * highlightscale - icon.width  * scale) / 2 - extrasize + icon.leftoffset * scale,
		self.top + (CAT_SIZE * highlightscale - icon.height * scale) / 2 - extrasize + icon.topoffset  * scale,
		scale,
		icon,
		flags
	)
end


local Picker = gui.extend(gui.Area)
maps.TilePicker = Picker


local function handleKeyRepeat(self, counter, wasPressed, delay)
	if not wasPressed then
		self[counter] = TICRATE / 4
		return true
	elseif self[counter] == 1 then
		self[counter] = delay
		return true
	else
		self[counter] = $ - 1
		return false
	end
end

local function checkKeyboardInputsForGridNavigation(self, delay)
	local left, right, up, down = maps.getLocalKeys(gui.cmd)
	local cl = maps.client
	local dx, dy = 0, 0

	if left and handleKeyRepeat(self, "hkeyrepeat", cl.prevleft, delay) then
		dx = -1
	end

	if right and handleKeyRepeat(self, "hkeyrepeat", cl.prevright, delay) then
		dx = 1
	end

	if up and handleKeyRepeat(self, "vkeyrepeat", cl.prevup, delay) then
		dy = -1
	end

	if down and handleKeyRepeat(self, "vkeyrepeat", cl.prevdown, delay) then
		dy = 1
	end

	return dx, dy
end

function Picker:tileButtonAtPos(x, y)
	local slot = self.tileGrid:get(x, y)
	if slot then
		return self.slotToButton[slot]
	else
		return nil
	end
end

function Picker:setupCategoryPicker()
	self:cleanup()

	self.selX, self.selY = 1, 1
	self.categoryIndex = nil
	self.selectedCategoryIndex = nil
	self.categoryButtons = {}

	local drawStep = (CAT_SIZE + CAT_GAP) * FU
	local drawX = CAT_GAP * FU
	local drawY = CAT_GAP * FU
	for categoryIndex = 1, #maps.tilecategories do
		local button = CategoryButton()

		button:move(drawX, drawY)
		button:setSize(CAT_SIZE * FU, CAT_SIZE * FU)
		button.categoryIndex = categoryIndex

		self.categoryButtons[categoryIndex] = self:attach(button)

		drawX = $ + drawStep
		if drawX > gui.screen.width - CAT_GAP - CAT_SIZE then
			drawX = CAT_GAP * FU
			drawY = $ + drawStep
		end
	end
end

function Picker:setupTilePicker()
	self:cleanup()

	self.categoryIndex = maps.client.buildertilecategoryindex

	self.tileGrid = maps.TilePickerGrid()
	for _, trees in ipairs(maps.tiledeftrees) do
		if trees.categoryIndex == self.categoryIndex then
			self.tileGrid:addTiles(trees)
		end
	end

	self.pointedButton = nil
	self.selectingLayout = false
	self.cursorX, self.cursorY = 1, 1
	self.selX1, self.selY1 = 1, 1
	self.selX2, self.selY2 = 1, 1
	self.scrolling = 0
	self.slotToButton = {}

	local drawStep = (TILE_SIZE + TILE_GAP) * FU
	local drawY = 0
	for y = 1, self.tileGrid.height do
		local drawX = 0

		for x = 1, self.tileGrid.width do
			local slot = self.tileGrid:get(x, y)
			local button = TileButton()

			button:move(drawX, drawY)
			local size = (TILE_SIZE + TILE_GAP) * FU
			button:setSize(size, size)

			button.tileGridX, button.tileGridY = x, y

			if slot then
				button.slot = slot
				self.slotToButton[slot] = button
			end

			self:attach(button)

			drawX = $ + drawStep
		end

		drawY = $ + drawStep
	end
end

function Picker:setup()
	self:move(0, 0)
	self:setSize(gui.screen.width, gui.screen.height)

	self.prevButtons = gui.cmd.buttons
	self.hkeyrepeat, self.vkeyrepeat = TICRATE / 8, TICRATE / 8

	if maps.client.buildertilecategoryindex then
		self:setupTilePicker()
	else
		self:setupCategoryPicker()
	end
end

function Picker:cleanup()
	local item = self.backChild
	while item do
		local frontItem = item.front
		item:detach()
		item = frontItem
	end
end

function Picker:handleCategoryPickerEvents()
	local cl = maps.client
	local p = cl.player
	local cmd = gui.cmd

	local dx = checkKeyboardInputsForGridNavigation(self, p.builderspeed)
	if dx ~= 0 then
		if self.selectedCategoryIndex == nil then
			self.selectedCategoryIndex = 1
		else
			self.selectedCategoryIndex = min(max($ + dx, 1), #self.categoryButtons)
		end
	end

	if cmd.buttons & BT_JUMP and not (self.prevButtons & BT_JUMP)
	and self.selectedCategoryIndex ~= nil then
		cl.buildertilecategoryindex = self.selectedCategoryIndex
		self:setupTilePicker()
	end

	if cmd.buttons & BT_SPIN and not (self.prevButtons & BT_SPIN) then
		closeTilePicker()
	end
end

function Picker:handleTilePickerEvents()
	local cl = maps.client
	local p = cl.player
	local cmd = gui.cmd

	local dx, dy = checkKeyboardInputsForGridNavigation(self, p.builderspeed)
	if dx ~= 0 or dy ~= 0 then
		self.cursorX = min(max($ + dx, 1), self.tileGrid.width)
		self.cursorY = min(max($ + dy, 1), self.tileGrid.height)
		self.pointedButton = self:tileButtonAtPos(self.cursorX, self.cursorY)
	end

	if cmd.buttons & BT_JUMP and not (self.prevButtons & BT_JUMP) then
	end

	if cmd.buttons & BT_SPIN and not (self.prevButtons & BT_SPIN) then
		self:setupCategoryPicker()
	end
end

function Picker:handleEvents()
	if self.categoryIndex == nil then
		self:handleCategoryPickerEvents()
	else
		self:handleTilePickerEvents()
	end

	self.prevButtons = gui.cmd.buttons
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
	v.drawFill()

	self:drawChildren(v)

	-- Draw selection rectangle
	if self.categoryIndex ~= nil and self.selectingLayout then
		local x1, x2 = self.selX1, self.selX2
		if x1 > x2 then
			x1, x2 = x2, x1
		end

		local y1, y2 = self.selY1, self.selY2
		if y1 > y2 then
			y1, y2 = y2, y1
		end

		local step = (TILE_SIZE + TILE_GAP) * FU
		drawRectangleBorders(
			v,
			(x1 - 1) * step,
			(y1 - 1) * step,
			(x2 - x1 + 1) * step,
			(y2 - y1 + 1) * step,
			1 * FU,
			0
		)
	end
end
