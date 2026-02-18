local skillName = '天生箭心'

local skill = {
    -- 名称
    name = skillName,

    -- 技能图标
    art = TEMPLATE_BTN_PATH,

    -- 技能说明
    title = skillName,
    tip = [[普通攻击有<NUM>%[chance]%<R>几率射出穿透箭，对直线上的敌人造成攻击力×<NUM>[rate1]<R>的物理伤害；触发箭术赐福后的下一次穿透箭伤害+<NUM>%@[raise]@%<R>]],

    -- 技能类型
    skillType = SKILL_TYPE_HERO_TALENT,

    -- 施放类型
    targetType = SKILL_TARGET_PASSIVE,

    -- 稀有度
    rare = DEFAULT_RARE,

    -- 数据
    chance = 0.15,
    atk = 3,

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
function mt:raise()
    local unit = self.unit
    return 0.3 + unit:getBlessClassLv(BLESS_CLASS_ARROW) * 0.05
end
--------------------------------------------------------------------------------------
function mt:onAtk(keys)
    local unit = self.unit
    local tgt = keys.tgt
    local chance = self:getData('chance')
    local atk = self:getData('atk')
    local dmg = unit:getStats(ST_ATK) * atk
    if unit:passQuickRandomPassiveTest(chance, self) then
        if self.buffed then
            dmg = dmg * (1 + self:raise())
            self.buffed = false
            gdebug('天生箭心触发，伤害加成：' .. self:raise())
        else
            gdebug('天生箭心触发，未加成')
        end
        if tgt and tgt:isAlive() then
            Arrow:new({
                unit = unit,
                model = [[Abilities\Weapons\Arrow\ArrowMissile.mdl]],
                size = 1.5,
                point = unit:getloc(),
                face = unit:getloc() / tgt:getloc(),
                onHit = self.onHit,
                skill = self,
                dmg = dmg,
                skillKeys = keys,
                isAtk = false,
            })
        end
    end
end
--------------------------------------------------------------------------------------
function mt:onHit(bullet)
    local unit = self.unit
    local tgt = bullet.tgt
    local dmg = bullet.dmg
    local isAtk = bullet.isAtk
    ApplyDamage({
        unit = unit,
        tgt = tgt,
        dmg = dmg,
        dmgType = DMG_TYPE_PHYSICAL,
        isAtk = isAtk,
        critChance = bullet.critChance,
        critRate = bullet.critRate,
    })

    fc.unitEffect(sef.PSIONIC_SHOT_ORANGE, tgt)

end
--------------------------------------------------------------------------------------
function mt:onTriggerBless(keys)
    local unit = self.unit
    local tgt = keys.tgt
    if keys.blessClass ~= BLESS_CLASS_ARROW then
        return
    end
    self.buffed = true
end
--------------------------------------------------------------------------------------
reg:initSkill(mt)
