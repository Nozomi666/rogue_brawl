local mt = {}
misc = mt
util = {}
--------------------------------------------------------------------------------------
function mt:implementTipColor(rawTip)
    local tip = rawTip
    tip = string.gsub(tip, '%<([%w_.>]*)%>', convertColor)

    return tip
end
--------------------------------------------------------------------------------------
function math.lerp(a, b, t)
    return a + (b - a) * t
end
--------------------------------------------------------------------------------------
function util.convertPct(name)
    local val = (tonumber(name) * 1)
    local formatted
    if val % 1 == 0 then -- 如果没有小数部分
        formatted = string.format("%.0f%%", val)
    else
        formatted = string.format("%.2g%%", val)
    end

    return formatted
end
--------------------------------------------------------------------------------------
convertPct = function(val)
    val = val * 100
    local formatted = string.format("%.2g%%", val)
    if val >= 99 then
        formatted = string.format("%.0f%%", val)
    end
    return formatted
end
--------------------------------------------------------------------------------------
function fc.filterUnitGroupInRange(selectorGroup, point, range, condition)
    local group = {}
    if not point then
        return group
    end

    if selectorGroup then
        for _, tgt in ipairs(selectorGroup) do
            local passTest = true

            if condition then
                passTest = condition(tgt)
            end

            if tgt:getloc() * point <= range and passTest then
                group[#group + 1] = tgt
            end
        end
    else
        print('selectorGroup is nil')
        if code.checkIsReply() == CLIENT_REPLY then
            traceError()
        end
    end

    return group
end
--------------------------------------------------------------------------------------
function fc.round(num, numDecimalPlaces)
    local mult = 10 ^ (numDecimalPlaces or 0)
    return math.floor(num * mult + 0.5) / mult
end
--------------------------------------------------------------------------------------
function mt:createStoreItemTip(table)
    local tip = ''
    for i, v in ipairs(table) do
        local statsType = v[1]
        local statsNum = v[2]
        local statsName = cst:getConstName(statsType)
        local statsNumText
        if math.floor(statsNum) == statsNum then
            statsNumText = str.format('|cffffcc00%d|r', statsNum)
        else
            statsNumText = str.format('|cffffcc00%.2f|r', statsNum)
        end

        if cst:getConstTag(v[1], 'isPct') then
            tip = tip .. statsName .. '+' .. statsNumText .. '%|n'
        else
            tip = tip .. statsName .. '+' .. statsNumText .. '|n'
        end
    end
    return tip
end
--------------------------------------------------------------------------------------
function mt:storeItemAddStats(unit, table)
    for i, v in ipairs(table) do
        local statsType = v[1]
        local statsNum = v[2]
        unit:modStats(v[1], v[2])
    end
end
--------------------------------------------------------------------------------------
function fc.getStatsTip(v, decimalPlace, noColor)
    local tip = ''
    local statsType = v[1]
    local statsNum = v[2]
    local statsName = cst:getConstName(statsType)
    local statsNumText

    if cst:getConstTag(v[1], 'isPct') then
        statsNum = statsNum * 100
    end

    decimalPlace = decimalPlace or 1
    local decimalStr = '%s%.'.. decimalPlace .. 'f|r'

    if  math.floor(statsNum) == statsNum then
        statsNumText = str.format('%s%d|r', noColor and '' or '|cffffcc00', statsNum)
    else
        statsNumText = str.format(decimalStr, noColor and '' or '|cffffcc00', statsNum)
    end

    local operator = '+'
    if statsNum < 0 then
        operator = ''
    end

    if cst:getConstTag(v[1], 'negateSign') then
        if statsNum < 0 then
            operator = '+'
        else
            operator = '-'
        end
    end

    if cst:getConstTag(v[1], 'isPct') then
        tip = tip .. statsName .. operator .. statsNumText .. '%'
    else
        tip = tip .. statsName .. operator .. statsNumText .. ''
    end
    return tip
end
--------------------------------------------------------------------------------------
function fc.getSlkSkillData(skillType, keyWord)
    return slk.ability[skillType][keyWord]
end
--------------------------------------------------------------------------------------
function fc.getDayMax(mapLv, table)
    local dayMax = 0
    for i, v in ipairs(table) do
        if mapLv >= v[1] then
            dayMax = v[2]
        end
    end
    return dayMax

end
--------------------------------------------------------------------------------------
function fc.getUnixDayToNow(earliestTime)
    local currentTime = os.time()
    if not localEnv then
        currentTime = gm.unixTime
    end

    local timeDiff = currentTime - earliestTime
    local timeDiffInDay = math.floor(timeDiff / 86400) + 1

    return timeDiffInDay
end
--------------------------------------------------------------------------------------
function fc.getUnixWeekToNow(earliestWeekTime)
    local currentTime = os.time()
    currentTime = gm.gameUnixTime
    if not localEnv then
        currentTime = gm.gameUnixTime
    end

    local diffTime = currentTime - earliestWeekTime
    local timeDiffInWeek = math.floor(diffTime / (7 * 24 * 60 * 60)) + 1

    return timeDiffInWeek
end
--------------------------------------------------------------------------------------
function fc.isMouseInBottomUI(x, y)
    if x >= 155 and x <= 1770 and y >= 810 and y <= 1070 then
        return true
    end
end
--------------------------------------------------------------------------------------
function fc.getMouseInItemSlot(x, y)
    if x >= 1200 and x <= 1255 and y >= 850 and y <= 905 then
        return 1
    elseif x >= 1275 and x <= 1335 and y >= 850 and y <= 905 then
        return 2
    elseif x >= 1200 and x <= 1255 and y >= 930 and y <= 985 then
        return 3
    elseif x >= 1275 and x <= 1335 and y >= 930 and y <= 985 then
        return 4
    elseif x >= 1200 and x <= 1255 and y >= 1005 and y <= 1065 then
        return 5
    elseif x >= 1275 and x <= 1335 and y >= 1005 and y <= 1065 then
        return 6
    end

    return nil
end
--------------------------------------------------------------------------------------
function fc.cloneVariantTable(oriTable)
    if not oriTable.__index then
        oriTable.__index = oriTable
    end
    local newTable = {}
    setmetatable(newTable, oriTable)
    return newTable
end
--------------------------------------------------------------------------------------
fc.rngStats = function()
    return cst.RNG_STATS[math.random(#cst.RNG_STATS)]
end
--------------------------------------------------------------------------------------
return mt
