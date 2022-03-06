local gui = ljrequire "ljgui"


function maps.initialiseGui(v)
	gui.root = gui.Root(v)

	local menu = maps.EditorMenu()
	menu:setup()
	gui.root.main.editorMenu = gui.root:attach(menu)
end

function maps.uninitialiseGui()
	gui.root = nil
end

function maps.updateGui(v, cmd)
	local root = gui.root
	if not root then return end -- !!!

	gui.v = v
	gui.cmd = cmd

	if root.focusedItem ~= nil then
		maps.client.inputeaten = true
	end

	root:update()

	/*if root.main.editorMenu.enabled or root.main.tilePicker then
		cmd.forwardmove = 0
		cmd.sidemove = 0
		cmd.buttons = 0
	end*/
end

---@param key keyevent_t
function maps.handleKeyDown(key)
	local cl = maps.client
	if not cl then return false end
	local p = cl.player
	if not p then return false end

	local root = gui.root
	if not root then return false end

	if maps.handleEditorCommandKeyDown(key) then return true end

	local panel = root.main.editorPanel

	if gui.handleKeyDown(key) or panel or root.main.tilePicker then
		return true
	end

	local keyName = key.name
	if keyName == "mouse1" then
		-- Show panel if mouse at top of screen
		if root.mouse.y < FU and not maps.client.panning then
			panel = maps.EditorPanel()
			root.main.editorPanel = root.main:attach(panel)
			panel:setup()
			return true
		end
	end

	local mode = cl.player.buildermode
	if mode then
		local modedef = maps.editormodes[mode.id]
		if modedef.on_key_down and modedef.on_key_down(key, cl.player) then
			return true
		end
	end
end

---@param key keyevent_t
function maps.handleKeyUp(key)
	local cl = maps.client
	if not cl then return false end

	local root = gui.root
	if not root then return false end

	if maps.handleEditorCommandKeyUp(key) then return false end

	if gui.handleKeyUp(key) or root.main.editorPanel or root.main.tilePicker then
		return true
	end

	local mode = cl.player.buildermode
	if mode then
		local modedef = maps.editormodes[mode.id]
		if modedef.on_key_up and modedef.on_key_up(key, cl.player) then
			return true
		end
	end
end

function maps.drawGui(v)
	if not gui.root then return end -- !!!

	gui.v = v
	gui.cmd = cmd

	gui.root:draw(v)
end
