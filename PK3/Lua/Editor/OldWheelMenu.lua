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

				if p.editorrenderscale ~= 16
					p.editorrenderscale = $ * 2

					if p.builder
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

				if p.editorrenderscale ~= 4
					p.editorrenderscale = $ / 2

					if p.builder
						p.renderscale = p.editorrenderscale
						maps.centerCamera(p)
					end
				end
			end
		},
	},
}


function maps.handleOldEditorWheelMenu(owner, t, bt, left, right, up, down)
	if not owner return end

	local p = maps.pp[owner.maps.player]
	if maps.handleWheelMenu(maps.editormenudef, p.editormenu, owner, t, bt, left, right, up, down)
		p.editormenu = nil
	end
end
