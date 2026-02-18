as.point = require 'ac.point'

local mt = {}
as.util = mt

--------------------------------------------------------------------------------------
function mapdebug(msg, ...)
    if (MAP_DEBUG_MODE) or REPLY_MODE then
        -- print(debug.traceback())

        msg = str.format(msg, ...)
        print(str.format('[Debug] - %s', msg))

        if (MAP_TRACE_BACK) then
            print '↑------------------↑'
            print(debug.traceback())
            print '--------------------'
        end
    end
end
--------------------------------------------------------------------------------------
gdebug = mapdebug
plainGdebug = function(msg)
    if (MAP_DEBUG_MODE) then
        -- print(debug.traceback())
        print(str.format('[Debug] - %s', msg))

        if (MAP_TRACE_BACK) then
            print '↑------------------↑'
            print(debug.traceback())
            print '--------------------'
        end
    end
end
--------------------------------------------------------------------------------------
function warn(str)
    print("[Warning] - " .. (str or ''))
end
--------------------------------------------------------------------------------------
function archlog(msg, ...)
    msg = str.format(msg, ...)
    print(str.format('[Arch] - %s', msg))
end
--------------------------------------------------------------------------------------
function ms(time)
    return time * 1000
end
--------------------------------------------------------------------------------------
function mt:angleBetweenJUnits(from, to)
    return as.point:getJUnitLoc(from) / as.point:getJUnitLoc(to)
end

--------------------------------------------------------------------------------------
function mt:angleBetweenUnits(from, to)
    return as.point:getUnitLoc(from) / as.point:getUnitLoc(to)
end
--------------------------------------------------------------------------------------
function fc.angleBetweenUnits(from, to)
    return as.point:getUnitLoc(from) / as.point:getUnitLoc(to)
end

--------------------------------------------------------------------------------------
function mt:angleBetweenUnitPoint(unit, point)

    local p1 = as.point:getUnitLoc(unit)
    return p1 / point

end
--------------------------------------------------------------------------------------
function mt:random()
    return math.random(100) / 100
end

--------------------------------------------------------------------------------------
function mt:randomPct()
    return math.random(100) / 100
end

--------------------------------------------------------------------------------------
function randomPct()
    return math.random(100) / 100
end

--------------------------------------------------------------------------------------
function mt:randomBtw(a, b)
    return a + (b - a) * mt:randomPct()
end
--------------------------------------------------------------------------------------
function math.randomPct()
    return math.random(100) / 100
end
--------------------------------------------------------------------------------------
function math.randomReal(a, b)
    return a + (b - a) * math.random(0, 100) / 100
end
--------------------------------------------------------------------------------------
function math.failPctTest(chance)
    local rng = math.randomPct()
    return rng > chance
end

--------------------------------------------------------------------------------------
function mt:convertPct(number)
    local val = number

    return str.format('%.01f%%', val)
end

--------------------------------------------------------------------------------------
function YDWEGetRect(x, y, width, height)
    return Rect(x - width * 0.5, y - height * 0.5, x + width * 0.5, y + height * 0.5)
end

--------------------------------------------------------------------------------------
function mt:splitStr(inputstr, sep)
    sep = sep or '%s'
    local t = {}
    for field, s in string.gmatch(inputstr, "([^" .. sep .. "]*)(" .. sep .. "?)") do
        table.insert(t, field)
        if s == "" then
            return t
        end
    end
    return t
end
--------------------------------------------------------------------------------------
local prd = {}
function mt:prdAdd(id, chance)
    if not prd[id] then
        prd[id] = 0
    end

    prd[id] = prd[id] + chance

    return prd[id]
end
--------------------------------------------------------------------------------------
function mt:prdReset(id)
    prd[id] = 0
end
--------------------------------------------------------------------------------------
function mt:prdRoll(id, chance)
    local chance = mt:prdAdd(id, chance)
    local outcome = false

    if as.util:randomPct() <= chance then
        outcome = true
        mt:prdReset(id)
    end

    return outcome
end
--------------------------------------------------------------------------------------
function mt:prdCheck(id)
    if not prd[id] then
        prd[id] = 0
    end
    return prd[id]
end
--------------------------------------------------------------------------------------
function mt:shakeScreen(u, direct, amp)
    local p = u.owner
    direct = mt:randomPct() < direct and -1 or 1

    if (as.player:pj2t(GetLocalPlayer()) == p) then
        local screenPoint = ac.point:new(GetCameraTargetPositionX(), GetCameraTargetPositionY(), 0)
        if screenPoint * u:getLoc() < 1200 then
            SetCameraFieldForPlayer(p.handle, CAMERA_FIELD_ROTATION, 90 + direct * amp, 0.02)
        end
    end

    ac.timer(35, 1, function()
        SetCameraFieldForPlayer(p.handle, CAMERA_FIELD_ROTATION, 90, 0.02)
    end)

end
--------------------------------------------------------------------------------------
local cdTable = {}
--------------------------------------------------------------------------------------
function mt:setInnerCd(parentKey, childKey, time)
    if not cdTable[parentKey] then
        cdTable[parentKey] = {}
    end

    if not cdTable[parentKey][childKey] then
        cdTable[parentKey][childKey] = true
        cdTable[parentKey][childKey] = ac.timer(ms(time), 1, function()
            cdTable[parentKey][childKey] = false
        end)
    end
end
--------------------------------------------------------------------------------------
function mt:getInnerCd(parentKey, childKey)
    if not cdTable[parentKey] then
        cdTable[parentKey] = {}
    end

    return cdTable[parentKey][childKey] -- return false or ture
end
--------------------------------------------------------------------------------------
function mt:isInCd(parentKey, childKey)
    if not cdTable[parentKey] then
        cdTable[parentKey] = {}
    end

    return cdTable[parentKey][childKey]
end
--------------------------------------------------------------------------------------
fc.isInCd = function(parentKey, childKey)
    return mt:isInCd(parentKey, childKey)
end
--------------------------------------------------------------------------------------
fc.setInnerCd = function(parentKey, childKey, time)
    return mt:setInnerCd(parentKey, childKey, time)
end
--------------------------------------------------------------------------------------
fc.shuffleTable = function(tb)
    for i = 1, #tb - 1 do
        local j = math.random(i, #tb)
        tb[i], tb[j] = tb[j], tb[i]
    end

    return tb
end
--------------------------------------------------------------------------------------
fc.rngSelect = function(tb)
    if #tb <= 0 then
        return nil
    end

    return tb[math.random(#tb)]
end
--------------------------------------------------------------------------------------
fc.randomRemove = function(tb)
    if #tb <= 0 then
        return nil
    end

    local element = tb[math.random(#tb)]
    table.removeTarget(tb, element)
    return element
end
--------------------------------------------------------------------------------------
fc.createGrowTable = function(keys)
    local baseVal = keys.baseVal
    local lastVal = keys.lastVal
    local rateLv = keys.rateLv
    local rateFix = keys.rateFix
    local maxLv = keys.maxLv
    local startLv = keys.startLv
    if not startLv then
        startLv = 1
    end
    local list = {}
    list[startLv] = baseVal
    for i = startLv + 1, maxLv do
        list[i] = (list[i - 1] * lastVal + i * rateLv + rateFix)
    end

    if keys.multiRate then
        for i = startLv, maxLv do
            list[i] = list[i] * keys.multiRate
        end
    end

    return list
end
--------------------------------------------------------------------------------------
function table.clone(org)
    return {table.unpack(org)}
end

--------------------------------------------------------------------------------------
function table.removeTarget(t, pack)
    local removed = nil

    if t then
        for i, v in ipairs(t) do
            if v == pack then
                removed = table.remove(t, i)
            end
        end
    else
        print('table.removeTarget is nil')
        if code.checkIsReply() == CLIENT_REPLY then
            traceError()
        end
    end

    return removed
end
--------------------------------------------------------------------------------------
function table.hasTarget(t, pack)
    local hasTarget = false
    for i, v in ipairs(t) do
        if v == pack then
            return pack
        end
    end

    return hasTarget
end
--------------------------------------------------------------------------------------
function table.multiInsert(t, node, time)
    for i = 1, time do
        t[#t + 1] = node
    end
end
--------------------------------------------------------------------------------------
function fc.asyncCheck(title)
    -- local ran = math.random(1,10000)
    -- local ran = 0
    -- gdebug(str.format('%s - 【%d】', title, ran))
end
--------------------------------------------------------------------------------------
-- closure
function fc.makePackTip(pack, tip)

    local getData = function(pack, name)
        local data = pack[name]
        local val = data
        return val or 0
    end

    local convertRate = function(name)
        return getData(pack, name)
    end

    -- closure
    local convertColor = function(name)
        return cst.COLOR_CODE[name]
    end

    -- closure
    local convertPct = function(name)
        if not name then
            name = 0
        end
        local val = (tonumber(name) * 1)
        local formatted
        if (val % 1 < 0.01) then
            formatted = string.format("%.0f%%", (tonumber(name) * 100))
        else
            formatted = string.format("%.1f%%", (tonumber(name) * 100))
        end

        return formatted
    end

    local tip = tip or pack.tip

    if tip then
        -- set tip
        tip = string.gsub(tip, '%<([%w_.>]*)%>', convertColor)
        tip = string.gsub(tip, '%$([%w_]*)%$', convertRate)
        tip = string.gsub(tip, '%[([%w_]*)%]', convertRate)
        tip = string.gsub(tip, '%%([%w_.]*)%%', convertPct)
    else
        tip = ''
    end
    return tip
end
--------------------------------------------------------------------------------------
function math.clamp(num, min, max)
    return math.min(math.max(num, min), max)
end
--------------------------------------------------------------------------------------
function fc.rewardRngEquip(rareLv, p)
    local equipName = as.dataRegister:getRandomEquip(rareLv)
    local args = {
        name = equipName,
        point = p.rewardPointEquip,
        owner = p,
    }
    local equip = as.equip:makeEquip(args)
    return equip
end
--------------------------------------------------------------------------------------
function fc.rewardList(rewardConfig, p, fromPoint)

    if not rewardConfig or not p then
        return
    end

    if not fromPoint then
        fromPoint = p.maid:getloc()
    end

    local hero = p.hero

    xpcall(function()
        for k, reward in ipairs(rewardConfig) do
            local rewardName = reward[1]
            local rewardNum = reward[2]
            msg.reward(p, str.format('%s×|cffffcc00%d|r', rewardName, rewardNum))

            if rewardName == '金币' then
                hero:addGold(rewardNum)
            elseif rewardName == '钻石' then
                hero:addLumber(rewardNum)
            elseif rewardName == '经验' then
                hero:addExp(rewardNum)
            elseif rewardName == '杀敌数' then
                hero:addKill(rewardNum)
            elseif rewardName == '赐福点' then
                hero:addBlessPoint()
            elseif rewardName == '专精点' then
                hero:addMemoryPoint()
            elseif rewardName == 'D级装备' then
                for i = 1, rewardNum, 1 do
                    fc.rewardRngEquip(1, p)
                end
            elseif rewardName == 'C级装备' then
                for i = 1, rewardNum, 1 do
                    fc.rewardRngEquip(2, p)
                end
            elseif rewardName == 'B级装备' then
                for i = 1, rewardNum, 1 do
                    fc.rewardRngEquip(3, p)
                end
            elseif rewardName == 'A级装备' then
                for i = 1, rewardNum, 1 do
                    fc.rewardRngEquip(4, p)
                end
            elseif rewardName == 'S级装备' then
                for i = 1, rewardNum, 1 do
                    fc.rewardRngEquip(5, p)
                end
            elseif rewardName == 'SS级装备' then
                for i = 1, rewardNum, 1 do
                    fc.rewardRngEquip(6, p)
                end
            elseif rewardName == 'SSS级装备' then
                for i = 1, rewardNum, 1 do
                    fc.rewardRngEquip(7, p)
                end
                -- elseif rewardName == 'C级躯改' then
                --    for i = 1, rewardNum, 1 do
                --        fc.rewardRngBodyReform(2, p)
                --    end
                -- elseif rewardName == 'B级躯改' then
                --    for i = 1, rewardNum, 1 do
                --        fc.rewardRngBodyReform(3, p)
                --    end
                -- elseif rewardName == 'A级躯改' then
                --    for i = 1, rewardNum, 1 do
                --        fc.rewardRngBodyReform(4, p)
                --    end
                -- elseif rewardName == 'S级躯改' then
                --    for i = 1, rewardNum, 1 do
                --        fc.rewardRngBodyReform(5, p)
                --    end
                -- elseif rewardName == 'SS级躯改' then
                --    for i = 1, rewardNum, 1 do
                --        fc.rewardRngBodyReform(6, p)
                --    end
                -------------------------------------------------------------------------------------
            else
                local itemType = as.dataRegister:getItemType(rewardName)
                for i = 1, rewardNum do
                    fc.rewardItem(rewardName, p, fromPoint)
                end
            end
        end
    end, function(msg)
        print(msg, debug.traceback())
    end)

end
--------------------------------------------------------------------------------------
local stringValTable = {}
--------------------------------------------------------------------------------------
function fc.setStringVal(key, val)
    stringValTable[key] = val
end
--------------------------------------------------------------------------------------
function fc.getStringVal(key)
    return stringValTable[key]
end
--------------------------------------------------------------------------------------
local errorReporter = function(msg)
    print(msg, debug.traceback())
    return nil
end
--------------------------------------------------------------------------------------
function fc.safeExecute(func)
    xpcall(func, errorReporter)
end
--------------------------------------------------------------------------------------
local parentHashTable = {}
--------------------------------------------------------------------------------------
function fc.setAttr(parentKey, childKey, val)

    if not parentHashTable[parentKey] then
        parentHashTable[parentKey] = {}
    end

    parentHashTable[parentKey][childKey] = val
end
--------------------------------------------------------------------------------------
function fc.getAttr(parentKey, childKey)
    if not parentHashTable[parentKey] then
        parentHashTable[parentKey] = {}
    end

    return parentHashTable[parentKey][childKey]
end
--------------------------------------------------------------------------------------
function fc.clearAttr(parentKey)
    parentHashTable[parentKey] = nil
end
--------------------------------------------------------------------------------------
function fc.convertDmg(dmgAmt)
    if dmgAmt < 100000 then
        return str.format('%.0f', dmgAmt)
    else
        dmgAmt = dmgAmt / 10000
        return str.format('%.1fw', dmgAmt)
    end
end
--------------------------------------------------------------------------------------
function dpt(node)
    -- to make output beautiful
    local function tab(amt)
        local str = ""
        for i = 1, amt do
            str = str .. "\t"
        end
        return str
    end

    local cache, stack, output = {}, {}, {}
    local depth = 1
    local output_str = "{\n"

    while true do
        local size = 0
        for k, v in pairs(node) do
            size = size + 1
        end

        local cur_index = 1
        for k, v in pairs(node) do
            if (cache[node] == nil) or (cur_index >= cache[node]) then

                if (string.find(output_str, "}", output_str:len())) then
                    output_str = output_str .. ",\n"
                elseif not (string.find(output_str, "\n", output_str:len())) then
                    output_str = output_str .. "\n"
                end

                -- This is necessary for working with HUGE tables otherwise we run out of memory using concat on huge strings
                table.insert(output, output_str)
                output_str = ""

                local key
                if (type(k) == "number" or type(k) == "boolean") then
                    key = "[" .. tostring(k) .. "]"
                else
                    key = "['" .. tostring(k) .. "']"
                end

                if (type(v) == "number" or type(v) == "boolean") then
                    output_str = output_str .. tab(depth) .. key .. " = " .. tostring(v)
                elseif (type(v) == "table") then
                    output_str = output_str .. tab(depth) .. key .. " = {\n"
                    table.insert(stack, node)
                    table.insert(stack, v)
                    cache[node] = cur_index + 1
                    break
                else
                    output_str = output_str .. tab(depth) .. key .. " = '" .. tostring(v) .. "'"
                end

                if (cur_index == size) then
                    output_str = output_str .. "\n" .. tab(depth - 1) .. "}"
                else
                    output_str = output_str .. ","
                end
            else
                -- close the table
                if (cur_index == size) then
                    output_str = output_str .. "\n" .. tab(depth - 1) .. "}"
                end
            end

            cur_index = cur_index + 1
        end

        if (#stack > 0) then
            node = stack[#stack]
            stack[#stack] = nil
            depth = cache[node] == nil and depth + 1 or depth - 1
        else
            break
        end
    end

    -- This is necessary for working with HUGE tables otherwise we run out of memory using concat on huge strings
    table.insert(output, output_str)
    output_str = table.concat(output)

    print(output_str)
end
--------------------------------------------------------------------------------------
traceError = function(msg)
    if msg then
        print(msg, debug.traceback())
    else
        print(debug.traceback())
    end

end
--------------------------------------------------------------------------------------
function fc.createWeightPool(tbl)
    local pool = {}

    for _, entry in ipairs(tbl) do
        local rare = entry[1]
        local num = entry[2]
        for i = 1, num do
            pool[#pool + 1] = rare
        end
    end

    return pool
end
--------------------------------------------------------------------------------------
return mt
