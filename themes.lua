
KAKTUS_TANOOKI_MUSIC = audio_stream_load("kaktus_tanooki.ogg")

KAKTUS_GOLD_SHROOM_MUSIC = audio_stream_load("kaktus_golden_shroom.ogg")

-- thank you xLuigiGamerx

function cur_level_music_kak(m)
    return get_current_background_music()
end

function kaktus_tanooki(m)
    if not m then return end
    return m.flags & MARIO_WING_CAP ~= 0 -- returns true if you have a wing cap, else it returns false
end

function kaktus_gold_shroom(m)
    if not m then return end
    return m.flags & MARIO_METAL_CAP ~= 0 -- returns true if you have a wing cap, else it returns false
end

function mario_update(m)
    if m.playerIndex ~= 0 then return end
    -- Tanooki theme
    if kaktus_tanooki(m) and is_kaktus() then
        audio_stream_play(KAKTUS_TANOOKI_MUSIC, false, 0.9)
        play_cap_music(0)
    else
        audio_stream_stop(KAKTUS_TANOOKI_MUSIC)
    end
    if is_game_paused() or m.action == ACT_START_SLEEPING or m.action == ACT_SLEEPING then
        audio_stream_set_volume(KAKTUS_TANOOKI_MUSIC, 0.3)
    end
    -- Golden Mushroom theme
    if kaktus_gold_shroom(m) and is_kaktus() then
        audio_stream_play(KAKTUS_GOLD_SHROOM_MUSIC, false, 0.9)
        play_cap_music(0)
    else
        audio_stream_stop(KAKTUS_GOLD_SHROOM_MUSIC)
    end
    if is_game_paused() or m.action == ACT_START_SLEEPING or m.action == ACT_SLEEPING then
        audio_stream_set_volume(KAKTUS_GOLD_SHROOM_MUSIC, 0.3)
    end
end

hook_event(HOOK_MARIO_UPDATE, mario_update)