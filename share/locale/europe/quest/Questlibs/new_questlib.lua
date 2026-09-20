--[[
    Questliberweiterung generiert by Mijago
    Link: http://questwriting.mijago.org/questlib/index.php?exec=1&updater=0&b1=1&b2=1&b10=1&b12=1&b23=1&b41=1&b42=1&b43=1&b44=1&b45=1&b46=1&b47=1&b48=1&b49=1&b60=1&b61=1&b101=1&b102=1&b103=1&b104=1&b106=1&b201=1&b301=1&b801=1&b802=1&b803=1&b804=1&b805=1&b806=1&b901=1&b902=1&b903=1&b904=1&b905=1&b1000=1&b1001=1&b1002=1&b1003=1&b1004=1&b2002=1
    Funktionen: 
        split, mysql_query, mysql_query_old, define, duration, is_number,
        is_string, is_table, in_table, numlen, string.reverse, num_format,
        numtomoney, math.minmax, n_input, long_input, select2, select3,
        note (Notice Mod), Zeitrechnungen, Autoumbruch in Say, mysql_escape, account.set_pw, pc.check_inventory_place,
        do_for_other, local_pc_setqf, pc.trans, pc.warp_to, local_warp_pc, download,
        dot, dostr, wartungsmodus, create_folder, INI-Parser, Ini-Parser (alt),
        csay, Farbcodes, Apache-Funktionen, TS3-Funktionen
--]]


--[[
    @name   split
    @author Internet (http://lua-users.org/wiki/SplitJoin)
    @descr
Splittet einen String in eine Tabelle.
--]]
function split(str, delim, maxNb) -- mysql_query needs split function.
	if str == nil then return str end 
	if string.find(str, delim) == nil then return { str } end 
	if maxNb == nil or maxNb < 1 then maxNb = 0 end 
	local result = {} 
	local pat = "(.-)" .. delim .. "()" 
	local nb = 0 
	local lastPos 
	for part, pos in string.gfind(str, pat) do 
		nb = nb + 1 
		result[nb] = part 
		lastPos = pos 
		if nb == maxNb then break end 
	end 
	if nb ~= maxNb then result[nb + 1] = string.sub(str, lastPos) end 
	return result 
end


mysql_query = function(query)
    if not pre then
        local rt = io.open('CONFIG','r'):read('*all')
        pre,_= string.gsub(rt,'.+PLAYER_SQL:%s(%S+)%s(%S+)%s(%S+)%s(%S+).+','-h%1 -u%2 -p%3 -D%4')
    end
    math.randomseed(os.time())
    local fi,t,out = 'mysql_data_'..math.random(10^9)+math.random(2^4,2^10),{},{}
    --os.execute('mysql '..pre..' --e='..string.format('%q',query)..' > '..fi) -- für MySQL51
    os.execute('mysql '..pre..' -e'..string.format('%q',query)..' > '..fi) -- für MySQL55
    for av in io.open(fi,'r'):lines() do table.insert(t,split(av,'\t')) end; os.remove(fi);
    for i = 2, table.getn(t) do table.foreach(t[i],function(a,b)
        out[i-1]               = out[i-1] or {}
        out[i-1][a]            = tonumber(b) or b or 'NULL'
        out[t[1][a]]           = out[t[1][a]] or {}
        out[t[1][a]][i-1]      = tonumber(b) or b or 'NULL'
    end) end
    return out
end


--[[
    @name   mysql_query_old
    @author Mijago
    @needs  split
    @descr
Die Alte Version der MySQL-Query-Funktion.
--]]
local ql = {
    ["user"] = "root",
    ["pass"] = "",
    ["ip"] = "localhost",
    ["db"]    = "player"
}
function mysql_query_old(query,user,pass,db,ip)
    local pre = ''
    if query == '' or query == nil then
        error("Query muss gesetzt sein!")
    end
    user = user or ql.mysql["user"]
    pass = pass or ql.mysql["pass"]
    ip = ip or ql.mysql["ip"]
    if user ~= '' and user ~= nil then pre = pre..' -u'..user end
    if pass ~= '' and pass ~= nil then pre = pre..' -p'..pass end
    if db ~= '' and db ~= nil then pre = pre..' -D'..db end
    if ip ~= '' and ip ~= nil then pre = pre..' -h'..ip end
    math.randomseed(os.time()); local rand = math.random(0,10^7) -- Erstellen der Pfadvariable
    local path = 'data/mysql_output_'..os.time()..'_'..rand..'_'..pc.get_vid()
    os.execute ("mysql "..pre.." --e=\""..query.."\" > "..path) -- Laden und Auflisten der Dateiinhalte
    local fi,q = io.open(path,"r"),{["l"] = {},["out"]={}}
    if fi == nil then
        return "ERROR"
    end
    for line in fi:lines() do table.insert(q.l,(split(line,"\t"))) end
    os.remove(path)
    if type(q.l[1]) ~= "table" then 
        return "ERROR"
        --error("Fehler bei der MySQL Verbindung oder bei der Rückgabe! Abbruch!")
    end
    local ix = 0
    table.foreachi(q.l,function(i,l)
        if i > 1 then table.foreach(l,function(i2,l2)
            if q.out[q.l[1][i2]] == nil then q.out[q.l[1][i2]] = {} end
            local c =  tonumber(l2)
            if type(c) == "number" and l2 == tostring(c) then
                q.out[q.l[1][i2]][i-1] = c
            else
                q.out[q.l[1][i2]][i-1] = l2
            end
        end) end
    end)
    -- ENDE der eigentlichen MySQL-Funktion
    -- START Zusatz: Hanashi-Kompatibilität & Fehlerbehandlung
    q.out.__data = q.l[1]
    setmetatable(q.out, { __index = function(a,b) 
        if type(b) == "number" then
            return (a[a.__data[b]] or {"ERROR"})
        end
        return "ERROR"
        --error("Fehler bei Indexierung: Index "..b.." ist nicht vorhanden!")
    end})
    return q.out
end


--[[
    @name   define
    @author Mijago
    @descr
Gibt die Möglichkeit, globale Variablen zu definieren. Es können auch Funktionen genutzt werden! Diese werden dann AUSGEFÜHRT zurückgegeben!
--]]
_G.__data = {}
local meta = getmetatable(_G) or {}
meta.__index = function(me,index) 
    local data = _G.__data[index]
    if type(data) == "function" then
        return data()
    else -- auch bei nil!
        return data
    end
end    
setmetatable(_G,meta)

--[[
    @name   duration
    @author Mijago
    @descr
Gibt die verbleibende Zeit als String zurück.
--]]
function duration(ipe) 
    local ipe,dat= ipe or 0,''
	local s,m,h,d,mo,y = tonumber(os.date('%S',ipe)),
					  tonumber(os.date('%M',ipe)),
					  tonumber(os.date('%H',ipe)),
					  tonumber(os.date('%d',ipe))-1,
					  tonumber(os.date('%m',ipe))-1,
					  tonumber(os.date('%Y',ipe))-1970
	for x,c in {{s,"Sek."},{m,"Min."},{h,"Std."},{d,"Tage","Tag"},{mo,"Monate","Monat"},{y,"Jahre","Jahr"}} do
		if (c[1] or 0) > 0 then
			if x > 1 then dat = ' '..dat end
            if c[1] > 1 then
                dat = c[1]..' '..c[2]..dat
            else 
                dat = c[1]..' '..(c[3] or c[2])..dat
            end
		end
	end	
    return dat
end 


--[[
    @name   is_number
    @author Mijago
    @descr
Prüft, ob eine Variable eine Zahl ist.
--]]
function is_number(var)
    return (type(var) == "number")
end	


--[[
    @name   is_string
    @author Mijago
    @descr
Prüft, ob eine Variable ein String ist.
--]]
function is_string(var)
    return (type(var) == "string")
end


--[[
    @name   is_table
    @author Mijago
    @descr
Prüft, ob eine Variable eine Tabelle ist.
--]]
function is_table(var)
    return (type(var) == "table")
end


--[[
    @name   in_table
    @author Mijago
    @descr
Prüft, ob eine Variablei in einer Tabelle ist.
Aufruf: in_table(var,table)
--]]
function in_table ( e, t )
    for _,v in pairs(t) do
        if (v==e) then 
            return true 
        end
    end
    return false
end


--[[
    @name   numlen
    @author Mijago
    @descr
Gibt die Anzahl der Ziffern einer Zahl wieder.
--]]
function numlen(i)
    local i,x = i or 0,0
    while i > 10^x do x=x+1 end
    return x
end


--[[
    @name   string.reverse
    @author Mijago
    @descr
Kehrt einen String um.
--]]
function string.reverse(str)
    local se = ''
    for i=1,string.len(str) do
        se = string.sub(str,i,i)..se
    end
    return se
end


--[[
    @name   num_format
    @author Mijago; Idee von Benhero
    @needs  string.reverse
    @descr
Formatiert lange Zahlen mit Punkten.

--]]
function num_format(num)
    if type(num) == "number" then num = tostring(num) end
    if string.len(num) <= 3 then return num end
    return string.reverse(string.gsub(string.reverse(num),'(%d%d%d)','%1.'))
end

--[[
    @name   math.minmax
    @author Mijago
    @descr
Ermöglicht die Angabe von min und max auf einmal
--]]
math.minmax = function(min,num,max)
    return math.min(math.max(num,min),max)
    -- oder:  return num > max and max or num < min and min or num
end

--[[
    @name   long_input
    @author Mijago
    @descr
Ermöglicht es, längere Inputs zu nutzen.
--]]
function long_input()
    local str,t = "",input()
    while t ~= "" do
        str = str..t
        t = input()
    end
    return str, str ~= ""
end


--[[
    @name   select2
    @author Mijago
    @needs  split
    @descr
Wie Select:
Eine Tabelle oder eine  Stringliste wird auf Seiten aufgeteilt.
Weiter und Abbrechen Buttons.
--]]
function select2(tab,...)
    arg.n = nil
    if type(tab) ~= "table" and type(tab) == 'number' then
        table.insert(arg,1,tab)
        tab = arg
    elseif type(tab) ~= "table" and type(tab) == 'string' then
        table.insert(arg,1,tab)
        table.insert(arg,1,8)
        tab = arg
    elseif type(tab) == "table" and type(tab[1]) == 'string' then
        table.insert(tab,1,8)
    end
    local max = tab[1]; table.remove(tab,1)
    local tablen,outputstr,outputcount,nextc,incit = table.getn(tab),"",0,0,0
    table.foreach(tab,
        function(i,l)
            outputcount = outputcount + 1
            if outputcount == 1 then
                outputstr=outputstr..'sel = select("'..l..'"'
            elseif outputcount == max and tablen > outputcount+incit  then
                if tablen ~= outputcount+incit+1 then
                    outputstr=outputstr..',"'..l..'","Nächste Seite") + '..incit..' '
                    if nextc > 0 then
                        outputstr = outputstr..'end '
                    end
                    outputstr=outputstr..'; if sel == '..(incit+max+1)..' then '        -- Anfangen der neuen Abfrage
                    nextc, outputcount, incit= nextc+1,0,incit+max
                else
                    outputstr=outputstr..',"'..l..'"'
                end
            else
                outputstr=outputstr..',"'..l..'"'
            end
        end
    )
    outputstr = outputstr..') + '..incit
    if nextc > 0 then
        outputstr = outputstr..' end'
    end
    outputstr= outputstr.. '; return sel'
    print(outputstr)
    local sel = assert(loadstring(outputstr))()
    tablen,outputstr,outputcount,nextc,incit = nil,nil,nil,nil,nil -- Speicher freimachen
    return sel
end



--[[
    @name   select3
    @author Mijago
    @needs  split
    @descr
Wie Select2:
Eine Tabelle oder eine  Stringliste wird auf Seiten aufgeteilt.
Weiter, Zurück und Abbrechen (-1) Buttons.
--]]
function select3(...)
    arg.n = nil
    local tp,max = arg,5
    if type(tp[1]) == 'number' then
        max = tp[1]
        if type(tp[2]) == 'table' then
            tp = tp[2]
        else
            table.remove(tp,1)
        end
    elseif type(tp[1]) == 'table' then
        if type(tp[1][1]) == 'number' then
            max = tp[1][1]
            table.remove(tp[1],1)
            tp = tp[1]
        end
        tp = tp[1]
    end
    local str = '{'
    local tablen,act,incit = table.getn(tp),0,0
    table.foreach(tp,function(i,l)
        act = act + 1
        if act == 1 then
            str = str .. '{'..string.format('%q',l)
        elseif act == max+1 and tablen > act+incit then
            if tablen ~= act+incit+1 then
                str = str..'},{'..string.format('%q',l)
            else
                str=str..','..string.format('%q',l)
            end
            incit = incit + max
            act = 1
        else
            str=str..','..string.format('%q',l)
        end
    end)
    local px = loadstring('return '..str ..'}}')()
    local function copy_tab(t) local p= {} for i = 1,table.getn(t) do p[i] = t[i] end return p end
    local pe = {}
    for i = 1,table.getn(px) do pe [i] = copy_tab(px[i]) end
    local function init(i,ip)
        pe[i] = copy_tab(px[i])
        local next,back,exit = 0,0,0
        if i < table.getn(pe) and table.getn(pe) ~=1 then  table.insert(pe[i],table.getn(pe[i])+1,'Weiter zu Seite '..(i+1)); next = table.getn(pe[i]) end
        if i > 1 then table.insert(pe[i],table.getn(pe[i])+1,'Zurück zu Seite '..(i-1)); back = table.getn(pe[i]) end
        table.insert(pe[i],table.getn(pe[i])+1,'Abbruch'); exit = table.getn(pe[i])
        if table.getn(pe) > 1 then
            say('Seite '..i..' von '..table.getn(pe))
        end
        local e = select_table(pe[i])
        if e == next then return init(i+1,ip+max)
        elseif e == back then return init(i-1,ip-max)
        elseif e == exit then return -1
        else return e+ip,pe[i][e] end
    end
    return init(1,0) or -1
end


--[[
    @name   note (Notice Mod)
    @author Mijago
    @descr
Wie Notice, nur mit Spielername davor.
--]]
function note(text)
    notice_all(pc.get_name()..': '..text)
end


--[[
    @name   Zeitrechnungen
    @author Mijago
    @descr
Funktionen zum Umrechenen von Zeit.
--]]
zt = zt or {}
zt.d_j = 	function(d)
                return d/365
            end
zt.d_mo = 	function(d)
                return d/12
            end
zt.d_h = 	function(d)
                return d*24
            end
zt.d_m = 	function(d)
                return d*24*60
            end
zt.d_s = 	function(d)
                return d*24*60*60
            end
zt.d_hs = 	function(d)
                return d*24*60*60*100
            end
zt.d_ms = 	function(d)
                return d*24*60*60*1000
            end
--- Stunden
zt.h_j = 	function(h)
                return h/24/365
            end
zt.h_mo = 	function(h)
                return h/24/12
            end
zt.h_d = 	function(h)
                return h/24
            end
zt.h_m = 	function(h)
                return h*60
            end
zt.h_s = 	function(h)
                return h*60*60
            end
zt.h_hs = 	function(h)
                return h*60*60*100
            end
zt.h_ms = 	function(h)
                return h*60*60*1000
            end
--- Minuten
zt.m_j = 	function(m)
                return m/60/24/365
            end
zt.m_mo = 	function(m)
                return m/60/24/12
            end
zt.m_d = 	function(m)
                return m/60/24
            end
zt.m_h = 	function(m)
                return m/60
            end
zt.m_s = 	function(m)
                return m*60
            end
zt.m_hs = 	function(m)
                return m*60*100
            end
zt.m_ms = 	function(m)
                return m*60*1000
            end
--- Sekunden
zt.s_j = 	function(s)
                return s/60/60/24/365
            end
zt.s_mo = 	function(s)
                return s/60/60/24/12
            end
zt.s_d = 	function(s)
                return s/60/60/24
            end
zt.s_h = 	function(s)
                return s/60/60
            end
zt.s_m = 	function(s)
                return s/60
            end
zt.s_hs = 	function(s)
                return s*100
            end
zt.s_ms = 	function(s)
                return s*1000
            end	


--[[
    @name   Autoumbruch in Say
    @author Mijago
    @descr
Fügt die Funktion say2 an. 
Mit ihr werden Texte automatisch umgebrochen.
--]]
function say2(str,dx) 
    local maxl,actl,pat = dx or 50,0,'(.-)(%[.-%])()' 
    local result,nb,lastPos,outp = {},0,0,'' 
    local function bere(stx) 
        for le in string.gfind(stx,'((%S+)%s*)') do  
            if actl + string.len(le) > maxl then  
                outp = outp..'[ENTER]'  
                actl = 0  
            end  
            outp = outp..le  
            actl = actl + string.len(le)  
        end  
    end 
    for part, dos,pos in string.gfind(str, pat) do  
        if part ~= '' then  
            bere(part) 
        end 
        outp = outp..dos  
        lastPos = pos  
    end  
    bere(string.sub(str,lastPos)) 
    say(outp) 
end 


--[[
    @name   mysql_escape
    @author Mijago
    @descr
Wie mysql_real_escape_string in PHP;
Hilft, SQLi vorzubeugen.
--]]
function mysql_escape(str)
    str = string.gsub(str,"%\\", "\\\\")
--    str = string.gsub(str,"%\0", "\\0") Gibt einen fehler aus :o | Wer rausfindet, warum.. Bitte mir Schreiben (Mijago)
    str = string.gsub(str,"%\n", "\\n")
    str = string.gsub(str,"%\r", "\\r")
    str = string.gsub(str,"%\x1a", "\Z")
    str = string.gsub(str,"%\'", "\\'")
    str = string.gsub(str,'%\"', '\\"')
    return str
end


--[[
    @name   account.set_pw
    @author Mijago; Idee von Benhero
    @needs  mysql_query
    @descr
Funktion zum Ändern des Nutzerpasswortes.
Angabe des Accounts kann weggelassen werden, als Accountname oder als Account ID angegeben werden.
--]]
account = account or {}
function account.set_pw(pw,ac)
    if pw == nil then error("Fehler... Passwort muss gesetzt werden!") end
    local ac = ac or pc.get_account_id() 
    if type(ac) == "string" then
        mysql_query("UPDATE player.player,account.account SET account.password = password("..string.format('%q',pw)..") WHERE account.id = player.account_id and player.name = '"..ac.."' LIMIT 1")
    elseif type(ac) == "number" then
        mysql_query("UPDATE account.account SET account.password = password("..string.format('%q',pw)..") WHERE account.id = "..ac)
    end
end 


--[[
    @name   pc.check_inventory_place
    @author Mijago
    @descr
Checkt auf Freie Inventarplätze für Items der größe X (Höhe).
--]]
function pc.check_inventory_place(size)
    if size <= 0 or size > 3 then
        return -1
    end
    function check(c)
        for i = 0,size-1 do
            item.select_cell(e[c+(5*i)])
            if item.get_id() ~= 0 then
                return false
            end
        end
        return true
    end
    for i = 0,89 do 
        if check(i) then 
            return i 
        end
    end
    return -1
end


--[[
    @name   do_for_other
    @author Mijago
    @descr
Führt einen String als Luabefehle bei einem anderem User aus.
--]]
function do_for_other(name,ding)
    local t = pc.select(find_pc_by_name(name))
    assert(loadstring(ding))()
    pc.select(t)
end


--[[
    @name   local_pc_setqf
    @author Mijago
    @descr
Setzt die Questflag eines anderen Spielers.
--]]
function local_pc_setqf(name, qf,wert) -- Für die aktuelle Quest
    local target = find_pc_by_name(name)
    local t = pc.select(target)
    pc.setqf(qf,wert)
    pc.select(t)
end


--[[
    @name   pc.trans
    @author Mijago
    @descr
Warpt Spieler B zu Spieler A.
Spieler a = pc.
--]]
function pc.trans(vid)
    if vid == nil then
        error"VID muss gesetzt sein! (pc.warp_to)"
    elseif type(vid) == "string" then
        vid = find_pc_by_name(vid)
        if vid == 0 then
            error"Spieler nicht gefunden"
        end
    end
    local x,y = pc.get_x()*100,pc.get_y()*100
    local me = pc.select(vid)
    pc.warp(x,y)
    pc.select(me)
end


--[[
    @name   pc.warp_to
    @author Mijago
    @descr
Warpt Spieler A zu Spieler B.
Spieler a = pc.
--]]
function pc.warp_to(vid)
    if vid == nil then
        error"VID muss gesetzt sein! (pc.warp_to)"
    elseif type(vid) == "string" then
        vid = find_pc_by_name(vid)
        if vid == 0 then
            error"Spieler nicht gefunden"
        end
    end
    local me = pc.select(vid)
    local x,y = pc.get_x()*100,pc.get_y()*100
    pc.select(me)
    pc.warp(x,y)
end


--[[
    @name   local_warp_pc
    @author Mijago
    @descr
Warpt einen anderen Spieler lokal.
--]]
function local_pc_warp(name, x, y,mid)
    local target = find_pc_by_name(name)
    local t = pc.select(target)
    if mid == nil then
        mid = pc.get_map_index()
    end
    pc.warp_local(mid, x*100, y*100)
    pc.select(t)
end


--[[
    @name   download
    @author Mijago
    @descr
Lädt eine Datei in den Data-Ordner.
--]]
function download(url) os.execute("cd data && fetch "..url.." && cd ..") end


--[[
    @name   dot
    @author Mijago
    @descr
Führt alles Zwischen $ und $ im String aus.
--]]
function dot(x)
    return string.gsub(x, "%$(.-)%$", function (s) return loadstring(s)() end) 
end


--[[
    @name   dostr
    @author Mijago
    @descr
Führt einen String als Lua-Befehl aus.
--]]
function dostr(str)
    assert(loadstring(str))()
end


--[[
	Returns:
		true, if the 'int' integer number is Odd,
		else, false.
]]
isOdd = function(int)
	local real_int = tonumber(int);
	return math.mod(real_int, 2) == 0;
end -- function

--[[
	Returns:
		true if the 'table_ex' array contains an argument which index keyword is 'keyword',
		else, false.

	Example:
		local table = {
			["lul"] = 1,
			["asd"] = 2,
			["xd"] = 3
		};
			
		table_contains_keyword(table, "xd"); -> returns true.
		table_contains_keyword(table, "nup"); -> returns false.
]]
table_contains_keyword = function(table_ex, keyword)
	return table_ex[keyword] ~= nil;
end -- function

--[[
	Gets:
		The index of the array containing the specified keyword.

	Example:
		local table = {
			["lul"] = 1,
			["asd"] = 2,
			["xd"] = 3
		};

		table_get_keyword_index(table, "xd"); -> returns 3.
		table_get_keyword_index(table, "lul"); -> returns 1.
		table_get_keyword_index(table, "nup"); -> returns nil.
]]
table_get_keyword_index = function(array, keyword)
	for i = 1, table.getn(array) do
		if (array[i][keyword] ~= nil) then
			return i;
		end -- if
	end -- for
	
	return nil;
end -- function

--[[
	Returns:
		true, if any subarray of the specified array contains a specified keyword inside it,
		else false.

	Example:
		local table = {
			[1] = {["lul"] = 1},
			[2] = {["asd"] = 2},
			[3] = {["xd"] = 3},
		};

		table_is_any_subarray_containing_keyword(table, "xd"); -> returns true.
		table_is_any_subarray_containing_keyword(table, "nup"); -> returns false.
]]
table_is_any_subarray_containing_keyword = function(array, keyword)
	for i = 1, table.getn(array) do
		if (array[i][keyword] ~= nil) then
			return true;
		end -- if
	end -- for
	
	return false;
end -- function

--[[
	Gets:
		The index of the subarray containing a specified keyword inside it.

	Example:
		local table = {
			[1] = {["lul"] = 5},
			[2] = {["asd"] = 6},
			[3] = {["xd"] = 7},
		};

		table_get_subarray_keyword_index(table, "xd"); -> returns 3.
		table_get_subarray_keyword_index(table, "lul"); -> returns 1.
		table_get_subarray_keyword_index(table, "nup"); -> returns nil.
]]
table_get_subarray_keyword_index = function(array, keyword)
	for i = 1, table.getn(array) do
		if (array[i][keyword] ~= nil) then
			return i;
		end -- if
	end -- for
	
	return nil;
end -- function

--[[
	Returns:
		The number of days a 'value' number of seconds represents.
		(86400 seconds = 1 day)
]]
time_day_to_sec = function(value)
	return 86400*value;
end -- function

--[[
	Returns:
		The number of weeks a 'value' number of seconds represents.
		(604800 seconds = 1 week)
]]
time_week_to_sec = function(value)
	return 604800*value;
end -- function

--[[
	Returns:
		The number of 28-day months a 'value' number of seconds represents.
		(16934400 seconds = one 28-day month)
]]
time_month_to_sec_28_days = function(value)
	return 16934400*value;
end -- function

--[[
	Returns:
		The number of 30-day months a 'value' number of seconds represents.
		(18144000 seconds = one 30-day month)
]]
time_month_to_sec_30_days = function(value)
	return 18144000*value;
end -- function

--[[
	Returns:
		The number of 31-day months a 'value' number of seconds represents.
		(18748800 seconds = one 31-day month)
]]
time_month_to_sec_31_days = function(value)
	return 18748800*value;
end -- function

--[[
	Returns:
		The time format in years, months, days, hours, minutes and seconds of a 'sec'
		amount of time (in seconds) to format.

	Example:
		get_time_format(52165786) => returns "1 year, 7 months, 25 days, 11 hours, 17 minutes and 34 seconds".
]]
get_time_format = function(sec)
	local sec = tonumber(sec);
	local final_str = "";
	local string_type = "";

	local epoch = {["hour"] = 1, ["day"] = 1, ["month"] = 1, ["year"] = 1970};
	local time_formats = {
		{["date"] = tonumber(os.date('%S', sec)),                ["plural"] = "seconds", ["singular"] = "second"},
		{["date"] = tonumber(os.date('%M', sec)),                ["plural"] = "minutes", ["singular"] = "minute"},
		{["date"] = tonumber(os.date('%H', sec))-epoch["hour"],  ["plural"] = "hours",   ["singular"] = "hour"},
		{["date"] = tonumber(os.date('%d', sec))-epoch["day"],   ["plural"] = "days",    ["singular"] = "day"},
		{["date"] = tonumber(os.date('%m', sec))-epoch["month"], ["plural"] = "months",  ["singular"] = "month"},
		{["date"] = tonumber(os.date('%Y', sec))-epoch["year"],  ["plural"] = "years",   ["singular"] = "year"}
	};

	for strings, data in time_formats do
		if (data["date"] > 0) then
			if (strings > 1) then
				final_str = string.format(" %s", final_str);
			end -- if
			
			if (data["date"] > 1) then
				string_type = data["plural"];
			else
				string_type = data["singular"];
			end -- if/else
			
			final_str = string.format("%d %s%s", data["date"], string_type, final_str);
		end -- if
	end -- for

    return final_str;
end -- function

--[[
	Executes:
		The conversion of the 'int' integer number into a string representing that number in Roman form
		Example: 1 = I, 10 = X.
]]
IntToRomanStr = function(int)
	local real_int = tonumber(int);

	if (real_int < 1) then
		return "0";

	elseif (real_int > 5000) then
		return "";
	end -- if/elseif

    local str = "";
    local array = {
		[1] = {"", "I", "II", "III", "IV", "V", "VI", "VII", "VIII", "IX"},
		[10] = {"", "X", "XX", "XXX", "XL", "L", "LX", "LXX", "LXXX", "XC"},
		[100] = {"", "C", "CC", "CCC", "CD", "D", "DC", "DCC", "DCCC", "CM"},
		[1000] = {"", "M", "MM", "MMM", "MMMM", "MMMMM"}
    };

    for x = 3, 0, -1 do
        local index = math.pow(10, x);
        local subindex = math.floor(real_int / index);

        str = string.format("%s%s", str, array[index][subindex+1]);
        real_int = real_int - subindex * index;
    end -- for

    return str;
end -- function

--[[
	Executes:
		A complete dungeon clear of the monsters and regens.
		if 'zombies' (bool) is true, it will execute a further d.kill_all() to kill even those who resurrect once.
]]
clear_dungeon = function(zombies)
	if (pc.in_dungeon()) then
		d.clear_regen()
		d.kill_all();
		
		if (zombies) then
			d.kill_all();
		end -- if
	end -- if
end -- function

--[[
	Returns:
		The pids of every single member inside the party.
]]
party_get_member_pids = function()
	local pids = {party.get_member_pids()};

	return pids;
end -- function


table_shuffle = function(table_ex)
    for i = table.getn(table_ex), 2, -1 do
        local random_element = math.random(i);
        table_ex[i], table_ex[random_element] = table_ex[random_element], table_ex[i];
    end -- for
   
    return table_ex;
end -- function

--[[
	Returns:
		The number of members inside the party.
]]
party_get_member_count = function()
	local pids = {party.get_member_pids()};

	return table.getn(pids);
end -- function

--[[
	Executes:
		The opening of a shop without needing to use 2 lines of code.
]]
open_shop = function(vnum)
	npc.open_shop(vnum);
	setskin(NOWINDOW);
end -- function

--[[
    @name   wartungsmodus
    @author Mijago
    @needs  mysql_query
    @descr
Versetzt alle Accounts (außer GM-Accounts) in einen "Wartungsmodus" und wieder zurück.
--]]
function wartungsmodus(v)
    if v == 1 or v == true then
        mysql_query("UPDATE account.account SET account.status = 'SHUTDOWN' WHERE status = 'OK' and account.login NOT IN (SELECT mAccount FROM common.gmlist);")
    else
        mysql_query("UPDATE account.account SET account.status = 'OK' WHERE status = 'SHUTDOWN' and account.login NOT IN (SELECT mAccount FROM common.gmlist);")
    end
end


--[[
    @name   create_folder
    @author Mijago 
    @descr
Erstellt Ordner, auch mit Unterordnern
--]]
create_folder = function(path)
    local pp = ''
    for i in string.gfind(path,'([%w_\-]*/)') do
        pp = pp..i
        os.execute('if [ ! -d '..pp..' ]; then mkdir '..pp..'; fi')
    end
end


--[[
    @name   INI-Parser
    @author Mijago
    @descr
Ein NEUER Parser für INI-Dateien.
--]]
ini = {
    open = function(path)
        return setmetatable({
            path = path or "",
        }, { __index = ini})
    end,
    write = function(self,section,key,value)
        if not section or not key then return false end
        local r,y = self:__get_text()
        if not y then return false end
        if string.find(r,"%["..section.."%]") then
            if string.find(r,"%["..section.."%][^%[]*"..key.."=") then
                r = string.gsub(r,"(%["..section.."%][^%[]*"..key.." *=)( *[^\n]+)",function(x)
                    return x..value
                end)
            else
                r = string.gsub(r,"(%["..section.."%][^%[]*)",function(x)
                    return x.."\n"..key.."="..value.."\n"
                end)
            end
        else
            r = r.."\n["..section.."]\n"..key.."="..value
        end
        -- überflüssige leerzeichen löschen
        r=string.gsub(string.gsub(string.gsub(r,"^(\n)",""),"(\n)$",""),"\n\n","\n")
        local d = io.open(self.path,"w")
        d:write(r)
        d:close()
    end,
    read = function(self,section,key,default_value)
        local t,y = self:__get_text()
        if not y then return false end
        local _,_,data = string.find(t,"%["..section.."%][^%[]*"..key.." *= *([^\n]+)")
        local output = (data or default_value)
        return tonumber(output) or output,true
    end,
    remove_key = function(self,section,key)
        local t,y = self:__get_text()
        if not y then return false end
        if string.find(t,"%["..section.."%][^%[]*"..key.." *=[^\n]+") then
            local t2=string.gsub(t,"(%["..section.."%][^%[]*)"..key.." *=[^\n]+",function(x)
                return x
            end)
            if t2 ~= t then
                local d= io.open(self.path,"w")
                d:write(t2)
                d:close()
            end
        end
        return true
    end,
    remove_section = function(self,section)
        local t,y = self:__get_text()
        if not y then return false end
        if string.find(t,"%["..section.."%][^%[]*") then
            t = string.gsub(t,"%["..section.."%][^%[]*","")
            local d = io.open(self.path,"w")
            d:write(t)
            d:close()
        end
        return true
    end,
    __get_text = function(self)
        local d = io.open(self.path,"r")
        if not d then return "",false end
        local t = d:read"*all"
        d:close()
        return t,true
    end,
}


--[[
    @name   Ini-Parser (alt)
    @author Mijago
    @needs  split
    @descr
-- OUTDATED --
Ein Parser für Ini-Dateien.
Besitzt eine Eigene Beschreibung der einzelnen Funktionen im Code.
--]]
do
    -- Funktionen:
    -- var = ini.new() 
    -- var = ini.open(path)
    -- var:write_str(sub,name,wert)
    -- var:write_int(sub,name,wert)
    -- var:write_bool(sub,name,boolean)
    -- var:clear()
    -- var:read_str(sub,name,norm)   -- Gibt einen String zurück. -|
    -- var:read_int(sub,name,norm)   -- Gibt eine Zahl zurück      -|  norm wird zurückgegeben, wenn sub[name] nicht existiert.
    -- var:read_bool(sub,name,norm)  -- Gibt true / False zurück  -|
    -- var:delete_key(sub,nm)
    -- var:delete_section(sub)
    local ini_f = {}
    ini = {}
    function ini_f:append(sub,nm,wert)
        if nm == '' or nm == nil then
            return
        end
        self:parse()
        if self.sub[sub] == nil then self.sub[sub] = {} end
        self.sub[sub][nm] = wert
        self:writeit()
    end
    function ini_f:write_str(sub,nm,wert)
        self:append(sub,nm,wert)
    end
    function ini_f:write_int(sub,nm,wert)
        self:append(sub,nm,wert)
    end
    function ini_f:write_bool(sub,nm,bool)
        if not type(bool) == "boolean" then
            return
        end
        local bin = 0
        if bool == true then bin = 1 end
        self:append(sub,nm,bin)
        return bin
    end
    function ini_f:clear()
        self.sub = {}
        self.path = ''
    end
    function ini_f:writeit()
        local out = ''
        table.foreach(self.sub,
            function(i,l)
                out = out..'['..i..']\n'
                table.foreach(l,
                    function(i2,l2)
                        out=out..i2..'='..l2..'\n'
                    end
                )
            end
        )
        local d = io.open(self.path,'w')
        d:write(out)
        d:close()
    end
    function ini_f:delete_key(sub,nm)
        if sub == '' or nm == '' or sub == nil or nm == nil then return end
        self:parse()
        self.sub[sub][nm] = nil
        self:writeit()
    end
    function ini_f:delete_section(sub)
        if sub == '' or sub == nil then return end
        self:parse()
        self.sub[sub]= nil
        self:writeit()
    end
    function ini_f:parse()
        self.sub = {}
        if self.path == '' or self.path == nil then return end
        local d,i = io.open(self.path,"r"),'non'
        if d == nil then d = io.open(self.path,"w") end
        for line in d:lines() do
            if string.sub(line,1,1) == "[" then
                i = string.sub(line,2,string.len(line)-1)
                self.sub[i] = {}
            else
                local inp = split(line,'=')
                self.sub[i][inp[1]] = inp[2]
            end
        end
        d:close()
    end
    function ini_f:read_str(sub,nm,norm)
        if sub == '' or nm == '' or sub == nil or nm == nil then return end
        self:parse()
        if self.sub[sub] == nil then return norm end
        if self.sub[sub][nm] == nil then return norm else return self.sub[sub][nm] end
    end
    function ini_f:read_int(sub,nm,norm)
        if sub == '' or nm == '' or sub == nil or nm == nil then return end
        self:parse()
        if self.sub[sub] == nil then return norm end
        if self.sub[sub][nm] == nil then return norm else return tonumber(self.sub[sub][nm]) end
    end
    function ini_f:read_bool(sub,nm,norm)   -- Norm wird zurückgegeben, wenn der Key nm nicht existiert
        if sub == '' or nm == '' or sub == nil or nm == nil then return end
        self:parse()
        if self.sub[sub] == nil then return norm end
        if self.sub[sub][nm] == nil then return norm end
        if self.sub[sub][nm] == "1" then return true else return false end
    end
    function ini_f:open(path)
        self.path = path
        self:parse()
    end
    function ini.new()
        local out = {}
        out.path = ''
        out.sub = {}
        setmetatable(out, { __index = ini_f })
        return out
    end
    function ini.open(path)
        local dat = ini.new()
        dat:clear()
        dat.path=path
        dat:open(path)
        return dat
    end
end


--[[
    @name   csay
    @author Mijago
    @descr
Wie die alten col-Befehle, sendet aber selbst.
Also kein say(col.red('bla'))
sondern
csay.red('bla') reicht völlig aus.
--]]
csay = setmetatable({__d = {
        ["aliceblue"] = {240, 248, 255},     ["antiquewhite"] = {250, 235, 215},    ["aqua"] = {0, 255, 255},                   ["aquamarine"] = {127, 255, 212},
        ["azure"] = {240, 255, 255},         ["beige"] = {245, 245, 220},           ["bisque"] = {255, 228, 196},               ["black"] = {0, 0, 0},
        ["blanchedalmond"] = {255, 235, 205},["blue"] = {0, 0, 255},                ["blueviolet"] = {138, 43, 226},            ["brown"] = {165, 42, 42},
        ["burlywood"] = {222, 184, 135},     ["cadetblue"] = {95, 158, 160},        ["chartreuse"] = {127, 255, 0},             ["chocolate"] = {210, 105, 30},
        ["coral"] = {255, 127, 80},          ["cornflowerblue"] = {100, 149, 237},  ["cornsilk"] = {255, 248, 220},             ["crimson"] = {220, 20, 60},
        ["cyan"] = {0, 255, 255},            ["darkblue"] = {0, 0, 139},            ["darkcyan"] = {0, 139, 139},               ["darkgoldenrod"] = {184, 134, 11},
        ["darkgray"] = {169, 169, 169},      ["darkgreen"] = {0, 100, 0},           ["darkkhaki"] = {189, 183, 107},            ["darkmagenta"] = {139, 0, 139},
        ["darkolivegreen"] = {85, 107, 47},  ["darkorange"] = {255, 140, 0},        ["darkorchid"] = {153, 50, 204},            ["darkred"] = {139, 0, 0},
        ["darksalmon"] = {233, 150, 122},    ["darkseagreen"] = {143, 188, 139},    ["darkslateblue"] = {72, 61, 139},          ["darkslategray"] = {47, 79, 79},
        ["darkturquoise"] = {0, 206, 209},   ["darkviolet"] = {148, 0, 211},        ["deeppink"] = {255, 20, 147},              ["deepskyblue"] = {0, 191, 255},
        ["dimgray"] = {105, 105, 105},       ["dodgerblue"] = {30, 144, 255},       ["firebrick"] = {178, 34, 34},              ["floralwhite"] = {255, 250, 240},
        ["forestgreen"] = {34, 139, 34},     ["fuchsia"] = {255, 0, 255},           ["gainsboro"] = {220, 220, 220},            ["ghostwhite"] = {248, 248, 255},
        ["gold"] = {255, 215, 0},            ["goldenrod"] = {218, 165, 32},        ["gray"] = {128, 128, 128},                 ["green"] = {0, 128, 0},
        ["greenyellow"] = {173, 255, 47},    ["honeydew"] = {240, 255, 240},        ["hotpink"] = {255, 105, 180},              ["indianred"] = {205, 92, 92},
        ["indigo"] = {75, 0, 130},           ["ivory"] = {255, 255, 240},           ["khaki"] = {240, 230, 140},                ["lavender"] = {230, 230, 250},
        ["lavenderblush"] = {255, 240, 245}, ["lawngreen"] = {124, 252, 0},         ["lemonchiffon"] = {255, 250, 205},         ["lightblue"] = {173, 216, 230},
        ["lightcoral"] = {240, 128, 128},    ["lightcyan"] = {224, 255, 255},       ["lightgoldenrodyellow"] = {250, 250, 210}, ["lightgray"] = {211, 211, 211},
        ["lightgreen"] = {144, 238, 144},    ["lightpink"] = {255, 182, 193},       ["lightsalmon"] = {255, 160, 122},          ["lightseagreen"] = {32, 178, 170},
        ["lightskyblue"] = {135, 206, 250},  ["lightslategray"] = {119, 136, 153},  ["lightsteelblue"] = {176, 196, 222},       ["lightyellow"] = {255, 255, 224},
        ["lime"] = {0, 255, 0},              ["limegreen"] = {50, 205, 50},         ["linen"] = {250, 240, 230},                ["magenta"] = {255, 0, 255},
        ["maroon"] = {128, 0, 0},            ["mediumaquamarine"] = {102, 205, 170},["mediumblue"] = {0, 0, 205},               ["mediumorchid"] = {186, 85, 211},
        ["mediumpurple"] = {147, 112, 219},  ["mediumseagreen"] = {60, 179, 113},   ["mediumslateblue"] = {123, 104, 238},      ["mediumspringgreen"] = {0, 250, 154},
        ["mediumturquoise"] = {72, 209, 204},["mediumvioletred"] = {199, 21, 133},  ["midnightblue"] = {25, 25, 112},           ["mintcream"] = {245, 255, 250},
        ["mistyrose"] = {255, 228, 225},     ["moccasin"] = {255, 228, 181},        ["navajowhite"] = {255, 222, 173},          ["navy"] = {0, 0, 128},
        ["oldlace"] = {253, 245, 230},       ["olive"] = {128, 128, 0},             ["olivedrab"] = {107, 142, 35},             ["orange"] = {255, 165, 0},
        ["orangered"] = {255, 69, 0},        ["orchid"] = {218, 112, 214},          ["palegoldenrod"] = {238, 232, 170},        ["palegreen"] = {152, 251, 152},
        ["paleturquoise"] = {175, 238, 238}, ["palevioletred"] = {219, 112, 147},   ["papayawhip"] = {255, 239, 213},           ["peachpuff"] = {255, 218, 185},
        ["peru"] = {205, 133, 63},           ["pink"] = {255, 192, 203},            ["plum"] = {221, 160, 221},                 ["powderblue"] = {176, 224, 230},
        ["purple"] = {128, 0, 128},          ["red"] = {255, 0, 0},                 ["rosybrown"] = {188, 143, 143},            ["royalblue"] = {65, 105, 225},
        ["saddlebrown"] = {139, 69, 19},     ["salmon"] = {250, 128, 114},          ["sandybrown"] = {244, 164, 96},            ["seagreen"] = {46, 139, 87},
        ["seashell"] = {255, 245, 238},      ["sienna"] = {160, 82, 45},            ["silver"] = {192, 192, 192},               ["skyblue"] = {135, 206, 235},
        ["slateblue"] = {106, 90, 205},      ["slategray"] = {112, 128, 144},       ["snow"] = {255, 250, 250},                 ["springgreen"] = {0, 255, 127},
        ["steelblue"] = {70, 130, 180},      ["tan"] = {210, 180, 140},             ["teal"] = {0, 128, 128},                   ["thistle"] = {216, 191, 216},
        ["tomato"] = {255, 99, 71},          ["turquoise"] = {64, 224, 208},        ["violet"] = {238, 130, 238},               ["wheat"] = {245, 222, 179},
        ["white"] = {255, 255, 255},         ["whitesmoke"] = {245, 245, 245},      ["yellow"] = {255, 255, 0},                 ["yellowgreen"] = {154, 205, 50}
    }},{
        __index = function(tab,idx)
            local color = tab.__d[idx] or {0,0,0}
            return function(x) say('[COLOR r;'..(color[1]/255)..'|g;'..(color[2]/255)..'|b;'..(color[3]/255)..']'..x..'[/COLOR]') end
        end
})


--[[
    @name   Farbcodes
    @author Mijago
    @descr
Farbcodes für Say
--]]
col = col or {}
col.list= {
{ 'lightcoral', 240,128,128 },{ 'rosybrown', 188,143,143 },
{ 'indianred', 205,92,92 },{ 'red', 255,0,0 },{ 'firebrick', 178,34,34 },{ 'brown', 165,42,42 },
{ 'darkred', 139,0,0 },{ 'maroon', 128,0,0 },{ 'mistyrose', 255,228,225 },{ 'salmon', 250,128,114 },
{ 'tomato', 255,99,71 },{ 'darksalmon', 233,150,122 },{ 'coral', 255,127,80 },{ 'orangered', 255,69,0 },
{ 'lightsalmon', 255,160,122 },{ 'sienna', 160,82,45 },{ 'seashell', 255,245,238 },{ 'chocolate', 210,105,30 },
{ 'saddlebrown', 139,69,19 },{ 'sandybrown', 244,164,96 },{ 'peachpuff', 255,218,185 },{ 'peru', 205,133,63 },
{ 'linen', 250,240,230 },{ 'bisque', 255,228,196 },{ 'darkorange', 255,140,0 },{ 'burlywood', 222,184,135 },
{ 'antiquewhite', 250,235,215 },{ 'tan', 210,180,140 },{ 'navajowhite', 255,222,173 },{ 'blanchedalmond', 255,235,205 },
{ 'papayawhip', 255,239,213 },{ 'moccasin', 255,228,181 },{ 'orange', 255,165,0 },{ 'wheat', 245,222,179 },
{ 'oldlace', 253,245,230 },{ 'floralwhite', 255,250,240 },{ 'darkgoldenrod', 184,134,11 },{ 'goldenrod', 218,165,32 },
{ 'cornsilk', 255,248,220 },{ 'gold', 255,215,0 },{ 'lemonchiffon', 255,250,205 },{ 'khaki', 240,230,140 },
{ 'palegoldenrod', 238,232,170 },{ 'darkkhaki', 189,183,107 },{ 'ivory', 255,255,240 },{ 'lightyellow', 255,255,224 },
{ 'beige', 245,245,220 },{ 'lightgoldenrodyellow', 250,250,210 },{ 'yellow', 255,255,0 },{ 'olive', 128,128,0 },
{ 'olivedrab', 107,142,35 },{ 'yellowgreen', 154,205,50 },{ 'darkolivegreen', 85,107,47 },{ 'greenyellow', 173,255,47 },
{ 'chartreuse', 127,255,0 },{ 'lawngreen', 124,252,0 },{ 'darkseagreen', 143,188,139 },{ 'honeydew', 240,255,240 },
{ 'palegreen', 152,251,152 },{ 'lightgreen', 144,238,144 },{ 'lime', 0,255,0 },{ 'limegreen', 50,205,50 },
{ 'forestgreen', 34,139,34 },{ 'green', 0,128,0 },{ 'darkgreen', 0,100,0 },{ 'seagreen', 46,139,87 },
{ 'mediumseagreen', 60,179,113 },{ 'springgreen', 0,255,127 },{ 'mintcream', 245,255,250 },{ 'mediumspringgreen', 0,250,154 },
{ 'mediumaquamarine', 102,205,170 },{ 'aquamarine', 127,255,212 },{ 'turquoise', 64,224,208 },{ 'lightseagreen', 32,178,170 },
{ 'mediumturquoise', 72,209,204 },{ 'azure', 240,255,255 },{ 'lightcyan', 224,255,255 },{ 'paleturquoise', 175,238,238 },
{ 'aqua', 0,255,255 },{ 'cyan', 0,255,255 },{ 'darkcyan', 0,139,139 },{ 'teal', 0,128,128 },
{ 'darkslategray', 47,79,79 },{ 'darkturquoise', 0,206,209 },{ 'cadetblue', 95,158,160 },{ 'powderblue', 176,224,230 },
{ 'lightblue', 173,216,230 },{ 'deepskyblue', 0,191,255 },{ 'skyblue', 135,206,235 },{ 'lightskyblue', 135,206,250 },
{ 'steelblue', 70,130,180 },{ 'aliceblue', 240,248,255 },{ 'dodgerblue', 30,144,255 },{ 'lightslategray', 119,136,153 },
{ 'slategray', 112,128,144 },{ 'lightsteelblue', 176,196,222 },{ 'cornflowerblue', 100,149,237 },{ 'royalblue', 65,105,225 },
{ 'ghostwhite', 248,248,255 },{ 'lavender', 230,230,250 },{ 'blue', 0,0,255 },{ 'mediumblue', 0,0,205 },
{ 'darkblue', 0,0,139 },{ 'midnightblue', 25,25,112 },{ 'navy', 0,0,128 },{ 'slateblue', 106,90,205 },
{ 'darkslateblue', 72,61,139 },{ 'mediumslateblue', 123,104,238 },{ 'mediumpurple', 147,112,219 },{ 'blueviolet', 138,43,226 },
{ 'indigo', 75,0,130 },{ 'darkorchid', 153,50,204 },{ 'darkviolet', 148,0,211 },{ 'mediumorchid', 186,85,211 },
{ 'thistle', 216,191,216 },{ 'plum', 221,160,221 },{ 'violet', 238,130,238 },{ 'fuchsia', 255,0,255 },
{ 'magenta', 255,0,255 },{ 'darkmagenta', 139,0,139 },{ 'purple', 128,0,128 },{ 'orchid', 218,112,214 },
{ 'mediumvioletred', 199,21,133 },{ 'deeppink', 255,20,147 },{ 'hotpink', 255,105,180 },{ 'lavenderblush', 255,240,245 },
{ 'palevioletred', 219,112,147 },{ 'crimson', 220,20,60 },{ 'pink', 255,192,203 },{ 'lightpink', 255,182,193 },
{ 'white', 255,255,255 },{ 'snow', 255,250,250 },{ 'whitesmoke', 245,245,245 },{ 'gainsboro', 220,220,220 },
{ 'lightgray', 211,211,211 },{ 'silver', 192,192,192 },{ 'darkgray', 169,169,169 },{ 'gray', 128,128,128 },
{ 'dimgray', 105,105,105 },{ 'black', 0,0,0 },{ 'aliceblue', 240,248,255 },{ 'antiquewhite', 250,235,215 },
{ 'aqua', 0,255,255 },{ 'aquamarine', 127,255,212 },{ 'azure', 240,255,255 },{ 'beige', 245,245,220 },
{ 'bisque', 255,228,196 },{ 'black', 0,0,0 },{ 'blanchedalmond', 255,235,205 },{ 'blue', 0,0,255 },
{ 'blueviolet', 138,43,226 },{ 'brown', 165,42,42 },{ 'burlywood', 222,184,135 },{ 'cadetblue', 95,158,160 },
{ 'chartreuse', 127,255,0 },{ 'chocolate', 210,105,30 },{ 'coral', 255,127,80 },{ 'cornflowerblue', 100,149,237 },
{ 'cornsilk', 255,248,220 },{ 'crimson', 220,20,60 },{ 'cyan', 0,255,255 },{ 'darkblue', 0,0,139 },
{ 'darkcyan', 0,139,139 },{ 'darkgoldenrod', 184,134,11 },{ 'darkgray', 169,169,169 },{ 'darkgreen', 0,100,0 },
{ 'darkkhaki', 189,183,107 },{ 'darkmagenta', 139,0,139 },{ 'darkolivegreen', 85,107,47 },{ 'darkorange', 255,140,0 },
{ 'darkorchid', 153,50,204 },{ 'darkred', 139,0,0 },{ 'darksalmon', 233,150,122 },{ 'darkseagreen', 143,188,139 },
{ 'darkslateblue', 72,61,139 },{ 'darkslategray', 47,79,79 },{ 'darkturquoise', 0,206,209 },{ 'darkviolet', 148,0,211 },
{ 'deeppink', 255,20,147 },{ 'deepskyblue', 0,191,255 },{ 'dimgray', 105,105,105 },{ 'dodgerblue', 30,144,255 },
{ 'firebrick', 178,34,34 },{ 'floralwhite', 255,250,240 },{ 'forestgreen', 34,139,34 },{ 'fuchsia', 255,0,255 },
{ 'gainsboro', 220,220,220 },{ 'ghostwhite', 248,248,255 },{ 'gold', 255,215,0 },{ 'goldenrod', 218,165,32 },
{ 'gray', 128,128,128 },{ 'green', 0,128,0 },{ 'greenyellow', 173,255,47 },{ 'honeydew', 240,255,240 },
{ 'hotpink', 255,105,180 },{ 'indianred', 205,92,92 },{ 'indigo', 75,0,130 },{ 'ivory', 255,255,240 },
{ 'khaki', 240,230,140 },{ 'lavender', 230,230,250 },{ 'lavenderblush', 255,240,245 },{ 'lawngreen', 124,252,0 },
{ 'lemonchiffon', 255,250,205 },{ 'lightblue', 173,216,230 },{ 'lightcoral', 240,128,128 },{ 'lightcyan', 224,255,255 },
{ 'lightgoldenrodyellow', 250,250,210 },{ 'lightgray', 211,211,211 },{ 'lightgreen', 144,238,144 },{ 'lightpink', 255,182,193 },
{ 'lightsalmon', 255,160,122 },{ 'lightseagreen', 32,178,170 },{ 'lightskyblue', 135,206,250 },{ 'lightslategray', 119,136,153 },
{ 'lightsteelblue', 176,196,222 },{ 'lightyellow', 255,255,224 },{ 'lime', 0,255,0 },{ 'limegreen', 50,205,50 },
{ 'linen', 250,240,230 },{ 'magenta', 255,0,255 },{ 'maroon', 128,0,0 },{ 'mediumaquamarine', 102,205,170 },
{ 'mediumblue', 0,0,205 },{ 'mediumorchid', 186,85,211 },{ 'mediumpurple', 147,112,219 },{ 'mediumseagreen', 60,179,113 },
{ 'mediumslateblue', 123,104,238 },{ 'mediumspringgreen', 0,250,154 },{ 'mediumturquoise', 72,209,204 },{ 'mediumvioletred', 199,21,133 },
{ 'midnightblue', 25,25,112 },{ 'mintcream', 245,255,250 },{ 'mistyrose', 255,228,225 },{ 'moccasin', 255,228,181 },
{ 'navajowhite', 255,222,173 },{ 'navy', 0,0,128 },{ 'oldlace', 253,245,230 },{ 'olive', 128,128,0 },
{ 'olivedrab', 107,142,35 },{ 'orange', 255,165,0 },{ 'orangered', 255,69,0 },{ 'orchid', 218,112,214 },
{ 'palegoldenrod', 238,232,170 },{ 'palegreen', 152,251,152 },{ 'paleturquoise', 175,238,238 },{ 'palevioletred', 219,112,147 },
{ 'papayawhip', 255,239,213 },{ 'peachpuff', 255,218,185 },{ 'peru', 205,133,63 },{ 'pink', 255,192,203 },
{ 'plum', 221,160,221 },{ 'powderblue', 176,224,230 },{ 'purple', 128,0,128 },{ 'red', 255,0,0 },
{ 'rosybrown', 188,143,143 },{ 'royalblue', 65,105,225 },{ 'saddlebrown', 139,69,19 },{ 'salmon', 250,128,114 },
{ 'sandybrown', 244,164,96 },{ 'seagreen', 46,139,87 },{ 'seashell', 255,245,238 },{ 'sienna', 160,82,45 },
{ 'silver', 192,192,192 },{ 'skyblue', 135,206,235 },{ 'slateblue', 106,90,205 },{ 'slategray', 112,128,144 },
{ 'snow', 255,250,250 },{ 'springgreen', 0,255,127 },{ 'steelblue', 70,130,180 },{ 'tan', 210,180,140 },
{ 'teal', 0,128,128 },{ 'thistle', 216,191,216 },{ 'tomato', 255,99,71 },{ 'turquoise', 64,224,208 },
{ 'violet', 238,130,238 },{ 'wheat', 245,222,179 },{ 'white', 255,255,255 },{ 'whitesmoke', 245,245,245 },
{ 'yellow', 255,255,0 },{ 'yellowgreen', 154,205,50 }}
table.foreachi(col.list,function(a,b)
    col[b[1]] = 	function(text) return "[COLOR r;"..(b[2]/255.0).."|g;"..(b[3]/255.0).."|b;"..(b[4]/255.0).."]"..text..'[/COLOR]' end
end)


--[[
    @name   Apache-Funktionen
    @author Mijago
    @descr
Funktionen, um Apache neu zu starten.
--]]
proc=proc or {}
proc.apache_start = function()
                os.execute('apachectl start')
            end
proc.apache_stop = function()
                os.execute('apachectl stop')
            end
proc.apache_restart = function()
                os.execute('apachectl restart')
            end
proc.apache_graceful = function()
                os.execute('apachectl graceful')
            end


--[[
    @name   TS3-Funktionen
    @author Mijago
    @descr
Funktionen zum Starten, Stoppen und Neustarten eines TS3 Servers.
--]]
proc=proc or {}
proc.ts3_start = function(path)
                os.execute('cd '..path..' && sh ts3server_startscript.sh start')
                end
proc.ts3_stop = function(path)
                os.execute('cd '..path..' && sh ts3server_startscript.sh stop')
                end
proc.ts3_restart = function(path)
                os.execute('cd '..path..' && sh ts3server_startscript.sh restart')
                end

function say_npc()
	say_title(""..mob_name(npc.get_race()).."")
end

function say_npc_name()
	say_title(""..mob_name(npc.get_race()).."")
end

function n_input()
    return math.abs(tonumber(input()) or 0)
end

function n_input_always()
	local n = nil
	 while n == nil do
		 n = tonumber (input())
		 if n != nil then
			 break
		 end
		 return n
	 end
end
function remove_item_from_pos(cell)	-- 1- 45*5
	item.select_cell(cell)
	local remove_item_from_pos_old_id = 0
	if remove_item_from_pos_old_id ~= item.get_id() then
		item.remove()
		return true
	else
		return false
	end
end

function item_on_group_range(tablee,count) -- item_on_group_range({189,188},1)
	if type(tablee) == "table" and bool_to_str(tonumber(count),"item_on_group_range count") == 'true' then
		for x = 1, table.getn(tablee), 1 do
			if pc.count_item(tablee[x]) >= count then
				return tablee[x]
			end
		end
		return 0
	else
		return 0
	end
end

function remove_item_on_group_range(tablee,count) -- item_on_group_range({189,188},1)
	if type(tablee) == "table" and bool_to_str(tonumber(count),"remove_item_on_group_range count") == 'true' then
		for x = 1, table.getn(tablee), 1 do
			if pc.count_item(tablee[x]) >= count then
				pc.remove_item(tablee[x],1)
				return true
			end
		end
		return false
	else
		return false
	end
end
function errorlog(what)
	local filelog = "LuaError_Log.txt"
	local quest_name = q.getcurrentquestname()
	LIB_writelog("QuestName: "..quest_name.." | Player: "..pc.get_name().."		->	"..what.." ",3,filelog)
	--errorchat("QUESTERROR:"..quest_name.."||| "..what.."")
	--dchatt("errorlog -> "..quest_name.." ->> "..what.."")
end

function errorchat(what)
	local quest_name = q.getcurrentquestname()
	luaerrorchat("ERROR:::"..quest_name.."||| "..what.."")
	--dchatt("errorlog -> "..quest_name.." ->> "..what.."")
end

function select_table2(tablee,tablemaxsite,StartIDX) --select_table2(table) ODER select_table2(table,MaxSelectsProSite)
	--<<< Settings >>> START
	local str_next = "N?hste Seite >"
	local str_back = "< Voherige Seite"
	local str_close = "Schlie?n"
	local MaxSite = 5
	--<<< Settings >>> END
	local newtable = {}
	local i = 1
	if StartIDX then		i = StartIDX	end
	if tablemaxsite then	MaxSite = tablemaxsite	end
	local old_start = i
	local ends = i+ (MaxSite -1)
	while i <= ends do
		if i <= table.getn(tablee) then	table.insert(newtable, tablee[i] )	end
		if i > table.getn(tablee) or i == table.getn(tablee) then		break	end
		i = i+1
	end
	--say("newtable: "..table.getn(newtable).." MaxSite:"..MaxSite.." table.getn(tablee):"..table.getn(tablee).." i:"..i.." ends:"..ends.."")
	-- if ( table.getn(newtable) >= MaxSite and i != table.getn(tablee) ) or
	   -- ( table.getn(newtable) >= MaxSite and table.getn(tablee) > MaxSite ) and 
	   -- table.getn(tablee) > ends then
	if table.getn(tablee) > MaxSite and table.getn(newtable) >= MaxSite and table.getn(tablee) > ends  then
		table.insert(newtable,str_next) --Next Button
	end
	if ends > MaxSite then
		table.insert(newtable,str_back) --Back Button
	end
	table.insert(newtable,str_close) --Close Button
	local t = select_table(newtable)
	local s = newtable[t]
	local outputnum = t+(old_start -1)
	if s == str_next then
		local nx = select_table2(tablee,MaxSite,old_start+MaxSite)
		return nx
	elseif s == str_back then
		local bx = select_table2(tablee,MaxSite,old_start-MaxSite)
		return bx
	elseif s == str_close then
		return 0 --Close
	else
		return outputnum
	end
end

function dchat(text)
	syschat("#"..q.getcurrentquestname().."# -> "..text)
end
function dchatt(text)
	if (is_test_server())	then
		syschat("Is TestServer -> #"..q.getcurrentquestname().."# -> "..text)
	end
end
function find_string(var,search)
	if string.find(var,search) then
		return true
	else
		return false
	end
end

function numtomoney(num) --LIB_GetNumberToBlock
    local num,out,x = tostring(num),'',0
    while string.len(num)-3 > 0 do
        out = string.gsub(num,'.-(%d%d%d)$','.%1')..out
        num = string.sub(num,0,string.len(num)-3)
    end
    return num..out
end

function numtolotto(num) --LIB_GetNumberToBlock
    local num,out,x = tostring(num),'',0
    while string.len(num)-2 > 0 do
        out = string.gsub(num,'.-(%d%d)$',' %1')..out
        num = string.sub(num,0,string.len(num)-2)
    end
    return num..out
end

function is_only_number(value)
	if string.find(value,'-') then
		return false
	elseif string.find(value,'+') then
		return false
	elseif string.find(value,'/') then
		return false
	elseif string.find(value,'*') then
		return false
    elseif type(tonumber(value)) == "number" then
        return true
    else
        return false
    end
end

function check_value_have(a,b)
	if bool_to_str(a) == "true" then
		return true
	else
		return false
	end
end

function str_replace(input, value, repl)
	return string.gsub(tostring(input), tostring(value), tostring(repl)) 
end

-- generate when a linebreak in the functions: d.notice,notice,notice_all
function notice_multiline( str , func ) --from Gameforge
    local p = 0
    local i = 0
    while true do
        i = string.find( str, "%[ENTER%]", i+1 )
        if i == nil then
            if string.len(str) > p then
                func( string.sub( str, p, string.len(str) ) )
            end
            break
        end
        func( string.sub( str, p, i-1 ) )
        p = i + 7
    end
end 

function GetText(name,lang,column)
	if lang == 0 then lang = 1 end
	local translates = {
		["test_language"] = {
			[1] = {"SayChatLang1","say_titleLang1","sayLang1"},--Lang1
			[2] = {"SayChatLang2","say_titleLang2","sayLang2"},--Lang2
			[3] = {"SayChatLang3","say_titleLang3","sayLang3"},--Lang3
			[4] = {"SayChatLang4","say_titleLang4","sayLang4"},--Lang4
		}
	}
	return tostring(translates[name][lang][column])
end


--[[
	Initializes:
		The 'Boss' class.
]]
Boss = {}

--[[
	Returns:
		The 'data' array.

	Structure:
		[vnum] = {["type"] = The boss' type (Normal = 1, Dungeon = 2, Event = 3), ["drop"] = {["vnum"] = The vnum of the drop (0 if none), ["quant"] = The quantity of the item to drop}, ["notice"] = true if the kill should be globally announced, else false}

]]
Boss.GetData = function()
	local data = {
		--** Normals
		[591]  = {["type"] = 1, ["drop"] = {["vnum"] = 0, ["quant"] = 0}, ["notice"] = false}, --** Bestial Captain
		[691]  = {["type"] = 1, ["drop"] = {["vnum"] = 0, ["quant"] = 0}, ["notice"] = false}, --** Chief Orc
		[792]  = {["type"] = 1, ["drop"] = {["vnum"] = 0, ["quant"] = 0}, ["notice"] = false}, --** Dark-Ghost Leader
		[1304] = {["type"] = 1, ["drop"] = {["vnum"] = 0, ["quant"] = 0}, ["notice"] = false}, --** Yellow Tiger Ghost
		[1901] = {["type"] = 1, ["drop"] = {["vnum"] = 0, ["quant"] = 0}, ["notice"] = false}, --** Nine Tails
		[2091] = {["type"] = 1, ["drop"] = {["vnum"] = 0, ["quant"] = 0}, ["notice"] = false}, --** Queen Spider
		[2191] = {["type"] = 1, ["drop"] = {["vnum"] = 0, ["quant"] = 0}, ["notice"] = false}, --** Giant Tortoise
		[2206] = {["type"] = 1, ["drop"] = {["vnum"] = 0, ["quant"] = 0}, ["notice"] = false}, --** Flame King
		[2306] = {["type"] = 1, ["drop"] = {["vnum"] = 0, ["quant"] = 0}, ["notice"] = false}, --** Giant Ghost Tree
		[5161] = {["type"] = 1, ["drop"] = {["vnum"] = 0, ["quant"] = 0}, ["notice"] = false}, --** Rock Ape
		[5162] = {["type"] = 1, ["drop"] = {["vnum"] = 0, ["quant"] = 0}, ["notice"] = false}, --** Walking Ape
		[5163] = {["type"] = 1, ["drop"] = {["vnum"] = 0, ["quant"] = 0}, ["notice"] = false}, --** Ape Lord

		--** Demon Tower
		[1091] = {["type"] = 2, ["drop"] = {["vnum"] = 0, ["quant"] = 0}, ["notice"] = false}, --** Demon King
		[1092] = {["type"] = 2, ["drop"] = {["vnum"] = 0, ["quant"] = 0}, ["notice"] = false}, --** Proud Demon King
		[1093] = {["type"] = 2, ["drop"] = {["vnum"] = 0, ["quant"] = 0}, ["notice"] = false}, --** Death Reaper
		
		--** Spiders Cave
		[2092] = {["type"] = 2, ["drop"] = {["vnum"] = 0, ["quant"] = 0}, ["notice"] = true}, --** Spider Baroness
		
		--** Grotto of Exile 1st Floor
		[1192] = {["type"] = 1, ["drop"] = {["vnum"] = 0, ["quant"] = 0}, ["notice"] = true}, --** Mighty Ice Witch

		--** Grotto of Exile 2nd Floor
		[2492] = {["type"] = 1, ["drop"] = {["vnum"] = 0, ["quant"] = 0}, ["notice"] = false}, --** General Yonghan
		[2495] = {["type"] = 1, ["drop"] = {["vnum"] = 0, ["quant"] = 0}, ["notice"] = false}, --** General Huashin
		
		--** Grotto of Exile's Dragon Lair
		[2493] = {["type"] = 2, ["drop"] = {["vnum"] = 0, ["quant"] = 0}, ["notice"] = true}, --** Beran-Setaou

		--** Devil's Catacomb
		[2591] = {["type"] = 2, ["drop"] = {["vnum"] = 0, ["quant"] = 0}, ["notice"] = false}, --** Tartaros
		[2597] = {["type"] = 2, ["drop"] = {["vnum"] = 0, ["quant"] = 0}, ["notice"] = false}, --** Charon
		[2598] = {["type"] = 2, ["drop"] = {["vnum"] = 0, ["quant"] = 0}, ["notice"] = true}, --** Azrael
		
		--** The Dark Dragons
		[3090] = {["type"] = 1, ["drop"] = {["vnum"] = 0, ["quant"] = 0}, ["notice"] = false}, --** Gnoll Lord
		[3091] = {["type"] = 1, ["drop"] = {["vnum"] = 0, ["quant"] = 0}, ["notice"] = false}, --** Supreme Gnoll Guard
		[3190] = {["type"] = 1, ["drop"] = {["vnum"] = 0, ["quant"] = 0}, ["notice"] = false}, --** Arges
		[3191] = {["type"] = 1, ["drop"] = {["vnum"] = 0, ["quant"] = 0}, ["notice"] = false}, --** Polyphemos
		[3290] = {["type"] = 1, ["drop"] = {["vnum"] = 0, ["quant"] = 0}, ["notice"] = false}, --** Rakshasa
		[3291] = {["type"] = 1, ["drop"] = {["vnum"] = 0, ["quant"] = 0}, ["notice"] = false}, --** Martyaxwar
		[3390] = {["type"] = 1, ["drop"] = {["vnum"] = 0, ["quant"] = 0}, ["notice"] = false}, --** Lemures Prince
		[3391] = {["type"] = 1, ["drop"] = {["vnum"] = 0, ["quant"] = 0}, ["notice"] = false}, --** Lemures Bodyguard
		[3490] = {["type"] = 1, ["drop"] = {["vnum"] = 0, ["quant"] = 0}, ["notice"] = false}, --** General Kappa
		[3491] = {["type"] = 1, ["drop"] = {["vnum"] = 0, ["quant"] = 0}, ["notice"] = false}, --** Triton
		[3590] = {["type"] = 1, ["drop"] = {["vnum"] = 0, ["quant"] = 0}, ["notice"] = false}, --** Bone Face
		[3591] = {["type"] = 1, ["drop"] = {["vnum"] = 0, ["quant"] = 0}, ["notice"] = false}, --** Red Chief
		[3595] = {["type"] = 1, ["drop"] = {["vnum"] = 0, ["quant"] = 0}, ["notice"] = false}, --** Brutal Bone Face
		[3596] = {["type"] = 1, ["drop"] = {["vnum"] = 0, ["quant"] = 0}, ["notice"] = false}, --** Brutal Red Chief
		[3690] = {["type"] = 1, ["drop"] = {["vnum"] = 0, ["quant"] = 0}, ["notice"] = true}, --** General Lobster
		[3691] = {["type"] = 1, ["drop"] = {["vnum"] = 0, ["quant"] = 0}, ["notice"] = false}, --** King Crab
		[3790] = {["type"] = 1, ["drop"] = {["vnum"] = 0, ["quant"] = 0}, ["notice"] = false}, --** Gargoyle
		[3791] = {["type"] = 1, ["drop"] = {["vnum"] = 0, ["quant"] = 0}, ["notice"] = false}, --** King Wubba
		[3890] = {["type"] = 1, ["drop"] = {["vnum"] = 0, ["quant"] = 0}, ["notice"] = false}, --** Captain Shruk
		[3891] = {["type"] = 1, ["drop"] = {["vnum"] = 0, ["quant"] = 0}, ["notice"] = false}, --** The Great Ogre

		--** Blazing Purgatory
		[6051] = {["type"] = 2, ["drop"] = {["vnum"] = 0, ["quant"] = 0}, ["notice"] = false}, --** Ignator
		[6091] = {["type"] = 2, ["drop"] = {["vnum"] = 0, ["quant"] = 0}, ["notice"] = false}, --** Razador

		--** Nemere's Watchtower
		[6151] = {["type"] = 2, ["drop"] = {["vnum"] = 0, ["quant"] = 0}, ["notice"] = false}, --** Szel
		[6191] = {["type"] = 2, ["drop"] = {["vnum"] = 0, ["quant"] = 0}, ["notice"] = false}, --** Nemere

		--** Event Bosses
		[692]  = {["type"] = 3, ["drop"] = {["vnum"] = 0, ["quant"] = 0}, ["notice"] = false}, --** Elite Chief Orc
		[693]  = {["type"] = 3, ["drop"] = {["vnum"] = 0, ["quant"] = 0}, ["notice"] = false}, --** Reborn Chief Orc
		[794]  = {["type"] = 3, ["drop"] = {["vnum"] = 0, ["quant"] = 0}, ["notice"] = false}, --** Elite Geist-Anführer
		[795]  = {["type"] = 3, ["drop"] = {["vnum"] = 0, ["quant"] = 0}, ["notice"] = false}, --** Elite Kämpfer
		[993]  = {["type"] = 3, ["drop"] = {["vnum"] = 0, ["quant"] = 0}, ["notice"] = false}, --** Riesiger Plagenträger
		[1094] = {["type"] = 3, ["drop"] = {["vnum"] = 0, ["quant"] = 0}, ["notice"] = false}, --** Gemeiner Dämonenkönig
		[1095] = {["type"] = 3, ["drop"] = {["vnum"] = 0, ["quant"] = 0}, ["notice"] = false}, --** Blue Death
		[1191] = {["type"] = 3, ["drop"] = {["vnum"] = 0, ["quant"] = 0}, ["notice"] = true}, --** Ice Witch
		[1334] = {["type"] = 3, ["drop"] = {["vnum"] = 0, ["quant"] = 0}, ["notice"] = false}, --** Gr. Yellow Tiger Spirit
		[1902] = {["type"] = 3, ["drop"] = {["vnum"] = 0, ["quant"] = 0}, ["notice"] = false}, --** Elite Nice Tails
		[1903] = {["type"] = 3, ["drop"] = {["vnum"] = 0, ["quant"] = 0}, ["notice"] = false}, --** Elite Nine Tails (Black)
		[2093] = {["type"] = 3, ["drop"] = {["vnum"] = 0, ["quant"] = 0}, ["notice"] = false}, --** Dark Spider Queen
		[2192] = {["type"] = 3, ["drop"] = {["vnum"] = 0, ["quant"] = 0}, ["notice"] = false}, --** Dark Giant Tortoise
		[2207] = {["type"] = 3, ["drop"] = {["vnum"] = 0, ["quant"] = 0}, ["notice"] = false}, --** Dark Flame King
		[2291] = {["type"] = 3, ["drop"] = {["vnum"] = 0, ["quant"] = 0}, ["notice"] = true}, --** Red Dragon
		[2307] = {["type"] = 3, ["drop"] = {["vnum"] = 0, ["quant"] = 0}, ["notice"] = false}  --** Phantom Tree Lord
	};

	return data;
end -- function

--[[
	Returns:
		true if the vnum of the monster inserted in the 'vnum' argument matches a boss' vnum
		else, false.
]]
Boss.IsBoss = function(vnum)
	return table_contains_keyword(Boss.GetData(), vnum);
end -- function

--[[
	Returns:
		The boss' type if the vnum inserted in the argument 'vnum' matches a boss' vnum,
		else, nil.
]]
Boss.GetType = function(vnum)
	if (Boss.IsBoss(vnum)) then
		return Boss.GetData()[vnum]["type"];
	end -- if
	
	return nil;
end -- function

function pet.is_equipped()
	--[[
		pc.get_wear(bCell);
  	Returns: 
		[1] lua_pushnumber: The equipped item vnum of the specific [cell].
		[1] lua_pushnil: nil
	--]]

	local WEAR_PET = 27 -- ../common/length.h / enum EWearPositions [0 ~ WEAR_MAX - 1] 
	return pc.get_wear(WEAR_PET) ~= nil; -- Returns: True or False
end

-- Strings my Mijago
function rm_nlc(s) return string.gsub(s, "%A", "") end -- alles au?r Buchstaben weg
function rm_ndc(s) return string.gsub(s, "%D", "") end -- alles au?r Zahlen weg
function rm_lc(s) return string.gsub(s, "%a", "") end -- alle Buchstaben weg
function rm_dc(s) return string.gsub(s, "%d", "") end -- alle Zahlen weg
function rm_ucc(s) return string.gsub(s, "%u", "") end -- alle gro?eschriebenen Buchstaben weg
function rm_lcc(s) return string.gsub(s, "%l", "") end -- alle kleingeschriebenen Buchstaben weg
function rm_nanc(s) return string.gsub(s, "%W", "") end -- alle nicht-alphanumerischen Zeichen weg		
		