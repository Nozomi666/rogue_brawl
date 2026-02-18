require("game.__api.stats_setter")

local mt = {}
StatsGetter = mt

--------------------------------------------------------------------------------------
mt[ST_HP_PCT] = function(u)
    return GetUnitLifePercent(u.handle) / 100
end
--------------------------------------------------------------------------------------
mt[ST_MP_PCT] = function(u)
    return GetUnitManaPercent(u.handle) / 100
end
--------------------------------------------------------------------------------------
mt[ST_HP] = function(u)
    return GetUnitState(u.handle, ConvertUnitState(0))
end
--------------------------------------------------------------------------------------
mt[ST_MP] = function(u)
    return GetUnitState(u.handle, ConvertUnitState(2))
end
--------------------------------------------------------------------------------------
mt[ST_ATK_SPEED] = function(u)
    return GetUnitState(u.handle, ConvertUnitState(81))
end
--------------------------------------------------------------------------------------
mt[ST_ATK_INTERVAL] = function(u)
    return GetUnitState(u.handle, ConvertUnitState(0x25))
end
--------------------------------------------------------------------------------------
mt[ST_MAIN] = function(u)
    local statsType = u:getMainStatsType()
    return u:getStats(statsType)
end
--------------------------------------------------------------------------------------
mt[ST_ALL] = function(u)
    return u:getStats(ST_STR) + u:getStats(ST_AGI) + u:getStats(ST_INT)
end
--------------------------------------------------------------------------------------
mt[ST_BASE_DOUBLE_DEF] = function(u, amt)
    return u:getStats(ST_BASE_PHY_DEF, amt) + u:getStats(ST_BASE_MAG_DEF, amt)
end
--------------------------------------------------------------------------------------
mt[ST_BONUS_MAIN] = function(u)
    local statsType = u:getMainStatsType()
    local getType = ST_BONUS_STR
    if statsType == ST_AGI then
        getType = ST_BONUS_AGI
    elseif statsType == ST_INT then
        getType = ST_BONUS_INT
    end
    return u:getStats(getType)
end
--------------------------------------------------------------------------------------
mt[ST_MAIN_PCT] = function(u)
    local statsType = u:getMainStatsType()
    local getType = ST_STR_PCT
    if statsType == ST_AGI then
        getType = ST_AGI_PCT
    elseif statsType == ST_INT then
        getType = ST_INT_PCT
    end
    return u:getStats(getType)
end
-- --------------------------------------------------------------------------------------
-- mt[CG_STATS_UNIT_BASE_AGI] = function(self)
--     return self:GetAgility()
-- end
-- --------------------------------------------------------------------------------------
-- mt[CG_STATS_UNIT_BASE_INT] = function(self)
--     return self:GetIntellect()
-- end
--------------------------------------------------------------------------------------
mt.generalGetter = function(obj, stats)
    if not obj.statsTable[stats] then
        obj.statsTable[stats] = 0
    end

    return obj.statsTable[stats]
end

--------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------
return mt
