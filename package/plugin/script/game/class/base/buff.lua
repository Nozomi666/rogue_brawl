local mt = {}
mt.__index = mt
cg.Buff = mt
as.buff = mt

mt.type = 'buff'

mt.pack = nil
mt.owner = nil
mt.from = nil
mt.name = nil
mt.lv = nil
mt.charge = 0
mt.maxTime = 0
mt.startFrame = 0
mt.removed = false
mt.effect = {}
mt.simpleBuffTable = {}
local gchash = 0
--------------------------------------------------------------------------------------
function mt:new(u, tgt, buffName, time, lv, keys)
    local o = {}

    local pack = fc.getAttr('buff_pack', buffName)
    o.pack = pack

    if not pack then
        warn('no skill pack: ' .. buffName)
        return
    end
    setmetatable(o, pack)

    o.owner = tgt
    o.from = u
    o.name = buffName
    o.lv = lv
    o.maxTime = time
    o.charge = keys and keys.charge or 0
    o.keys = keys
    o.effect = {}
    o.stackTimer = {}
    o.stack = 0
    o.startFrame = ac.clock()
    o.endTimer = nil
    gchash = gchash + 1
    dbg.gchash(o, gchash)
    o.gchash = gchash

    -- 施加事件
    o:onApply()

    -- 绑定特效
    if o.pack.effect then
        local effList = tgt.buffEffectList

        for _, v in ipairs(o.pack.effect) do
            local bind = v[1]
            local model = v[2]

            if not effList[bind][model] then
                local mustShow = false
                if o.pack.mustShowEffect then
                    mustShow = true
                end
                local eff = fc.unitEffect({
                    bind = bind,
                    model = model,
                    time = -1,
                    mustShow = mustShow,
                }, tgt)

                effList[bind][model] = {
                    eff = eff,
                    stack = 1,
                }
            else
                effList[bind][model].stack = effList[bind][model].stack + 1
            end

        end
    end

    if o.pulseInterval and o.pulseInterval > 0 then
        ac.loop(ms(o.pulseInterval), function(timer)

            if not tgt.removed then
                o:onPulse()
            end

            -- 检测到当前buff被覆盖（结束）/所有者不存在时停止pluse
            if tgt.removed or o.removed then
                -- gdebug(str.format('buff stop pulse'))
                timer:remove()
                -- mapdebug('pulse stop detected')
                return
            end

        end)
    end

    -- 倒计时到期；刷新时会被重置
    o.endTimer = mt:makeEndTimer(o)

    return o
end

--------------------------------------------------------------------------------------
function mt:makeEndTimer(buff)
    local last = buff.maxTime
    local timer = ac.wait(ms(last), function()
        -- gdebug(buff.endTimer)
        buff.endTimer = nil
        mt:removeBuff(buff)
    end)

    return timer
end

--------------------------------------------------------------------------------------
function mt:getLifeTime()
    if not self.startFrame then
        return -1
    end

    return self.maxTime - (ac.clock() - self.startFrame) / 1000
end

--------------------------------------------------------------------------------------
function mt:onApply()
    if self.pack.onSwitch then
        xpcall(function()
            self.pack.onSwitch(self, true)
        end, function(msg)
            print(msg, debug.traceback())
        end)

    end

end
--------------------------------------------------------------------------------------
function mt:onPulse()
    if self.pack.onPulse then
        xpcall(function()
            self.pack.onPulse(self)
        end, function(msg)
            print('buff pulse error: ' .. self.name)
            print(msg, debug.traceback())
        end)

    end

end
--------------------------------------------------------------------------------------
function mt:onRemove()
    if self.pack.onSwitch then

        xpcall(function()
            self.pack.onSwitch(self, false)
        end, function(msg)
            print(msg, debug.traceback())
        end)

    end
end
--------------------------------------------------------------------------------------
function mt:removeBuff(buff)
    if buff.type ~= 'buff' then
        -- gdebug('remove buff fail bc buff no type')
        return
    end

    local u = buff.owner
    local buffList = u.buffList
    local buffNameList = u.buffNameList
    local buffName = buff.name

    -- 移除特效
    if buff.effect then

        local effList = u.buffEffectList
        for _, v in ipairs(buff.pack.effect) do
            local bind = v[1]
            local model = v[2]

            local effs = effList[bind][model]
            if effs.stack > 1 then
                effs.stack = effs.stack - 1
            else
                fc.removeEffect(effs.eff)
                effList[bind][model] = nil
            end
        end
    end

    if buff.endTimer then
        buff.endTimer:remove()
        buff.endTimer = nil
    end

    if not u.removed then
        buff:onRemove()
    else
        -- fc.asyncCheck(str.format('remove buff to removed unit, buffName: %s, uName:%s ', buffName, u:getName()))
    end

    -- gdebug(str.format('remove buff, name: %s, owner: %s, player: %s', buffName, u:getName(), u.owner:getName()))

    if buff.stack > 0 then
        -- gdebug('buff stack： ' .. buff.stack)
        for _, timer in ipairs(buff.stackTimer) do
            timer:remove()
        end

        if not u.removed then
            buff.pack.onUpdateStack(buff, buff.stack * -1)
        end

    end

    buff.removed = true
    local buffChain = u.buffNameList[buffName]
    buffChain:remove(buff)
    buffList:remove(buff)

end
--------------------------------------------------------------------------------------
function mt:removeBuffByName(u, buffName)

    local buffChain = u.buffNameList[buffName]
    if not buffChain then
        return
    end

    local buff = buffChain:at(1)

    local c = 0
    while buff and c < 100 do
        -- gdebug('remove a buff by name: %s', buffName)
        mt:removeBuff(buff)
        buff = buffChain:at(1)
        c = c + 1
        if c >= 100 then
            print('removeBuffByName 死循环, buffName: ' .. buffName)
        end
    end

end
----------------------------------------u----------------------------------------------
local onApplyStun = function(u, tgt, buffName, time, lv, keys)
    -- fc.asyncCheck('施加眩晕')
    local keys = {
        u = u,
        tgt = tgt,
        buffName = buffName,
        time = time,
        lv = lv,
        keys = keys,
    }
    u:triggerEvent(UNIT_EVENT_ON_APPLY_STUN, keys)

end
--------------------------------------------------------------------------------------
local buffOnCast = {
    ['眩晕'] = onApplyStun,
}
--------------------------------------------------------------------------------------
function mt:updateStack(modStack, time)
    self.pack.onUpdateStack(self, modStack)
    if not self.pack.refreshAllStack then
        local timer = ac.timer(ms(time), 1, function()
            self.pack.onUpdateStack(self, modStack * -1)
        end)
        table.insert(self.stackTimer, timer)
    end

end
--------------------------------------------------------------------------------------
-- ApplyBuff({
--     unit = unit,
--     tgt = tgt,
--     buffName = skillName,
--     lv = skill.lv,
--     time = 3,

-- })
--------------------------------------------------------------------------------------
function ApplyBuff(keys)
    local u = keys.unit
    local tgt = keys.tgt
    local buffName = keys.buffName
    local lv = keys.lv
    local time = keys.time

    if tgt.ignoreBuff then
        return
    end

    if not time then
        gdebug('buffTime is nil')
        return
    end

    if time <= 0 then
        mapdebug('ignore buff time < 0')
        return
    end

    if not u then
        error('buff no caster')
        return
    end

    if not tgt then
        error('buff no tgt')
        return
    end

    local pack = fc.getAttr('buff_pack', buffName)
    if not pack then
        error('buff type not exist')
        return
    end

    if pack.noLv then
        lv = 1
    end

    if not tgt:isAlive() then
        return
    end

    -- 是敌对buff
    if u:isEnemy(tgt) then
        local evade = tgt:getStats(ST_DEBUFF_EVADE)
        local acc = u:getStats(ST_DEBUFF_ACC)

        if evade - acc > 0 and math.random(100) < ConvertFunctionEvade(acc, evade) then
            -- gdebug('触发了闪避debuff。acc：%.0f, evade: %.0f, chance:%.0f%%', acc, evade,
            --     ConvertFunctionEvade(acc, evade))
            return
        end

        -- 减益时长
        time = time * math.clamp((1 + (u:getStats(ST_DEBUFF_APPLY) + tgt:getStats(ST_DEBUFF_GET)) / 100), 0.1, 3)

    end

    -- 控制系数
    if pack.control then
        if tgt.controlResistCounter > 0 then
            -- gdebug('触发了控制免疫')
            return
        end

        local controlRate = u:getStats(ST_CONTROL_RATE)
        local controlResist = tgt:getStats(ST_CONTROL_RESIST)

        local controlTimeRate = ConvertControlRate(controlRate, controlResist)
        time = time * (1 + controlTimeRate / 100)

    end

    -- 同名buff覆盖
    local prevBuff
    if pack.differentApplierStackable then
        prevBuff = tgt:hasBuff(buffName, u)
    else
        prevBuff = tgt:hasBuff(buffName)
    end

    if prevBuff then

        if pack.multiple then

            local buff = mt:new(u, tgt, buffName, time, lv, keys)

            if (keys and keys.modStack) then
                buff:updateStack(keys.modStack, time)
            end

            buff:addBuff(tgt)

        else

            -- print('has no multiple prev buff')
            local oldBuff = prevBuff
            local oldTime = oldBuff:getLifeTime()

            -- 新buff等级比老buff低时
            if lv <= oldBuff.lv then
                time = time * lv / oldBuff.lv

                -- 新buff持续时间比较久时刷新老buff持续时间；施法单位更新为新单位
                if time > oldTime then
                    -- update time and frame
                    oldBuff.maxTime = time
                    oldBuff.startFrame = ac.clock()
                    -- update from
                    oldBuff.from = u

                    -- update end timer
                    oldBuff.endTimer:remove()
                    oldBuff.endTimer = mt:makeEndTimer(oldBuff)
                    -- fc.asyncCheck(string.format('keep old lv; oldtime: %f, newtime: %f, buffName: %s ', oldTime, time,
                    --     buffName))
                end

                if (keys and keys.modStack) then
                    -- gdebug('更新buff【%s】，modStack：%d， time：%.0f', oldBuff.name, keys.modStack, time)
                    oldBuff:updateStack(keys.modStack, time)
                end

                -- 新buff等级比老buff高时，持续时间取较大值（新时间，老时间折算）
            else
                oldTime = oldTime * oldBuff.lv / lv

                time = math.max(time, oldTime)

                -- 移除老buff
                local oldStack = oldBuff.stack
                mt:removeBuff(oldBuff)

                -- 增加新buff
                local buff = mt:new(u, tgt, buffName, time, lv, keys)
                if (keys and keys.modStack) then
                    buff:updateStack(keys.modStack + oldStack, time)
                end

                buff:addBuff(tgt)
            end

        end

        return
    end

    -- 没有buff
    local buff = mt:new(u, tgt, buffName, time, lv, keys)

    if (keys and keys.modStack) then
        buff:updateStack(keys.modStack, time)
    end

    buff:addBuff(tgt)

end
------------------------------------------------------------------------------------
function mt:addBuff(u)
    local buffList = u.buffList
    local buffNameList = u.buffNameList
    local buffName = self.name

    local buffChain = u.buffNameList[buffName]

    if not buffChain then
        buffChain = linked.create()
        u.buffNameList[buffName] = buffChain
    end

    buffChain:add(self)
    buffList:add(self)
end

--------------------------------------------------------------------------------------
function mt:removeAllBuff(u)
    local buffList = u.buffList

    -- fc.asyncCheck('before removing all buff'.. u:getName())

    local list = {}

    local buffData = buffList:at(1)
    while buffData do
        list[#list + 1] = buffData
        buffData = buffList:next(buffData)
    end

    for i, buff in ipairs(list) do
        local buffName = buff.name
        mt:removeBuffByName(u, buffName)
        -- mapdebug(str.format('removing all buff: %s from %s', buffName, u:getName()))
    end

end
--------------------------------------------------------------------------------------
-- function mt:removeEnemyBuff(u)
--     if not u.buffList then
--         return
--     end
--     local buffList = u.buffList

--     -- fc.asyncCheck('before removing enemy buff' .. u:getName())

--     local list = {}

--     local buffData = buffList:at(1)
--     while buffData do
--         list[#list + 1] = buffData
--         buffData = buffList:next(buffData)
--     end

--     for i, buff in ipairs(list) do
--         local buffName = buff.name
--         -- gdebug('buffname list check: ' .. buffName)
--     end

--     for i, buff in ipairs(list) do
--         local buffName = buff.name
--         if u:isEnemy(buff.from) then
--             mapdebug(str.format('removing enemy buff: %s from %s', buffName, u:getName()))
--             mt:removeBuff(buff)
--         end
--     end

-- end
--------------------------------------------------------------------------------------
-- function mt:removeAllyBuff(u)

--     -- fc.asyncCheck('before removing ally buff' .. u:getName())
--     local buffList = u.buffList

--     local list = {}

--     local buffData = buffList:at(1)
--     while buffData do
--         list[#list + 1] = buffData
--         buffData = buffList:next(buffData)
--     end

--     for i, buff in ipairs(list) do
--         local buffName = buff.name
--         -- gdebug('buffname list check: ' .. buffName)
--     end

--     for i, buff in ipairs(list) do
--         local buffName = buff.name
--         if u:isAlly(buff.from) then
--             mt:removeBuff(buff)
--         end
--     end
-- end
--------------------------------------------------------------------------------------
function mt:getValidStack()
    return math.min(self.stack, self.maxStack)
end

return mt
