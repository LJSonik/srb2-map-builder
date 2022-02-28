---@class ljgui
local gui = ljrequire "ljgui.common"


---@class ljgui.ItemStyle
---@field background table
---@field border     table


---@class ljgui.Item
---@field parent     ljgui.Item
---@field enabled    boolean
---@field backChild  ljgui.Item
---@field frontChild ljgui.Item
---
---@field left   fixed_t
---@field right  fixed_t
---@field top    fixed_t
---@field bottom fixed_t
---
---@field events function[]
---
---@field focusedItem ljgui.Item
local Item = gui.extend{}
gui.Item = Item


function Item:__init()
	self.enabled = true

	self.events = {}

	/*for _, template in ipairs{...} do
		self:applyTemplate(template)
	end*/
end

function Item:attachFront(item, refItem)
	item.parent = self

	if refItem then
		if refItem.front then
			item.front = refItem.front
			item.front.back = item
		end

		item.back = refItem
		refItem.front = item

		if self.frontChild == refItem then
			self.frontChild = item
		end
	elseif self.frontChild then
		item.back = self.frontChild
		self.frontChild.front = item
		self.frontChild = item
	else
		self.backChild = item
		self.frontChild = item
	end

	if self.onAttach then
		self:onAttach()
	end

	return item
end

Item.attach = Item.attachFront

function Item:attachBack(item, refItem)
	item.parent = self

	if refItem then
		if refItem.back then
			item.back = refItem.back
			item.back.front = item
		end

		item.front = refItem
		refItem.back = item

		if self.backChild == refItem then
			self.backChild = item
		end
	elseif self.backChild then
		item.front = self.backChild
		self.backChild.back = item
		self.backChild = item
	else
		self.frontChild = item
		self.backChild = item
	end

	if self.onAttach then
		self:onAttach()
	end

	return item
end

function Item:detach(item)
	item = $ or self

	if item.onDetach then
		item:onDetach()
	end

	for eventName, _ in pairs(item.events) do
		gui.root.eventItems[eventName][item] = nil
	end
	item.events = {}

	local child = item.backChild
	while child do
		child:detach()
		child = child.front
	end

	local parent = item.parent
	local back = item.back
	local front = item.front

	if back then
		back.front = front
		item.back = nil
	else
		parent.backChild = front
	end

	if front then
		front.back = back
		item.front = nil
	else
		parent.frontChild = back
	end

	item.parent = nil
end

function Item:enable()
	self.enabled = true
end

function Item:disable()
	self.enabled = false
end

function Item:move(x, y)
	if self.left ~= nil then
		local dx = x - self.left
		local dy = y - self.top

		self.left = x
		self.top = y

		local child = self.backChild
		while child do
			if child.left ~= nil then
				child:move(child.left + dx, child.top + dy)
			end

			child = child.front
		end

		-- self:cachePosition()
	else
		self.left = x
		self.top = y
	end

	if self.onMove then
		self:onMove()
	end
end

-- function Item:cachePosition()
-- 	local parent = self.parent

-- 	if parent then
-- 		self.cache_left = parent.cache_left + self.left
-- 		self.cache_top = parent.cache_top + self.top
-- 	else
-- 		self.cache_left = self.left
-- 		self.cache_top = self.top
-- 	end

-- 	local child = self.backChild
-- 	while child do
-- 		--if child.enabled then
-- 			child:cachePosition()
-- 		--end

-- 		child = child.front
-- 	end
-- end

function Item:getCenter()
	return
		self.left + self.width  / 2,
		self.top  + self.height / 2
end

function Item:centerOnParent()
	local parent = self.parent

	self:move(
		parent.left + (parent.width  - self.width ) / 2,
		parent.top  + (parent.height - self.height) / 2
	)
end

---@param width fixed_t
---@param height fixed_t
function Item:resize(width, height)
	self.width = width
	self.height = height

	if self.onResize then
		self:onResize()
	end
end

function Item:focus()
	gui.root.focusedItem = self
end

function Item:unfocus()
	if self == gui.root.focusedItem then
		gui.root.focusedItem = nil
	end
end

function Item:hasFocus()
	return (gui.root.focusedItem == self)
end

---@param name string
---@param callback function
function Item:addEvent(name, callback)
	local items = gui.root.eventItems
	items[name] = $ or {}
	items[name][self] = true

	self.events[name] = $ or {}
	table.insert(self.events[name], callback)
end

---@param x fixed_t
---@param y fixed_t
---@return boolean
function Item:isPointInside(x, y)
	local l = self.left
	if x < l or x >= l + self.width then
		return false
	end

	local t = self.top
	if y < t or y >= t + self.height then
		return false
	end

	return true
end

function Item:ignoreMouse()
	self.ignoresMouse = true
end

function Item:unignoreMouse()
	self.ignoresMouse = false
end

/*function Item:applyTemplate(template)
	for fieldName, fieldValue in pairs(template) do
		self[fieldName] = fieldValue
	end
end*/

function Item:drawChildren(v)
	local child = self.backChild
	while child do
		if child.enabled then
			child:draw(v)
		end

		child = child.front
	end
end

---@param v videolib
---@param style ljgui.ItemStyle
function Item:drawStyle(v, style)
	if not style then return end

	local l, t = self.left, self.top
	local w, h = self.width, self.height
	local bdStyle = style.border
	local bdSize = bdStyle and bdStyle.size or 0

	if bdStyle then
		local bdType = bdStyle.type
		if bdType == "color" then
			v.drawFill(l / FU, t / FU, w / FU, h / FU, bdStyle.color)
		elseif bdType == "tiles" then
			local image = v.cachePatch(bdStyle.image)
			local scale = bdSize / image.width
			local drawScaled = v.drawScaled

			for x = l, l + w - 2 * bdSize, bdSize do
				drawScaled(x, t, scale, image)
			end

			local x = l + w - bdSize
			for y = t, t + h - 2 * bdSize, bdSize do
				drawScaled(x, y, scale, image)
			end

			local y = t + h - bdSize
			for x = l + bdSize, l + w - bdSize, bdSize do
				drawScaled(x, y, scale, image)
			end

			for y = t + bdSize, t + h - bdSize, bdSize do
				drawScaled(l, y, scale, image)
			end
		end
	end

	local bgStyle = style.background
	local bgType = bgStyle.type
	if bgType == "color" then
		v.drawFill(
			(l     + bdSize) / FU,
			(t     + bdSize) / FU,
			(w - 2 * bdSize) / FU,
			(h - 2 * bdSize) / FU,
			bgStyle.color
		)
	elseif bgType == "image" then
		local image = v.cachePatch(bgStyle.image)

		v.drawStretched(
			l + bdSize,
			t + bdSize,
			(w - 2 * bdSize) / image.width,
			(h - 2 * bdSize) / image.height,
			image
		)
	elseif bgType == "tiles" then
		local image = v.cachePatch(bgStyle.image)
		local size = bgStyle.imageSize
		local scale = size / image.width
		local drawScaled = v.drawScaled
		local b = t + h - 1
		local r = l + w - 1

		for y = t, b, size do
			for x = l, r, size do
				drawScaled(x, y, scale, image)
			end
		end
	end
end

function Item:dump(text, prefix)
	text = $ or ""
	prefix = $ or ""

	print(prefix .. text .. " = {")

	for k, v in pairs(self) do
		if type(v) == "table" then
			print(prefix .. "    " .. tostring(k) .. " = " .. tostring(v))
		elseif type(v) == "string" then
			print(prefix .. "    " .. tostring(k) .. ' = "' .. v .. '"')
		else
			print(prefix .. "    " .. tostring(k) .. " = " .. tostring(v))
		end
	end

	local child = self.backChild
	while child do
		if child.enabled then
			child:dump("child", prefix .. "    ")
		end

		child = child.front
	end

	print(prefix .. "}")
end
