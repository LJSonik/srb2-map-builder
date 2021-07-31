function maps.addTileToRespawnList(i, layer, duration)
	local time = maps.time + duration

	local layerlist = maps.tilestorespawn[layer]
	local list = layerlist[time]
	if list then
		list[#list + 1] = i
	else
		layerlist[time] = {i}
	end
end

function maps.handleTileRespawn()
	local tiledefs = maps.tiledefs

	for layernum = 2, 3 do
		local layer = maps.map[layernum]
		local tiledata = maps.tiledata[layernum]
		local list = maps.tilestorespawn[layernum][maps.time]
		if list then
			for i = 1, #list do
				local tileindex = list[i]
				local def = tiledefs[layer[tileindex]]
				if def.respawn then
					maps.setTile(layernum, tileindex, layer[tileindex] - 1)
					--maps.setTile(layernum, tileindex, tiledefs[def.respawn].index)
					tiledata[tileindex] = nil
				end
			end

			maps.tilestorespawn[layernum][maps.time] = nil
		end
	end
end


addHook("NetVars", function(n)
	maps.tilestorespawn = n($)
	--maps.numtilestorespawn = n($)
end)
