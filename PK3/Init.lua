-- Also define "modmaps" for backward compatibility
rawset(_G, "maps", maps or modmaps or {})
rawset(_G, "modmaps", maps)
modmaps.maps = modmaps.maps or {}


dofile "Libraries/ljrequire.lua"
maps.ljrequire = ljrequire

for _, filename in ipairs{
	"Core.lua",
	"Math.lua",
	"Client.lua",
	"Map.lua",
	"Camera.lua",
	"TileGrid.lua",
	"WheelMenu.lua",
	"Menus.lua",

	"Game/Physics.lua",
	"Game/Collision.lua",
	"Game/Player.lua",
	"Game/Object.lua",
	"Game/Spawner.lua",
	"Game/TileRespawn.lua",
	"Game/SpatialHashmap.lua",

	"Editor/Editor.lua",
	"Editor/Client.lua",
	"Editor/Building.lua",
	"Editor/TilePicker.lua",
	"Editor/TilePickerGrid.lua",
	"Editor/OldWheelMenu.lua",
	"Editor/ConsoleCommands.lua",
	"Editor/PenMode.lua",
	"Editor/BucketFillMode.lua",

	"Renderer/Renderer.lua",
	"Renderer/WheelMenu.lua",

	"IO/Huffman.lua",
	"IO/IO.lua",
	"IO/Gamestate.lua",

	"API/API.lua",
	"API/Tiles.lua",

	"GUI/GUI.lua",
	"GUI/EditorPanel.lua",
	"GUI/EditorMenu.lua",
	"GUI/TilePicker.lua",
	"GUI/KeyboardGridNavigation.lua",
	"GUI/PaletteColorPicker.lua",

	"Data/Init.lua",
} do
	dofile(filename)
end
