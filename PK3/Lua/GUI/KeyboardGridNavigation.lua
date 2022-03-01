local class = ljrequire "ljclass"


---@class maps.KeyboardGridNavigation
---@field dx integer
---@field dy integer
---
---@field xRepeatTime integer
---@field yRepeatTime integer
---
---@field delay integer
---@field frequency integer
local Navigation = class.localclass()
maps.KeyboardGridNavigation = Navigation


---@param delay integer
---@param frequency integer
function Navigation:__init(delay, frequency)
	self.dx, self.dy = 0, 0
	self.xRepeatTime, self.yRepeatTime = 0, 0

	self.delay = delay
	self.frequency = frequency
end

---@return integer
---@return integer
function Navigation:update()
	local dx, dy = 0, 0

	if self.dx ~= 0 then
		if self.xRepeatTime == self.delay then
			dx = self.dx
		end

		if self.xRepeatTime == 1 then
			dx = self.dx
			self.xRepeatTime = self.frequency
		else
			self.xRepeatTime = $ - 1
		end
	end

	if self.dy ~= 0 then
		if self.yRepeatTime == self.delay then
			dy = self.dy
		end

		if self.yRepeatTime == 1 then
			dy = self.dy
			self.yRepeatTime = self.frequency
		else
			self.yRepeatTime = $ - 1
		end
	end

	return dx, dy
end

---@param key keyevent_t
function Navigation:keyDown(key)
	if key.repeated then return end

	local keyName = key.name
	if keyName == "left arrow" then
		if self.dx == 0 then
			self.xRepeatTime = self.delay
		end
		self.dx = -1
	elseif keyName == "right arrow" then
		if self.dx == 0 then
			self.xRepeatTime = self.delay
		end
		self.dx = 1
	elseif keyName == "up arrow" then
		if self.dx == 0 then
			self.yRepeatTime = self.delay
		end
		self.dy = -1
	elseif keyName == "down arrow" then
		if self.dx == 0 then
			self.yRepeatTime = self.delay
		end
		self.dy = 1
	end
end

---@param key keyevent_t
function Navigation:keyUp(key)
	local keyName = key.name
	if keyName ==  "left arrow" and self.dx == -1
	or keyName == "right arrow" and self.dx ==  1 then
		self.dx = 0
	elseif keyName ==   "up arrow" and self.dy == -1
	or     keyName == "down arrow" and self.dy ==  1 then
		self.dy = 0
	end
end
