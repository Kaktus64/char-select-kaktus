---@diagnostic disable: undefined-global
if not _G.charSelectExists then return end

local function limit_angle(a)
    return (a + 0x8000) % 0x10000 - 0x8000
end

ACT_DASH = allocate_mario_action(ACT_GROUP_AIRBORNE|ACT_FLAG_ALLOW_VERTICAL_WIND_ACTION|ACT_FLAG_ATTACKING|ACT_FLAG_AIR)
ACT_SUPERJUMP_CROUCH_KAK = allocate_mario_action(ACT_GROUP_STATIONARY)
ACT_BRELLA_FLOAT = allocate_mario_action(ACT_GROUP_AIRBORNE | ACT_FLAG_AIR | ACT_FLAG_CONTROL_JUMP_HEIGHT)

function act_dash (m)
    smlua_anim_util_set_animation(m.marioObj, "triplejump")
    mario_set_forward_vel(m, 60)

    local stepResult = perform_air_step(m, 0)
    if stepResult == AIR_STEP_LANDED then --hitting the gound
        return set_mario_action(m, ACT_BRAKING, 0)
    elseif m.wall then
    m.faceAngle.y = m.faceAngle.y * -60
        mario_bonk_reflection(m, true)
    end
end
hook_mario_action(ACT_DASH, act_dash)

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
    [ACT_WALL_KICK_AIR] = true
}

function act_brella_float(m)
    m.particleFlags = m.particleFlags | PARTICLE_SPARKLES
    local stepResult = common_air_action_step(m, ACT_FREEFALL_LAND, CHAR_ANIM_HANG_ON_CEILING, AIR_STEP_CHECK_LEDGE_GRAB)
    m.faceAngle.y = m.intendedYaw - approach_s32(limit_angle(m.intendedYaw - m.faceAngle.y), 0, 0x200, 0x200)
    m.marioBodyState.handState = MARIO_HAND_PEACE_SIGN
    m.marioBodyState.eyeState = MARIO_EYES_LOOK_DOWN
    if m.actionTimer == 1 then
        m.vel.y = 0
    elseif m.actionTimer > 1 and m.vel.y > -5 then
        m.vel.y = m.vel.y - 1
    else
        m.vel.y = -5
    end
    if m.forwardVel > 50 then
    m.forwardVel = m.forwardVel - 1
    end
    if m.input & INPUT_A_DOWN == 0 then
        set_mario_action(m, ACT_FREEFALL, 0)
    end
    if stepResult == AIR_STEP_LANDED then
        set_mario_action(m, ACT_FREEFALL_LAND, 0)
    end

    m.actionTimer = m.actionTimer + 1
    return false
end
hook_mario_action(ACT_BRELLA_FLOAT, act_brella_float)


function add_moveset()

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

charSelect.character_hook_moveset(CT_KAKTUS, HOOK_BEFORE_SET_MARIO_ACTION,
function (m, inc)
local np = gNetworkPlayers[m.playerIndex]
if inc == ACT_DOUBLE_JUMP then
    return ACT_JUMP
end
if inc == ACT_TRIPLE_JUMP_LAND then
    return ACT_GROUND_POUND_LAND
end
if inc == ACT_QUICKSAND_JUMP_LAND then 
    m.vel.y = 30
    return ACT_JUMP
end
if inc == ACT_SLIDE_KICK then
    m.vel.y = 65
    m.forwardVel = 55
    return ACT_BUTT_SLIDE_AIR
end
if inc == ACT_JUMP and m.action == ACT_BUTT_SLIDE then
    return ACT_FORWARD_ROLLOUT
end
if inc == ACT_SIDE_FLIP then
    m.vel.y = 60
end
if inc == ACT_BACKFLIP then
    return ACT_GROUND_POUND_LAND
end
if inc == ACT_JUMP and m.prevAction == ACT_JUMP then
    m.vel.y = 0
    smlua_anim_util_set_animation(m.marioObj, "triplejumpspin")
end
end)
function kaktus_update(m)
    if brellaActions[m.action] and m.vel.y < 0 and m.input & INPUT_A_PRESSED ~= 0 then
        set_mario_action(m, ACT_BRELLA_FLOAT, 0)
        set_mario_particle_flags(m, PARTICLE_MIST_CIRCLE, 0)
    end
    if m.action == ACT_SUPERJUMP_CROUCH_KAK then
        obj_act_squished(1.5)
    end
    if m.action == ACT_HOLD_IDLE and m.controller.buttonPressed & L_TRIG ~= 0 then
        set_mario_action(m, ACT_HOLDING_BOWSER, 0)
    end
    if m.action == ACT_HOLD_HEAVY_IDLE and m.controller.buttonPressed & L_TRIG ~= 0 then
        set_mario_action(m, ACT_HOLDING_BOWSER, 0)
    end
    if m.action == ACT_CROUCHING and m.marioObj.header.gfx.animInfo.animFrame == 30 then
        set_mario_action(m, ACT_SUPERJUMP_CROUCH_KAK, 0)
    end
    if m.action == ACT_GROUND_POUND_LAND and m.controller.buttonPressed & B_BUTTON ~= 0 then
        set_mario_action(m, ACT_DIVE, 0)
        m.vel.y = 30
        m.forwardVel = 50
        m.faceAngle.y = m.intendedYaw
    end
    if m.action == ACT_TRIPLE_JUMP and m.controller.buttonPressed & A_BUTTON ~= 0 and m.controller.buttonDown & Z_TRIG == 0 then
        set_mario_action(m, ACT_JUMP, 0)
        m.vel.y = 45
    end
    if m.action == ACT_CROUCHING and m.controller.buttonPressed & B_BUTTON ~= 0 then
        set_mario_action(m, ACT_KAKROLL, 0)
    end
    if m.action == ACT_JUMP and m.prevAction == ACT_TRIPLE_JUMP then
        smlua_anim_util_set_animation(m.marioObj, "kakbouncejump")
    end
    if m.action == ACT_JUMP and smlua_anim_util_get_current_animation_name(m.marioObj) == "kakbouncejump" and m.marioObj.header.gfx.animInfo.animFrame == 1 and m.prevAction == ACT_TRIPLE_JUMP then
        play_character_sound(m, CHAR_SOUND_HOOHOO)
    end
    if m.action == ACT_GROUND_POUND_LAND and m.controller.buttonPressed & A_BUTTON ~= 0 and m.controller.buttonDown & Z_TRIG == 0 then
        set_mario_action(m, ACT_TRIPLE_JUMP, 0)
        set_mario_particle_flags(m, PARTICLE_HORIZONTAL_STAR, 0)
        m.vel.y = 50
        m.forwardVel = 60
        m.faceAngle.y = m.intendedYaw
    elseif m.action == ACT_GROUND_POUND_LAND and m.controller.buttonPressed & A_BUTTON ~= 0 and m.controller.buttonDown & Z_TRIG ~= 0 then
        set_mario_action(m, ACT_TRIPLE_JUMP, 0)
        set_mario_particle_flags(m, PARTICLE_HORIZONTAL_STAR, 0)
        m.vel.y = 65
        m.forwardVel = 40
        m.faceAngle.y = m.intendedYaw
    end
    if m.action == ACT_TRIPLE_JUMP and m.controller.buttonDown & Z_TRIG ~= 0 and m.prevAction == ACT_GROUND_POUND_LAND then
        set_mario_particle_flags(m, ACTIVE_PARTICLE_SPARKLES, 0)
    end
    if m.action == ACT_WALKING then
        m.marioBodyState.torsoAngle.x = 0
        m.marioBodyState.torsoAngle.z = 0
    end
    if m.action == ACT_TRIPLE_JUMP then
        smlua_anim_util_set_animation(m.marioObj, "kakroll")
    end
    if m.action == ACT_GROUND_POUND and m.controller.buttonPressed & B_BUTTON ~= 0 and m.flags & MARIO_WING_CAP == 0 then
        set_mario_action(m, ACT_SLIDE_KICK, 0)
        m.vel.y = 65
        m.faceAngle.y = m.intendedYaw
    end
    if m.action == ACT_GROUND_POUND and m.controller.buttonPressed & B_BUTTON ~= 0 and m.flags & MARIO_WING_CAP ~= 0 then
        set_mario_action(m, ACT_VERTICAL_WIND, 0)
        m.vel.y = 65
        m.faceAngle.y = m.intendedYaw
    end
    if m.action == ACT_DIVE and m.flags & MARIO_WING_CAP ~= 0 then
        set_mario_action(m, ACT_FLYING_TRIPLE_JUMP, 0)
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
    if m.quicksandDepth ~= 0 and m.action ~= ACT_QUICKSAND_DEATH then
        m.quicksandDepth = 0
    end
    if (m.action & ACT_GROUP_MASK) == ACT_GROUP_SUBMERGED then
        m.health = m.health - 1.5
    end
    -- CHANGING EYES
    if (m.marioObj.header.gfx.animInfo.animID == CHAR_ANIM_STAR_DANCE and m.marioObj.header.gfx.animInfo.animID == CHAR_ANIM_FIRST_PUNCH ) or (m.marioObj.header.gfx.animInfo.animID == CHAR_ANIM_WATER_STAR_DANCE and m.marioObj.header.gfx.animInfo.animFrame > 68) then
        m.marioBodyState.eyeState = MARIO_EYES_LOOK_UP
    end
    if m.marioObj.header.gfx.animInfo.animID == CHAR_ANIM_AIR_KICK and m.marioObj.header.gfx.animInfo.animFrame < 14 then
        m.marioBodyState.eyeState = MARIO_EYES_DEAD
    end
    if smlua_anim_util_get_current_animation_name(m.marioObj) == "kakbouncejump" then
        m.marioBodyState.eyeState = MARIO_EYES_BLINK
    end
    if m.marioObj.header.gfx.animInfo.animID == CHAR_ANIM_FALL_OVER_BACKWARDS or m.marioObj.header.gfx.animInfo.animID == CHAR_ANIM_BACKWARD_AIR_KB then
        m.marioBodyState.eyeState = MARIO_EYES_DEAD
    end
    if m.marioObj.header.gfx.animInfo.animID == CHAR_ANIM_GROUND_POUND or m.marioObj.header.gfx.animInfo.animID == CHAR_ANIM_START_GROUND_POUND or m.marioObj.header.gfx.animInfo.animID == CHAR_ANIM_TRIPLE_JUMP_GROUND_POUND then
        m.marioBodyState.eyeState = MARIO_EYES_LOOK_DOWN
    end
    if m.marioObj.header.gfx.animInfo.animID == CHAR_ANIM_GROUND_POUND_LANDING then
        m.marioBodyState.eyeState = MARIO_EYES_DEAD
    end
    if m.marioObj.header.gfx.animInfo.animID == CHAR_ANIM_FIRST_PUNCH or m.marioObj.header.gfx.animInfo.animID == CHAR_ANIM_SECOND_PUNCH or m.marioObj.header.gfx.animInfo.animID == CHAR_ANIM_AIR_KICK or m.marioObj.header.gfx.animInfo.animID == CHAR_ANIM_GROUND_KICK or m.marioObj.header.gfx.animInfo.animID == CHAR_ANIM_FIRST_PUNCH_FAST or m.marioObj.header.gfx.animInfo.animID == CHAR_ANIM_SECOND_PUNCH_FAST or m.marioObj.header.gfx.animInfo.animID == CHAR_ANIM_SLIDE_KICK then
        m.marioBodyState.eyeState = MARIO_EYES_DEAD
    end
    if m.marioObj.header.gfx.animInfo.animID == CHAR_ANIM_DROWNING_PART1 or m.marioObj.header.gfx.animInfo.animID == CHAR_ANIM_DROWNING_PART2 then
        m.marioBodyState.eyeState = MARIO_EYES_DEAD
    end
    if m.marioObj.header.gfx.animInfo.animID == CHAR_ANIM_TRIPLE_JUMP_LAND and m.marioObj.header.gfx.animInfo.animFrame < 20 then
        m.marioBodyState.eyeState = MARIO_EYES_CLOSED
    end
    if m.marioObj.header.gfx.animInfo.animID == CHAR_ANIM_WALK_PANTING or m.marioObj.header.gfx.animInfo.animID == CHAR_ANIM_FAST_LEDGE_GRAB or m.marioObj.header.gfx.animInfo.animID == CHAR_ANIM_SLOW_LEDGE_GRAB then
        m.marioBodyState.eyeState = MARIO_EYES_DEAD
    end
    if m.marioObj.header.gfx.animInfo.animID == CHAR_ANIM_IDLE_ON_LEDGE then
        m.marioBodyState.eyeState = MARIO_EYES_LOOK_DOWN
    end
    if m.marioObj.header.gfx.animInfo.animID == CHAR_ANIM_FORWARD_KB or m.marioObj.header.gfx.animInfo.animID == CHAR_ANIM_BACKWARD_KB or m.marioObj.header.gfx.animInfo.animID == CHAR_ANIM_AIR_FORWARD_KB or m.marioObj.header.gfx.animInfo.animID == CHAR_ANIM_BACKWARD_AIR_KB or m.marioObj.header.gfx.animInfo.animID == CHAR_ANIM_WATER_FORWARD_KB or m.marioObj.header.gfx.animInfo.animID == CHAR_ANIM_BACKWARDS_WATER_KB or m.marioObj.header.gfx.animInfo.animID == CHAR_ANIM_SHOCKED then
        m.marioBodyState.eyeState = MARIO_EYES_DEAD
    end
    if m.marioObj.header.gfx.animInfo.animID == CHAR_ANIM_SOFT_FRONT_KB or m.marioObj.header.gfx.animInfo.animID == CHAR_ANIM_SOFT_BACK_KB then
        m.marioBodyState.eyeState = MARIO_EYES_LOOK_DOWN
    end
end
_G.charSelect.character_hook_moveset(CT_KAKTUS, HOOK_MARIO_UPDATE, kaktus_update)
end