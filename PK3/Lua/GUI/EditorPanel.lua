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
		local icon = gui.Image()
		bt.icon = bt:attach(icon)
		icon:resize(32*FU, 32*FU)
		icon:move(bt.left, bt.top)
		icon:setImage(props.icon)
		icon:setScale(FU/2)
	end

	if props.action then
		bt.onTrigger = props.action
	elseif #props >= 1 then
		bt.onTrigger = props[1][2]
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
			openTextDropdown(props, bt)
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
				maps.closeEditorMenu()
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
		maps.drawTile(v, maps.client.player.buildertile, x, y, FU)
	end
	buttonX = $ + panelGap

	local layerButton

	local function pickLayer(layer)
		maps.client.player.builderlayer = layer

		local packet = maps.prepareEditorCommand("set_cursor_layer")
		bs.writeUInt(packet, 2, layer - 1)
		ci.send(packet)

		layerButton.icon:setImage("MAPS_EDITOR_PICKLAYER" .. layer)
	end

	layerButton = addPanelButton{
		panel = self,
		x = buttonX,
		icon = "MAPS_EDITOR_PICKLAYER1",

		action = function()
			pickLayer((maps.client.player.builderlayer % 4) + 1)
		end,
		{
			"Layer 1",
			function()
				pickLayer(1)
			end
		},
		{
			"Layer 2",
			function()
				pickLayer(2)
			end
		},
		{
			"Layer 3",
			function()
				pickLayer(3)
			end
		},
		{
			"Layer 4",
			function()
				pickLayer(4)
			end
		},
	}
	buttonX = $ + panelGap

	layerButton.icon:setImage("MAPS_EDITOR_PICKLAYER" .. maps.client.player.builderlayer)

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


function maps.updatePanel()
	local main = gui.root.main
	local panel = main.editorPanel
	local mouse = gui.root.mouse

	if panel then -- Panel shown
		local dd = panel.dropdown
		local inside = mouse:isInsideItem(panel) or (dd and mouse:isInsideItem(dd))

		if not inside then
			if dd then
				dd:detach()
			end

			panel:detach()
			main.editorPanel = nil
		end
	else -- Panel hidden
		-- Show panel if mouse at top of screen
		if mouse.y < FU then
			panel = maps.EditorPanel()
			main.editorPanel = main:attach(panel)
			panel:setup()
		end
	end
end
