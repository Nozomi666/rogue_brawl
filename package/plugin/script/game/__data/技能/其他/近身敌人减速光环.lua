local skillName = '近身敌人减速光环'

local skill = {
    -- 名称
    name = skillName,

    -- 技能图标
    art = [[moyingguanghuan]],

    -- 技能说明
    title = skillName,
    tip = [[降低周围<NUM>[aoe]<R>范围内的敌人<NUM>%[rate1]%<R>移速。]],


    -- 最大等级
    maxLv = 5,

    -- 技能类型
    skillType = SKILL_TYPE_NO_FLAG,

    -- 施放类型
    targetType = SKILL_TARGET_PASSIVE,

    -- 数据
    aoe = 600,
    rate1 = 0.5,

}
local mt = skill
mt.__index = mt
--------------------------------------------------------------------------------------
function mt:onSwitch(isAdd)
    local unit = self.unit

    if isAdd then
        unit:addAura({
            name = skillName,
            lv = self.lv,
            aoe = self.aoe,
            toAlly = false,
            toEnemy = true,
            effKeys = nil,
            filter = nil,
        })
    else
        unit:removeAura(skillName)
    end

end
--------------------------------------------------------------------------------------
reg:initSkill(mt)
--------------------------------------------------------------------------------------
-- buff
--------------------------------------------------------------------------------------
local buffName = skillName

local buff = {
    name = buffName,

    effect = {},
    multiple = false,

}

local mt = buff
mt.__index = mt
--------------------------------------------------------------------------------------
function mt:onSwitch(isAdd)

    local u = self.owner
    local from = self.from
    local lv = self.lv
    local stack = 0

    local rate1 = skill:getData('rate1') * lv * -1
    if isAdd then
    else
        rate1 = rate1 * -1
    end

    u:modStats(ST_MOVE_SPEED_PCT, rate1)

end
--------------------------------------------------------------------------------------
reg:initBuff(buff)
