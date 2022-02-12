---@class ljgui
local gui = ljrequire "ljgui.common"

local FU = FRACUNIT
local MOUSE_SENS = 8 * FU


local cv_mousesens = CV_FindVar("mousesens")
local cv_mouseysens = CV_FindVar("mouseysens")


---@class ljgui.Mouse
---
---@field x fixed_t
---@field y fixed_t
---@field oldX fixed_t
---@field oldY fixed_t
---
---@field image string
local Mouse = gui.extend{}
gui.Mouse = Mouse


function Mouse:__init()
	self.x, self.y = 0, 0
	self.oldX, self.oldY = self.x, self.y

	self:setImage("LJGUI_CURSOR")

	--self.oldAngle = 0
	--self.oldAiming = 0
end

function Mouse:move(x, y)
	self.x, self.y = x, y
end

---@param image string Name of the patch used to draw the cursor
function Mouse:setImage(image)
	self.image = image
end

function Mouse:updatePosition()
	local v = gui.v

	self.oldX, self.oldY = self.x, self.y

	local centerWidth, centerHeight = 320 * v.dupx(), 200 * v.dupy()
	local borderWidth  = (v.width()  - centerWidth ) / 2
	local borderHeight = (v.height() - centerHeight) / 2

	-- input.setMouseGrab(false) -- !!! DON'T DO THAT ALL THE TIME

	local x, y = input.getCursorPosition()
	x = min(max(x - borderWidth , 0), centerWidth)
	y = min(max(y - borderHeight, 0), centerHeight)
	x = x * FU / v.dupx()
	y = y * FU / v.dupy()

	self:move(x, y)
end

/*function Mouse:updatePosition()
	local cmd, v = gui.cmd, gui.v
	local sens, ysens = cv_mousesens.value, cv_mouseysens.value

	self.oldX, self.oldY = self.x, self.y

	local dx = cmd.angleturn - self.oldAngle
	--print("dx = " .. dx)
	if dx < -32767 then
		dx = $ + 65536
	elseif dx > 32767 then
		dx = $ - 65536
	end
	--dx = $ * FixedDiv(320, v.width())
	dx = $ * FU
	dx = FixedMul($ / (sens * sens), MOUSE_SENS)

	local dy = cmd.aiming - self.oldAiming
	if dy < -32767 then
		dy = $ + 65536
	elseif dy > 32767 then
		dy = $ - 65536
	end
	--dy = $ * FixedDiv(200, v.height())
	dy = $ * FU
	dy = FixedMul($ / (ysens * sens), MOUSE_SENS)

	self:move(
		min(max(self.x - dx, 0), 320 * FU - 1),
		min(max(self.y - dy, 0), 200 * FU - 1)
		--min(max($ - dx, 0), v.width() * FU - 1),
		--min(max($ - dy, 0), v.height() * FU - 1)
	)

	cmd.angleturn, cmd.aiming = self.oldAngle, self.oldAiming
	--self.oldAngle, self.oldAiming = cmd.angleturn, cmd.aiming
end*/

---@param item ljgui.Item
---@return boolean
function Mouse:isInsideItem(item)
	return item:isPointInside(self.x, self.y)
end

---@param item ljgui.Item
---@return ljgui.Item?
function Mouse:findPointedItem(item)
	if item.ignoresMouse or not self:isInsideItem(item) then
		return nil
	end

	local child = item.frontChild
	while child do
		if child.enabled then
			local pointedChild = self:findPointedItem(child)
			if pointedChild then
				return pointedChild
			end
		end

		child = child.back
	end

	return item
end

function Mouse:updateHovering()
	local oldItem = self.pointedItem
	local newItem = self:findPointedItem(gui.root)
	local moved = (self.x ~= self.oldX or self.y ~= self.oldY)

	if moved and oldItem and oldItem.parent and oldItem.onMouseMove then
		oldItem:onMouseMove(self)
		newItem = self:findPointedItem(gui.root)
	end

	self.pointedItem = newItem

	if newItem ~= oldItem then
		if oldItem and oldItem.parent and oldItem.onMouseLeave then
			oldItem:onMouseLeave(self)
		end

		if newItem and newItem.onMouseEnter then
			newItem:onMouseEnter(self)
		end

		if moved and newItem and newItem.onMouseMove then
			newItem:onMouseMove(self)
		end
	end
end

-- function Mouse:updateHovering()
-- 	local pointedItem = self:findPointedItem(gui.root)

-- 	if pointedItem ~= self.pointedItem then
-- 		if self.pointedItem and self.pointedItem.onMouseLeave and self.pointedItem.parent then
-- 			self.pointedItem:onMouseLeave(self)
-- 		end

-- 		if pointedItem and pointedItem.onMouseEnter then
-- 			pointedItem:onMouseEnter(self)
-- 		end

-- 		self.pointedItem = pointedItem
-- 	end

-- 	if (self.x ~= self.oldX or self.y ~= self.oldY)
-- 	and pointedItem and pointedItem.onMouseMove then
-- 		pointedItem:onMouseMove(self)
-- 	end
-- end

function Mouse:updateClicking()
	local wasLeftPressed = self.leftPressed
	self.leftPressed = (mouse.buttons & MB_BUTTON1) ~= 0

	if self.leftPressed ~= wasLeftPressed then
		local item = self.pointedItem
		if item then
			if self.leftPressed then
				if item.onLeftMousePress then
					item:onLeftMousePress(self)
				end
			else
				if item.onLeftMouseRelease then
					item:onLeftMouseRelease(self)
				end
			end
		end
	end
end

function Mouse:update()
	self:updatePosition()
	self:updateHovering()
	self:updateClicking()
end

---@param v videolib
function Mouse:draw(v)
	local patch = v.cachePatch(self.image)
	local x, y = gui.greenToReal(v, self.x, self.y)
	v.draw(x, y, patch, V_NOSCALEPATCH)
end
