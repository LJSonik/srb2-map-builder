local gui = ljrequire "ljgui.common"


local Item = gui.extend{}
gui.Item = Item


function Item:__init()
	self.enabled = true

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

	return item
end

function Item:detach(item)
	item = $ or self

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
	self.left = x
	self.top = y

	self:cachePosition()
end

function Item:cachePosition()
	local parent = self.parent

	if parent then
		self.cache_left = parent.cache_left + self.left
		self.cache_top = parent.cache_top + self.top
	else
		self.cache_left = self.left
		self.cache_top = self.top
	end

	local child = self.backChild
	while child do
		--if child.enabled then
			child:cachePosition()
		--end

		child = child.front
	end
end

function Item:getCenter()
	return self.width / 2, self.height / 2
end

function Item:setSize(width, height)
	self.width = width
	self.height = height
end

function Item:focus()
	gui.screen.focusedItem = self
end

function Item:unfocus()
	if self == gui.screen.focusedItem then
		gui.screen.focusedItem = nil
	end
end

function Item:hasFocus()
	return (gui.screen.focusedItem == self)
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
