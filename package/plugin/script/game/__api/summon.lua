local mt = {}
--------------------------------------------------------------------------------------
local statsFollowList = {}
table.insert(statsFollowList, ST_BASE_HP_MAX)
table.insert(statsFollowList, ST_HP_MAX_PCT)
table.insert(statsFollowList, ST_BASE_ATK)
table.insert(statsFollowList, ST_BONUS_ATK)
table.insert(statsFollowList, ST_ATK_PCT)
table.insert(statsFollowList, ST_PHY_DEF)
table.insert(statsFollowList, ST_MAG_DEF)
--------------------------------------------------------------------------------------
function UpdateSummonUnitStats(summon)

    local master = summon.master
    local statsPct = (summon.statsPct / 100) * (1 + ConvertFunctionInverse1(master:getStats(ST_SUMMON_AMP)) / 100)

    for _, statsName in ipairs(statsFollowList) do
        local masterVal = master:getStats(statsName)
        local modVal = masterVal * statsPct
        local prevVal = summon.baseStatsTable[statsName] or 0
        local trueModVal = modVal - prevVal
        summon:modStats(statsName, trueModVal)
        summon.baseStatsTable[statsName] = modVal
    end

    local modVal = master:getStats(ST_SUMMON_ATK_SPEED)
    local prevVal = summon.baseStatsTable[ST_ATK_SPEED] or 0
    local trueModVal = modVal - prevVal
    summon:modStats(ST_ATK_SPEED, trueModVal)
    summon.baseStatsTable[ST_ATK_SPEED] = modVal

end
--------------------------------------------------------------------------------------
function SummonUnit(keys)
    local uType = keys.uType
    local master = keys.master
    local p = master.owner
    local point = keys.point
    local face = keys.face or master:getFace()
    local time = keys.time

    keys.uType = uType

    time = time or 1
    time = time * (1 + ConvertFunctionInverse1(master:getStats(ST_SUMMON_TIME)) / 100)

    local summon = as.customUnit:createUnit(p, uType, point, face)
    summon.master = master
    summon.isSummon = true
    summon.statsPct = keys.statsPct
    summon.baseStatsTable = {}

    ApplyBuff({
        unit = master,
        tgt = summon,
        buffName = '召唤物',
        lv = 1,
        time = time
    })

    UpdateSummonUnitStats(summon)

    -- summon event

    xpcall(function()
        keys.summon = summon
        master:triggerEvent(UNIT_EVENT_ON_SUMMON, keys)
    end, function(msg)
        print(msg, debug.traceback())
    end)

    return summon
end
--------------------------------------------------------------------------------------
function mt.vanish(u)
    u:suicide()
    ShowUnitHide(u.handle)
    local eff = {
        model = [[Abilities\Spells\Human\MassTeleport\MassTeleportTarget.mdl]]
    }

    fc.pointEffect(eff, u:getloc())
end

--------------------------------------------------------------------------------------
return mt
