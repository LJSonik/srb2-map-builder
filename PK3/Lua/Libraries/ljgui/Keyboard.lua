---@class ljgui
local gui = ljrequire "ljgui.common"


---@type keyevent_t
function gui.handleKeyDown(key)
    local root = gui.root

    if root:callEvent("KeyDown", key) then return end

    if key.name == "mouse1" then
        root.mouse:pressLeftButton()
    end

    local item = root.focusedItem
    if not item then return end

    if item.onKeyDown then
        item:onKeyDown(key)
    end
end

---@type keyevent_t
function gui.handleKeyUp(key)
    local root = gui.root

    if root:callEvent("KeyUp", key) then return end

    if key.name == "mouse1" then
        root.mouse:releaseLeftButton()
    end

    local item = root.focusedItem
    if not item then return end

    if item.onKeyUp then
        item:onKeyUp(key)
    end
end
