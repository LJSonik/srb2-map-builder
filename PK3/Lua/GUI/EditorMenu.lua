local gui = ljrequire "ljgui"
local ci = ljrequire "custominput"
local bs = ljrequire "bytestream"


local FU = FRACUNIT


local wheelDef = {
	{
		text = function()
			return "Layer " .. maps.client.player.builderlayer
		end,
		onTrigger = function()
			local p = maps.client.player
			p.builderlayer = ($ % 4) + 1

			local cmd = maps.prepareEditorCommand("set_cursor_layer")
			bs.writeUInt(cmd, 2, p.builderlayer - 1)
			ci.send(cmd)
		end
	},
	{
		text = "Zoom",
		{
			text = "Zoom +",
			onTrigger = function()
				local p = maps.client.player

				if p.editorrenderscale ~= 16 then
					p.editorrenderscale = $ * 2

					if p.builder then
						p.renderscale = p.editorrenderscale
						maps.centerClientCamera(p)
					end
				end
			end
		},
		false,
		false,
		false,
		{
			text = "Zoom -",
			onTrigger = function()
				local p = maps.getPlayer(consoleplayer)

				if p.editorrenderscale ~= 4 then
					p.editorrenderscale = $ / 2

					if p.builder then
						p.renderscale = p.editorrenderscale
						maps.centerClientCamera(p)
					end
				end
			end
		},
	},
	{
		text = "Play",
		/*{
			text = "From here",

			onTrigger = function()
				ci.send(maps.prepareEditorCommand("play"))
				maps.closeEditorMenu()
			end
		},*/
		false,
		false,
		{
			text = "From test spawn",
			onTrigger = function()
				ci.send(maps.prepareEditorCommand("play"))
				maps.closeEditorMenu()
			end
		},
		false,
		{
			text = "From start",
			onTrigger = function()
				ci.send(maps.prepareEditorCommand("play"))
				maps.closeEditorMenu()
			end
		},
	},
	{
		text = "Bucket fill",
		onTrigger = function()
			ci.send(maps.prepareEditorCommand("bucket_fill_mode"))
			maps.enterEditorMode(maps.client.player, "bucket_fill")
			maps.closeEditorMenu()
		end
	},
	{
		text = "Pen",
		onTrigger = function()
			ci.send(maps.prepareEditorCommand("pen_mode"))
			maps.enterEditorMode(maps.client.player, "pen")
			maps.closeEditorMenu()
		end
	},
	false,
	false,
	false,
}


local Menu, base = gui.extend(gui.Area)
maps.EditorMenu = Menu


local buttonBackgroundColor = 31
local buttonBorderColor = 0


local function getButtonNumFromKeys(cmd)
	local left, right, up, down = maps.getLocalKeys(cmd)
	local sel

	if left then
		if up then
			sel = 4
		elseif down then
			sel = 6
		else
			sel = 5
		end
	elseif right then
		if up then
			sel = 2
		elseif down then
			sel = 8
		else
			sel = 1
		end
	elseif up then
		sel = 3
	elseif down then
		sel = 7
	end

	return sel
end

local function isButtonNumDiagonal(index)
	return (index ~= nil and index % 2 == 0)
end

local wheelPositions = {
	{ 1,  0},
	{ 1, -1},
	{ 0, -1},
	{-1, -1},
	{-1,  0},
	{-1,  1},
	{ 0,  1},
	{ 1,  1},
}

local function setupButtonTexts(self)
	for index, bt in pairs(self.wheelButtons) do
		local def = self.wheelDef[index]
		local text = def.text

		if type(text) == "function" then
			text = text()
		end
		bt:setText(text)
	end
end

-- Called when the "wheel" menu at the center is opened
-- or one of its submenus is opened
function Menu:setupButtons()
	-- Get rid of the previously displayed buttons, if any
	if self.wheelButtons then
		for i, bt in pairs(self.wheelButtons) do
			self.detach(bt)
			self.wheelButtons[i] = nil
		end
	end
	self.wheelButtons = {}

	local dist = 64 * FU
	local w, h = 48 * FU, 24 * FU
	local cx, cy = self:getCenter()

	for index, pos in ipairs(wheelPositions) do
		local def = self.wheelDef[index]
		if not def then continue end

		local bt = gui.Button()
		self.wheelButtons[index] = self:attachBack(bt)

		bt:setSize(w, h)
		bt:setNormalBackgroundColor(buttonBackgroundColor)
		bt:setNormalBorderColor(buttonBorderColor)
		bt:setPressedBackgroundColor(153)
		bt:setPressedBorderColor(153)

		local x = cx - w / 2 + dist * pos[1]
		local y = cy - h / 2 + dist * pos[2]
		bt:move(x, y)

		if def.onTrigger then
			bt.onTrigger = function()
				def.onTrigger()
				setupButtonTexts(self)
				self.notUsedYet = false
			end
		elseif def[1] ~= nil then
			bt.onTrigger = function()
				-- Open the button's submenu
				self.wheelDef = def
				self:setupButtons()
				self.notUsedYet = false
			end
		end
	end

	setupButtonTexts(self)
end

function Menu:setup()
	self:disable()
	self:move(0, 0)
	self:setSize(gui.screen.width, gui.screen.height)

	/*local dist = 64 * FU
	local w, h = 48 * FU, 24 * FU
	local cx, cy = self:getCenter()
	local button

	local function addButton(name, text, x, y)
		button = gui.Button()
		self[name] = self:attach(button)

		button:setSize(w, h)
		button:move(cx - w / 2 + dist * x, cy - h / 2 + dist * y)

		button:setText(text)
		button:setBackgroundColor(153)
	end

	addButton("playButton", "Play", 0, -1)
	addButton("zoomOutButton", "Zoom out", -1, 0)
	addButton("zoomInButton", "Zoom in", 1, 0)*/
end

function Menu:handleEvents()
	local cmd = gui.cmd

	local oldButtonNum = self.pressedButtonNum
	local newButtonNum = getButtonNumFromKeys(cmd)
	local oldButton = self.wheelButtons[oldButtonNum]
	local newButton = self.wheelButtons[newButtonNum]

	if oldButtonNum ~= newButtonNum then
		if newButtonNum ~= nil then
			if not isButtonNumDiagonal(oldButtonNum) then
				if oldButton then
					oldButton:release()
				end

				if newButton then
					if not newButton.pressed then
						newButton:press()
					end

					if isButtonNumDiagonal(newButtonNum) then
						newButton:trigger()
					end
				end

				self.pressedButtonNum = newButtonNum
			end
		else
			if oldButton then
				oldButton:release()

				if not isButtonNumDiagonal(oldButtonNum) then
					oldButton:trigger()
				end
			end

			self.pressedButtonNum = nil
		end
	end

	if cmd.buttons & BT_SPIN and not (self.prevButtons & BT_SPIN) then
		if self.notUsedYet then
			local picker = maps.TilePicker()
			gui.screen.tilePicker = gui.screen:attach(picker)
			picker:setup()
			picker:focus()
		end

		maps.closeEditorMenu()
	end

	self.prevButtons = cmd.buttons
end


function maps.openEditorMenu()
	local menu = gui.screen.editorMenu

	menu.notUsedYet = true
	menu.prevButtons = gui.cmd.buttons

	menu.wheelDef = wheelDef
	menu:setupButtons()

	menu:enable()
	menu:focus()

	/*local cp = maps.PaletteColorPicker()
	menu:attach(cp)
	cp:move((320 - 16 - 64) * FU, 16 * FU)

	function cp:onColorPicked(color)
		buttonBackgroundColor = color
		menu:setupButtons()
	end

	cp:setup()

	local cp = maps.PaletteColorPicker()
	menu:attach(cp)
	cp:move((320 - 16 - 64) * FU, (200 - 16 - 64) * FU)

	function cp:onColorPicked(color)
		buttonBorderColor = color
		menu:setupButtons()
	end

	cp:setup()*/
end

function maps.closeEditorMenu()
	gui.screen.editorMenu:disable()
	gui.screen.editorMenu:unfocus() -- !!!
	--maps.client.ignorespin = true
end
