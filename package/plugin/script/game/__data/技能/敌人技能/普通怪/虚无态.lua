local skillName = '虚无态'

local mt = {
    -- 名称
    name = skillName,

    -- 技能图标
    art = [[ReplaceableTextures\CommandButtons\BTNDevourMagic.blp]],

    -- 技能说明
    title = skillName,
    tip = [[具有20%闪避]],

    -- 技能类型
    skillType = SKILL_TYPE_ENEMY,

    -- 施放类型
    targetType = SKILL_TARGET_PASSIVE,

    -- 数据
    evade = 0.2,
}
mt.__index = mt
local skill = mt
--------------------------------------------------------------------------------------
function mt:onSwitch(isAdd)
    local unit = self.unit
    if isAdd then
        unit:modStats(ST_EVADE, self.evade)
    end
end
--------------------------------------------------------------------------------------
reg:initSkill(mt)
