maps.addPack()

for _, filename in ipairs{
	"Heightmaps.lua",
	"Layouts.lua",
	"Skins.lua",
	"Backgrounds.lua",

	"Objects/Player.lua",
	"Objects/Crawla.lua",
	"Objects/OldObjects.lua",

	"TileEvents/Ring.lua",
	"TileEvents/Spring.lua",

	"Tiles/Generic.lua",
	"Tiles/Grass.lua",
	"Tiles/Factory.lua",
	--"Tiles/Test.lua",
} do
	dofile("Data/" .. filename)
end

maps.endPack()
