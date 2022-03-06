---@class ljgui
local gui = ljrequire "ljgui.common"


---@param key keyevent_t
---@return boolean
function gui.handleKeyDown(key)
    local root = gui.root

    if root:callEvent("KeyDown", key) then return true end

    if key.name == "mouse1" and root.mouse:pressLeftButton() then
        return true
    end

    local item = root.focusedItem
    return item and item.onKeyDown and item:onKeyDown(key) and true or false
end

---@param key keyevent_t
---@return boolean
function gui.handleKeyUp(key)
    local root = gui.root

    if root:callEvent("KeyUp", key) then return true end

    if key.name == "mouse1" and root.mouse:releaseLeftButton() then
        return true
    end

    local item = root.focusedItem
    return item and item.onKeyUp and item:onKeyUp(key) and true or false
end
