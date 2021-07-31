local libs = {}

rawset(_G, "ljrequire", function(libname)
	/*if not libs[libname] then
		local success, lib = pcall(dofile, "Libraries/" .. libname:gsub('.', '/') .. ".lua")

		if success then
			libs[libname] = lib
		else
			local errmsg = lib
			error(errmsg)
		end
	end

	return libs[libname]*/

	libs[libname] = libs[libname] or dofile("Libraries/" .. libname:gsub('%.', '/') .. ".lua")
	return libs[libname]
end)
