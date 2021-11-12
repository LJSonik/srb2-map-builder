maps.editormenudef = {
	x = 160, y = 100,

	false,
	{
		text = "Layer: 2",
	},
	{
		text = "Play",

		{
			text = "From start",

			action = function(owner)
				local p = maps.pp[owner.maps.player]
				maps.spawnPlayer(p)
				return true
			end
		},
		false,
		{
			text = "From here",

			action = function(owner)
				local p = maps.pp[owner.maps.player]
				maps.spawnPlayer(p)
				return true
			end
		},
	},
	{
		text = function(owner)
			local p = maps.getPlayer(owner)
			return "Zoom: "..p.editorrenderscale
		end,

		{
			text = "+",
			instant = true,

			action = function(owner)
				local p = maps.getPlayer(owner)

				if p.editorrenderscale ~= 16 then
					p.editorrenderscale = $ * 2

					if p.builder then
						p.renderscale = p.editorrenderscale
						maps.centerCamera(p)
					end
				end
			end
		},
		false,
		false,
		false,
		{
			text = "-",
			instant = true,

			action = function(owner)
				local p = maps.getPlayer(owner)

				if p.editorrenderscale ~= 4 then
					p.editorrenderscale = $ / 2

					if p.builder then
						p.renderscale = p.editorrenderscale
						maps.centerCamera(p)
					end
				end
			end
		},
	},
}


function maps.handleOldEditorWheelMenu(owner, t, bt, left, right, up, down)
	if not owner then return end

	local p = maps.pp[owner.maps.player]
	if maps.handleWheelMenu(maps.editormenudef, p.editormenu, owner, t, bt, left, right, up, down) then
		p.editormenu = nil
	end
end
