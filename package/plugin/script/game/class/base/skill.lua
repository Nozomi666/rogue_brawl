local mt = {}
mt.__index = mt
cg.Skill = mt
as.skill = mt
--------------------------------------------------------------------------------------
mt.lv = 0
mt.cd = 0
mt.unit = nil
mt.skillBtn = nil
mt.cooling = false
mt.cdTimer = nil
mt.cdCharge = 0
mt.currentChargeCd = 0
--------------------------------------------------------------------------------------
function mt:new(unit, skillName, lv)
    local pack = fc.getAttr('skill_pack', skillName)
    if not pack then
        warn('no skill pack: ' .. skillName)
        return
    end

    local o = {}
    setmetatable(o, pack)

    o.unit = unit
    -- gdebug('new skillName = '..skillName)
    o:setLv(lv or 1)

    if o.maxCharge then
        o.currentLeftCharge = o.maxCharge
    end

    return o
end
--------------------------------------------------------------------------------------
function mt:setLv(amt)

    -- gdebug('set skill: %s lv: %d', self.name, self.lv)
    local prevLv = self.lv
    if prevLv ~= 0 then
        if self.onSwitch then
            xpcall(function()
                self:onSwitch(false)
            end, traceError)

        end
    end
    self.lv = amt

    if self.lv > 0 then
        if self.onSwitch then
            xpcall(function()
                self:onSwitch(true)
            end, traceError)
        end
    end

    if self.lv > prevLv then
        local deltaLv = self.lv - prevLv
        for i = 1, deltaLv do
            if self.onLevelUp then
                xpcall(function()
                    self:onLevelUp()
                end, traceError)
            end
        end
    end

end
--------------------------------------------------------------------------------------
function mt:setLevel(amt)
    return self:setLv(amt)
end
--------------------------------------------------------------------------------------
function mt:setInCd(cd)

    if self.cdTimer then
        self.cdTimer:remove()
    end

    if not cd then
        cd = self:getData('cd')
    end
    -- gdebug('cd start')
    -- print(self.name .. '技能开始进入冷却')
    -- print('--------------------------------------------------------------------------------------')
    -- print('cd..' .. cd)
    -- print('--------------------------------------------------------------------------------------')
    if not self.maxCharge then
        self.cooling = true
        self.cdTimer = ac.wait(ms(cd), function()
            -- gdebug('cd end')
            self.cooling = false
            self.cdTimer = nil
            -- print(self.name .. '技能冷却完成')
        end)
    else
        self.currentLeftCharge = self.currentLeftCharge - 1
        -- gdebug('currnet left charge: ' .. self.currentLeftCharge)

        if not self.cdLooper then
            self.currentChargeCd = cd
            self.cdLooper = ac.loop(ms(0.03), function()

                if self.currentLeftCharge < self.maxCharge then
                    if self.currentChargeCd <= 0 then
                        self.currentLeftCharge = self.currentLeftCharge + 1
                        self.cooling = false
                        self.currentChargeCd = self:getData('cd')
                        -- gdebug('charge complete, add one point')
                    else
                        self.currentChargeCd = self.currentChargeCd - 0.03
                    end
                end

            end)
        end

        if self.currentLeftCharge == 0 then
            -- gdebug('self.currentChargeCd = 0 : ' .. self.currentChargeCd)
            cd = self.currentChargeCd
            self.cooling = true
        else
            -- gdebug('self.currentChargeCd = 0 : else')
            cd = 0
        end

    end

    if self.skillBtn then
        self.skillBtn:setCurrentCd(cd, true)
    end

end
--------------------------------------------------------------------------------------
function mt:addCharge()
    self.currentLeftCharge = math.min(self.currentLeftCharge + 1, self.maxCharge)
    self.cooling = false

    if self.skillBtn then
        self.skillBtn:setCurrentCd(0, true)
    end
end
--------------------------------------------------------------------------------------
function mt:getInterval(val)
    if val then
        return val
    end

    if not self.interval then
        return 0
    end

    return self:getData('interval')
end
--------------------------------------------------------------------------------------
function mt:isInCd()
    return self.cooling
end
--------------------------------------------------------------------------------------
function mt:levelUp(amt)
    amt = amt or 1
    self:setLv(self.lv + amt)
end
--------------------------------------------------------------------------------------
function mt:remove()
    self:setLv(0)
end
--------------------------------------------------------------------------------------
function mt:getTitle()
    if self.skillType == SKILL_TYPE_HERO_TALENT then
        if not self.heroName then
            self.heroName = self.unit:getName()
        end
        return str.format(str.format('%s - [%s]', self.title, self.heroName))
    elseif self.skillType == SKILL_TYPE_CUSTOM then
        if not self:isPassive() then
            return str.format(str.format('%s', self:getNameWithRare()))
        else
            return str.format(str.format('%s', self:getNameWithRare()))
        end

    elseif self.skillType == SKILL_TYPE_NO_FLAG then
        return str.format(str.format('%s', self.title))
    end
end
--------------------------------------------------------------------------------------
function mt:getTip()
    return self:generateTip()
end
--------------------------------------------------------------------------------------
function mt:getUpgradeTip(nowLv, tgtLv)
    return self:generateTip(nowLv, tgtLv)
end
--------------------------------------------------------------------------------------
function mt:isPassive()
    return self.targetType == SKILL_TARGET_PASSIVE
end
--------------------------------------------------------------------------------------
function mt:getData(name, lv)

    lv = lv or self.lv
    local data = self[name]
    local val = data

    if (type(data) == 'table') then
        lv = math.min(#data, lv)
        val = data[lv]
    end

    return val or 0
end
--------------------------------------------------------------------------------------
function mt:getPackData(skillName, dataName, lv)

    lv = lv or 1
    local data = fc.getAttr('skill_pack', skillName)
    local val = 0
    val = data

    if (type(data) == 'table') then
        lv = math.min(#data, lv)
        val = data[lv]
    end

    return val or 0
end
--------------------------------------------------------------------------------------
function mt:getlv()
    return self.lv
end
--------------------------------------------------------------------------------------
function mt:generateAffixTip()
    local convertColorFunc = function(name)
        if name == 'NUM' then
            return cst.COLOR_CODE['DANGER']
        else
            return cst.COLOR_CODE[name]
        end

    end

    return self:generateTip(nil, nil, {
        convertColorFunc = convertColorFunc,
    })
end
--------------------------------------------------------------------------------------
function mt:generateAffixDarkTip()
    local convertColorFunc = function(name)
        return ''
    end

    return str.format([[|cffbbbbbb%s|r]], self:generateTip(nil, nil, {
        convertColorFunc = convertColorFunc,
    }))
end
--------------------------------------------------------------------------------------
function mt:generateTip(lv, tgtLv, keys)
    local skLv = lv or self.lv or 1
    local tip = self.tip

    local convertColorFunc = convertColor
    if keys then
        if keys.convertColorFunc then
            convertColorFunc = keys.convertColorFunc
        end
    end

    -- closure
    local convertRate = function(name)
        return self:getData(name, skLv)
    end

    -- closure
    local convertUpgradeRate = function(name)
        skLv = math.max(skLv, 1)
        local val = self[name] * skLv
        if tgtLv and tgtLv > 1 then
            local valNext = self[name] * tgtLv
            return str.format('%s（%s↑）', tostring(valNext), tostring(valNext - val))
        else
            return val
        end

    end

    -- closure
    local convertMixRate = function(callbackName)

        skLv = math.max(skLv, 1)
        local valPrev = self[callbackName](self, skLv)
        if tgtLv and tgtLv > 1 then
            local valNext = self[callbackName](self, tgtLv)
            return str.format('%s（%s↑）', tostring(valNext), tostring(valNext - valPrev))
        else
            return valPrev
        end

    end

    -- set tip
    tip = string.gsub(tip, '%<([%w_.>]*)%>', convertColorFunc)
    tip = string.gsub(tip, '%[([%w_]*)%]', convertRate)
    tip = string.gsub(tip, '%#([%w_]*)%#', convertUpgradeRate)
    tip = string.gsub(tip, '%@([%w_]*)%@', convertMixRate)
    tip = string.gsub(tip, "%%(%d+%.?%d*)%%", convertPct)

    -- add presentMain
    local mainInfo = self.presentMain
    local skillName = self.name
    local hint = self.hint

    if hint then
        tip = tip .. '\n\n' .. str.format('|cffccffcc%s|r', hint)
    end

    local skillLvMax = 3

    if (mainInfo) then
        tip = tip .. '\n'
        for i, entry in ipairs(mainInfo) do
            local details = ''

            local entryName = string.gsub(entry.name, '%<([%w_.>]*)%>', convertColor)
            local entryData = self[entry.type]
            if (type(entryData) == 'table') then
                if #entryData > 1 then
                    for j = 1, skillLvMax do
                        local val = self:getData(entry.type, j)
                        -- if (entry.isPct) then
                        --     val = convertPct(val)
                        -- end
                        details = details .. (j == lv and '|cffffff00' .. val .. '|r' or val) ..
                                      (j < cst.skillLvMax and '/' or '')
                    end
                else
                    local val = entryData[1]
                    if (entry.isPct) then
                        val = convertPct(val)
                    end
                    details = details .. string.format('|cffffff00%s|r', val)
                end
            else
                local val = entryData
                if (entry.isPct) then
                    val = convertPct(val)
                end
                details = details .. string.format('|cffffff00%s|r', val)
            end

            tip = tip .. string.format('%s|cffff9900%s|r%s', '\n', entryName, details)
        end
    end

    -- add presentSide
    local sideInfo = self.presentSide
    local skillName = self.name
    if (sideInfo and next(sideInfo) ~= nil) then
        tip = tip .. '\n\n'
        for i, entry in ipairs(sideInfo) do
            local details = ''

            local entryData = self[entry.type]
            if (type(entryData) == 'table') then
                if #entryData > 1 then
                    for j = 1, cst.skillLvMax do
                        local val = self:getPackData(skillName, entry.type, j)
                        details = details .. (j == lv and '|cffcc99ff' .. val .. '|r' or val) ..
                                      (j < cst.skillLvMax and '/' or (i < #sideInfo and '\n' or ''))
                    end
                else
                    details = details .. string.format('|cffcc99ff%s|r%s', entryData[1], (i < #sideInfo and '\n' or ''))
                end
            else
                details = details .. string.format('|cffcc99ff%s|r%s', entryData, (i < #sideInfo and '\n' or ''))
            end

            tip = tip .. string.format('|cff99ccff%s|r%s', entry.name, details)
        end
    end

    -- add heroTalent
    if self.skillType == SKILL_TYPE_HERO_TALENT and self.unit then

    end

    if self.getExtraTip then
        tip = str.format('%s%s', tip, self:getExtraTip())
    end

    if self.skillType == SKILL_TYPE_CUSTOM and self.unit then

        local crystalNeed = self:getRefreshSkillNeedCrystal()
        local crystalRefreshReqStr = str.format('|cff00ffbf右键消耗|r|cffffcc00%d|r|cff00ffbf钻石来刷新。|r',
            crystalNeed)
        tip = str.format('%s|n|n%s', tip, crystalRefreshReqStr)
    end
    return tip
end
--------------------------------------------------------------------------------------
function mt:searchTarget()
    local u = self.unit
    local point = u:getloc()
    local range = self:getData('range')
    local keys = {
        u = u,
        dest = point,
    }

    if (self.targetType == SKILL_TARGET_UNIT) then
        local g = ac.selector():inRangeEnemy(point, range, u)
        local tgt = g:randomRemove()
        if tgt then
            keys.tgt = tgt
        else
            return nil
        end

    elseif (self.targetType == SKILL_TARGET_POINT) then
        local g = ac.selector():inRangeEnemy(point, range, u)

        local tgt = g:randomRemove()
        if tgt then
            keys.tgt = tgt
            keys.dest = tgt:getloc()
        else
            return nil
        end

    end

    return keys
end
--------------------------------------------------------------------------------------
function mt:powerCast(keys)
    local unit = self.unit
    unit:pause()
    unit:playAnimId(keys.preAct)
    unit:setAnimSpeed(keys.preSpeed)
    unit.bPowerCasting = true
    ac.wait(ms(keys.preTime), function()
        self:powerCastPhase2(keys)
    end)

    if keys.onStartPowerCast then
        xpcall(function()
            keys.onStartPowerCast(self, keys.tgtKeys)
        end, traceError)
    end

    ApplyBuff({
        unit = unit,
        tgt = unit,
        buffName = cst.BUFF_CONTROL_RESIST,
        lv = 1,
        time = keys.actTime,
    })

    ac.wait(ms(keys.actTime), function()
        if keys.actFunc then
            xpcall(function()
                if unit:isAlive() then
                    keys.actFunc(self, keys.tgtKeys)
                end
            end, traceError)
        end
    end)

end
--------------------------------------------------------------------------------------
function mt:powerCastPhase2(keys)
    local unit = self.unit
    if unit:isDead() then
        self:endPowerCast(keys)
        return
    end

    unit:playAnimId(keys.slowAct)
    unit:setAnimSpeed(keys.slowSpeed)
    ac.wait(ms(keys.slowTime), function()
        self:powerCastPhase3(keys)
    end)
end
--------------------------------------------------------------------------------------
function mt:powerCastPhase3(keys)
    local unit = self.unit
    if unit:isDead() then
        self:endPowerCast(keys)
        return
    end

    unit:playAnimId(keys.fastAct)
    unit:setAnimSpeed(keys.fastSpeed)
    ac.wait(ms(keys.fastTime), function()
        self:powerCastPhase4(keys)
    end)
end
--------------------------------------------------------------------------------------
function mt:powerCastPhase4(keys)
    local unit = self.unit
    if unit:isDead() then
        self:endPowerCast(keys)
        return
    end

    unit:playAnimId(keys.postAct)
    unit:setAnimSpeed(keys.postSpeed)
    self:endPowerCast(keys)

    -- ac.wait(ms(keys.postTime), function()
    --     self:endPowerCast(keys)
    -- end)
end
--------------------------------------------------------------------------------------
function mt:endPowerCast(keys)
    local unit = self.unit
    unit:resetAnim()
    unit:resume()
    unit.bPowerCasting = false

    if keys.onEndPowerCast then
        xpcall(function()
            keys.onEndPowerCast(self, keys.tgtKeys)
        end, traceError)
    end

    if keys.tgtKeys.tgt then
        unit:issuePointOrder('attack', keys.tgtKeys.tgt:getloc())
    else
        local group = ac.selector():inRangeEnemy(unit:getloc(), unit:getStats(ST_RANGE), unit)
        local tgt = group:random()
        if tgt then
            unit:issuePointOrder('attack', tgt:getloc())
        end

    end

end
--------------------------------------------------------------------------------------

return mt
