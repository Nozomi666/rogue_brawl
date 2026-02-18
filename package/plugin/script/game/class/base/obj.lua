require('game.__api.stats_setter')
require('game.__api.stats_getter')

local mt = {}
mt.__index = mt
cg.BaseObj = mt
--------------------------------------------------------------------------------------

mt.eventList = nil
mt.statsTable = nil
--------------------------------------------------------------------------------------
function mt:new()
    local o = {}
    setmetatable(o, self)

    o.statsTable = {}

    return o
end
--------------------------------------------------------------------------------------
-- local keys = {
--     name = name,
--     condition = condition,
--     callback = callback,
-- }
function mt:addEvent(keys)

    local name = keys.name
    local condition = keys.condition

    -- gdebug('call add event: ' .. name)

    if not self.eventList then
        self.eventList = {}
    end
    if not self.eventList[condition] then
        self.eventList[condition] = {}
    end

    if type(condition) == 'table' or type(name) == 'table' then
        warn('出现事件添加表错误，试图将索引设置为table')
        return
    end

    local subList = self.eventList[condition]
    subList[#subList + 1] = keys

    -- 如果是英雄出生事件，并且已经有英雄了，则直接触发一次
    if condition == PLAYER_EVENT_HERO_BORN and self.hero then
        xpcall(function()
            keys.u = self.hero
            keys.callback(keys.self, keys)
        end, function(msg)
            print(msg, debug.traceback())
        end)
    end

    return keys
end
--------------------------------------------------------------------------------------
function mt:removeEvent(keys)

    local name = keys.name
    local condition = keys.condition

    if not self.eventList then
        return
    end
    if not self.eventList[condition] then
        return
    end

    local subList = self.eventList[condition]

    for i = #subList, 1, -1 do
        if subList[i].name == name and subList[i].self == keys.self then
            -- gdebug('call remove event: ' .. name)
            table.remove(subList, i)
            -- break
        end
    end

end
--------------------------------------------------------------------------------------
-- local keys = {
--     safeExecute = true,
-- }
--------------------------------------------------------------------------------------
function mt:triggerEvent(condition, keys)
    -- dpt(keys)
    if not self.eventList then
        return
    end
    if not self.eventList[condition] then
        return
    end
    if not keys then
        keys = {}
    end

    local loopList = {}
    for _, eventKeys in ipairs(self.eventList[condition]) do
        loopList[#loopList + 1] = eventKeys
    end

    for _, eventKeys in ipairs(loopList) do
        if eventKeys.callback then
            keys.eventKeys = eventKeys

            if keys.safeExecute then
                xpcall(function()
                    eventKeys.callback(eventKeys.self, keys)
                end, function(msg)
                    print(msg, debug.traceback())
                end)
            else
                eventKeys.callback(eventKeys.self, keys)
            end

            -- gdebug(str.format('%s trigger event [%s] - %s', self:getName(), cst:getConstName(condition), eventKeys.name))
        else
            -- print('error msg -- cant trigger event')
            print(str.format('Failed %s trigger event [%s] - %s', self:getName(), cst:getConstName(condition),
                eventKeys.name))
        end

    end

end
--------------------------------------------------------------------------------------
function mt:modStats(stats, amount, time)
    if amount == 0 then
        return
    end

    local after = nil
    local callback = StatsSetter[stats]
    if callback then
        after = callback(self, amount)
    else
        after = StatsSetter.generalModifier(self, stats, amount)
    end

    if time and time > 0 then
        ac.wait(ms(time), function()
            if self.removed then
                gdebug('no mod removed unit stats')
                return
            end
            if callback then
                callback(self, amount * -1)
            else
                StatsSetter.generalModifier(self, stats, amount * -1)
            end
        end)

    end

    return after
end
--------------------------------------------------------------------------------------
function mt:refreshStats(stats)
    local callback = StatsSetter[stats]
    local after = nil
    if callback then
        after = callback(self, 0)
    else
        after = StatsSetter.generalModifier(self, stats, 0)
    end

    return after
end
--------------------------------------------------------------------------------------
function mt:setStats(stats, amount, time)
    local prev = self:getStats(stats)
    local delta = amount - prev
    self:modStats(stats, delta, time)
end
--------------------------------------------------------------------------------------
function mt:getStats(stats)
    local callback = StatsGetter[stats]
    if not callback then
        callback = StatsGetter.generalGetter
    end

    return callback(self, stats)
end
--------------------------------------------------------------------------------------
function mt:printStats()
    -- 这个函数多人模式下会造成异步
    print('-------------------------------------------单位属性------------------------------------')
    for stats, val in pairs(self.statsTable) do
        local statsName = cst:getConstName(stats)
        print(str.format([[  [%s]：%f%s]], statsName, val, cst:getConstTag(stats, 'isPct') and '%' or ''))
    end
    print('--------------------------------------------------------------------------------------')
end
--------------------------------------------------------------------------------------
function mt:setAttribute(k, v)
    if not self.attribute then
        self.attribute = {}
    end

    self.attribute[k] = v
end
--------------------------------------------------------------------------------------
function mt:getAttribute(k)
    if not self.attribute then
        self.attribute = {}
    end

    return self.attribute[k]
end
--------------------------------------------------------------------------------------
function mt:setAttr(k, v)
    return self:setAttribute(k, v)
end
--------------------------------------------------------------------------------------
function mt:getAttr(k)
    return self:getAttribute(k)
end

--------------------------------------------------------------------------------------
return mt
