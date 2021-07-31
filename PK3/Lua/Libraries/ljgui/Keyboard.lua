local gui = ljrequire "ljgui.common"


function gui.handleKeyDown(key)
    print("DOWN " .. key)
end

function gui.handleKeyUp(key)
    print("UP " .. key)
end
