local savepath = 'locale/qf/'
local pathname_GAME = 'GAME'
local pathname_PLAYER = 'PLAYERID_'

function check_for_folder(name)
	local l = io.open(savepath..name..'__index','w')
	if not l then
		local h = io.open(savepath..'__index','w')
		if not h then
			dchatt("#debug# CREATE MAIN DIR")
			os.execute('mkdir "'..savepath..'"')
		end
		
		dchatt("#debug# CREATE NAMEFOLDER DIR")
		os.execute('mkdir "'..savepath..name..'"')
	end
	if l then
		l:close()
	end
	dchatt("#debug# FOLDER IS EXEST!")
end

function LIB_global_add_file_player(name,wert)
	if name == nil or wert == nil then
		return
	end
	local pid = pc.get_player_id()
	check_for_folder(pathname_"..DB_Player.."..pid..'/',name..'/')
	local wrt = io.open(savepath..pathname_"..DB_Player.."..pid..'/'..name,'w')
	wrt:write(wert)
	wrt:close()
end

function LIB_global_get_file_player(name)
	local pid = pc.get_player_id()
	local rd = io.open(savepath..pathname_"..DB_Player.."..pid..'/'..name,'r')
	if not rd then return 0 end
	for qfdata in rd:lines() do
		local ex = qfdata
		rd:close()
		return ex
	end
	rd:close()
	return 0
end

function LIB_global_del_file_player(name)
	local pid = pc.get_player_id()
	os.remove(savepath..pathname_"..DB_Player.."..pid..'/'..name)
end

--GAME
function LIB_variable_game_add(name,wert)
	if name == nil or wert == nil then
		return
	end
	--qname = q_getcurrentquestname
	check_for_folder(pathname_GAME..'/',name..'/')
	local wrt = io.open(savepath..pathname_GAME..'/'..name,'w')
	wrt:write(wert)
	wrt:close()
end
function LIB_variable_game_get(name)
	if name == nil then
		return
	end
	local rd = io.open(savepath..pathname_GAME..'/'..name,'r')
	if not rd then return 0 end
	for qfdata in rd:lines() do
		local ex = qfdata
		rd:close()
		return ex
	end
	rd:close()
	return 0
end

function LIB_variable_game_del(name)
	os.remove(savepath..pathname_GAME..'/'..name)
end

--Folder
function LIB_variable_global_add_to_folder(folder,name,wert)
	if name == nil or wert == nil then
		return
	end
	--qname = q_getcurrentquestname
	check_for_folder(folder..'/',name..'/')
	local wrt = io.open(savepath..folder..'/'..name,'w')
	wrt:write(wert)
	wrt:close()
end
function LIB_variable_global_get_to_folder(folder,name)
	if name == nil then
		return
	end
	local rd = io.open(savepath..folder..'/'..name,'r')
	if not rd then return 0 end
	for qfdata in rd:lines() do
		local ex = qfdata
		rd:close()
		return ex
	end
	rd:close()
	return 0
end

function LIB_variable_global_del_to_folder(folder,name)
	os.remove(savepath..folder..'/'..name)
end



--------------------------
function LIB_variable_add_player(name,wert)
	local id = pc.get_player_id()
	if wert == nil or id == nil then
	return
	end
	_G[ name.."_"..id ] = wert
end
function LIB_variable_get_player(name)
	local id = pc.get_player_id()
	if bool_to_str(_G[ name.."_"..id ]) == "false" or _G[ name.."_"..id ] == nil then
		return 0
	else
		return _G[ name.."_"..id ]
	end
end
function LIB_variable_del_player(name)
	local id = pc.get_player_id()
	_G[ name.."_"..id ] = nil
end
----------------------
----------------------
----------------------
function LIB_variable_add_guild(name,wert)
	--local func = loadstring(""..name.."_"..pc.get_player_id().." = '"..wert.."'")
	local guild_id = pc.get_guild()
	if wert == nil or guild_id == nil then
		return
	end
	_G[ name.."_"..guild_id ] = wert
end

function LIB_variable_get_guild(name)
	local guild_id = pc.get_guild()
	if bool_to_str(_G[ name.."_"..guild_id ]) == "false" or _G[ name.."_"..guild_id ] == nil then
		return 0
	else
		return _G[ name.."_"..guild_id ]
	end
end
function LIB_variable_del_guild(name)
	local guild_id = pc.get_guild()
	_G[ name.."_"..guild_id ] = nil
end

----------------------
--Globale Mapabhängige Variablen
function LIB_map_variable_add(name,wert)
	local map = pc.get_map_index()
	if wert == nil or map == nil then
		return
	end
	_G[ name.."_"..map ] = wert
end
function LIB_map_variable_get(name)
	local map = pc.get_map_index()
	if bool_to_str(_G[ name.."_"..map ]) == "false" or _G[ name.."_"..map ] == nil then
		return 0
	else
		return _G[ name.."_"..map ]
	end
end
function LIB_map_variable_del(name)
	local map = pc.get_map_index()
	_G[ name.."_"..map ] = nil
end
---------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------
function LIB_variable_add(name,wert)
	if name == nil or wert == nil then
	LIB_writelog("LIB_variable_add FEHLER",1)
	end
	_G[ name ] = wert
end

function LIB_variable_get(name)
	if bool_to_str(_G[ name ]) == "false" or _G[ name ] == nil then
		return 0
	else
		return _G[ name ]
	end
end
function LIB_variable_del(name)
	_G[ name ] = nil
end

------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------
--Tabellenspeicherung
-------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------
function LIB_table_add(name,wert) --hinzufügen
	if wert == nil then
	return
	end
	if bool_to_str(_G[ name.."_table"]) == "false" then
		_G[ name.."_table"] = { }
	end
	if LIB_table_find(name,wert) == false then
		if table.getn(_G[ name.."_table"]) == 0 then
			table.insert(_G[ name.."_table"],1, wert)
		else
			table.insert(_G[ name.."_table"],table.getn(_G[ name.."_table"]) +1, wert)
		end
	end
	
end
function LIB_table_get(name) --einträge ausgeben
	if bool_to_str(_G[ name.."_table"]) == "true" then
		if table.getn(_G[ name.."_table"]) == 0 then
			return {} --nil
		end
		return _G[ name.."_table"]
	else
		return {} --nil
	end
end
function LIB_table_remove(name,wert) --eintrag entfernen
	if name == nil or wert == nil then
	return false
	end
	if bool_to_str(_G[ name.."_table"]) == "true" then
		 for mijago_x3 = 1, table.getn(_G[ name.."_table"]), 1 do
			if tostring(_G[ name.."_table"][mijago_x3]) == tostring(wert) then
				table.remove(_G[ name.."_table"],mijago_x3)
				return true
			end
			if table.getn(_G[ name.."_table"]) == mijago_x3 then
				return false
			end
		 end
	else
		return false
	end
end

function LIB_table_del(name) --tabelle leeren
	if name == ni then
	return
	end
	_G[ name.."_table"] = {}
end

function LIB_table_find(name,wert) --eintrag finden
	if name == nil or wert == nil then
	return false
	end
	if bool_to_str(_G[ name.."_table"]) == "true" then
		 for mijago_x3 = 1, table.getn(_G[ name.."_table"]), 1 do
			if tostring(_G[ name.."_table"][mijago_x3]) == tostring(wert) then
				return true
			end
		 end
		 return false
	else
		return false
	end
end

-- Datenspeicherung by Mijago
function LIB_writelog(text,var,file)
	logbase2 = get_locale_base_path()
	logbase = string.gsub(logbase2,"germany", "")
	--LIB_writelog(text,var,file)
	--[[ 
	var == 1 (syserror) 
	var == 2 (syslog) 
	var == 3 (filename by file)
	]]
    if var == nil then
        var = 1
    end
    if var == 1 then
        local data = io.open(logbase..'/syserr','a+')
        data:write(os.date()..'::\t'..text.."\n")
        data:close()
    elseif var == 2 then
        local data = io.open(logbase..'/syslog','a+')
        data:write(os.date()..'::\t'..text.."\n")
        data:close()
    elseif var == 3 then
        local data = io.open(logbase..'/'..file,'a+')
        data:write(os.date()..'::\t'..text.."\n")
        data:close()
	elseif var == 4 then
        local data = io.open(logbase..'/'..file,'a+')
        data:write(text.."\n")
        data:close()
    end
end