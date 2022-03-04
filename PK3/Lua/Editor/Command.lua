--#region classes
---@class maps.EditorCommand
---@field name string
---@field id integer
---@field action? function
---@field start? function
---@field stop? function
---@field keyBind? string
--#endregion


--#region Variables
---@type table<integer|string, table>
local editorCommands = {}

---@type table<string, maps.EditorCommand>
local keyBinds = {}

local ctrlDown, shiftDown, altDown = false, false, false

---@type maps.EditorCommand?
local activeCommand
--#endregion


--#region functions
---@param command maps.EditorCommand
function maps.addEditorCommand(command)
	command.id = #editorCommands + 1

	editorCommands[command.name] = command
	editorCommands[command.id] = command

	if command.keyBind then
		keyBinds[command.keyBind] = command
	end
end

---@param key keyevent_t
---@param down boolean
---@return boolean
local function handleModifierUpOrDown(key, down)
	local keyName = key.name
	if keyName == "lctrl" or keyName == "rctrl" then
		ctrlDown = down
		return true
	elseif keyName == "lshift" or keyName == "rshift" then
		shiftDown = down
		return true
	elseif keyName == "lalt" or keyName == "ralt" then
		altDown = down
		return true
	else
		return false
	end
end

---@param key keyevent_t
---@return maps.EditorCommand
local function keyToCommand(key)
	local s = key.name
	if altDown then
		s = "alt+" .. s
	end
	if shiftDown then
		s = "shift+" .. s
	end
	if ctrlDown then
		s = "ctrl+" .. s
	end

	return keyBinds[s]
end

---@param key keyevent_t
---@return boolean
function maps.handleEditorCommandKeyDown(key)
	if handleModifierUpOrDown(key, true) then return false end

	local command = keyToCommand(key)
	if not command then return false end

	if command.action then
		command.action()
	elseif not key.repeated then
		activeCommand = command
		command.start()
	end

	return true
end

---@param key keyevent_t
---@return boolean
function maps.handleEditorCommandKeyUp(key)
	handleModifierUpOrDown(key, false)

	if activeCommand then
		activeCommand.stop()
		activeCommand = nil

		return true
	else
		return false
	end
end

function maps.clearEditorKeys()
	ctrlDown, shiftDown, altDown = false, false, false
	activeCommand = nil
end
--#region
