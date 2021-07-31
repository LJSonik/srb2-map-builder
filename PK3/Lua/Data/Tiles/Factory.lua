if true then return end


local FU = FRACUNIT


maps.addTileCategory{
	id = "factory",
	name = "Factory",
	icon = "THZWAL01"
}

maps.addTiles{
	category = "factory",


	{"thz_metal1", "full", "THZWAL01"},
	{"thz_metal2", "full", "THZWALLA"},
	{"thz_metal3", "full", "THZWALLB"},
	{"thz_metal4", "full", "THZWAL09"},
	{"thz_metal5", "full", "THZWALLF"},
	{"thz_metal6", "full", "THZWAL11"},

	{"thz_metal1_big", "full", spanw=2, spanh=2, "THZWAL01"},
	{"thz_metal2_big", "full", spanw=2, spanh=2, "THZWALLA"},
	{"thz_metal3_big", "full", spanw=2, spanh=2, "THZWALLB"},
	{"thz_metal6_big", "full", spanw=2, spanh=2, "THZWAL11"},

	{"thz_tiles1", "full", "THZWALLE"},

	{"thz_steel1", "full", "STEELW"},
	{"thz_steel2", "full", "STEEL3W"},
	{"thz_steel3", "full", "STEEL2W"},
	{"thz_steel4", "full", "STEEL4W"},
	{"thz_steel5", "full", "STEEL4WB"},

	{"thz_box" , "full", spanw=2, spanh=2, "THZBOX"},
	{"thz_box2", "full", spanw=2, spanh=2, "BOXWARN2"},
	{"thz_box3", "full", spanw=2, spanh=2, "BOXWARNG"},
	{"thz_box", "full", spanw=2, spanh=2, {spd=2,"THZBOX01","THZBOX02","THZBOX03","THZBOX04"}},

	--{"thz_", "full", ""},

	--{"thz_", "full", ""},

	{"thz_pipe1_white_h", "full", "THZWAL02"},
	{"thz_pipe1_white_v", "full", "THZWAL03"},
	{"thz_pipe2_white"  , "full", "THZWAL05"},

	{"thz_pipe1_black_h", "full", "THZWALLC"},
	{"thz_pipe1_black_v", "full", "THZWALLD"},
	{"thz_pipe2_black"  , "full", "THZWALLG"},

	{"thz_black1_h", "full", "THZWAL07"},
	{"thz_black1_v", "full", "THZWAL06"},
	{"thz_board1", "full", "THZWAL08"},
	{"thz_door1", "full", "THZWAL04"},

	{"thz_greenbar1_h" , "full", spanw=2, "THZ2W3HB"},
	{"thz_greenbar1_v" , "full", spanh=2, "THZ2W3B" },
	{"thz_greenbars1_h", "full", spanw=2, "THZ2W3H" },
	{"thz_greenbars1_v", "full", spanh=2, "THZ2W3"  },

	{"thz_bluebar1_h" , "full", spanw=2, "THZ2W4HB"},
	{"thz_bluebar1_v" , "full", spanh=2, "THZ2W4B" },
	{"thz_bluebars1_h", "full", spanw=2, "THZ2W4H" },
	{"thz_bluebars1_v", "full", spanh=2, "THZ2W4"  },

	{"thz_yellowbar2_h" , "full", spanw=2, "THZ2C1HB"},
	{"thz_yellowbar2_v" , "full", spanh=2, "THZ2C1B" },
	{"thz_yellowbars2_h", "full", spanw=2, "THZ2C1H" },
	{"thz_yellowbars2_v", "full", spanh=2, "THZ2C1"  },

	{"thz_redbar2_h" , "full", spanw=2, "THZ2C2HB"},
	{"thz_redbar2_v" , "full", spanh=2, "THZ2C2B" },
	{"thz_redbars2_h", "full", spanw=2, "THZ2C2H" },
	{"thz_redbars2_v", "full", spanh=2, "THZ2C2"  },

	{"thz_greenbar2_h" , "full", spanw=2, "THZ2C3HB"},
	{"thz_greenbar2_v" , "full", spanh=2, "THZ2C3B" },
	{"thz_greenbars2_h", "full", spanw=2, "THZ2C3H" },
	{"thz_greenbars2_v", "full", spanh=2, "THZ2C3"  },

	{"thz_bluebar2_h" , "full", spanw=2, "THZ2C4HB"},
	{"thz_bluebar2_v" , "full", spanh=2, "THZ2C4B" },
	{"thz_bluebars2_h", "full", spanw=2, "THZ2C4H" },
	{"thz_bluebars2_v", "full", spanh=2, "THZ2C4"  },

	{"thz_window1", "full", spanw=2, spanh=2, "THZ2WINA"},
	{"thz_window2", "full", spanw=2, spanh=2, "THZ2WINB"},
	{"thz_window3", "full", spanw=2, spanh=2, "THZ2WINC"},
	{"thz_window4", "full", spanw=2, spanh=2, "THZ2WIND"},
	{"thz_window5", "full", spanw=2, spanh=2, "THZ2WINE"},
	{"thz_window6", "full", spanw=2, spanh=2, "THZ2WINF"},
}
