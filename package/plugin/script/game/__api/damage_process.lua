local runtime = require 'jass.runtime'
local error_handle = runtime.error_handle

local flowtext = require 'game.__api.flowtext'

local mt = {}

mt.delayAction = {}


--------------------------------------------------------------------------------------
-- 处理攻击特效（延迟）
local processAtkOnHit = function(keys)
    keys.unit:triggerEvent(UNIT_EVENT_ON_ATK, keys)
    keys.tgt:triggerEvent(UNIT_EVENT_ON_ATKED, keys)
end

--------------------------------------------------------------------------------------
function ApplyDamage(keys)

    if not keys.dmg then
        return
    end

    keys.oriDmg = keys.dmg

    local unit = keys.unit

    local tgt = keys.tgt

    unit:triggerEvent(UNIT_EVENT_DMG_VERY_BEGINNING, keys)
    local dmgType = keys.dmgType

    if dmgType == DMG_TYPE_AUTO then
        if unit:getStats(ST_MAG_RATE) > unit:getStats(ST_PHY_RATE) then
            dmgType = DMG_TYPE_MAGICAL
        else
            dmgType = DMG_TYPE_PHYSICAL
        end
    end

    if unit.baseType ~= 'unit' then
        print('Damage attacker is not unit!!!')
        return
    end

    if tgt.baseType ~= 'unit' then
        print(debug.traceback())
        print('Damage receiver is not unit!!!')
        return
    end

    if tgt.dead then
        return
    end
    keys.critChance = keys.critChance or 0
    keys.critRate = keys.critRate or 0
    keys.dmgRate = keys.dmgRate or 0
    keys.defRate = keys.defRate or 0
    keys.defPenerate = keys.defPenerate or 0
    keys.receiveExtraRate = keys.receiveExtraRate or 0

    if unit.removed or tgt.removed then
        return
    end

    if tgt.immuneCounter > 0 then
        flowtext.printImmune(unit, tgt)
        return
    end

    keys.evade = math.min(tgt.statsTable[ST_EVADE], 0.8)
    keys.acc = unit.statsTable[ST_ACC]
    if not keys.acc then
        keys.acc = 0
        error(str.format('Apply Damage No Acc, unit: %s, target: %s', unit:getName(), tgt:getName()))
        if unit.name then
            print('error unit name: ' .. unit.name)
        else
            print('error unit no name')
        end
    end
    if keys.evade > 0 and math.randomPct() < keys.evade and math.randomPct() >= keys.acc then
        -- print('tgt evade dmg')
        keys.tgt:triggerEvent(UNIT_EVENT_ON_EVADE, keys)
        flowtext.printEvade(unit, tgt)
        return
    end
    --------------------------------------------------------------------------------------
    -- 格挡修正
    keys.dmg = math.max(keys.dmg - tgt:getStats(ST_BLOCK), keys.dmg * 0.05)

    if keys.isAtk then
        tgt:modStats(ST_PHY_DEF, unit:getStats(ST_ATK_NERF_PHY_DEF) * -1)
        tgt:modStats(ST_MAG_DEF, unit:getStats(ST_ATK_NERF_MAG_DEF) * -1)
    end

    --------------------------------------------------------------------------------------
    -- 物理魔法系数计算
    if dmgType == DMG_TYPE_PHYSICAL then
        keys.def = tgt:getStats(ST_PHY_DEF)
        if keys.def > 0 then
            keys.def = math.max(keys.def - unit:getStats(ST_IGNORE_PHY_DEF), 0)
        end
        keys.defPenerate = keys.defPenerate + unit:getStats(ST_PHY_PENETRATE)
        keys.critChance = keys.critChance + unit:getStats(ST_PHY_CRIT_CHANCE)
        keys.critEvade = tgt:getStats(ST_CRIT_EVADE)
        keys.critRate = keys.critRate + unit:getStats(ST_PHY_CRIT_RATE)
        keys.critResist = tgt:getStats(ST_CRIT_RESIST)
        keys.dmgRate = keys.dmgRate + unit:getStats(ST_DMG_RATE) + unit:getStats(ST_PHY_RATE)
        keys.defRate = keys.defRate + tgt:getStats(ST_DEF_RATE) + tgt:getStats(ST_PHY_RESIST)
        keys.receiveExtraRate = keys.receiveExtraRate + tgt:getStats(ST_RECEIVE_EXTRA_PHY_DMG)
    elseif dmgType == DMG_TYPE_MAGICAL then
        keys.def = tgt:getStats(ST_MAG_DEF)
        if keys.def > 0 then
            keys.def = math.max(keys.def - unit:getStats(ST_IGNORE_MAG_DEF), 0)
        end
        keys.defPenerate = keys.defPenerate + unit:getStats(ST_MAG_PENETRATE)
        keys.critChance = keys.critChance + unit:getStats(ST_MAG_CRIT_CHANCE)
        keys.critEvade = tgt:getStats(ST_CRIT_EVADE)
        keys.critRate = keys.critRate + unit:getStats(ST_MAG_CRIT_RATE)
        keys.critResist = tgt:getStats(ST_CRIT_RESIST)
        keys.dmgRate = keys.dmgRate + unit:getStats(ST_DMG_RATE) + unit:getStats(ST_MAG_RATE)
        keys.defRate = keys.defRate + tgt:getStats(ST_DEF_RATE) + tgt:getStats(ST_MAG_RESIST)
        keys.receiveExtraRate = keys.receiveExtraRate + tgt:getStats(ST_RECEIVE_EXTRA_MAG_DMG)
    elseif dmgType == DMG_TYPE_MIX then
        keys.def = (tgt:getStats(ST_PHY_DEF) + tgt:getStats(ST_MAG_DEF)) / 2
        if keys.def > 0 then
            keys.def = math.max(keys.def - (unit:getStats(ST_IGNORE_PHY_DEF) + unit:getStats(ST_IGNORE_MAG_DEF)) / 2, 0)
        end
        keys.defPenerate = keys.defPenerate + (unit:getStats(ST_PHY_PENETRATE) + unit:getStats(ST_MAG_PENETRATE)) / 2
        keys.critChance = keys.critChance + (unit:getStats(ST_PHY_CRIT_CHANCE) + unit:getStats(ST_MAG_CRIT_CHANCE)) / 2
        keys.critEvade = tgt:getStats(ST_CRIT_EVADE)
        keys.critRate = keys.critRate + (unit:getStats(ST_PHY_CRIT_RATE) + unit:getStats(ST_MAG_CRIT_RATE)) / 2
        keys.critResist = tgt:getStats(ST_CRIT_RESIST)
        keys.dmgRate = keys.dmgRate + unit:getStats(ST_DMG_RATE) +
                           (unit:getStats(ST_PHY_RATE) + unit:getStats(ST_MAG_RATE)) / 2
        keys.defRate = keys.defRate + tgt:getStats(ST_DEF_RATE) +
                           (tgt:getStats(ST_PHY_RESIST) + tgt:getStats(ST_PHY_RESIST)) / 2
        keys.receiveExtraRate = keys.receiveExtraRate +
                                    (tgt:getStats(ST_RECEIVE_EXTRA_PHY_DMG) + tgt:getStats(ST_RECEIVE_EXTRA_MAG_DMG)) /
                                    2
    elseif dmgType == DMG_TYPE_PURE then
        keys.def = (tgt:getStats(ST_PURE_DEF))
        keys.defPenerate = 0
        keys.critChance = keys.critChance + unit:getStats(ST_PHY_CRIT_CHANCE)
        keys.critEvade = tgt:getStats(ST_CRIT_EVADE)
        keys.critRate = keys.critRate + unit:getStats(ST_PHY_CRIT_RATE)
        keys.critResist = tgt:getStats(ST_CRIT_RESIST)
        keys.dmgRate = keys.dmgRate + unit:getStats(ST_DMG_RATE) + unit:getStats(ST_PHY_RATE)
        keys.defRate = keys.defRate + tgt:getStats(ST_DEF_RATE) + tgt:getStats(ST_PHY_RESIST)
        keys.receiveExtraRate = keys.receiveExtraRate + tgt:getStats(ST_RECEIVE_EXTRA_PHY_DMG)
    elseif dmgType == DMG_TYPE_FIX then
        keys.def = 0
        keys.critChance = 0
        keys.critEvade = 0
        keys.critRate = 0
        keys.critResist = 0
        keys.dmgRate = 0
        keys.defRate = 0
    end

    if keys.isAtk or keys.isSplash then
        keys.critRate = keys.critRate + unit:getStats(ST_ATK_CRIT_RATE)
        keys.defRate = keys.defRate + tgt:getStats(ST_ATK_DEF_RATE)
    else
        keys.critRate = keys.critRate + unit:getStats(ST_SKILL_CRIT_RATE)
        keys.defRate = keys.defRate + tgt:getStats(ST_SKILL_DEF_RATE)
        -- gdebug('skill def rate: %.2f', tgt:getStats(ST_SKILL_DEF_RATE))
    end

    keys.receiveExtraRate = keys.receiveExtraRate + tgt:getStats(ST_RECEIVE_EXTRA_DMG)

    if keys.def > 0 then
        keys.def = keys.def * (1 - ConvertFunctionInverse1(keys.defPenerate))
    end

    --------------------------------------------------------------------------------------
    -- 敌人类型增伤系数计算
    local eType = tgt.eType
    if eType then
        if eType == ENEMY_TYPE_BOSS then
            keys.dmgRate = keys.dmgRate + unit:getStats(ST_BOSS_DMG_RATE)
        elseif eType == ENEMY_TYPE_ELITE then
            keys.dmgRate = keys.dmgRate + unit:getStats(ST_ELITE_DMG_RATE)
        else
            keys.dmgRate = keys.dmgRate + unit:getStats(ST_CREEP_DMG_RATE)
        end
    end

    if keys.isAtk or keys.isSplash then
        keys.dmgRate = keys.dmgRate + unit:getStats(ST_ATK_RATE)
    else
        keys.dmgRate = keys.dmgRate + unit:getStats(ST_SKILL_RATE)
    end

    if tgt.bChallenge then
        keys.dmgRate = keys.dmgRate + unit:getStats(ST_CHALLENGE_DMG_RATE)
        if keys.dmgType == DMG_TYPE_PHYSICAL then
            keys.dmgRate = keys.dmgRate + unit:getStats(ST_CHALLENGE_DMG_RATE_PHY)
        elseif keys.dmgType == DMG_TYPE_MAGICAL then
            keys.dmgRate = keys.dmgRate + unit:getStats(ST_CHALLENGE_DMG_RATE_PHY)
        end
    end


    unit:triggerEvent(UNIT_EVENT_DMG_CALC, keys)

    --------------------------------------------------------------------------------------
    -- 护甲魔抗伤害修正
    local phyMagReduce = ConvertPhyMagDefReduce(keys.def)
    -- gdebug('phyMagReduce: %.2f', phyMagReduce)

    keys.dmg = keys.dmg * (1 - (phyMagReduce))

    --------------------------------------------------------------------------------------
    -- 暴击伤害修正
    local trueCritChance = keys.critChance * (1 - keys.critEvade)
    if math.randomPct() < trueCritChance then
        keys.isCrit = true
    end

    if keys.bNoAugment then
        keys.isCrit = false
    end

    if keys.isCrit then

        -- local trueCritRate = keys.critRate * (1 - math.min(keys.critResist, 1))

        local trueCritRate = ConvertFunctionCritRate(keys.critRate, keys.critResist)

        -- if localEnv then
        --     gdebug('trueCritRate: %.2f', trueCritRate)
        -- end

        keys.dmg = keys.dmg * (1 + trueCritRate)

        unit:triggerEvent(UNIT_EVENT_DMG_CALC_AFTER_CRIT, keys)

    end

    --------------------------------------------------------------------------------------
    -- 伤害系数修正
    local amp = keys.dmgRate

    local defRateReduce = ConvertDefRateReduce(keys.defRate * 100)
    -- gdebug('defRateReduce: %.2f', defRateReduce)
    -- gdebug('amp: %.2f', amp)
    -- gdebug('dmg before amp: %.0f', keys.dmg)
    keys.dmg = keys.dmg * (1 + amp) * (1 - defRateReduce)

    --------------------------------------------------------------------------------------
    -- 易伤乘区修正
    keys.dmg = keys.dmg * (1 + keys.receiveExtraRate)

    --------------------------------------------------------------------------------------
    -- 减伤事件修正
    keys.tgt:triggerEvent(UNIT_EVENT_ON_REDUCE_DMG, keys)
    -- gdebug('dmg before reduce dmg: %.0f', keys.dmg)
    keys.dmg = keys.dmg * (1 - tgt.totalDmgReduction)
    -- gdebug('dmg after reduce dmg: %.0f', keys.dmg)

    --------------------------------------------------------------------------------------
    -- 最终增伤修正
    keys.dmg = keys.dmg * math.max((1 + unit.statsTable[ST_FINAL_DMG_PCT]), 0) *
                   math.max(0, (1 - tgt.statsTable[ST_FINAL_REDUCE_DMG_PCT]))
    if test.bCheckDmg then
        -- gdebug('dmg after final dmg pct: %.0f', keys.dmg)
        -- gdebug('------------------------------------------------------------')
    end

    if dmgType == DMG_TYPE_FIX then
        keys.dmg = tonumber(keys.oriDmg)
        -- keys.dmg = keys.oriDmg
        -- print('fix dmg: ' .. keys.dmg)
        -- print('ori dmg: ' .. keys.oriDmg)
    end

    if unit.player.ceEngineUsed and (not localEnv) and (not MAP_DEBUG_MODE) then
        keys.dmg = math.random(1, 10000)
    end

    tgt:triggerEvent(UNIT_EVENT_ON_TAKE_DMG_BEFORE_CALC, keys)
    unit:triggerEvent(UNIT_EVENT_BEFORE_DEAL_DAMAGE, keys)
    tgt.lastDmgFrom = unit
    tgt.lastDmg = keys

    -- if EnemyManager.diffNum > 12 and gm.gameMin <= 2 and keys.dmg > 100000 * 10000 * 10000 then
    --     gdebug('damage too high: %.0f', keys.dmg)
    --     traceError()

    --     if not unit.player.addedCheat then
    --         unit.player.addedCheat = true
    --         unit.player:modSimpleArch(INT_STORAGE.CHEAT_TEST, 1)
    --     end

    -- end

    local shieldAmt = tgt:getStats(ST_SHIELD_AMT)
    if shieldAmt > 0 then
        local blockedDmg = math.min(shieldAmt, keys.dmg * (1 + unit:getStats(ST_SHIELD_BREAK_RATE)))
        if dmgType == DMG_TYPE_PHYSICAL then
            blockedDmg = math.min(shieldAmt, keys.dmg *
                (1 + unit:getStats(ST_SHIELD_BREAK_RATE) + unit:getStats(ST_SHIELD_BREAK_RATE_PHY)))
        elseif dmgType == DMG_TYPE_MAGICAL then
            blockedDmg = math.min(shieldAmt, keys.dmg *
                (1 + unit:getStats(ST_SHIELD_BREAK_RATE) + unit:getStats(ST_SHIELD_BREAK_RATE_MAG)))
        end

        local leftDmg = math.max(keys.dmg - blockedDmg, 0)
        tgt:modStats(ST_SHIELD_AMT, blockedDmg * -1)
        if leftDmg > 0 then
            tgt:modStats(ST_HP, leftDmg * -1)
            tgt:triggerEvent(UNIT_EVENT_ON_HERO_HP_REDUCE, keys)
            unit:triggerEvent(UNIT_EVENT_ON_BREAK_SHIELD, keys)
            tgt:triggerEvent(UNIT_EVENT_ON_SHIELD_BROKEN, keys)
        end

    else
        tgt:modStats(ST_HP, keys.dmg * -1)
        tgt:triggerEvent(UNIT_EVENT_ON_HERO_HP_REDUCE, keys)
    end

    if keys.isAtk then
        unit:triggerEvent(UNIT_EVENT_ON_ATK, keys)
        tgt:triggerEvent(UNIT_EVENT_ON_ATKED, keys)
    end

    unit:triggerEvent(UNIT_EVENT_ON_DEAL_DMG, keys)
    tgt:triggerEvent(UNIT_EVENT_ON_TAKE_DMG, keys)

    -- if localEnv then
    --     gdebug('dmg after final dmg pct: %.0f', keys.dmg)
    -- end

    -- 显示伤害
    if keys.dmg > 0 then
        flowtext.printDmg(unit, tgt, keys.dmg, dmgType, keys.isCrit)
    end

end

--------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------
-- 添加进循环
function mt:delay(func)
    table.insert(mt.delayAction, func)
    -- mt.delayAction[func] = func
end

local function updateDelay()

    local tbl = {}
    while #mt.delayAction > 0 do
        tbl[#tbl + 1] = table.remove(mt.delayAction, 1)
    end

    for i = 1, #tbl do
        local func = tbl[i]
        local act = func.act
        local keys = func.keys
        act(keys)
    end

end

--------------------------------------------------------------------------------------
function mt.update()
    -- mapdebug('running')
    xpcall(updateDelay, error_handle)
    -- updateDelay()
end

return mt
