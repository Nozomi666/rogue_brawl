local mt = {}
StatsSetter = mt
--------------------------------------------------------------------------------------
-- only reference, not used
mt.JAPI_KEY = {
    [ST_HP] = ConvertUnitState(0),
    [ST_MP] = ConvertUnitState(2),
    [ST_HP_MAX] = ConvertUnitState(1),
    [ST_MP_MAX] = ConvertUnitState(3),
    [ST_ATK] = ConvertUnitState(0x12),

}

--------------------------------------------------------------------------------------
mt.statsTable = nil
mt.heroStatsRecord = nil
--------------------------------------------------------------------------------------
function mt.updateBonusStats(u)
    if not u.heroStatsRecord then
        u.heroStatsRecord = {}
    end
    local heroStatsRecord = u.heroStatsRecord

    --------------------------------------------------------------------------------------
    -- update str
    local statsType = ST_STR
    if not heroStatsRecord[statsType] then
        heroStatsRecord[statsType] = 0
    end
    local prev = heroStatsRecord[statsType]
    local after = u:getStats(statsType)
    if after ~= prev then
        heroStatsRecord[statsType] = after
        --------------------------------------------------------------------------------------
        -- update hp max
        local amt = (after - prev) * STR_RATE_HP
        u:modStats(ST_BASE_HP_MAX, amt)
        --------------------------------------------------------------------------------------
        -- update hp regen
        local amt = (after - prev) * STR_RATE_HP_REGEN
        u:modStats(ST_BASE_HP_REGEN, amt)
        --------------------------------------------------------------------------------------
        -- update hp pct
        local prevAmt = ConvertStrToHpPct(prev)
        local afterAmt = ConvertStrToHpPct(after)
        u:modStats(ST_HP_MAX_PCT, (afterAmt - prevAmt))
        -- gdebug(str.format('str: %.0f, hp pct: %.3f', after, afterAmt))
        --------------------------------------------------------------------------------------
        -- update phy pct
        local prevAmt = ConvertStrToPhyDmg(prev)
        local afterAmt = ConvertStrToPhyDmg(after)
        u:modStats(ST_PHY_RATE, (afterAmt - prevAmt))
        --------------------------------------------------------------------------------------
        -- update base atk
        if u:mainStIs(statsType) then
            local amt = (after - prev) * MAIN_RATE_ATK
            u:modStats(ST_BASE_ATK, amt)
        end
        --------------------------------------------------------------------------------------
    end

    --------------------------------------------------------------------------------------
    -- update agi
    local statsType = ST_AGI
    if not heroStatsRecord[statsType] then
        heroStatsRecord[statsType] = 0
    end
    local prev = heroStatsRecord[statsType]
    local after = u:getStats(statsType)
    if after ~= prev then
        heroStatsRecord[statsType] = after
        --------------------------------------------------------------------------------------
        -- update atk speed
        local prevAmt = ConvertAgiToAtkSpeed(prev)
        local afterAmt = ConvertAgiToAtkSpeed(after)
        u:modStats(ST_ATK_SPEED, (afterAmt - prevAmt))
        --------------------------------------------------------------------------------------
        -- update atk rate
        local prevAmt = ConvertAgiToAtkRate(prev)
        local afterAmt = ConvertAgiToAtkRate(after)
        u:modStats(ST_ATK_DMG, (afterAmt - prevAmt))
        --------------------------------------------------------------------------------------
        -- update base phy def
        -- local prevAmt = ConvertAgiToPhyDef(prev)
        -- local afterAmt = ConvertAgiToPhyDef(after)
        -- u:modStats(ST_BASE_PHY_DEF, (afterAmt - prevAmt))
        --------------------------------------------------------------------------------------
        -- update base atk
        if u:mainStIs(statsType) then
            local amt = (after - prev) * MAIN_RATE_ATK
            u:modStats(ST_BASE_ATK, amt)
        end
        --------------------------------------------------------------------------------------
    end

    --------------------------------------------------------------------------------------
    -- update int
    local statsType = ST_INT
    if not heroStatsRecord[statsType] then
        heroStatsRecord[statsType] = 0
    end
    local prev = heroStatsRecord[statsType]
    local after = u:getStats(statsType)
    if after ~= prev then
        heroStatsRecord[statsType] = after
        --------------------------------------------------------------------------------------
        -- update mag rate
        local prevAmt = ConvertIntToMagRate(prev)
        local afterAmt = ConvertIntToMagRate(after)
        u:modStats(ST_MAG_RATE, (afterAmt - prevAmt))
        --------------------------------------------------------------------------------------
        -- update skill rate
        local prevAmt = ConvertIntToSkillRate(prev)
        local afterAmt = ConvertIntToSkillRate(after)
        u:modStats(ST_SKILL_DMG, (afterAmt - prevAmt))
        --------------------------------------------------------------------------------------
        -- update base phy def
        -- local prevAmt = ConvertAgiToPhyDef(prev)
        -- local afterAmt = ConvertAgiToPhyDef(after)
        -- u:modStats(ST_BASE_MAG_DEF, (afterAmt - prevAmt))
        --------------------------------------------------------------------------------------
        -- update base atk
        if u:mainStIs(statsType) then
            local amt = (after - prev) * MAIN_RATE_ATK
            u:modStats(ST_BASE_ATK, amt)
        end
        --------------------------------------------------------------------------------------
    end

end
--------------------------------------------------------------------------------------
function mt.updateTotalStr(u)
    local total = u:getStats(ST_BASE_STR) * (1 + u:getStats(ST_STR_PCT)) + u:getStats(ST_BONUS_STR)
    u.statsTable[ST_STR] = total
    SetHeroStr(u.handle, total, true)
    mt.updateBonusStats(u)
end
--------------------------------------------------------------------------------------
function mt.updateTotalAgi(u)
    local total = u:getStats(ST_BASE_AGI) * (1 + u:getStats(ST_AGI_PCT)) + u:getStats(ST_BONUS_AGI)
    u.statsTable[ST_AGI] = total
    SetHeroAgi(u.handle, total, true)
    mt.updateBonusStats(u)
end
--------------------------------------------------------------------------------------
function mt.updateTotalInt(u)
    local total = u:getStats(ST_BASE_INT) * (1 + u:getStats(ST_INT_PCT)) + u:getStats(ST_BONUS_INT)
    u.statsTable[ST_INT] = total
    SetHeroInt(u.handle, total, true)
    mt.updateBonusStats(u)
end
--------------------------------------------------------------------------------------
function mt.updateTotalAtk(u)
    local total = u:getStats(ST_BASE_ATK) * (1 + u:getStats(ST_ATK_PCT)) + u:getStats(ST_BONUS_ATK)
    u.statsTable[ST_ATK] = total
end
--------------------------------------------------------------------------------------
function mt.updateTotalPhyDef(u)
    local total = u:getStats(ST_BASE_PHY_DEF) * (1 + u:getStats(ST_PHY_DEF_PCT)) + u:getStats(ST_BONUS_PHY_DEF)
    u.statsTable[ST_PHY_DEF] = total
end
--------------------------------------------------------------------------------------
function mt.updateTotalMagDef(u)
    local total = u:getStats(ST_BASE_MAG_DEF) * (1 + u:getStats(ST_MAG_DEF_PCT)) + u:getStats(ST_BONUS_MAG_DEF)
    u.statsTable[ST_MAG_DEF] = total
end
--------------------------------------------------------------------------------------
function mt.updateTotalBlock(u)
    local total = u:getStats(ST_BASE_BLOCK) * (1 + u:getStats(ST_BLOCK_PCT))
    u.statsTable[ST_BLOCK] = total

end
--------------------------------------------------------------------------------------
function mt.updateTotalMoveSpeed(u)
    local total = u:getStats(ST_BASE_MOVE_SPEED) * (1 + u:getStats(ST_MOVE_SPEED_PCT)) + u:getStats(ST_BONUS_MOVE_SPEED)
        if u.fixedMoveSpeed then
        return
    end

    if not u.slowSpeedList then
        u.slowSpeedList = {}
    end

    for i = 1, #u.slowSpeedList do
        total = total * (1 - u.slowSpeedList[i] * math.max(0, 1 - u:getStats(ST_SLOW_RESIST)))
    end

    total = math.max(total, MIN_MOVE_SPEED)

    u.statsTable[ST_MOVE_SPEED] = total
    -- gdebug('updateTotalMoveSpeed: ' .. total)

    SetUnitMoveSpeed(u.handle, total)
end
--------------------------------------------------------------------------------------
function mt.updateTotalRange(u)
    local total = u:getStats(ST_BASE_RANGE) * (1 + u:getStats(ST_RANGE_PCT)) + u:getStats(ST_EXTRA_RANGE)
    u.statsTable[ST_RANGE] = total

    if u.handle and not u:isRemoved() then
        SetUnitState(u.handle, ConvertUnitState(0x16), total)
    end

end
--------------------------------------------------------------------------------------
function mt.updateTotalDmgReduction(u)
    local totalReceiveDmg = 1

    if not u.dmgReductionList then
        u.dmgReductionList = {}
    end

    for i = 1, #u.dmgReductionList do
        totalReceiveDmg = totalReceiveDmg * (1 - math.min(1, u.dmgReductionList[i]))
    end

    u.totalDmgReduction = math.max(1 - totalReceiveDmg, 0)
    -- gdebug('update totalDmgReduction: ' .. u.totalDmgReduction)
end
--------------------------------------------------------------------------------------
mt[ST_MP_MAX] = function(u, amt)
    local after = mt.generalModifier(u, ST_MP_MAX, amt) * math.max(-0.95, (1 + u:getStats(ST_MP_MAX_PCT)))

    local mpPct = u:getStats(ST_MP_PCT)

    if u:isRemoved() then
        return
    end
    SetUnitState(u.handle, ConvertUnitState(3), after)

    u:setStats(ST_MP_PCT, mpPct)

    return after
end
--------------------------------------------------------------------------------------
mt[ST_MP_MAX_PCT] = function(u, amt)
    local after = mt.generalModifier(u, ST_MP_MAX_PCT, amt)

    u:refreshStats(ST_MP_MAX)
    return after
end
--------------------------------------------------------------------------------------
mt[ST_HP_PCT] = function(u, amt)
    local after = u:getStats(ST_HP_PCT) + amt
    SetUnitLifePercentBJ(u.handle, after * 100)
    return after
end
--------------------------------------------------------------------------------------
mt[ST_MP_PCT] = function(u, amt)
    local after = u:getStats(ST_MP_PCT) + amt
    SetUnitManaPercentBJ(u.handle, after * 100)
    return after
end
--------------------------------------------------------------------------------------
mt[ST_HP] = function(u, amt)
    local after = u:getStats(ST_HP) + amt
    if u:isRemoved() then
        return
    end
    SetUnitState(u.handle, ConvertUnitState(0), after)
    return after
end
--------------------------------------------------------------------------------------
mt[ST_MP] = function(u, amt)
    local after = u:getStats(ST_MP) + amt
    if u:isRemoved() then
        return
    end
    SetUnitState(u.handle, ConvertUnitState(2), after)
    return after
end
--------------------------------------------------------------------------------------
mt[ST_BASE_STR] = function(u, amt)
    local after = mt.generalModifier(u, ST_BASE_STR, amt)
    mt.updateTotalStr(u)
    return after
end
--------------------------------------------------------------------------------------
mt[ST_BASE_AGI] = function(u, amt)
    local after = mt.generalModifier(u, ST_BASE_AGI, amt)
    mt.updateTotalAgi(u)
    return after
end
--------------------------------------------------------------------------------------
mt[ST_BASE_INT] = function(u, amt)
    local after = mt.generalModifier(u, ST_BASE_INT, amt)
    mt.updateTotalInt(u)
    return after
end
--------------------------------------------------------------------------------------
mt[ST_BASE_ATK] = function(u, amt)
    local after = mt.generalModifier(u, ST_BASE_ATK, amt)
    mt.updateTotalAtk(u)
    return after
end
--------------------------------------------------------------------------------------
mt[ST_BASE_PHY_DEF] = function(u, amt)
    local after = mt.generalModifier(u, ST_BASE_PHY_DEF, amt)
    mt.updateTotalPhyDef(u)
    return after
end
--------------------------------------------------------------------------------------
mt[ST_BASE_MAG_DEF] = function(u, amt)
    local after = mt.generalModifier(u, ST_BASE_MAG_DEF, amt)
    mt.updateTotalMagDef(u)
    return after
end
--------------------------------------------------------------------------------------
mt[ST_BASE_BLOCK] = function(u, amt)
    local after = mt.generalModifier(u, ST_BASE_BLOCK, amt)
    mt.updateTotalBlock(u)
    return after
end
mt[ST_BLOCK] = mt[ST_BASE_BLOCK]
--------------------------------------------------------------------------------------
mt[ST_BASE_MOVE_SPEED] = function(u, amt)
    local after = mt.generalModifier(u, ST_BASE_MOVE_SPEED, amt)
    mt.updateTotalMoveSpeed(u)
    return after
end
mt[ST_MOVE_SPEED] = mt[ST_BASE_MOVE_SPEED]
--------------------------------------------------------------------------------------
mt[ST_SLOW_SPEED] = function(u, amt)
    if not u.slowSpeedList then
        u.slowSpeedList = {}
    end

    if amt > 0 then
        table.insert(u.slowSpeedList, amt)
    else
        amt = amt * -1
        local removed
        for i = 1, #u.slowSpeedList do
            if u.slowSpeedList[i] == amt then
                removed = table.remove(u.slowSpeedList, i)
                break
            end
        end
        if not removed then
            gdebug('did not find slow speed remove: ' .. amt)
            gdebug(u:getName())
            traceError()
        end
    end
    mt.updateTotalMoveSpeed(u)

end
--------------------------------------------------------------------------------------
mt[ST_DMG_REDUCTION] = function(u, amt)
    if not u.dmgReductionList then
        u.dmgReductionList = {}
    end

    if amt > 0 then
        table.insert(u.dmgReductionList, amt)
    else
        amt = amt * -1
        local removed
        for i = 1, #u.dmgReductionList do
            if u.dmgReductionList[i] == amt then
                removed = table.remove(u.dmgReductionList, i)
                break
            end
        end
        if not removed then
            gdebug('did not find dmg reduction remove: ' .. amt)
            gdebug(u:getName())
            traceError()
        end
    end
    mt.updateTotalDmgReduction(u)

end
--------------------------------------------------------------------------------------
mt[ST_BASE_MAIN] = function(u, amt)
    local statsType = u:getMainStatsType()
    local modType = ST_BASE_STR
    if statsType == ST_AGI then
        modType = ST_BASE_AGI
    elseif statsType == ST_INT then
        modType = ST_BASE_INT
    end
    return u:modStats(modType, amt)
end
--------------------------------------------------------------------------------------
mt[ST_BASE_SIDE] = function(u, amt)
    local statsType = u:getMainStatsType()
    if statsType == ST_AGI then
        local modType = ST_BASE_INT
        local modType1 = ST_BASE_STR
        return u:modStats(modType, amt) + u:modStats(modType1, amt)
    elseif statsType == ST_INT then
        local modType = ST_BASE_AGI
        local modType1 = ST_BASE_STR
        return u:modStats(modType, amt) + u:modStats(modType1, amt)
    elseif statsType == ST_STR then
        local modType = ST_BASE_AGI
        local modType1 = ST_BASE_INT
        return u:modStats(modType, amt) + u:modStats(modType1, amt)
    end
end
--------------------------------------------------------------------------------------
mt[ST_BASE_ALL] = function(u, amt)
    return u:modStats(ST_BASE_INT, amt) + u:modStats(ST_BASE_AGI, amt) + u:modStats(ST_BASE_STR, amt)
end
--------------------------------------------------------------------------------------
mt[ST_BASE_DOUBLE_DEF] = function(u, amt)
    return u:modStats(ST_BASE_PHY_DEF, amt) + u:modStats(ST_BASE_MAG_DEF, amt)
end
--------------------------------------------------------------------------------------
mt[ST_BONUS_STR] = function(u, amt)
    local after = mt.generalModifier(u, ST_BONUS_STR, amt)
    mt.updateTotalStr(u)

    return after
end
mt[ST_STR] = mt[ST_BONUS_STR]
--------------------------------------------------------------------------------------
mt[ST_BONUS_AGI] = function(u, amt)
    local after = mt.generalModifier(u, ST_BONUS_AGI, amt)
    mt.updateTotalAgi(u)

    return after
end
mt[ST_AGI] = mt[ST_BONUS_AGI]
--------------------------------------------------------------------------------------
mt[ST_BONUS_INT] = function(u, amt)
    local after = mt.generalModifier(u, ST_BONUS_INT, amt)
    mt.updateTotalInt(u)

    return after
end
mt[ST_INT] = mt[ST_BONUS_INT]
--------------------------------------------------------------------------------------
mt[ST_BONUS_ATK] = function(u, amt)
    local after = mt.generalModifier(u, ST_BONUS_ATK, amt)
    mt.updateTotalAtk(u)

    return after
end
mt[ST_ATK] = mt[ST_BONUS_ATK]
--------------------------------------------------------------------------------------
mt[ST_BONUS_PHY_DEF] = function(u, amt)
    local after = mt.generalModifier(u, ST_BONUS_PHY_DEF, amt)
    mt.updateTotalPhyDef(u)

    return after
end
mt[ST_PHY_DEF] = mt[ST_BONUS_PHY_DEF]
--------------------------------------------------------------------------------------
mt[ST_BONUS_MAG_DEF] = function(u, amt)
    local after = mt.generalModifier(u, ST_BONUS_MAG_DEF, amt)
    mt.updateTotalMagDef(u)

    return after
end
mt[ST_MAG_DEF] = mt[ST_BONUS_MAG_DEF]
--------------------------------------------------------------------------------------
mt[ST_BONUS_MOVE_SPEED] = function(u, amt)
    local after = mt.generalModifier(u, ST_BONUS_MOVE_SPEED, amt)
    mt.updateTotalMoveSpeed(u)

    return after
end
--------------------------------------------------------------------------------------
mt[ST_BONUS_MAIN] = function(u, amt)
    local statsType = u:getMainStatsType()
    local modType = ST_BONUS_STR
    if statsType == ST_AGI then
        modType = ST_BONUS_AGI
    elseif statsType == ST_INT then
        modType = ST_BONUS_INT
    end
    return u:modStats(modType, amt)
end
mt[ST_MAIN] = mt[ST_BONUS_MAIN]
--------------------------------------------------------------------------------------
mt[ST_BONUS_SIDE] = function(u, amt)
    local statsType = u:getMainStatsType()
    if statsType == ST_AGI then
        local modType = ST_BONUS_INT
        local modType1 = ST_BONUS_STR
        u:modStats(modType, amt)
        u:modStats(modType1, amt)
        return
    elseif statsType == ST_INT then
        local modType = ST_BONUS_AGI
        local modType1 = ST_BONUS_STR
        u:modStats(modType, amt)
        u:modStats(modType1, amt)
        return
    elseif statsType == ST_STR then
        local modType = ST_BONUS_AGI
        local modType1 = ST_BONUS_INT
        u:modStats(modType, amt)
        u:modStats(modType1, amt)
        return
    end
end
mt[ST_SIDE] = mt[ST_BONUS_SIDE]
--------------------------------------------------------------------------------------
mt[ST_BONUS_ALL] = function(u, amt)
    u:modStats(ST_BONUS_STR, amt)
    u:modStats(ST_BONUS_AGI, amt)
    u:modStats(ST_BONUS_INT, amt)
    return
end
mt[ST_ALL] = mt[ST_BONUS_ALL]
--------------------------------------------------------------------------------------
mt[ST_STR_PCT] = function(u, amt)
    local after = mt.generalModifier(u, ST_STR_PCT, amt)
    mt.updateTotalStr(u)

    return after
end
--------------------------------------------------------------------------------------
mt[ST_AGI_PCT] = function(u, amt)
    local after = mt.generalModifier(u, ST_AGI_PCT, amt)
    mt.updateTotalAgi(u)

    return after
end
--------------------------------------------------------------------------------------
mt[ST_INT_PCT] = function(u, amt)
    local after = mt.generalModifier(u, ST_INT_PCT, amt)
    mt.updateTotalInt(u)

    return after
end
--------------------------------------------------------------------------------------
mt[ST_ATK_PCT] = function(u, amt)
    local after = mt.generalModifier(u, ST_ATK_PCT, amt)
    mt.updateTotalAtk(u)

    return after
end
--------------------------------------------------------------------------------------
mt[ST_PHY_DEF_PCT] = function(u, amt)
    local after = mt.generalModifier(u, ST_PHY_DEF_PCT, amt)
    mt.updateTotalPhyDef(u)

    return after
end
--------------------------------------------------------------------------------------
mt[ST_MAG_DEF_PCT] = function(u, amt)
    local after = mt.generalModifier(u, ST_MAG_DEF_PCT, amt)
    mt.updateTotalMagDef(u)

    return after
end
--------------------------------------------------------------------------------------
mt[ST_BLOCK_PCT] = function(u, amt)
    local after = mt.generalModifier(u, ST_BLOCK_PCT, amt)
    mt.updateTotalBlock(u)

    return after
end
--------------------------------------------------------------------------------------
mt[ST_MOVE_SPEED_PCT] = function(u, amt)
    local after = mt.generalModifier(u, ST_MOVE_SPEED_PCT, amt)
    mt.updateTotalMoveSpeed(u)

    return after
end
--------------------------------------------------------------------------------------
mt[ST_MAIN_PCT] = function(u, amt)
    local statsType = u:getMainStatsType()
    local modType = ST_STR_PCT
    if statsType == ST_AGI then
        modType = ST_AGI_PCT
    elseif statsType == ST_INT then
        modType = ST_INT_PCT
    end
    return u:modStats(modType, amt)
end
--------------------------------------------------------------------------------------
mt[ST_SIDE_PCT] = function(u, amt)
    local statsType = u:getMainStatsType()
    if statsType == ST_AGI then
        local modType = ST_INT_PCT
        local modType1 = ST_STR_PCT
        u:modStats(modType, amt)
        u:modStats(modType1, amt)
        return
    elseif statsType == ST_INT then
        local modType = ST_AGI_PCT
        local modType1 = ST_STR_PCT
        u:modStats(modType, amt)
        u:modStats(modType1, amt)
        return
    elseif statsType == ST_STR then
        local modType = ST_AGI_PCT
        local modType1 = ST_INT_PCT
        u:modStats(modType, amt)
        u:modStats(modType1, amt)
        return
    end
end
--------------------------------------------------------------------------------------
mt[ST_ALL_PCT] = function(u, amt)
    u:modStats(ST_STR_PCT, amt)
    u:modStats(ST_AGI_PCT, amt)
    u:modStats(ST_INT_PCT, amt)
    return
end
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function mt.updateTotalHpRegen(u)
    local total = u:getStats(ST_BASE_HP_REGEN) * (1 + u:getStats(ST_HP_REGEN_PCT)) + u:getStats(ST_BONUS_HP_REGEN)
    u.statsTable[ST_HP_REGEN] = total

    return total
end
--------------------------------------------------------------------------------------
-- 血量上限
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function mt.updateTotalHpMax(u)
    local total = u:getStats(ST_BASE_HP_MAX) * (1 + u:getStats(ST_HP_MAX_PCT)) + u:getStats(ST_BONUS_HP_MAX)
    u.statsTable[ST_HP_MAX] = total

    -- gdebug(str.format('base: %.0f, pct: %.0f,bonus: %.0f', u:getStats(ST_BASE_HP_MAX), u:getStats(ST_HP_MAX_PCT),
    --     u:getStats(ST_BONUS_HP_MAX)))

    --     print(debug.traceback())

    local hpPct = u:getStats(ST_HP_PCT)
    if u:isRemoved() then
        return
    end
    SetUnitState(u.handle, ConvertUnitState(1), total)

    u:setStats(ST_HP_PCT, hpPct)

    return total
end
--------------------------------------------------------------------------------------
mt[ST_BASE_HP_MAX] = function(u, amt)
    local after = mt.generalModifier(u, ST_BASE_HP_MAX, amt)
    mt.updateTotalHpMax(u)
    return after
end
--------------------------------------------------------------------------------------
mt[ST_BONUS_HP_MAX] = function(u, amt)
    local after = mt.generalModifier(u, ST_BONUS_HP_MAX, amt)
    mt.updateTotalHpMax(u)

    return after
end
mt[ST_HP_MAX] = mt[ST_BONUS_HP_MAX]
--------------------------------------------------------------------------------------
mt[ST_HP_MAX_PCT] = function(u, amt)
    local after = mt.generalModifier(u, ST_HP_MAX_PCT, amt)
    mt.updateTotalHpMax(u)

    u:refreshStats(ST_HP_MAX)
    return after
end
--------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------
mt[ST_BASE_HP_REGEN] = function(u, amt)
    local after = mt.generalModifier(u, ST_BASE_HP_REGEN, amt)
    mt.updateTotalHpRegen(u)
    return after
end
--------------------------------------------------------------------------------------
mt[ST_BONUS_HP_REGEN] = function(u, amt)
    local after = mt.generalModifier(u, ST_BONUS_HP_REGEN, amt)
    mt.updateTotalHpRegen(u)

    return after
end
mt[ST_HP_REGEN] = mt[ST_BONUS_HP_REGEN]
--------------------------------------------------------------------------------------
mt[ST_HP_REGEN_PCT] = function(u, amt)
    local after = mt.generalModifier(u, ST_HP_REGEN_PCT, amt)
    mt.updateTotalHpRegen(u)

    return after
end
--------------------------------------------------------------------------------------
mt[ST_ATK_SPEED] = function(u, amt)
    local after = mt.generalModifier(u, ST_ATK_SPEED, amt)
    SetUnitState(u.handle, ConvertUnitState(81), after)

    u:refreshStats(ST_ATK_INTERVAL)

    return after
end
--------------------------------------------------------------------------------------
mt[ST_ATK_INTERVAL_REDUCE] = function(u, amt)
    local after = mt.generalModifier(u, ST_ATK_INTERVAL_REDUCE, amt)

    u:refreshStats(ST_ATK_INTERVAL)

    return after
end
--------------------------------------------------------------------------------------
mt[ST_ATK_INTERVAL] = function(u, amt)
    local atkIntervalReduce = u:getStats(ST_ATK_INTERVAL_REDUCE)
    local defaultAtkInterval = u:getSlkData('cool1')
    local atkInterval = defaultAtkInterval - atkIntervalReduce
    local modAtkInterval = atkInterval / math.max(math.min(u:getStats(ST_ATK_SPEED), MAX_ATK_SPEED) / 5, 1)

    SetUnitState(u.handle, ConvertUnitState(0x25), modAtkInterval)

    return modAtkInterval
end
--------------------------------------------------------------------------------------
-- 边际递减属性
--------------------------------------------------------------------------------------
mt[ST_PHY_RATE] = function(u, amt)
    local after = mt.generalModifier(u, ST_PHY_RATE, amt)

    return after
end
--------------------------------------------------------------------------------------
mt[ST_MAG_RATE] = function(u, amt)
    local after = mt.generalModifier(u, ST_MAG_RATE, amt)

    return after
end
--------------------------------------------------------------------------------------
mt[ST_SUMMON_RATE] = function(u, amt)
    local after = mt.generalModifier(u, ST_SUMMON_RATE, amt)
    local summonAmp = ConvertSummonRateToAmp(after)

    u.statsTable[ST_SUMMON_AMP] = summonAmp
    return after
end
--------------------------------------------------------------------------------------
mt[ST_CD_SPEED] = function(u, amt)
    local after = mt.generalModifier(u, ST_CD_SPEED, amt)
    local amp = ConvertFunctionInverse1(after)

    u.statsTable[ST_CD_AMP] = amp
    return after
end
--------------------------------------------------------------------------------------
mt[ST_PHY_PENETRATE] = function(u, amt)
    local after = mt.generalModifier(u, ST_PHY_PENETRATE, amt)
    local amp = ConvertFunctionInverse1(after)

    return after
end
--------------------------------------------------------------------------------------
mt[ST_MAG_PENETRATE] = function(u, amt)
    local after = mt.generalModifier(u, ST_MAG_PENETRATE, amt)
    local amp = ConvertFunctionInverse1(after)

    return after
end
--------------------------------------------------------------------------------------
mt[ST_SEC_MAIN] = function(u, amt)
    local statsType = u:getMainStatsType()
    local modType = ST_SEC_STR
    if statsType == ST_AGI then
        modType = ST_SEC_AGI
    elseif statsType == ST_INT then
        modType = ST_SEC_INT
    end
    return u:modStats(modType, amt)
end
--------------------------------------------------------------------------------------
mt[ST_SEC_ALL] = function(u, amt)
    return u:modStats(ST_SEC_STR, amt) + u:modStats(ST_SEC_AGI, amt) + u:modStats(ST_SEC_INT, amt)
end
--------------------------------------------------------------------------------------
mt[ST_GROW_MAIN] = function(u, amt)
    local statsType = u:getMainStatsType()
    local modType = ST_GROW_STR
    if statsType == ST_AGI then
        modType = ST_GROW_AGI
    elseif statsType == ST_INT then
        modType = ST_GROW_INT
    end

    return u:modStats(modType, amt)
end
--------------------------------------------------------------------------------------
mt[ST_GROW_ALL] = function(u, amt)
    return u:modStats(ST_GROW_STR, amt) + u:modStats(ST_GROW_AGI, amt) + u:modStats(ST_GROW_INT, amt)
end
--------------------------------------------------------------------------------------
mt[ST_GROW_MAIN_PCT] = function(u, amt)
    local statsType = u:getMainStatsType()
    local modType = ST_GROW_STR_PCT
    if statsType == ST_AGI then
        modType = ST_GROW_AGI_PCT
    elseif statsType == ST_INT then
        modType = ST_GROW_INT_PCT
    end
    return u:modStats(modType, amt)
end
--------------------------------------------------------------------------------------
mt[ST_GROW_ALL_PCT] = function(u, amt)
    return u:modStats(ST_GROW_STR_PCT, amt) + u:modStats(ST_GROW_AGI_PCT, amt) + u:modStats(ST_GROW_INT_PCT, amt)
end
--------------------------------------------------------------------------------------
mt[ST_KILL_MAIN] = function(u, amt)
    local statsType = u:getMainStatsType()
    local modType = ST_KILL_STR
    if statsType == ST_AGI then
        modType = ST_KILL_AGI
    elseif statsType == ST_INT then
        modType = ST_KILL_INT
    end
    return u:modStats(modType, amt)
end
--------------------------------------------------------------------------------------
mt[ST_KILL_ALL] = function(u, amt)
    return u:modStats(ST_KILL_STR, amt) + u:modStats(ST_KILL_AGI, amt) + u:modStats(ST_KILL_INT, amt)
end
--------------------------------------------------------------------------------------
mt[ST_KILL_MAIN_PCT] = function(u, amt)
    local statsType = u:getMainStatsType()
    local modType = ST_KILL_STR_PCT
    if statsType == ST_AGI then
        modType = ST_KILL_AGI_PCT
    elseif statsType == ST_INT then
        modType = ST_KILL_INT_PCT
    end
    return u:modStats(modType, amt)
end
--------------------------------------------------------------------------------------
mt[ST_KILL_ALL_PCT] = function(u, amt)
    return u:modStats(ST_KILL_STR_PCT, amt) + u:modStats(ST_KILL_AGI_PCT, amt) + u:modStats(ST_KILL_INT_PCT, amt)
end
--------------------------------------------------------------------------------------
mt[ST_BASE_RANGE] = function(u, amt)
    local after = mt.generalModifier(u, ST_BASE_RANGE, amt)
    if u:isRemoved() then
        return
    end
    mt.updateTotalRange(u)
    return after
end
--------------------------------------------------------------------------------------
mt[ST_RANGE_PCT] = function(u, amt)
    local after = mt.generalModifier(u, ST_RANGE_PCT, amt)
    if u:isRemoved() then
        return
    end
    mt.updateTotalRange(u)
    return after
end
--------------------------------------------------------------------------------------

mt[ST_EXTRA_RANGE] = function(u, amt)
    local after = mt.generalModifier(u, ST_EXTRA_RANGE, amt)
    if u:isRemoved() then
        return
    end
    mt.updateTotalRange(u)
    return after
end
--------------------------------------------------------------------------------------
mt[ST_RANGE] = mt[ST_EXTRA_RANGE]
--------------------------------------------------------------------------------------
mt[ST_CRIT_CHANCE] = function(u, amt)
    mt.generalModifier(u, ST_PHY_CRIT_CHANCE, amt)
    mt.generalModifier(u, ST_MAG_CRIT_CHANCE, amt)
    return 0
end
--------------------------------------------------------------------------------------
mt[ST_CRIT_RATE] = function(u, amt)
    mt.generalModifier(u, ST_PHY_CRIT_RATE, amt)
    mt.generalModifier(u, ST_MAG_CRIT_RATE, amt)
    return 0
end
--------------------------------------------------------------------------------------
-- 只读属性
--------------------------------------------------------------------------------------
mt[ST_SUMMON_AMP] = function(u, amt)
    warn('prevent a direct change to ST_SUMMON_AMP')
    return u.statsTable[ST_SUMMON_AMP]
end
--------------------------------------------------------------------------------------
mt[ST_CD_AMP] = function(u, amt)
    warn('prevent a direct change to ST_CD_AMP')
    return u.statsTable[ST_CD_AMP]
end

--------------------------------------------------------------------------------------
mt[ST_RANDOM] = function(u, amt)
    local ttlVal = {0, 0, 0}

    for i = 1, amt do
        local rng = math.random(1, 3)
        ttlVal[rng] = ttlVal[rng] + 1
    end

    u:modStats(ST_STR, ttlVal[1])
    u:modStats(ST_AGI, ttlVal[2])
    u:modStats(ST_INT, ttlVal[3])

end
--------------------------------------------------------------------------------------
mt[ST_ITEM_RATE] = function(u, amt)
    local after = mt.generalModifier(u, ST_ITEM_RATE, amt)
    local amp = ConvertFunctionItemRate(after)

    u.statsTable[ST_TRUE_ITEM_RATE] = amp
    return after
end
--------------------------------------------------------------------------------------
-- 基础百分比类属性
mt[ST_BASE_ATK_PCT] = function(u, amt)
    u:modStats(ST_BASE_ATK, u:getStats(ST_BASE_ATK) * amt)

    return 0
end
--------------------------------------------------------------------------------------
mt[ST_BASE_PHY_DEF_PCT] = function(u, amt)
    u:modStats(ST_BASE_PHY_DEF, u:getStats(ST_BASE_PHY_DEF) * amt)

    return 0
end
--------------------------------------------------------------------------------------
mt[ST_BASE_MAG_DEF_PCT] = function(u, amt)
    u:modStats(ST_BASE_MAG_DEF, u:getStats(ST_BASE_MAG_DEF) * amt)

    return 0
end
--------------------------------------------------------------------------------------
mt[ST_BASE_HP_MAX_PCT] = function(u, amt)
    u:modStats(ST_BASE_HP_MAX, u:getStats(ST_BASE_HP_MAX) * amt)

    return 0
end
--------------------------------------------------------------------------------------
-- 玩家属性
--------------------------------------------------------------------------------------
mt[RES_GOLD] = function(p, amt)
    local after = mt.resourceModifier(p, RES_GOLD, amt)
    --SetPlayerStateBJ(p.handle, PLAYER_STATE_RESOURCE_GOLD, after)

    if p:isLocal() then
        GUI.ResourceGold:updateBoard()
    end

    return after
end
--------------------------------------------------------------------------------------
mt[RES_LUMBER] = function(p, amt)
    local after = mt.resourceModifier(p, RES_LUMBER, amt)
    --SetPlayerStateBJ(p.handle, PLAYER_STATE_RESOURCE_LUMBER, after)

    if p:isLocal() then
        GUI.ResourceCrystal:updateBoard()
    end

    return after
end
--------------------------------------------------------------------------------------
mt[RES_KILL] = function(p, amt)
    local after = mt.resourceModifier(p, RES_KILL, amt)
    --SetPlayerStateBJ(p.handle, PLAYER_STATE_RESOURCE_FOOD_USED, after)

    if p:isLocal() then
        GUI.ResourceKill:updateBoard()
    end

    return after
end
--------------------------------------------------------------------------------------
mt[RES_ROLL] = function(p, amt)
    local after = mt.resourceModifier(p, RES_ROLL, amt)

    if p:isLocal() then
        GUI.ResourceRoll:updateBoard()
    end

    return after
end
--------------------------------------------------------------------------------------
-- 基础函数
--------------------------------------------------------------------------------------
mt.generalModifier = function(obj, stats, amt)
    if not obj.statsTable[stats] then
        obj.statsTable[stats] = 0
    end

    obj.statsTable[stats] = obj.statsTable[stats] + amt

    -- local p = as.player:getLocalPlayer()
    -- if p.lastPick == obj and cst:getConstTag(stats, 'updateUI') then -- 正好时选择的单位
    --     gdebug('update ui: %s, %d', cst:getConstName(stats), amt)
    --     GUI.UnitInfo:updateBoard(obj)
    -- end

    return obj.statsTable[stats]
end
--------------------------------------------------------------------------------------
mt.resourceModifier = function(obj, stats, amt)
    if not obj.statsTable[stats] then
        obj.statsTable[stats] = 0
    end

    obj.statsTable[stats] = math.max(obj.statsTable[stats] + amt, 0)

    -- local p = as.player:getLocalPlayer()
    -- if p.lastPick == obj and cst:getConstTag(stats, 'updateUI') then -- 正好时选择的单位
    --     gdebug('update ui: %s, %d', cst:getConstName(stats), amt)
    --     GUI.UnitInfo:updateBoard(obj)
    -- end

    return obj.statsTable[stats]
end

--------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------
return mt
