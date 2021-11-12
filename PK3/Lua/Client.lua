---@class maps.Client
---@field active boolean
---@field player maps.Player
---@field backup table
---
---@field leftpressed  boolean
---@field rightpressed boolean
---@field uppressed    boolean
---@field downpressed  boolean
---
---@field prevleft  boolean
---@field prevright boolean
---@field prevup    boolean
---@field prevdown  boolean
---
---@field fullresendneeded boolean
---@field fullresendtime   integer


---@type maps.Client
maps.client = nil -- For storing clientside data


function maps.updateClient(v)
	local cl = maps.client
	local p = maps.getPlayer(consoleplayer)

	maps.updateGui(v, cl.cmd)

	if p and p.builder then
		maps.updateClientEditor(p, cl.cmd, v)
	end

	cl.prevleft, cl.prevright, cl.prevup, cl.prevdown = maps.getLocalKeys(cl.cmd)
	cl.prevbuttons = cl.cmd.buttons
	cl.inputeaten = false
end

function maps.initialiseClient()
	maps.client = {
		active = false,
		player = maps.getPlayer(consoleplayer)
	}

	maps.refreshClientMap()
end
