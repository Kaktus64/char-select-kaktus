
KAKTUS_TANOOKI_MUSIC = audio_stream_load("kaktus_tanooki.ogg")

if is_kaktus() then
    if (m.flags & MARIO_WING_CAP) ~= 0 then
        audio_stream_play(KAKTUS_TANOOKI_MUSIC, true, 20)
    else
        audio_stream_stop(KAKTUS_TANOOKI_MUSIC)
    end
end