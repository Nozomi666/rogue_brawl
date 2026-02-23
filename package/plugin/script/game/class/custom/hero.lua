local Unit = require 'game.class.base.unit'
require 'game.class.custom.unit'
require 'game.class.base.skill_btn'
require 'game.class.custom.maid'

local mt = {}
mt.__index = mt
setmetatable(mt, cg.Unit)
cg.Hero = mt

-- 通用 -----------------------------
mt.parent = Unit

mt.type = 'hero'
mt.baseType = 'unit'

mt.hId = 0
mt.lv = 1
mt.exp = 0
mt.expFloat = 0
mt.fp = 100

mt.archExpListName = nil
mt.archSlotId = nil
mt.archLv = 0

mt.dieCount = 0
mt.mainStatsType = 0

mt.roundDmg = 0
mt.isFishing = false
mt.fishCount = 0

-- 经验值表
HERO_MAX_LV = 60

mt.expChart = {
    [1] = 0,
    [2] = 30,
    [3] = 80,
    [4] = 150,
    [5] = 240,
    [6] = 350,
    [7] = 480,
    [8] = 630,
    [9] = 800,
    [10] = 990,
    [11] = 1200,
    [12] = 1430,
    [13] = 1680,
    [14] = 1950,
    [15] = 2240,
    [16] = 2550,
    [17] = 2880,
    [18] = 3230,
    [19] = 3600,
    [20] = 3990,
    [21] = 4400,
    [22] = 4830,
    [23] = 5280,
    [24] = 5750,
    [25] = 6240,
    [26] = 6750,
    [27] = 7280,
    [28] = 7830,
    [29] = 8400,
    [30] = 8990,
}

-- if localEnv then
--     gdebug('hero exp chart:')
--     for i = 1, HERO_MAX_LV do
--         gdebug(str.format('lv: %d, exp: %.0f', i, mt.expChart[i]))
--     end
-- end

mt.expChart[HERO_MAX_LV + 1] = mt.expChart[HERO_MAX_LV]
--------------------------------------------------------------------------------------
function mt:onTestBorn()

    gdebug('%s 选择了 %s', self.player:getName(), self.name)
    -- self:morphHero('矢魂战灵', 1)

    -- self:modStats(ST_EXTRA_RANGE, 200)
    -- self:modStats(ST_RANGE_PCT, 0.1)

    -- self.player.blessManager:addRandomRootBlessPoint()
end
--------------------------------------------------------------------------------------
function mt:link(uId)

    -- init table
    local o = mt.parent:link(uId)
    setmetatable(o, self)

    o.hpBar:beforeDestroy()
    o.hpBar:destroy()

    local hpBar = class.heroHpBar.add_child(MAIN_UI, o)
    o.hpBar = hpBar
    hpBar:bind_unit_overhead(o)

    -- msg.notice(cst.ALL_PLAYERS, str.format('%s 招募了 |cffffcc00%s|r 。', p:getName(), o:getName()))

    -- 选择单位事件
    local eventPack = {
        name = 'on_pick_event',
        condition = UNIT_EVENT_ON_PICK,
        callback = mt.onMousePick,
    }
    o:addEvent(eventPack)

    return o
end
--------------------------------------------------------------------------------------
function mt:init(keys)

    self.player = keys.player
    self.skillBtn = {}
    self.eatItemList = {}

    self.blessOptionQueue = linked.create()
    self.visitorList = linked.create()
    self.reDrawBlessNum = 1
    self.blessClassProvideList = {}
    self.blessComboLv = {}

    local player = self.player

    player.shopAutoBuyer = self

    local hpBar = self.hpBar
    if self.hpBarOffsetX then
        hpBar:setHpbarOffseX(self.hpBarOffsetX)
    end
    if self.hpBarOffsetY then
        gdebug('hero has hp offset bar y: ' .. self.hpBarOffsetY)
        hpBar:setHpbarOffseY(self.hpBarOffsetY)
    end
    if self.hpBarOffsetX then
        hpBar:setHpbarOffseZ(self.hpBarOffsetZ)
    end

    --------------------------------------------------------------------------------------
    -- 信使
    if not player.maid then
        local maid = as.maid:create(player)
        player.maid = maid
        self.maid = maid
        maid.hero = self
    end

    -- UnitAddAbility(self.handle, ID('m003'))
    UnitAddAbility(self.handle, ID('m005')) -- 停止

    local pId = self:getPlayerId()
    local hId = 1
    local tId = SKILL_TARGET_NONE

    self:setStats(ST_BASE_RANGE, self.range)

    self:modStats(ST_BASE_HP_MAX, 1000)

    self:modStats(ST_PHY_CRIT_CHANCE, 0.05)
    self:modStats(ST_MAG_CRIT_CHANCE, 0.05)

    self:modStats(ST_PHY_CRIT_RATE, 0.5)
    self:modStats(ST_MAG_CRIT_RATE, 0.5)

    self:modStats(ST_BASE_ALL, 0)

    self:modStats(ST_BASE_ATK, 50)

    local baseGrow = 0
    local baseMainGrow = 0
    local statsType = self:getMainStatsType()
    local modType = ST_GROW_STR_PCT
    if statsType == ST_AGI then
        modType = ST_GROW_AGI_PCT
    elseif statsType == ST_INT then
        modType = ST_GROW_INT_PCT
    end
    self.mainStatsType = modType

    self:addEvent({
        name = 'event_on_launch_atk',
        condition = UNIT_EVENT_ON_LAUNCH_ATK,
        callback = mt.onLaunchAtk,
        self = self,
    })

    self:addEvent({
        name = 'event_on_atk',
        condition = UNIT_EVENT_ON_ATK,
        callback = mt.onAtk,
        self = self,
    })

    self:addEvent({
        name = 'event_on_cast',
        condition = UNIT_EVENT_ON_CAST_SPELL,
        callback = mt.onCast,
        self = self,
    })

    self:addEvent({
        name = 'event_on_deal_dmg',
        condition = UNIT_EVENT_ON_DEAL_DMG,
        callback = mt.heroRoundDmgCalc,
        self = self,
    })

    self:addEvent({
        name = 'event_on_every_sec',
        condition = UNIT_EVENT_ON_EVERY_SECOND,
        callback = mt.onEverySecond,
        self = self,
    })

    --------------------------------------------------------------------------------------
    -- 出生事件
    xpcall(function()
        if not player:isCheat() then
            player:triggerEvent(PLAYER_EVENT_HERO_BORN, {
                u = self,
                safeExecute = true,
            })
        else
            gdebug('检测到作弊；出生事件不生效')
        end

    end, function(msg)
        print(msg, debug.traceback())
    end)

    ac.loop(ms(1), function(t)
        if self.removed then
            t:remove()
            return
        end
        self:onTick()
    end)

    self.nearEnemyGroup = ac.selector():inRangeEnemy(self:getloc(), 1000, self):get()

    ac.loop(ms(0.33), function(t)
        if self.removed then
            t:remove()
            return
        end
    end)

    if localEnv then
        self:onTestBorn()
    end

    self:setMoveType(MOVE_TYPE_NORMAL)

end
--------------------------------------------------------------------------------------
function mt:onTick()

    if self:isDead() then
        return
    end

end
--------------------------------------------------------------------------------------
function mt:onLaunchAtk(keys)
    local tgt = keys.tgt
    local point = tgt:getloc()
    local aoe = 300 + self:getStats(ST_ATK_SPLASH_AOE)
    local dmg = keys.dmg
    local splashDmgPct = self:getStats(ST_ATK_SPLASH_DMG)
    if splashDmgPct <= 0 then
        return
    end
    dmg = dmg * splashDmgPct / 100
    for _, tgt in ac.selector():inRange(point, aoe):isEnemy(self):isNot(tgt):ipairs() do
        ApplyDamage({
            unit = self,
            tgt = tgt,
            dmg = dmg,
            dmgType = DMG_TYPE_PHYSICAL,
        })
    end
end
--------------------------------------------------------------------------------------
function mt:onAtk(keys)
    local val = self:getStats(ST_ATK_LIFE_STEAL)
    self:heal(self, val)
    self:triggerEvent(UNIT_EVENT_ON_ATK_REGEN, {
        amt = val,
    })

end
--------------------------------------------------------------------------------------
function mt:onCast(keys)
    local val = self:getStats(ST_CAST_HEAL)
    self:heal(self, val)

end
--------------------------------------------------------------------------------------
function mt:onEverySecond()
    local player = self.player
    -- local addGold = math.max(0, player:getStats(PST_SEC_GOLD) * (1 + player:getStats(PST_SEC_GOLD_PCT)))
    -- player:modStats(RES_GOLD, addGold)
end
--------------------------------------------------------------------------------------
function mt:onEveryHalfSec()
    -- gdebug('hero onevery sec')

    local base = getmetatable(mt)
    base.onEveryHalfSec(self)

end
--------------------------------------------------------------------------------------
function mt:addHeroSkill(skillName, slotId)
    if self.skillBtn[slotId] then
        warn('add hero skill fail to slotId: ' .. slotId)
        return
    end

    local skill = self:addSkill(skillName)

    local pId = self:getPlayerId()
    local hId = 1
    local tId = skill.targetType

    if tId == SKILL_TARGET_PASSIVE then
        tId = SKILL_TARGET_NONE
    end

    local skillBtn = cg.SkillBtn:newFlexBtn(self, (pId .. hId), (slotId .. tId), slotId)
    self.skillBtn[slotId] = skillBtn
    skillBtn:bindSkill(skill)
    skillBtn:updateInfo()

    return skill
end
--------------------------------------------------------------------------------------
function mt:removeHeroSkill(skillName, slotId)
    local skill = self:getSkill(skillName)
    if not skill then
        warn('remove hero skill fail: ' .. skillName)
        return
    end

    self:removeSkill(skillName)

    local skillBtn = skill.skillBtn
    self.skillBtn[slotId] = nil

    skillBtn:remove()

end

--------------------------------------------------------------------------------------
function mt:onMousePick(p, u, isPick)

    p.shopAutoBuyer = u

    if u.owner ~= p then
        return
    end

    if p:isLocal() then

    end

end
--------------------------------------------------------------------------------------
function mt:tpBack()

    -- if not self:isAlive() then
    --     return
    -- end

    -- if self.isFishing then
    --     return
    -- end

    -- local point = self.player.heroBornPoint

    -- fc.unitEffect({
    --     model = [[Abilities\Spells\Human\MassTeleport\MassTeleportTarget.mdl]],
    --     bind = [[origin]],
    -- }, self)

    -- self:move(point)
    -- self.player:moveCamera(point)

end
--------------------------------------------------------------------------------------
function mt:autoCast(tgt)

    if true then
        return
    end

    if not self.player.autoCast then
        return
    end

    -- if as.util:isInCd(self, 'fight_spell') then
    --     return
    -- end

    -- as.util:setInnerCd(self, 'fight_spell', 1)

    -- local skillBtnList = {}
    -- for slotId = 1, 4 do
    --     local skillBtn = self.skillBtn[slotId]
    --     local skill = skillBtn.skill
    --     -- gdebug('loop throught slotId: ' .. slotId .. skill.name)
    --     if skill.skillType ~= SKILL_TYPE_NO_FLAG and skill.targetType ~= SKILL_TARGET_PASSIVE and
    --         skillBtn:getCurrentCd() <= 0 then
    --         -- gdebug('is ready')
    --         skillBtnList[#skillBtnList + 1] = skillBtn
    --     end
    -- end

    -- fc.shuffleTable(skillBtnList)

    -- if not next(skillBtnList) then
    --     return
    -- end

    -- local skillBtn = skillBtnList[1]
    -- local skill = skillBtn.skill
    -- local order = skillBtn:getSlkData('DataF1')

    -- if not skill.customAI then
    --     if skill.targetType == 1 then
    --         self:issueUnitOrder(order, tgt)

    --     elseif skill.targetType == 2 then
    --         tgt = skill:searchTarget().tgt
    --         -- gdebug('对友军施放：' .. tgt:getName())
    --         -- print(tgt.handle)
    --         self:issueUnitOrder(order, tgt)
    --     elseif skill.targetType == 3 then
    --         self:issuePointOrder(order, tgt:getloc())

    --     elseif skill.targetType == 4 then
    --         self:issueImmediateOrder(order)
    --     end
    -- else
    --     skill.customAI(self, skill, order, tgt)
    -- end

end
--------------------------------------------------------------------------------------
function mt:getPrimary()
    return self:getSlkData('Primary')
end
--------------------------------------------------------------------------------------
function mt:mainStIs(stType)
    local primary = self:getSlkData('Primary')

    if stType == ST_STR then
        return primary == 'STR'
    elseif stType == ST_AGI then
        return primary == 'AGI'
    else
        return primary == 'INT'
    end

end
--------------------------------------------------------------------------------------
function mt:getMainStatsType()
    local primary = self:getSlkData('Primary')
    if primary == 'STR' then
        return ST_STR
    elseif primary == 'AGI' then
        return ST_AGI
    else
        return ST_INT
    end
end
--------------------------------------------------------------------------------------
function mt:createHero(p, uType, pt, face, hId)

    local x, y

    if not pt.type == 'point' then
        x = 0
        y = 0
    else
        x, y = ac.point.get(pt)
    end

    return mt:new(CreateUnit(p.handle, ID(uType), x, y, face), hId)
end
--------------------------------------------------------------------------------------
function mt:addGold(amt, showPoint, isFix)
    local player = self.player
    player:addGold(amt, showPoint, isFix)

end
--------------------------------------------------------------------------------------
function mt:addLumber(amt, showPoint, isFix)

    local player = self.player
    player:addLumber(amt, showPoint, isFix)
end
--------------------------------------------------------------------------------------
function mt:addKill(amt, showPoint, isFix)
    local player = self.player

    player:addKill(amt, showPoint, isFix)

end
--------------------------------------------------------------------------------------
function mt:addExp(amt, showPoint, isFix)

    local expRate = (1 + self:getStats(ST_EXP_RATE))
    if not isFix then
        amt = amt * expRate
    end

    self.exp = self.exp + amt

    self:checkLvUp()
    -- gdebug('hero add exp: ' .. amt)

    local keys = {}
    keys.amt = amt
    self:triggerEvent(UNIT_EVENT_ON_GET_EXP, keys)
end
--------------------------------------------------------------------------------------
function mt:checkLvUp()
    local maxLv = self:getMaxLv()
    if self.lv >= maxLv then
        return
    end
    if self.exp >= self.expChart[self.lv + 1] and self.lv < maxLv then
        self:updateLv()
    end
end
--------------------------------------------------------------------------------------
function mt:updateLv()
    local prevLv = self.lv
    local maxLv = self:getMaxLv()
    while self.lv + 1 <= maxLv and self.exp >= self.expChart[self.lv + 1] do
        self:levelUp()
        -- gdebug('---------------')
        -- gdebug('self lv: ' .. self.lv)
        -- gdebug('self exp: ' .. self.exp)
        -- gdebug('maxLv' .. maxLv)
    end

end
--------------------------------------------------------------------------------------
function mt:getMaxLv()
    return HERO_MAX_LV
end
--------------------------------------------------------------------------------------
function mt:levelUp()
    local oldLv = self.lv

    self.lv = self.lv + 1

    -- self:modStats(ST_BASE_STR, self:getStats(ST_GROW_STR) * (1 + self:getStats(ST_GROW_STR_PCT) / 100))
    -- self:modStats(ST_BASE_AGI, self:getStats(ST_GROW_AGI) * (1 + self:getStats(ST_GROW_AGI_PCT) / 100))
    -- self:modStats(ST_BASE_INT, self:getStats(ST_GROW_INT) * (1 + self:getStats(ST_GROW_INT_PCT) / 100))
    -- self:modStats(ST_BASE_HP_MAX, self:getStats(ST_GROW_HP_MAX) * (1 + self:getStats(ST_GROW_HP_MAX_PCT) / 100))
    -- self:modStats(ST_BASE_ATK, self:getStats(ST_GROW_ATK) * (1 + self:getStats(ST_GROW_ATK_PCT) / 100))

    self:triggerEvent(UNIT_EVENT_ON_LV_UP, {
        u = self,
        lv = self.lv,
    })

    GUI.multiUsePanel:updateLv(self.player, self.lv)

end
--------------------------------------------------------------------------------------
function mt:onKillEnemy(keys)

    if gm.state ~= GAME_STATE_NORMAL then
        return
    end

    local player = self.player

    -- 召唤物杀也触发
    -- self:modStats(ST_STR, self:getStats(ST_KILL_STR) * (1 + self:getStats(ST_KILL_STR_PCT) / 100))
    -- self:modStats(ST_AGI, self:getStats(ST_KILL_AGI) * (1 + self:getStats(ST_KILL_AGI_PCT) / 100))
    -- self:modStats(ST_INT, self:getStats(ST_KILL_INT) * (1 + self:getStats(ST_KILL_INT_PCT) / 100))
    -- self:modStats(ST_HP_MAX, self:getStats(ST_KILL_HP_MAX) * (1 + self:getStats(ST_KILL_HP_MAX_PCT) / 100))
    -- self:modStats(ST_ATK, self:getStats(ST_KILL_ATK) * (1 + self:getStats(ST_KILL_ATK_PCT) / 100))
    -- self:modStats(ST_PHY_DEF, self:getStats(ST_KILL_PHY_DEF))

    -- 加金币和经验在enemyManager
end
--------------------------------------------------------------------------------------
function mt:enterEndless()
    -- for i, entry in ipairs(self.endlessModList) do
    --     local stType = entry[1]
    --     local amt = entry[2]

    --     gdebug(str.format('mod stats: %s, val: %.0f', cst:getConstName(stType), amt))
    --     self:modStats(stType, amt)
    -- end
end

--------------------------------------------------------------------------------------
function mt:onDie(keys)

    -- gdebug('hero on die trig')
    self.parent.onDie(self, keys)

    self.chargeBeforeDead = self:getStats(ST_MP)
    local p = self.player

    local reviveTimePct = self:getStats(ST_REVIVE_TIME_PCT)

    if self:isDead() then

        local flowTextSize = 12

        if self.player:isLocal() then
            local point = self:getloc()
            GUI.ReviveTime:set_world_position(point[1], point[2], 100)
            GUI.ReviveTime:show()
        end
        -- local dieCountdownFlowText = as.flowText.makeClassicFlowText({
        --     text = str.format('|cfffce08510.0|r'),
        --     point = fc.polarPoint(self:getloc(), 120, 100),
        --     size = flowTextSize,
        --     speed = 0,
        --     angle = 0,
        --     fadeTime = -1,
        --     time = -1,
        -- })

        self.revivePoint = self:getloc()

        self.reviveEff = fc.pointEffect({
            model = [[az78.mdx]],
            size = 1.5,
            time = -1,
            mustShow = true,
        }, self.revivePoint)

        self.player.hasHeroDied = true
        self.reviveTime = 10 * (1 - math.min(reviveTimePct, 0.8))

        EnemyManager:onPlayerDieFollowOther(self.player)

        ac.loop(ms(0.1), function(t)
            self.reviveTime = self.reviveTime - 0.1
            if self.reviveTime <= 0 then
                fc.removeEffect(self.reviveEff)
                self:revive(self.revivePoint)
                msg.send(self.player, str.format('你的英雄已复活。', self.reviveTime))

                if self.player:isLocal() then
                    GUI.ReviveTime:unbind_world()
                    GUI.ReviveTime:hide()
                end

                -- DestroyTextTag(dieCountdownFlowText)

                t:remove()
            else
                if self.player:isLocal() then
                    GUI.ReviveTime:setTime(str.format('|cfffce085%.1f|r', self.reviveTime))
                end
            end
        end)

    end

    -- HandleRemoveTable(self.handle)
end
--------------------------------------------------------------------------------------
function mt:revive(point, eff)
    local player = self.player
    if not player:isAlive() then
        return
    end

    if gm.state == GAME_STATE_FINISH then
        return
    end

    local x, y = point:get()
    ReviveHero(self.handle, x, y, false)
    self.dead = false
    -- self:updateOrbs()
    local defaultTime = 3
    local time = defaultTime + (defaultTime * self:getStats(ST_REVIVE_IMMUNE_TIME_PCT) / 100)

    -- gdebug("apply revive immune buff")
    ApplyBuff({
        unit = self,
        tgt = self,
        buffName = cst.BUFF_IMMUNE,
        lv = 1,
        time = time,
    })

    self:triggerEvent(UNIT_EVENT_ON_REVIVE, {
        u = self,
    })

    self.player:forcePickUnit(self)

    ac.wait(ms(1), function()
        EnemyManager:onPlayerReviveEnemyFollow(self.player)
    end)

end

--------------------------------------------------------------------------------------
function mt.getNearEnemyHero(u, range)
    -- group action
    local point = u:getLoc()
    local g = {}
    for _, hero in ac.selector():inRange(point, range):isEnemy(u):isHero():ipairs() do

        table.insert(g, hero)
    end

    return g
end
--------------------------------------------------------------------------------------
function mt:getRandomCdSkill()
    return self.skillManager:getRandomCdSkill()
end
--------------------------------------------------------------------------------------
function mt:getCdSkills()
    return self.skillManager:getCdSkills()
end
--------------------------------------------------------------------------------------
function mt:getNameLv()
    return str.format('%s - [等级 %d]', self:getName(), self.lv)
end
--------------------------------------------------------------------------------------
function mt:modFp(amt)
    self.fp = self.fp + amt

    local p = self.owner

end
--------------------------------------------------------------------------------------
function mt:getArchLv()
    return self.archLv
end
--------------------------------------------------------------------------------------
function mt:updateArchLv()
    local archListName = self.archExpListName
    local archSlotId = self.archSlotId
    local p = self.owner
    if not archListName then
        return 0
    end

    self.archLv = archFunc.getHeroArchLv(p, archListName, archSlotId)
end
--------------------------------------------------------------------------------------
function mt:addArchExp(amt)
    local archListName = self.archExpListName
    local archSlotId = self.archSlotId
    local p = self.owner
    if archListName then
        archFunc.modHeroArchExp(p, archListName, archSlotId, amt)
        -- gdebug('英雄目前无archlistname和archslotId')
    else
        p:modArchVal(cst.CUSTOM_HERO_EXP, amt * 0.5)
    end

end
--------------------------------------------------------------------------------------
function mt:getArchLv()
    if self.cheatArchLv then
        return self.cheatArchLv
    end

    if self.owner.cheatHeroArchLv then
        return self.owner.cheatHeroArchLv
    end

    return self.archLv
end
--------------------------------------------------------------------------------------
function mt:reachArchExpPhase()
    local p = self.owner
    -- self.archExpListName = self.class.archExpListName
    -- self.archSlotId = self.class.archSlotId
    -- gdebug('upgrade to class that has archExp')
    -- self:updateArchLv()
    -- gdebug('current arch lv: ' .. self.archLv)

    -- local archLv = self:getArchLv()
    -- local amt = cst.HERO_ARCH_REWARD_RATE_1 * archLv
    -- local pct = cst.HERO_ARCH_REWARD_RATE_2 * archLv
    -- local pctStr = as.util:convertPct(pct)

    -- if archLv > 0 then
    --     self:modStats(cst.ST_MAIN, amt)

    --     self:modStats(cst.ST_GROW_STR_PCT, pct)
    --     self:modStats(cst.ST_GROW_AGI_PCT, pct)
    --     self:modStats(cst.ST_GROW_INT_PCT, pct)

    --     msg.reward(p, str.format(
    --         '[|cff00ff88%s|r]获得了熟练度等级提供的[|cffffff00%d|r]点主属性和[|cffffff00%s|r]全属性成长！',
    --         self:getName(), amt, pctStr))
    -- end

end

--------------------------------------------------------------------------------------
function mt:addBlessPoint()
    self.player.blessManager:addBlessPoint()
end
--------------------------------------------------------------------------------------
function mt:pickBless(btnId)
    local player = self.player
    if not player.blessOptions then
        return
    end

    fc.setInnerCd(player, '赐福刷新cd', 1)

    self.pickingMemory = false

    self.pickedNewBlessOnce = true

    local blessOption = player.blessOptions[btnId]
    local bless = blessOption.bless

    if not bless then
        return
    end

    local getLv = blessOption.getLv

    for i = 1, getLv do
        local blessSkill = self:addBless(bless.name)

        if blessSkill.lv == 1 then
            msg.notice(player, str.format('你获得了赐福 |cffffff00%s|r ！', bless.name))
        else
            msg.notice(player, str.format('赐福 |cffffff00%s|r 的等级提升至 |cff00ffbf%d|r 级！', bless.name,
                blessSkill.lv))
        end
    end

    gdebug('玩家[%s]获得了赐福：%s', player:getName(), bless.name)

    fc.unitEffect({
        model = [[MS_R2_az.MDX]],
    }, self)

    sound.playToPlayer(glo.gg_snd_pick_bless, player, 1, 0, true)

    if player.currentTutorial == 2 then
        if self.player:isLocal() then
            GUI.Tutorial:showTutorial(self.player.currentTutorial)
        end
    end

    local showAnim = function()
        local movingIcon = class.pick_bless_moving_btn.create()
        local optionBtn = GUI.PickBlessPanel.optionBtn[btnId]
        local art = cst:getConstTag(bless.blessClassProvide[1], 'tempArt')
        movingIcon:onStartMove(str.format('BlessArt\\%s.tga', art), optionBtn)
        if player:isLocal() then
            movingIcon:show()
        else
            movingIcon:hide()
        end
    end

    showAnim()
    if getLv > 1 then
        ac.timer(ms(0.1), getLv - 1, function()
            showAnim()
        end)
    end

    player.blessManager:onHeroGetBless(bless.name)

    player.blessOptions = nil
    player.pickedOnceBless = true
end
--------------------------------------------------------------------------------------
function mt:drawBless(keys)
    local player = self.player

    self.player.blessManager:drawBless(keys)

end
--------------------------------------------------------------------------------------
function mt:getBlessLv(blessName)
    local bless = self:getSkill(blessName)
    return bless and bless.lv or 0
end
--------------------------------------------------------------------------------------
function mt:heroRoundDmgCalc(keys)
    local player = self.player
    local dmg = keys.dmg
    self.roundDmg = self.roundDmg + dmg
    self.player.totalGameDmg = self.player.totalGameDmg + dmg
end
--------------------------------------------------------------------------------------
function mt:clearRoundDmg()
    self.roundDmg = 0
end
--------------------------------------------------------------------------------------
function mt:getRoundDmg()
    return self.roundDmg
end
--------------------------------------------------------------------------------------
-- override, assync
function mt:mouseInTool(btnId)
    local player = self.player
    local skillBtn = self.skillBtn[btnId]
    local art, title, tip, resourceIcon1, resourceTip1, resourceIcon2, resourceTip2, cdText, mpText, titleHint
    local skill

    gdebug('hero mouseInTool: %d', btnId)

    if btnId == 1 then
        title = '攻击(|cffffcc00A|r)'
        tip = [[向目标敌人或是地点发动攻击]]
        art = [[ReplaceableTextures\CommandButtons\BTNgongji.blp]]
    elseif btnId == 2 then
        title = '停止(|cffffcc00S|r)'
        tip = [[停止攻击指令]]
        art = [[ReplaceableTextures\CommandButtons\BTNfangyu.blp]]

    elseif btnId == 3 then
        title = '合成物品(|cffffcc00E|r)'
        tip = [[将2个同品质的装备合成成为更高品质的装备]]
        art = [[ReplaceableTextures\CommandButtons\BTNMagicImmunity.blp]]

    elseif btnId == 6 or btnId == 7 then
        local skillId = btnId
        local skillBtn = self.skillBtn[skillId]
        skill = skillBtn.skill
        art = skill.art
        title = skill:getTitle()
        tip = skill:getTip()

        if skill.getExtraSkillTip then
            xpcall(function()
                tip = tip .. '|n|n' .. skill:getExtraSkillTip()
            end, traceError)
        end
    elseif (btnId >= 9 and btnId <= 12) then
        local skillId = btnId - 8
        local skillBtn = self.skillBtn[skillId]
        skill = skillBtn.skill
        art = skill.art
        title = skill:getTitle()
        tip = skill:getTip()

        if skill.getExtraSkillTip then
            xpcall(function()
                tip = tip .. '|n|n' .. skill:getExtraSkillTip()
            end, traceError)
        end
    end

    skillTipbox:makeTip({
        icon = art,
        title = title,
        tip = tip,
        resourceIcon1 = resourceIcon1,
        resourceTip1 = resourceTip1,
        resourceIcon2 = resourceIcon2,
        resourceTip2 = resourceTip2,
        cdText = cdText,
        mpText = mpText,
        titleHint = titleHint,
    })

    toolbox:hideOriginTooltip()
end

--------------------------------------------------------------------------------------
return mt
