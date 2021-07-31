maps.addLayout{
	id = "loop_tl",

	{1, 6, 7, 8},

	{4, 5, 0, 0},

	{3, 0, 0, 0},

	{2, 0, 0, 0},
}

maps.addLayout{
	id = "loop",
	splitx = 4,
	splity = 4,

	{ 1, 6, 7, 8, 9,10,11, 1},

	{ 4, 5, 0, 0, 0, 0,12,13},

	{ 3, 0, 0, 0, 0, 0, 0,14},

	{ 2, 0, 0, 0, 0, 0, 0,15},

	{29, 0, 0, 0, 0, 0, 0,16},

	{28, 0, 0, 0, 0, 0, 0,17},

	{27,26, 0, 0, 0, 0,19,18},

	{ 1,25,24,23,22,21,20, 1},
}

maps.addLayout{
	id = "circle",
	splitx = 4,
	splity = 4,

	{ 0, 6, 7, 8, 9,10,11, 0},

	{ 4, 5, 1, 1, 1, 1,12,13},

	{ 3, 1, 1, 1, 1, 1, 1,14},

	{ 2, 1, 1, 1, 1, 1, 1,15},

	{29, 1, 1, 1, 1, 1, 1,16},

	{28, 1, 1, 1, 1, 1, 1,17},

	{27,26, 1, 1, 1, 1,19,18},

	{ 0,25,24,23,22,21,20, 0},
}

maps.addLayout{
	id = "grass_slope45",
	splitx = 1,
	splity = 2,

	{1, 3},
	{2, 4},
	{5, 6},
}

maps.addLayout{
	id = "grass_slope30",
	splitx = 2,
	splity = 2,

	{1, 3, 5, 7},
	{2, 4, 6, 8},
	{9,10,11,12},
}

maps.addLayout{
	id = "grass_slope60",
	splitx = 1,
	splity = 3,

	{1, 4},
	{2, 5},
	{3, 6},
	{7, 9},
	{8,10},
}

maps.addLayout{
	id = "line2",

	{1, 2},
}

maps.addLayout{
	id = "line3",

	{1, 2, 3},
}

maps.addLayout{
	id = "line4",

	{1, 2, 3, 4},
}

maps.addLayout{
	id = "column2",

	{1},
	{2},
}

maps.addLayout{
	id = "column3",

	{1},
	{2},
	{3},
}

maps.addLayout{
	id = "column4",

	{1},
	{2},
	{3},
	{4},
}

for w = 1, 8 do
	for h = 1, 8 do
		local layout = {id = "rectangle"..w.."x"..h}

		local i = 1
		for y = 1, h do
			layout[y] = {}
			for x = 1, w do
				layout[y][x] = i
				i = i + 1
			end
		end

		maps.addLayout(layout)
	end
end
