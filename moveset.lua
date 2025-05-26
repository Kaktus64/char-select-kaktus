---@diagnostic disable: undefined-global
if not _G.charSelectExists then return end
ACT_DASH = allocate_mario_action(ACT_GROUP_AIRBORNE|ACT_FLAG_ALLOW_VERTICAL_WIND_ACTION|ACT_FLAG_ATTACKING|ACT_FLAG_AIR)
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
ACT_SUPERJUMP_CROUCH_KAK = allocate_mario_action(ACT_GROUP_STATIONARY)
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
hook_mario_action(ACT_DASH, act_dash) 
hook_mario_action(ACT_SUPERJUMP_CROUCH_KAK, act_superjump_crouch_kak)
ACT_TAUNTKAK = allocate_mario_action(ACT_FLAG_CUSTOM_ACTION|ACT_FLAG_ALLOW_FIRST_PERSON)
function act_tauntkak (m)
    smlua_anim_util_set_animation(m.marioObj, "triplejump")
    mario_set_forward_vel(m, 0)
end
hook_mario_action(ACT_TAUNTKAK, act_tauntkak) 
function add_moveset()

-- a TON of coding help by the coop server, saul and charlie. thanks yall!

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

end)
function kaktus_update(m)
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
    if m.action == ACT_LONG_JUMP then
        set_mario_action (m, ACT_TRIPLE_JUMP, 0)
        m.vel.y = 50
        m.forwardVel = 52
    end
    if m.action == ACT_GROUND_POUND_LAND and m.controller.buttonPressed & A_BUTTON ~= 0 and m.controller.buttonDown & Z_TRIG == 0 then
        set_mario_action(m, ACT_TRIPLE_JUMP, 0)
        set_mario_particle_flags(m, PARTICLE_HORIZONTAL_STAR, 0)
        m.vel.y = 50
        m.forwardVel = 50
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