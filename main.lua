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

local KAKTUS_ICON = get_texture_info("Kaktus-LifeIcon1")



local KAKTUS_SILHOUETTE = get_texture_info("kaksilh")

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
	[CHAR_SOUND_PUNCH_YAH] = 'kakhey.ogg', -- Punch 1
	[CHAR_SOUND_PUNCH_WAH] = 'kakyip.ogg', -- Punch 2
	[CHAR_SOUND_PUNCH_HOO] = 'kakyeah.ogg', -- Punch 3
	[CHAR_SOUND_YAH_WAH_HOO] = {'kakheyshort.ogg', 'kakyeahshort.ogg'}, -- First/Second jump sounds
	[CHAR_SOUND_HOOHOO] = 'kakheyhey.ogg', -- Third jump sound
	[CHAR_SOUND_YAHOO_WAHA_YIPPEE] = {'kakwoohoo.ogg', 'kakyipee.ogg'}, -- Triple jump sounds
	[CHAR_SOUND_UH] = 'kakeek.ogg', -- Wall bonk
	[CHAR_SOUND_UH2] = 'kakyes.ogg', -- Landing after long jump
	[CHAR_SOUND_UH2_2] = 'kakyes.ogg', -- Same sound as UH2; jumping onto ledge
	[CHAR_SOUND_HAHA] = 'kaktada.ogg', -- Landing triple jump
	[CHAR_SOUND_YAHOO] = 'kakwoohoo.ogg', -- Long jump
	[CHAR_SOUND_DOH] = 'kakuhoh.ogg', -- Long jump wall bonk
	[CHAR_SOUND_WHOA] = 'kakeek.ogg', -- Grabbing ledge
	[CHAR_SOUND_EEUH] = 'Silent.ogg', -- Climbing over ledge
	[CHAR_SOUND_WAAAOOOW] = 'Silent.ogg', -- Falling a long distance
	[CHAR_SOUND_TWIRL_BOUNCE] = 'kakyipee.ogg', -- Bouncing off of a flower spring
	[CHAR_SOUND_GROUND_POUND_WAH] = 'kakyip.ogg',
	[CHAR_SOUND_HRMM] = 'kakhurt.ogg', -- Lifting something
	[CHAR_SOUND_HERE_WE_GO] = 'kakwoohoo.ogg', -- Star get
	[CHAR_SOUND_SO_LONGA_BOWSER] = 'Silent.ogg', -- Throwing Bowser
--DAMAGE
	[CHAR_SOUND_ATTACKED] = 'kakow.ogg', -- Damaged
	[CHAR_SOUND_PANTING] = 'Silent.ogg', -- Low health
	[CHAR_SOUND_ON_FIRE] = 'kakeek.ogg', -- Burned
--SLEEP SOUNDS
	[CHAR_SOUND_IMA_TIRED] = 'Silent.ogg', -- Mario feeling tired
	[CHAR_SOUND_YAWNING] = 'Silent.ogg', -- Mario yawning before he sits down to sleep
	[CHAR_SOUND_SNORING1] = 'Silent.ogg', -- Snore Inhale
	[CHAR_SOUND_SNORING2] = 'Silent.ogg', -- Exhale
	[CHAR_SOUND_SNORING3] = 'Silent.ogg', -- Sleep talking / mumbling
--COUGHING (USED IN THE GAS MAZE)
	[CHAR_SOUND_COUGHING1] = 'Silent.ogg', -- Cough take 1
	[CHAR_SOUND_COUGHING2] = 'Silent.ogg', -- Cough take 2
	[CHAR_SOUND_COUGHING3] = 'Silent.ogg', -- Cough take 3
--DEATH
	[CHAR_SOUND_DYING] = 'kakeek.ogg', -- Dying from damage
	[CHAR_SOUND_DROWNING] = 'Silent.ogg', -- Running out of air underwater
    [CHAR_SOUND_MAMA_MIA] = 'kakuhoh.ogg', -- Booted out of level
--EXTRAS
    [CHAR_SOUND_PRESS_START_TO_PLAY] = 'sm64_moneybags_jump.ogg'
}


local ANIMTABLE_KAKTUS = {
    [_G.charSelect.CS_ANIM_MENU] = "kaktus_menu_pose",
    [CHAR_ANIM_TRIPLE_JUMP] = 'triplejumpspin',
    [CHAR_ANIM_CREDITS_START_WALK_LOOK_UP] = 'endcutscenekak',
    [CHAR_ANIM_CREDITS_LOOK_BACK_THEN_RUN] = 'endcutsceneotherkak',
    [CHAR_ANIM_CREDITS_WAVING] = 'endcutsceneotherkak',
    [CHAR_ANIM_AIR_KICK] = 'roundhousekak',
    [CHAR_ANIM_SINGLE_JUMP] = 'kaktus_single_jump',
    [CHAR_ANIM_RUNNING] = 'kaktuse_run',

}

local PALETTE_KAKTUS = {

    name = "Kaktus",
    [PANTS]  = "313149",
    [SHIRT]  = "791E82",
    [GLOVES] = "FF0003",
    [SHOES]  = "D8004D",
    [HAIR]   = "743F39",
    [SKIN]   = "DB9C70",
    [CAP]    = "3E8948",
	[EMBLEM] = "D87644"
}

local PALETTE_JERTUS = {

    name = "Jertus",
    [PANTS]  = "008040",
    [SHIRT]  = "ffaa00",
    [GLOVES] = "008040",
    [SHOES]  = "462c1e",
    [HAIR]   = "462c1e",
    [SKIN]   = "DB9C70",
    [CAP]    = "00ff00",
	[EMBLEM] = "4c4c4c"
}

local PALETTE_TRANSGENDER_KAK = {
        name = "Transgender",
        [PANTS] = "398FBE",
        [SHIRT] = "B96C86",
        [GLOVES] = "B96C86",
        [SHOES] = "620E22",
        [HAIR] = "FF9BCD",
        [SKIN] = "DB9C70",
        [CAP] = "398FBE",
        [EMBLEM] = "FFFFFF"
    }

    local PALETTE_WARM_BREEZE_KAK = {
        name = "Warm Breeze",
        [PANTS] = "353b64",
        [SHIRT] = "872e59",
        [GLOVES] = "872e59",
        [SHOES] = "462c1e",
        [HAIR] = "462c1e",
        [SKIN] = "db9c70",
        [CAP] = "36a74d",
        [EMBLEM] = "8c4947"
    }

    local PALETTE_COOL_BREEZE_KAK = {
        name = "Cool Breeze",
        [PANTS] = "2b213b",
        [SHIRT] = "582e82",
        [GLOVES] = "582e82",
        [SHOES] = "362c47",
        [HAIR] = "362c47",
        [SKIN] = "a39cd6",
        [CAP] = "365594",
        [EMBLEM] = "585090"
    }

    local PALETTE_FALL_BREEZE_KAK = {
    name = "Fall Breeze",
    [PANTS]  = "62263c",
    [SHIRT]  = "ff722f",
    [GLOVES] = "ff722f",
    [SHOES]  = "8e6b41",
    [HAIR]   = "944025",
    [SKIN]   = "fe975b",
    [CAP]    = "905b33",
    [EMBLEM] = "ff722f",
    }

    PALETTE_LOOK_GOOD_KAK =  {
    name = "Looking Good",
    [PANTS]  = { r = 0xA9, g = 0x1D, b = 0x28 }, -- A91D28
    [SHIRT]  = { r = 0x3E, g = 0x20, b = 0x45 }, -- 3E2045
    [GLOVES] = { r = 0x00, g = 0x9D, b = 0xBD }, -- 009DBD
    [SHOES]  = { r = 0x5B, g = 0x7C, b = 0xBD }, -- 5B7CBD
    [HAIR]   = { r = 0x3B, g = 0x0F, b = 0x1C }, -- 3B0F1C
    [SKIN] = "db9c70",
    [CAP]    = { r = 0x1C, g = 0x24, b = 0x2D }, -- 1C242D
    [EMBLEM] = { r = 0xDB, g = 0x3C, b = 0x2E }, -- DB3C2E
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

local COURSE_KAKTUS = {
    top = get_texture_info("KakCourse1"),
    bottom = get_texture_info("KakCourse2"),
}

local CAPTABLE_KAKTUS = {
    normal = smlua_model_util_get_id("kakcap_geo"),
    wing = smlua_model_util_get_id("kakwingcap_geo"),
    metal = smlua_model_util_get_id("kakmetalcap_geo"),
    --metalWing = smlua_model_util_get_id("custom_model_cap_wing_geo")
}

--function texture_override_handle(WARP_TRANSITION_FADE_INTO_MARIO, KAKTUS_SILHOUETTE) -- This refuses to work


    --if _G.charSelect.character_get_current_number() == CT_KAKTUS then
        --texture_override_set(WARP_TRANSITION_FADE_INTO_MARIO, KAKTUS_SILHOUETTE) 
    --end
--end

local CSloaded = false
local function on_character_select_load()
    CT_KAKTUS = _G.charSelect.character_add("Kaktus", {"Kaktus arrives at Peach's Castle", "after taking a wrong turn on the", "I-35."}, "Kaktus64 & JerThePear", {r = 172, g = 80, b = 255}, E_MODEL_KAKTUS, CT_KAKTUS, KAKTUS_ICON)
    _G.charSelect.character_add_caps(E_MODEL_KAKTUS, CAPTABLE_KAKTUS)
    _G.charSelect.character_add_voice(E_MODEL_KAKTUS, VOICETABLE_KAKTUS)
    _G.charSelect.character_add_health_meter(CT_KAKTUS, HM_KAKTUS)
    _G.charSelect.character_add_course_texture(CT_KAKTUS, COURSE_KAKTUS)
    _G.charSelect.character_add_animations(E_MODEL_KAKTUS, ANIMTABLE_KAKTUS)
    _G.charSelect.character_hook_moveset(CT_KAKTUS, HOOK_MARIO_UPDATE, HOOK_BEFORE_SET_MARIO_ACTION, HOOK_ON_HUD_RENDER_BEHIND, HOOK_ON_SET_MARIO_ACTION, kaktus_hud)
    _G.charSelect.character_set_category(CT_KAKTUS, "DXA")
    _G.charSelect.character_set_category(CT_KAKTUS, "Squishy Workshop")

    -- PALETTES

    _G.charSelect.character_add_palette_preset(E_MODEL_KAKTUS, PALETTE_KAKTUS, "Kaktus")
    _G.charSelect.character_add_palette_preset(E_MODEL_KAKTUS, PALETTE_JERTUS, "Jertus")
    _G.charSelect.character_add_palette_preset(E_MODEL_KAKTUS, PALETTE_TRANSGENDER_KAK, "Trans")
    _G.charSelect.character_add_palette_preset(E_MODEL_KAKTUS, PALETTE_WARM_BREEZE_KAK, "Warm Breeze")
    _G.charSelect.character_add_palette_preset(E_MODEL_KAKTUS, PALETTE_COOL_BREEZE_KAK, "Cool Breeze")
    _G.charSelect.character_add_palette_preset(E_MODEL_KAKTUS, PALETTE_FALL_BREEZE_KAK, "Fall Breeze")
    _G.charSelect.character_add_palette_preset(E_MODEL_KAKTUS, PALETTE_LOOK_GOOD_KAK, "Looking Good")
    add_moveset()

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
