if not _G.charSelectExists then return end

local KAKTUS_MOVES_SCRIBBLES = get_texture_info("kakscribbles")

local kaktusMovesetGuide = false

local function cmd_kaktus_moveset_guide(msg)
    kaktusMovesetGuide = true
    return true
end
hook_chat_command("kaktus-moves", "Brings up a tutorial on Kaktus's moves.", cmd_kaktus_moveset_guide)

local function kaktus_hud()
    djui_hud_set_resolution(RESOLUTION_N64)
    djui_hud_set_color(255, 255, 255, 255)

    if kaktusMovesetGuide then
        djui_hud_render_texture(KAKTUS_MOVES_SCRIBBLES, 1, 1, 1, 1)
    end
end
--_G.charSelect.character_hook_moveset(CT_KAKTUS, HOOK_ON_HUD_RENDER_BEHIND, kaktus_hud)