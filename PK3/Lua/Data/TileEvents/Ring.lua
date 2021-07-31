function maps.on_ring_hit(tilepos, layernum, o)
	if not o.player then return end

	o.rings = min($ + 1, 9999)
	maps.startSound(sfx_itemup, o.player)

	maps.setTile(layernum, tilepos, maps.map[layernum][tilepos] + 1)
	maps.addTileToRespawnList(tilepos, layernum, 15 * TICRATE)
end
