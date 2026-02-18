local mt = {}
--------------------------------------------------------------------------------------
function ConvertStrToHpPct(val)
    return val * STR_RATE_HP_PCT
end
--------------------------------------------------------------------------------------
function ConvertStrToPhyDmg(val)
    return val * STR_RATE_PHY_DMG
end
--------------------------------------------------------------------------------------
function ConvertAgiToAtkSpeed(val)
    return val * AGI_RATE_ATK_SPD
end
--------------------------------------------------------------------------------------
function ConvertAgiToAtkRate(val)
    return val * AGI_RATE_ATK_DMG
end
--------------------------------------------------------------------------------------
-- function ConvertAgiToPhyDef(val)
--     return val * (AGI_RATE_PHY_DEF_1 / (val + AGI_RATE_PHY_DEF_2)) * 1
-- end
--------------------------------------------------------------------------------------
function ConvertIntToSkillRate(val)
    return val * INT_RATE_SKILL_DMG
end
--------------------------------------------------------------------------------------
function ConvertIntToMagRate(val)
    return val * INT_RATE_MAG_DMG
end
--------------------------------------------------------------------------------------
function ConvertFunctionInverse1(val)
    if val < 0 then
        val = math.abs(val)
        return (1 - 1 / ((val / 100) + 1)) * 100 * -1
    end

    return (1 - 1 / ((val / 100) + 1)) * 100
end
--------------------------------------------------------------------------------------
function ConvertFunctionItemRate(val)
    if val < 0 then
        val = math.abs(val)
        return (1 - 1 / ((val / 100) + 1)) * 100 * -1
    end

    return (1 - 1 / ((val / 100) + 1)) * 100
end
--------------------------------------------------------------------------------------
function ConvertFunctionEvade(acc, evade)
    if acc >= evade then
        return 0
    end

    return (1 - 1 / (((evade - acc) / (100 + acc)) + 1)) * 100
end
--------------------------------------------------------------------------------------
function ConvertPhyMagDefReduce(val)
    if val >= 0 then
        return val * 0.01 / (1 + val * 0.01)
    else
        val = math.abs(val)
        return val * 0.01 / (1 + val * 0.01) * -1
    end

end
--------------------------------------------------------------------------------------
function ConvertDmgRateToDamage(critRate, critResist)
    if critRate < 0 then
        return 0
    end

    if critResist < 0 then
        critRate = critRate + critResist * -1
        critResist = 0
    end

    -- x * (10 / (x + 1000 + 10 * 10)) * 100

    return critRate * (AMP_RATE_DMG_1 / (critRate + AMP_RATE_DMG_2 + critResist * 10)) * 100
end
--------------------------------------------------------------------------------------
function ConvertSummonRateToAmp(val)
    if val < 0 then
        return 0
    end
    return val * (AMP_RATE_SUMMON_1 / (val + AMP_RATE_SUMMON_2)) * 100
end
--------------------------------------------------------------------------------------
function ConvertDefRateReduce(val)
    if val >= 0 then
        return val * 0.01 / (1 + val * 0.01)
    else
        val = math.abs(val)
        return val * 0.01 / (1 + val * 0.01) * -1
    end

end
--------------------------------------------------------------------------------------
function ConvertFunctionCritRate(critRate, critResist)

    critRate = math.max(math.max(critRate, 0) * (math.max(0.05, 1 - critResist)), 0)

    -- critRate = math.max(math.max(critRate, 0) * (math.max(0, 1 - critResist)), 0)

    return critRate
end
--------------------------------------------------------------------------------------
function ConvertControlRate(controlRate, controlResist)
    if controlRate < 0 then
        controlResist = controlResist + controlRate * -1
    end

    if controlResist < 0 then
        controlRate = controlRate + controlResist * -1
        controlResist = 0
    end

    local finalRate = controlRate * 100 *
                          (AMP_RATE_CONTROL_1 / (controlRate * 100 + AMP_RATE_CONTROL_2 + controlResist * 100 * 10)) *
                          100
    if controlResist > 0 and finalRate <= 0 then
        finalRate = ConvertFunctionInverse1(controlResist * 100) * -1
    end

    return finalRate
end
--------------------------------------------------------------------------------------
function ConvertBigNumberToText(val)

    if val >= 1000000000000 then
        if val >= 1000000000000000 then
            return str.format('%.0f兆', val / 1000000000000)
        else
            return str.format('%.1f兆', val / 1000000000000)
        end

    elseif val >= 100000000 then
        if val >= 100000000000 then
            return str.format('%.0f亿', val / 100000000)
        else
            return str.format('%.1f亿', val / 100000000)
        end

    elseif val >= 10000 then
        if val >= 10000000 then
            return str.format('%.0f万', val / 10000)
        else
            return str.format('%.1f万', val / 10000)
        end

    end

    return str.format('%.0f', val)
end
--------------------------------------------------------------------------------------
function mt.critChance(val)
    return 1 - (100 / (math.max(0, val) + 100))
end
--------------------------------------------------------------------------------------
function mt.critRate(val)
    return 1 + math.max(0, val * (700 / (700 + val))) * 0.01
end
--------------------------------------------------------------------------------------
function mt.dmgTypeRate(val)
    if val >= 0 then
        val = val * 0.01
        return val * 3 / (val + 3)
    else
        val = math.abs(val)
        return math.max(-0.8, ((val * 0.01) / (1 + val * 0.01)) * -1)
    end
end
--------------------------------------------------------------------------------------
function mt.elementPowerRate(val)
    if val >= 0 then
        val = val * 0.01
        return val * 4 / (val + 4)
    else
        val = math.abs(val)
        return math.max(-0.8, ((val * 0.01) / (1 + val * 0.01)) * -1)
    end
end
--------------------------------------------------------------------------------------
function mt.healTypeRate(val)
    if val >= 0 then
        return 1 - (100 / (val + 100))
    else
        val = math.abs(val)
        return (1 - math.max(0.2, ((val * 0.01) / (1 + val * 0.01)))) * -1
    end
end
--------------------------------------------------------------------------------------
function mt.agiToAtkSpeed(val)
    return val * (150 / (val + 1500)) * 0.01
end
--------------------------------------------------------------------------------------
function mt.agiToArm(val)
    return val * (200 / (val + 4000))
end
--------------------------------------------------------------------------------------
function mt.intToMpMax(val)
    return val * (600 / (val + 3000))
end
--------------------------------------------------------------------------------------
function mt.intToMpRegen(val)
    return 0.2 * val * (10 / (0.2 * val + 300))
end
--------------------------------------------------------------------------------------
function mt.cdRate(val)
    if val >= 0 then
        val = val * 0.01
        return val * 1 / (1 + val * 1.5)
    else
        return -(0.7 - 0.7 * (100 / (val * -1 + 100)))
    end

end
--------------------------------------------------------------------------------------
function mt.lifeSteal(x)
    x = x * 0.01
    return x * 0.5 / (x + 0.5)
end
--------------------------------------------------------------------------------------
function GetFightPower(name)
    if not FightPowerDefine[name] then
        gdebug('get fight power fail: ' .. name)
        return 0
    end

    local fpVal = FightPowerDefine[name].val
    return fpVal
end
--------------------------------------------------------------------------------------
function math.round(val)
    return math.floor(val + 0.5)
end
--------------------------------------------------------------------------------------
return mt
