if not _G.charSelectExists then return end
ACT_DASH = allocate_mario_action(ACT_GROUP_AIRBORNE|ACT_FLAG_ALLOW_VERTICAL_WIND_ACTION|ACT_FLAG_ATTACKING|ACT_FLAG_AIR)
function act_dash (m)
    smlua_anim_util_set_animation(m.marioObj, "triplejumpspin")
    mario_set_forward_vel(m, 50)
    local stepResult = perform_air_step(m, 0)
        if stepResult == AIR_STEP_LANDED then --hitting the gound
            return set_mario_action(m, ACT_BRAKING, 0)
        elseif m.wall then
        m.faceAngle.y = m.faceAngle.y * -60
            mario_bonk_reflection(m, true)

end
end
ACT_KAKFLOAT = allocate_mario_action(ACT_FLAG_AIR|ACT_FLAG_ALLOW_VERTICAL_WIND_ACTION)
function act_kakfloat (m)
    sml
ACT_KAKROLL = allocate_mario_action(ACT_GROUP_MOVING|ACT_FLAG_ALLOW_VERTICAL_WIND_ACTION|ACT_FLAG_ATTACKING)
function act_kakroll (m)
    smlua_anim_util_set_animation(m.marioObj, "kakroll")
    mario_set_forward_vel(m, 50)
    local stepResult = perform_air_step(m, 0)
        if stepResult == AIR_STEP_LANDED and m.prevAction ~= ACT_KAKROLLFLOOR then --hitting the gound
        return set_mario_action(m, ACT_KAKROLLFLOOR, 0)
        elseif m.wall then
            m.vel.y = 0
            return set_mario_action(m, ACT_BACKWARD_AIR_KB, 0)
        elseif stepResult == AIR_STEP_LANDED and m.prevAction == ACT_KAKROLLFLOOR then
            return set_mario_action(m, ACT_BRAKING, 0)
        end
end
ACT_KAKROLLFLOOR = allocate_mario_action(ACT_GROUP_MOVING|ACT_FLAG_ALLOW_VERTICAL_WIND_ACTION|ACT_FLAG_ATTACKING)
function act_kakrollfloor (m)
    smlua_anim_util_set_animation(m.marioObj, "kakroll")
    m.forwardVel = m.forwardVel * 0.99
        if m.controller.buttonPressed & A_BUTTON ~= 0 then
            return set_mario_action(m, ACT_LONG_JUMP, 0)
        end
        local stepResult = perform_ground_step(m)
        if stepResult == GROUND_STEP_HIT_WALL then
            m.vel.y = 0
            return set_mario_action(m, ACT_BACKWARD_AIR_KB, 0)
        elseif stepResult == GROUND_STEP_LEFT_GROUND then
            set_mario_action(m, ACT_KAKROLL, 0)
        end
        if m.marioObj.header.gfx.animInfo.animFrame == 8 then
        return set_mario_action(m, ACT_BRAKING, 0)
        end
end
local function dialogs(m)
    local m = gMarioStates[0]
end
hook_mario_action(ACT_DASH, act_dash) 
hook_mario_action(ACT_KAKROLL, act_kakroll)
hook_mario_action(ACT_KAKROLLFLOOR, act_kakrollfloor)
function add_moveset()


charSelect.character_hook_moveset(CT_KAKTUS, HOOK_BEFORE_SET_MARIO_ACTION,
function (m, inc)
local np = gNetworkPlayers[m.playerIndex]
if inc == ACT_WATER_PLUNGE and m.action == ACT_DIVE and m.prevAction ~= ACT_DIVE then
    m.forwardVel = 50
    m.vel.y = 50
    return ACT_DIVE
end
if inc == ACT_SLIDE_KICK then
    return ACT_KAKROLL
end
if inc == ACT_KAKROLLFLOOR then
    set_anim_to_frame(m, 0)
    mario_set_forward_vel(m, 45)
end
--if inc ==  ACT_JUMP_KICK then
  --  return ACT_ROUNDHOUSE_KICK
--end
end)

function kaktus_update(m, i)
    


    for i = 0, MAX_PLAYERS - 1 do
        if is_kaktus() then
            set_dialog_override_color(62, 0, 84, 150, 255, 255, 255, 255)
        else 
            reset_dialog_override_color()
        end
    
    end

    --if m.action == ACT_DIVE and m.prevAction == ACT_WALKING then
        --set_mario_action(m, ACT_FORWARD_ROLLOUT, 0)
        --m.forwardVel = m.forwardVel * 1.2
        --m.faceAngle.y = m.intendedYaw
    --end
    if m.action == ACT_START_SLEEPING then
        set_mario_action(m, ACT_IDLE, 0)
    end
    if (m.action & ACT_GROUP_MASK) == ACT_GROUP_SUBMERGED then
        m.health = m.health - 1.5
    end
    if m.action == ACT_GROUND_POUND and m.controller.buttonPressed & B_BUTTON ~= 0 then
        set_mario_particle_flags(m, PARTICLE_VERTICAL_STAR, 0)
        set_mario_action(m, ACT_KAKROLL, 0)
        set_anim_to_frame(m, 0)
        m.forwardVel = 50
        m.vel.y = 0
    end
    --if m.action == ACT_FORWARD_ROLLOUT and m.prevAction == ACT_DIVE_SLIDE and m.controller.buttonPressed & A_BUTTON ~= 0 then
       -- set_mario_action(m, ACT_BACKFLIP, 0)
        --m.forwardVel = 30
        --m.vel.y = 30
    --end
    if m.action == ACT_BACKFLIP and m.prevAction == ACT_CROUCHING and m.marioObj.header.gfx.animInfo.animFrame == 13 then
        set_mario_action(m, ACT_TWIRLING, 0)
    end
    if m.action == ACT_TWIRLING then
        m.faceAngle.y = m.intendedYaw 
        m.forwardVel = m.forwardVel * 1.5
    end
    if m.action == ACT_FORWARD_ROLLOUT and m.vel.y == -10 then
        m.forwardVel = m.forwardVel * 0.9
    end
    if m.action == ACT_JUMP_KICK then
         m.faceAngle.y = m.intendedYaw
    end
    if m.action == ACT_JUMP_KICK and m.vel.y < -45 then
        m.forwardVel = m.forwardVel * 0.99
    end
    if m.action == ACT_TWIRLING and m.forwardVel > 40 then
        m.forwardVel = 40
    end
    if m.action == ACT_TWIRLING and m.forwardVel < 1 then
        m.forwardVel = 0
    end
    if m.action == ACT_JUMP_KICK and m.marioObj.header.gfx.animInfo.animFrame == 1 then
        m.vel.y = m.vel.y * 3
    end
    if m.action == ACT_WALKING then
        m.marioBodyState.torsoAngle.x = 0
        m.marioBodyState.torsoAngle.z = 0
    end
    if (m.marioObj.header.gfx.animInfo.animID == CHAR_ANIM_STAR_DANCE and m.marioObj.header.gfx.animInfo.animFrame > 37) or (m.marioObj.header.gfx.animInfo.animID == CHAR_ANIM_WATER_STAR_DANCE and m.marioObj.header.gfx.animInfo.animFrame > 68) then
        m.marioBodyState.eyeState = MARIO_EYES_LOOK_UP
    end
        if m.marioObj.header.gfx.animInfo.animID == CHAR_ANIM_AIR_KICK and m.marioObj.header.gfx.animInfo.animFrame < 14 then
        m.marioBodyState.eyeState = MARIO_EYES_DEAD
    end
        if m.marioObj.header.gfx.animInfo.animID == CHAR_ANIM_FALL_OVER_BACKWARDS or m.marioObj.header.gfx.animInfo.animID == CHAR_ANIM_BACKWARD_AIR_KB then
            m.marioBodyState.eyeState = MARIO_EYES_DEAD
    end
    -- GOLD SHROOM
    if (m.flags & MARIO_METAL_CAP) ~= 0 and m.action == ACT_MOVE_PUNCHING then
        set_mario_particle_flags(m, PARTICLE_VERTICAL_STAR, 0)
        set_mario_action(m, ACT_WALKING, 0)
        m.forwardVel = m.forwardVel * 10
        m.faceAngle.y = m.intendedYaw
    end
    if (m.flags & MARIO_METAL_CAP) ~= 0 and m.action == ACT_DIVE and m.prevAction == ACT_WALKING then
        set_mario_action(m, ACT_MOVE_PUNCHING, 0)
    end
    if (m.flags & MARIO_METAL_CAP) ~= 0 and m.action == ACT_WALKING and m.forwardVel == 48 then
        m.forwardVel = m.forwardVel * 2
    end
    if (m.flags & MARIO_METAL_CAP) ~= 0 and m.action == ACT_IDLE then
        set_mario_action(m, ACT_STANDING_AGAINST_WALL, 0)
    end
    if (m.flags & MARIO_METAL_CAP) ~= 0 and m.action == ACT_JUMP and m.forwardVel > 45 then
        m.forwardVel = m.forwardVel * 0.9
        m.faceAngle.y = m.intendedYaw
    end
    if (m.flags & MARIO_METAL_CAP) ~= 0 and m.action == ACT_JUMP and m.forwardVel > 80 then
        m.forwardVel = m.forwardVel * 0.1
        m.faceAngle.y = m.intendedYaw
    end
    if (m.flags & MARIO_METAL_CAP) ~= 0 and m.vel.y > 100 then
        m.faceAngle.y = m.intendedYaw
        m.vel.y = m.vel.y * 0.3
    end
    if (m.flags & MARIO_METAL_CAP) ~= 0 and m.action == ACT_BRAKING and m.forwardVel > 80 then
        m.forwardVel = m.forwardVel * 0
        m.faceAngle.y = m.intendedYaw
    end
    --if m.prevAction == ACT_DIVE and m.action == ACT_FORWARD_ROLLOUT then 
    --    set_mario_particle_flags(m, ACTIVE_PARTICLE_V_STAR, 0)
    --end
end
_G.charSelect.character_hook_moveset(CT_KAKTUS, HOOK_MARIO_UPDATE, kaktus_update)
end