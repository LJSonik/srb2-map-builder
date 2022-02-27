---@class ljgui
local gui = ljrequire "ljgui.common"


---@class ljgui.Root : ljgui.Item
---@field eventItems table<ljgui.Item, boolean>
local Root, base = gui.extend(gui.Item)
gui.Root = Root


function Root:__init()
	base.__init(self)

	self:move(0, 0)
	self:resize(320*FU, 200*FU)

	local main = gui.Area()
	self.main = self:attach(main)
	main:move(0, 0)
	main:resize(320*FU, 200*FU)

	self.focusedItem = nil

	self.eventItems = {}

	self.mouse = gui.Mouse()
	self.mouse:move(self.width / 2, self.height / 2)
end

function Root:update()
	local item = self.focusedItem
	if item and item.enabled and item.handleEvents then
		item:handleEvents()
	end

	self.mouse:update()
end

---@param name string
function Root:callEvent(name, ...)
	local eventItems = self.eventItems[name]
	if not eventItems then return end

	for item, _ in pairs(eventItems) do
        for _, callback in ipairs(item.events[name]) do
            if callback(item, ...) then
				return true
			end
        end
    end
end

function Root:draw(v)
	self:drawChildren(v)
	self.mouse:draw(v)
end
