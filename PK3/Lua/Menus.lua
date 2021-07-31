local menulib = ljrequire "menulib"


local help_page = 1
local HELP_PAGES = 5

local function helptitle(title)
	return {
		text = "\x85"..title,
		skip = true
	}
end

local function helppage()
	local page = help_page

	local line = {
		text = "Page "..page.." of "..HELP_PAGES,
		tip = "Use the left and right keys to change the page, or spin to come back.",
	}

	if page ~= 1 then
		line.left = function(p, t)
			t.id = "help"..page - 1
		end
	end

	if page ~= HELP_PAGES then
		line.right = function(p, t)
			t.id = "help"..page + 1
		end
		line.ok = function(p, t)
			t.id = "help"..page + 1
		end
	end

	help_page = $ + 1

	return line
end

local function helpline(text)
	return {
		text = function() return text, "" end,
		skip = true
	}
end

local function helplinecentered(text)
	return {
		text = text,
		skip = true
	}
end


local menus = {
template = {
	step = 6,
	background = "GHZWALLC",
	backgroundsize = 32,
	border = "GHZWALL7",
	bordersize = 8
},
mainhost = {
	w = 128, h = 128,
	{
		text = function(p)
			return maps.getPlayer(p).builder and "Play" or "Edit"
		end,
		tip = "Switch between testing and editing mode",
		ok = function(owner)
			local n = owner.maps.player
			local p = maps.pp[n]

			if p.builder then
				maps.spawnPlayer(p)
			else
				maps.enterEditor(p)
			end

			menulib.close(owner)
		end
	},
	menulib.separator,
	/*{
		text = function(p)
			return "Zoom: "..maps.getPlayer(p).editorrenderscale
		end,
		tip = "Choose how much area is shown",
		condition = function(p)
			return maps.getPlayer(p).builder
		end,
		left = function(p)
			p = maps.getPlayer(p)

			if p.editorrenderscale ~= 4
				p.editorrenderscale = $ >> 1
			else
				p.editorrenderscale = 16
			end

			if p.builder
				p.renderscale = p.editorrenderscale
				maps.centerCamera(p)
			end
		end,
		right = function(p)
			p = maps.getPlayer(p)

			if p.editorrenderscale ~= 16
				p.editorrenderscale = $ << 1
			else
				p.editorrenderscale = 4
			end

			if p.builder
				p.renderscale = p.editorrenderscale
				maps.centerCamera(p)
			end
		end
	},*/
	{
		text = function(owner)
			return "Layer: "..maps.getPlayer(owner).builderlayer
		end,
		tip = "Shortcut: CUSTOM ACTION 1",
		condition = function(p)
			return maps.getPlayer(p).builder
		end,
		ok = function(owner)
			local p = maps.getPlayer(owner)
			p.builderlayer = ($ % 4) + 1
		end,
		left = function(owner)
			local p = maps.getPlayer(owner)
			p.builderlayer = $ ~= 1 and $ - 1 or 4
		end,
		right = function(owner)
			local p = maps.getPlayer(owner)
			p.builderlayer = ($ % 4) + 1
		end
	},
	{
		text = function(p)
			local layer = maps.getPlayer(p).visiblelayer
			return "Show "..(
				layer == 1 and "layer 1"
				or layer == 2 and "layer 2"
				or layer == 3 and "layer 3"
				or layer == 4 and "layer 4"
				or "all layers"
			)
		end,
		tip = "Choose what layers are displayed in editing mode",
		condition = function(p)
			return maps.getPlayer(p).builder
		end,
		left = function(p)
			maps.getPlayer(p).visiblelayer = not $ and 4 or $ ~= 1 and $ - 1 or nil
		end,
		right = function(p)
			maps.getPlayer(p).visiblelayer = not $ and 1 or $ ~= 4 and $ + 1 or nil
		end
	},
	/*menulib.separator,
	{
		text = "Fill rectangular area",
		tip = "Fill a rectangular area with a tile",
		condition = function(p)
			return maps.getPlayer(p).builder
		end,
		ok = function(player)
			local p = maps.pp[player.maps.player]
			p.fillx, p.filly = p.builderx, p.buildery
			menulib.close(player)
		end
	},
	{
		text = "Remove rectangular area",
		tip = "Remove a rectangular area",
		condition = function(p)
			return maps.getPlayer(p).builder
		end,
		ok = function(player)
			local p = maps.pp[player.maps.player]
			p.fillremove = true
			p.fillx, p.filly = p.builderx, p.buildery
			menulib.close(player)
		end
	},*/
	menulib.separator,
	{
		text = "Set spawn",
		tip = "Set your cursor position as your spawn",
		condition = function(p)
			return maps.getPlayer(p).builder
		end,
		ok = "playerspawnproperties"
	},
	menulib.separator,
	{
		text = "Set map spawn",
		tip = "Set your cursor position as the map spawn",
		condition = function(p)
			return maps.getPlayer(p).builder
		end,
		ok = "mapspawnproperties"
	},
	{text = "Level properties", ok = "properties"},
	{text = "Clear level", ok = "clearmap"},
	menulib.separator,
	{text = "Options", ok = "options"},
	{text = "Help", ok = "help1"},
	{
		text = "Quit",
		tip = cpulib and "Quit the Map Builder" or "You can't quit in stand-alone mode.",
		condition = not cpulib and function() return false end or nil,
		ok = function(owner)
			cpulib.leaveApplication(owner)
		end
	}
},
mainplayer = {
	w = 128, h = 128,
	{
		text = function(p)
			return maps.getPlayer(p).builder and "Play" or "Edit"
		end,
		tip = "Switch between testing and editing mode",
		ok = function(owner)
			local p = maps.getPlayer(owner)

			if p.builder then
				maps.spawnPlayer(p)
			else
				maps.enterEditor(p)
			end

			menulib.close(owner)
		end
	},
	menulib.separator,
	/*{
		text = function(owner)
			return "Zoom: "..maps.getPlayer(owner).editorrenderscale
		end,
		tip = "Choose how much area is shown",
		condition = function(owner)
			return maps.getPlayer(owner).builder
		end,
		left = function(p)
			local p = maps.getPlayer(owner)

			if p.editorrenderscale ~= 4
				p.editorrenderscale = $ >> 1
			else
				p.editorrenderscale = 16
			end

			if p.builder
				p.renderscale = p.editorrenderscale
				maps.centerCamera(p)
			end
		end,
		right = function(owner)
			local p = maps.getPlayer(owner)

			if p.editorrenderscale ~= 16
				p.editorrenderscale = $ << 1
			else
				p.editorrenderscale = 4
			end

			if p.builder
				p.renderscale = p.editorrenderscale
				maps.centerCamera(p)
			end
		end
	},*/
	{
		text = function(owner)
			return "Layer: "..maps.getPlayer(owner).builderlayer
		end,
		tip = "Shortcut: CUSTOM ACTION 1",
		condition = function(owner)
			return maps.getPlayer(owner).builder
		end,
		ok = function(owner)
			maps.getPlayer(owner).builderlayer = ($ % 4) + 1
		end,
		left = function(owner)
			maps.getPlayer(owner).builderlayer = $ ~= 1 and $ - 1 or 4
		end,
		right = function(owner)
			maps.getPlayer(owner).builderlayer = ($ % 4) + 1
		end
	},
	{
		text = function(p)
			local layer = maps.getPlayer(p).visiblelayer
			return "Show "..(
				layer == 1 and "layer 1"
				or layer == 2 and "layer 2"
				or layer == 3 and "layer 3"
				or layer == 4 and "layer 4"
				or "all layers"
			)
		end,
		tip = "Choose what layers are displayed in editing mode",
		condition = function(owner)
			return maps.getPlayer(owner).builder
		end,
		left = function(owner)
			maps.getPlayer(owner).visiblelayer = not $ and 4 or $ ~= 1 and $ - 1 or nil
		end,
		right = function(owner)
			maps.getPlayer(owner).visiblelayer = not $ and 1 or $ ~= 4 and $ + 1 or nil
		end
	},
	menulib.separator,
	{
		text = "Set spawn",
		tip = "Set your cursor position as your spawn",
		condition = function(owner)
			return maps.getPlayer(owner).builder
		end,
		ok = "playerspawnproperties"
	},
	menulib.separator,
	{text = "Options", ok = "options"},
	{text = "Help", ok = "help1"},
	{
		text = "Quit",
		tip = cpulib and "Quit the Map Builder" or "You can't quit in stand-alone mode.",
		condition = not cpulib and function() return false end or nil,
		ok = function(p)
			cpulib.leaveApplication(p)
		end
	}
},
playerspawnproperties = {
	w = 128, h = 128,
	{
		text = function(player)
			local p = maps.pp[player.maps.player]
			return "Direction", p.spawndir == 1 and "Left" or "Right"
		end,
		ok = function(owner)
			local p = maps.getPlayer(owner)

			p.spawnx = p.builderx * maps.TILESIZE + maps.TILESIZE / 2
			p.spawny = (p.buildery + 1) * maps.TILESIZE - 1
			p.spawndir = $ or 2
			menulib.close(owner)
		end,
		left = function(player)
			local p = maps.pp[player.maps.player]
			p.spawndir = $ == 1 and 2 or 1
		end,
		right = function(player)
			local p = maps.pp[player.maps.player]
			p.spawndir = $ == 1 and 2 or 1
		end
	},
},
mapspawnproperties = {
	w = 128, h = 128,
	{
		text = function(p)
			return "Direction", maps.map.spawndir == 1 and "Left" or "Right"
		end,
		ok = function(player)
			local p = maps.pp[player.maps.player]

			maps.map.spawnx = p.builderx * maps.TILESIZE + maps.TILESIZE / 2
			maps.map.spawny = (p.buildery + 1) * maps.TILESIZE - 1
			menulib.close(player)
		end,
		left = function()
			maps.map.spawndir = $ == 1 and 2 or 1
		end,
		right = function()
			maps.map.spawndir = $ == 1 and 2 or 1
		end
	},
},
properties = {
	w = 128, h = 128,
	open = function(p)
		p.menu.mapw, p.menu.maph = maps.map.w, maps.map.h
	end,
	{
		text = function()
			return "Background type", maps.map.backgroundtype == 1 and "Picture" or "Colour"
		end,
		tip = "Set the level background type",
		left = function()
			if maps.map.backgroundtype == 1 then
				maps.map.backgroundtype = 2
				maps.map.background = 213
			else
				maps.map.backgroundtype = 1
				maps.map.background = 1
			end
		end,
		right = function()
			if maps.map.backgroundtype == 1 then
				maps.map.backgroundtype = 2
				maps.map.background = 213
			else
				maps.map.backgroundtype = 1
				maps.map.background = 1
			end
		end
	},
	{
		text = function()
			if maps.map.backgroundtype == 1 then
				return "Background picture", maps.backgrounds[maps.map.background].name
			else
				return "Background color", maps.map.background
			end
		end,
		tip = "Set the level background",
		left = function()
			if maps.map.backgroundtype == 1 then
				maps.map.background = $ == 1 and #maps.backgrounds or $ - 1
			else
				maps.map.background = $ == 0 and 255 or $ - 1
			end
		end,
		right = function()
			if maps.map.backgroundtype == 1 then
				maps.map.background = $ ~= #maps.backgrounds and $ + 1 or 1
			else
				maps.map.background = $ ~= 255 and $ + 1 or 0
			end
		end
	},
	menulib.separator,
	{
		text = function()
			if type(maps.map.music) == "number" and maps.map.music >= mus_map01m and maps.map.music <= mus_mapzzm then
				return "Music slot", G_BuildMapName(maps.map.music):sub(4, 5)
			else
				return "Music slot", maps.map.music
			end
		end,
		tip = "Set the level music",
		left = function(p)
			if type(maps.map.music) == "number" and maps.map.music >= mus_map01m and maps.map.music <= mus_mapzzm then
				maps.map.music = $ <= mus_map01m and mus_mapb9m or $ - 1
			else
				maps.map.music = mus_mapb9m
			end
			if maps.allowmusicpreview then
				S_ChangeMusic(maps.map.music, true, p)
			end
		end,
		right = function(p)
			if type(maps.map.music) == "number" and maps.map.music >= mus_map01m and maps.map.music <= mus_mapzzm then
				maps.map.music = $ < mus_mapb9m and $ + 1 or mus_map01m
			else
				maps.map.music = mus_map01m
			end
			if maps.allowmusicpreview then
				S_ChangeMusic(maps.map.music, true, p)
			end
		end
	},
	{
		text = function()
			return "Music preview", maps.allowmusicpreview and "On" or "Off"
		end,
		tip = "Preview when setting the music. Disable if it causes lag spikes.",
		ok = function()
			maps.allowmusicpreview = not $
		end,
		left = function()
			maps.allowmusicpreview = not $
		end,
		right = function()
			maps.allowmusicpreview = not $
		end
	},
	menulib.separator,
	{
		text = function(p)
			return "Width", p.menu.mapw
		end,
		left = function(p)
			p.menu.mapw = max($ - 8, 40)
		end,
		right = function(p)
			p.menu.mapw = ($ + 8) * p.menu.maph <= 65536 and $ + 8 or $
		end
	},
	{
		text = function(p)
			return "Height", p.menu.maph
		end,
		left = function(p)
			p.menu.maph = max($ - 8, 32)
		end,
		right = function(p)
			p.menu.maph = p.menu.mapw * ($ + 8) <= 65536 and $ + 8 or $
		end
	},
	menulib.separator,
	{
		text = function()
			return "Level editing", maps.allowediting and "Enabled" or "Disabled"
		end,
		tip = "When disabled, only the host and the administrator can edit the map",
		ok = function()
			maps.allowediting = not $
			print("Level editing was "..(maps.allowediting and "en" or "dis").."abled.")
		end,
		left = function()
			maps.allowediting = not $
			print("Level editing was "..(maps.allowediting and "en" or "dis").."abled.")
		end,
		right = function()
			maps.allowediting = not $
			print("Level editing was "..(maps.allowediting and "en" or "dis").."abled.")
		end
	},
	/*menulib.separator,
	{
		text = function()
			return "Scale factor", maps.renderscale
		end,
		--tip = "", -- !!!
		left = function()
			if maps.renderscale ~= 1
				maps.setRenderScale(maps.renderscale >> 1)
			else
				maps.setRenderScale(16)
			end
			for _, p in ipairs(maps.pp)
				maps.centerCamera(p)
			end
		end,
		right = function()
			if maps.renderscale ~= 16
				maps.setRenderScale(maps.renderscale << 1)
			else
				maps.setRenderScale(1)
			end
			for _, p in ipairs(maps.pp)
				maps.centerCamera(p)
			end
		end
	},*/
	menulib.separator,
	{
		text = "Apply new level size",
		tip = "Be careful, this will reset the map!",
		condition = function(p)
			return p.menu.mapw ~= nil and (p.menu.mapw ~= maps.map.w or p.menu.maph ~= maps.map.h)
		end,
		ok = "clearmap"
	}
},
clearmap = {
	w = 128, h = 128,
	open = function(p, t)
		t.choice = 4
	end,
	{text = "Are you sure you want", skip = true},
	{text = "to remove everything?", skip = true},
	menulib.separator,
	{
		text = "No",
		ok = function(p)
			menulib.close(p)
		end
	},
	{
		text = "Yes",
		ok = function(player)
			if player.menu.mapw ~= nil then
				maps.map.w, maps.map.h = player.menu.mapw, player.menu.maph
			end

			maps.clearMap()

			print("The map has been reset.")

			menulib.close(player)
		end
	}
},
options = {
	w = 128, h = 128,
	/*{
		text = function(p)
			local t = maps.getPlayer(p).camera
			if t == 1
				t = "Basic"
			elseif t == 2
				t = "Center"
			elseif t == 3
				t = "Dynamic 1"
			elseif t == 4
				t = "Dynamic 2"
			end
			return "Camera type", t
		end,
		left = function(p)
			maps.getPlayer(p).camera = $ ~= 1 and $ - 1 or 4
		end,
		right = function(p)
			maps.getPlayer(p).camera = $ ~= 4 and $ + 1 or 1
		end,
	},*/
	/*{
		text = function(p)
			return "Dynamic camera", maps.getPlayer(p).dynamiccamera and "Yes" or "No"
		end,
		left = function(p)
			maps.getPlayer(p).dynamiccamera = not $
		end,
		right = function(p)
			maps.getPlayer(p).dynamiccamera = not $
		end,
		ok = function(p)
			menulib.close(p)
		end
	},*/
	/*{
		text = function(p)
			return "Camera scrolling distance", maps.getPlayer(p).scrolldistance
		end,
		left = function(p)
			maps.getPlayer(p).scrolldistance = $ <= 0 and 15 or $ - 1
		end,
		right = function(p)
			maps.getPlayer(p).scrolldistance = $ < 15 and $ + 1 or 0
		end,
	},*/
	--menulib.separator,
	{
		text = function(p)
			return "Cursor speed", 9 - maps.getPlayer(p).builderspeed
		end,
		left = function(p)
			maps.getPlayer(p).builderspeed = $ == 8 and 1 or $ + 1
		end,
		right = function(p)
			maps.getPlayer(p).builderspeed = $ == 1 and 8 or $ - 1
		end,
		ok = function(p)
			menulib.close(p)
		end
	},
	{
		text = function(p)
			return "Erase both layers", maps.getPlayer(p).erasebothlayers and "Yes" or "No"
		end,
		tip = "Erase both layers when erasing",
		left = function(p)
			maps.getPlayer(p).erasebothlayers = not $
		end,
		right = function(owner)
			maps.getPlayer(owner).erasebothlayers = not $
		end,
		ok = function(owner)
			maps.getPlayer(owner).erasebothlayers = not $
		end
	},
	menulib.separator,
	{
	text = function(owner)
		return "Show background", maps.getPlayer(owner).nobgpic and "No" or "Yes"
	end,
	tip = "Disabling may improve the framerate",
	left = function(owner)
		maps.getPlayer(owner).nobgpic = not $ and true or nil
	end,
	right = function(owner)
		maps.getPlayer(owner).nobgpic = not $ and true or nil
	end,
	ok = function(owner)
		maps.getPlayer(owner).nobgpic = not $ and true or nil
	end,
	}
},
help1 = {
	w = 256, h = 128,
	helppage(),
	helptitle("Basic controls"),
	menulib.separator,
	menulib.separator,
	helpline("Toss flag: open/close menu"),
	menulib.separator,
	helpline("Jump: add/remove block"),
	menulib.separator,
	helpline("Spin: choose block")
},
help2 = {
	w = 256, h = 128,
	helppage(),
	helptitle("Advanced controls"),
	menulib.separator,
	menulib.separator,
	menulib.separator,
	menulib.separator,
	helpline("Custom action 1: switch between layers"),
	helpline("Custom action 2: Toggle solidity for other layer"),
	helpline("Ring toss: copy block")
},
help3 = {
	w = 256, h = 128,
	helppage(),
	helptitle("Layers"),
	menulib.separator,
	menulib.separator,
	menulib.separator,
	menulib.separator,
	menulib.separator,
	helpline("Blocks on layer 2 and 3 may be interacted with,"),
	helpline("while blocks on layer 1 and 4 are decorative."),
},
help4 = {
	w = 256, h = 128,
	helppage(),
	helptitle("Commands"),
	menulib.separator,
	menulib.separator,
	menulib.separator,
	helpline("helpmaps: read this help menu"),
	helpline("tp: teleport to another builder"),
	helpline("tp back: teleport back to your location before teleporting"),
	helpline("showlayer: choose what layer are shown while in build mode"),
},
help5 = {
	w = 256, h = 128,
	helppage(),
	helptitle("Server commands"),
	menulib.separator,
	menulib.separator,
	--helpline("rect: fill a rectangular area with a block"),
	--helpline("rect rm: remove a rectangular area"),
	helpline("tileowner: see who put the block under the cursor"),
	helpline("allowediting: enable/disable level editing for non-server players"),
	helpline("music: set the music name/number")
}
}

menulib.set("maps", menus)
