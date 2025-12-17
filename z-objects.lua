if not _G.charSelectExists then return end

local E_MODEL_PROPELLER = smlua_model_util_get_id("propeller_geo")

gPlayerObjects = {}
for i = 0, (MAX_PLAYERS - 1) do
    gPlayerObjects[i] = nil
end

------------

define_custom_obj_fields({
    oPlayerIndex = 'u32',
})

local function propeller_init(o)
    o.oFlags = OBJ_FLAG_UPDATE_GFX_POS_AND_ANGLE
    o.oOpacity = 0
    o.hookRender = 1
    obj_scale(o, 1)
    o.hitboxRadius = 100
    o.hitboxHeight = 100
    o.oIntangibleTimer = 0
    cur_obj_hide()
end

local function propeller_loop(o)
    local m = gMarioStates[o.oPlayerIndex]

    -- if the player is off screen, hide the obj
    if m.marioBodyState.updateTorsoTime ~= gMarioStates[0].marioBodyState.updateTorsoTime then
        cur_obj_hide()
        return
    end

    -- update pallet
    local np = gNetworkPlayers[o.oPlayerIndex]
    if np ~= nil then
        o.globalPlayerIndex = np.globalIndex
    end

    -- check if this should be activated
    if obj_is_hidden(o) ~= 0 then
        cur_obj_unhide()
        obj_set_model_extended(o, E_MODEL_PROPELLER)
        obj_scale(o, 0.2)
        o.oAnimState = 0
        o.header.gfx.node.flags = o.header.gfx.node.flags & ~GRAPH_RENDER_BILLBOARD
        o.oAnimations = nil
    end

    if m.action == ACT_BRELLA_FLOAT and m.character.type == CT_LUIGI then
        cur_obj_unhide()
        if o.header.gfx.scale.y < 2 then
            o.header.gfx.scale.x = o.header.gfx.scale.x * 1.2
            o.header.gfx.scale.y = o.header.gfx.scale.y * 1.2
            o.header.gfx.scale.z = o.header.gfx.scale.z * 1.2
        end
    else
        cur_obj_hide()
    end
end

local id_bhvPropeller = hook_behavior(nil, OBJ_LIST_DEFAULT, true, propeller_init, propeller_loop, "bhvPropeller")

------------

local function on_sync_valid()
    for i = 0, (MAX_PLAYERS - 1) do
        gPlayerObjects[i] = {
            [1] = spawn_non_sync_object(id_bhvPropeller, E_MODEL_PROPELLER, 0, 0, 0,
            function(o)
                o.oPlayerIndex = i
            end)
        }
    end
end

local function on_object_render(o)
    local m = gMarioStates[o.oPlayerIndex]
    if get_id_from_behavior(o.behavior) == id_bhvPropeller then
        o.oFaceAngleYaw = o.oFaceAngleYaw + 0x1500
        o.oPosX = m.marioObj.header.gfx.pos.x
        o.oPosY = m.marioObj.header.gfx.pos.y + 100
        o.oPosZ = m.marioObj.header.gfx.pos.z
    
        -- if the player is off screen, move the obj to the player origin
        if m.marioBodyState.updateTorsoTime ~= gMarioStates[0].marioBodyState.updateTorsoTime then
            o.oPosX = m.pos.x
            o.oPosY = m.pos.y
            o.oPosZ = m.pos.z
        end
    
        o.oPosX = o.oPosX + sins(m.faceAngle.y) * 10
        o.oPosZ = o.oPosZ + coss(m.faceAngle.y) * 10
    
        o.header.gfx.pos.x = o.oPosX
        o.header.gfx.pos.y = o.oPosY
        o.header.gfx.pos.z = o.oPosZ
    end
end

hook_event(HOOK_ON_OBJECT_RENDER, on_object_render)
hook_event(HOOK_ON_SYNC_VALID, on_sync_valid)