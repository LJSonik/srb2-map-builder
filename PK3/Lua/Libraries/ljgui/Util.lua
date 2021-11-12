local ljgui = ljrequire "ljgui.common"


---
--- Converts a 320x200-based coordinates into their
--- pixel-based (resolution-dependent) equivalent
---
---@param v videolib
---@param x fixed_t
---@param y fixed_t
---@return integer
---@return integer
function ljgui.greenToReal(v, x, y)
	local dupx, dupy = v.dupx(), v.dupy()
	local centerWidth, centerHeight = 320 * dupx, 200 * dupy
	local borderWidth  = (v.width()  - centerWidth ) / 2
	local borderHeight = (v.height() - centerHeight) / 2

	x = borderWidth  + x * dupx / FU
	y = borderHeight + y * dupy / FU

	return x, y
end
