-- name: [CS] \\#ac50ff\\Kaktus
-- description: Kaktus arrives at Peach's Castle after taking a wrong turn on the I-35. \n\n\\#ff7777\\This Pack requires Character Select\nto use as a Library!

--[[
    API Documentation for Character Select can be found below:
    https://github.com/Squishy6094/character-select-coop/wiki/API-Documentation

    Use this if you're curious on how anything here works >v<
	(This is an edited version of the Template File by Squishy)
]]

local TEXT_MOD_NAME = "[CS] Kaktus"

-- Stops mod from loading if Character Select isn't on
if not _G.charSelectExists then
    djui_popup_create("\\#ffffdc\\\n"..TEXT_MOD_NAME.."\nRequires the Character Select Mod\nto use as a Library!\n\nPlease turn on the Character Select Mod\nand Restart the Room!", 6)
    return 0
end

local E_MODEL_KAKTUS = smlua_model_util_get_id("kaktus_geo")

local E_MODEL_KAKTETO = smlua_model_util_get_id("kakteto_geo")

local KAKTUS_ICON = get_texture_info("Kaktus-LifeIcon1")

local KAKTETO_ICON = get_texture_info("Kakteto_Icon")

-- SPEEDOMETER

SPEEDOMETER_0 = get_texture_info("Speedometer1")
SPEEDOMETER_1 = get_texture_info("Speedometer2")
SPEEDOMETER_2 = get_texture_info("Speedometer3")
SPEEDOMETER_3 = get_texture_info("Speedometer4")
SPEEDOMETER_MAX = get_texture_info("Speedometer5")

-- All Located in "sound" Name them whatever you want. Remember to include the .ogg extension
local VOICETABLE_KAKTUS = {
    [CHAR_SOUND_OKEY_DOKEY] = 'Silent.ogg', -- Starting game
	[CHAR_SOUND_LETS_A_GO] = 'Silent.ogg', -- Starting level
	[CHAR_SOUND_PUNCH_YAH] = 'hit1.ogg', -- Punch 1
	[CHAR_SOUND_PUNCH_WAH] = 'hit2.ogg', -- Punch 2
	[CHAR_SOUND_PUNCH_HOO] = 'kick.ogg', -- Punch 3
	[CHAR_SOUND_YAH_WAH_HOO] = {'jump1.ogg', 'jump2.ogg', 'jump3.ogg'}, -- First/Second jump sounds
	[CHAR_SOUND_HOOHOO] = 'jumpdouble23.ogg', -- Third jump sound
	[CHAR_SOUND_YAHOO_WAHA_YIPPEE] = {'triplejump.ogg', 'longjump.ogg'}, -- Triple jump sounds
	[CHAR_SOUND_UH] = 'ohmygod.ogg', -- Wall bonk
	[CHAR_SOUND_UH2] = 'Silent.ogg', -- Landing after long jump
	[CHAR_SOUND_UH2_2] = 'longjumpland.ogg', -- Same sound as UH2; jumping onto ledge
	[CHAR_SOUND_HAHA] = 'landtriple.ogg', -- Landing triple jump
	[CHAR_SOUND_YAHOO] = 'longjump.ogg', -- Long jump
	[CHAR_SOUND_DOH] = 'wallhit.ogg', -- Long jump wall bonk
	[CHAR_SOUND_WHOA] = 'ohmygod.ogg', -- Grabbing ledge
	[CHAR_SOUND_EEUH] = 'lift.ogg', -- Climbing over ledge
	[CHAR_SOUND_WAAAOOOW] = 'fallong.ogg', -- Falling a long distance
	[CHAR_SOUND_TWIRL_BOUNCE] = 'holyshit.ogg', -- Bouncing off of a flower spring
	[CHAR_SOUND_GROUND_POUND_WAH] = 'jump1.ogg',
	[CHAR_SOUND_HRMM] = 'lift.ogg', -- Lifting something
	[CHAR_SOUND_HERE_WE_GO] = {'stargetnew.ogg', 'stargetnew2.ogg', 'stargetnew3.ogg', 'stargetnew5.ogg'}, -- Star get
	[CHAR_SOUND_SO_LONGA_BOWSER] = 'solonga.ogg', -- Throwing Bowser
--DAMAGE
	[CHAR_SOUND_ATTACKED] = 'hurt.ogg', -- Damaged
	[CHAR_SOUND_PANTING] = 'lowhealth.ogg', -- Low health
	[CHAR_SOUND_ON_FIRE] = 'assfire.ogg', -- Burned
--SLEEP SOUNDS
	[CHAR_SOUND_IMA_TIRED] = 'Silent.ogg', -- Mario feeling tired
	[CHAR_SOUND_YAWNING] = 'yawn.ogg', -- Mario yawning before he sits down to sleep
	[CHAR_SOUND_SNORING1] = 'Silent.ogg', -- Snore Inhale
	[CHAR_SOUND_SNORING2] = 'Silent.ogg', -- Exhale
	[CHAR_SOUND_SNORING3] = 'sleeptalking.ogg', -- Sleep talking / mumbling
--COUGHING (USED IN THE GAS MAZE)
	[CHAR_SOUND_COUGHING1] = 'cough1.ogg', -- Cough take 1
	[CHAR_SOUND_COUGHING2] = 'cough2.ogg', -- Cough take 2
	[CHAR_SOUND_COUGHING3] = 'cough3.ogg', -- Cough take 3
--DEATH
	[CHAR_SOUND_DYING] = 'deathdamage.ogg', -- Dying from damage
	[CHAR_SOUND_DROWNING] = 'drown.ogg', -- Running out of air underwater
    [CHAR_SOUND_MAMA_MIA] = 'levelboot.ogg', -- Booted out of level
--EXTRAS
    [CHAR_SOUND_PRESS_START_TO_PLAY] = 'sm64_moneybags_jump.ogg'
}


local ANIMTABLE_KAKTUS = {
    [CHAR_ANIM_IDLE_HEAD_CENTER] = 'idleanimkak',
    [CHAR_ANIM_IDLE_HEAD_LEFT] = 'idleanimkak',
    [CHAR_ANIM_IDLE_HEAD_RIGHT] = 'lookingsidekak',
    [CHAR_ANIM_TRIPLE_JUMP] = 'triplejumpspin',
    [CHAR_ANIM_CREDITS_START_WALK_LOOK_UP] = 'endcutscenekak',
    [CHAR_ANIM_CREDITS_LOOK_BACK_THEN_RUN] = 'endcutsceneotherkak',
    [CHAR_ANIM_CREDITS_WAVING] = 'endcutsceneotherkak',
    [CHAR_ANIM_FIRST_PERSON] = 'idleanimkak',
    [CHAR_ANIM_AIR_KICK] = 'roundhousekak',
    [CHAR_ANIM_SLOW_LONGJUMP] = 'kakbouncejump',
}

local PALETTE_KAKTUS = {
    [PANTS]  = "313149",
    [SHIRT]  = "791E82",
    [GLOVES] = "FFB97B",
    [SHOES]  = "D8004D",
    [HAIR]   = "743F39",
    [SKIN]   = "DB9C70",
    [CAP]    = "3E8948",
	[EMBLEM] = "D87644"
}

local PALETTE_KAKTETO = {
    [PANTS]  = "313149",
    [SHIRT]  = "333333",
    [GLOVES] = "FFB97B",
    [SHOES]  = "D8004D",
    [HAIR]   = "AD1834",
    [SKIN]   = "DB9C70",
    [CAP]    = "3E8948",
	[EMBLEM] = "D87644"
}

local HM_KAKTUS= {
    label = {
        left = get_texture_info("KakLeftHealth"),
        right = get_texture_info("KakRightHealth"),
    },
    pie = {
        [1] = get_texture_info("KakPie1"),
        [2] = get_texture_info("KakPie2"),
        [3] = get_texture_info("KakPie3"),
        [4] = get_texture_info("KakPie4"),
        [5] = get_texture_info("KakPie5"),
        [6] = get_texture_info("KakPie6"),
        [7] = get_texture_info("KakPie7"),
        [8] = get_texture_info("KakPie8"),
    }
}

local CSloaded = false
local function on_character_select_load()
    CT_KAKTUS = _G.charSelect.character_add("Kaktus", {"Kaktus arrives at Peach's Castle", "after taking a wrong turn on the", "I-35."}, "Kaktus64 & JerThePear", {r = 172, g = 80, b = 255}, E_MODEL_KAKTUS, CT_KAKTUS, KAKTUS_ICON)
    _G.charSelect.character_add_caps(E_MODEL_KAKTUS, CAPTABLE_CHAR)
    _G.charSelect.character_add_voice(E_MODEL_KAKTUS, VOICETABLE_KAKTUS)
    _G.charSelect.character_add_palette_preset(E_MODEL_KAKTUS, PALETTE_KAKTUS)
    _G.charSelect.character_add_health_meter(CT_KAKTUS, HM_KAKTUS)
    _G.charSelect.character_add_animations(E_MODEL_KAKTUS, ANIMTABLE_KAKTUS)
    _G.charSelect.character_hook_moveset(CT_KAKTUS, HOOK_MARIO_UPDATE, HOOK_BEFORE_SET_MARIO_ACTION, HOOK_ON_HUD_RENDER_BEHIND, HOOK_ON_HUD_RENDER)
    _G.charSelect.character_set_category(CT_KAKTUS, "DXA")
    _G.charSelect.character_set_category(CT_KAKTUS, "Squishy Workshop")
    add_moveset()

    _G.charSelect.character_add_costume(CT_KAKTUS, "Kakane Teto", nil, "Kaktus64 & JerThePear", nil, E_MODEL_KAKTETO, CT_LUIGI, KAKTETO_ICON, nil, nil)
    _G.charSelect.character_add_voice(E_MODEL_KAKTETO, VOICETABLE_KAKTUS)
    _G.charSelect.character_add_palette_preset(E_MODEL_KAKTETO, PALETTE_KAKTETO)
    _G.charSelect.character_add_animations(E_MODEL_KAKTETO, ANIMTABLE_KAKTUS)

    CSloaded = true
end

local function on_character_sound(m, sound)
    if not CSloaded then return end
    if _G.charSelect.character_get_voice(m) == VOICETABLE_KAKTUS then return _G.charSelect.voice.sound(m, sound) end
end

local function on_character_snore(m)
    if not CSloaded then return end
    if _G.charSelect.character_get_voice(m) == VOICETABLE_KAKTUS then return _G.charSelect.voice.snore(m) end
end

hook_event(HOOK_ON_MODS_LOADED, on_character_select_load)
hook_event(HOOK_CHARACTER_SOUND, on_character_sound)
hook_event(HOOK_MARIO_UPDATE, on_character_snore)

KakGB = get_texture_info("KaktusGameBoy")

function is_kaktus()
    return CT_KAKTUS == charSelect.character_get_current_number()
end
