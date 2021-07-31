maps.addCommand("tp", function(owner, dst)
	if not dst then
		CONS_Printf(owner, "tp <player name/num>: teleport yourself to another builder")
		CONS_Printf(owner, "tp back: teleport yourself back to the location you were before teleporting")
		return
	end

	local p = owner and owner.maps and maps.pp[owner.maps.player]
	if not p then
		return
	elseif not p.builder then
		CONS_Printf(owner, "You need to be in building mode to use this command.")
		return
	end

	if dst == "back" then
		if p.tpx ~= nil then
			p.builderx, p.buildery = p.tpx, p.tpy
			p.tpx, p.tpy = nil, nil
		end
	else
		dst = maps.stringToPlayer($)
		if not dst then
			CONS_Printf(owner, "Player not found.")
			return
		end

		dst = dst.maps and maps.pp[dst.maps.player]
		if not dst then
			CONS_Printf(owner, "This player is not in game.")
			return
		elseif not dst.builder then
			CONS_Printf(owner, "This player is not in building mode.")
			return
		end

		p.tpx, p.tpy = p.builderx, p.buildery
		p.builderx, p.buildery = dst.x, dst.y
	end
end)

maps.addCommand("showlayer", function(owner, layer)
	local p = owner and owner.maps and maps.pp[owner.maps.player]
	if not p then
		return
	end

	if not layer then
		CONS_Printf(owner, "showlayer <layer>: chooses the layers displayed when editing")
		CONS_Printf(owner, "Valid options: all, active, background/back, overlay/front")
		return
	end

	if layer == "all" or layer == "0" then
		p.visiblelayer = nil
	elseif layer == "1" then
		p.visiblelayer = 1
	elseif layer == "2" then
		p.visiblelayer = 2
	elseif layer == "3" then
		p.visiblelayer = 3
	elseif layer == "4" then
		p.visiblelayer = 4
	end
end)

/*maps.addCommand("rect", function(owner, remove)
	local p = owner and owner.maps and maps.pp[owner.maps.player]
	if not p
		return
	elseif not p.builder
		CONS_Printf(owner, "You need to be in building mode to use this command.")
		return
	end

	if remove == "remove"
	or remove == "delete"
	or remove == "rm"
		p.fillremove = true
	end
	p.fillx, p.filly = p.builderx, p.buildery
end, 1)*/

maps.addCommand("pos", function(owner)
	local p = owner and owner.maps and maps.pp[owner.maps.player]
	if not p then
		return
	elseif not p.builder then
		CONS_Printf(owner, "You need to be in building mode to use this command.")
		return
	end

	CONS_Printf(owner, p.builderx..", "..p.buildery)
end)

maps.addCommand("allowediting", function(p, on)
	if not on then
		CONS_Printf(p, "Level editing is "..(maps.allowediting and "en" or "dis").."abled.")
		return
	elseif not (p == server or IsPlayerAdmin(p)) then
		CONS_Printf(p, "Only the server or a remote admin can use this.")
		return
	end

	on = on:lower()
	if on == "on" or on == "yes" or on == "1" then
		if not maps.allowediting then
			maps.allowediting = true
			print("Level editing was enabled.")
		end
	elseif on == "off" or on == "no" or on == "0" then
		if maps.allowediting then
			maps.allowediting = false
			print("Level editing was disabled.")
		end
	elseif on == "toggle" then
		if maps.allowediting then
			maps.allowediting = false
			print("Level editing was disabled.")
		else
			maps.allowediting = true
			print("Level editing was enabled.")
		end
	else
		CONS_Printf(p, "allowediting <On/Off>: allows players to edit the level")
	end
end)

maps.addCommand("music", function(p, music)
	if not music then
		CONS_Printf(p, "music <slot>: sets the level music")
		return
	end

	maps.map.music = music:lower()
	--maps.map.music = _G["mus_"..music:lower()]
	--if not maps.map.music
	--	CONS_Printf(p, "This music doesn't exist!")
	--end
end, 1)

maps.addCommand("tileowner", function(owner)
	if gamemap ~= 557 then
		CONS_Printf(owner, "You can't use this here!")
		return
	end
	local p = owner and owner.maps and maps.pp[owner.maps.player]
	if not p then
		return
	elseif not p.builder then
		CONS_Printf(owner, "You need to be in building mode to use this command.")
		return
	end

	local latestinfo
	local latesttime = 0
	local i = p.builderx + p.buildery * maps.map.w
	for _, info in ipairs(maps.tilehistory) do
		if info[1] == i and info[3] >= latesttime then
			latestinfo, latesttime = info, info[3]
		end
	end

	if latestinfo then
		CONS_Printf(owner, latestinfo[2].." "..(leveltime - latesttime) / TICRATE.." seconds ago")
	else
		CONS_Printf(owner, "Tile owner unknown")
	end
end, 1)
