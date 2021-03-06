---@class ljgui
---@field root ljgui.Root
local gui = ljrequire "ljgui.common"


function gui.extend(parent)
	local class = {}

	local objectMetatable = {
		__index = class
	}

	for k, v in pairs(parent) do
		class[k] = v
	end

	class.class = class

	return setmetatable(class, {
		__call = function(_, ...)
			local object = setmetatable({}, objectMetatable)

			if object.__init then
				object:__init(...)
			end

			return object
		end
	}), parent
end


for _, filename in ipairs{
	"Util.lua",
	"Item.lua",
	"Root.lua",
	"Area.lua",
	"Text.lua",
	"Image.lua",
	"Grid.lua",
	"Window.lua",
	"Button.lua",
	"Mouse.lua",
	"Keyboard.lua",
} do
	dofile("Libraries/ljgui/" .. filename)
end


return gui
