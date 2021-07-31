local FU = FRACUNIT


maps.addTileCategory{
	id = "grass",
	name = "Grass",
	icon = "GHZWALL6"
}

-- This is IMPORTANT.
maps.addLayout{
	id = "gfz_house",

	{5, 5, 5, 5, 5, 5, 5, 5, 5},

	{0, 2, 1, 1, 2, 1, 1, 1, 0},

	{0, 1, 4, 1, 1, 2, 4, 1, 0},

	{0, 1, 2, 1, 3, 1, 1, 2, 0},
}

maps.addTiles{
	category = "grass",


	--{layout = "column2"},
	"layout column2",
		{"ghz_grass1", "full", "MAPS_GHZ_GRASS1"},
		{"ghz_block1", "full", "GHZWALL7"},
	"end",

	{"ghz_block2", "full", "GHZWALLC"},
	{"ghz_rock1", "full", "GHZWALL1"},

	{"gfz_block1_dark" , "full", "GFZTILA1"},
	{"gfz_block1_light", "full", "GFZTILA2"},
	{"gfz_block2_dark" , "full", "GFZTILB1"},
	{"gfz_block2_light", "full", "GFZTILB2"},
	{"gfz_block3_dark" , "full", "GFZTILC1"},
	{"gfz_block3_light", "full", "GFZTILC2"},

	{"gfz_block1_dark_big" , spanw=2, spanh=2, "full", "GFZTILD1"},
	{"gfz_block1_light_big", spanw=2, spanh=2, "full", "GFZTILD2"},
	{"gfz_block2_dark_big" , spanw=2, spanh=2, "full", "GFZTILE1"},
	{"gfz_block2_light_big", spanw=2, spanh=2, "full", "GFZTILE2"},
	{"gfz_block3_dark_big" , spanw=2, spanh=2, "full", "GFZTILF1"},
	{"gfz_block3_light_big", spanw=2, spanh=2, "full", "GFZTILF2"},

	{"gfz_block4"    , "full",                   "GFZBLOKS"},
	{"gfz_block4_big", "full", spanw=2, spanh=2, "GFZBLOCK"},
	{"gfz_block5_dark" , "full", "GFZTILG1"},
	{"gfz_block5_light", "full", "GFZTILG2"},
	{"gfz_block6", "full", "GFZWAVE"},
	{"gfz_block7", "full", "GFZINSID"},

	{"gfz_rail1"     , "empty", align="bottomleft", editspanw=2, w=FU*2, "GFZRAIL"},
	{"gfz_rail1_vine", "empty", align="bottomleft", editspanw=2, w=FU*2, "GFZRAIL2"},

	{"gfz_vines1"    , "empty", align="topleft",                                   "GFVINES"},
	{"gfz_vines1_big", "empty", align="topleft", editspanw=2, editspanh=2, w=FU*2, "GFVINES"},

	{"gfz_orangeflower" , "empty", offset=true,         {spd=3, prefix="FWR1", "A0","B0","C0","D0","E0","F0","G0","H0"}},
	{"gfz_sunflower"    , "empty", editspanh=2, offset=true, h=FU*2, {spd=3, prefix="FWR2", "A0","B0","C0","D0","E0","F0","G0","H0","I0","J0","K0","L0","M0","N0","O0","P0","Q0","R0","S0","T0"}},
	{"gfz_buddingflower", "empty", offset=true, h=FU/2, {spd=4, prefix="FWR3", "A0","B0","C0","D0","E0","F0","G0","H0","I0","J0","K0","L0"}},

	{"gfz_bush"         , "empty", offset=true, "BUS2A0"},
	{"gfz_redberrybush" , "empty", offset=true, "BUS1A0"},
	{"gfz_blueberrybush", "empty", offset=true, "BUS3A0"},

	{"gfz_tree"      , "empty", editspanw=2, editspanh=3, offset=true, h=FU*3, "TRE1A0"},
	{"gfz_berrytree" , "empty", editspanw=2, editspanh=3, offset=true, h=FU*3, "TRE1B0"},
	{"gfz_cherrytree", "empty", editspanw=2, editspanh=3, offset=true, h=FU*3, "TRE1C0"},

	{"ghz_bridge1", "full" , "GHZWALLA"},
	"layout line3",
		{"ghz_bridgerope1_left" , "empty", align="bottomleft" , w=FU*5/4, "GHZWALL4"},
		{"ghz_bridgepillar1"    , "empty", "GHZWAL02"},
		{"ghz_bridgerope1_right", "empty", align="bottomright", w=FU*5/4, "GHZWALLB"},
	"end",

	{"ghz_totemwing_left", "empty", "GHZWALL3"},
	"layout column4",
		{"ghz_totem1", "empty", "MAPS_GHZ_TOTEM1"},
		{"ghz_totem2", "empty", "MAPS_GHZ_TOTEM2"},
		{"ghz_totem3", "empty", "MAPS_GHZ_TOTEM3"},
		{"ghz_totem4", "empty", "MAPS_GHZ_TOTEM4"},
	"end",
	{"ghz_totemwing_right", "empty", "GHZWALL8"},


	--{layout = "gfz_house"},
	"layout gfz_house",
		{"gfz_brick1", "full", "GFZBRIK1"},
		{"gfz_brick2", "full", "GFZBRIK2"},
		{"gfz_door1", "full", w=FU, "GFZDOORP"},
		{"gfz_window1", "full", "GFZWINDP"},
		{"gfz_roof1", "full", "GFZROOF"},
	"end",


	--{layout = "column2"},
	"layout column2",
		{"waterfall1_top", "empty", align="top", h=FU*2, {spd=2, prefix="GFALL", "1","2","3","4"}},
		{"waterfall1"    , "empty", align="top", h=FU*2, {spd=2, prefix="CFALL", "1","2","3","4"}},
	"end",


	--{layout = "loop"},
	"layout loop",

		"ghz_block1",

		{"ghz_loop_tl1", "loop_tl1", "MAPS_GHZ_BLOCK1_LOOP_TL1"},
		{"ghz_loop_tl2", "loop_tl2", "MAPS_GHZ_BLOCK1_LOOP_TL2"},
		{"ghz_loop_tl3", "loop_tl3", "MAPS_GHZ_BLOCK1_LOOP_TL3"},
		{"ghz_loop_tl4", "loop_tl4", "MAPS_GHZ_BLOCK1_LOOP_TL4"},
		{"ghz_loop_tl5", "loop_tl5", "MAPS_GHZ_BLOCK1_LOOP_TL5"},
		{"ghz_loop_tl6", "loop_tl6", "MAPS_GHZ_BLOCK1_LOOP_TL6"},
		{"ghz_loop_tl7", "loop_tl7", "MAPS_GHZ_BLOCK1_LOOP_TL7"},

		{"ghz_loop_tr1", "loop_tr1", "MAPS_GHZ_BLOCK1_LOOP_TR1"},
		{"ghz_loop_tr2", "loop_tr2", "MAPS_GHZ_BLOCK1_LOOP_TR2"},
		{"ghz_loop_tr3", "loop_tr3", "MAPS_GHZ_BLOCK1_LOOP_TR3"},
		{"ghz_loop_tr4", "loop_tr4", "MAPS_GHZ_BLOCK1_LOOP_TR4"},
		{"ghz_loop_tr5", "loop_tr5", "MAPS_GHZ_BLOCK1_LOOP_TR5"},
		{"ghz_loop_tr6", "loop_tr6", "MAPS_GHZ_BLOCK1_LOOP_TR6"},
		{"ghz_loop_tr7", "loop_tr7", "MAPS_GHZ_BLOCK1_LOOP_TR7"},

		{"ghz_loop_br1", "loop_br1", "MAPS_GHZ_BLOCK1_LOOP_BR1"},
		{"ghz_loop_br2", "loop_br2", "MAPS_GHZ_BLOCK1_LOOP_BR2"},
		{"ghz_loop_br3", "loop_br3", "MAPS_GHZ_BLOCK1_LOOP_BR3"},
		{"ghz_loop_br4", "loop_br4", "MAPS_GHZ_BLOCK1_LOOP_BR4"},
		{"ghz_loop_br5", "loop_br5", "MAPS_GHZ_BLOCK1_LOOP_BR5"},
		{"ghz_loop_br6", "loop_br6", "MAPS_GHZ_BLOCK1_LOOP_BR6"},
		{"ghz_loop_br7", "loop_br7", "MAPS_GHZ_BLOCK1_LOOP_BR7"},

		{"ghz_loop_bl1", "loop_bl1", "MAPS_GHZ_BLOCK1_LOOP_BL1"},
		{"ghz_loop_bl2", "loop_bl2", "MAPS_GHZ_BLOCK1_LOOP_BL2"},
		{"ghz_loop_bl3", "loop_bl3", "MAPS_GHZ_BLOCK1_LOOP_BL3"},
		{"ghz_loop_bl4", "loop_bl4", "MAPS_GHZ_BLOCK1_LOOP_BL4"},
		{"ghz_loop_bl5", "loop_bl5", "MAPS_GHZ_BLOCK1_LOOP_BL5"},
		{"ghz_loop_bl6", "loop_bl6", "MAPS_GHZ_BLOCK1_LOOP_BL6"},
		{"ghz_loop_bl7", "loop_bl7", "MAPS_GHZ_BLOCK1_LOOP_BL7"},

	"end",


	--{layout = "circle"},
	"layout circle",

		"ghz_block1",

		{"ghz_circle_tl1", "circle_tl1", "MAPS_GHZ_BLOCK1_CIRCLE_TL1"},
		{"ghz_circle_tl2", "circle_tl2", "MAPS_GHZ_BLOCK1_CIRCLE_TL2"},
		{"ghz_circle_tl3", "circle_tl3", "MAPS_GHZ_BLOCK1_CIRCLE_TL3"},
		{"ghz_circle_tl4", "circle_tl4", "MAPS_GHZ_BLOCK1_CIRCLE_TL4"},
		{"ghz_circle_tl5", "circle_tl5", "MAPS_GHZ_BLOCK1_CIRCLE_TL5"},
		{"ghz_circle_tl6", "circle_tl6", "MAPS_GHZ_BLOCK1_CIRCLE_TL6"},
		{"ghz_circle_tl7", "circle_tl7", "MAPS_GHZ_BLOCK1_CIRCLE_TL7"},

		{"ghz_circle_tr1", "circle_tr1", "MAPS_GHZ_BLOCK1_CIRCLE_TR1"},
		{"ghz_circle_tr2", "circle_tr2", "MAPS_GHZ_BLOCK1_CIRCLE_TR2"},
		{"ghz_circle_tr3", "circle_tr3", "MAPS_GHZ_BLOCK1_CIRCLE_TR3"},
		{"ghz_circle_tr4", "circle_tr4", "MAPS_GHZ_BLOCK1_CIRCLE_TR4"},
		{"ghz_circle_tr5", "circle_tr5", "MAPS_GHZ_BLOCK1_CIRCLE_TR5"},
		{"ghz_circle_tr6", "circle_tr6", "MAPS_GHZ_BLOCK1_CIRCLE_TR6"},
		{"ghz_circle_tr7", "circle_tr7", "MAPS_GHZ_BLOCK1_CIRCLE_TR7"},

		{"ghz_circle_br1", "circle_br1", "MAPS_GHZ_BLOCK1_CIRCLE_BR1"},
		{"ghz_circle_br2", "circle_br2", "MAPS_GHZ_BLOCK1_CIRCLE_BR2"},
		{"ghz_circle_br3", "circle_br3", "MAPS_GHZ_BLOCK1_CIRCLE_BR3"},
		{"ghz_circle_br4", "circle_br4", "MAPS_GHZ_BLOCK1_CIRCLE_BR4"},
		{"ghz_circle_br5", "circle_br5", "MAPS_GHZ_BLOCK1_CIRCLE_BR5"},
		{"ghz_circle_br6", "circle_br6", "MAPS_GHZ_BLOCK1_CIRCLE_BR6"},
		{"ghz_circle_br7", "circle_br7", "MAPS_GHZ_BLOCK1_CIRCLE_BR7"},

		{"ghz_circle_bl1", "circle_bl1", "MAPS_GHZ_BLOCK1_CIRCLE_BL1"},
		{"ghz_circle_bl2", "circle_bl2", "MAPS_GHZ_BLOCK1_CIRCLE_BL2"},
		{"ghz_circle_bl3", "circle_bl3", "MAPS_GHZ_BLOCK1_CIRCLE_BL3"},
		{"ghz_circle_bl4", "circle_bl4", "MAPS_GHZ_BLOCK1_CIRCLE_BL4"},
		{"ghz_circle_bl5", "circle_bl5", "MAPS_GHZ_BLOCK1_CIRCLE_BL5"},
		{"ghz_circle_bl6", "circle_bl6", "MAPS_GHZ_BLOCK1_CIRCLE_BL6"},
		{"ghz_circle_bl7", "circle_bl7", "MAPS_GHZ_BLOCK1_CIRCLE_BL7"},

	"end",


	--{layout = "grass_slope45"},
	"layout grass_slope45",
		{"ghz_grass1_slope45_tl1", "slope45_tl", "MAPS_GHZ_GRASS1_SLOPE45_TL1"},
		{"ghz_grass1_slope45_tl2",       "full", "MAPS_GHZ_GRASS1_SLOPE45_TL2"},
		{"ghz_grass1_slope45_tr1", "slope45_tr", "MAPS_GHZ_GRASS1_SLOPE45_TR1"},
		{"ghz_grass1_slope45_tr2",       "full", "MAPS_GHZ_GRASS1_SLOPE45_TR2"},
		{"ghz_grass1_slope45_bl1", "slope45_bl", "MAPS_GHZ_BLOCK1_SLOPE45_BL1"},
		{"ghz_grass1_slope45_br1", "slope45_br", "MAPS_GHZ_BLOCK1_SLOPE45_BR1"},
	"end",


	--{layout = "grass_slope30"},
	"layout grass_slope30",

		{"ghz_grass1_slope30_tl1", "slope30_tl1", "MAPS_GHZ_GRASS1_SLOPE30_TL1"},
		{"ghz_grass1_slope30_tl2",        "full", "MAPS_GHZ_GRASS1_SLOPE30_TL2"},
		{"ghz_grass1_slope30_tl3", "slope30_tl2", "MAPS_GHZ_GRASS1_SLOPE30_TL3"},
		{"ghz_grass1_slope30_tl4",        "full", "MAPS_GHZ_GRASS1_SLOPE30_TL4"},

		{"ghz_grass1_slope30_tr1", "slope30_tr1", "MAPS_GHZ_GRASS1_SLOPE30_TR1"},
		{"ghz_grass1_slope30_tr2",        "full", "MAPS_GHZ_GRASS1_SLOPE30_TR2"},
		{"ghz_grass1_slope30_tr3", "slope30_tr2", "MAPS_GHZ_GRASS1_SLOPE30_TR3"},
		{"ghz_grass1_slope30_tr4",        "full", "MAPS_GHZ_GRASS1_SLOPE30_TR4"},

		{"ghz_grass1_slope30_bl1", "slope30_bl1", "MAPS_GHZ_BLOCK1_SLOPE30_BL1"},
		{"ghz_grass1_slope30_bl2", "slope30_bl2", "MAPS_GHZ_BLOCK1_SLOPE30_BL2"},

		{"ghz_grass1_slope30_br1", "slope30_br1", "MAPS_GHZ_BLOCK1_SLOPE30_BR1"},
		{"ghz_grass1_slope30_br2", "slope30_br2", "MAPS_GHZ_BLOCK1_SLOPE30_BR2"},

	"end",


	--{layout = "grass_slope60"},
	"layout grass_slope60",

		{"ghz_grass1_slope60_tl1", "slope60_tl1", "MAPS_GHZ_GRASS1_SLOPE60_TL1"},
		{"ghz_grass1_slope60_tl2", "slope60_tl2", "MAPS_GHZ_GRASS1_SLOPE60_TL2"},
		{"ghz_grass1_slope60_tl3",        "full", "MAPS_GHZ_GRASS1_SLOPE60_TL3"},

		{"ghz_grass1_slope60_tr1", "slope60_tr1", "MAPS_GHZ_GRASS1_SLOPE60_TR1"},
		{"ghz_grass1_slope60_tr2", "slope60_tr2", "MAPS_GHZ_GRASS1_SLOPE60_TR2"},
		{"ghz_grass1_slope60_tr3",        "full", "MAPS_GHZ_GRASS1_SLOPE60_TR3"},

		{"ghz_grass1_slope60_bl1", "slope60_bl1", "MAPS_GHZ_BLOCK1_SLOPE60_BL1"},
		{"ghz_grass1_slope60_bl2", "slope60_bl2", "MAPS_GHZ_BLOCK1_SLOPE60_BL2"},

		{"ghz_grass1_slope60_br1", "slope60_br1", "MAPS_GHZ_BLOCK1_SLOPE60_BR1"},
		{"ghz_grass1_slope60_br2", "slope60_br2", "MAPS_GHZ_BLOCK1_SLOPE60_BR2"},

	"end",


	--{layout = "line2"},
	"layout line2",
		{"blue_crawla_left" , "empty", spawn="blue_crawla", editonly=true,            scale=FU/40, "POSSA3A7"},
		{"blue_crawla_right", "empty", spawn="blue_crawla", editonly=true, flip=true, scale=FU/40, "POSSA3A7"},
	"end",
}
