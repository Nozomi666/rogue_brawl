local skillName = '月之攻击'

local skill = {
    -- 名称
    name = skillName,

    -- 技能图标
    art = TEMPLATE_BTN_PATH,

    -- 技能说明
    title = skillName,
    tip = [[攻击有<NUM>%[chance]%<R>几率召唤月光，对目标施加攻击力×<NUM>[rate1]<R>的魔法伤害]],

    -- 技能类型
    skillType = SKILL_TYPE_HERO_TALENT,

    -- 施放类型
    targetType = SKILL_TARGET_PASSIVE,

    -- 稀有度
    rare = DEFAULT_RARE,

    -- 数据
    chance = 0.12,
    rate1 = 5,

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

    if isAdd then
        unit:addEvent(eventPack)
    else
        unit:removeEvent(eventPack)
    end
end
--------------------------------------------------------------------------------------
function mt:onAtk(keys)
    local unit = self.unit
    local tgt = keys.tgt
    local chance = self:getData('chance')
    local rate1 = self:getData('rate1')
    local dmg = unit:getStats(ST_ATK) * rate1

    -- gdebug('moon chance: ' .. chance .. ', rate1: ' .. rate1)

    if unit:passQuickRandomPassiveTest(chance, self) then
        fc.pointEffect({
            model = [[Units\NightElf\Owl\Owl.mdl]],
            bind = [[origin]],
            time = 0.4,
        }, tgt:getloc())

        ApplyDamage({
            unit = unit,
            tgt = tgt,
            dmg = dmg,
            isAtk = false,
            dmgType = DMG_TYPE_MAGICAL,
        })
    end

end
--------------------------------------------------------------------------------------
reg:initSkill(mt)
