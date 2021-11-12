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
	maps.updatePanel()

	/*if root.main.editorMenu.enabled or root.main.tilePicker then
		cmd.forwardmove = 0
		cmd.sidemove = 0
		cmd.buttons = 0
	end*/
end

---@param key keyevent_t
function maps.handleKeyDown(key)
	local cl = maps.client
	if not cl then return end

	local root = gui.root

	gui.handleKeyDown(key)
	if root and (root.main.editorPanel or root.main.tilePicker) then
		return
	end

	if key.name == "SPACE" then
		cl.panning = true
	end

	local mode = cl.player.buildermode
	if mode then
		local modedef = maps.editormodes[mode.id]
		if modedef.on_key_down then
			modedef.on_key_down(key, cl.player)
		end
	end
end

---@param key keyevent_t
function maps.handleKeyUp(key)
	local cl = maps.client
	if not cl then return end

	local root = gui.root

	gui.handleKeyUp(key)
	if root and (root.main.editorPanel or root.main.tilePicker) then
		return
	end

	if key.name == "SPACE" then
		cl.panning = false
	end

	local mode = cl.player.buildermode
	if mode then
		local modedef = maps.editormodes[mode.id]
		if modedef.on_key_up then
			modedef.on_key_up(key, cl.player)
		end
	end
end

function maps.drawGui(v)
	if not gui.root then return end -- !!!

	gui.v = v
	gui.cmd = cmd

	gui.root:draw(v)
end
