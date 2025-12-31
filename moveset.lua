
local KAKTUS_TAIL = audio_sample_load("kaktus-tail.ogg")
local KAKTUS_PIROUETTE = audio_sample_load("kaktus_pirouette.ogg")

---@diagnostic disable: undefined-global
if not _G.charSelectExists then return end

local gStateExtras = {}
for i = 0, MAX_PLAYERS - 1 do
    gStateExtras[i] = {}
    local m = gMarioStates[i]
    local e = gStateExtras[i]
    e.rotAngle = 0
    e.canBrella = true
    e.charArg = 0
    e.flyFloor = 0
    e.canIsikleDrill = true
end

local function limit_angle(a)
    return (a + 0x8000) % 0x10000 - 0x8000
end

--kaktus actions
ACT_SUPERJUMP_CROUCH_KAK = allocate_mario_action(ACT_GROUP_STATIONARY)
ACT_BRELLA_FLOAT = allocate_mario_action(ACT_GROUP_AIRBORNE | ACT_FLAG_AIR)
ACT_BRELLA_JUMP = allocate_mario_action(ACT_GROUP_AIRBORNE | ACT_FLAG_AIR)
ACT_BRELLA_POUND = allocate_mario_action(ACT_GROUP_AIRBORNE | ACT_FLAG_AIR | ACT_FLAG_ATTACKING)
ACT_BRELLA_SPIN = allocate_mario_action(ACT_GROUP_AIRBORNE | ACT_FLAG_AIR | ACT_FLAG_ATTACKING)
ACT_KAK_LONG_JUMP = allocate_mario_action(ACT_GROUP_AIRBORNE | ACT_FLAG_AIR)
ACT_TANOOKI_FLY_KAK = allocate_mario_action(ACT_GROUP_AIRBORNE | ACT_FLAG_AIR)
ACT_SHROOM_DASH = allocate_mario_action(ACT_GROUP_AIRBORNE | ACT_FLAG_AIR | ACT_FLAG_ATTACKING)

--isikle actions
ACT_ISIKLE_POUND = allocate_mario_action(ACT_GROUP_AIRBORNE | ACT_FLAG_AIR | ACT_FLAG_ATTACKING)
ACT_ISIKLE_HAMMER_SPIN = allocate_mario_action(ACT_GROUP_AIRBORNE | ACT_FLAG_AIR | ACT_FLAG_ATTACKING)
ACT_ISIKLE_DRILL_AIR = allocate_mario_action(ACT_GROUP_AIRBORNE | ACT_FLAG_AIR | ACT_FLAG_ATTACKING)

function act_superjump_crouch_kak (m)
    if m.controller.buttonPressed & A_BUTTON ~= 0 then
        set_mario_action(m, ACT_BACKFLIP, 0)
        m.vel.y = 80
        m.forwardVel = 0
    end
    if m.controller.buttonPressed & B_BUTTON ~= 0 then
        set_mario_action(m, ACT_SLIDE_KICK, 0)
    end
end
hook_mario_action(ACT_SUPERJUMP_CROUCH_KAK, act_superjump_crouch_kak)


local brellaActions = { -- What actions you can brella out of
    [ACT_JUMP] = true,
    [ACT_DOUBLE_JUMP] = true,
    [ACT_TRIPLE_JUMP] = true,
    [ACT_LONG_JUMP] = true,
    [ACT_FREEFALL] = true,
    [ACT_SIDE_FLIP] = true,
    [ACT_BACKFLIP] = true,
    [ACT_WALL_KICK_AIR] = true,
    [ACT_TOP_OF_POLE_JUMP] = true,
    [ACT_SHOT_FROM_CANNON] = true,
    [ACT_WATER_JUMP] = true,
    [ACT_SHROOM_DASH] = true
}

local brellaHandActions = { -- What actions you bring out the brella for
    [ACT_PUNCHING] = true,
    [ACT_MOVE_PUNCHING] = true,
    [ACT_CROUCHING] = true,
    [ACT_CROUCH_SLIDE] = true
}

-- CAP ACTIONS

function act_tanooki_fly_kak(m)
    local e = gStateExtras[m.playerIndex]
    local stepResult = common_air_action_step(m, ACT_FREEFALL_LAND, CHAR_ANIM_FLY_FROM_CANNON, AIR_STEP_CHECK_LEDGE_GRAB)
    m.faceAngle.y = m.intendedYaw - approach_s32(limit_angle(m.intendedYaw - m.faceAngle.y), 0, 0x400, 0x400)
    m.peakHeight = m.pos.y -- no fall sound
    if m.vel.y < -75 then
        m.vel.y = -75
    end
    if m.forwardVel > 40 then
        m.forwardVel = m.forwardVel - 1
    end
    if m.pos.y < e.flyFloor + 1000 then
        if m.controller.buttonPressed & A_BUTTON ~= 0 and m.prevAction ~= ACT_JUMP and m.actionTimer > 5 then
            m.vel.y = 30
            audio_sample_play(KAKTUS_TAIL, m.pos, 1)
            set_mario_particle_flags(m, PARTICLE_MIST_CIRCLE, 0)
            set_mario_action(m, ACT_TANOOKI_FLY_KAK, 0)
        end
        m.marioBodyState.eyeState = MARIO_EYES_LOOK_DOWN
    else
        m.marioBodyState.eyeState = MARIO_EYES_DEAD
    end
    if stepResult == AIR_STEP_LANDED then
        return set_mario_action(m, ACT_FREEFALL_LAND, 0)
    end
    if stepResult == AIR_STEP_HIT_WALL then
        mario_bonk_reflection(m, 0)
        return set_mario_action(m, ACT_TANOOKI_FLY_KAK, 0)
    end
    smlua_anim_util_set_animation(m.marioObj, "kaktus_tanookifly")
    if m.input & INPUT_Z_PRESSED ~= 0 then
        return set_mario_action(m, ACT_GROUND_POUND, 0)
    elseif m.input & INPUT_B_PRESSED ~= 0 then
        m.vel.y = 45
        m.forwardVel = 48
        return set_mario_action(m, ACT_BRELLA_SPIN, 0)
    end

    m.actionTimer = m.actionTimer + 1
end

function act_tanooki_fly_kak_gravity(m)
    m.vel.y = math.max(m.vel.y - 3, -50)
end

hook_mario_action(ACT_TANOOKI_FLY_KAK, {every_frame = act_tanooki_fly_kak, gravity = act_tanooki_fly_kak_gravity})

function act_shroom_dash(m)
    local stepResult = common_air_action_step(m, ACT_FREEFALL_LAND, CHAR_ANIM_BACKFLIP, ACT_FLAG_AIR)
    m.faceAngle.y = m.intendedYaw - approach_s32(limit_angle(m.intendedYaw - m.faceAngle.y), 0, 0x400, 0x400)
    set_mario_particle_flags(m, PARTICLE_DUST, 0)
    if m.prevAction == ACT_WALKING then
        smlua_anim_util_set_animation(m.marioObj, "triplejumpspin")
    end
    if m.input & INPUT_Z_PRESSED ~= 0 then
        set_mario_action(m, ACT_GROUND_POUND, 0)
    end
end
hook_mario_action(ACT_SHROOM_DASH, act_shroom_dash)

-- BRELLA ACTIONS

function act_brella_float(m)
    local anim = CHAR_ANIM_HANG_ON_CEILING
    
    m.faceAngle.y = m.intendedYaw - approach_s32(limit_angle(m.intendedYaw - m.faceAngle.y), 0, 0x200, 0x200)
    m.marioBodyState.eyeState = MARIO_EYES_LOOK_DOWN
    m.peakHeight = m.pos.y -- no fall sound

    if m.character.type == CT_LUIGI then
        m.particleFlags = m.particleFlags | PARTICLE_DUST
        anim = CHAR_ANIM_SLOW_LONGJUMP
    else
        m.particleFlags = m.particleFlags | PARTICLE_SPARKLES
        m.marioBodyState.handState = MARIO_HAND_PEACE_SIGN
    end

    local stepResult = common_air_action_step(m, ACT_FREEFALL_LAND, anim, AIR_STEP_CHECK_LEDGE_GRAB)
    --[[
    if m.vel.y < 0 then
        m.vel.y = math.lerp(m.vel.y, -m.actionTimer/300, 0.1)
    elseif m.floor.type == SURFACE_VERTICAL_WIND then -- updraft
        m.vel.y = m.vel.y + 1
    else
        m.vel.y = m.vel.y + 3 -- lets you bounce off goombas
    end
    ]]
    if m.forwardVel > 40 then
        m.forwardVel = m.forwardVel - 1
    end
    if stepResult == AIR_STEP_LANDED then
        set_mario_action(m, ACT_FREEFALL_LAND, 0)
    end
    if stepResult == AIR_STEP_HIT_WALL and m.forwardVel ~= 0 then
        mario_bonk_reflection(m, 1)
        set_mario_action(m, ACT_BRELLA_FLOAT, 0)
        m.actionTimer = 10
    end
    if m.input & INPUT_A_DOWN == 0 then
        set_mario_action(m, ACT_FREEFALL, 0)
    end
    if m.input & INPUT_Z_PRESSED ~= 0 then
        set_mario_action(m, ACT_GROUND_POUND, 0)
    elseif m.input & INPUT_B_PRESSED ~= 0 then
        set_mario_action(m, ACT_BRELLA_SPIN, 0)
        m.vel.y = 45
        m.forwardVel = 48
    end
    if m.actionTimer > 35 then
        m.vel.y = m.vel.y * 1.02
    end
    m.actionTimer = m.actionTimer + 1
    return false
end

function act_brella_float_gravity(m)
    if m.floor.type == SURFACE_VERTICAL_WIND then -- updraft
        m.vel.y = math.min(m.vel.y + 1, 50)
        m.actionTimer = 0
    else
        m.vel.y = math.lerp(m.vel.y, -m.actionTimer*0.1 - 0.5, 0.1)
    end
    return false
end


hook_mario_action(ACT_BRELLA_FLOAT, {every_frame = act_brella_float, gravity = act_brella_float_gravity})

function act_brella_jump(m)
    local e = gStateExtras[m.playerIndex]
    local anim = CHAR_ANIM_HANG_ON_CEILING

    m.marioBodyState.eyeState = MARIO_EYES_LOOK_DOWN
    m.vel.y = m.vel.y + 2

    if m.character.type == CT_LUIGI then
        anim = CHAR_ANIM_DOUBLE_JUMP_RISE
    else
        m.marioBodyState.handState = MARIO_HAND_PEACE_SIGN
    end

    local stepResult = common_air_action_step(m, ACT_FREEFALL_LAND, anim, AIR_STEP_CHECK_LEDGE_GRAB)

    if m.vel.y > 10 then
        m.particleFlags = m.particleFlags | PARTICLE_DUST
    end

    if m.actionTimer == 0 then
        play_character_sound(m, CHAR_SOUND_YAHOO)
        m.particleFlags = m.particleFlags | PARTICLE_MIST_CIRCLE
        m.vel.y = 50
        e.rotAngle = m.faceAngle.y
    end
    if m.vel.y < 0 then
        if m.input & INPUT_A_DOWN ~= 0 then
            set_mario_action(m, ACT_BRELLA_FLOAT, 0)
            e.canBrella = false
        else
            set_mario_action(m, ACT_FREEFALL, 0)
        end
    end

    if m.input & INPUT_B_PRESSED ~= 0 then
        set_mario_action(m, ACT_BRELLA_SPIN, 0)
        m.vel.y = 45
        m.forwardVel = 48
    end

    e.rotAngle = e.rotAngle + (m.vel.y * 200)
    m.marioObj.header.gfx.angle.y = e.rotAngle
    
    m.actionTimer = m.actionTimer + 1
    return false
end
hook_mario_action(ACT_BRELLA_JUMP, act_brella_jump)

function act_brella_pound(m)
    local e = gStateExtras[m.playerIndex]
    local stepResult = common_air_action_step(m, ACT_GROUND_POUND_LAND, CHAR_ANIM_START_HANDSTAND, AIR_STEP_NONE)
    smlua_anim_util_set_animation(m.marioObj, "brella_pound")
    m.faceAngle.y = m.intendedYaw - approach_s32(limit_angle(m.intendedYaw - m.faceAngle.y), 0, 0x200, 0x200)
    m.marioBodyState.handState = MARIO_HAND_PEACE_SIGN
    m.marioBodyState.eyeState = MARIO_EYES_DEAD
    m.peakHeight = m.pos.y
    if m.actionTimer == 1 then
        e.rotAngle = m.faceAngle.y
    end
    if m.vel.y > -75 then --Speeding up the fall -Kaktus
        m.vel.y = m.vel.y - 0.7
    end
    if m.marioObj.header.gfx.animInfo.animFrame < 5 then --small jump at the start of the anim -Kaktus
        m.vel.y = 35
    end
    if m.marioObj.header.gfx.animInfo.animFrame == 3 then
        play_sound(SOUND_ACTION_KEY_SWISH, m.marioObj.header.gfx.cameraToObject)
    end
    if m.input & INPUT_B_PRESSED ~= 0 then
        set_mario_action(m, ACT_BRELLA_SPIN, 0)
        m.vel.y = 45
        m.forwardVel = 48
    end
    if m.forwardVel > 75 then --slow down! -Kaktus
    m.forwardVel = m.forwardVel - 1
    end

    if m.vel.y < 0 then
        e.rotAngle = e.rotAngle + (m.vel.y * -100)
        if m.vel.y < -15 then
            m.particleFlags = m.particleFlags | PARTICLE_DUST
        end
    end
    m.marioObj.header.gfx.angle.y = e.rotAngle

    m.actionTimer = m.actionTimer + 1
    return 0
end
hook_mario_action(ACT_BRELLA_POUND, act_brella_pound)

function act_brella_spin(m)
    local e = gStateExtras[m.playerIndex]
    local anim = CHAR_ANIM_SKID_ON_GROUND
    m.faceAngle.y = m.intendedYaw - approach_s32(limit_angle(m.intendedYaw - m.faceAngle.y), 0, 0x20, 0x20)

    if m.character.type == CT_LUIGI then
        anim = CHAR_ANIM_TWIRL
        m.marioBodyState.handState = MARIO_HAND_OPEN
    else
        m.marioBodyState.handState = MARIO_HAND_PEACE_SIGN
        m.marioBodyState.eyeState = MARIO_EYES_DEAD
    end

    local stepResult = common_air_action_step(m, ACT_FREEFALL_LAND, anim, AIR_STEP_NONE)

    if m.forwardVel > 75 then --slow down! -Kaktus
        m.forwardVel = m.forwardVel - 1
    end

    e.rotAngle = e.rotAngle + (m.forwardVel * 200)
    m.marioObj.header.gfx.angle.y = e.rotAngle
end
hook_mario_action(ACT_BRELLA_SPIN, act_brella_spin)

function act_kak_long_jump(m)
    local e = gStateExtras[m.playerIndex]
    local stepResult = common_air_action_step(m, ACT_LONG_JUMP_LAND, CHAR_ANIM_FAST_LONGJUMP, AIR_STEP_HIT_WALL)
    --m.faceAngle.y = m.intendedYaw - approach_s32(limit_angle(m.intendedYaw - m.faceAngle.y), 0, 0x20, 0x20)
    -- if m.actionTimer < 0 then
    --     m.vel.y = 26
    --     m.forwardVel = 46
    -- end
    if m.actionTimer < 1 then
        set_anim_to_frame(m, 1)
    end
    m.actionTimer = m.actionTimer + 1
    m.vel.y = m.vel.y + 0.45
    m.forwardVel = m.forwardVel + 1
    if m.forwardVel > 50 then
        m.forwardVel = m.forwardVel - 0.9
    end
end
hook_mario_action(ACT_KAK_LONG_JUMP, act_kak_long_jump)

--isikle actions

function act_isikle_pound(m)
    local e = gStateExtras[m.playerIndex]
    local stepResult = common_air_action_step(m, ACT_GROUND_POUND_LAND, CHAR_ANIM_GROUND_POUND, AIR_STEP_NONE)
    m.marioBodyState.eyeState = MARIO_EYES_DEAD
    if m.actionTimer == 0 then
        m.vel.y = 45
    end
    m.vel.y = m.vel.y - 2
        e.rotAngle = e.rotAngle + 5000
    m.marioObj.header.gfx.angle.y = e.rotAngle

    if m.input & INPUT_B_PRESSED ~= 0 and e.canIsikleDrill == true then
        set_mario_action(m, ACT_ISIKLE_DRILL_AIR, 0)
        m.actionTimer = -1
    end

    m.actionTimer = m.actionTimer + 1
    return false
end
hook_mario_action(ACT_ISIKLE_POUND, act_isikle_pound)

function act_isikle_hammer_spin(m)
    local e = gStateExtras[m.playerIndex]
    local stepResult = common_air_action_step(m, ACT_GROUND_POUND_LAND, CHAR_ANIM_FORWARD_SPINNING, AIR_STEP_NONE)
    m.faceAngle.y = m.intendedYaw - approach_s32(limit_angle(m.intendedYaw - m.faceAngle.y), 0, 0x40, 0x40)
    m.marioBodyState.eyeState = MARIO_EYES_DEAD
    if m.actionTimer == 0 then
        m.vel.y = 45
        m.forwardVel = 50
    end

    if m.input & INPUT_Z_PRESSED ~= 0 then
        set_mario_action(m, ACT_ISIKLE_POUND, 0)
        m.actionTimer = -1
    end

    m.actionTimer = m.actionTimer + 1
end
hook_mario_action(ACT_ISIKLE_HAMMER_SPIN, act_isikle_hammer_spin)

function act_isikle_drill_air(m)
    local e = gStateExtras[m.playerIndex]
    local stepResult = common_air_action_step(m, ACT_BRAKING, CHAR_ANIM_WING_CAP_FLY, AIR_STEP_HIT_WALL)
    m.faceAngle.y = m.intendedYaw - approach_s32(limit_angle(m.intendedYaw - m.faceAngle.y), 0, 0x40, 0x40)
    m.marioBodyState.eyeState = MARIO_EYES_DEAD
    m.forwardVel = 60
    m.vel.y = -5
    e.canIsikleDrill = false

    if m.actionTimer > 17 then
        set_mario_action(m, ACT_FREEFALL, 0)
        m.vel.y = 0
    end

    m.actionTimer = m.actionTimer + 1

    e.rotAngle = e.rotAngle + 7000
    m.marioObj.header.gfx.angle.z = e.rotAngle

    if m.actionTimer % 5 == 0 then
        play_sound(SOUND_ACTION_SPIN, m.marioObj.header.gfx.cameraToObject)
    end

end
hook_mario_action(ACT_ISIKLE_DRILL_AIR, act_isikle_drill_air)
-- i am so motherfucking stupid
-- No you're not, you are very smart and an awesome human being <3
-- thanks jer :)

--charSelect.character_hook_moveset(CT_KAKTUS, HOOK_ON_HUD_RENDER,
--function ()
--    local m = gMarioStates[0]
--    djui_hud_set_resolution(RESOLUTION_N64)
--if m.forwardVel > 50 then djui_hud_render_texture(SPEEDOMETER_MAX, 20, 35, 1, 1)
--end
--if m.forwardVel > 40 and m.forwardVel < 49 and (m.flags & MARIO_METAL_CAP) ~= 0 then djui_hud_render_texture(SPEEDOMETER_3, 20, 35, 1, 1)
--end
--if m.forwardVel > 29 and m.forwardVel < 40 and (m.flags & MARIO_METAL_CAP) ~= 0 then djui_hud_render_texture(SPEEDOMETER_2, 20, 35, 1, 1)
--end
--if m.forwardVel > 0 and m.forwardVel < 30 and (m.flags & MARIO_METAL_CAP) ~= 0 then djui_hud_render_texture(SPEEDOMETER_1, 20, 35, 1, 1)
--end
--if m.forwardVel == 0 and (m.flags & MARIO_METAL_CAP) ~= 0 then djui_hud_render_texture(SPEEDOMETER_0, 20, 35, 1, 1)
--end
--if m.forwardVel < 0 and (m.flags & MARIO_METAL_CAP) ~= 0 then djui_hud_render_texture(SPEEDOMETER_0, 20, 35, 1, 1)
--end
--end)
--charSelect.character_hook_moveset(CT_KAKTUS, HOOK_ON_HUD_RENDER_BEHIND,
--function ()
--    local m = gMarioStates[0]
--djui_hud_set_resolution(RESOLUTION_N64)
--if (m.flags & MARIO_METAL_CAP) ~= 0 then djui_hud_render_texture(SPEEDOMETER_0, 20, 35, 1, 1)
--end
--end)

function kaktus_before_set_action(m, inc)
    local e = gStateExtras[m.playerIndex]
    local np = gNetworkPlayers[m.playerIndex]
    if inc == ACT_DOUBLE_JUMP then
        return ACT_JUMP
    end
    if inc == ACT_TRIPLE_JUMP then
        return ACT_JUMP
    end
    if inc == ACT_GROUND_POUND then
        return ACT_BRELLA_POUND
    end
    if inc == ACT_SLIDE_KICK then
        m.vel.y = 65
        m.forwardVel = 55
        return ACT_BUTT_SLIDE_AIR
    end
    if inc == ACT_FLYING then
        return ACT_TANOOKI_FLY_KAK
    end
    if inc == ACT_BRELLA_SPIN then
        play_character_sound(m, CHAR_SOUND_HOOHOO)
    end
    if inc == ACT_BACKFLIP then
        m.pos.y = m.pos.y + 10
        return ACT_BRELLA_JUMP
    end
    if inc == ACT_JUMP and m.prevAction == ACT_JUMP then
        m.vel.y = 0
        smlua_anim_util_set_animation(m.marioObj, "triplejumpspin")
    end
    if inc == ACT_JUMP and m.forwardVel > 40 and (m.flags & MARIO_WING_CAP) ~= 0 then
        m.vel.y = 50
        e.flyFloor = m.floorHeight
        audio_sample_play(KAKTUS_TAIL, m.pos, 1)
        return ACT_TANOOKI_FLY_KAK
    end
    if inc == ACT_DIVE and (m.flags & MARIO_METAL_CAP) ~= 0 then
        set_mario_particle_flags(m, PARTICLE_VERTICAL_STAR, 0)
        m.forwardVel = 65
        return ACT_SHROOM_DASH
    end
    if inc == ACT_MOVE_PUNCHING and (m.flags & MARIO_METAL_CAP) ~= 0 then
        set_mario_particle_flags(m, PARTICLE_VERTICAL_STAR, 0)
        m.forwardVel = 65
        return ACT_SHROOM_DASH
    end
    if inc == ACT_BRELLA_FLOAT and (m.flags & MARIO_METAL_CAP) ~= 0 then
        return ACT_FREEFALL
    end
    if inc == ACT_WATER_PLUNGE and m.controller.buttonDown & B_BUTTON ~= 0 and (m.flags & MARIO_METAL_CAP) ~= 0 then
        smlua_anim_util_set_animation(m.marioObj, "triplejumpspin")
        m.vel.y = 60
        m.forwardVel = 65
        return ACT_SHROOM_DASH
    end
    if inc == ACT_FREEFALL and m.controller.buttonDown & B_BUTTON ~= 0 and (m.flags & MARIO_METAL_CAP) ~= 0 then
        smlua_anim_util_set_animation(m.marioObj, "triplejumpspin")
        m.vel.y = 60
        m.forwardVel = 65
        return ACT_SHROOM_DASH
    end
    if inc == ACT_START_CROUCHING then
        return ACT_CROUCHING
    end
    if inc == ACT_STOP_CROUCHING then
        return ACT_IDLE
    end
    if inc == ACT_BUTT_SLIDE_STOP and m.action == ACT_GROUND_POUND_LAND then
        return ACT_IDLE
    end
end

function kaktus_set_action(m)
    if m.action == ACT_BRELLA_SPIN then
        play_sound(SOUND_ACTION_TWIRL, m.marioObj.header.gfx.cameraToObject)
    end
    if m.action == ACT_SIDE_FLIP then
        m.vel.y = 55
    end
    if m.action == ACT_KAK_LONG_JUMP then
        m.vel.y = 40
        m.forwardVel = m.forwardVel + 30
    end
    if m.action == ACT_BUTT_SLIDE_AIR and m.prevAction == ACT_CROUCH_SLIDE then
        play_sound(SOUND_ACTION_TWIRL, m.marioObj.header.gfx.cameraToObject)
    end
    if m.action == ACT_GROUND_POUND then
        set_mario_action(m, ACT_BRELLA_POUND, 0)
    end
end

local eyeStateTable = { -- Epic Eye States Table of Evil Swag - Jer
    [CHAR_ANIM_FIRST_PUNCH] = MARIO_EYES_DEAD,
    [CHAR_ANIM_SECOND_PUNCH] = MARIO_EYES_DEAD,
    [CHAR_ANIM_AIR_KICK] = MARIO_EYES_DEAD,
    [CHAR_ANIM_GROUND_KICK] = MARIO_EYES_DEAD,
    [CHAR_ANIM_FIRST_PUNCH_FAST] = MARIO_EYES_DEAD,
    [CHAR_ANIM_SECOND_PUNCH_FAST] = MARIO_EYES_DEAD,
    [CHAR_ANIM_SLIDE_KICK] = MARIO_EYES_DEAD,
    [CHAR_ANIM_DROWNING_PART1] = MARIO_EYES_DEAD,
    [CHAR_ANIM_DROWNING_PART2] = MARIO_EYES_DEAD,
    [CHAR_ANIM_WALK_PANTING] = MARIO_EYES_DEAD,
    [CHAR_ANIM_FAST_LEDGE_GRAB] = MARIO_EYES_DEAD,
    [CHAR_ANIM_SLOW_LEDGE_GRAB] = MARIO_EYES_DEAD,
    [CHAR_ANIM_IDLE_ON_LEDGE] = MARIO_EYES_LOOK_DOWN,
    [CHAR_ANIM_SOFT_FRONT_KB] = MARIO_EYES_LOOK_DOWN,
    [CHAR_ANIM_SOFT_BACK_KB] = MARIO_EYES_LOOK_DOWN,
    [CHAR_ANIM_GROUND_POUND_LANDING] = MARIO_EYES_DEAD,
    [CHAR_ANIM_GROUND_POUND] = MARIO_EYES_LOOK_DOWN,
    [CHAR_ANIM_START_GROUND_POUND] = MARIO_EYES_LOOK_DOWN,
    [CHAR_ANIM_TRIPLE_JUMP_GROUND_POUND] = MARIO_EYES_LOOK_DOWN,
    [CHAR_ANIM_FALL_OVER_BACKWARDS] = MARIO_EYES_DEAD,
    [CHAR_ANIM_BACKWARD_AIR_KB] = MARIO_EYES_DEAD,
    [CHAR_ANIM_TIPTOE] = MARIO_EYES_LOOK_DOWN,
    [CHAR_ANIM_CROUCHING] = MARIO_EYES_LOOK_LEFT,
    [CHAR_ANIM_START_CROUCHING] = MARIO_EYES_LOOK_DOWN,
    [CHAR_ANIM_FIRE_LAVA_BURN] = MARIO_EYES_DEAD,
}

---@param m MarioState
function kaktus_update(m)
    local e = gStateExtras[m.playerIndex]

    if brellaActions[m.action] and m.vel.y < 0 and m.input & INPUT_A_PRESSED ~= 0 and e.canBrella and (m.flags & MARIO_WING_CAP) == 0 and (m.flags & MARIO_METAL_CAP) == 0 then
        set_mario_action(m, ACT_BRELLA_FLOAT, 0)
        set_mario_particle_flags(m, PARTICLE_MIST_CIRCLE, 0)
        e.canBrella = false
        -- Fix Camera from acts like Cannon
        if m.playerIndex == 0 then
            if (not camera_config_is_free_cam_enabled()) then
                set_camera_mode(m.area.camera, m.area.camera.defMode, 1);
            else
                m.area.camera.mode = CAMERA_MODE_NEWCAM;
                gLakituState.mode = CAMERA_MODE_NEWCAM;
            end
        end
    end
    if m.marioObj.header.gfx.animInfo.animID == CHAR_ANIM_FAST_LONGJUMP and m.marioObj.header.gfx.animInfo.animFrame < 0 then
        m.vel.y = m.vel.y - 0.35
    end
    if m.pos.y == m.floorHeight then
        e.canBrella = true
    end
    if m.action == ACT_CROUCHING then
        --spawn_non_sync_object(id_bhvSparkleSpawn, E_MODEL_NONE, m.pos.x, m.pos.y, m.pos.z, nil)
        set_mario_particle_flags(m, PARTICLE_SPARKLES, 0)
        smlua_anim_util_set_animation(m.marioObj, 'kaktus_crouch')
    end
    if m.action == ACT_CROUCH_SLIDE then
        smlua_anim_util_set_animation(m.marioObj, 'kaktus_crouch_slide')
    end
    if m.action == ACT_TANOOKI_FLY_KAK and (m.flags & MARIO_WING_CAP) == 0 then
        set_mario_action(m, ACT_FREEFALL, 0)
    end
    if (m.flags & MARIO_WING_CAP) ~= 0 then
        if m.input & INPUT_A_PRESSED ~= 0 and brellaActions[m.action] and m.vel.y < 0 then
            audio_sample_play(KAKTUS_TAIL, m.pos, 3)
            m.vel.y = 0
        end
    end
    if m.action == ACT_WALKING and m.forwardVel > 45 and m.forwardVel < 55 then
        m.forwardVel = m.forwardVel + 0.965
        smlua_anim_util_set_animation(m.marioObj, "kaktus_fast_run")
        m.marioBodyState.eyeState = MARIO_EYES_DEAD
    end
    if m.action == ACT_WALKING and m.forwardVel > 35 and m.forwardVel < 40 and (m.flags & MARIO_METAL_CAP) == 0 then
        m.forwardVel = m.forwardVel + 1.01
    end
    if m.action == ACT_WALKING and m.forwardVel > 32 and m.forwardVel < 32.1 and (m.flags & MARIO_METAL_CAP) == 0 then
        m.forwardVel = 40
    end
    if m.action == ACT_WALKING and m.forwardVel > 35 and m.forwardVel < 60 and (m.flags & MARIO_METAL_CAP) ~= 0 then
        m.forwardVel = m.forwardVel + 1.01
    end
    if m.action == ACT_WALKING and m.forwardVel > 32 and m.forwardVel < 32.1 and (m.flags & MARIO_METAL_CAP) ~= 0 then
        m.forwardVel = 40
        set_mario_particle_flags(m, PARTICLE_VERTICAL_STAR, 0)
    end
    if m.action == ACT_WALKING and m.forwardVel > 35 then
        set_mario_particle_flags(m, PARTICLE_DUST, 0)
        obj_get_temp_spawn_particles_info(E_MODEL_SMOKE)
    end
    --if m.action == ACT_WALKING and m.forwardVel > 45 then
        --smlua_anim_util_set_animation(m.marioObj, "kak_run_fast_temp")
    --end
    if brellaHandActions[m.action] and m.prevAction ~= ACT_CROUCHING then
        m.marioBodyState.handState = MARIO_HAND_PEACE_SIGN
    end
    if m.action == ACT_PUNCHING and m.prevAction ~= ACT_CROUCHING then
        m.marioBodyState.handState = MARIO_HAND_PEACE_SIGN
    end
    -- quicksand invulnerability
    if is_kaktus() and m.floor.type == SURFACE_QUICKSAND then
        m.floor.type = SURFACE_CLASS_DEFAULT
    end
    if is_kaktus() and m.floor.type == SURFACE_DEEP_QUICKSAND then
        m.floor.type = SURFACE_CLASS_DEFAULT
    end
    if is_kaktus() and m.floor.type == SURFACE_MOVING_QUICKSAND then
        m.floor.type = SURFACE_CLASS_DEFAULT
    end
    if is_kaktus() and m.floor.type == SURFACE_SHALLOW_QUICKSAND then
        m.floor.type = SURFACE_CLASS_DEFAULT
    end
    if is_kaktus() and m.floor.type == SURFACE_DEEP_MOVING_QUICKSAND then
        m.floor.type = SURFACE_CLASS_DEFAULT
    end
    if is_kaktus() and m.floor.type == SURFACE_SHALLOW_MOVING_QUICKSAND then
        m.floor.type = SURFACE_CLASS_DEFAULT
    end
    if is_kaktus() and m.floor.type == SURFACE_MOVING_QUICKSAND then
        m.floor.type = SURFACE_CLASS_DEFAULT
    end
    if is_kaktus() and m.floor.type == SURFACE_INSTANT_MOVING_QUICKSAND then
        m.floor.type = SURFACE_CLASS_DEFAULT
    end
    if is_kaktus() and m.floor.type == SURFACE_INSTANT_QUICKSAND then
        m.floor.type = SURFACE_CLASS_DEFAULT
    end
    if m.action == ACT_SUPERJUMP_CROUCH_KAK then
        obj_act_squished(1.5)
    end
    if m.action == ACT_GROUND_POUND_LAND and m.controller.buttonPressed & A_BUTTON ~= 0 then
        set_mario_action(m, ACT_BRELLA_JUMP, 0)
        m.vel.y = 40
        m.forwardVel = 30
    end
    if m.action == ACT_GROUND_POUND_LAND and m.controller.buttonPressed & B_BUTTON ~= 0 then
        set_mario_action(m, ACT_DIVE, 0)
        m.vel.y = 30
        m.forwardVel = 50
        m.faceAngle.y = m.intendedYaw
    end
    if m.action == ACT_GROUND_POUND_LAND and m.marioObj.header.gfx.animInfo.animFrame == 0 then
        m.particleFlags = m.particleFlags | PARTICLE_MIST_CIRCLE
        m.particleFlags = m.particleFlags | PARTICLE_HORIZONTAL_STAR
    end
    if m.action == ACT_TRIPLE_JUMP and m.controller.buttonPressed & A_BUTTON ~= 0 and m.controller.buttonDown & Z_TRIG == 0 then
        set_mario_action(m, ACT_JUMP, 0)
        m.vel.y = 45
    end
    if m.action == ACT_JUMP and m.prevAction == ACT_TRIPLE_JUMP then
        smlua_anim_util_set_animation(m.marioObj, "kakbouncejump")
    end
    if m.action == ACT_BUTT_SLIDE and m.input & INPUT_A_PRESSED ~= 0 and m.prevAction == ACT_BUTT_SLIDE_AIR then
        set_mario_action(m, ACT_JUMP, 0)
    end
    if m.action == ACT_JUMP and smlua_anim_util_get_current_animation_name(m.marioObj) == "kakbouncejump" and m.marioObj.header.gfx.animInfo.animFrame == 1 and m.prevAction == ACT_TRIPLE_JUMP then
        play_character_sound(m, CHAR_SOUND_HOOHOO)
    end
    if m.action == ACT_TRIPLE_JUMP and m.controller.buttonDown & Z_TRIG ~= 0 and m.prevAction == ACT_GROUND_POUND_LAND then
        set_mario_particle_flags(m, ACTIVE_PARTICLE_SPARKLES, 0)
    end
    if m.action == ACT_WALKING and m.forwardVel > 35 then
        m.marioBodyState.torsoAngle.x = 20
    end
    if m.action == ACT_WALKING and m.forwardVel < 35 then
        m.marioBodyState.torsoAngle.x = 0
        m.marioBodyState.torsoAngle.z = 0
    end
    if m.action == ACT_WALKING and m.forwardVel > 33 and m.forwardVel < 44 then
        m.marioBodyState.eyeState = MARIO_EYES_LOOK_DOWN
    end
    if m.action == ACT_WALKING and m.forwardVel > 49 then
        m.marioBodyState.eyeState = MARIO_EYES_LOOK_DOWN
    end
    if m.action == ACT_TRIPLE_JUMP then
        smlua_anim_util_set_animation(m.marioObj, "kakroll")
    end
    if m.action == ACT_GROUND_POUND and m.controller.buttonPressed & B_BUTTON ~= 0 and m.flags & MARIO_WING_CAP ~= 0 then
        set_mario_action(m, ACT_VERTICAL_WIND, 0)
        m.vel.y = 65
        m.faceAngle.y = m.intendedYaw
    end
    if m.action == ACT_FLYING_TRIPLE_JUMP and m.controller.buttonDown & A_BUTTON ~= 0 then
        m.vel.y = 0
    end
    if m.action == ACT_BUTT_SLIDE_AIR and m.prevAction == ACT_CROUCH_SLIDE then
        smlua_anim_util_set_animation(m.marioObj, "GroundPound")
    end
        if m.action == ACT_BUTT_SLIDE_AIR and m.prevAction == ACT_GROUND_POUND then
        smlua_anim_util_set_animation(m.marioObj, "GroundPound")
    end
    if m.action == ACT_BUTT_SLIDE_AIR and m.vel.y > 50 then
        m.vel.y = 0
    end
    if (m.action & ACT_GROUP_MASK) == ACT_GROUP_SUBMERGED then
        m.health = m.health - 1.5
    end
    -- Firstie anim
    if m.action == ACT_WALL_KICK_AIR and m.prevAction == ACT_AIR_HIT_WALL then
        smlua_anim_util_set_animation(m.marioObj, "triplejumpspin")
        set_mario_particle_flags(m, PARTICLE_SPARKLES, 0)
    end
    -- CHANGING EYES
    if eyeStateTable[m.marioObj.header.gfx.animInfo.animID] ~= nil then
        m.marioBodyState.eyeState = eyeStateTable[m.marioObj.header.gfx.animInfo.animID]
    end
    


    
    -- you can get rid of anything in notes, the ones based on anim frames gotta stay tho - Jer

    --if (m.marioObj.header.gfx.animInfo.animID == CHAR_ANIM_STAR_DANCE and m.marioObj.header.gfx.animInfo.animID == CHAR_ANIM_FIRST_PUNCH ) or (m.marioObj.header.gfx.animInfo.animID == CHAR_ANIM_WATER_STAR_DANCE and m.marioObj.header.gfx.animInfo.animFrame > 68) then
    --    m.marioBodyState.eyeState = MARIO_EYES_LOOK_UP
    --end
    if m.marioObj.header.gfx.animInfo.animID == CHAR_ANIM_AIR_KICK and m.marioObj.header.gfx.animInfo.animFrame < 14 then
        m.marioBodyState.eyeState = MARIO_EYES_DEAD
    end
    if smlua_anim_util_get_current_animation_name(m.marioObj) == "kakbouncejump" then
        m.marioBodyState.eyeState = MARIO_EYES_BLINK
    end
    --if m.marioObj.header.gfx.animInfo.animID == CHAR_ANIM_FALL_OVER_BACKWARDS or m.marioObj.header.gfx.animInfo.animID == CHAR_ANIM_BACKWARD_AIR_KB then
    --    m.marioBodyState.eyeState = MARIO_EYES_DEAD
    --end
    --if m.marioObj.header.gfx.animInfo.animID == CHAR_ANIM_GROUND_POUND or m.marioObj.header.gfx.animInfo.animID == CHAR_ANIM_START_GROUND_POUND or m.marioObj.header.gfx.animInfo.animID == CHAR_ANIM_TRIPLE_JUMP_GROUND_POUND then
    --    m.marioBodyState.eyeState = MARIO_EYES_LOOK_DOWN
    --end
    --if m.marioObj.header.gfx.animInfo.animID == CHAR_ANIM_GROUND_POUND_LANDING then
    --    m.marioBodyState.eyeState = MARIO_EYES_DEAD
    --end
    --if m.marioObj.header.gfx.animInfo.animID == CHAR_ANIM_FIRST_PUNCH or m.marioObj.header.gfx.animInfo.animID == CHAR_ANIM_SECOND_PUNCH or m.marioObj.header.gfx.animInfo.animID == CHAR_ANIM_AIR_KICK or m.marioObj.header.gfx.animInfo.animID == CHAR_ANIM_GROUND_KICK or m.marioObj.header.gfx.animInfo.animID == CHAR_ANIM_FIRST_PUNCH_FAST or m.marioObj.header.gfx.animInfo.animID == CHAR_ANIM_SECOND_PUNCH_FAST or m.marioObj.header.gfx.animInfo.animID == CHAR_ANIM_SLIDE_KICK then
    --    m.marioBodyState.eyeState = MARIO_EYES_DEAD
    --end
    --if m.marioObj.header.gfx.animInfo.animID == CHAR_ANIM_DROWNING_PART1 or m.marioObj.header.gfx.animInfo.animID == CHAR_ANIM_DROWNING_PART2 then
    --    m.marioBodyState.eyeState = MARIO_EYES_DEAD
    --end
    if m.marioObj.header.gfx.animInfo.animID == CHAR_ANIM_TRIPLE_JUMP_LAND and m.marioObj.header.gfx.animInfo.animFrame < 20 then
        m.marioBodyState.eyeState = MARIO_EYES_CLOSED
    end
    if m.marioObj.header.gfx.animInfo.animID == CHAR_ANIM_STAR_DANCE and m.marioObj.header.gfx.animInfo.animFrame > 25 then
        m.marioBodyState.eyeState = MARIO_EYES_LOOK_UP
        m.marioBodyState.handState = MARIO_HAND_FISTS
    end
    --if m.marioObj.header.gfx.animInfo.animID == CHAR_ANIM_WALK_PANTING or m.marioObj.header.gfx.animInfo.animID == CHAR_ANIM_FAST_LEDGE_GRAB or m.marioObj.header.gfx.animInfo.animID == CHAR_ANIM_SLOW_LEDGE_GRAB then
    --    m.marioBodyState.eyeState = MARIO_EYES_DEAD
    --end
    --if m.marioObj.header.gfx.animInfo.animID == CHAR_ANIM_IDLE_ON_LEDGE then
    --    m.marioBodyState.eyeState = MARIO_EYES_LOOK_DOWN
    --end
    --if m.marioObj.header.gfx.animInfo.animID == CHAR_ANIM_FORWARD_KB or m.marioObj.header.gfx.animInfo.animID == CHAR_ANIM_BACKWARD_KB or m.marioObj.header.gfx.animInfo.animID == CHAR_ANIM_AIR_FORWARD_KB or m.marioObj.header.gfx.animInfo.animID == CHAR_ANIM_BACKWARD_AIR_KB or m.marioObj.header.gfx.animInfo.animID == CHAR_ANIM_WATER_FORWARD_KB or m.marioObj.header.gfx.animInfo.animID == CHAR_ANIM_BACKWARDS_WATER_KB or m.marioObj.header.gfx.animInfo.animID == CHAR_ANIM_SHOCKED then
    --    m.marioBodyState.eyeState = MARIO_EYES_DEAD
    --end
    --if m.marioObj.header.gfx.animInfo.animID == CHAR_ANIM_SOFT_FRONT_KB or m.marioObj.header.gfx.animInfo.animID == CHAR_ANIM_SOFT_BACK_KB then
    --    m.marioBodyState.eyeState = MARIO_EYES_LOOK_DOWN
    --end
end

--isikle
function isikle_update(m)
    local e = gStateExtras[m.playerIndex]
    if m.forwardVel < 20 and m.action == ACT_WALKING then
        m.marioBodyState.torsoAngle.z = 0
        m.marioBodyState.torsoAngle.x = -2500
    end
    if m.forwardVel > 20 and m.forwardVel < 27 and m.action == ACT_WALKING then
        m.marioBodyState.torsoAngle.x = -1200
    end
    if m.forwardVel > 28 and m.action == ACT_WALKING then
        m.marioBodyState.torsoAngle.x = 1000
    end
    if m.pos.y == m.floorHeight then
        e.canIsikleDrill = true
    end
end

function isikle_before_set_action(m, inc)
    local e = gStateExtras[m.playerIndex]
    if inc == ACT_DIVE and m.input & INPUT_A_DOWN ~= 0 then
        return ACT_ISIKLE_HAMMER_SPIN
    end
    if inc == ACT_JUMP_KICK and m.input & INPUT_A_DOWN ~= 0 and m.forwardVel > 5 then
        return ACT_ISIKLE_HAMMER_SPIN
    end
    if inc == ACT_GROUND_POUND then
        return ACT_ISIKLE_POUND
    end
end

function isikle_set_action(m)
    local e = gStateExtras[m.playerIndex]
    if m.action == ACT_GROUND_POUND_LAND then
        play_sound(SOUND_ACTION_METAL_HEAVY_LANDING, m.marioObj.header.gfx.cameraToObject)
    end
    
end

_G.charSelect.character_hook_moveset(CT_KAKTUS, HOOK_MARIO_UPDATE, kaktus_update)
_G.charSelect.character_hook_moveset(CT_KAKTUS, HOOK_ON_SET_MARIO_ACTION, kaktus_set_action)
_G.charSelect.character_hook_moveset(CT_KAKTUS, HOOK_BEFORE_SET_MARIO_ACTION, kaktus_before_set_action)
_G.charSelect.character_hook_moveset(CT_KAKTUS, HOOK_ON_HUD_RENDER_BEHIND, kaktus_hud)
_G.charSelect.character_hook_moveset(CT_KAKTUS, HOOK_ALLOW_HAZARD_SURFACE, kaktus_allow_hazard_surface)

--isikle
_G.charSelect.character_hook_moveset(CT_ISIKLE, HOOK_MARIO_UPDATE, isikle_update)
_G.charSelect.character_hook_moveset(CT_ISIKLE, HOOK_ON_SET_MARIO_ACTION, isikle_set_action)
_G.charSelect.character_hook_moveset(CT_ISIKLE, HOOK_BEFORE_SET_MARIO_ACTION, isikle_before_set_action)
