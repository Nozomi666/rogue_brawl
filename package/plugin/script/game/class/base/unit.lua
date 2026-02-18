require('game.class.manager.event_manager')
require('game.class.base.skill')
local flowtext = require 'game.__api.flowtext'
local linked = require 'tool.linked'

local mt = {}
mt.__index = mt
setmetatable(mt, cg.BaseObj)
cg.BaseUnit = mt
as.unit = mt

mt.type = 'unit'
mt.baseType = 'unit'

mt.handle = nil
mt.owner = nil
mt.player = nil
mt.dead = false
mt.isRemoving = nil
mt.removed = nil

mt.damagedTrig = nil

-- 独特
mt.skillManager = nil -- ex
mt.statsManager = nil -- init by as.statsManager
mt.buffList = nil
mt.buffNameList = nil
mt.shieldList = nil -- init by as.shield
mt.shieldNameList = nil
mt.auraList = nil -- init by mt:addAura
mt.maid = nil -- init by maid:new
mt.eventList = nil -- init by mt:addEvent
mt.summonManager = nil -- init by as.summonManager
mt.attribute = nil -- init by setAttribute
mt.master = nil -- init by summon manager
mt.isIllusion = nil
mt.isSummon = nil
mt.banBlink = false

mt.atkPoint = nil
mt.atkTgt = nil
mt.atkTimer = nil
mt.enemySkillList = nil
mt.eventList = nil
mt.getPrimary = nil

mt.typeDmgChecker = nil

mt.pauseCounter = 0
mt.noMoveCounter = 0
mt.immuneCounter = 0

mt.immuneCounterMagical = 0
mt.immuneCounterPhysical = 0

mt.controlResistCounter = 0

mt.dmgRecordPhy = 0
mt.dmgRecordMag = 0
mt.lastDmgRank = 0
mt.dmgRank = 0
mt.atkStatsPage = 0
mt.atkStatsPageMax = 1
mt.totalDmgReduction = 0

mt.barPctLast = 0
mt.barPct = 0
mt.barGreenPctLast = 0
mt.barGreenPct = 0
mt.barBluePctLast = 0
mt.barBluePct = 0
mt.deadcount = 0
mt.bPowerCasting = false

mt.banList = {
    -- ['e000'] = true,
    -- ['e001'] = true,
}
mt.unitId = 0
--------------------------------------------------------------------------------------
function mt:init()
    self.buffEffectList = {
        ['origin'] = {},
        ['chest'] = {},
        ['hand left'] = {},
        ['hand right'] = {},
        ['head'] = {},
        ['overhead'] = {},
    }

    self.unitId = mt.unitId
    mt.unitId = mt.unitId + 1

    gm:trackNewObject(self)

    self.skillList = {}
    self.skillTable = {}
    self.visitorTable = {}
    self.statsTable[ST_FINAL_DMG_PCT] = 0
    self.statsTable[ST_FINAL_REDUCE_DMG_PCT] = 0
    self.statsTable[ST_ACC] = 0
    self.statsTable[ST_EVADE] = 0
    self.statsTable[ST_BLOCK] = 0
    self.statsTable[ST_DMG_RATE] = 0
    self.statsTable[ST_DEF_RATE] = 0
    self.receiveDmgFrom = {}

    ac.wait(ms(0.01), function()
        self:modStats(ST_ATK_SPEED, 1) -- 初始100%的速度
    end)
    self:setStats(ST_MOVE_SPEED, UNIT_DEFAULT_MOVE_SPEED)

    UnitManager:addUnit(self)
end
--------------------------------------------------------------------------------------
function mt:link(uId, keys)

    if (mt.banList[I2ID(GetUnitTypeId(uId))]) then
        gdebug('avoided creating an table for dummy unit')
        return
    end

    if (GetUnitState(uId, UNIT_STATE_LIFE) <= 0.00) then
        gdebug('avoided creating an table for empty unit')
        return
    end

    local o = getmetatable(mt).new(self)

    -- init value
    o.handle = uId or 0
    o.owner = HandleGetTable(GetOwningPlayer(uId)) or 0
    o.player = o.owner
    o.pId = GetConvertedPlayerId(GetOwningPlayer(uId))
    o.eventList = {}
    o.buffList = linked.create()
    o.shieldList = linked.create()
    o.buffNameList = {}
    o.shieldNameList = {}

    dbg.gchash(o, uId)
    o.gchash = uId
    HandleRegTable(uId, o)

    -- init damage receiver
    o.damagedTrig = as.eventManager:ujRegisterDmgEvent(uId)

    -- hpbar
    local selectSize = tonumber(o:getSlkData('scale'))
    local base = [[enemy_hpbarbase.tga]]
    local fill = [[enemy_hpbar.tga]]
    -- local base = [[arch_hero_exp_base.tga]]
    -- local fill = [[arch_hero_exp_bar_red.tga]]

    if o.player ~= 0 and o.player:isNotEnemyPlayer() then
        fill = [[arch_hero_exp_bar_green.tga]]
    end

    local isFinalBoss = false
    if keys then
        if keys.bFinalBoss then
            isFinalBoss = true
            gdebug('link a boss unit')
        end
    end

    local w = 400 * screenRatio * 0.3 * 0.5
    local h = 25 * 0.3

    local innerW = w - 3
    local innerH = h - 3

    local hpBarTag = nil
    if keys and keys.hpBarTag then
        hpBarTag = keys.hpBarTag
    end

    local hpBar = class.hpBar.add_child(MAIN_UI, base, fill, w, h, innerW, innerH, o, hpBarTag)
    o.hpBar = hpBar
    japi.SetUnitPressUIVisible(o.handle, false)

    hpBar:bind_unit_overhead(o)

    o:init()

    -- 飞行单位高度
    local flyHeight = tonumber(o:getSlkData('moveHeight'))
    if flyHeight > 0 then
        o:setHeight(flyHeight)
    end

    -- shadow
    local eff = {
        -- model = [[[TX][Z]yinying.mdx]],
        model = [[222.mdx]],
        bind = 'origin',
        time = -1,
        mustShow = true,
    }
    o.shadowEffect = fc.unitEffect(eff, o)

    -- fc.asyncCheck('unit create sync check')
    -- gdebug(str.format("unit X %.1f, unit Y %.1f",o:getloc()[1], o:getloc()[2]))

    -- local eff = {
    --     model = [[222.mdx]],
    --     bind = 'origin',
    --     time = -1,
    --     force = true,
    -- }
    -- o.shadowEffect = fc.unitEffect(eff, o)

    return o
end
--------------------------------------------------------------------------------------
function mt:onCreate()
    local hpBar = self.hpBar
    if self.hpBarOffsetX then
        hpBar:setHpbarOffseX(self.hpBarOffsetX)
    end
    if self.hpBarOffsetY then
        hpBar:setHpbarOffseY(self.hpBarOffsetY)
    end
    if self.hpBarOffsetX then
        hpBar:setHpbarOffseZ(self.hpBarOffsetZ)
    end
end
--------------------------------------------------------------------------------------
function mt:updateLastMomentPosition()
    self.lastMomentPosition = self:getloc()
end
--------------------------------------------------------------------------------------
function mt:onEveryHalfSec()
    -- gdebug('unit onEveryHalfSec')
    --------------------------------------------------------------------------------------
    -- update pos
    self:updateLastMomentPosition()

    if self:isAlive() then
        --------------------------------------------------------------------------------------
        -- hp regen
        local hpRegen = math.max(self:getStats(ST_HP_REGEN), 0) / 2
        self:modStats(ST_HP, hpRegen)
        --------------------------------------------------------------------------------------
        -- mp regen
        local mpRegen = math.max(self:getStats(ST_MP_REGEN), 0) / 2
        mpRegen = mpRegen + self:getStats(ST_MP_REGEN_PCT) * mpRegen
        self:modStats(ST_MP, mpRegen)
        -- gdebug('unit onEveryHalfSec mpRegen: ' .. mpRegen)
        --------------------------------------------------------------------------------------
        -- damage trig test
        -- if self.bComputerEnemy and (not self.bInvulnerable) then
        --     if self.reportTestDmg then

        --     else
        --         gdebug('unit report dmg wrong')
        --         TriggerRemoveCondition(self.damagedTrig)
        --         DestroyTrigger(self.damagedTrig)
        --         dbg.handle_unref(self.damagedTrig)
        --         self.damagedTrig = as.eventManager:ujRegisterDmgEvent(self.handle)
        --         gdebug('fix enemy dmg trigger')
        --     end

        --     self.reportTestDmg = false
        --     UnitDamageTarget(self.handle, self.handle, 101, false, false, ATTACK_TYPE_MELEE, DAMAGE_TYPE_NORMAL,
        --         WEAPON_TYPE_WHOKNOWS)
        -- end

        if self.halfSecFlag then
            self.halfSecFlag = false
            -- trigger every half second event
            xpcall(function()
                self:triggerEvent(UNIT_EVENT_ON_EVERY_SECOND, {})
            end, function(msg)
                print(msg, debug.traceback())
            end)
        else
            self.halfSecFlag = true
        end

    end

end
--------------------------------------------------------------------------------------
function mt:addSkill(skillName)
    if self:getSkill() then
        warn('try add repeat skill: ' .. skillName)
        return
    end

    local skill = cg.Skill:new(self, skillName)

    table.insert(self.skillList, skill)
    self.skillTable[skillName] = skill

    return skill
end
--------------------------------------------------------------------------------------
function mt:getSkill(skillName)
    return self.skillTable[skillName]
end
mt.hasSkill = mt.getSkill
--------------------------------------------------------------------------------------
function mt:removeSkill(skillName)
    local skill = self:getSkill(skillName)
    if not skill then
        warn('try delete nil skill: ' .. skillName)
        return
    end

    skill:remove()

    table.removeTarget(self.skillList, skill)
    self.skillTable[skillName] = nil

    return skill
end
--------------------------------------------------------------------------------------
function mt:getPlayerId()

    return self.owner.id
end

--------------------------------------------------------------------------------------
function mt:getJPlayer()

    return self.owner.handle
end

--------------------------------------------------------------------------------------
function mt:getPlayer()

    return self.owner
end
--------------------------------------------------------------------------------------
function mt:pause()
    PauseUnit(self.handle, true)
end
--------------------------------------------------------------------------------------
function mt:resume()
    PauseUnit(self.handle, false)
end

--------------------------------------------------------------------------------------
function mt:getName()
    if self and self.name then
        return self.name
    end
    return self and GetUnitName(self.handle) or 'unknow'
end

--------------------------------------------------------------------------------------
function mt:setface(face)
    japi.EXSetUnitFacing(self.handle, face)
end
--------------------------------------------------------------------------------------
function mt:setFace(face)
    japi.EXSetUnitFacing(self.handle, face)
end
--------------------------------------------------------------------------------------
function mt:setSmoothFace(face)
    SetUnitFacing(self.handle, face)
end
--------------------------------------------------------------------------------------
function mt:getface()
    return GetUnitFacing(self.handle)
end
--------------------------------------------------------------------------------------
function mt:getFace()
    return GetUnitFacing(self.handle)
end
--------------------------------------------------------------------------------------
function mt:getLoc()
    return as.point:getUnitLoc(self)
end
--------------------------------------------------------------------------------------
function mt:getloc()
    return as.point:getUnitLoc(self)
end
--------------------------------------------------------------------------------------
function mt:getPoint()
    return as.point:getUnitLoc(self)
end
--------------------------------------------------------------------------------------
function mt:get_point()
    -- if self._dummy_point then
    --     return self._dummy_point
    -- end

    return as.point:getUnitLoc(self)

    -- if self.removed then
    --     return self._last_point:copy()
    -- else
    --     return ac.point(jass.GetUnitX(self.handle), jass.GetUnitY(self.handle))
    -- end
end
--------------------------------------------------------------------------------------
function mt:uj2t(uj)
    return HandleGetTable(uj) or as.unit:new(uj)
end

--------------------------------------------------------------------------------------
function mt:addAbility(abid, lv)
    lv = lv or 1

    UnitAddAbility(self.handle, abid)
    self:setAbilityLevel(abid, lv)
end

--------------------------------------------------------------------------------------
function mt:setAbilityLevel(abid, lv)

    -- local ability_id = base.string2id(ability_id)
    jass.SetUnitAbilityLevel(self.handle, abid, lv or 1)
end
--------------------------------------------------------------------------------------
function mt:getSlkData(keyWord)
    local val
    -- xpcall(function()
    --     val = slk.unit[GetUnitTypeId(self.handle)][keyWord]
    -- end, function(msg)
    --     print(msg, debug.traceback())
    -- end)

    val = slk.unit[GetUnitTypeId(self.handle)][keyWord]

    return val
end
--------------------------------------------------------------------------------------
function mt:isRange()
    return not (self:getSlkData('weapTp1') == 'normal')
end
--------------------------------------------------------------------------------------
function mt:isMelee()
    return self:getSlkData('weapTp1') == 'normal'
end

--------------------------------------------------------------------------------------
-- @returns u table
function mt:createUnit(p, uType, pt, face, keys)

    local x, y

    if not pt.type == 'point' then
        x = 0
        y = 0
    else
        x, y = ac.point.get(pt)
    end

    return self:link(CreateUnit(p.handle, ID(uType), x, y, face), keys)
end

--------------------------------------------------------------------------------------
-- p is tb
-- @returns u table
function mt:createJUnit(p, uType, pt, face)

    local x, y

    if not pt.type == 'point' then
        x = 0
        y = 0
    else
        x, y = ac.point.get(pt)
    end

    return CreateUnit(p.handle, ID(uType), x, y, face)
end

--------------------------------------------------------------------------------------
-- 是否被移除
function mt:isRemoved()
    return self.removed
end
-- 是否存活
function mt:isAlive()

    if self.dead or self.removed then
        return false
    end

    return (GetUnitState(self.handle, UNIT_STATE_LIFE) > 0.00)
end
--------------------------------------------------------------------------------------
function mt:isDead()

    if self.dead or self.removed then
        return true
    end

    return (GetUnitState(self.handle, UNIT_STATE_LIFE) <= 0.00)
end
--------------------------------------------------------------------------------------
-- 是否是友方
--	对象
function mt:isAlly(other)
    return IsUnitAlly(self.handle, GetOwningPlayer(other.handle))
end
--------------------------------------------------------------------------------------
-- 是否是敌人
--	对象
function mt:isEnemy(other)
    return IsUnitEnemy(self.handle, GetOwningPlayer(other.handle))
end
--------------------------------------------------------------------------------------
-- 是否是英雄
--	对象
function mt:isHero()
    return self.type == 'hero'
end

--------------------------------------------------------------------------------------
function mt:dealDamage(tgt, dmg, isAtk, dmgType, keys)

    -- if self.removed or tgt.removed then
    --     return
    -- end

    -- local atkType, dmgTypeJ, wepType

    -- if keys then
    --     wepType = keys.weapType
    -- end

    -- if dmgType == cst.DMG_TYPE_PHYSICAL then
    --     atkType = ATTACK_TYPE_NORMAL
    --     dmgTypeJ = DAMAGE_TYPE_NORMAL
    -- elseif dmgType == cst.DMG_TYPE_MAGICAL then
    --     atkType = ATTACK_TYPE_NORMAL
    --     dmgTypeJ = DAMAGE_TYPE_MAGIC
    -- else
    --     atkType = ATTACK_TYPE_NORMAL
    --     dmgTypeJ = DAMAGE_TYPE_DIVINE
    -- end

    -- if MAP_DEEP_DEBUG then
    --     local showType
    --     if dmgType == cst.DMG_TYPE_PHYSICAL then
    --         showType = '物理'
    --     elseif dmgType == cst.DMG_TYPE_MAGICAL then
    --         showType = '魔法'
    --     else
    --         showType = '真实'
    --     end
    --     mapdebug(str.format('%s 对 %s 施加 %f 点%s伤害', self:getName(), tgt:getName(), dmg, showType))
    --     -- self:getName() .. ' 对 ' .. tgt:getName() .. '施加 ' .. dmg .. ' 点伤害'
    -- end

    -- self.dmgKeys = keys
    -- UnitDamageTarget(self.handle, tgt.handle, dmg, isAtk, false, atkType, dmgTypeJ, wepType or WEAPON_TYPE_WHOKNOWS)
    -- self.dmgKeys = nil

end

--------------------------------------------------------------------------------------
function mt:remove()
    -- gdebug(str.format("unit on remove event %s, from player %s",self:getName(), self.owner:getName()))
    -- gdebug(str.format("unit X %.1f, unit Y %.1f",self:getloc()[1], self:getloc()[2]))
    -- set removed
    self.removed = true

    gm:untrackObject(self)

    fc.clearAttr(self)

    as.buff:removeAllBuff(self)

    if (self.shadowEffect) then
        fc.removeEffect(self.shadowEffect)
    end

    self.hpBar:beforeDestroy()
    self.hpBar:destroy()

    UnitManager:removeUnit(self)

    -- delete j unit
    RemoveUnit(self.handle)
    -- delete damage event and trigger
    -- TriggerClearActions(self.damagedTrig)
    TriggerRemoveCondition(self.damagedTrig)
    DestroyTrigger(self.damagedTrig)
    dbg.handle_unref(self.damagedTrig)
    -- deregister lua table
    HandleRemoveTable(self.handle)

    self.handle = nil

end

--------------------------------------------------------------------------------------
function mt:delayRemove(time)
    if self.isRemoving then
        mapdebug('delay remove twice')
        return
    end

    self.isRemoving = true
    ac.timer(ms(time), 1, function()
        self:remove()
    end)

end
--------------------------------------------------------------------------------------
function mt:onCast(keys)
    if (keys.data.skillType == '自定义技能' or keys.data.skillType == '天赋') then
        self:triggerEvent(cst.UNIT_EVENT_ON_CAST, keys)
    end

end
--------------------------------------------------------------------------------------
function mt:getKiller()
    return self.lastDmgFrom
end

--------------------------------------------------------------------------------------
-- killer = killer,
-- u = u,
-- p = killer.owner,
function mt:onDie(keys)

    xpcall(function()
        self:triggerEvent(UNIT_EVENT_BEFORE_DIE, keys)
    end, function(msg)
        print(msg, debug.traceback())
    end)

    if keys.revived then
        return
    end

    self.dead = true
    local killer = keys.killer
    local kOwner = keys.p

    if killer then
        xpcall(function()
            killer:triggerEvent(UNIT_EVENT_ON_KILL, keys)
        end, function(msg)
            print(msg, debug.traceback())
        end)

        if kOwner then
            xpcall(function()
                kOwner:triggerEvent(PLAYER_EVENT_ON_KILL, keys)
                kOwner.zhuanzhu = 1
                if self.pTarget and self.pTarget ~= kOwner then
                    kOwner.jingjiduli = 1
                end
                
            end, function(msg)
                print(msg, debug.traceback())
            end)
        end

    end

    -- if self.targetPlayer then
    --     xpcall(function()
    --         self.targetPlayer:triggerEvent(cst.PLAYER_EVENT_ENEMY_DIE, keys)
    --     end, function(msg)
    --         print(msg, debug.traceback())
    --     end)

    -- end

    xpcall(function()
        if self.deadcount then
            self.deadcount = self.deadcount + 1
        else
            self.deadcount = 1
        end
        self:triggerEvent(UNIT_EVENT_ON_DIE, keys)
    end, function(msg)
        print(msg, debug.traceback())
    end)

    as.buff:removeAllBuff(self)

    if (self.shadowEffect) then
        fc.removeEffect(self.shadowEffect)
        self.shadowEffect = nil
    end

    if not IsUnitType(self.handle, UNIT_TYPE_HERO) then
        self:delayRemove(5)
    end

    -- hide ui
    local localPlayer = as.player:getLocalPlayer()
    if localPlayer.lastPick == self then
        GUI.UnitInfo.atkInfoOn = false
        GUI.UnitInfo.defInfoOn = false
        GUI.EnemySkills:hide()
        toolbox:hide()
    end

end
--------------------------------------------------------------------------------------
function mt:issuePointOrder(act, point)
    local x, y = point:get()

    if not self then
        return
    end

    -- IssueNeutralPointOrder( self.owner.handle, self.handle, act, x, y )

    ac.wait(ms(0.02), function()
        -- gdebug('do a act')
        IssuePointOrder(self.handle, act, x, y)
    end)

end
--------------------------------------------------------------------------------------
function mt:issueImmediateOrder(act)

    if not self then
        return
    end

    -- IssueImmediateOrder(self.handle, act)

    ac.wait(ms(0.02), function()
        IssueImmediateOrder(self.handle, act)
    end)

end
--------------------------------------------------------------------------------------
function mt:issueUnitOrder(act, tgt)

    if not self then
        return
    end

    ac.wait(ms(0.02), function()
        IssueTargetOrder(self.handle, act, tgt.handle)
    end)

end
--------------------------------------------------------------------------------------
function mt:getHpPercent()
    return GetUnitState(self.handle, UNIT_STATE_LIFE) / GetUnitState(self.handle, UNIT_STATE_MAX_LIFE)
end
--------------------------------------------------------------------------------------
function mt:getMpPercent()
    return GetUnitState(self.handle, UNIT_STATE_MANA) / GetUnitState(self.handle, UNIT_STATE_MAX_MANA)
end
--------------------------------------------------------------------------------------
function mt:getLostHpPercent()
    return 1 - GetUnitState(self.handle, UNIT_STATE_LIFE) / GetUnitState(self.handle, UNIT_STATE_MAX_LIFE)
end
--------------------------------------------------------------------------------------
function mt:healFix(target, amount)
    if amount <= 0 then
        return
    end

    if target.removed then
        return
    end

    if target:getStats(ST_HP) <= 0 then
        return
    end

    flowtext.printHeal(self, target, amount, nil, false)

    target:modStats(ST_HP, amount)
    target:triggerEvent(UNIT_EVENT_ON_REGEN, {
        amt = amount,
    })

    -- -- 回血事件
    -- if target.eventList[cst.UNIT_EVENT_ON_HEALED] then
    --     local keys = {
    --         u = target,
    --         from = self,
    --         amt = amount,
    --     }

    --     xpcall(function()
    --         target:triggerEvent(cst.UNIT_EVENT_ON_HEALED, keys)
    --     end, function(msg)
    --         print(msg, debug.traceback())
    --     end)

    -- end
end
--------------------------------------------------------------------------------------
function mt:heal(target, amount)
    if amount <= 0 then
        return
    end

    if target.removed then
        return
    end

    amount = amount * (1 + ConvertFunctionInverse1(self:getStats(ST_HEAL_RATE)) / 100 +
                 ConvertFunctionInverse1(target:getStats(ST_HEALED_RATE)) / 100)

    self:healFix(target, amount)
end
--------------------------------------------------------------------------------------
function mt:addAura(keys)
    local name = keys.name
    local lv = keys.lv
    local aoe = keys.aoe
    local toAlly = keys.toAlly
    local toEnemy = keys.toEnemy
    local notToSelf = keys.notToSelf
    local buffInterval = keys.buffInterval
    local effKeys = keys.effKeys
    local filter = keys.filter

    if not self.auraList then
        self.auraList = {}
        self:pulseAura()
    end

    local eff = effKeys and as.effect:unitEffect(effKeys, self) or nil

    if type(name) == 'table' then
        msg.error(cst.ALL_PLAYERS, str.format('auraName appears table: %s', name))
        return
    end

    if self:getAttr('auraList' .. name) then
        gdebug('repeat auralist')
        return
    end

    local keys = {
        lv = lv,
        aoe = aoe,
        toEnemy = toEnemy,
        toAlly = toAlly,
        notToSelf = notToSelf,
        buffInterval = buffInterval or 0,
        eff = eff,
        filter = filter,
        buffName = name,
        skill = keys.skill,
    }

    self:setAttr('auraList' .. name, keys)

    table.insert(self.auraList, keys)
    -- gdebug(str.format('%s add aura [%s]', self:getName(), name))

    -- for _, pack in ipairs(self.auraList) do
    --     gdebug(str.format('%s current aura [%s]', self:getName(), pack.buffName))
    -- end

end
--------------------------------------------------------------------------------------
function mt:removeAura(name)
    if not self.auraList then
        self.auraList = {}
        self:pulseAura()
    end

    local aura = self:getAttr('auraList' .. name)
    if not aura then
        gdebug('error - remove aura fail, not exist')
        return
    end

    local eff = aura.eff

    if eff then
        fc.removeEffect(eff)
    end

    -- for _, pack in ipairs(self.auraList) do
    --     gdebug(str.format('%s before remove aura [%s]', self:getName(), pack.buffName))
    -- end

    -- gdebug(str.format('%s remove aura [%s]', self:getName(), name))
    table.removeTarget(self.auraList, aura)
    self:setAttr('auraList' .. name, false)

    -- for _, pack in ipairs(self.auraList) do
    --     gdebug(str.format('%s after remove aura [%s]', self:getName(), pack.buffName))
    -- end

end

--------------------------------------------------------------------------------------
function mt:pulseAura()

    local act = function(t)
        if (self:isDead()) then
            if (self.type ~= 'hero') then
                t:remove()
                -- gdebug(str.format('aura timer removed, unit: %s', GetUnitName(self.handle)))
                return
            end
            return
        end

        local list = {}

        for i, aura in ipairs(self.auraList) do
            table.insert(list, aura)
        end

        for i, aura in ipairs(list) do
            local u = self
            local buffName = aura.buffName
            -- gdebug(str.format('%s trigger aura [%s]', self:getName(), buffName))
            local lv = aura.lv
            local aoe = aura.aoe * (1 + self:getStats(ST_AURA_AOE_PCT))
            local toEnemy = aura.toEnemy
            local toAlly = aura.toAlly
            local notToSelf = aura.notToSelf
            local buffInterval = aura.buffInterval
            local filter = aura.filter
            local point = self:getLoc()

            if toEnemy and not toAlly then
                -- group action
                for _, tgt in ac.selector():inRangeEnemy(point, aoe, u):isNotIllusion():ipairs() do
                    if ((u:isAlly(tgt) and toAlly) or (u:isEnemy(tgt) and toEnemy)) then
                        if (u ~= tgt or (not notToSelf)) then
                            if (not filter) or filter(tgt) then
                                ApplyBuff({
                                    unit = u,
                                    tgt = tgt,
                                    buffName = buffName,
                                    lv = lv,
                                    time = 2,
                                    skill = aura.skill,
                                })

                            end
                        end

                    end
                end
            elseif toAlly and not toEnemy then
                -- group action
                for _, tgt in ac.selector():inRangeAlly(point, aoe, u):isNotIllusion():ipairs() do
                    if ((u:isAlly(tgt) and toAlly) or (u:isEnemy(tgt) and toEnemy)) then
                        if (u ~= tgt or (not notToSelf)) then
                            if (not filter) or filter(tgt) then
                                ApplyBuff({
                                    unit = u,
                                    tgt = tgt,
                                    buffName = buffName,
                                    lv = lv,
                                    time = 2,
                                    skill = aura.skill,
                                })

                            end
                        end

                    end
                end
            else
                -- group action
                for _, tgt in ac.selector():inRangeAll(point, aoe):isNotIllusion():ipairs() do
                    if ((u:isAlly(tgt) and toAlly) or (u:isEnemy(tgt) and toEnemy)) then
                        if (u ~= tgt or (not notToSelf)) then
                            if (not filter) or filter(tgt) then
                                ApplyBuff({
                                    unit = u,
                                    tgt = tgt,
                                    buffName = buffName,
                                    lv = lv,
                                    time = 2,
                                    skill = aura.skill,
                                })

                            end
                        end

                    end
                end
            end

        end

    end

    ac.timer(ms(0.5), 0, function(t)
        act(t)
    end)

end
--------------------------------------------------------------------------------------
function mt:addItem(itemType)
    local keys = {
        owner = self.owner,
        holder = self,
    }
    local item = as.item:makeItem(itemType, keys)
    return item
end
--------------------------------------------------------------------------------------
function fc.addItem(unit, itemName)
    local itemType = reg:getItemType(itemName)
    if not itemName then
        warn('add item fail, item name: ' .. itemName)
        traceError()
        return
    end

    if not unit then
        warn('add item fail, item name: ' .. itemName)
        traceError()
        return
    end

    return unit:addItem(itemType)
end
--------------------------------------------------------------------------------------
function mt:kill(killer)
    self.lastDmgFrom = killer
    SetUnitLifeBJ(self.handle, 0)
end
--------------------------------------------------------------------------------------
function mt:killBy(killer)
    self:kill(killer)
end
--------------------------------------------------------------------------------------
function mt:killOther(other)
    other.specialKiller = self
    SetUnitLifeBJ(other.handle, 0)
end
--------------------------------------------------------------------------------------
function mt:hasBuff(buffName, fromApplier)

    local buffChain = self.buffNameList[buffName]
    if not buffChain then
        buffChain = linked.create()
        self.buffNameList[buffName] = buffChain
    end

    if not fromApplier then
        return buffChain:at(1)
    end

    local buff = buffChain:at(1)

    while buff and not (buff.from == fromApplier) do
        buff = buffChain:next(buff)
        -- gdebug('get next buff: %s', buffName)
    end

    return buff
end
--------------------------------------------------------------------------------------
function mt:countNearbyEnemy(aoe)
    local list = {}
    local u = self
    local counter = 0
    for _, tgt in ac.selector():inRange(u:getLoc(), aoe):isEnemy(u):ipairs() do
        table.insert(list, tgt)
        counter = counter + 1
        if IsUnitType(tgt.handle, UNIT_TYPE_TAUREN) then
            counter = counter + 2
        end
        if IsUnitType(tgt.handle, UNIT_TYPE_GIANT) then
            counter = counter + 9
        end
    end

    return counter, list
end
--------------------------------------------------------------------------------------
function mt:isStrongUnit()
    return self.eType == ENEMY_TYPE_ELITE or self.eType == ENEMY_TYPE_BOSS
    -- return IsUnitType(self.handle, UNIT_TYPE_TAUREN) or IsUnitType(self.handle, UNIT_TYPE_GIANT)
end
--------------------------------------------------------------------------------------
function mt:isStrongEnemy()
    return self.eType == ENEMY_TYPE_ELITE or self.eType == ENEMY_TYPE_BOSS
end
--------------------------------------------------------------------------------------
function mt:isElite()
    return self.eType == ENEMY_TYPE_ELITE
end
--------------------------------------------------------------------------------------
function mt:isBoss()
    return self.eType == ENEMY_TYPE_BOSS
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
function mt:cancelOrder()
    local act = function()
        self:issueImmediateOrder('stop')
    end
    ac.timer(1, 1, function()
        act()
    end)
end
--------------------------------------------------------------------------------------
function mt:move(point, face)
    local x, y = point:get()
    SetUnitX(self.handle, x)
    SetUnitY(self.handle, y)
    if face then
        japi.EXSetUnitFacing(self.handle, face)
    end

end
--------------------------------------------------------------------------------------
function mt:getHeight()
    return GetUnitFlyHeight(self.handle)
end
--------------------------------------------------------------------------------------
function mt:growStats(source, stats, amount)
    local u = self
    local color = cst:getConstTag(stats, 'textColor') or '|cffffcc00'
    local stName = cst:getConstTag(stats, 'name')
    local text

    if gm.endlessMode then
        return
    end

    if cst:getConstTag(stats, 'isPct') then
        text = str.format('%s+%.1f%%%s|r', color, amount, stName)
    else
        text = str.format('%s+%.0f%s|r', color, amount, stName)
    end

    local angle = math.random(20, 160)
    local textKeys = {
        text = text,
        point = fc.polarPoint(u:getLoc(), math.random(60, 120), angle),
        size = 10,
        speed = 64,
        angle = angle,
        fadeTime = 1,
        time = 2,
    }
    as.flowText.makeClassicFlowText(textKeys)

    u:modStats(stats, amount)

end
--------------------------------------------------------------------------------------
function mt:preAtk(tgt)

    if tgt:isAlly(self) then
        self:cancelOrder()
        return
    end

    if self.type == 'hero' then
        self:autoCast(tgt)
    end

end
--------------------------------------------------------------------------------------
function mt:kicked(angle, speed, acc, time)

    if self.duringKicked then
        return
    end

    if self.bNoKicked then
        return
    end

    if self.bPowerCasting then
        return
    end

    self.duringKicked = true

    if self:isStrongEnemy() then
        speed = speed * 0.5
    end

    speed = speed * math.max((1 - self:getStats(ST_KNOCK_BACK_RESIST) / 100), 0.01)

    speed = speed * 0.03
    acc = acc * 0.03

    if time >= 0 then
        ac.loop(ms(0.03), function(timer)
            local pointT = fc.polarPoint(self:getloc(), speed, angle)
            if not pointT:isWalkable() then
                self.duringKicked = false
                timer:remove()
                return
            end
            self:move(pointT)
            speed = speed + acc
            time = time - 0.03
            if time <= 0 then
                self.duringKicked = false
                timer:remove()
            end
        end)

    else
        ac.loop(ms(0.03), function(t)
            local pointT = fc.polarPoint(self:getloc(), speed, angle)
            if not pointT:isWalkable() then
                self.duringKicked = false
                t:remove()
                return
            end
            self:move(pointT)
            speed = speed + acc
            if speed <= 0 then
                self.duringKicked = false
                t:remove()
            end
        end)
    end

end
--------------------------------------------------------------------------------------
function mt:setAtkPoint(point)
    if self.atkTgt then
        self:setAtkTgt(self.atkTgt)
        return
    end

    if (self.type == 'hero' and not self.inFight) then
        return
    end

    self.atkPoint = point
    self:issuePointOrder('attack', point)
end
--------------------------------------------------------------------------------------
function mt:getEmptyItemSlotNum()
    local c = 0
    for i = 1, 6 do
        local ij = UnitItemInSlotBJ(self.handle, i)

        if ij == 0 then
            c = c + 1
        end
    end

    return c
end
--------------------------------------------------------------------------------------
function mt:getItemBySlot(slot)
    local ij = UnitItemInSlotBJ(self.handle, slot)
    return as.item:j2t(ij)
end
--------------------------------------------------------------------------------------
function mt:show()
     local uJ = self.handle
    ShowUnit(uJ, true)
end
--------------------------------------------------------------------------------------
function mt:hide()
    local uJ = self.handle
    ShowUnit(uJ, false)

    if self.hpBar then
        self.hpBar:beforeDestroy()
        self.hpBar:destroy()
    end
end
--------------------------------------------------------------------------------------
function mt:suicide()
    self.lastDmgFrom = self
    self:setStats(ST_HP, 0)
end
--------------------------------------------------------------------------------------
function mt:enableFly()
    if not self.canFly then
        -- gdebug('initial fly')
        self.canFly = true
        UnitAddAbility(self.handle, ID('Amrf'))
        UnitRemoveAbility(self.handle, ID('Amrf'))
    end

end
--------------------------------------------------------------------------------------
function mt:setHeight(val)
    if not self.canFly then
        self:enableFly()
    end
    ac.wait(ms(0.05), function()
        SetUnitFlyHeight(self.handle, val, 99999)
    end)

end
--------------------------------------------------------------------------------------
function mt:taunt(tgt, time)
    time = time or 1
    time = math.ceil(time)
    tgt:setAtkTgt(self)

end
--------------------------------------------------------------------------------------
function mt:changeOwner(p)
    self.owner = p
    self.player = p
    SetUnitOwner(self.handle, p.handle, true)

    UnitManager:removeUnit(self)
    UnitManager:addUnit(self)
end
--------------------------------------------------------------------------------------
function mt:setAtkTgt(tgt)
    self.atkTgt = tgt
    self:issueUnitOrder('attack', tgt)
end
--------------------------------------------------------------------------------------
function mt:changeAtkStatsPage()
    local maxPage = 1
    self.atkStatsPage = self.atkStatsPage + 1
    if self.atkStatsPage > maxPage then
        self.atkStatsPage = 0
    end
end
--------------------------------------------------------------------------------------
function mt:failAddCount(name, rateInc, rateMax)
    local prev = self:getAttr(name) or 0

    if prev >= rateMax then
        return true
    end

    -- can be seperate
    self:setAttr(name, prev + rateInc)
    return false

end
--------------------------------------------------------------------------------------
function mt:mouseInItem(btnId)
    gdebug('mouse in item')

    local itemJ = UnitItemInSlotBJ(self.handle, btnId + 1)
    local item = as.item:j2t(itemJ)

    if not item then
        return
    end

    if item.isEquip then
        local equip = item
        equip:updateEnchantShow() -- async
    end

end
--------------------------------------------------------------------------------------
function mt:removeBuff(buffName)
    return as.buff:removeBuffByName(self, buffName)
end
--------------------------------------------------------------------------------------
function mt:playAnimId(id)
    if id < 0 then
        return
    end
    SetUnitAnimationByIndex(self.handle, id)
end
--------------------------------------------------------------------------------------
function mt:playAnimName(name)
    SetUnitAnimation(self.handle, name)
end
--------------------------------------------------------------------------------------
function mt:setAnimSpeed(speed)
    SetUnitTimeScale(self.handle, speed)
end
--------------------------------------------------------------------------------------
function mt:resetAnim()
    if self:isAlive() then
        self:playAnimName('stand_pick')
    end
end
--------------------------------------------------------------------------------------
function mt:findItemByName(findName)
    for i = 1, 6 do
        local item = self:getItemBySlot(i)
        if item and item.name == findName then
            return item
        end
    end

    return
end
--------------------------------------------------------------------------------------
function mt:getRandomRangePoint()
    return fc.polarPoint(self:getloc(), math.random(self:getStats(ST_RANGE)), math.random(360))
end
--------------------------------------------------------------------------------------
function mt:kickedOnSky(initSpeed, deltaSpeed)

    if self.bKickedOnSky then
        return
    end

    ApplyBuff({
        unit = self,
        tgt = self,
        buffName = cst.BUFF_PAUSE,
        lv = 1,
        time = -1,
    })

    self.bKickedOnSky = true
    local currentSpeed = initSpeed
    local currentHeight = 0
    ac.loop(ms(0.03), function(t)
        currentHeight = currentHeight + currentSpeed
        currentSpeed = currentSpeed + deltaSpeed
        if currentHeight <= 0 then
            self:setHeight(0)
            self.bKickedOnSky = false
            self:removeBuff(cst.BUFF_PAUSE)
            t:remove()
            return
        else
            self:setHeight(currentHeight)
        end
    end)

end
--------------------------------------------------------------------------------------
function mt:setMoveType(moveType)
    japi.EXSetUnitMoveType(self.handle, moveType)

end
--------------------------------------------------------------------------------------
function mt:setColor(r, g, b)
    SetUnitVertexColorBJ(self.handle, r, g, b, self.opacity or 0)
end
--------------------------------------------------------------------------------------
function mt:setOpacity(opacity)
    SetUnitVertexColorBJ(self.handle, 255, 255, 255, opacity * 100)
end
--------------------------------------------------------------------------------------
function mt:applySlow(tgt, rate, time)
    if rate > 0 then
        self:triggerEvent(UNIT_EVENT_ON_SLOW_ENEMY, {
            u = self,
            tgt = tgt,
            rate = rate,
        })
    end

    tgt:modStats(ST_SLOW_SPEED, rate)

    if time and time > 0 then
        time = time * (1 + self:getStats(ST_SLOW_TIME))
        ac.wait(ms(time), function()
            tgt:modStats(ST_SLOW_SPEED, -rate)
        end)
    end

end
--------------------------------------------------------------------------------------
function mt:addDmgReduction(rate, time)
    self:modStats(ST_DMG_REDUCTION, rate)

    if time and time > 0 then
        ac.wait(ms(time), function()
            self:modStats(ST_DMG_REDUCTION, -rate)
        end)
    end
end
--------------------------------------------------------------------------------------
function mt:getDebuffNum()
    return self.debuffCounter
end
--------------------------------------------------------------------------------------
function mt:passRandomPassiveTest(baseChance)
    if baseChance <= 0 then
        return false
    end
    local actualChance = baseChance
    return math.randomPct() <= actualChance
end
--------------------------------------------------------------------------------------
function mt:failRandomPassiveTest(baseChance)
    return not (self:passRandomPassiveTest(baseChance))
end
--------------------------------------------------------------------------------------
function mt:passQuickRandomPassiveTest(baseChance, triggerObject)
    if baseChance <= 0 then
        return false
    end

    if not triggerObject then
        return false
    end

    if not triggerObject.nextQuickRandomNeed then
        self:resetQuickRandomPassiveObjectNeed(baseChance, triggerObject)
    end

    triggerObject.nextQuickRandomNeed = triggerObject.nextQuickRandomNeed - 1
    -- gdebug('quick random need: ' .. triggerObject.nextQuickRandomNeed)
    if triggerObject.nextQuickRandomNeed <= 0 then
        self:resetQuickRandomPassiveObjectNeed(baseChance, triggerObject)
        return true
    end

    return false
end
--------------------------------------------------------------------------------------
function mt:resetQuickRandomPassiveObjectNeed(baseChance, triggerObject)
    if not triggerObject.nextQuickRandomNeed then
        triggerObject.nextQuickRandomNeed = 0
    end

    local triggerChanceAvergage = 1 / baseChance
    local nextQuickRandomNeed = math.randomReal(triggerChanceAvergage * 0.8, triggerChanceAvergage * 1.2)
    triggerObject.nextQuickRandomNeed = triggerObject.nextQuickRandomNeed + nextQuickRandomNeed
    -- gdebug('quick random need reset: ' .. triggerObject.nextQuickRandomNeed)
end
--------------------------------------------------------------------------------------
return mt
