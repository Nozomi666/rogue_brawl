local mt = {}
mt.__index = mt
cg.SkillBtn = mt

mt.name = nil
mt.handle = nil -- 模板技能类的handle；单位身上的技能需要用get_handle()
mt.owner = nil
mt.unit = nil
mt.skillPack = nil
mt.slotId = 0

mt.targetType = nil

-- data in hashtable
mt.parentKey = nil
mt.childKey = nil
--------------------------------------------------------------------------------------
mt.skill = nil
mt.slotId = 0

local gchash = 0
--------------------------------------------------------------------------------------
-- 新建自定义技能模板
-- @param unit table
-- @param str parentKey
-- @param str childKey
-- @param table skillPack
function mt:newFlexBtn(unit, parentKey, childKey, slotId)

    local o = {}
    setmetatable(o, self)

    o.owner = unit
    o.unit = unit
    o.slotId = slotId

    gchash = gchash + 1
    dbg.gchash(o, gchash)
    o.gchash = gchash

    -- get model
    o.handle = mt:getSkillModel(parentKey, childKey)
    -- add model
    UnitAddAbility(unit.handle, o.handle)

    -- set namelist 
    fc.setAttr('skill_btn_obj', o.handle, o)

    -- auto config for hero skill
    -- if config ~= nil then
    --     config(o)
    -- else
    --     o:setLv(1)
    --     o:updateInfo()
    -- end

    return o
end
--------------------------------------------------------------------------------------
function mt:bindExist(u, typeHandle)
    local o = {}
    setmetatable(o, self)

    o.owner = u
    o.name = 'todo'
    o.pack = {}
    o.skillPack = {}

    gchash = gchash + 1
    dbg.gchash(o, gchash)
    o.gchash = gchash
    o.handle = typeHandle

    fc.setAttr('skill_btn_obj', o.handle, o)

    -- local skillHandle = o.handle
    -- as.skillManager.registry[skillHandle] = o

    return o
end
--------------------------------------------------------------------------------------
function mt:bindSkill(skill)
    if skill.skillBtn then
        warn('skill already has btn: ' .. skill.name)
        traceError()
        return
    end
    self.skill = skill
    skill.skillBtn = self

end
--------------------------------------------------------------------------------------
function mt:getSlk(name, default)
    local ability_id = self.handle
    if not ability_id then
        return
    end
    local ability_data = slk.ability[ability_id]
    if not ability_data then
        mapdebug('技能数据未找到' .. ability_id)
        return default
    end
    local data = ability_data[name]
    if data == nil then
        return default
    end
    if type(default) == 'number' then
        return tonumber(data) or default
    end
    return data
end
--------------------------------------------------------------------------------------]
function mt:updateCompleteTitle()
    local completeTitle = (self.title or '') .. (self.titlePostfix or '')
    japi.EXSetAbilityString(self.handle, 1, 0xD7, completeTitle)
end
--------------------------------------------------------------------------------------
function mt:setTitlePostfix(postfix)
    self.titlePostfix = postfix
    self:updateCompleteTitle()
end
--------------------------------------------------------------------------------------
function mt:setTitle(title)

    -- 主动快捷键
    local hk = self:getSlk('Hotkey')

    if self.skill then
        if (self.skill.targetType ~= SKILL_TARGET_PASSIVE or self.skill.showHotKey) and (not self.skill.hideDashHotkey) then
            title = title .. '(|cffffcc00' .. hk .. '|r)'
        end
    else
        title = title .. '(|cffffcc00' .. hk .. '|r)'
    end

    self.title = title
    self:updateCompleteTitle()
end
--------------------------------------------------------------------------------------
function mt:setTip(tip)
    japi.EXSetAbilityDataString(self:get_handle(), 1, 0xDA, tip)

end

--------------------------------------------------------------------------------------
function mt:setArt(art)
    japi.EXSetAbilityString(self.handle, 1, 0xCC, art)
end

--------------------------------------------------------------------------------------
function mt:onAdd()
    if (self.skillPack.onSwitch) then

        xpcall(function()
            self.skillPack.onSwitch(self, true)
        end, function(msg)
            print(msg, debug.traceback())
        end)

    end

end
--------------------------------------------------------------------------------------
function mt:beforeCast(keys)
    local skill = self.skill

    gdebug('beforeCast 1111')
    if skill then
        if skill.beforeCast then
            xpcall(function()
                skill:beforeCast(keys)
            end, traceError)
        end

        gdebug('beforeCast 2222')
        self:preventCastPassive()
    end

    local shopKeys = self.shopKeys

    if shopKeys and shopKeys.onClick then
        shopKeys.onClick(self.owner, shopKeys)
    end

end

--------------------------------------------------------------------------------------
-- local keys = {
--     u = u,
--     tgt = as.unit:uj2t(tj),
--     dest = as.point:new(x, y, 0),
--     skill = skill,
--     data = skill.skillPack,
--     lv = skill.lv

-- }
function mt:onCast(keys)

    local skill = self.skill
    if skill then
        if skill.onCast then
            xpcall(function()
                skill:onCast(keys)
            end, traceError)

            if not skill.fixCd then
                local time = skill:getData('cd') * (self.owner:getStats(ST_CD_AMP) / 100)
                self:reduceCd(time)
            end
            -- print('reduce skill cd: ' .. time)

        end

        if not skill.noTriggerCastEvent then
            self.owner:triggerEvent(UNIT_EVENT_ON_CAST_SPELL, {
                triggerSkill = skill,
            })
        end

    end

    -- -- funcBtn
    -- -- 跳过技能商店技能
    -- if (self.skillPack and self.skillPack.onCast and not self.banCastEffect) then

    --     xpcall(function()
    --         fc.asyncCheck(str.format('%s cast skill [%s]', self.owner:getName(), self.name))
    --         self.skillPack.onCast(self, keys)
    --     end, function(msg)
    --         print(msg, debug.traceback())
    --     end)

    -- end

    -- -- 主动技能cd加速
    -- if keys.trueCast and not keys.skipReduceCd then
    --     local time = self:getData('cd') * (algo.cdRate(self.owner:getStats(cst.ST_CD_SPEED)))
    --     self:reduceCd(time)

    --     -- 减少耗蓝
    --     local cost = self:getData('cost')
    --     local mpRegen = cost * self.owner:getStats(cst.ST_MP_SAVE)
    --     self.owner:modStats(cst.ST_MP, mpRegen)

    --     -- 充能回血
    --     local castHeal = self.owner:getStats(cst.ST_CAST_HEAL)
    --     if castHeal > 0 then
    --         self.owner:heal(castHeal, self.owner)
    --     end

    -- end

    if (self.callback) then
        self.callback(self, keys)
    end

end
--------------------------------------------------------------------------------------
-- s施放类型数字
local castTypeList = {
    [0] = 0, -- 被动
    [1] = 1, -- 对敌
    [2] = 1, -- 对友
    [3] = 2, -- 对点
    [4] = 0, -- 无目标
    [5] = 1, -- 任意单位

}
-- 转换目标允许
local targList = {
    ["地面"] = 2 ^ 1,
    ["空中"] = 2 ^ 2,
    ["建筑"] = 2 ^ 3,
    ["守卫"] = 2 ^ 4,
    ["物品"] = 2 ^ 5,
    ["树木"] = 2 ^ 6,
    ["墙"] = 2 ^ 7,
    ["残骸"] = 2 ^ 8,
    ["装饰物"] = 2 ^ 9,
    ["桥"] = 2 ^ 10,
    ["未知1"] = 2 ^ 11,
    ["自己"] = 2 ^ 12,
    ["友军单位"] = 2 ^ 13,
    ["联盟"] = 2 ^ 14,
    ["中立"] = 2 ^ 15,
    ["敌人"] = 2 ^ 16,
    ["未知2"] = 2 ^ 17,
    ---@diagnostic disable-next-line: duplicate-index
    ["未知"] = 2 ^ 18,
    ---@diagnostic disable-next-line: duplicate-index
    ["未知3"] = 2 ^ 19,
    ["可攻击的"] = 2 ^ 20,
    ["无敌"] = 2 ^ 21,
    ["英雄"] = 2 ^ 22,
    ["非-英雄"] = 2 ^ 23,
    ["存活"] = 2 ^ 24,
    ["死亡"] = 2 ^ 25,
    ["有机生物"] = 2 ^ 26,
    ["机械类"] = 2 ^ 27,
    ["非-自爆工兵"] = 2 ^ 28,
    ["自爆工兵"] = 2 ^ 29,
    ["非-古树"] = 2 ^ 30,
    ["古树"] = 2 ^ 31,
}

--------------------------------------------------------------------------------------
-- 转换目标类型
function mt:convertTargets(data)
    local result = 0
    for name in data:gmatch '%S+' do
        local flag = targList[name]
        if not flag then
            error('错误的目标允许类型: ' .. name)
        end
        result = result + flag
    end
    return result
end
--------------------------------------------------------------------------------------
function mt:getSlkData(keyWord)
    return slk.ability[self.handle][keyWord]
end

--------------------------------------------------------------------------------------
-- 设置技能施放类型
function mt:setCastType(type)

    if not castTypeList[type] then
        error("error - can't set skill type - " .. type)
        return
    end

    -- 主动技能设置施法目标

    if type == 0 then
        type = 4
    end

    -- 设置单位/点/无目标
    japi.EXSetAbilityDataReal(self:get_handle(), 1, 0x6D, castTypeList[type])

    -- 设置目标类型
    local targs = '敌人'
    if (type == 1) then
        targs = '敌人'
    elseif (type == 2) then
        targs = '自己 友军单位 联盟'
    else
        targs = '自己 友军单位 联盟 敌人'
    end

    -- 设置指向型目标
    japi.EXSetAbilityDataInteger(self:get_handle(), 1, 0x64, self:convertTargets(targs))

    -- 设置圆圈指示

    local aoe = japi.EXGetAbilityDataReal(self:get_handle(), 1, 106)

    if (type == 3 and self.skill.showCircle and aoe > 0) then
        japi.EXSetAbilityDataReal(self:get_handle(), 1, 110, 15)
    else
        japi.EXSetAbilityDataReal(self:get_handle(), 1, 110, 13)
    end

    -- 刷新等级
    self.owner:setAbilityLevel(self.handle, 2)
    self.owner:setAbilityLevel(self.handle, 1)

end

--------------------------------------------------------------------------------------
-- 设置技能蓝
function mt:setManaCost(r1)

    if self.targetType == 0 then
        r1 = 0
    end
    japi.EXSetAbilityDataInteger(self:get_handle(), 1, 0x68, r1)
end

--------------------------------------------------------------------------------------
-- 设置技能cd（物编）
function mt:setCd(r1, force) -- instant
    --
    if self.targetType ~= 0 or force then
        japi.EXSetAbilityDataReal(self:get_handle(), 1, 105, r1)
        -- local passiveCd = as.skillManager:getInnerCd(self)
        -- if passiveCd then
        --     as.skillManager:setInnerCd(self, r1)
        -- end
    else
        japi.EXSetAbilityDataReal(self:get_handle(), 1, 105, 0)
    end

end

--------------------------------------------------------------------------------------
-- 设置施法距离
function mt:setRange(r1)
    japi.EXSetAbilityDataReal(self:get_handle(), 1, 107, r1)
end

--------------------------------------------------------------------------------------
-- 设置作用范围
function mt:setAoe(r1)
    japi.EXSetAbilityDataReal(self:get_handle(), 1, 106, r1)
end

--------------------------------------------------------------------------------------
-- 删技能
function mt:remove()
    local removed = UnitRemoveAbility(self.owner.handle, self.handle)
    self.owner = nil
    return removed
end
--------------------------------------------------------------------------------------

-- 获取技能模板
function mt:getSkillModel(parentKey, childKey)

    local skModel = LoadInteger(glo.udg_HTSkillModel, StringHash(parentKey), StringHash(childKey))

    return skModel
end
--------------------------------------------------------------------------------------

-- 获得技能句柄(jass)
function mt:get_handle()

    if not self.owner then
        if self.name then
            gdebug('no owner skill name: ' .. self.name)
        end
        return 0
    end

    if self.owner.removed then
        return 0
    end

    return japi.EXGetUnitAbility(self.owner.handle, self.handle)
end

--------------------------------------------------------------------------------------
function mt:updateInfo()

    local skill = self.skill

    local u = self.owner
    -- local addiRange = u:getStats(cst.ST_CAST_RANGE)

    self:setTitle(skill:getTitle())
    self:setTip(skill:getTip())
    self:setArt(skill.art)

    self:setManaCost(skill:getData('cost'))
    self:setCd(skill:getData('cd'))
    local castRange = skill:getData('range')
    if castRange <= 0 then
        castRange = u:getStats(ST_RANGE)
    end
    -- gdebug('skill name: ' .. skill.name .. ' skill range: ' .. castRange)
    self:setRange(castRange)
    self:setAoe(skill:getData('aoe'))
    self:setCastType(skill.targetType)

end

--------------------------------------------------------------------------------------
function mt:getName()
    return self.skillPack.name
end
--------------------------------------------------------------------------------------
function mt:addCombo(comboName)
    self.activeCombos[comboName] = true
    local skillPack = self.skillPack
    if (skillPack.onComboAdd) then
        skillPack.onComboAdd(self, true, comboName)
    end
end
--------------------------------------------------------------------------------------
function mt:removeCombo(comboName)
    self.activeCombos[comboName] = false
    local skillPack = self.skillPack
    if (skillPack.onComboAdd) then
        skillPack.onComboAdd(self, false, comboName)
    end
end
--------------------------------------------------------------------------------------
function mt:hasCombo(comboName)
    return self.activeCombos[comboName]

end
--------------------------------------------------------------------------------------
function mt:getCurrentCd()
    if not self.owner then
        return -1
    end

    local cd = japi.EXGetAbilityState(self:get_handle(), 1)
    return cd
end
--------------------------------------------------------------------------------------
function mt:setCurrentCd(time) -- instant

    if not self.owner then
        return
    end

    time = math.max(time, 0)

    if self.targetType == 0 then
        self:setCd(time, true)
    end

    japi.EXSetAbilityState(self:get_handle(), 1, time)
end
--------------------------------------------------------------------------------------
function mt:updateCd(time) -- delay

    ac.timer(10, 1, function()
        local after = time
        self:setCurrentCd(after)
    end)
end
--------------------------------------------------------------------------------------
function mt:reduceCd(time) -- delay
    ac.timer(10, 1, function()
        local cd = self:getCurrentCd()
        if cd < 0 then
            return
        end
        local after = cd - time
        self:setCurrentCd(after)
    end)
end
--------------------------------------------------------------------------------------
function mt:reduceCdPct(pct) -- delay

    ac.timer(10, 1, function()
        local cd = self:getCurrentCd()
        if cd < 0 then
            return
        end
        local after = cd * (1 - pct)
        self:setCurrentCd(after)
    end)

end
--------------------------------------------------------------------------------------
function mt:preventCastPassive()
    gdebug('preventCastPassive')
    if not self.skill then
        return
    end

    if (self.skill.targetType == 0) then
        self.owner:cancelOrder()
    end

    -- if as.test.canFreeMove then
    --     return
    -- end

    -- if self.owner.type == 'hero' and not self.owner.inFight then
    --     self.owner:cancelOrder()
    -- end

end
--------------------------------------------------------------------------------------
function mt:show()
    local p = self.owner.owner
    SetPlayerAbilityAvailable(p.handle, self.handle, true)
end
--------------------------------------------------------------------------------------
function mt:hide()
    local p = self.owner.owner
    SetPlayerAbilityAvailable(p.handle, self.handle, false)
end
--------------------------------------------------------------------------------------
function mt:updateCastRange()
    local u = self.owner
    local addiRange = u:getStats(cst.ST_CAST_RANGE)

    local castRange = self.skill:getData('range')
    if not castRange then
        castRange = u:getStats(ST_RANGE)
    end

    self:setRange(castRange)

    gdebug(str.format('update skill range: %s, %f', self.name, addiRange))

    self.owner:setAbilityLevel(self.handle, 2)
    self.owner:setAbilityLevel(self.handle, 1)
end
--------------------------------------------------------------------------------------
function mt:setAnimCover(showAnimFunc, hideAnimFunc)
    self.showAnimFunc = showAnimFunc
    self.hideAnimFunc = hideAnimFunc
    local unit = self.unit
    local player = unit.player

    -- gdebug('setAnimCover')

    if player.lastPick == unit then
        if player:isLocal() then
            showAnimFunc()
        end
    end

end
--------------------------------------------------------------------------------------
function mt:clearAnimCover()
    local unit = self.unit
    local player = unit.player

    -- gdebug('clearAnimCover')

    if player.lastPick == unit then
        if self.hideAnimFunc then
            if player:isLocal() then
                self.hideAnimFunc()
            end

        end
    end

    self.showAnimFunc = nil
    self.hideAnimFunc = nil
end
--------------------------------------------------------------------------------------
function mt:onUnitGetPicked()
    local unit = self.unit
    local player = unit.player
    -- gdebug('onUnitGetPicked')

    if self.showAnimFunc then
        if player:isLocal() then
            self.showAnimFunc()
        end
    end
end
--------------------------------------------------------------------------------------
function mt:onUnitCancelPicked()
    local unit = self.unit
    local player = unit.player

    -- gdebug('onUnitCancelPicked')
    if self.hideAnimFunc then
        if player:isLocal() then
            self.hideAnimFunc()
        end

    end
end
--------------------------------------------------------------------------------------
return mt
