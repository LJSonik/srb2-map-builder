local FU = FRACUNIT
local TILESIZE = maps.TILESIZE


function maps.centerCameraAroundPoint(p, x, y)
	p.scrollx = x - maps.SCREEN_WIDTH / 2 / p.renderscale
	local limit = maps.map.w * TILESIZE - maps.SCREEN_WIDTH / p.renderscale
	if p.scrollx > limit then
		p.scrollx = limit
	elseif p.scrollx < 0 then
		p.scrollx = 0
	end

	p.scrolly = y - maps.SCREEN_HEIGHT / 2 / p.renderscale
	limit = maps.map.h * TILESIZE - maps.SCREEN_HEIGHT / p.renderscale
	if p.scrolly > limit then
		p.scrolly = limit
	elseif p.scrolly < 0 then
		p.scrolly = 0
	end
end

function maps.centerClientCameraAroundPoint(x, y)
	local cl = maps.client
	local p = cl.player

	cl.scrollx = x - maps.SCREEN_WIDTH / 2 / p.renderscale
	local limit = maps.map.w * TILESIZE - maps.SCREEN_WIDTH / p.renderscale
	if cl.scrollx > limit then
		cl.scrollx = limit
	elseif cl.scrollx < 0 then
		cl.scrollx = 0
	end

	cl.scrolly = y - maps.SCREEN_HEIGHT / 2 / p.renderscale
	limit = maps.map.h * TILESIZE - maps.SCREEN_HEIGHT / p.renderscale
	if cl.scrolly > limit then
		cl.scrolly = limit
	elseif cl.scrolly < 0 then
		cl.scrolly = 0
	end
end

function maps.centerCamera(p)
	if p.builder then
		maps.centerCameraAroundPoint(p,
			p.builderx * TILESIZE + TILESIZE / 2,
			p.buildery * TILESIZE + TILESIZE / 2
		)
	elseif p.dead then
		maps.centerCameraAroundPoint(p, p.x, p.y)
	else
		local o = p.obj
		maps.centerCameraAroundPoint(p, o.refx, o.refy)
	end
end

function maps.centerClientCamera()
	local p = maps.client.player

	if p.builder then
		maps.centerClientCameraAroundPoint(
			p.builderx * TILESIZE + TILESIZE / 2,
			p.buildery * TILESIZE + TILESIZE / 2
		)
	elseif p.dead then
		maps.centerClientCameraAroundPoint(p.x, p.y)
	else
		local o = p.obj
		maps.centerClientCameraAroundPoint(o.refx, o.refy)
	end
end

local function handleBasicOrSpeedCamera(p)
	local o = p.carried or p.obj
	local speedx, speedy = o.speedx, o.speedy

	local baseviewh = (p.camera ~= 4 and p.scrolldistance or 12) * TILESIZE * 16 / p.renderscale
	local baseviewv = 4 * TILESIZE * 16 / p.renderscale
	local extraviewh = speedx * 8 * 16 / p.renderscale
	local extraviewv = speedy * 8 * 16 / p.renderscale
	local basecameraspeedh = 1 * TILESIZE * 16 / p.renderscale
	local basecameraspeedv = 2 * TILESIZE * 16 / p.renderscale

	if speedx < 0 then
		local view = baseviewh
		if p.camera == 4 then
			view = $ - extraviewh
		end
		local limit = (maps.SCREEN_WIDTH - 4 * TILESIZE) / p.renderscale
		if view > limit then
			view = limit
		end

		limit = o.refx - view
		if p.scrollx > limit then
			local scrolldx = limit - p.scrollx
			limit = speedx - basecameraspeedh
			if scrolldx < limit then
				scrolldx = limit
			end

			p.scrollx = $ + scrolldx

			if p.scrollx < 0 then
				p.scrollx = 0
			end
		end
	elseif speedx > 0 then
		local view = baseviewh
		if p.camera == 4 then
			view = $ + extraviewh
		end
		local limit = (maps.SCREEN_WIDTH - 4 * TILESIZE) / p.renderscale
		if view > limit then
			view = limit
		end

		limit = o.refx - maps.SCREEN_WIDTH / p.renderscale + view
		if p.scrollx < limit then
			local scrolldx = limit - p.scrollx
			limit = speedx + basecameraspeedh
			if scrolldx > limit then
				scrolldx = limit
			end

			p.scrollx = $ + scrolldx

			limit = maps.map.w * TILESIZE - maps.SCREEN_WIDTH / p.renderscale
			if p.scrollx > limit then
				p.scrollx = limit
			end
		end
	end

	if speedy < 0 then
		local view = baseviewv
		if p.camera == 4 and not p.jump then
			view = $ - extraviewv
		end
		local limit = (maps.SCREEN_HEIGHT - 4 * TILESIZE) / p.renderscale
		if view > limit then
			view = limit
		end

		limit = o.refy - view
		if p.scrolly > limit then
			local scrolldy = limit - p.scrolly
			limit = speedy - basecameraspeedv
			if scrolldy < limit then
				scrolldy = limit
			end

			p.scrolly = $ + scrolldy

			if p.scrolly < 0 then
				p.scrolly = 0
			end
		end
	elseif speedy > 0 then
		local view = baseviewv
		if p.camera == 4 and not p.jump then
			view = $ + extraviewv
		end
		local limit = (maps.SCREEN_HEIGHT - 4 * TILESIZE) / p.renderscale
		if view > limit then
			view = limit
		end

		limit = o.refy + view - maps.SCREEN_HEIGHT / p.renderscale
		if p.scrolly < limit then
			local scrolldy = limit - p.scrolly
			limit = speedy + basecameraspeedv
			if scrolldy > limit then
				scrolldy = limit
			end

			p.scrolly = $ + scrolldy

			limit = maps.map.h * TILESIZE - maps.SCREEN_HEIGHT / p.renderscale
			if p.scrolly > limit then
				p.scrolly = limit
			end
		end
	end
end

/*local function handleBasicOrSpeedCamera(p)
	local o = p.carried or p.obj
	local speedx, speedy = o.speedx, o.speedy

	local baseviewh = (p.camera ~= 4 and p.scrolldistance or 12) * TILESIZE * 16 / p.renderscale
	local baseviewv = 4 * TILESIZE * 16 / p.renderscale
	local extraviewh = speedx * 8 * 16 / p.renderscale
	local extraviewv = speedy * 8 * 16 / p.renderscale
	local basecameraspeedh = 1 * TILESIZE * 16 / p.renderscale
	local basecameraspeedv = 2 * TILESIZE * 16 / p.renderscale

	if speedx < 0 then
		local view = baseviewh
		if p.camera == 4 then
			view = $ - extraviewh
		end
		local limit = (maps.SCREEN_WIDTH - 4 * TILESIZE) / p.renderscale
		if view > limit then
			view = limit
		end

		limit = o.l - view
		if p.scrollx > limit then
			local scrolldx = limit - p.scrollx
			limit = speedx - basecameraspeedh
			if scrolldx < limit then
				scrolldx = limit
			end

			p.scrollx = $ + scrolldx

			if p.scrollx < 0 then
				p.scrollx = 0
			end
		end
	elseif speedx > 0 then
		local view = baseviewh
		if p.camera == 4 then
			view = $ + extraviewh
		end
		local limit = (maps.SCREEN_WIDTH - 4 * TILESIZE) / p.renderscale
		if view > limit then
			view = limit
		end

		limit = o.l + o.w - maps.SCREEN_WIDTH / p.renderscale + view
		if p.scrollx < limit then
			local scrolldx = limit - p.scrollx
			limit = speedx + basecameraspeedh
			if scrolldx > limit then
				scrolldx = limit
			end

			p.scrollx = $ + scrolldx

			limit = maps.map.w * TILESIZE - maps.SCREEN_WIDTH / p.renderscale
			if p.scrollx > limit then
				p.scrollx = limit
			end
		end
	end

	if speedy < 0 then
		local view = baseviewv
		if p.camera == 4 and not p.jump then
			view = $ - extraviewv
		end
		local limit = (maps.SCREEN_HEIGHT - 4 * TILESIZE) / p.renderscale
		if view > limit then
			view = limit
		end

		limit = o.t - view
		if p.scrolly > limit then
			local scrolldy = limit - p.scrolly
			limit = speedy - basecameraspeedv
			if scrolldy < limit then
				scrolldy = limit
			end

			p.scrolly = $ + scrolldy

			if p.scrolly < 0 then
				p.scrolly = 0
			end
		end
	elseif speedy > 0 then
		local view = baseviewv
		if p.camera == 4 and not p.jump then
			view = $ + extraviewv
		end
		local limit = (maps.SCREEN_HEIGHT - 4 * TILESIZE) / p.renderscale
		if view > limit then
			view = limit
		end

		limit = o.t + o.h + view - maps.SCREEN_HEIGHT / p.renderscale
		if p.scrolly < limit then
			local scrolldy = limit - p.scrolly
			limit = speedy + basecameraspeedv
			if scrolldy > limit then
				scrolldy = limit
			end

			p.scrolly = $ + scrolldy

			limit = maps.map.h * TILESIZE - maps.SCREEN_HEIGHT / p.renderscale
			if p.scrolly > limit then
				p.scrolly = limit
			end
		end
	end
end*/

local function handleDirectionCamera(p)
	local o = p.carried or p.obj

	local view = 12 * TILESIZE / p.renderscale
	local cameraspeed = 4096
	--local cameraspeed = TILESIZE / 4 + abs(o.speedy) * 5 / 4
	local minspeed = 2 * FU

	local srcx = p.scrollx + maps.SCREEN_WIDTH / p.renderscale / 2

	local dstx
	if o.speedy < -minspeed then -- Left
		dstx = o.l + o.w / 2 - view
	elseif o.speedy > minspeed or o.dir == 2 then -- Right
		dstx = o.l + o.w / 2 + view
	else -- Left
		dstx = o.l + o.w / 2 - view
	end

	local x = FixedMul(srcx + o.speedy, FU - cameraspeed) + FixedMul(dstx, cameraspeed)
	--if srcx < dstx
	--	x = $ + cameraspeed
	--	if x > dstx
	--		x = dstx
	--	end
	--elseif srcx > dstx
	--	x = $ - cameraspeed
	--	if x < dstx
	--		x = dstx
	--	end
	--end

	maps.centerCameraAroundPoint(p, x, o.refy)
end

-- ....
function maps.handlePlayerCamera(p)
	if p.camera == 1 or p.camera == 4 then -- Basic or speed
		handleBasicOrSpeedCamera(p)
	elseif p.camera == 2 then -- Center
		local o = p.carried or p.obj
		maps.centerCameraAroundPoint(p, o.refx, o.refy)
	elseif p.camera == 3 then -- Direction
		handleDirectionCamera(p)
	end
end

function maps.handleClientBuilderCamera(p)
	local cl = maps.client
	local p = cl.player

	if (p.builderx + 1) * TILESIZE > cl.scrollx + 224 * FU / p.renderscale then
		cl.scrollx = min(
			(p.builderx + 1) * TILESIZE - 224 * FU / p.renderscale,
			maps.map.w * TILESIZE - maps.SCREEN_WIDTH / p.renderscale
		)
	elseif (p.builderx + 1) * TILESIZE < cl.scrollx + 96 * FU / p.renderscale then
		cl.scrollx = max(
			(p.builderx + 1) * TILESIZE - 96 * FU / p.renderscale,
			0
		)
	end

	if (p.buildery + 1) * TILESIZE > cl.scrolly + 136 * FU / p.renderscale then
		cl.scrolly = min(
			(p.buildery + 1) * TILESIZE - 136 * FU / p.renderscale,
			maps.map.h * TILESIZE - maps.SCREEN_HEIGHT / p.renderscale
		)
	elseif (p.buildery + 1) * TILESIZE < cl.scrolly + 64 * FU / p.renderscale then
		cl.scrolly = max(
			(p.buildery + 1) * TILESIZE - 64 * FU / p.renderscale,
			0
		)
	end
end

/*function maps.handleBuilderCamera(p)
	if (p.builderx + 1) * TILESIZE > p.scrollx + 224 * FU / p.renderscale then
		p.scrollx = min(
			(p.builderx + 1) * TILESIZE - 224 * FU / p.renderscale,
			maps.map.w * TILESIZE - maps.SCREEN_WIDTH / p.renderscale
		)
	elseif (p.builderx + 1) * TILESIZE < p.scrollx + 96 * FU / p.renderscale then
		p.scrollx = max(
			(p.builderx + 1) * TILESIZE - 96 * FU / p.renderscale,
			0
		)
	end

	if (p.buildery + 1) * TILESIZE > p.scrolly + 136 * FU / p.renderscale then
		p.scrolly = min(
			(p.buildery + 1) * TILESIZE - 136 * FU / p.renderscale,
			maps.map.h * TILESIZE - maps.SCREEN_HEIGHT / p.renderscale
		)
	elseif (p.buildery + 1) * TILESIZE < p.scrolly + 64 * FU / p.renderscale then
		p.scrolly = max(
			(p.buildery + 1) * TILESIZE - 64 * FU / p.renderscale,
			0
		)
	end
end*/
