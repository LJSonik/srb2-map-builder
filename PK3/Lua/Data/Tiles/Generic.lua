local FU = FRACUNIT


local ringanim = {spd=1, prefix="RING", "A0","B0X0","C0W0","D0V0","E0U0","F0T0","G0S0","H0R0","I0Q0","J0P0","K0O0","L0N0","M0","L0N0","K0O0","J0P0","I0Q0","H0R0","G0S0","F0T0","E0U0","D0V0","C0W0","B0X0"}


maps.addTileCategory{
	id = "generic",
	name = "Generic",
	icon = "RINGA0"
}

maps.addTiles{
	category = "generic",

	{"air", "empty", hidden=true, noedit=true, "NULLA0"},

	{"span", "full", hidden=true, noedit=true, "NULLA0"},

	{"ring", "empty", on_hit=maps.on_ring_hit, align="center", w=FU*3/4, ringanim},
	{"ring_picked", "empty", respawn=true, hidden=true, noedit=true, "NULLA0"},


	{"bluespring_up"          , "empty", on_hit=maps.on_spring_hit, angle=270, strength=FU*5/8, align="bottom", offset=true, scale=FU/44, "SPRBA0"},
	{"bluespring_up_active"   , copyprev=true, on_draw=maps.on_spring_draw, respawn=true, noedit=true, {spd=1, prefix="SPRB", "E0","E0","E0","E0","D0","C0","B0"}},

	{"bluespring_down"        , copy="bluespring_up", angle=90, offset=true, align="top", "BLUESPRING_DOWN1"},
	{"bluespring_down_active" , copyprev=true, on_draw=maps.on_spring_draw, respawn=true, noedit=true, {spd=1, prefix="BLUESPRING_DOWN", "5","5","5","5","4","3","2"}},

	{"bluespring_left"        , copy="bluespring_down", angle=180, offset=false, align="right", "SSWBA3A7"},
	{"bluespring_left_active" , copyprev=true, on_draw=maps.on_spring_draw, respawn=true, noedit=true, {spd=1, prefix="SSWB", "E3E7","E3E7","E3E7","E3E7","D3D7","C3C7","B3B7"}},

	{"bluespring_right"       , copy="bluespring_left", angle=0, flip=true, offset=false, align="left", "SSWBA3A7"},
	{"bluespring_right_active", copyprev=true, on_draw=maps.on_spring_draw, respawn=true, noedit=true, {spd=1, prefix="SSWB", "E3E7","E3E7","E3E7","E3E7","D3D7","C3C7","B3B7"}},

	{"bluespring_upleft"          , "empty", on_hit=maps.on_diagonal_spring_hit, angle=225, strength=FU*6/8, align="bottomright", scale=FU/44, "BSPRA3"},
	{"bluespring_upleft_active"   , copyprev=true, on_draw=maps.on_spring_draw, respawn=true, noedit=true, {spd=1, prefix="BSPR", "E3","E3","E3","E3","D3","C3","B3"}},

	{"bluespring_upright"         , copy="bluespring_upleft", angle=315, flip=true, align="bottomleft", "BSPRA3"},
	{"bluespring_upright_active"  , copyprev=true, on_draw=maps.on_spring_draw, respawn=true, noedit=true, {spd=1, prefix="BSPR", "E3","E3","E3","E3","D3","C3","B3"}},

	{"bluespring_downleft"        , copy="bluespring_upright", angle=135, flip=false, align="topright", "BLUESPRING_DOWNLEFT1"},
	{"bluespring_downleft_active" , copyprev=true, on_draw=maps.on_spring_draw, respawn=true, noedit=true, {spd=1, prefix="BLUESPRING_DOWNLEFT", "5","5","5","5","4","3","2"}},

	{"bluespring_downright"       , copy="bluespring_downleft", angle=45, flip=true, align="topleft", "BLUESPRING_DOWNLEFT1"},
	{"bluespring_downright_active", copyprev=true, on_draw=maps.on_spring_draw, respawn=true, noedit=true, {spd=1, prefix="BLUESPRING_DOWNLEFT", "5","5","5","5","4","3","2"}},

	/*{"bluespring_up"   , "empty", on_hit=maps.on_spring_hit, angle=270, strength=FU*5/8,            align="bottom", offset=true, scale=FU/44, "SPRBA0"},
	{"bluespring_down" , "empty", on_hit=maps.on_spring_hit, angle= 90, strength=FU*5/8,            align="top"   , offset=true, scale=FU/44, "BLUESPRING_DOWN1"},
	{"bluespring_left" , "empty", on_hit=maps.on_spring_hit, angle=180, strength=FU*5/8,            align="right"              , scale=FU/44, "SSWBA3A7"},
	{"bluespring_right", "empty", on_hit=maps.on_spring_hit, angle=  0, strength=FU*5/8, flip=true, align="left"               , scale=FU/44, "SSWBA3A7"},
	{"bluespring_upleft"   , "empty", on_hit=maps.on_diagonal_spring_hit, angle=225, strength=FU*6/8,            align="bottomright", scale=FU/44, "BSPRA3"},
	{"bluespring_upright"  , "empty", on_hit=maps.on_diagonal_spring_hit, angle=315, strength=FU*6/8, flip=true, align="bottomleft" , scale=FU/44, "BSPRA3"},
	{"bluespring_downleft" , "empty", on_hit=maps.on_diagonal_spring_hit, angle=135, strength=FU*6/8,            align="topright"   , scale=FU/44, "BSPRA3"},
	{"bluespring_downright", "empty", on_hit=maps.on_diagonal_spring_hit, angle= 45, strength=FU*6/8, flip=true, align="topleft"    , scale=FU/44, "BSPRA3"},*/


	{"yellowspring_up"          , "empty", on_hit=maps.on_spring_hit, angle=270, strength=FU*7/8, align="bottom", offset=true, scale=FU/44, "SPRYA0"},
	{"yellowspring_up_active"   , copyprev=true, on_draw=maps.on_spring_draw, respawn=true, noedit=true, {spd=1, prefix="SPRY", "E0","E0","E0","E0","D0","C0","B0"}},

	{"yellowspring_down"        , copy="yellowspring_up", angle=90, offset=true, align="top", "YELLOWSPRING_DOWN1"},
	{"yellowspring_down_active" , copyprev=true, on_draw=maps.on_spring_draw, respawn=true, noedit=true, {spd=1, prefix="YELLOWSPRING_DOWN", "5","5","5","5","4","3","2"}},

	{"yellowspring_left"        , copy="yellowspring_down", angle=180, offset=false, align="right", "SSWYA3A7"},
	{"yellowspring_left_active" , copyprev=true, on_draw=maps.on_spring_draw, respawn=true, noedit=true, {spd=1, prefix="SSWY", "E3E7","E3E7","E3E7","E3E7","D3D7","C3C7","B3B7"}},

	{"yellowspring_right"       , copy="yellowspring_left", angle=0, flip=true, offset=false, align="left", "SSWYA3A7"},
	{"yellowspring_right_active", copyprev=true, on_draw=maps.on_spring_draw, respawn=true, noedit=true, {spd=1, prefix="SSWY", "E3E7","E3E7","E3E7","E3E7","D3D7","C3C7","B3B7"}},

	{"yellowspring_upleft"          , "empty", on_hit=maps.on_diagonal_spring_hit, angle=225, strength=FU*8/8, align="bottomright", scale=FU/44, "YSPRA3"},
	{"yellowspring_upleft_active"   , copyprev=true, on_draw=maps.on_spring_draw, respawn=true, noedit=true, {spd=1, prefix="YSPR", "E3","E3","E3","E3","D3","C3","B3"}},

	{"yellowspring_upright"         , copy="yellowspring_upleft", angle=315, flip=true, align="bottomleft", "YSPRA3"},
	{"yellowspring_upright_active"  , copyprev=true, on_draw=maps.on_spring_draw, respawn=true, noedit=true, {spd=1, prefix="YSPR", "E3","E3","E3","E3","D3","C3","B3"}},

	{"yellowspring_downleft"        , copy="yellowspring_upright", angle=135, flip=false, align="topright", "YELLOWSPRING_DOWNLEFT1"},
	{"yellowspring_downleft_active" , copyprev=true, on_draw=maps.on_spring_draw, respawn=true, noedit=true, {spd=1, prefix="YELLOWSPRING_DOWNLEFT", "5","5","5","5","4","3","2"}},

	{"yellowspring_downright"       , copy="yellowspring_downleft", angle=45, flip=true, align="topleft", "YELLOWSPRING_DOWNLEFT1"},
	{"yellowspring_downright_active", copyprev=true, on_draw=maps.on_spring_draw, respawn=true, noedit=true, {spd=1, prefix="YELLOWSPRING_DOWNLEFT", "5","5","5","5","4","3","2"}},

	{"yellowballspring_up"       , copy="yellowspring_up", "YSPBA0"},
	{"yellowballspring_up_active", copyprev=true, on_draw=maps.on_spring_draw, respawn=true, noedit=true, {spd=1, prefix="YSPB", "E0","E0","E0","E0","D0","C0","B0"}},


	{"redspring_up"          , "empty", on_hit=maps.on_spring_hit, angle=270, strength=FU*9/8, align="bottom", offset=true, scale=FU/44, "SPRRA0"},
	{"redspring_up_active"   , copyprev=true, on_draw=maps.on_spring_draw, respawn=true, noedit=true, {spd=1, prefix="SPRR", "E0","E0","E0","E0","D0","C0","B0"}},

	{"redspring_down"        , copy="redspring_up", angle=90, offset=true, align="top", "REDSPRING_DOWN1"},
	{"redspring_down_active" , copyprev=true, on_draw=maps.on_spring_draw, respawn=true, noedit=true, {spd=1, prefix="REDSPRING_DOWN", "5","5","5","5","4","3","2"}},

	{"redspring_left"        , copy="redspring_down", angle=180, offset=false, align="right", "SSWRA3A7"},
	{"redspring_left_active" , copyprev=true, on_draw=maps.on_spring_draw, respawn=true, noedit=true, {spd=1, prefix="SSWR", "E3E7","E3E7","E3E7","E3E7","D3D7","C3C7","B3B7"}},

	{"redspring_right"       , copy="redspring_left", angle=0, flip=true, offset=false, align="left", "SSWRA3A7"},
	{"redspring_right_active", copyprev=true, on_draw=maps.on_spring_draw, respawn=true, noedit=true, {spd=1, prefix="SSWR", "E3E7","E3E7","E3E7","E3E7","D3D7","C3C7","B3B7"}},

	{"redspring_upleft"          , "empty", on_hit=maps.on_diagonal_spring_hit, angle=225, strength=FU*10/8, align="bottomright", scale=FU/44, "RSPRA3"},
	{"redspring_upleft_active"   , copyprev=true, on_draw=maps.on_spring_draw, respawn=true, noedit=true, {spd=1, prefix="RSPR", "E3","E3","E3","E3","D3","C3","B3"}},

	{"redspring_upright"         , copy="redspring_upleft", angle=315, flip=true, align="bottomleft", "RSPRA3"},
	{"redspring_upright_active"  , copyprev=true, on_draw=maps.on_spring_draw, respawn=true, noedit=true, {spd=1, prefix="RSPR", "E3","E3","E3","E3","D3","C3","B3"}},

	{"redspring_downleft"        , copy="redspring_upright", angle=135, flip=false, align="topright", "REDSPRING_DOWNLEFT1"},
	{"redspring_downleft_active" , copyprev=true, on_draw=maps.on_spring_draw, respawn=true, noedit=true, {spd=1, prefix="REDSPRING_DOWNLEFT", "5","5","5","5","4","3","2"}},

	{"redspring_downright"       , copy="redspring_downleft", angle=45, flip=true, align="topleft", "REDSPRING_DOWNLEFT1"},
	{"redspring_downright_active", copyprev=true, on_draw=maps.on_spring_draw, respawn=true, noedit=true, {spd=1, prefix="REDSPRING_DOWNLEFT", "5","5","5","5","4","3","2"}},

	{"redballspring_up"       , copy="redspring_up", "RSPBA0"},
	{"redballspring_up_active", copyprev=true, on_draw=maps.on_spring_draw, respawn=true, noedit=true, {spd=1, prefix="RSPB", "E0","E0","E0","E0","D0","C0","B0"}},

	/*{"redspring_up"   , "empty", on_hit=maps.on_spring_hit, angle=270, strength=FU*9/8,            align="bottom", offset=true, scale=FU/44, "SPRRA0"},
	{"redspring_down" , "empty", on_hit=maps.on_spring_hit, angle= 90, strength=FU*9/8,            align="top"   , offset=true, scale=FU/44, "REDSPRING_DOWN1"},
	{"redspring_left" , "empty", on_hit=maps.on_spring_hit, angle=180, strength=FU*9/8,            align="right"              , scale=FU/44, "SSWRA3A7"},
	{"redspring_right", "empty", on_hit=maps.on_spring_hit, angle=  0, strength=FU*9/8, flip=true, align="left"               , scale=FU/44, "SSWRA3A7"},
	{"redspring_upleft"   , "empty", on_hit=maps.on_diagonal_spring_hit, angle=225, strength=FU*10/8,            align="bottomright", scale=FU/44, "RSPRA3"},
	{"redspring_upright"  , "empty", on_hit=maps.on_diagonal_spring_hit, angle=315, strength=FU*10/8, flip=true, align="bottomleft" , scale=FU/44, "RSPRA3"},
	{"redspring_downleft" , "empty", on_hit=maps.on_diagonal_spring_hit, angle=135, strength=FU*10/8,            align="topright"   , scale=FU/44, "RSPRA3"},
	{"redspring_downright", "empty", on_hit=maps.on_diagonal_spring_hit, angle= 45, strength=FU*10/8, flip=true, align="topleft"    , scale=FU/44, "RSPRA3"},
	{"redballspring_up", "empty", on_hit=maps.on_spring_hit, angle=270, strength=FU*9/8, align="bottom", offset=true, scale=FU/44, "RSPBA0"},*/
}
