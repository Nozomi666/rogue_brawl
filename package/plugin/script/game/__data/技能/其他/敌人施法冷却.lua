local skillName = '敌人施法冷却'

local mt = {
    -- 名称
    name = skillName,

    -- 技能图标
    art = [[ReplaceableTextures\CommandButtons\BTNInvisibility.blp]],

    -- 技能说明
    title = skillName,
    tip = [[马甲技能。]],

    -- 技能类型
    skillType = SKILL_TYPE_NO_FLAG,

    -- 施放类型
    targetType = SKILL_TARGET_NONE,
    showHotKey = true,

    -- 数据
    cd = 99,

    presentSide = {{
        type = 'cd',
        name = '冷却时间：',
    }, {
        type = 'maxRange',
        name = '最大距离：',
    }},

}
mt.__index = mt
--------------------------------------------------------------------------------------
reg:initSkill(mt)
