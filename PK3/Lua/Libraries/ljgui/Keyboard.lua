---@class ljgui
local gui = ljrequire "ljgui.common"


---@type keyevent_t
function gui.handleKeyDown(key)
    if key.name == "mouse1" then
        gui.root.mouse:pressLeftButton()
    end

    local item = gui.root.focusedItem
    if not item then return end

    if item.onKeyDown then
        item:onKeyDown(key)
    end
end

---@type keyevent_t
function gui.handleKeyUp(key)
    if key.name == "mouse1" then
        gui.root.mouse:releaseLeftButton()
    end

    local item = gui.root.focusedItem
    if not item then return end

    if item.onKeyUp then
        item:onKeyUp(key)
    end
end
