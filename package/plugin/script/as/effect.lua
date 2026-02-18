local dbg = require 'jass.debug'

local mt = {}

local timerDeleteEff = function(eff, time)

    time = time or 0

    if time > 0 then
        ac.timer(ms(time), 1, function()
            fc.removeEffect(eff)
        end)
    else
        fc.removeEffect(eff)
    end
end
--------------------------------------------------------------------------------------
function mt:pointEffect(keys, point)
    if (not point) then
        error('point effect create fail')
        return
    end

    -- if (not keys.isProjectile) and (not keys.isText) and (not keys.isWarning)and (not keys.isOrb) then
    --     if math.randomPct() <= EnemyManager.hideEffectChance then
    --         return
    --     end
    -- end

    if not keys.model then
        keys.model = ''
    end

    if (not keys.isText) and (not keys.isWarning) and (not keys.isOrb) then
        if math.randomPct() <= gm.hideEffectChance then
            keys.model = ''
        end
    end

    local localP = as.player:getLocalPlayer()

    if not keys.mustShow then
        if (keys.isLocal and localP.effectOptmize) or localP.closeAllEffect then
            keys.model = ''
        end

    end

    local eff = AddSpecialEffect(keys.model, point:get())
    dbg.handle_ref(eff)

    if keys.size then
        japi.EXSetEffectSize(eff, keys.size)
    end

    if keys.face then
        japi.EXEffectMatRotateZ(eff, keys.face)
    end

    if keys.height then
        japi.EXSetEffectZ(eff, keys.height)
    end

    if keys.color then
        mt:setColor(eff, keys.color.red, keys.color.green, keys.color.blue)
    end

    if keys.speed then
        japi.EXSetEffectSpeed(eff, 2.00)
    end

    if keys.x then
        japi.EXEffectMatRotateX(eff, keys.x)
    end
    if keys.y then
        japi.EXEffectMatRotateY(eff, keys.y)
    end
    if keys.z then
        japi.EXEffectMatRotateZ(eff, keys.z)
    end

    local time = keys.time or 0

    if time > 0 then
        timerDeleteEff(eff, keys.time)
    elseif time == 0 then
        fc.removeEffect(eff)
    end

    return eff
end
--------------------------------------------------------------------------------------
function fc.removeEffect(eff)
    DestroyEffect(eff)
    dbg.handle_unref(eff)
end
--------------------------------------------------------------------------------------
function fc.pointEffect(keys, point)
    return mt:pointEffect(keys, point)
end
--------------------------------------------------------------------------------------
function mt:unitEffect(keys, unit)

    if (unit.removed) then
        gdebug('unit effect create fail')
        return
    end

    if math.randomPct() <= EnemyManager.hideEffectChance then
        return
    end

    if (not keys.isText) and (not keys.isWarning) and (not keys.isOrb) then
        if math.randomPct() <= gm.hideEffectChance then
            keys.model = ''
        end
    end

    if not keys.mustShow then
        if not keys.model then
            keys.model = ''
        end

        local localP = as.player:getLocalPlayer()

        if (keys.isLocal and localP.effectOptmize) or localP.closeAllEffect then
            keys.model = ''
        end
    end

    local eff = AddSpecialEffectTarget(keys.model, unit.handle or 0, keys.bind or 'origin')
    dbg.handle_ref(eff)

    local time = keys.time or 0

    if time > 0 then
        timerDeleteEff(eff, keys.time)
    elseif time == 0 then
        fc.removeEffect(eff)
    end

    return eff
end
--------------------------------------------------------------------------------------
function fc.unitEffect(keys, unit)
    return mt:unitEffect(keys, unit)
end
--------------------------------------------------------------------------------------
function mt:moveEffect(eff, point)
    local x, y = point:get()
    japi.EXSetEffectXY(eff, x, y)
end
--------------------------------------------------------------------------------------
function mt:setSize(eff, size)
    japi.EXSetEffectSize(eff, size)
end
--------------------------------------------------------------------------------------
function mt:setHeight(eff, height)
    japi.EXSetEffectZ(eff, height)
end
--------------------------------------------------------------------------------------
function mt:setColor(eff, red, green, blue)
    japi.EXSetEffectColor(eff, 0xff000000 + 0x10000 * red + 0x100 * green + blue)
end
--------------------------------------------------------------------------------------
return mt
