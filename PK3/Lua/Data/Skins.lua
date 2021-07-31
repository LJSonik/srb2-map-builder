local FU = FRACUNIT


maps.addSkin{
	id = "sonic",

	speed = FU * 6 / 8,
	runspeed = FU * 4 / 8,
	acc = FU / 96,
	minspindashspeed = FU * 2 / 8,
	maxspindashspeed = FU * 11 / 16,

	icon = "LIVSONIC",

	anim = {
		stand    = {spd =  9, sprite2 = SPR2_STND, frames = 1},
		walk     = {spd = 16, sprite2 = SPR2_WALK, frames = 8},
		run      = {spd =  1, sprite2 = SPR2_RUN_, frames = 4},
		roll     = {spd =  1, sprite2 = SPR2_ROLL, frames = 6},
		spindash = {spd =  2, sprite2 = SPR2_SPIN, frames = 4},
		spring   = {spd =  9, sprite2 = SPR2_SPNG, frames = 1},
		fall     = {spd =  2, sprite2 = SPR2_FALL, frames = 2},
		carry    = {spd =  9, sprite2 = SPR2_RIDE, frames = 1},
		pain     = {spd =  9, sprite2 = SPR2_PAIN, frames = 1},
		die      = {spd =  9, sprite2 = SPR2_DEAD, frames = 1},
	}
}

maps.addSkin{
	id = "tails",

	speed = FU * 6 / 8,
	runspeed = FU * 4 / 8,
	acc = FU / 96,
	minspindashspeed = FU * 1 / 4,
	maxspindashspeed = FU * 11 / 16,
	fly = 8 * TICRATE,

	icon = "LIVTAILS",

	anim = {
		stand    = {spd =  9, sprite2 = SPR2_STND, frames = 1},
		walk     = {spd = 16, sprite2 = SPR2_WALK, frames = 8},
		run      = {spd =  1, sprite2 = SPR2_RUN_, frames = 2},
		roll     = {spd =  1, sprite2 = SPR2_ROLL, frames = 3},
		spindash = {spd =  2, sprite2 = SPR2_SPIN, frames = 3},
		spring   = {spd =  9, sprite2 = SPR2_SPNG, frames = 1},
		fall     = {spd =  2, sprite2 = SPR2_FALL, frames = 2},
		carry    = {spd =  9, sprite2 = SPR2_RIDE, frames = 1},
		pain     = {spd =  9, sprite2 = SPR2_PAIN, frames = 1},
		die      = {spd =  9, sprite2 = SPR2_DEAD, frames = 1},
		fly      = {spd =  2, sprite2 = SPR2_FLY_, frames = 2},
		tired    = {spd =  6, sprite2 = SPR2_TIRE, frames = 2},
	}
}

maps.addSkin{
	id = "knuckles",

	speed = FU * 6 / 8,
	runspeed = FU * 4 / 8,
	acc = FU / 96,
	minspindashspeed = FU * 1 / 4,
	maxspindashspeed = FU * 11 / 16,
	glideandclimb = true,

	icon = "LIVKNUX",

	anim = {
		stand         = {spd =  9, sprite2 = SPR2_STND, frames = 1},
		walk          = {spd = 16, sprite2 = SPR2_WALK, frames = 8},
		run           = {spd =  1, sprite2 = SPR2_RUN_, frames = 4},
		roll          = {spd =  1, sprite2 = SPR2_ROLL, frames = 5},
		spindash      = {spd =  2, sprite2 = SPR2_SPIN, frames = 4},
		spring        = {spd =  9, sprite2 = SPR2_SPNG, frames = 1},
		fall          = {spd =  2, sprite2 = SPR2_FALL, frames = 2},
		carry         = {spd =  9, sprite2 = SPR2_RIDE, frames = 1},
		pain          = {spd =  9, sprite2 = SPR2_PAIN, frames = 1},
		die           = {spd =  9, sprite2 = SPR2_DEAD, frames = 1},
		glide         = {spd =  2, sprite2 = SPR2_GLID, frames = 2},
		glideslow     = {spd =  2, sprite2 = SPR2_GLID, frames = 2, angle = 2},
		glideveryslow = {spd =  2, sprite2 = SPR2_GLID, frames = 2, angle = 1},
		climb         = {spd =  5, sprite2 = SPR2_CLMB, frames = 4},
		climbstatic   = {spd =  9, sprite2 = SPR2_CLNG, frames = 1},
	}
}

maps.addSkin{
	id = "amy",

	speed = FU * 6 / 8,
	runspeed = FU * 4 / 8,
	acc = FU / 96,
	minspindashspeed = FU * 2 / 8,
	maxspindashspeed = FU * 11 / 16,

	icon = "LIVAMY",

	anim = {
		stand    = {spd =  9, sprite2 = SPR2_STND, frames = 1},
		walk     = {spd = 16, sprite2 = SPR2_WALK, frames = 8},
		run      = {spd =  1, sprite2 = SPR2_RUN_, frames = 8},
		roll     = {spd =  1, sprite2 = SPR2_ROLL, frames = 4},
		spindash = {spd =  1, sprite2 = SPR2_ROLL, frames = 4},
		spring   = {spd =  9, sprite2 = SPR2_SPNG, frames = 1},
		fall     = {spd =  2, sprite2 = SPR2_FALL, frames = 2},
		carry    = {spd =  9, sprite2 = SPR2_RIDE, frames = 1},
		pain     = {spd =  9, sprite2 = SPR2_PAIN, frames = 1},
		die      = {spd =  9, sprite2 = SPR2_DEAD, frames = 1},
	}
}

maps.addSkin{
	id = "fang",

	speed = FU * 6 / 8,
	runspeed = FU * 4 / 8,
	acc = FU / 96,
	minspindashspeed = FU * 2 / 8,
	maxspindashspeed = FU * 11 / 16,

	icon = "LIVFANG",

	anim = {
		stand    = {spd =  9, sprite2 = SPR2_STND, frames = 1},
		walk     = {spd = 16, sprite2 = SPR2_WALK, frames = 8},
		run      = {spd =  1, sprite2 = SPR2_RUN_, frames = 6},
		roll     = {spd =  1, sprite2 = SPR2_ROLL, frames = 4},
		spindash = {spd =  1, sprite2 = SPR2_ROLL, frames = 4},
		spring   = {spd =  9, sprite2 = SPR2_SPNG, frames = 1},
		fall     = {spd =  2, sprite2 = SPR2_FALL, frames = 2},
		carry    = {spd =  9, sprite2 = SPR2_RIDE, frames = 1},
		pain     = {spd =  9, sprite2 = SPR2_PAIN, frames = 1},
		die      = {spd =  9, sprite2 = SPR2_DEAD, frames = 1},
		shoot    = {spd =  2, sprite2 = SPR2_FIRE, frames = 4},
	}
}

maps.addSkin{
	id = "metalsonic",

	speed = FU * 6 / 8,
	runspeed = FU * 4 / 8,
	acc = FU / 96,
	minspindashspeed = FU * 2 / 8,
	maxspindashspeed = FU * 11 / 16,

	icon = "LIVMETAL",

	anim = {
		stand    = {spd =  9, sprite2 = SPR2_STND, frames = 1},
		walk     = {spd = 16, sprite2 = SPR2_WALK, frames = 1},
		run      = {spd =  1, sprite2 = SPR2_RUN_, frames = 1},
		roll     = {spd =  1, sprite2 = SPR2_ROLL, frames = 6},
		spindash = {spd =  2, sprite2 = SPR2_SPIN, frames = 4},
		spring   = {spd =  9, sprite2 = SPR2_SPNG, frames = 1},
		fall     = {spd =  2, sprite2 = SPR2_FALL, frames = 1},
		carry    = {spd =  9, sprite2 = SPR2_RIDE, frames = 1},
		pain     = {spd =  9, sprite2 = SPR2_PAIN, frames = 1},
		die      = {spd =  9, sprite2 = SPR2_DEAD, frames = 1},
	}
}

/*maps.addSkin{
	id = "earless",

	speed = FU * 6 / 8,
	runspeed = FU * 4 / 8,
	acc = FU / 8,
	mindash = FU / 4,
	maxdash = FU * 3 / 4,

	icon = "LIVKNUX",

	anim = {
		stand    = {spd =  9, sprite2 = SPR2_STND, frames = 1},
		walk     = {spd = 16, sprite2 = SPR2_WALK, frames = 4},
		run      = {spd =  1, sprite2 = SPR2_RUN_, frames = 4},
		roll     = {spd =  1, sprite2 = SPR2_ROLL, frames = 4},
		spring   = {spd =  9, sprite2 = SPR2_SPNG, frames = 1},
		fall     = {spd =  2, sprite2 = SPR2_FALL, frames = 1},
		carry    = {spd =  9, sprite2 = SPR2_RIDE, frames = 1},
		pain     = {spd =  9, sprite2 = SPR2_PAIN, frames = 1},
		die      = {spd =  9, sprite2 = SPR2_DEAD, frames = 1},
	}
}

maps.addSkin{
	id = "earlessredesign",

	speed = FU * 6 / 8,
	runspeed = FU * 4 / 8,
	acc = FU / 2,
	mindash = FU / 4,
	maxdash = FU * 3 / 4,

	icon = "LIVKNUX",

	anim = {
		stand    = {spd =  9, sprite2 = SPR2_STND, frames = 1},
		walk     = {spd = 16, sprite2 = SPR2_WALK, frames = 8},
		run      = {spd =  1, sprite2 = SPR2_RUN_, frames = 4},
		roll     = {spd =  1, sprite2 = SPR2_ROLL, frames = 4},
		spring   = {spd =  9, sprite2 = SPR2_SPNG, frames = 1},
		fall     = {spd =  2, sprite2 = SPR2_FALL, frames = 1},
		carry    = {spd =  9, sprite2 = SPR2_RIDE, frames = 1},
		pain     = {spd =  9, sprite2 = SPR2_PAIN, frames = 1},
		die      = {spd =  9, sprite2 = SPR2_DEAD, frames = 1},
	}
}*/
