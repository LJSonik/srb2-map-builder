local gui = ljrequire "ljgui"


function maps.initialiseGui(v)
	gui.screen = gui.Screen(v)

	local menu = maps.EditorMenu()
	menu:setup()
	gui.screen.editorMenu = gui.screen:attach(menu)
end

function maps.uninitialiseGui()
	gui.screen = nil
end

function maps.updateGui(v, cmd)
	if not gui.screen then return end -- !!!

	gui.v = v
	gui.cmd = cmd

	if gui.screen.focusedItem ~= nil then
		maps.client.inputeaten = true
	end

	gui.screen:update()

	/*if gui.screen.editorMenu.enabled or gui.screen.tilePicker then
		cmd.forwardmove = 0
		cmd.sidemove = 0
		cmd.buttons = 0
	end*/
end

function maps.handleKeyDown(key)
	--gui.handleKeyDown(key)

	local cl = maps.client
	if cl then
		local mode = cl.player.buildermode
		if mode then
			local modedef = maps.editormodes[mode.id]
			if modedef.on_key_down then
				modedef.on_key_down(cl.player, key)
			end
		end
	end
end

function maps.handleKeyUp(key)
	--gui.handleKeyUp(key)

	local cl = maps.client
	if cl then
		local mode = cl.player.buildermode
		if mode then
			local modedef = maps.editormodes[mode.id]
			if modedef.on_key_up then
				modedef.on_key_up(cl.player, key)
			end
		end
	end
end

function maps.drawGui(v)
	if not gui.screen then return end -- !!!

	gui.v = v
	gui.cmd = cmd

	gui.screen:draw(v)
end
