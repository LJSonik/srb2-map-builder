local gui = ljrequire "ljgui"
local ci = ljrequire "custominput"
local bs = ljrequire "bytestream"


local panelStyle = {
	background = { type = "color", color = 26 }
}

local normalButtonStyle = panelStyle

local pointedButtonStyle = {
	background = { type = "color", color = 23 }
}

local pressedButtonStyle = {
	background = { type = "color", color = 16 }
}


---@class maps.EditorPanel : ljgui.Area
local Panel, base = gui.extend(gui.Area)
maps.EditorPanel = Panel


---@param item ljgui.Item
---@param image string
---@param scale fixed_t
local function addIcon(item, image, scale)
	local icon = gui.Image()
	item.icon = item:attach(icon)

	icon:resize(item.width, item.height)
	icon:move(item.left, item.top)

	icon:setImage(image)
	icon:setScale(scale)
end

local function openTextDropdown(props, bt)
	local root = gui.root

	local dd = props.panel.dropdown
	if dd then
		dd:detach()
	end

	dd = gui.Grid()
	root.main:attach(dd)
	props.panel.dropdown = dd

	dd:setColumnWidth(96*FU)
	dd:setRowHeight(16*FU)

	dd:move(bt.left + (bt.width - dd.columnWidth) / 2, bt.top + bt.height)

	dd:setStyle{
		background = { type = "color", color = 0 }
	}

	for _, data in ipairs(props) do
		local item = gui.Button()
		item:setText(data[1])
		item:resize(96*FU, 16*FU)
		item.onTrigger = data[2]
		dd:add(item)

		item:setNormalStyle(normalButtonStyle)
		item:setPointedStyle(pointedButtonStyle)
		item:setPressedStyle(pressedButtonStyle)
	end

	dd:resizeToFit()

	local l = min(max(dd.left, 0), root.width - dd.width)
	dd:move(l, dd.top)
end

local function openIconDropdown(props, bt)
	local root = gui.root

	local dd = props.panel.dropdown
	if dd then
		dd:detach()
	end

	dd = gui.Grid()
	root.main:attach(dd)
	props.panel.dropdown = dd

	dd:setNumColumns(props.dropdownColumns)
	dd:setSlotSize(32*FU)
	dd:move(0, 0)

	dd:setStyle{
		background = { type = "color", color = 0 }
	}

	for _, itemData in ipairs(props) do
		local item = gui.Button()
		item:resize(32*FU, 32*FU)
		dd:add(item)

		item.onTrigger = function()
			itemData[2]()
			maps.closeEditorPanel()
		end

		item:setNormalStyle(normalButtonStyle)
		item:setPointedStyle(pointedButtonStyle)
		item:setPressedStyle(pressedButtonStyle)

		addIcon(item, itemData[1], props.dropdownIconScale or FU/2)
	end

	dd:resizeToFit()

	dd:move(bt.left + (bt.width - dd.width) / 2, bt.top + bt.height)
	local left = min(max(dd.left, 0), root.width - dd.width)
	dd:move(left, dd.top)
end

---@param props table
---@return ljgui.Item
local function addPanelButton(props)
	local bt = gui.Button()
	props.panel:attach(bt)
	bt:resize(32*FU, 32*FU)
	bt:move(props.x, 0)

	bt:setNormalStyle(normalButtonStyle)
	bt:setPointedStyle(pointedButtonStyle)
	bt:setPressedStyle(pressedButtonStyle)

	if props.icon then
		local iconName = props.icon
		if type(iconName) == "function" then
			iconName = iconName()
		end

		addIcon(bt, iconName, props.iconScale or FU/2)
	end

	function bt.onTrigger()
		if props.action then
			props.action()
		elseif #props >= 1 then
			props[1][2]()
		end

		if type(props.icon) == "function" then
			bt.icon:setImage(props.icon())
		end
	end

	function bt.onMouseEnter()
		bt.class.onMouseEnter(bt)

		local dd = props.panel.dropdown
		if dd then
			dd:detach()
			props.panel.dropdown = nil
		end

		if #props >= 2 then
			bt.class.onMouseEnter(bt)

			if props.dropdownType == "icon" then
				openIconDropdown(props, bt)
			else
				openTextDropdown(props, bt)
			end
		end
	end

	return bt
end


function Panel:__init()
	base.__init(self)
end

function Panel:setup()
	self:move(0, 0)
	self:resize(self.parent.width, 32*FU)

	self:setStyle(panelStyle)

	local panelGap = (32 + 0) * FU
	local buttonX = 0

	addPanelButton{
		panel = self,
		x = buttonX,
		icon = "MAPS_EDITOR_PLAY",

		{
			"Play from start",
			function()
				ci.send(maps.prepareEditorCommand("play"))
			end
		},
		{
			"Play from test spawn",
			function()
			end
		},
		{
			"Play from here",
			function()
			end
		},
	}
	buttonX = $ + panelGap

	local tilePickerButton = addPanelButton{
		panel = self,
		x = buttonX,

		{
			"Open tile picker",
			function()
				local picker = maps.TilePicker()
				gui.root.main.tilePicker = gui.root.main:attach(picker)
				picker:setup()
				picker:focus()
			end
		}
	}

	function tilePickerButton.draw(bt, v)
		bt.class.draw(bt, v)

		local x, y = bt:getCenter()
		local tile = maps.client.player.buildertile or "ghz_block1"
		maps.drawTile(v, tile, x, y, FU)
	end
	buttonX = $ + panelGap

	local layerButton

	local function pickLayer(layer)
		maps.client.player.builderlayer = layer

		local packet = maps.prepareEditorCommand("set_cursor_layer")
		bs.writeUInt(packet, 2, layer - 1)
		ci.send(packet)
	end

	layerButton = addPanelButton{
		panel = self,
		x = buttonX,

		icon = function()
			local p = maps.client.player
			return "MAPS_EDITOR_PICKLAYER" .. p.builderlayer
		end,

		action = function()
			pickLayer((maps.client.player.builderlayer % 4) + 1)
		end,

		dropdownType = "icon",
		dropdownColumns = 1,
		{
			"MAPS_EDITOR_PICKLAYER1",
			function()
				pickLayer(1)
			end
		},
		{
			"MAPS_EDITOR_PICKLAYER2",
			function()
				pickLayer(2)
			end
		},
		{
			"MAPS_EDITOR_PICKLAYER3",
			function()
				pickLayer(3)
			end
		},
		{
			"MAPS_EDITOR_PICKLAYER4",
			function()
				pickLayer(4)
			end
		},
	}
	buttonX = $ + panelGap

	addPanelButton{
		panel = self,
		x = buttonX,
		icon = "MAPS_EDITOR_MODE_PEN",
		iconScale = FU/4,

		dropdownType = "icon",
		dropdownColumns = 2,
		dropdownIconScale = FU/4,
		{
			"MAPS_EDITOR_MODE_PEN",
			function()
				ci.send(maps.prepareEditorCommand("pen_mode"))
				maps.enterEditorMode(maps.client.player, "pen")
			end
		},
		{
			"MAPS_EDITOR_MODE_BUCKET",
			function()
				ci.send(maps.prepareEditorCommand("bucket_fill_mode"))
				maps.enterEditorMode(maps.client.player, "bucket_fill")
			end
		},
	}
	buttonX = $ + panelGap

	local doubleLayerButton
	doubleLayerButton = addPanelButton{
		panel = self,
		x = buttonX,

		icon = function()
			local p = maps.client.player
			return "MAPS_EDITOR_DOUBLELAYER_" .. (p.bothsolid and "ON" or "OFF")
		end,

		{
			"Toggle double layering",
			function()
				local p = maps.client.player

				p.bothsolid = not $

				local packet = maps.prepareEditorCommand("set_cursor_double_layering")
				bs.writeUInt(packet, 1, p.bothsolid and 1 or 0)
				ci.send(packet)
			end
		}
	}
	buttonX = $ + panelGap

	addPanelButton{
		panel = self,
		x = buttonX,
		icon = "MAPS_EDITOR_PLAY",

		{
			"???",
			function()
				local window = maps.LevelPropertiesWindow()
				gui.root.main:attach(window)
				window:setup()
			end
		},
	}
	buttonX = $ + panelGap

	-- addPanelButton{
	-- 	panel = self,
	-- 	x = buttonX,
	-- 	icon = "MAPS_EDITOR_PLAY",

	-- 	{
	-- 		"???",
	-- 		function()
	-- 		end
	-- 	},
	-- }
	-- buttonX = $ + panelGap

	addPanelButton{
		panel = self,
		x = buttonX,
		icon = "MAPS_EDITOR_PLAY",

		{
			"???",
			function()
			end
		},
	}
	buttonX = $ + panelGap

	addPanelButton{
		panel = self,
		x = buttonX,
		icon = "MAPS_EDITOR_PLAY",

		{
			"???",
			function()
			end
		},
	}
	buttonX = $ + panelGap

	addPanelButton{
		panel = self,
		x = buttonX,
		icon = "MAPS_EDITOR_PLAY",

		{
			"???",
			function()
			end
		},
	}
	buttonX = $ + panelGap

	addPanelButton{
		panel = self,
		x = buttonX,
		icon = "MAPS_EDITOR_PLAY",

		{
			"???",
			function()
			end
		},
	}
	buttonX = $ + panelGap

	-- local window = gui.Window()
	-- gui.root.main:attach(window)
	-- window:move(64*FU, 64*FU)
	-- window:resize(68*FU, 74*FU)

	-- local cp = maps.PaletteColorPicker()
	-- window.content:attach(cp)
	-- cp:move(window.content.left, window.content.top)
	-- local panel = self
	-- panel.color = 166
	-- function cp:onColorPicked(color)
	--     panel.color = color
	--     print(color)
	-- end
	-- cp:setup()
end

-- function Panel:onMouseLeave()
-- 	self:detach()
-- 	gui.root.main.editorPanel = nil
-- end


function maps.updateEditorPanel()
	local root = gui.root
	local panel = root.main.editorPanel
	local mouse = root.mouse

	if panel then -- Panel shown
		local dd = panel.dropdown
		local inside = (mouse:isInsideItem(panel) or (dd and mouse:isInsideItem(dd)))

		if not inside then
			maps.closeEditorPanel()
		end
	else -- Panel hidden
		-- Show panel if mouse at top of screen
		if mouse.y < FU
		and not (root.main.editorPanel or root.main.tilePicker or maps.client.panning) then
			panel = maps.EditorPanel()
			root.main.editorPanel = root.main:attach(panel)
			panel:setup()
		end
	end
end

function maps.closeEditorPanel()
	local dd = gui.root.main.editorPanel.dropdown
	if dd then
		dd:detach()
	end

	gui.root.main.editorPanel:detach()
	gui.root.main.editorPanel = nil
end
