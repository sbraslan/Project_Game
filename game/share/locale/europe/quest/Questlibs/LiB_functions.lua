function LIB_ride_not_here_map()
	local map_index = pc.get_map_index()
	if map_index == 113 or --metin2_map_oxevent
		map_index == 118 or --118 metin2_map_sungzi_flame_hill_01
		map_index == 119 or --119 metin2_map_sungzi_flame_hill_02
		map_index == 120 or --120 metin2_map_sungzi_flame_hill_03
		map_index == 122 or --122 metin2_map_sungzi_snow_pass01
		map_index == 123 or --123 metin2_map_sungzi_snow_pass02
		map_index == 124 or --124 metin2_map_sungzi_snow_pass03
		map_index == 126 or --126 metin2_map_sungzi_desert_hill_01
		map_index == 127 or --127 metin2_map_sungzi_desert_hill_02
		map_index == 128 or--128 metin2_map_sungzi_desert_hill_03
		map_index == 350 --metin2_map_multiox
		and not pc.is_gm() then
		return true
	else
		return false
	end
end


function say_item_vnum_inline_showtooltip_by_cell(window_type, cell)
	raw_script("[INSERT_IMAGE_SHOWTOOLTIP_BY_CELL window_type;"..window_type.."|cell;"..cell.."]")
end

function LIB_while_give_item(item,count)
	for i = 1, count, 1 do	
		pc.give_item2(""..item.."")
	end
end

function LIB_get_mob_level(vnum)
	if npc.is_pc() or vnum == 0 then
		return 0
	else
		--return npc.get_level()
	--end
	if bool_to_str(LIB_mob_level_done,"LIB_mob_level_done") == "false" then
		LIB_mob_level_done = 1
		local mob_level_tables = mysql_query("SELECT vnum,level FROM "..DB_Player..".mob_proto")
		for i = 1, table.getn(mob_level_tables), 1 do
			_G[ "mob_level_"..mob_level_tables[i][1] ] = mob_level_tables[i][2]
		end
		return 0
	else
		if is_bool(_G[ "mob_level_"..vnum ]) == false then
			return 0
		else
			return _G[ "mob_level_"..vnum ]
		end
	end
	
	
	end
end

function LIB_is_mob_boss(vnum)
	if npc.is_pc() or vnum == 0 then
		return false
	elseif npc.is_boss() == true then
		return true
	else
		return false
	end
--[[
OLD!!!!!
	local checkthis = loadstring("return mob_rank_")
	if vnum == 2093 or	vnum == 2091 or  vnum == 2291 or	vnum ==	2191 or	vnum == 5161 or	vnum == 591 or
	vnum ==	592 or	vnum ==	691 or	vnum == 593 or	vnum ==	692 or	vnum ==	693 or	vnum ==	791 or	vnum ==	1901 or
	vnum ==	1902 or	vnum ==	1903 or	vnum ==	2206 or	vnum ==	2207 or	vnum ==	1192 or	vnum ==	2492 or	vnum ==	2493 or
	vnum ==	1091 or	vnum ==	1092 or	vnum ==	1093 or	vnum ==	2597 or	vnum ==	2598 or	vnum ==	2595 or	vnum ==	3090 or
	vnum ==	3290 or	vnum ==	3590 or	vnum ==	3595 or	vnum ==	3690 or	vnum ==	3490 or	vnum ==	3790 or	vnum ==	3190 or
	vnum ==	3301 or	vnum ==	3890
	then 
		return true
	else
		if bool_to_str(LIB_mob_rank_done) == "false" then
			LIB_mob_rank_done = 1
			local mob_rank_tables = mysql_query_server("SELECT vnum,rank FROM "..DB_Player..".mob_proto where rank = '5' or rank = '4'")
			for i = 1, table.getn(mob_rank_tables), 1 do
				_G[ "mob_rank"..mob_rank_tables[i][1] ] = mob_rank_tables[i][2]
			end
			return 0
		else
			if bool_to_str(_G[ "mob_rank"..vnum ]) == "false" then
				return 0
			else
				return _G[ "mob_rank"..vnum ]
			end
		end
	end
	]]
end

function LIB_is_mob_stone(vnum) --return false or true
	if vnum >= 8015 and vnum <= 8023 then --Special Steine
		return false
	elseif vnum >= 8201 and vnum <= 8227 then --Farm Steine
		return false
	elseif npc.is_metin() == true then
		return true
	end
	--[[
	if bool_to_str(LIB_Stone_done) == "false" then
		LIB_Stone_done = 1
		local mob_stone_tables = mysql_query_server("SELECT vnum,level FROM "..DB_Player..".mob_proto where type = '2'")
		for i = 1, table.getn(mob_stone_tables), 1 do
			_G[ "stone_level"..mob_stone_tables[i][1] ] = mob_stone_tables[i][2]
		end
		return false
	else
		if bool_to_str(_G[ "stone_level"..vnum ]) == "false" then
			return false
		else
			return true
		end
	end
	]]
end

function LIB_temporium_system_ActiveOnThis(v)
	local t = get_global_time()
	--chat(""..tonumber(pc.getf("temporium_system","e_time") + t).." >= "..t.."")
	local t = get_global_time()
	if (tonumber(pc.getf("temporium_system","e_time")) + t) >= t then
		local w = pc.getf("temporium_system","e_ventype")
		if w == v then 
			--chat("True to Event func")
			return true
		else
			return false
		end
	else
		return false
	end
end

function LIB_client_popup_message(text)
	local newtext = string.gsub(text," ", "*")
	LIB_client_app("popup_message",newtext)
end

function LIB_client_app(app,value1,value2,value3,value4,value5,value6,value7,value8,value9,value10,value11,value12,value13,value14,value15,value16,value17,value18,value19,value20,value21,value22,value23,value24,value25,value26,value27,value28,value29,value30,value31,value32,value33,value34,value35,value36,value37,value38,value39,value40)
	local Log = true
	if app != nil then
		if value1 == nil then	value1 = 0	end
		if value2 == nil then	value2 = 0	end
		if value3 == nil then	value3 = 0	end
		if value4 == nil then	value4 = 0	end
		if value5 == nil then	value5 = 0	end
		if value6 == nil then	value6 = 0	end
		if value7 == nil then	value7 = 0	end
		if value8 == nil then	value8 = 0	end
		if value9 == nil then	value9 = 0	end
		if value10 == nil then	value10 = 0	end
		if value11 == nil then	value11 = 0	end
		if value12 == nil then	value12 = 0	end
		if value13 == nil then	value13 = 0	end
		if value14 == nil then	value14 = 0	end
		if value15 == nil then	value15 = 0	end
		if value16 == nil then	value16 = 0	end
		if value17 == nil then	value17 = 0	end
		if value18 == nil then	value18 = 0	end
		if value19 == nil then	value19 = 0	end
		if value20 == nil then	value20 = 0	end
		
		if value20 == nil then	value20 = 0	end
		if value21 == nil then	value21 = 0	end
		if value22 == nil then	value22 = 0	end
		if value23 == nil then	value23 = 0	end
		if value24 == nil then	value24 = 0	end
		if value25 == nil then	value25 = 0	end
		if value26 == nil then	value26 = 0	end
		if value27 == nil then	value27 = 0	end
		if value28 == nil then	value28 = 0	end
		if value29 == nil then	value29 = 0	end
		
		if value30 == nil then	value30 = 0	end
		if value31 == nil then	value31 = 0	end
		if value32 == nil then	value32 = 0	end
		if value33 == nil then	value33 = 0	end
		if value34 == nil then	value34 = 0	end
		if value35 == nil then	value35 = 0	end
		
		if value36 == nil then	value36 = 0	end
		if value37 == nil then	value37 = 0	end
		if value38 == nil then	value38 = 0	end
		if value39 == nil then	value39 = 0	end
		if value40 == nil then	value40 = 0	end
		local StringLenTest = "client_app "..app.." "..value1.." "..value2.." "..value3.." "..value4.." "..value5.." "..value6.." "..value7.." "..value8.." "..value9.." "..value10.." "..value11.." "..value12.." "..value13.." "..value14.." "..value15.." "..value16.." "..value17.." "..value18.." "..value19.." "..value20.." "..value21.." "..value22.." "..value23.." "..value24.." "..value25.." "..value26.." "..value27.." "..value28.." "..value29.." "..value30.." "..value31.." "..value32.." "..value33.." "..value34.." "..value35.." "..value36.." "..value37.." "..value38.." "..value39.." "..value40..""
		dchat(StringLenTest)
		cmdchat(StringLenTest)
		if Log == true then
			LIB_writelog("StringLänge:"..string.len(StringLenTest).." Code -> "..tostring(StringLenTest).."",3,"Client_App_Log.txt")
		end
	end
end

function LIB_client_app_to_AccountID(account_id,app,value1,value2,value3,value4,value5,value6,value7,value8,value9,value10,value11,value12,value13,value14,value15,value16,value17,value18,value19,value20,value21,value22,value23,value24,value25,value26,value27,value28,value29,value30,value31,value32,value33,value34,value35,value36,value37,value38,value39,value40)
	if app != nil then
		if value1 == nil then	value1 = 0	end
		if value2 == nil then	value2 = 0	end
		if value3 == nil then	value3 = 0	end
		if value4 == nil then	value4 = 0	end
		if value5 == nil then	value5 = 0	end
		if value6 == nil then	value6 = 0	end
		if value7 == nil then	value7 = 0	end
		if value8 == nil then	value8 = 0	end
		if value9 == nil then	value9 = 0	end
		if value10 == nil then	value10 = 0	end
		if value11 == nil then	value11 = 0	end
		if value12 == nil then	value12 = 0	end
		if value13 == nil then	value13 = 0	end
		if value14 == nil then	value14 = 0	end
		if value15 == nil then	value15 = 0	end
		if value16 == nil then	value16 = 0	end
		if value17 == nil then	value17 = 0	end
		if value18 == nil then	value18 = 0	end
		if value19 == nil then	value19 = 0	end
		if value20 == nil then	value20 = 0	end
		
		if value20 == nil then	value20 = 0	end
		if value21 == nil then	value21 = 0	end
		if value22 == nil then	value22 = 0	end
		if value23 == nil then	value23 = 0	end
		if value24 == nil then	value24 = 0	end
		if value25 == nil then	value25 = 0	end
		if value26 == nil then	value26 = 0	end
		if value27 == nil then	value27 = 0	end
		if value28 == nil then	value28 = 0	end
		if value29 == nil then	value29 = 0	end
		if value30 == nil then	value30 = 0	end
		if value31 == nil then	value31 = 0	end
		if value32 == nil then	value32 = 0	end
		if value33 == nil then	value33 = 0	end
		if value34 == nil then	value34 = 0	end
		if value35 == nil then	value35 = 0	end
		if value36 == nil then	value36 = 0	end
		if value37 == nil then	value37 = 0	end
		if value38 == nil then	value38 = 0	end
		if value39 == nil then	value39 = 0	end
		if value40 == nil then	value40 = 0	end
		local StringLenTest = "client_app "..app.." "..value1.." "..value2.." "..value3.." "..value4.." "..value5.." "..value6.." "..value7.." "..value8.." "..value9.." "..value10.." "..value11.." "..value12.." "..value13.." "..value14.." "..value15.." "..value16.." "..value17.." "..value18.." "..value19.." "..value20.." "..value21.." "..value22.." "..value23.." "..value24.." "..value25.." "..value26.." "..value27.." "..value28.." "..value29.." "..value30.." "..value31.." "..value32.." "..value33.." "..value34.." "..value35.." "..value36.." "..value37.." "..value38.." "..value39.." "..value40..""
		game.CMD_ACCOUNTID_USERS_S(account_id,StringLenTest )
		LIB_writelog("StringLänge:"..string.len(StringLenTest).." AccountID: "..account_id.." Code -> "..tostring(StringLenTest).."",3,"Client_App_Log_to_AccountID.txt")
	end
end


function LIB_client_app_Multi(app,value1,value2,value3,value4,value5,value6,value7,value8,value9,value10,value11,value12,value13,value14,value15,value16,value17,value18,value19,value20,value21,value22,value23,value24,value25,value26,value27,value28,value29,value30,value31,value32,value33,value34,value35,value36,value37,value38,value39,value40)
	local Log = true
	if app != nil then
		if value1 == nil then	value1 = 0	end
		if value2 == nil then	value2 = 0	end
		if value3 == nil then	value3 = 0	end
		if value4 == nil then	value4 = 0	end
		if value5 == nil then	value5 = 0	end
		if value6 == nil then	value6 = 0	end
		if value7 == nil then	value7 = 0	end
		if value8 == nil then	value8 = 0	end
		if value9 == nil then	value9 = 0	end
		if value10 == nil then	value10 = 0	end
		if value11 == nil then	value11 = 0	end
		if value12 == nil then	value12 = 0	end
		if value13 == nil then	value13 = 0	end
		if value14 == nil then	value14 = 0	end
		if value15 == nil then	value15 = 0	end
		if value16 == nil then	value16 = 0	end
		if value17 == nil then	value17 = 0	end
		if value18 == nil then	value18 = 0	end
		if value19 == nil then	value19 = 0	end
		if value20 == nil then	value20 = 0	end
		
		if value20 == nil then	value20 = 0	end
		if value21 == nil then	value21 = 0	end
		if value22 == nil then	value22 = 0	end
		if value23 == nil then	value23 = 0	end
		if value24 == nil then	value24 = 0	end
		if value25 == nil then	value25 = 0	end
		if value26 == nil then	value26 = 0	end
		if value27 == nil then	value27 = 0	end
		if value28 == nil then	value28 = 0	end
		if value29 == nil then	value29 = 0	end
		if value30 == nil then	value30 = 0	end
		if value31 == nil then	value31 = 0	end
		if value32 == nil then	value32 = 0	end
		if value33 == nil then	value33 = 0	end
		if value34 == nil then	value34 = 0	end
		if value35 == nil then	value35 = 0	end
		if value36 == nil then	value36 = 0	end
		if value37 == nil then	value37 = 0	end
		if value38 == nil then	value38 = 0	end
		if value39 == nil then	value39 = 0	end
		if value40 == nil then	value40 = 0	end
		local StringLenTest = "client_app "..app.." "..value1.." "..value2.." "..value3.." "..value4.." "..value5.." "..value6.." "..value7.." "..value8.." "..value9.." "..value10.." "..value11.." "..value12.." "..value13.." "..value14.." "..value15.." "..value16.." "..value17.." "..value18.." "..value19.." "..value20.." "..value21.." "..value22.." "..value23.." "..value24.." "..value25.." "..value26.." "..value27.." "..value28.." "..value29.." "..value30.." "..value31.." "..value32.." "..value33.." "..value34.." "..value35.." "..value36.." "..value37.." "..value38.." "..value39.." "..value40..""
		if (is_test_server())	then
			dchatt("LIB_client_app_Multi  StringLänge:"..string.len(StringLenTest).." | Funktion:"..app.."")
		end
		game.CMD_ALL_USERS_S(StringLenTest)
		if Log == true then
			LIB_writelog("StringLänge:"..string.len(StringLenTest).." Code -> "..tostring(StringLenTest).."",3,"Client_AppMulti_Log.txt")
		end
	end
end

function LIB_SendQuestIndexClient(questname,questindex)
	local StringLenTest = "SendQuestIndexClient "..questname.." "..questindex..""
	cmdchat(StringLenTest)
end

function LIB_api_key_generate(l) -- args: smallest and largest possible password lengths, inclusive
	local char = {"a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z","0","1","2","3","4","5","6","7","8","9"}
	local size = l
	local r_pw = ""
	for z = 1,size do
		local a = math.random(1,table.getn(char)) -- randomly choose a character from the "char" array
		if math.random(1,2) == 1 then
			r_pw = r_pw..string.upper(char[a]) -- uppercase if case = 1
		else
			r_pw = r_pw..string.lower(char[a]) -- lowercase if case = 2
		end
	end
	return r_pw
end
-- game.get_event_flag("MonarchHealGold") //monarch_bless
-- game.get_event_flag("MonarchPowerupGold") //monarch_powerup
-- game.get_event_flag("MonarchDefenseGold") //monarch_defenseup
-- game.get_event_flag("MonarchWarpGold") //monarch_warp
-- game.get_event_flag("MonarchTransferGold") //monarch_transfe


function LIB_monarch_action_log(what)
	local empire = pc.get_empire()
	mysql_query("INSERT INTO "..DB_Log..".monarch_log (date_time,empire,player_id,base_y,base_x,mapindex,what) VALUES (NOW(),'"..empire.."','"..pc.get_player_id().."','"..pc.get_x().."','"..pc.get_y().."','"..pc.get_map_index().."','"..tostring(what).."')")
end

-- Energy System ItemCheck! Wird geprüft ob die Items aus dem Shop sind.
function LIB_energy_item_blocks(vnum)
	if bool_to_str(EnergyCheckBlockItems,"LIB_energy_item_blocks EnergyCheckBlockItems") == "false" then
		EnergyCheckBlockItems = 1
		local EnergyCheckBlockItemsVnum_tables = mysql_query("SELECT item_vnum from "..DB_Player..".shop_item")
		--local EnergyCheckBlockItemsVnum_tables = mysql_query("SELECT item_vnum from "..DB_Player..".shop_item where shop_vnum >= 6181 and shop_vnum <= 6186")
		for i = 1, table.getn(EnergyCheckBlockItemsVnum_tables), 1 do
			_G[ "EnergyCheckBlockItemsVnum_"..EnergyCheckBlockItemsVnum_tables[i][1] ] = 1
		end
		--chat("erste mal retzrn false")
		return true
	else
		if bool_to_str(_G[ "EnergyCheckBlockItemsVnum_"..vnum ],"LIB_energy_item_blocks: vnum:"..vnum.."") == "false" then
			return false
		else
			return true
		end
	end
end

-- Dungeon Log -> log.dungeon_log
function LIB_Dungeon_log(what,by_username_kill,group_count,map_index,groub_usernames)
	mysql_query("INSERT INTO "..DB_Log..".dungeon_log (date_time,what,by_username_kill,group_count,map_index,groub_usernames) VALUES (NOW(),'"..what.."','"..by_username_kill.."','"..tonumber(group_count).."','"..map_index.."','"..groub_usernames.."')")						
end

function LIB_DeniedMyAccount() --Account vorrübergehend deaktivieren
	say_title("User-Panel - Account Managment")
	say("")
	say("Hier kannst du deinen Account für einen Zeitraum")
	say("nicht nutzbar machen. Keiner kann sich einloggen.")
	say("Ist nützlich wenn man in den Urlaub möchte oder")
	say("eine Pause einlegen möchte.")
	say("")
	say_reward("Möchtest du dies nutzen?")
	if select("Ja","Nein") == 1 then
		say_title("User-Panel - Account Managment")
		say("")
		say("Wie viele Tage? ")
		local days_ = input()
		if days_ == "" or is_only_number(days_) == false then
		chat("ERROR")
		days_ = 0
		end
		if tonumber(days_) >= 182 then
		say_title("User-Panel - Account Managment")
		say("")
		say("Das sind zuviele Tage.")
		say("Nehm eine niedrigere Zahl")
		return
		end
		say_title("User-Panel - Account Managment")
		say("")
		say("Wie viele Stunden?")
		local hours_ = input()
		
		if hours_ == "" or is_only_number(hours_) == false then
		hours_ = 0
		end
		
		if tonumber(hours_) >= 24 then
		say_title("User-Panel - Account Managment")
		say("")
		say("Mehr wie 24 Stunden gehen nicht")
		say("Nehm eine niedrigere Zahl")
		return
		end
		
		local banTage = 60*60*24* days_
		local banstunden = 60*60* hours_
		local now = banTage + banstunden
		local sayy = time_to_str(get_time() + now +3600)
		say_title("User-Panel - Account Managment")
		say("")
		say("Aktuell: "..time_to_str(get_time() + 3600).."")
		say("Wird gesperrt bis: "..sayy.."")
		say("")
		say_reward("Bist du dir wirklich sicher?")
		local x = select("Ja","Nein")
		if x == 2 then
		return
		end
		--mysql_query("UPDATE "..DB_Account..".account SET  WHERE login = '"..pc.get_account().."'")
		local check = mysql_query("UPDATE "..DB_Account..".account SET availDt = CURRENT_TIMESTAMP(), availDt = DATE_ADD(availDt,INTERVAL "..now.." SECOND),ban_grund = '1337', ban_von = 'self_deactivate'  WHERE login = '"..pc.get_account().."'")
		if check[1] == "SUCCESS" then
			say_title("User-Panel - Account Managment")
			say("")
			say("Dein Account wurde erfolgreich deaktiviert.")
			say("Du kannst nun absofort nicht mehr einloggen.")
			mysql_query("INSERT INTO "..DB_Log..".self_deactive (account,date_time,to_deactive,player_name) VALUES ('"..pc.get_account().."',NOW(),'"..sayy.."','"..pc.get_name().."')")
			say("")
		else
			say_title("User-Panel - Account Managment")
			say("")
			say("Es ist ein Fehler aufgetreten!")
			say("Dein Account konnte nicht deaktiviert werden.")
			say("Vorgang abgebrochen!")
		end
	end
end

function LIB_is_GameMaster(name)
	if string.find(name,"]") then
		return true
	else
		return false
	end
end

function LIB_CanDrop(Special_R,Special_Pct) 
		-- if bool_to_str(ml,"_CanDrop mob_level") == 'false' 
		-- or bool_to_str(mk,"_CanDrop mob_rank") == 'false'
		-- or bool_to_str(pl,"_CanDrop pc_player") == 'false'
		-- then
			-- return false
		-- end
		local mob_id = npc.get_race()
		local mob_level = tonumber(LIB_get_mob_level(mob_id))
		local mob_rank = tonumber(npc.get_rank())
		local pc_player_level = tonumber(pc.get_level())
		if mob_level == 0 then
			return false
		end
		if pc_player_level == 0 then
			return false
		end 
		if pc_player_level > mob_level then
			return false
		end
		if mob_rank < 0 or mob_rank > 8 then
			return false
		end
		local mob_ranks = 
		{
		[0] = 100, --MOB_RANK_PAWN
		[1] = 200, --MOB_RANK_S_PAWN
		[2] = 300, --MOB_RANK_KNIGHT
		[3] = 400, --MOB_RANK_S_KNIGHT
		[4] = 500, --MOB_RANK_BOSS
		[5] = 600, --CHAMPION
		[6] = 700, --RARE
		[7] = 800, --LEGEND
		[8] = 900, --EVENTMOB
		}
		CanDropLevelCalc = false
		CanDropIsSpecialPct = false --Standart
		local pct_from_mob_ranks = mob_ranks[mob_rank]
		local player_level_diff = mob_level - pc_player_level
		local player_level_diff_R = number(1,15)
		if player_level_diff == 0 and number(1,5) == 1 then												CanDropLevelCalc = true
			elseif player_level_diff >= 0 and player_level_diff <= 1 and player_level_diff_R > 13 then	CanDropLevelCalc = true
			elseif player_level_diff >= 2 and player_level_diff <= 3 and player_level_diff_R > 10 then	CanDropLevelCalc = true
			elseif player_level_diff >= 4 and player_level_diff <= 5 and player_level_diff_R > 8 then	CanDropLevelCalc = true
			elseif player_level_diff >= 6 and player_level_diff <= 7 and player_level_diff_R > 6 then	CanDropLevelCalc = true
			elseif player_level_diff >= 8 and player_level_diff <= 9 and player_level_diff_R > 4 then	CanDropLevelCalc = true
			elseif player_level_diff >= 10 then															CanDropLevelCalc = true
			
		end
		local MobRandomPct = number(1,1500)
		if pct_from_mob_ranks < MobRandomPct and CanDropLevelCalc == true and CanDropIsSpecialPct == false then
			LIB_writelog("mob_level:"..mob_level.." mob_rank:"..mob_rank.." pc_player_level:"..pc_player_level.." pct_from_mob_ranks:"..pct_from_mob_ranks.." MobRandomPct:"..MobRandomPct.." player_level_diff:"..player_level_diff.." player_level_diff_R:"..player_level_diff_R.." CanDropLevelCalc:"..tostring(CanDropLevelCalc).." CanDropIsSpecialPct:"..tostring(CanDropIsSpecialPct).." # DROP TRUE",3,"CanDrop_Log.txt")
			return true
		else
			LIB_writelog("mob_level:"..mob_level.." mob_rank:"..mob_rank.." pc_player_level:"..pc_player_level.." pct_from_mob_ranks:"..pct_from_mob_ranks.." MobRandomPct:"..MobRandomPct.." player_level_diff:"..player_level_diff.." player_level_diff_R:"..player_level_diff_R.." CanDropLevelCalc:"..tostring(CanDropLevelCalc).." CanDropIsSpecialPct: "..tostring(CanDropIsSpecialPct).." # DROP FALSE",3,"CanDrop_Log.txt")
			return false
		end
end

function LIB_CheckNoDifferenzForNpcAndPlayer() --
	local x = npc.get_x() - pc.get_x()
	local y = npc.get_y() - pc.get_y()
	if x >= -1 and x <= 1 and y >= -1 and y <= 1 
	and 
	not (x == -1 and y == -1 
	or x == -1 and y == 1 
	or x == 1 and y == -1) --WEnn es bugt! 
	then
		return true
	else
		return false
	end
end

function LIB_GetNumberToBlock(v) --numtomoney --Wandelt Zahlen oder Buchstaben in Tausender Punkte um
	--local v = "ABCDEFGHIJKLMNOPQRSTUVWXYZ12"
	--local v = input()
	local tables = { }
	local gg = ""
	if string.len(v) <= 3 then
		return v
	end
	if string.len(v) == 4 then
		return string.sub(v, 1,1).."."..string.sub(v, 2,4)
	end
	for i = 2, string.len(v), 2 do
		if i == 2 then
			table.insert(tables,string.sub(v, string.len(v) -i,string.len(v) ))
		else 
			table.insert(tables,string.sub(v, string.len(v) -(i+1),string.len(v) -(i+1-2) ))
		end
	end
	for x = table.getn(tables), 1,-1 do
		if gg == "" then
			gg = tables[x]
		else
			gg = gg.."."..tables[x]
		end
	end
	return gg
end

function LIB_GetRandomCollectAnimationFailsMessage()
	local Animation_fails = { 
		"Beim Aufheben der Blume wurde sie geknickt.",
		"Die Blume ist beim berühen erfallen.",
		"Diese Blume wurde beschädigt von Spaziergängern."
	}
	local s = Animation_fails[ number(1, table.getn(Animation_fails) ) ]
	return s
end

function LIB_GetRandomCollectSuccessItemMessage()
	local SuccessItemsMessagess = { 
	"Hevorragend!", 
	"Sehr Gut!", 
	"Ausgezeichnet!",
	"Prima!"
	}
	local s = SuccessItemsMessagess[ number(1, table.getn(SuccessItemsMessagess) ) ]
	return s
end

function LIB_SplitWord(w) --Zerlegt das Word und return die ausgabe als Tabelle.
	local re = { }
	--local w = "hallo was geht"
	-- say("Debug: "..string.sub(w, 1,2).."")
	-- say("Debug: "..string.sub(w, 1,1).."")
	-- say("Debug: "..string.sub(w, 2,2).."")
	-- say("Debug: "..string.sub(w, 3,3).."")
	for i = 1, string.len(w), 1 do
		table.insert(re,table.getn(re) +1, string.sub(w, i,i) )
		--say("debug::: "..string.sub(w, i,i).."")
	end
	--say("count: "..table.getn(re).."")
	return re
end

function LIB_CheckOnlyLetters(w) --Prüft ob Nur Buchstaben sich im wort (Tabelle) befinden
	local bool_re = false
	for i = 1, table.getn(w), 1 do
		local c = tonumber( string.byte (w[i]) )
		--[[
		http://de.wikipedia.org/wiki/American_Standard_Code_for_Information_Interchange
		65 - 90  = A Z
		97 - 122 = a z
		]]
		if c >= 65 and c <= 90 then --
			bool_re = true
		elseif c >= 97 and c <= 122 then
			bool_re = true
		else --return automatisch false
			return false
		end
	end
	return bool_re
end

function LIB_SplitWordAndCheckOnlyLetters(word) --Zerlegt das Word und Prüft ob nur buchstaben im Word sind.
	--Info: Gedacht zum Überprüfen der Pet Namen...
	local bool_re = false
	for i = 1, string.len(word), 1 do
		local c = tonumber( string.byte( string.sub(word, i,i) ) )
		if c >= 65 and c <= 90 then --
			bool_re = true
		elseif c >= 97 and c <= 122 then
			bool_re = true
		else --return automatisch false
			return false
		end
	end
	return bool_re
	--[[ Version from ProfessorEnte (Dennis)
		if string.match(word, '^%a+$') then
			return true 
		else 
			return false
		end
	]]
end

function LiB_SendEffect_QuestFinish()
	pc.send_effect_path("d:\\\\ymir work\\\\effect\\\\etc\\\\buff\\\\quest.mse")
end

--Beta für neues Packet!
function LIB_client_app2(app,value1,value2,value3,value4,value5,value6,value7,value8,value9,value10,value11,value12,value13,value14,value15,value16,value17,value18,value19,value20,value21,value22,value23,value24,value25,value26,value27,value28,value29,value30,value31,value32,value33,value34,value35,value36,value37,value38,value39,value40)
	local Log = true
	if app != nil then
		if value1 == nil then	value1 = 0	end
		if value2 == nil then	value2 = 0	end
		if value3 == nil then	value3 = 0	end
		if value4 == nil then	value4 = 0	end
		if value5 == nil then	value5 = 0	end
		if value6 == nil then	value6 = 0	end
		if value7 == nil then	value7 = 0	end
		if value8 == nil then	value8 = 0	end
		if value9 == nil then	value9 = 0	end
		if value10 == nil then	value10 = 0	end
		if value11 == nil then	value11 = 0	end
		if value12 == nil then	value12 = 0	end
		if value13 == nil then	value13 = 0	end
		if value14 == nil then	value14 = 0	end
		if value15 == nil then	value15 = 0	end
		if value16 == nil then	value16 = 0	end
		if value17 == nil then	value17 = 0	end
		if value18 == nil then	value18 = 0	end
		if value19 == nil then	value19 = 0	end
		if value20 == nil then	value20 = 0	end
		
		if value20 == nil then	value20 = 0	end
		if value21 == nil then	value21 = 0	end
		if value22 == nil then	value22 = 0	end
		if value23 == nil then	value23 = 0	end
		if value24 == nil then	value24 = 0	end
		if value25 == nil then	value25 = 0	end
		if value26 == nil then	value26 = 0	end
		if value27 == nil then	value27 = 0	end
		if value28 == nil then	value28 = 0	end
		if value29 == nil then	value29 = 0	end
		
		if value30 == nil then	value30 = 0	end
		if value31 == nil then	value31 = 0	end
		if value32 == nil then	value32 = 0	end
		if value33 == nil then	value33 = 0	end
		if value34 == nil then	value34 = 0	end
		if value35 == nil then	value35 = 0	end
		
		if value36 == nil then	value36 = 0	end
		if value37 == nil then	value37 = 0	end
		if value38 == nil then	value38 = 0	end
		if value39 == nil then	value39 = 0	end
		if value40 == nil then	value40 = 0	end
		local replace_chr = "#"
		local StringLenTest = ""..app..replace_chr..value1..replace_chr..value2..replace_chr..value3..replace_chr..value4..replace_chr..value5..replace_chr..value6..replace_chr..value7..replace_chr..value8..replace_chr..value9..replace_chr..value10..replace_chr..value11..replace_chr..value12..replace_chr..value13..replace_chr..value14..replace_chr..value15..replace_chr..value16..replace_chr..value17..replace_chr..value18..replace_chr..value19..replace_chr..value20..replace_chr..value21..replace_chr..value22..replace_chr..value23..replace_chr..value24..replace_chr..value25..replace_chr..value26..replace_chr..value27..replace_chr..value28..replace_chr..value29..replace_chr..value30..replace_chr..value31..replace_chr..value32..replace_chr..value33..replace_chr..value34..replace_chr..value35..replace_chr..value36..replace_chr..value37..replace_chr..value38..replace_chr..value39..replace_chr..value40..""
		local string1 = ""
		local string2 = ""
		local string3 = ""
		--local StringLenTest = "hallowiegehts1234567890dummi"
		local max_len = 130
		if string.len(StringLenTest) > max_len then
			string1 = string.sub(tostring(StringLenTest), 0,max_len)
		end
		if string.len(StringLenTest) > (max_len*2) then
			string2 = string.sub(tostring(StringLenTest), max_len+1,max_len*2)
		end 
		if string.len(StringLenTest) > (max_len*2+1) then
			string3 = string.sub(tostring(StringLenTest), (max_len*2+1),string.len(StringLenTest))
		end 
		if string.len(StringLenTest) > max_len*3 then
			dchatt("<<FATAL ERROR>>> OVERLIMIT STRING LENGH "..string.len(StringLenTest).."")
			return
		end
		dchatt("string1: "..string1.."")
		dchatt("string2: "..string2.."")
		dchatt("string3: "..string3.."")
		ClientCommandsNew(app,string1,string2,string3)
		if Log == true then
			LIB_writelog("StringLänge:"..string.len(StringLenTest).." Code -> "..tostring(StringLenTest).."",3,"Client_App_Log2.txt")
		end
	end
	
	-- logbase2 = get_locale_base_path()
	-- logbase = string.gsub(logbase2,"germany", "")
	-- local file = "NewClientCommandsValue"
	-- local data = io.open(logbase..'/'..file,'w')
	-- local data = io.open(logbase..'/'..file,'a+')
	-- for i = 1, 40, 1 do
		-- data:write("#"..i.."\n")
		-- data:write("try:\n")
		-- data:write("	value"..i.." = GetString["..i.."]\n")
		-- data:write("except:\n")
		-- data:write("	value"..i.." = 0\n")
	-- end
    -- data:close()
		
		
end

function LIB_Convert_mobdropitemfile()
--[[
	local need_time = get_global_time()
	logbase = get_locale_base_path()
	CUBE_datei=io.open(logbase..'/mob_drop_item.txt',"r")
	CUBE_result_items = ""
	local GroupCounts = 0
	local GroupNumberLine = 1
	local Groupbegin = false
	for CUBE_line in CUBE_datei:lines() do
		var = CUBE_line	
		local hr = Split2(var, "	")
		
		if string.find(string.lower(var),'group') and Groupbegin == false then
			GroupNumberLine = 1
			Groupbegin = false
			GroupCounts = GroupCounts +1
		end
		if string.find(var,'}') and Groupbegin == true then
			Groupbegin = false
		end
			
		if table.getn(hr) > 5 and not ( string.find( string.lower(var) ,'mob') or string.find( string.lower(var) ,'type') )  then
			local _NameItemSplit = Split2(var, "#")
			local vnum = hr[3]
			--dchat("count hr: "..table.getn(hr).." hr1: "..hr[3].." vnum:"..vnum.."")
			--dchat("count _NameItemSplit: "..table.getn(_NameItemSplit).." _NameItemSplit:".._NameItemSplit[1].."")
			--dchat("write: ".._NameItemSplit[1].."")
			local v = _NameItemSplit[1]
			-- dchat("newwite:  "..newwrite.."")
			local r = "	"..hr[1]..""..hr[2]
			local newwrite  = "	"..GroupNumberLine..""..string.gsub(v,r, "",1)
			dchat("remove:'"..r.."'")
			CUBE_result_items = CUBE_result_items..newwrite.."\n"
			GroupNumberLine = GroupNumberLine+1
		else
			CUBE_result_items = CUBE_result_items..var.."\n"
		end

	end
	local data = io.open(logbase..'/mob_drop_item_CONVERT.txt','a')
	data:write(CUBE_result_items.."\n")
	data:close()
	say("Gesammt Groups: "..GroupCounts.."")
	say("Benötigte Zeit: "..math.abs(get_global_time() - need_time).." Sekunden")
	say("Benötigte Zeit: "..LIB_duration(get_global_time() - need_time).."")
	]]
end

-- Official Events
EVENT_TYPE_MYSTERY_BOX_DROP = 1
EVENT_TYPE_E_BUFF_SPAWN = 2
EVENT_TYPE_MINI_GAME_OKEY = 3
EVENT_TYPE_NEW_XMAS_EVENT = 4
EVENT_TYPE_MINI_GAME_YUTNORI = 5
EVENT_TYPE_ATTENDANCE = 6
EVENT_TYPE_E_MONSTERBACK = 7
EVENT_TYPE_EASTER_DROP = 8
EVENT_TYPE_E_SUMMER_EVENT = 9
EVENT_TYPE_RAMADAN_DROP = 10
EVENT_TYPE_HALLOWEEN_BOX = 11
EVENT_TYPE_SOUL_EVENT = 12
EVENT_TYPE_FOOTBALL_DROP = 13
EVENT_TYPE_MEDAL_PART_DROP = 14
EVENT_TYPE_VALENTINE_DROP = 15
EVENT_TYPE_FISH_EVENT = 16
EVENT_TYPE_E_FLOWER_DROP = 17
EVENT_TYPE_MINI_GAME_CATCHKING = 18
EVENT_TYPE_MD_START = 19
EVENT_TYPE_MINI_GAME_FINDM = 20
EVENT_TYPE_E_LATE_SUMMER = 21
EVENT_TYPE_MINI_GAME_BNW = 22
EVENT_TYPE_WORLD_BOSS = 23
EVENT_TYPE_BATTLE_ROYALE = 24
-- Custom
EVENT_TYPE_EXPERIENCE = 25
EVENT_TYPE_ITEM_DROP = 26
EVENT_TYPE_SUPER_METIN = 27
EVENT_TYPE_BOSS = 28
EVENT_TYPE_OX = 29
EVENT_TYPE_MANWOO = 30
EVENT_TYPE_MINING = 31
EVENT_TYPE_BUDOKAN = 32
EVENT_TYPE_SUNGZI_WAR = 33
-- Custom drop events
EVENT_TYPE_MOONLIGHT = 34
EVENT_TYPE_HEXEGONAL_CHEST = 35
EVENT_TYPE_HUNT_YOUR_MOUNT = 36
-- Unused
EVENT_TYPE_GOLD_FROG = 37
EVENT_TYPE_TANAKA = 38
EVENT_TYPE_HIDE_AND_SEEK = 39
EVENT_TYPE_MAX = 40

-- DROP_TYPE
DROP_TYPE_NONE = 1
DROP_TYPE_GENERAL = 2
DROP_TYPE_BOSS_AND_MORE = 3
DROP_TYPE_BOSS = 4
DROP_TYPE_STONE = 5
DROP_TYPE_MAX = 6
