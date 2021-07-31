local class = {}


function class.localclass(parent)
	local class = {}

	local objectMetatable = {
		__index = class
	}

	if parent then
		for k, v in pairs(parent) do
			class[k] = v
		end
	end

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


return class
