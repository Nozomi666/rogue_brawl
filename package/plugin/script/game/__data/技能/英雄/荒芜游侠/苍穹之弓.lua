local skillName = '苍穹之弓'

local skill = {
    -- 名称
    name = skillName,

    -- 技能图标
    art = TEMPLATE_BTN_PATH,

    -- 技能说明
    title = skillName,
    tip = [[攻击时有<NUM>%[chance]%<R>概率召唤一枚来自苍穹的箭矢，对目标<NUM>[aoe]<R>范围内敌人造成攻击力×<NUM>[atk]<R>的物理伤害；触发箭术赐福时有<NUM>%[arrowChance]%<R>概率触发苍穹之弓，且此次天赋伤害无视目标<NUM>%[def]%<R>护甲（内置冷却<NUM>[cd]<R>秒）]],

    -- 技能类型
    skillType = SKILL_TYPE_HERO_TALENT,

    -- 施放类型
    targetType = SKILL_TARGET_PASSIVE,

    -- 稀有度
    rare = DEFAULT_RARE,

    -- 数据
    chance = 0.07,
    aoe = 200,
    atk = 4,
    arrowChance = 0.14,
    def = 0.4,
    cd = 0.5,

}
local mt = skill
mt.__index = mt
--------------------------------------------------------------------------------------
function mt:onSwitch(isAdd)
    local unit = self.unit
    local eventPack = {
        name = skillName,
        condition = UNIT_EVENT_ON_ATK,
        callback = mt.onAtk,
        self = self,
    }
    local eventPack1 = {
        name = skillName,
        condition = UNIT_EVENT_ON_TRIGGER_BLESS,
        callback = mt.onTriggerBless,
        self = self,
    }
    if isAdd then
        unit:addEvent(eventPack)
        unit:addEvent(eventPack1)
    else
        unit:removeEvent(eventPack)
        unit:removeEvent(eventPack1)
    end
end
--------------------------------------------------------------------------------------
function mt:onAtk(keys)
    local unit = self.unit
    local tgt = keys.tgt
    local chance = self:getData('chance')
    local atk = self:getData('atk')
    local aoe = self:getData('aoe')
    local dmg = unit:getStats(ST_ATK) * atk
    if unit:passQuickRandomPassiveTest(chance, self) then
        fc.pointEffect({
            model = [[Units\NightElf\Owl\Owl.mdl]],
            bind = [[origin]],
            time = 1,
        }, tgt:getloc())
        for _, target in ac.selector():inRangeEnemy(tgt:getloc(), aoe, unit):ipairs() do
            local keys = {
                unit = unit,
                tgt = tgt,
                dmg = dmg,
                dmgType = DMG_TYPE_PHYSICAL,
            }
            ApplyDamage(keys)
        end
    end
end
--------------------------------------------------------------------------------------
function mt:onTriggerBless(keys)
    local unit = self.unit
    if fc.isInCd(unit, self) then
        return
    end
    local tgt = fc.rngSelect(unit.nearEnemyGroup)
    if not tgt then
        return
    end
    local chance = self:getData('arrowChance')
    local atk = self:getData('atk')
    local aoe = self:getData('aoe')
    local dmg = unit:getStats(ST_ATK) * atk
    if unit:passQuickRandomPassiveTest(chance, self) then
        fc.setInnerCd(unit, self, self.cd)
        fc.pointEffect({
            model = [[Units\NightElf\Owl\Owl.mdl]],
            bind = [[origin]],
            time = 1,
        }, tgt:getloc())
        for _, target in ac.selector():inRangeEnemy(tgt:getloc(), aoe, unit):ipairs() do
            local keys = {
                unit = unit,
                tgt = tgt,
                dmg = dmg,
                dmgType = DMG_TYPE_PHYSICAL,
                defPenerate = self.def,
            }
            ApplyDamage(keys)
        end
    end
end
--------------------------------------------------------------------------------------
reg:initSkill(mt)
