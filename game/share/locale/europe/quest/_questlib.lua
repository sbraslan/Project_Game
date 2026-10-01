CONFIRM_NO = 0
CONFIRM_YES = 1
CONFIRM_OK = 1
CONFIRM_TIMEOUT = 2

MALE = 0
FEMALE = 1

--quest.create = function(f) return coroutine.create(f) end
--quest.process = function(co,args) return coroutine.resume(co, args) end
setstate = q.setstate
newstate = q.setstate

q.set_clock = function(name, value) q.set_clock_name(name) q.set_clock_value(value) end
q.set_counter = function(name, value) q.set_counter_name(name) q.set_counter_value(value) end
c_item_name = function(vnum) return ("[ITEM value;"..vnum.."]") end
c_mob_name = function(vnum) return ("[MOB value;"..vnum.."]") end

function locale_select(...)
	return q.yield('locale_select', arg)
end

-- d.set_folder = function (path) raw_script("[SET_PATH path;"..path.."]") end
-- d.set_folder = function (path) path.show_cinematic("[SET_PATH path;"..path.."]") end
-- party.run_cinematic = function (path) party.show_cinematic("[RUN_CINEMATIC value;"..path.."]") end

newline = "[ENTER]"
function color256(r, g, b) return "[COLOR r;"..(r/255.0).."|g;"..(g/255.0).."|b;"..(b/255.0).."]" end
function color(r,g,b) return "[COLOR r;"..r.."|g;"..g.."|b;"..b.."]" end
function delay(v) return "[DELAY value;"..v.."]" end
function setcolor(r,g,b) raw_script(color(r,g,b)) end
function setdelay(v) raw_script(delay(v)) end
function resetcolor(r,g,b) raw_script("[/COLOR]") end
function resetdelay(v) raw_script("[/DELAY]") end
function send_letter_blue_text(name) send_letter_ex(name, "blue,ex", "scroll_open_blue.tga") end

-- ENABLE_ATTR_6TH_7TH
function say_item_vnum_inline_showtooltip_by_cell(window_type, cell)
    raw_script("[INSERT_IMAGE_SHOWTOOLTIP_BY_CELL window_type;"..window_type.."|cell;"..cell.."]")
end

-- trim a string
function trim(s) return (string.gsub(s, "^%s*(.-)%s*$", "%1")) end

-- minimap에 동그라미 표시
function addmapsignal(x,y) raw_script("[ADDMAPSIGNAL x;"..x.."|y;"..y.."]") end


-- minimap 동그라미들 모두 클리어
function clearmapsignal() raw_script("[CLEARMAPSIGNAL]") end

-- 클라이언트에서 보여줄 대화창 배경 그림을 정한다.
function setbgimage(src) raw_script("[BGIMAGE src;") raw_script(src) raw_script("]") end

-- 대화창에 이미지를 보여준다.
function addimage(x,y,src) raw_script("[IMAGE x;"..x.."|y;"..y) raw_script("|src;") raw_script(src) raw_script("]") end

-- generate when a linebreak in the functions: d.notice,notice,notice_all
function notice_multiline( str , func )
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

function makequestbutton(name)
    raw_script("[QUESTBUTTON idx;")
    raw_script(""..q.getcurrentquestindex()) 
    raw_script("|name;")
    raw_script(name) raw_script("]")
end

function make_quest_button_ex(name, icon_type, icon_name)
    test_chat(icon_type)
    test_chat(icon_name)
    raw_script("[QUESTBUTTON idx;")
    raw_script(""..q.getcurrentquestindex()) 
    raw_script("|name;")
    raw_script(name)
    raw_script("|icon_type;")
    raw_script(icon_type)
    raw_script("|icon_name;")
    raw_script(icon_name)
    raw_script("]")
end

function make_quest_button(name) makequestbutton(name) end

function send_letter_ex(name, icon_type, icon_name) make_quest_button_ex(name, icon_type, icon_name) set_skin(NOWINDOW) q.set_title(name) q.start() end

function send_letter(name) makequestbutton(name) set_skin(NOWINDOW) q.set_title(name) q.start() end
function clear_letter() q.done() end
function say_title(name) say(color256(255, 230, 186)..name..color256(196, 196, 196)) end
function say_reward(name) say(color256(255, 200, 200)..name..color256(196, 196, 196)) end
function say_pc_name() say(pc.get_name()..":") end
function say_size(width, height) say("[WINDOW_SIZE width;"..width.."|height;"..height.."]") end
function setmapcenterposition(x,y)
    raw_script("[SETCMAPPOS x;")
    raw_script(x.."|y;")
    raw_script(y.."]")
end
function say_item(name, vnum, desc)
    say("[INSERT_IMAGE image_type;item|idx;"..vnum.."|title;"..name.."|desc;"..desc.."|index;".. 0 .."|total;".. 1 .."]")
end
function say_show_item(vnum)
    say("[INSERT_IMAGE image_type;item|idx;"..vnum.."|index;".. 0 .."|total;".. 1 .."]")
end
function say_item_vnum(vnum)
    say_item(item_name(vnum), vnum, "")
end
function say_item_vnum_inline(vnum,index,total)
    if index >= total then
        return
    end
    if total > 3 then
        return
    end
    raw_script("[INSERT_IMAGE image_type;item|idx;"..vnum.."|title;"..item_name(vnum).."|desc;".."".."|index;"..index.."|total;"..total.."]")
end
function say_show_item_by_cell(window_type, cell)
	say("[INSERT_ITEM_TOOLTIP_BY_CELL window_type;" .. window_type .. "|cell;" .. cell .. "]")
end

function pc_is_novice()
    if pc.get_skill_group()==0 then
        return true
    else
        return false
    end
end
function pc_get_exp_bonus(exp, text)
    say_reward(text)
    pc.give_exp2(exp)
    set_quest_state("levelup", "run")
end
function pc_get_village_map_index(index)
    return village_map[pc.get_empire()][index]
end
function pc_has_even_id()
    return math.mod(pc.get_player_id(),2) == 0
end

function pc_get_account_id()
    return math.mod(pc.get_account_id(), 2) !=0
end

village_map = {
    {1, 3},
    {21, 23},
    {41, 43},
}

function npc_is_same_empire()
    if pc.get_empire()==npc.empire then
        return true
    else
        return false
    end
end

function npc_get_skill_teacher_race(pc_empire, pc_job, sub_job)
    if 1==sub_job then
        if 0==pc_job then
            return WARRIOR1_NPC_LIST[pc_empire]
        elseif 1==pc_job then
            return ASSASSIN1_NPC_LIST[pc_empire]
        elseif 2==pc_job then
            return SURA1_NPC_LIST[pc_empire]
        elseif 3==pc_job then
            return SHAMAN1_NPC_LIST[pc_empire]
        end	
    elseif 2==sub_job then
        if 0==pc_job then
            return WARRIOR2_NPC_LIST[pc_empire]
        elseif 1==pc_job then
            return ASSASSIN2_NPC_LIST[pc_empire]
        elseif 2==pc_job then
            return SURA2_NPC_LIST[pc_empire]
        elseif 3==pc_job then
            return SHAMAN2_NPC_LIST[pc_empire]
        end	
    end

    return 0
end 


function pc_find_square_guard_vid()
    if pc.get_empire()==1 then 
        return find_npc_by_vnum(11000) 
    elseif pc.get_empire()==2 then
        return find_npc_by_vnum(11002)
    elseif pc.get_empire()==3 then
        return find_npc_by_vnum(11004)
    end
    return 0
end

function pc_find_skill_teacher_vid(sub_job)
    local vnum=npc_get_skill_teacher_race(pc.get_empire(), pc.get_job(), sub_job)
    return find_npc_by_vnum(vnum)
end

function pc_find_square_guard_vid()
    local pc_empire=pc.get_empire()
    if pc_empire==1 then
        return find_npc_by_vnum(11000)
    elseif pc_empire==2 then
        return find_npc_by_vnum(11002)
    elseif pc_empire==3 then
        return find_npc_by_vnum(11004)
    end
end

function npc_is_same_job()
    local pc_job=pc.get_job()
    local npc_vnum=npc.get_race()

    -- test_chat("pc.job:"..pc.get_job())
    -- test_chat("npc_race:"..npc.get_race())
    -- test_chat("pc.skill_group:"..pc.get_skill_group())
    if pc_job==0 then
        if table_is_in(WARRIOR1_NPC_LIST, npc_vnum) then return true end
        if table_is_in(WARRIOR2_NPC_LIST, npc_vnum) then return true end
    elseif pc_job==1 then
        if table_is_in(ASSASSIN1_NPC_LIST, npc_vnum) then return true end
        if table_is_in(ASSASSIN2_NPC_LIST, npc_vnum) then return true end
    elseif pc_job==2 then
        if table_is_in(SURA1_NPC_LIST, npc_vnum) then return true end
        if table_is_in(SURA2_NPC_LIST, npc_vnum) then return true end
    elseif pc_job==3 then
        if table_is_in(SHAMAN1_NPC_LIST, npc_vnum) then return true end
        if table_is_in(SHAMAN2_NPC_LIST, npc_vnum) then return true end
    end

    return false
end

function npc_get_job()
    local npc_vnum=npc.get_race()

    if table_is_in(WARRIOR1_NPC_LIST, npc_vnum) then return COND_WARRIOR_1 end
    if table_is_in(WARRIOR2_NPC_LIST, npc_vnum) then return COND_WARRIOR_2 end
    if table_is_in(ASSASSIN1_NPC_LIST, npc_vnum) then return COND_ASSASSIN_1 end
    if table_is_in(ASSASSIN2_NPC_LIST, npc_vnum) then return COND_ASSASSIN_2 end
    if table_is_in(SURA1_NPC_LIST, npc_vnum) then return COND_SURA_1 end
    if table_is_in(SURA2_NPC_LIST, npc_vnum) then return COND_SURA_2 end
    if table_is_in(SHAMAN1_NPC_LIST, npc_vnum) then return COND_SHAMAN_1 end
    if table_is_in(SHAMAN2_NPC_LIST, npc_vnum) then return COND_SHAMAN_2 end
    return 0

end

function time_min_to_sec(value)
    return 60*value
end

function time_hour_to_sec(value)
    return 3600*value
end

function next_time_set(value, test_value)
    local nextTime=get_time()+value
    if is_test_server() then
        nextTime=get_time()+test_value
    end
    pc.setqf("__NEXT_TIME__", nextTime)
end

function next_time_is_now(value)
    if get_time()>=pc.getqf("__NEXT_TIME__") then
        return true
    else
        return false
    end
end

function table_get_random_item(self)
    return self[number(1, table.getn(self))]
end

function table_is_in(self, test)
    for i = 1, table.getn(self) do
        if self[i]==test then
            return true
        end
    end
    return false
end


function giveup_quest_menu(title)
    local s=select("진행한다", "포기한다")
    if 2==s then 
    say(title.." 퀘스트를 정말로")
    say("포기하시겠습니까?")
    local s=select("네, 그렇습니다", "아닙니다")
    if 1==s then
        say(title.."퀘스트를 포기했습니다")
        restart_quest()
    end
    end
end

function restart_quest()
    set_state("start")
    q.done()
end

function complete_quest()
    set_state("__COMPLETE__")
    q.done()
end

function giveup_quest()
    set_state("__GIVEUP__")
    q.done()
end

function complete_quest_state(state_name)
    set_state(state_name)
    q.done()
end

function test_chat(log)
    if is_test_server() then
        chat(log)
    end
end

function bool_to_str(is)
    if is then
        return "true"
    else
        return "false"
    end
end

WARRIOR1_NPC_LIST 	= {20300, 20320, 20340, }
WARRIOR2_NPC_LIST 	= {20301, 20321, 20341, }
ASSASSIN1_NPC_LIST 	= {20302, 20322, 20342, }
ASSASSIN2_NPC_LIST 	= {20303, 20323, 20343, }
SURA1_NPC_LIST 		= {20304, 20324, 20344, }
SURA2_NPC_LIST 		= {20305, 20325, 20345, }
SHAMAN1_NPC_LIST 	= {20306, 20326, 20346, }
SHAMAN2_NPC_LIST 	= {20307, 20327, 20347, }

function skill_group_dialog(e, j, g) -- e = 제국, j = 직업, g = 그룹
    e = 1 -- XXX 메시지가 나라별로 있다가 하나로 통합되었음
    

    -- 다른 직업이거나 다른 제국일 경우
    if pc.job != j then
        say(locale.skill_group.dialog[e][pc.job][3])
    elseif pc.get_skill_group() == 0 then
        if pc.level < 5 then
            say(locale.skill_group.dialog[e][j][g][1])
            return
        end
        say(locale.skill_group.dialog[e][j][g][2])
        local answer = select(locale.yes, locale.no)

        if answer == 1 then
            --say(locale.skill_group.dialog[e][j][g][2])
            pc.set_skill_group(g)
        else
            --say(locale.skill_group.dialog[e][j][g][3])
        end
    --elseif pc.get_skill_group() == g then
        --say(locale.skill_group.dialog[e][j][g][4])
    --else
        --say(locale.skill_group.dialog[e][j][g][5])
    end
end

function horse.set_level2()
	horse.set_level(horse.get_level()+max_count)
end	

function show_horse_menu()
    if horse.is_mine() then			
        say(locale.horse_menu.menu)

        local s = 0
        if horse.is_dead() then
            s = select(locale.horse_menu.revive, locale.horse_menu.ride, locale.horse_menu.unsummon, locale.horse_menu.close)
        else
            s = select(locale.horse_menu.feed, locale.horse_menu.ride, locale.horse_menu.unsummon, locale.horse_menu.close)
        end

        if s==1 then
            if horse.is_dead() then
                horse.revive()
            else
                local food = horse.get_grade() + 50054 - 1
                if pc.countitem(food) > 0 then
                pc.removeitem(food, 1)
                horse.feed()
                else
                say(locale.need_item_prefix..item_name(food)..locale.need_item_postfix);
                end
            end
        elseif s==2 then
            horse.ride()
        elseif s==3 then
            horse.unsummon()
        elseif s==4 then
            -- do nothing
        end
    end
end

npc_index_table = {
    ['race'] = npc.getrace,
    ['empire'] = npc.get_empire,
}

pc_index_table = {
    ['weapon']		= pc.getweapon,
    ['level']		= pc.get_level,
    ['hp']		= pc.gethp,
    ['maxhp']		= pc.getmaxhp,
    ['sp']		= pc.getsp,
    ['maxsp']		= pc.getmaxsp,
    ['exp']		= pc.get_exp,
    ['nextexp']		= pc.get_next_exp,
    ['job']		= pc.get_job,
    ['money']		= pc.getmoney,
    ['gold'] 		= pc.getmoney,
    ['name'] 		= pc.getname,
    ['playtime'] 	= pc.getplaytime,
    ['leadership'] 	= pc.getleadership,
    ['empire'] 		= pc.getempire,
    ['skillgroup'] 	= pc.get_skill_group,
    ['x'] 		= pc.getx,
    ['y'] 		= pc.gety,
    ['local_x'] 	= pc.get_local_x,
    ['local_y'] 	= pc.get_local_y,
}

item_index_table = {
    ['vnum']		= item.get_vnum,
    ['name']		= item.get_name,
    ['size']		= item.get_size,
    ['count']		= item.get_count,
    ['type']		= item.get_type,
    ['sub_type']	= item.get_sub_type,
    ['refine_vnum']	= item.get_refine_vnum,
    ['level']		= item.get_level,
}

guild_war_bet_price_table = 
{
    10000,
    30000,
    50000,
    100000
}

function npc_index(t,i) 
    local npit = npc_index_table
    if npit[i] then
    return npit[i]()
    else
    return rawget(t,i)
    end
end

function pc_index(t,i) 
    local pit = pc_index_table
    if pit[i] then
    return pit[i]()
    else
    return rawget(t,i)
    end
end

function item_index(t, i)
    local iit = item_index_table
    if iit[i] then
    return iit[i]()
    else
    return rawget(t, i)
    end
end

setmetatable(pc,{__index=pc_index})
setmetatable(npc,{__index=npc_index})
setmetatable(item,{__index=item_index})

--coroutine을 이용한 선택항 처리
function select(...)
    return q.yield('select', arg)
end

function select_table(table)
    return q.yield('select', table)
end

-- coroutine을 이용한 다음 엔터 기다리기
function wait()
    q.yield('wait')
end

function input()
    return q.yield('input')
end

function confirm(vid, msg, timeout)
    return q.yield('confirm', vid, msg, timeout)
end

function select_item()
    setskin(NOWINDOW)
    return q.yield('select_item')
end

function select_item_ex()
    setskin(NOWINDOW)
    return q.yield('select_item_ex')
end

--전역 변수 접근과 관련된 계열
NOWINDOW = 0
NORMAL = 1
CINEMATIC = 2
SCROLL = 3

WARRIOR = 0
ASSASSIN = 1
SURA = 2
SHAMAN = 3

COND_WARRIOR_0 = 8
COND_WARRIOR_1 = 16
COND_WARRIOR_2 = 32
COND_WARRIOR = 56

COND_ASSASSIN_0 = 64
COND_ASSASSIN_1 = 128
COND_ASSASSIN_2 = 256
COND_ASSASSIN = 448

COND_SURA_0 = 512
COND_SURA_1 = 1024
COND_SURA_2 = 2048
COND_SURA = 3584

COND_SHAMAN_0 = 4096
COND_SHAMAN_1 = 8192
COND_SHAMAN_2 = 16384
COND_SHAMAN = 28672

PART_MAIN = 0
PART_HAIR = 3

GUILD_CREATE_ITEM_VNUM = 70101

QUEST_SCROLL_TYPE_KILL_MOB = 1
QUEST_SCROLL_TYPE_KILL_ANOTHER_EMPIRE = 2

apply = {
    ["MAX_HP"]		= 1,
    ["MAX_SP"]		= 2,
    ["CON"]			= 3,
    ["INT"]			= 4,
    ["STR"]			= 5,
    ["DEX"]			= 6,
    ["ATT_SPEED"]		= 7,
    ["MOV_SPEED"]		= 8,
    ["CAST_SPEED"]		= 9,
    ["HP_REGEN"]		= 10,
    ["SP_REGEN"]		= 11,
    ["POISON_PCT"]		= 12,
    ["STUN_PCT"]		= 13,
    ["SLOW_PCT"]		= 14,
    ["CRITICAL_PCT"]	= 15,
    ["PENETRATE_PCT"]	= 16,
    ["ATTBONUS_HUMAN"]	= 17,
    ["ATTBONUS_ANIMAL"]	= 18,
    ["ATTBONUS_ORC"]	= 19,
    ["ATTBONUS_MILGYO"]	= 20,
    ["ATTBONUS_UNDEAD"]	= 21,
    ["ATTBONUS_DEVIL"]	= 22,
    ["STEAL_HP"]		= 23,
    ["STEAL_SP"]		= 24,
    ["MANA_BURN_PCT"]	= 25,
    ["DAMAGE_SP_RECOVER"]	= 26,
    ["BLOCK"]		= 27,
    ["DODGE"]		= 28,
    ["RESIST_SWORD"]	= 29,
    ["RESIST_TWOHAND"]	= 30,
    ["RESIST_DAGGER"]	= 31,
    ["RESIST_BELL"]		= 32,
    ["RESIST_FAN"]		= 33,
    ["RESIST_BOW"]		= 34,
    ["RESIST_FIRE"]		= 35,
    ["RESIST_ELEC"]		= 36,
    ["RESIST_MAGIC"]	= 37,
    ["RESIST_WIND"]		= 38,
    ["REFLECT_MELEE"]	= 39,
    ["REFLECT_CURSE"]	= 40,
    ["POISON_REDUCE"]	= 41,
    ["KILL_SP_RECOVER"]	= 42,
    ["EXP_DOUBLE_BONUS"]	= 43,
    ["GOLD_DOUBLE_BONUS"]	= 44,
    ["ITEM_DROP_BONUS"]	= 45,
    ["POTION_BONUS"]	= 46,
    ["KILL_HP_RECOVER"]	= 47,
    ["IMMUNE_STUN"]		= 48,
    ["IMMUNE_SLOW"]		= 49,
    ["IMMUNE_FALL"]		= 50,
    ["SKILL"]		= 51,
    ["BOW_DISTANCE"]	= 52,
    ["ATT_GRADE_BONUS"]	= 53,
    ["DEF_GRADE_BONUS"]	= 54,
    ["MAGIC_ATT_GRADE"]	= 55,
    ["MAGIC_DEF_GRADE"]	= 56,
    ["CURSE_PCT"]		= 57,
    ["MAX_STAMINA"]		= 58,
    ["ATTBONUS_WARRIOR"]	= 59,
    ["ATTBONUS_ASSASSIN"]	= 60,
    ["ATTBONUS_SURA"]	= 61,
    ["ATTBONUS_SHAMAN"]	= 62,
    ["ATTBONUS_MONSTER"]	= 63,
    ["MALL_EXPBONUS"]   = 66,
    ["MAX_HP_PCT"]  = 69,
    ["MAX_SP_PCT"]  = 70,

    ["MALL_DEFBONUS"] = 65,

    ["NORMAL_HIT_DEFEND_BONUS"] = 74,
}

-- 레벨업 퀘스트 -_-
special = {}

special.fortune_telling = 
{
--  { prob	크리	item	money	remove money
    { 1,	0,	20,	20,	0	}, -- 10
    { 499,	0,	10,	10,	0	}, -- 5
    { 2500,	0,	5,	5,	0	}, -- 1
    { 5000,	0,	0,	0,	0	},
    { 1500,	0,	-5,	-5,	20000	},
    { 499,	0,	-10,	-10,	20000	},
    { 1,	0,	-20,	-20,	20000	},
}

special.questscroll_reward =
{
    {1,	1500,	3000,	30027,	0,	0    },
    {2,	1500,	3000,	30028,	0,	0    },
    {3,	1000,	2000,	30034,	30018,	0    },
    {4,	1000,	2000,	30034,	30011,	0    },
    {5,	1000,	2000,	30011,	30034,	0    },
    {6,	1000,	2000,	27400,	0,	0    },
    {7,	2000,	4000,	30023,	30003,	0    },
    {8,	2000,	4000,	30005,	30033,	0    },
    {9,	2000,	8000,	30033,	30005,	0    },
    {10,	4000,	8000,	30021,	30033,	30045},
    {11,	4000,	8000,	30045,	30022,	30046},
    {12,	5000,	12000,	30047,	30045,	30055},
    {13,	5000,	12000,	30051,	30017,	30058},
    {14,	5000,	12000,	30051,	30007,	30041},
    {15,	5000,	15000,	30091,	30017,	30018},
    {16,	3500,	6500,	30021,	30033,	0    },
    {17,	4000,	9000,	30051,	30033,	0    },
    {18,	4500,	10000,	30056,	30057,	30058},
    {19,	4500,	10000,	30059,	30058,	30041},
    {20,	5000,	15000,	0,	0,	0    },
}

special.active_skill_list = {
    {
        { 1, 2, 3, 4, 5},
        { 16, 17, 18, 19, 20},
    },
    {
        {31, 32, 33, 34, 35},
        {46, 47, 48, 49, 50},
    },
    {
        {61, 62, 63, 64, 65, 66},
        {76, 77, 78, 79, 80, 81},
    },
    {
        {91, 92, 93, 94, 95, 96},
        {106, 107, 108, 109, 110, 111},
    },
}

special.skill_reset_cost = {
    2000,
    2000,
    2000,
    2000,
    2000,
    2000,
    4000,
    6000,
    8000,
    10000,
    14000,
    18000,
    22000,
    28000,
    34000,
    41000,
    50000,
    59000,
    70000,
    90000,
    101000,
    109000,
    114000,
    120000,
    131000,
    141000,
    157000,
    176000,
    188000,
    200000,
    225000,
    270000,
    314000,
    348000,
    393000,
    427000,
    470000,
    504000,
    554000,
    600000,
    758000,
    936000,
    1103000,
    1276000,
    1407000,
    1568000,
    1704000,
    1860000,
    2080000,
    2300000,
    2700000,
    3100000,
    3500000,
    3900000,
    4300000,
    4800000,
    5300000,
    5800000,
    6400000,
    7000000,
    8000000,
    9000000,
    10000000,
    11000000,
    12000000,
    13000000,
    14000000,
    15000000,
    16000000,
    17000000,
}

special.levelup_img = 
{
    [171] = "dog.tga",
    [172] = "wolf.tga",
    [173] = "wolf.tga",
    [174] = "wolf.tga",
    [175] = "wolf.tga",
    [175] = "wolf.tga",
    [176] = "wolf.tga",
    [177] = "wolf.tga",
    [178] = "wild_boar.tga",
    [179] = "wild_boar.tga",
    [180] = "bear.tga",
    [181] = "bear.tga",
    [182] = "bear.tga",
    [183] = "bear.tga",
    [184] = "tiger.tga",
    [185] = "tiger.tga",

    [351] = "bak_inf.tga",
    [352] = "bak_gung.tga",
    [353] = "bak_gen1.tga",
    [354] = "bak_gen2.tga",
    
    [402] = "402.tga",

    [451] = "huk_inf.tga",
    [452] = "huk_dol.tga",
    [453] = "huk_gen1.tga",
    [454] = "huk_gen2.tga",
    [456] = "456.tga",

    [551] = "o_inf.tga",
    [552] = "o_jol.tga",
    [553] = "o_gung.tga",
    [554] = "o_jang.tga",

    [651] = "ung_inf.tga",
    [652] = "ung_chuk.tga",
    [653] = "ung_tu.tga",

    [751] = "mil_chu.tga",
    [752] = "mil_na.tga",
    [753] = "mil_na.tga",
    [754] = "mil_na.tga",
    [755] = "mil_jip.tga",
    [756] = "756.tga",
    [757] = "757.tga",

    [771] = "mil_chu.tga",
    [772] = "mil_na.tga",
    [773] = "mil_na.tga",
    [774] = "mil_na.tga",
    [775] = "mil_jip.tga",
    [776] = "776.tga",
    [777] = "777.tga",

    [931] = "sigwi.tga",
    [932] = "932.tga",
    [933] = "gwoijil.tga",
    [934] = "934.tga",
    [935] = "935.tga",
    [936] = "936.tga",
    [937] = "937.tga",
    
    [1001] = "1001.tga",
    [1002] = "1002.tga",
    [1003] = "1003.tga",
    [1004] = "1004.tga",
    
    [1061] = "1061.tga",
    [1063] = "1063.tga",
    [1064] = "1064.tga",
    [1065] = "1065.tga",
    [1066] = "1066.tga",
    [1068] = "1068.tga",
    [1069] = "1069.tga",

    [1070] = "1070.tga",
    [1071] = "1071.tga",

    [1101] = "1101.tga",
    [1102] = "1102.tga",
    [1104] = "1104.tga",
    [1105] = "1105.tga",
    [1106] = "1106.tga",
    [1107] = "1107.tga",

    [1131] = "1131.tga",
    [1132] = "1132.tga",
    [1133] = "1133.tga",
    [1135] = "1135.tga",
    [1136] = "1136.tga",
    [1137] = "1137.tga",

    [1301] = "1301.tga",
    [1303] = "1303.tga",
    [1305] = "1305.tga",

    [2001] = "spider.tga",
    [2002] = "spider.tga",
    [2003] = "spider.tga",
    [2004] = "spider.tga",
    [2005] = "spider.tga",

    [2051] = "spider.tga",
    [2052] = "spider.tga",
    [2053] = "spider.tga",
    [2054] = "spider.tga",
    [2055] = "spider.tga",

    [2031] = "2031.tga",
    [2032] = "2032.tga",
    [2033] = "2033.tga",
    [2034] = "2034.tga",

    [2061] = "2061.tga",
    [2062] = "2062.tga",
    [2063] = "2063.tga",

    [2102] = "2102.tga",
    [2103] = "2103.tga",
    [2106] = "2106.tga",
    
    [2131] = "2131.tga",
    [2158] = "2158.tga",
    
    [2201] = "2201.tga",
    [2202] = "2202.tga",
    [2204] = "2204.tga",
    [2205] = "2205.tga",
    
    [2301] = "2301.tga",
    [2302] = "2302.tga",
    [2303] = "2303.tga",
    [2304] = "2304.tga",
    [2305] = "2305.tga",
    
    [2311] = "2311.tga",
    [2312] = "2312.tga",
    [2313] = "2313.tga",
    [2314] = "2314.tga",
    [2315] = "2315.tga",

    [5123] = "5123.tga",
    [5124] = "5124.tga",
    [5125] = "5125.tga",
    [5126] = "5126.tga",
    

}

special.levelup_quest = {
    -- monster kill  monster   kill
-- 1Vnum   1Count	2Vnum	2Count  exp in %
{	0	,	0	,	0	,	0	,	0		}	,	--	lev	1
{	171	,	5	,	172	,	5	,	75		}	,	--	lev	2
{	171	,	5	,	172	,	5	,	75		}	,	--	lev	3
{	172	,	5	,	173	,	5	,	75		}	,	--	lev	4
{	173	,	5	,	174	,	5	,	75		}	,	--	lev	5
{	174	,	5	,	178	,	5	,	75		}	,	--	lev	6
{	178	,	6	,	175	,	6	,	75		}	,	--	lev	7
{	178	,	6	,	175	,	6	,	75		}	,	--	lev	8
{	175	,	6	,	179	,	6	,	75		}	,	--	lev	9
{	175	,	6	,	179	,	6	,	75		}	,	--	lev	10
{	179	,	6	,	180	,	6	,	75		}	,	--	lev	11
{	180	,	7	,	176	,	7	,	75		}	,	--	lev	12
{	176	,	7	,	181	,	7	,	75		}	,	--	lev	13
{	181	,	7	,	177	,	7	,	75		}	,	--	lev	14
{	181	,	7	,	177	,	7	,	50		}	,	--	lev	15
{	177	,	7	,	184	,	7	,	50		}	,	--	lev	16
{	177	,	8	,	184	,	8	,	50		}	,	--	lev	17
{	184	,	8	,	182	,	8	,	50		}	,	--	lev	18
{	182	,	8	,	183	,	8	,	50		}	,	--	lev	19
{	183	,	8	,	352	,	8	,	50		}	,	--	lev	20
{	352	,	8	,	185	,	8	,	"20-50"	}	,	--	lev	21
{	185	,	9	,	354	,	9	,	"20-50"	}	,	--	lev	22
{	354	,	9	,	451	,	9	,	"20-50"	}	,	--	lev	23
{	451	,	9	,	402	,	9	,	"20-50"	}	,	--	lev	24
{	551	,	9	,	454	,	9	,	"20-50"	}	,	--	lev	25
{	552	,	9	,	456	,	9	,	"20-50"	}	,	--	lev	26
{	456	,	10	,	554	,	10	,	"20-50"	}	,	--	lev	27
{	651	,	10	,	554	,	10	,	"20-50"	}	,	--	lev	28
{	651	,	10	,	652	,	10	,	"20-50"	}	,	--	lev	29
{	652	,	10	,	2102,	10	,	"20-50"	}	,	--	lev	30
{	652	,	10	,	2102,	10	,	"20-50"	}	,	--	lev	31
{	653	,	11	,	2051,	11	,	"20-50"	}	,	--	lev	32
{	751	,	11	,	2103,	11	,	"20-50"	}	,	--	lev	33
{	751	,	11	,	2103,	11	,	"20-50"	}	,	--	lev	34
{	752	,	11	,	2052,	11	,	"20-50"	}	,	--	lev	35
{	754	,	11	,	2106,	11	,	"20-35"	}	,	--	lev	36
{	773	,	12	,	2003,	12	,	"20-35"	}	,	--	lev	37
{	774	,	12	,	2004,	12	,	"20-35"	}	,	--	lev	38
{	756	,	12	,	2005,	12	,	"20-35"	}	,	--	lev	39
{	757	,	12	,	2158,	12	,	"20-35"	}	,	--	lev	40
{	931	,	12	,	5123,	12	,	"20-35"	}	,	--	lev	41
{	932	,	13	,	5123,	13	,	"20-35"	}	,	--	lev	42
{	932	,	13	,	2031,	13	,	"20-35"	}	,	--	lev	43
{	933	,	13	,	2031,	13	,	"20-35"	}	,	--	lev	44
{	771	,	13	,	2032,	13	,	"20-35"	}	,	--	lev	45
{	772	,	13	,	5124,	13	,	"20-35"	}	,	--	lev	46
{	933	,	14	,	5125,	14	,	"20-35"	}	,	--	lev	47
{	934	,	14	,	5125,	14	,	"20-35"	}	,	--	lev	48
{	773	,	14	,	2033,	14	,	"20-35"	}	,	--	lev	49
{	774	,	14	,	5126,	14	,	"20-35"	}	,	--	lev	50
{	775	,	14	,	5126,	14	,	"20-30"	}	,	--	lev	51
{	934	,	15	,	2034,	15	,	"20-30"	}	,	--	lev	52
{	934	,	15	,	2034,	15	,	"20-30"	}	,	--	lev	53
{	776	,	15	,	1001,	15	,	"20-30"	}	,	--	lev	54
{	777	,	15	,	1301,	15	,	"20-30"	}	,	--	lev	55
{	935	,	15	,	1002,	15	,	"20-30"	}	,	--	lev	56
{	935	,	16	,	1002,	16	,	"20-30"	}	,	--	lev	57
{	936	,	16	,	1303,	16	,	"20-30"	}	,	--	lev	58
{	936	,	16	,	1303,	16	,	"20-30"	}	,	--	lev	59
{	937	,	16	,	1003,	16	,	"20-30"	}	,	--	lev	60
{	1004,	16	,	2061,	16	,	"20-30"	}	,	--	lev	61
{	1305,	17	,	2131,	17	,	"20-30"	}	,	--	lev	62
{	1305,	17	,	1101,	17	,	"20-30"	}	,	--	lev	63
{	2062,	17	,	1102,	17	,	"20-30"	}	,	--	lev	64
{	1104,	17	,	2063,	17	,	"20-30"	}	,	--	lev	65
{	2301,	17	,	1105,	17	,	"20-30"	}	,	--	lev	66
{	2301,	18	,	1105,	18	,	"20-30"	}	,	--	lev	67
{	1106,	18	,	1061,	18	,	"20-30"	}	,	--	lev	68
{	1107,	18	,	1061,	18	,	"15-20"	}	,	--	lev	69
{	2302,	18	,	2201,	18	,	"15-20"	}	,	--	lev	70
{	2303,	18	,	2202,	18	,	"15-20"	}	,	--	lev	71
{	2303,	19	,	2202,	19	,	"15-20"	}	,	--	lev	72
{	2304,	19	,	1063,	19	,	"15-20"	}	,	--	lev	73
{	2305,	19	,	1063,	19	,	"15-20"	}	,	--	lev	74
{	1064,	19	,	2204,	19	,	"15-20"	}	,	--	lev	75
{	2205,	19	,	1065,	19	,	"15-20"	}	,	--	lev	76
{	2311,	20	,	1068,	20	,	"15-20"	}	,	--	lev	77
{	1070,	20	,	1066,	20	,	"15-20"	}	,	--	lev	78
{	1070,	20	,	1069,	20	,	"15-20"	}	,	--	lev	79
{	1071,	20	,	2312,	20	,	"10-15"	}	,	--	lev	80
{	1071,	20	,	2312,	20	,	"10-15"	}	,	--	lev	81
{	2313,	21	,	2314,	21	,	"10-15"	}	,	--	lev	82
{	2313,	21	,	2314,	21	,	"10-15"	}	,	--	lev	83
{	1131,	21	,	2315,	21	,	"10-15" }	,	--	lev	84
{	1131,	21	,	2315,	21	,	"10-15" }	,	--	lev	85
{	1132,	21	,	1135,	21	,	"10-15" }	,	--	lev	86
{	1132,	22	,	1135,	22	,	"10-15" }	,	--	lev	87
{	1133,	22	,	1136,	22	,	"10-15" }	,	--	lev	88
{	1133,	22	,	1137,	22	,	"10-15" }	,	--	lev	89
{	1132,	22	,	1137,	22	,	"10-15" }	,	--	lev	90

}

special.levelup_reward1 = 
{
    -- warrior assassin  sura  shaman lycan
    {     0,        0,      0,      0 },
    { 72725,    72725,  72725,  72725,  72725 }, -- 갑옷
    { 72729,    72729,  72729,  72729,  72729 }, -- 투구
    { 71081,    71081,  71081,  71081,  71081 }  -- 방패
}

-- levelup_reward1 테이블 크기보다 레벨이 높아지면 아래
-- 테이블을 이용하여 아이템을 준다.
special.levelup_reward3 = {
    -- pct   item #  item count
    {   33,  71151,  15 }, -- 25%
    {   67,  71152,  15 }, -- 25%
	{   75,  70024,   5 }, -- 25%
    {  100,  25040,   3 }, -- 25%
}

special.levelup_reward_gold21 = 
{
    { 100000,	20 },
    { 200000,	50 },
    { 400000,	25 },
    { 800000,	3 },
    { 1000000,	2 },
}
special.levelup_reward_gold31 =
{
    { 200000,	20 },
    { 400000,	40 },
    { 600000,	25 },
    { 800000,	10 },
    { 1000000,	5 },
}
special.levelup_reward_gold41 =
{
    { 400000,	20 },
    { 600000,	40 },
    { 800000,	25 },
    { 1000000,	10 },
    { 1500000,	5 },
}
special.levelup_reward_gold51 =
{
    { 600000,	20 },
    { 800000,	40 },
    { 1000000,	25 },
    { 1500000,	10 },
    { 2000000,	5 },
}

special.levelup_reward_exp21 =
{
    { 20,	9 },
    { 30,	14 },
    { 40,	39 },
    { 60,	24 },
    { 80,	9 },
    { 100,	4 },
}

special.levelup_reward_exp31 = 
{
    { 20,	10 },
    { 25,	15 },
    { 30,	40 },
    { 35,	25 },
    { 40,	8 },
    { 45,	5 },
    { 50,	2 },
}
special.levelup_reward_exp41 = 
{
    { 20,	10 },
    { 25,	15 },
    { 30,	40 },
    { 35,	25 },
    { 40,	8 },
    { 45,	5 },
    { 50,	2 },
}
special.levelup_reward_exp51 = 
{
    { 10,	10 },
    { 15,	15 },
    { 20,	40 },
    { 25,	25 },
    { 30,	8 },
    { 35,	5 },
    { 40,	2 },
}
special.levelup_reward_exp84 =
{
    { 10,	9 },
    { 12,	14 },
    { 14,	39 },
    { 16,	24 },
    { 18,	9 },
    { 20,	4 },
}

special.levelup_reward_item_21 =
{
    -- no couple ring
    { { 72723, 3 }, { 72727, 3 }, { 50300, 10 } }, -- lev 21
    { 15087, 15107, 15127, 15147 }, -- lev 22
    { 16087, 16107, 16127, 16147 }, -- lev 23
    { 17087, 17107, 17127, 17147 }, -- lev 24
    { { 72723, 3 }, { 72727, 3 }, { 71107, 1 } }, -- lev 25
    { { 72724, 3 }, { 72728, 3 }, { 90525, 1 } }, -- over lev 25

    -- with couple ring
    -- { { 27002, 10 }, { 27005, 10 }, { 27114, 10 }, { 70301, 1 } }, -- lev 21
    -- { 15080, 15100, 15120, 15140, 70301 }, -- lev 22
    -- { 16080, 16100, 16120, 16140, 70301 }, -- lev 23
    -- { 17080, 17100, 17120, 17140, 70301 }, -- lev 24
    -- { { 27002, 10 }, { 27005, 10 }, { 27114, 10 }, { 70301, 1 } }, -- lev 25
    -- { { 27003, 20 }, { 27006, 20 }, { 27114, 10 } }, -- over lev 25
}

special.warp_to_pos = {
-- 승룡곡
    {
    { 402100, 673900 }, 
    { 270400, 739900 },
    { 321300, 808000 },
    },
--도염화지
    {
--A 5994 7563 
--B 5978 6222
--C 7307 6898
    { 599400, 756300 },
    { 597800, 622200 },
    { 730700, 689800 },
    },
--영비사막
    {
--A 2178 6272
    { 217800, 627200 },
--B 2219 5027
    { 221900, 502700 },
--C 3440 5025
    { 344000, 502500 },
    },
--서한산
    {
--A 4342 2906
    { 434200, 290600 },
--B 3752 1749
    { 375200, 174900 },
--C 4918 1736
    { 491800, 173600 },
    },
}

special.devil_tower = 
{
    --{ 123, 608 },
    { 2048+126, 6656+384 },
    { 2048+134, 6656+147 },
    { 2048+369, 6656+629 },
    { 2048+369, 6656+401 },
    { 2048+374, 6656+167 },
    { 2048+579, 6656+616 },
    { 2048+578, 6656+392 },
    { 2048+575, 6656+148 },
}

special.lvq_map = {
    { -- "A1" 1
        {},
    
        { { 440, 565 }, { 460, 771 }, { 668, 800 },},
        { { 440, 565 }, { 460, 771 }, { 668, 800 },},
        { { 440, 565 }, { 460, 771 }, { 668, 800 },},
        {{496, 401}, {494, 951}, {542, 1079}, {748, 9741},},
        {{496, 401}, {494, 951}, {542, 1079}, {748, 9741},},
        {{496, 401}, {494, 951}, {542, 1079}, {748, 9741},},
        {{496, 401}, {494, 951}, {542, 1079}, {748, 9741},},
        {{496, 401}, {494, 951}, {542, 1079}, {748, 9741},},
        {{496, 401}, {494, 951}, {542, 1079}, {748, 9741},},
        {{496, 401}, {494, 951}, {542, 1079}, {748, 9741},},
        
        {{496, 401}, {494, 951}, {542, 1079}, {748, 9741},},
        {{853,557}, {845,780}, {910,956},},
        {{853,557}, {845,780}, {910,956},},
        {{340, 179}, {692, 112}, {787, 256}, {898, 296},},
        {{340, 179}, {692, 112}, {787, 256}, {898, 296},},
        {{340, 179}, {692, 112}, {787, 256}, {898, 296},},
        {{340, 179}, {692, 112}, {787, 256}, {898, 296},},
        {{340, 179}, {692, 112}, {787, 256}, {898, 296},},
        {{340, 179}, {692, 112}, {787, 256}, {898, 296},},
        {{340, 179}, {692, 112}, {787, 256}, {898, 296},},
        
        {{224,395}, {137,894}, {206,830}, {266,1067},},
        {{224,395}, {137,894}, {206,830}, {266,1067},},
        {{224,395}, {137,894}, {206,830}, {266,1067},},
        {{405,74}},
        {{405,74}},
        {{405,74}},
        {{405,74}},
        {{405,74}},
        {{405,74}},
        {{405,74}},
        
        {{405,74}}, {{405,74}}, {{405,74}}, {{405,74}}, {{405,74}}, {{405,74}}, {{405,74}}, {{405,74}}, {{405,74}}, {{405,74}},
        
        {{405,74}}, {{405,74}}, {{405,74}}, {{405,74}}, {{405,74}}, {{405,74}}, {{405,74}}, {{405,74}}, {{405,74}},
    },


    { -- "A2" 2
        {},
        
        {{ 640,1437 }}, {{ 640,1437 }}, {{ 640,1437 }}, {{ 640,1437 }}, {{ 640,1437 }}, {{ 640,1437 }}, {{ 640,1437 }}, {{ 640,1437 }}, {{ 640,1437 }}, {{ 640,1437 }},
        
        {{ 640,1437 }}, {{ 640,1437 }}, {{ 640,1437 }}, {{ 640,1437 }}, {{ 640,1437 }}, {{ 640,1437 }}, {{ 640,1437 }}, {{ 640,1437 }}, {{ 640,1437 }}, {{ 640,1437 }},
        
        {{ 640,1437 }}, {{ 640,1437 }}, {{ 640,1437 }}, {{640,1437}}, {{640,1437}}, {{640,1437}}, {{640,1437}}, {{640,1437}}, {{640,1437}}, {{640,1437}},
        
        {{640,1437}}, {{640,1437}}, {{640,1437}}, {{640,1437}}, {{640,1437}}, {{640,1437}}, {{640,1437}}, {{640,1437}}, {{640,1437}}, {{640,1437}},
        
        {{640,1437}},
        {{640,1437}},
        {{640,1437}},
        {{244,1309}, {4567,1080}, {496,885}, {798,975}, {1059,1099}, {855,1351},},
        {{244,1309}, {4567,1080}, {496,885}, {798,975}, {1059,1099}, {855,1351},},
        {{244,1309}, {4567,1080}, {496,885}, {798,975}, {1059,1099}, {855,1351},},
        {{244,1309}, {4567,1080}, {496,885}, {798,975}, {1059,1099}, {855,1351},},
        {{193,772}, {390,402}, {768,600}, {1075,789}, {1338,813},},
        {{193,772}, {390,402}, {768,600}, {1075,789}, {1338,813},},
    },



    { -- "A3" 3
        {},

        {{ 948,804 }}, {{ 948,804 }}, {{ 948,804 }}, {{ 948,804 }}, {{ 948,804 }}, {{ 948,804 }}, {{ 948,804 }}, {{ 948,804 }}, {{ 948,804 }}, {{ 948,804 }},
        {{ 948,804 }}, {{ 948,804 }}, {{ 948,804 }}, {{ 948,804 }}, {{ 948,804 }}, {{ 948,804 }}, {{ 948,804 }}, {{ 948,804 }}, {{ 948,804 }}, {{ 948,804 }},

        {{ 948,804 }},
        {{ 948,804 }},
        {{ 948,804 }},
        {{438, 895}, {725, 864}, {632, 671},},
        {{438, 895}, {725, 864}, {632, 671},},
        {{438, 895}, {725, 864}, {632, 671},},
        {{438, 895}, {725, 864}, {632, 671},},
        {{438, 895}, {725, 864}, {632, 671},},
        {{847, 412}, {844, 854}, {823, 757}, {433, 407},},
        {{847, 412}, {844, 854}, {823, 757}, {433, 407},},
        {{847, 412}, {844, 854}, {823, 757}, {433, 407},},
        {{847, 412}, {844, 854}, {823, 757}, {433, 407},},
        {{847, 412}, {844, 854}, {823, 757}, {433, 407},},
        {{316,168}, {497,130}, {701,157}, {858,316},},
        {{316,168}, {497,130}, {701,157}, {858,316},},
        {{316,168}, {497,130}, {701,157}, {858,316},},
        {{316,168}, {497,130}, {701,157}, {858,316},},
        {{316,168}, {497,130}, {701,157}, {858,316},},
        {{316,168}, {497,130}, {701,157}, {858,316},},
        {{316,168}, {497,130}, {701,157}, {858,316},},
        {{200,277}, {130,646}, {211,638}, {291,851},},
        {{200,277}, {130,646}, {211,638}, {291,851},},
        {{200,277}, {130,646}, {211,638}, {291,851},},
        {{100,150}},
        {{100,150}},
        {{100,150}},
        {{100,150}},
        {{100,150}},
        {{100,150}},
    },

    {}, -- 4
    {}, -- 5
    {}, -- 6
    {}, -- 7
    {}, -- 8
    {}, -- 9
    {}, -- 10
    {}, -- 11
    {}, -- 12
    {}, -- 13
    {}, -- 14
    {}, -- 15
    {}, -- 16
    {}, -- 17
    {}, -- 18
    {}, -- 19
    {}, -- 20

    { -- "B1" 21
        {},
        
        {{412,635}, {629,428}, {829,586},},
        {{412,635}, {629,428}, {829,586},},
        {{412,635}, {629,428}, {829,586},},
        {{329,643}, {632,349}, {905,556},},
        {{329,643}, {632,349}, {905,556},},
        {{329,643}, {632,349}, {905,556},},
        {{329,643}, {632,349}, {905,556},},
        {{329,643}, {632,349}, {905,556},},
        {{329,643}, {632,349}, {905,556},},
        {{329,643}, {632,349}, {905,556},},

        {{329,643}, {632,349}, {905,556},},
        {{866,822}, {706,224}, {247,722},},
        {{866,822}, {706,224}, {247,722},},
        {{617,948}, {353,221},},
        {{617,948}, {353,221},},
        {{617,948}, {353,221},},
        {{617,948}, {353,221},},
        {{617,948}, {353,221},},
        {{617,948}, {353,221},},
        {{617,948}, {353,221},},
    
        {{496,1089}, {890,1043},},
        {{496,1089}, {890,1043},},
        {{496,1089}, {890,1043},},
        {{876,1127}},
        {{876,1127}},
        {{876,1127}},
        {{876,1127}},
        {{876,1127}},
        {{876,1127}},
        {{876,1127}},
    
        {{876,1127}}, {{876,1127}}, {{876,1127}}, {{876,1127}}, {{876,1127}},	{{876,1127}},	{{876,1127}},	{{876,1127}},	{{876,1127}}, {{876,1127}},
        {{876,1127}}, {{876,1127}}, {{876,1127}}, {{908,87}},	{{908,87}},		{{908,87}},		{{908,87}},		{{908,87}},		{{908,87}},
    },

    { -- "B2" 22
        {},

        {{ 95,819 }}, {{ 95,819 }}, {{ 95,819 }}, {{ 95,819 }}, {{ 95,819 }}, {{ 95,819 }}, {{ 95,819 }}, {{ 95,819 }}, {{ 95,819 }}, {{ 95,819 }},
        {{ 95,819 }}, {{ 95,819 }}, {{ 95,819 }}, {{ 95,819 }}, {{ 95,819 }}, {{ 95,819 }}, {{ 95,819 }}, {{ 95,819 }}, {{ 95,819 }}, {{ 95,819 }},
        {{ 95,819 }}, {{ 95,819 }}, {{ 95,819 }}, {{746,1438}}, {{746,1438}}, {{746,1438}}, {{746,1438}}, {{746,1438}}, {{746,1438}}, {{746,1438}},
        {{746,1438}}, {{746,1438}}, {{746,1438}}, {{746,1438}}, {{746,1438}}, {{746,1438}}, {{746,1438}}, {{746,1438}}, {{746,1438}}, {{746,1438}},

        {{746,1438}},
        {{746,1438}},
        {{746,1438}},
        {{ 172,810}, {288,465}, {475,841}, {303,156}, {687,466},},
        {{ 172,810}, {288,465}, {475,841}, {303,156}, {687,466},},
        {{ 172,810}, {288,465}, {475,841}, {303,156}, {687,466},},
        {{ 172,810}, {288,465}, {475,841}, {303,156}, {687,466},},
        {{787,235}, {1209,382}, {1350,571}, {1240,852}, {1254,1126}, {1078,1285}, {727,1360},},
        {{787,235}, {1209,382}, {1350,571}, {1240,852}, {1254,1126}, {1078,1285}, {727,1360},},
    },


    { -- "B3" 23
        {},
        
        {{ 106,88 }}, {{ 106,88 }}, {{ 106,88 }}, {{ 106,88 }}, {{ 106,88 }}, {{ 106,88 }}, {{ 106,88 }}, {{ 106,88 }}, {{ 106,88 }}, {{ 106,88 }},
        {{ 106,88 }}, {{ 106,88 }}, {{ 106,88 }}, {{ 106,88 }}, {{ 106,88 }}, {{ 106,88 }}, {{ 106,88 }}, {{ 106,88 }}, {{ 106,88 }}, {{ 106,88 }},

         {{ 106,88 }},
        {{ 106,88 }},
        {{ 106,88 }},
        {{230, 244}, {200, 444}, {594, 408},},
        {{230, 244}, {200, 444}, {594, 408},},
        {{230, 244}, {200, 444}, {594, 408},},
        {{230, 244}, {200, 444}, {594, 408},},
        {{230, 244}, {200, 444}, {594, 408},},
        {{584,204}, {720,376}, {861,272},},
        {{584,204}, {720,376}, {861,272},},
        {{584,204}, {720,376}, {861,272},},
        {{584,204}, {720,376}, {861,272},},
        {{584,204}, {720,376}, {861,272},},
        {{566,694}, {349,574}, {198,645},},
        {{566,694}, {349,574}, {198,645},},
        {{566,694}, {349,574}, {198,645},},
        {{566,694}, {349,574}, {198,645},},
        {{566,694}, {349,574}, {198,645},},
        {{566,694}, {349,574}, {198,645},},
        {{566,694}, {349,574}, {198,645},},
        {{816,721}, {489,823},},
        {{816,721}, {489,823},},
        {{816,721}, {489,823},},
        {{772,140}},
        {{772,140}},
        {{772,140}},
        {{772,140}},
        {{772,140}},
        {{772,140}},
    },

    {}, -- 24
    {}, -- 25
    {}, -- 26
    {}, -- 27
    {}, -- 28
    {}, -- 29
    {}, -- 30
    {}, -- 31
    {}, -- 32
    {}, -- 33
    {}, -- 34
    {}, -- 35
    {}, -- 36
    {}, -- 37
    {}, -- 38
    {}, -- 39
    {}, -- 40

    { -- "C1" 41
        {},

        {{385,446}, {169,592}, {211,692}, {632,681},},
        {{385,446}, {169,592}, {211,692}, {632,681},},
        {{385,446}, {169,592}, {211,692}, {632,681},},
        {{385,374}, {227,815}, {664,771},},
        {{385,374}, {227,815}, {664,771},},
        {{385,374}, {227,815}, {664,771},},
        {{385,374}, {227,815}, {664,771},},
        {{385,374}, {227,815}, {664,771},},
        {{385,374}, {227,815}, {664,771},},
        {{385,374}, {227,815}, {664,771},},
        
        {{385,374}, {227,815}, {664,771},},
        {{169,362}, {368,304}, {626,409}, {187,882}, {571,858},},
        {{169,362}, {368,304}, {626,409}, {187,882}, {571,858},},
        {{178,275}, {365,242}, {644,313}, {194,950}, {559,936},},
        {{178,275}, {365,242}, {644,313}, {194,950}, {559,936},},
        {{178,275}, {365,242}, {644,313}, {194,950}, {559,936},},
        {{178,275}, {365,242}, {644,313}, {194,950}, {559,936},},
        {{178,275}, {365,242}, {644,313}, {194,950}, {559,936},},
        {{178,275}, {365,242}, {644,313}, {194,950}, {559,936},},
        {{178,275}, {365,242}, {644,313}, {194,950}, {559,936},},
        
        {{452,160}, {536,1034}, {184,1044},},
        {{452,160}, {536,1034}, {184,1044},},
        {{452,160}, {536,1034}, {184,1044},},
        {{137,126}},
        {{137,126}},
        {{137,126}},
        {{137,126}},
        {{137,126}},
        {{137,126}},
        {{137,126}},
        
        {{137,126}}, {{137,126}}, {{137,126}}, {{137,126}}, {{137,126}}, {{137,126}}, {{137,126}}, {{137,126}}, {{137,126}}, {{137,126}},
        {{137,126}}, {{137,126}}, {{137,126}}, {{137,126}}, {{137,126}}, {{137,126}}, {{137,126}}, {{137,126}}, {{137,126}},
    },

    { -- "C2" 42
        {},

        {{1409,139}}, {{1409,139}}, {{1409,139}}, {{1409,139}}, {{1409,139}}, {{1409,139}}, {{1409,139}}, {{1409,139}}, {{1409,139}}, {{1409,139}},
        {{1409,139}}, {{1409,139}}, {{1409,139}}, {{1409,139}}, {{1409,139}}, {{1409,139}}, {{1409,139}}, {{1409,139}}, {{1409,139}}, {{1409,139}},
        {{1409,139}}, {{1409,139}}, {{1409,139}}, {{1409,139}}, {{1409,139}}, {{1409,139}}, {{1409,139}}, {{1409,139}}, {{1409,139}}, {{1409,139}},
        {{1409,139}}, {{1409,139}}, {{1409,139}}, {{1409,139}}, {{1409,139}}, {{1409,139}}, {{1409,139}}, {{1409,139}}, {{1409,139}}, {{1409,139}},
    
        {{1409,139}},
        {{1409,139}},
        {{1409,139}},
        {{991,222}, {1201,525}, {613,232}, {970,751}, {1324,790},},
        {{991,222}, {1201,525}, {613,232}, {970,751}, {1324,790},},
        {{991,222}, {1201,525}, {613,232}, {970,751}, {1324,790},},
        {{991,222}, {1201,525}, {613,232}, {970,751}, {1324,790},},
        {{192,211}, {247,600}, {249,882}, {987,981}, {1018,1288}, {1303,1174},},
        {{192,211}, {247,600}, {249,882}, {987,981}, {1018,1288}, {1303,1174},},
    },

    { -- "C3" 43
        {},

        {{901,151}}, {{901,151}}, {{901,151}}, {{901,151}}, {{901,151}}, {{901,151}}, {{901,151}}, {{901,151}}, {{901,151}}, {{901,151}},
        {{901,151}}, {{901,151}}, {{901,151}}, {{901,151}}, {{901,151}}, {{901,151}}, {{901,151}}, {{901,151}}, {{901,151}}, {{901,151}},
    
        {{901,151}},
        {{901,151}},
        {{901,151}},
        {{421, 189}, {167, 353},},
        {{421, 189}, {167, 353},},
        {{421, 189}, {167, 353},},
        {{421, 189}, {167, 353},},
        {{421, 189}, {167, 353},},
        {{679,459}, {505,709},},
        {{679,459}, {505,709},},
        {{679,459}, {505,709},},
        {{679,459}, {505,709},},
        {{679,459}, {505,709},},
        {{858,638}, {234,596},},
        {{858,638}, {234,596},},
        {{858,638}, {234,596},},
        {{858,638}, {234,596},},
        {{858,638}, {234,596},},
        {{858,638}, {234,596},},
        {{858,638}, {234,596},},
        {{635,856}, {324,855},},
        {{635,856}, {324,855},},
        {{635,856}, {324,855},},
        {{136,899}},
        {{136,899}},
        {{136,899}},
        {{136,899}},
        {{136,899}},
        {{136,899}},
    },

    {}, -- 44
    {}, -- 45
    {}, -- 46
    {}, -- 47
    {}, -- 48
    {}, -- 49
    {}, -- 50
    {}, -- 51
    {}, -- 52
    {}, -- 53
    {}, -- 54
    {}, -- 55
    {}, -- 56
    {}, -- 57
    {}, -- 58
    {}, -- 59
    {}, -- 60
}

function BuildSkillList(job, group)
    local skill_vnum_list = {}
    local skill_name_list = {}

    if pc.get_skill_group() != 0 then
        local skill_list = special.active_skill_list[job+1][group]
                
        table.foreachi( skill_list,
            function(i, t)
                local lev = pc.get_skill_level(t)

                if lev > 0 then
                    local name = locale.GM_SKILL_NAME_DICT[t]

                    if name != nil then
                        table.insert(skill_vnum_list, t)
                        table.insert(skill_name_list, name)
                    end
                end
            end
        )
    end

    table.insert(skill_vnum_list, 0)
    table.insert(skill_name_list, gameforge.locale.cancel)

    return { skill_vnum_list, skill_name_list }
end

--BEGIN EDIT created for Heavens cave pre event, Arne 23Sept09
-- Table for storing character names,
char_name_list = {}
   char_name_list[1] = {}
   char_name_list[2] = {}
   char_name_list[3] = {}
   char_name_list[4] = {}
   char_name_list[5] = {}
   char_name_list[6] = {}
   char_name_list[7] = {}
   char_name_list[8] = {}
   char_name_list[9] = {}
   char_name_list[10] = {}

--no return, just used for storing a name into the list
function store_charname_by_id(id, charname, charid)
       char_name_list[id]["name"] = charname
       char_name_list[id]["eid"] = charid
    return nil
end

-- returns the name of a given list item, id is the highscore slot
function return_charname_by_id(charid)
    local counter = 11
    repeat
        counter = counter -1
    until char_name_list[counter]["eid"] == charid
    return char_name_list[counter]["name"]
end

 function get_map_name_by_number(number)
map_name = {
--EmpireNr-MapNrs
        [1] = {[1] = gameforge.functions._100_say, [2] = gameforge.functions._130_say, [3] = gameforge.functions._130_say,  [4] = gameforge.functions._160_say, [61] = gameforge.functions._200_say, [62] = gameforge.functions._210_say, [63] = gameforge.functions._220_say, [64] = gameforge.functions._190_say, [65] = gameforge.functions._230_say, [72] = gameforge.functions._240_say, [73] = gameforge.functions._240_say,},
        [2] = {[1] = gameforge.functions._110_say, [2] = gameforge.functions._140_say, [3] = gameforge.functions._140_say,  [4] = gameforge.functions._170_say, [61] = gameforge.functions._200_say, [62] = gameforge.functions._210_say, [63] = gameforge.functions._220_say, [64] = gameforge.functions._190_say, [65] = gameforge.functions._230_say, [72] = gameforge.functions._240_say, [73] = gameforge.functions._240_say,},
        [3] = {[1] = gameforge.functions._120_say, [2] = gameforge.functions._150_say, [3] = gameforge.functions._150_say,  [4] = gameforge.functions._180_say, [61] = gameforge.functions._200_say, [62] = gameforge.functions._210_say, [63] = gameforge.functions._220_say, [64] = gameforge.functions._190_say, [65] = gameforge.functions._230_say, [72] = gameforge.functions._240_say, [73] = gameforge.functions._240_say,},
}
    return map_name[pc.get_empire()][number]
end
--END EDIT 

PREMIUM_EXP             = 0
PREMIUM_ITEM            = 1
PREMIUM_SAFEBOX         = 2
PREMIUM_AUTOLOOT        = 3
PREMIUM_FISH_MIND       = 4
PREMIUM_MARRIAGE_FAST   = 5
PREMIUM_GOLD            = 6

-- point type start
POINT_NONE                 = 0
POINT_LEVEL                = 1
POINT_VOICE                = 2
POINT_EXP                  = 3
POINT_NEXT_EXP             = 4
POINT_HP                   = 5
POINT_MAX_HP               = 6
POINT_SP                   = 7
POINT_MAX_SP               = 8  
POINT_STAMINA              = 9  --스테미너
POINT_MAX_STAMINA          = 10 --최대 스테미너

POINT_GOLD                 = 11
POINT_ST                   = 12 --근력
POINT_HT                   = 13 --체력
POINT_DX                   = 14 --민첩성
POINT_IQ                   = 15 --정신력
POINT_DEF_GRADE			= 16
POINT_ATT_SPEED            = 17 --공격속도
POINT_ATT_GRADE			= 18 --공격력 MAX
POINT_MOV_SPEED            = 19 --이동속도
POINT_CLIENT_DEF_GRADE		= 20 --방어등급
POINT_CASTING_SPEED        = 21 --주문속도 (쿨다운타임*100) / (100 + 이값) = 최종 쿨다운 타임
POINT_MAGIC_ATT_GRADE      = 22 --마법공격력
POINT_MAGIC_DEF_GRADE      = 23 --마법방어력
POINT_EMPIRE_POINT         = 24 --제국점수
POINT_LEVEL_STEP           = 25 --한 레벨에서의 단계.. (1 2 3 될 때 보상 4 되면 레벨 업)
POINT_STAT                 = 26 --능력치 올릴 수 있는 개수
POINT_SUB_SKILL			= 27 --보조 스킬 포인트
POINT_SKILL				= 28 --액티브 스킬 포인트
POINT_WEAPON_MIN			= 29 --무기 최소 데미지
POINT_WEAPON_MAX			= 30 --무기 최대 데미지
POINT_PLAYTIME             = 31 --플레이시간
POINT_HP_REGEN             = 32 --HP 회복률
POINT_SP_REGEN             = 33 --SP 회복률

POINT_BOW_DISTANCE         = 34 --활 사정거리 증가치 (meter)

POINT_HP_RECOVERY          = 35 --체력 회복 증가량
POINT_SP_RECOVERY          = 36 --정신력 회복 증가량

POINT_POISON_PCT           = 37 --독 확률
POINT_STUN_PCT             = 38 --기절 확률
POINT_SLOW_PCT             = 39 --슬로우 확률
POINT_CRITICAL_PCT         = 40 --크리티컬 확률
POINT_PENETRATE_PCT        = 41 --관통타격 확률
POINT_CURSE_PCT            = 42 --저주 확률

POINT_ATTBONUS_HUMAN       = 43 --인간에게 강함
POINT_ATTBONUS_ANIMAL      = 44 --동물에게 데미지 % 증가
POINT_ATTBONUS_ORC         = 45 --웅귀에게 데미지 % 증가
POINT_ATTBONUS_MILGYO      = 46 --밀교에게 데미지 % 증가
POINT_ATTBONUS_UNDEAD      = 47 --시체에게 데미지 % 증가
POINT_ATTBONUS_DEVIL       = 48 --마귀(악마)에게 데미지 % 증가
POINT_ATTBONUS_INSECT      = 49 --벌레족
POINT_ATTBONUS_FIRE        = 50 --화염족
POINT_ATTBONUS_ICE         = 51 --빙설족
POINT_ATTBONUS_DESERT      = 52 --사막족
POINT_ATTBONUS_MONSTER     = 53 --모든 몬스터에게 강함
POINT_ATTBONUS_WARRIOR     = 54 --무사에게 강함
POINT_ATTBONUS_ASSASSIN	= 55 --자객에게 강함
POINT_ATTBONUS_SURA		= 56 --수라에게 강함
POINT_ATTBONUS_SHAMAN		= 57 --무당에게 강함

-- ADD_TRENT_MONSTER
POINT_ATTBONUS_TREE     	= 58 --나무에게 강함 20050729.myevan UNUSED5 
-- END_OF_ADD_TRENT_MONSTER
POINT_RESIST_WARRIOR		= 59 --무사에게 저항
POINT_RESIST_ASSASSIN		= 60 --자객에게 저항
POINT_RESIST_SURA			= 61 --수라에게 저항
POINT_RESIST_SHAMAN		= 62 --무당에게 저항

POINT_STEAL_HP             = 63 --생명력 흡수
POINT_STEAL_SP             = 64 --정신력 흡수

POINT_MANA_BURN_PCT        = 65 --마나 번

--/ 피해시 보너스 =/

POINT_DAMAGE_SP_RECOVER    = 66 --공격당할 시 정신력 회복 확률

POINT_BLOCK                = 67 --블럭율
POINT_DODGE                = 68 --회피율

POINT_RESIST_SWORD         = 69
POINT_RESIST_TWOHAND       = 70
POINT_RESIST_DAGGER        = 71
POINT_RESIST_BELL          = 72
POINT_RESIST_FAN           = 73
POINT_RESIST_BOW           = 74  --화살   저항   : 대미지 감소
POINT_RESIST_FIRE          = 75  --화염   저항   : 화염공격에 대한 대미지 감소
POINT_RESIST_ELEC          = 76  --전기   저항   : 전기공격에 대한 대미지 감소
POINT_RESIST_MAGIC         = 77  --술법   저항   : 모든술법에 대한 대미지 감소
POINT_RESIST_WIND          = 78  --바람   저항   : 바람공격에 대한 대미지 감소

POINT_REFLECT_MELEE        = 79 --공격 반사

--/ 특수 피해시 =/
POINT_REFLECT_CURSE		= 80 --저주 반사
POINT_POISON_REDUCE		= 81 --독데미지 감소

--/ 적 소멸시 =/
POINT_KILL_SP_RECOVER		= 82 --적 소멸시 MP 회복
POINT_EXP_DOUBLE_BONUS		= 83
POINT_GOLD_DOUBLE_BONUS		= 84
POINT_ITEM_DROP_BONUS		= 85

--/ 회복 관련 =/
POINT_POTION_BONUS			= 86
POINT_KILL_HP_RECOVERY		= 87

POINT_IMMUNE_STUN			= 88
POINT_IMMUNE_SLOW			= 89
POINT_IMMUNE_FALL			= 90
--========

POINT_PARTY_ATTACKER_BONUS		= 91
POINT_PARTY_TANKER_BONUS		= 92

POINT_ATT_BONUS			= 93
POINT_DEF_BONUS			= 94

POINT_ATT_GRADE_BONUS		= 95
POINT_DEF_GRADE_BONUS		= 96
POINT_MAGIC_ATT_GRADE_BONUS	= 97
POINT_MAGIC_DEF_GRADE_BONUS	= 98

POINT_RESIST_NORMAL_DAMAGE		= 99

POINT_HIT_HP_RECOVERY		= 100
POINT_HIT_SP_RECOVERY 		= 101
POINT_MANASHIELD			= 102 --흑신수호 스킬에 의한 마나쉴드 효과 정도

POINT_PARTY_BUFFER_BONUS		= 103
POINT_PARTY_SKILL_MASTER_BONUS	= 104

POINT_HP_RECOVER_CONTINUE		= 105
POINT_SP_RECOVER_CONTINUE		= 106

POINT_STEAL_GOLD			= 107 
POINT_POLYMORPH			= 108 --변신한 몬스터 번호
POINT_MOUNT				= 109 --타고있는 몬스터 번호

POINT_PARTY_HASTE_BONUS		= 110
POINT_PARTY_DEFENDER_BONUS		= 111
POINT_STAT_RESET_COUNT		= 112 --피의 단약 사용을 통한 스텟 리셋 포인트 (1당 1포인트 리셋가능)

POINT_HORSE_SKILL			= 113

POINT_MALL_ATTBONUS		= 114 --공격력 +x%
POINT_MALL_DEFBONUS		= 115 --방어력 +x%
POINT_MALL_EXPBONUS		= 116 --경험치 +x%
POINT_MALL_ITEMBONUS		= 117 --아이템 드롭율 x/10배
POINT_MALL_GOLDBONUS		= 118 --돈 드롭율 x/10배

POINT_MAX_HP_PCT			= 119 --최대생명력 +x%
POINT_MAX_SP_PCT			= 120 --최대정신력 +x%

POINT_SKILL_DAMAGE_BONUS		= 121 --스킬 데미지 *(100+x)%
POINT_NORMAL_HIT_DAMAGE_BONUS	= 122 --평타 데미지 *(100+x)%

-- DEFEND_BONUS_ATTRIBUTES
POINT_SKILL_DEFEND_BONUS		= 123 --스킬 방어 데미지
POINT_NORMAL_HIT_DEFEND_BONUS	= 124 --평타 방어 데미지
-- END_OF_DEFEND_BONUS_ATTRIBUTES

-- PC_BANG_ITEM_ADD 
POINT_PC_BANG_EXP_BONUS		= 125 --PC방 전용 경험치 보너스
POINT_PC_BANG_DROP_BONUS		= 126 --PC방 전용 드롭률 보너스
-- END_PC_BANG_ITEM_ADD
POINT_RAMADAN_CANDY_BONUS_EXP = 127	-- 라마단 사탕 경픽치 증가용

POINT_ENERGY = 128				-- 128 기력

-- 기력 ui 용.
-- 서버에서 쓰지 않기만, 클라이언트에서 기력의 끝 시간을 POINT로 관리하기 때문에 이렇게 한다.
-- 아 부끄럽다
POINT_ENERGY_END_TIME = 129					-- 129 기력 종료 시간

POINT_COSTUME_ATTR_BONUS = 130
POINT_MAGIC_ATT_BONUS_PER = 131
POINT_MELEE_MAGIC_ATT_BONUS_PER = 132

-- 추가 속성 저항
POINT_RESIST_ICE = 133          --   냉기 저항   : 얼음공격에 대한 대미지 감소
POINT_RESIST_EARTH = 134        --   대지 저항   : 얼음공격에 대한 대미지 감소
POINT_RESIST_DARK = 135        --  어둠 저항   : 얼음공격에 대한 대미지 감소

POINT_RESIST_CRITICAL = 136		-- 크리티컬 저항	: 상대의 크리티컬 확률을 감소
POINT_RESIST_PENETRATE = 137		-- 관통타격 저항	: 상대의 관통타격 확률을 감소

POINT_BOOST_CRITICAL = 138
POINT_BOOST_PENETRATE = 139

POINT_FREEZE_PCT = 140
POINT_LASTING_FIRE_PCT = 141

POINT_BLEEDING_PCT = 142
POINT_BLEEDING_REDUCE = 143

POINT_ATTBONUS_WOLFMAN = 144
POINT_RESIST_WOLFMAN = 145
POINT_RESIST_CLAW = 146
POINT_ACCEDRAIN_RATE = 147

POINT_RESIST_MAGIC_REDUCTION = 148

-- point type start


function input_number (sentence)
     say (sentence)
     local n = nil
     while n == nil do
         n = tonumber (input())
         if n != nil then
             break
         end
         say ("input number")
     end
     return n
 end
ITEM_NONE = 0
ITEM_WEAPON = 1
ITEM_ARMOR = 2

WEAPON_SWORD = 0
WEAPON_DAGGER = 1
WEAPON_BOW = 2
WEAPON_TWO_HANDED = 3
WEAPON_BELL = 4
WEAPON_FAN = 5
WEAPON_ARROW = 6
WEAPON_MOUNT_SPEAR = 7

RESEARCH_LEVEL30 = 0
RESEARCH_LEVEL40 = 1
RESEARCH_LEVEL50 = 2
RESEARCH_LEVEL60 = 3
RESEARCH_LEVEL70 = 4
RESEARCH_LEVEL80 = 5
RESEARCH_LEVEL85 = 6
RESEARCH_LEVEL90 = 7
RESEARCH_LEVEL92 = 8
RESEARCH_LEVEL94 = 9

-- Resets
RESEARCH_RESET_LV92 = 1
RESEARCH_RESET_LV94 = 2

-- Applys
RESEARCH_APPLY_NONE = 0
RESEARCH_APPLY_HP = 1
RESEARCH_APPLY_DEF = 2
RESEARCH_APPLY_STR = 3

function get_today_count(questname, flag_name)
    local today = math.floor(get_global_time() / 86400)
    local today_flag = flag_name.."_today"
    local today_count_flag = flag_name.."_today_count"
    local last_day = pc.getf(questname, today_flag)
    if last_day == today then
        return pc.getf(questname, today_count_flag)
    else
        return 0
    end
end
-- "$flag_name"_today unix_timestamp % 86400
-- "$flag_name"_count count
function inc_today_count(questname, flag_name, count)
    local today = math.floor(get_global_time() / 86400)
    local today_flag = flag_name.."_today"
    local today_count_flag = flag_name.."_today_count"
    local last_day = pc.getqf(questname, today_flag)
    if last_day == today then
        pc.setf(questname, today_count_flag, pc.getf(questname, today_count_flag) + 1)
    else
        pc.setf(questname, today_flag, today)
        pc.setf(questname, today_count_flag, 1)
    end
end

-- This function will return true always in window os,
--  but not in freebsd.
-- (In window os, RAND_MAX = 0x7FFF = 32767.)
function drop_gamble_with_flag(drop_flag)
        local dp, range = pc.get_killee_drop_pct()
        dp = 40000 * dp / game.get_event_flag(drop_flag)
        if dp < 0 or range < 0 then
            return false
        end
        return dp >= number(1, range)
end

function NumberToMoneyString(money)
	local sourceText = tostring(money)
	while true do  
		sourceText, k = string.gsub(sourceText, "^(-?%d+)(%d%d%d)", "%1.%2")
		if (k==0) then
			break
		end
	end
	return sourceText
end

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

function say_enter(msg)
	msg_size = string.len(msg)
	if msg_size > 59 then
		local i = 59
		last_word = nil
		while last_word == nil and i > 0 do
			if string.sub(msg,i,i) == " " or string.sub(msg,i,i) == "." or string.sub(msg,i,i) == "," then
				last_word = i
			end
			i = i-1
		end
		if i == 0 then
			last_word = 59
		end
		say(string.sub(msg,0,last_word))
		say_enter(string.sub(msg,last_word+1))
	else
		say(msg)
	end
end

function LIB_duration(seconds)
	local days = 0
	local hours = math.floor(seconds / 3600)
	local mins = math.floor((seconds - (hours*3600)) / 60)
	local secs = math.floor(seconds - hours*3600 - mins*60)
	local t = ""
	if tonumber(hours) >= 24 then
		days = math.floor(hours / 24)
		hours = math.floor(hours - (days*24))
	end
	if tonumber(days) == 1 then
		t = t..days.." dia "
	elseif tonumber(days) >= 1 then
		t = t..days.." dias "
	end
	if tonumber(hours) == 1 then
		t = t..hours.." hora "
	elseif tonumber(hours) >= 1 then
		t = t..hours.." horas "
	end
	if tonumber(mins) == 1 then
		t = t..mins.." minuto "
	elseif tonumber(mins) >= 1 then
		t = t..mins.." minutos "
	end
	if tonumber(secs) == 1 then
		t = t..secs.." segundo "
	elseif tonumber(secs) >= 1 then
		t = t..secs.." segundos "
	end
	if t == "" then
		return "(Por el momento no puedes!)"
	end
	return t
end
function modulo(v1, v2)
	return v1-(math.floor(v1/v2)*v2)
end

function disp_time(t)
	local days = (t / 86400) or 0
	local hours = (modulo(t, 86400) / 3600) or 0
	local minutes = (modulo(t, 3600) / 60) or 0
	local seconds = (modulo(t, 60)) or 0

	return math.floor(days), math.floor(hours), math.floor(minutes), math.floor(seconds)
end

function tableToEnumeratedString(strTable)
	local lastElementIndex = table.getn(strTable)
	local lastElement = strTable[lastElementIndex]
	if not lastElement then return "" end	

	local str = ""
	if table.getn(strTable) > 1 then
		table.remove(strTable, lastElementIndex)
		str = table.concat(strTable, ", ")
		str = str .. " und " .. lastElement
	else
		str = lastElement
	end
	
	return trim(str)
end

function second_to_hms(t)
	local days, hours, minutes, seconds = disp_time(t)
	local strTable = {}

	if days > 0 then
		table.insert(strTable, string.format("%d Tage", days))
	end

	if hours > 0 then
		table.insert(strTable, string.format("%d Stunden", hours))
	end

	if minutes > 0 then
		table.insert(strTable, string.format("%d Minuten", minutes))
	end

	if seconds > 0
		then table.insert(strTable, string.format("%d Sekunden", seconds))
	end

	return tableToEnumeratedString(strTable)
end

function setTarget(vnum)
	local vid = find_npc_by_vnum(vnum)
	if not vid then return end

	target.vid(tostring(vnum), vid, mob_name(vnum))
end

function deleteTarget(vnum)
	target.delete(tostring(vnum))
end

function clearTarget(vnum)
	target.delete(tostring(vnum))
end

function printQuestHeader(title)
	local title = title or "Information"

	say_title(title)
	say()
end

function printQuestInfo(text)
	local text = text or "Aufgabe"

	say_reward(text)
	say()
end

function sayQuestText(text, value)
	say2(text)

	if not value then
		say()
	end
end

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

function contains(tbl, val)
	for i = 1, table.getn(tbl) do
		if tbl[i] == val then 
			return true
		end
	end
	
	return false
end

function choice()
	local rand = number(1, table.getn(tab))
	
	return tab[rand]
end

function say_blue ( name ) say ( color256 ( 0 , 0 , 255 ).. name .. color256 ( 0 , 0 , 255 )) end
function say_red ( name ) say ( color256 ( 255 , 0 , 0 ).. name .. color256 ( 255 , 0 , 0 )) end
function say_green ( name ) say ( color256 ( 0 , 238 , 0 ).. name .. color256 ( 0 , 238 , 0 )) end
function say_gold ( name ) say ( color256 ( 255 , 215 , 0 ).. name .. color256 ( 255 , 215 , 0 )) end
function say_black ( name ) say ( color256 ( 0 , 0 , 0 ).. name .. color256 ( 0 , 0 , 0 )) end
function say_white ( name ) say ( color256 ( 255 , 255 , 255 ).. name .. color256 ( 255 , 255 , 255 )) end
function say_yellow ( name ) say ( color256 ( 255 , 255 , 0 ).. name .. color256 ( 255 , 255 , 0 )) end
function say_blue2 ( name ) say ( color256 ( 0 , 206 , 209 ).. name .. color256 ( 0 , 206 , 209 )) end

function gold_format(amount)
	local formatted = amount
	while true do
		formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1.%2')
		if k == 0 then
			break
		end
	end
	return formatted
end

nice_time = function(secondsLeft, infoArray)
	local finalString = "";
	local timeFormats = {
		{["timeFormat"] = "%S", ["timeString"] = "second", ["epoch"] = 0, ["handle"] = "secs"},
		{["timeFormat"] = "%M", ["timeString"] = "minute", ["epoch"] = 0, ["handle"] = "min"},
		{["timeFormat"] = "%H", ["timeString"] = "hour", ["epoch"] = 2, ["handle"] = "hours"},
		{["timeFormat"] = "%d", ["timeString"] = "day", ["epoch"] = 1, ["handle"] = "days"},
		{["timeFormat"] = "%m", ["timeString"] = "month", ["epoch"] = 1, ["handle"] = "months"},
		{["timeFormat"] = "%Y", ["timeString"] = "years", ["epoch"] = 1970, ["handle"] = "years"}
	};
	
	for index, data in timeFormats do
		if (infoArray[data["handle"]]) then
			local timeStomp = tonumber(os.date(data["timeFormat"], tonumber(seconds))-data["epoch"]);
			if (timeStomp > 0) then
				local editString = data["timeString"];
				if (timeStomp > 1) then
					editString = string.format("%s%s", editString, "s");
				end
				
				finalString = string.format("%d %s %s", timeStomp, editString, finalString);
			end
		end
	end

	return finalString;
end

function has_item_in_list(item_list, val)
	local list = item_list
	local target = val
	local hasFound =  false
	
	for key, value in pairs(list) do
		if value == target then
			hasFound = true
		end
	end
	return hasFound
end

----------------------------------------------------------------------------
-- Multilang
locale_quest = function(vnum, ...) -- LC -> locale_quest.txt
	local val = ""
	for i, v in ipairs(arg) do
		val = val .. tostring(string.format(";%s", v))
	end
	return string.format("[LC;%d%s]", vnum, val)
end

locale_string = function(vnum, ...) -- LS -> locale_string.txt
	local val = ""
	for i, v in ipairs(arg) do
		val = val .. tostring(string.format(";%s", v))
	end
	return string.format("[LS;%d%s]", vnum, val)
end

locale_ox = function(vnum) -- LOX -> locale_quiz.txt
	return string.format("[LOX;%d]", vnum)
end

item_name = function(vnum) -- item_name
	return string.format("[IN;%d]", vnum)
end

mob_name = function(vnum) -- mob_name
	return string.format("[MN;%d]", vnum)
end

skill_name = function(vnum) -- skill_name
	return string.format("[SN;%d]", vnum)
end

pet_skill_name = function(vnum) -- pet_skill_name
	return string.format("[PSN;%d]", vnum)
end

-- Owsap function
is_valid_number = function(num)
	return not ({
		["nan"] = true,
		["inf"] = true,
		["-inf"] = true
	})[tostring(num)];
end -- function

fortune_words = function(index, line)
	local fortuneWords = {
		{
			locale_quest(2500),
			locale_quest(2499)
		},
		{
			locale_quest(2502),
			locale_quest(2501)
		},
		{
			locale_quest(2504),
			locale_quest(2503)
		},
		{
			locale_quest(2506),
			locale_quest(2505)
		},
		{
			locale_quest(2508),
			locale_quest(2507)
		},
		{
			locale_quest(2510),
			locale_quest(2509)
		},
		{
			locale_quest(2512),
			locale_quest(2511)
		},
	}
	index = index or math.random(1, table.getn(fortuneWords))
	line = line or 1
	return fortuneWords[index][line]
end

function say_npc() say_title("" .. mob_name(npc.get_race()) .. "") end

-- BuildSkillList
function BuildLocaleSkillList(job, group)
	local skill_vnum_list = {}
	local skill_name_list = {}
	if pc.get_skill_group() != 0 then
		local skill_list = special.active_skill_list[job + 1][group]
		table.foreachi( skill_list,
			function(i, t)
				local lev = pc.get_skill_level(t)
				if lev > 0 then
					local name = skill_name(t)
					if name != nil then
						table.insert(skill_vnum_list, t)
						table.insert(skill_name_list, name)
					end
				end
			end
		)
	end
	table.insert(skill_vnum_list, 0)
	table.insert(skill_name_list, locale_quest(2426))
	return { skill_vnum_list, skill_name_list }
end

map_name = function(map_index)
	local mapName = {
		[61] = locale_quest(2691),
		[62] = locale_quest(2692),
		[63] = locale_quest(2693),
		[64] = locale_quest(2694),
	}
	return mapName[map_index]
end

function wait_time_to_str(timestamp)
	local left_secs = timestamp - get_global_time()
	if left_secs > 0 then
		hours = string.format("%02.f", math.floor(left_secs / 3600))
		mins = string.format("%02.f", math.floor(left_secs / 60 - (hours * 60)))
		secs = string.format("%02.f", math.floor(left_secs - hours * 3600 - mins * 60))
		if tonumber(hours) > 0 then
			return string.format(locale_quest(4446), hours, mins)
		else
			return string.format(locale_quest(4447), mins, secs)
		end
	end
end
-- End Owsap function

function round(x)
  return x>=0 and math.floor(x+0.5) or math.ceil(x-0.5)
end
