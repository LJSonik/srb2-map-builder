local FU = FRACUNIT


maps.addTileCategory{
	id = "test",
	name = "Grass",
	icon = "GHZWALL6"
}

maps.addLayout{
	id = "test",

	{1, 2},
	{3, 4},
}

maps.addTiles{
	category = "test",


	{"air", "empty", hidden=true, noedit=true, "NULLA0"},

	"layout test",
		{"test1", "full", "MAPS_GHZ_GRASS1"},
		{"test2", "full", "MAPS_GHZ_GRASS1"},
		{"test3", "full", "GHZWALL7"},
		{"test4", "full", "GHZWALL7"},
	"end",
}
