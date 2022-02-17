---@class ljgui
local gui = ljrequire "ljgui.common"


---@type keyevent_t
function gui.handleKeyDown(key)
    local item = gui.root.focusedItem
    if not item then return end

    if item.onKeyDown then
        item:onKeyDown(key)
    end
end

---@type keyevent_t
function gui.handleKeyUp(key)
    local item = gui.root.focusedItem
    if not item then return end

    if item.onKeyUp then
        item:onKeyUp(key)
    end
end
