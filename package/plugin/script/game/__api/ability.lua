local mt = {}
mt.__index = mt

mt.keys = {
    ABILITY_STATE_COOLDOWN = 1,

    ABILITY_DATA_TARGS = 100, -- integer
    ABILITY_DATA_CAST = 101, -- real
    ABILITY_DATA_DUR = 102, -- real
    ABILITY_DATA_HERODUR = 103, -- real
    ABILITY_DATA_COST = 104, -- integer
    ABILITY_DATA_COOL = 105, -- real
    ABILITY_DATA_AREA = 106, -- real
    ABILITY_DATA_RNG = 107, -- real
    ABILITY_DATA_DATA_A = 108, -- real
    ABILITY_DATA_DATA_B = 109, -- real
    ABILITY_DATA_DATA_C = 110, -- real
    ABILITY_DATA_DATA_D = 111, -- real
    ABILITY_DATA_DATA_E = 112, -- real
    ABILITY_DATA_DATA_F = 113, -- real
    ABILITY_DATA_DATA_G = 114, -- real
    ABILITY_DATA_DATA_H = 115, -- real
    ABILITY_DATA_DATA_I = 116, -- real
    ABILITY_DATA_UNITID = 117, -- integer

    ABILITY_DATA_HOTKET = 200, -- integer
    ABILITY_DATA_UNHOTKET = 201, -- integer
    ABILITY_DATA_RESEARCH_HOTKEY = 202, -- integer
    ABILITY_DATA_NAME = 203, -- string
    ABILITY_DATA_ART = 204, -- string
    ABILITY_DATA_TARGET_ART = 205, -- string
    ABILITY_DATA_CASTER_ART = 206, -- string
    ABILITY_DATA_EFFECT_ART = 207, -- string
    ABILITY_DATA_AREAEFFECT_ART = 208, -- string
    ABILITY_DATA_MISSILE_ART = 209, -- string
    ABILITY_DATA_SPECIAL_ART = 210, -- string
    ABILITY_DATA_LIGHTNING_EFFECT = 211, -- string
    ABILITY_DATA_BUFF_TIP = 212, -- string
    ABILITY_DATA_BUFF_UBERTIP = 213, -- string
    ABILITY_DATA_RESEARCH_TIP = 214, -- string
    ABILITY_DATA_TIP = 215, -- string
    ABILITY_DATA_UNTIP = 216, -- string
    ABILITY_DATA_RESEARCH_UBERTIP = 217, -- string
    ABILITY_DATA_UBERTIP = 218, -- string
    ABILITY_DATA_UNUBERTIP = 219, -- string
    ABILITY_DATA_UNART = 220, -- string
}

mt.abilityCallbackTable = {}

--------------------------------------------------------------------------------------
function mt:getAbilityOnUnit(u, abid)
    if not u then
        return
    end

    return japi.EXGetUnitAbility(u.handle, abid)
end

--------------------------------------------------------------------------------------
function mt:setUnitSkillDataReal(u, ability, lv, dataName, dataVal)
    if not u then
        return
    end

    if not mt.keys[dataName] then
        return
    end

    lv = lv or 1
    dataVal = dataVal or 0

    local dataId = mt.keys[dataName]
    local uAbility = mt:getAbilityOnUnit(u, ability)

    -- mapdebug(string.format('set skill data: %s, %s, %d, %d, %d', GetUnitName(u.handle), GetAbilityName(ability), lv, dataId, dataVal))

    japi.EXSetAbilityDataReal(uAbility, lv, dataId, dataVal)

end

--------------------------------------------------------------------------------------
function mt:setUnitSkillDataInt(u, ability, lv, dataName, dataVal)
    if not u then
        return
    end

    if not mt.keys[dataName] then
        return
    end

    lv = lv or 1
    dataVal = dataVal or 0

    local dataId = mt.keys[dataName]
    local uAbility = mt:getAbilityOnUnit(u, ability)

    -- mapdebug(string.format('set skill data: %s, %s, %d, %d, %d', GetUnitName(u.handle), GetAbilityName(ability), lv, dataId, dataVal))

    japi.EXSetAbilityDataInteger(uAbility, lv, dataId, dataVal)

end

--------------------------------------------------------------------------------------
function mt:setUnitAbilityLevel(u, abid, lv)
    if not u then
        return
    end

    jass.SetUnitAbilityLevel(u.handle, abid, lv or 1)

end
--------------------------------------------------------------------------------------
function CreateLineWarning(keys)
    local eff = fc.pointEffect({
        model = [[az_spiderwebd_line1.mdx]],
        size = 1,
        time = keys.time,
        mustShow = true,
        isWarning = true,
    }, fc.polarPoint(keys.point, 200 * (keys.far / 1400.00), keys.face))
    japi.EXEffectMatScale(eff, (keys.far / 1400.00), (keys.wide / 270.00), 1)
    japi.EXEffectMatRotateZ(eff, keys.face)
    return eff
end
--------------------------------------------------------------------------------------
function CreateCircleWarning(keys)
    local face = keys.face or math.random(360)
    for i = 1, 1 do
        local eff = fc.pointEffect({
            model = [[AZ_AurelVlaicu_C2_Enemy.MDX]],
            size = keys.rad / 500,
            time = keys.time,
            face = face,
            mustShow = true,
            isWarning = true,
        }, keys.point)
        japi.EXSetEffectSpeed(eff, (2 / (keys.time * 1.01)))
    end
end
--------------------------------------------------------------------------------------
function CreateObviousCircleWarning(keys)
    local face = keys.face or math.random(360)
    for i = 1, 1 do
        local eff = fc.pointEffect({
            model = [[208.mdx]],
            size = keys.rad / 175,
            -- time = keys.time,
            face = face,
            mustShow = true,
            isWarning = true,
        }, keys.point)
        -- japi.EXSetEffectSpeed(eff, (2 / (keys.time * 1.01)))
    end
end
--------------------------------------------------------------------------------------
function CreateSectorWarning(keys)
    local face = keys.face or math.random(360)
    local eff = fc.pointEffect({
        model = [[647.MDX]],
        size = 1,
        time = keys.time,
        face = face,
        mustShow = true,
        isWarning = true,
    }, keys.point)
    japi.EXSetEffectSpeed(eff, (2 / (keys.time * 1.01)))
end
--------------------------------------------------------------------------------------
function CreateCircleHelp(keys)

    for i = 1, 1 do
        local eff = fc.pointEffect({
            model = [[AZ_AurelVlaicu_C2_Ally.MDX]],
            size = keys.rad / 500,
            -- size = keys.rad / 400,
            time = keys.time,
            face = 270,
            mustShow = true,
            isWarning = true,
        }, keys.point)

        japi.EXSetEffectSpeed(eff, (1 / (keys.time * 1.01)))
    end

end
--------------------------------------------------------------------------------------
function mt:registerRawAbilityCallback(abilityIdString, callback)
    local callbackTable = mt.abilityCallbackTable

    callbackTable[abilityIdString] = callback
end
--------------------------------------------------------------------------------------
function mt:checkRawAbilityCallback(keys)
    local callbackTable = mt.abilityCallbackTable
    local abilityIdString = keys.abilityIdString

    if callbackTable[abilityIdString] then
        xpcall(function()
            callbackTable[abilityIdString](keys)
        end, traceError)
    end

end
--------------------------------------------------------------------------------------
return mt
