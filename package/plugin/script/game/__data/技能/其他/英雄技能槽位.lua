for i = 1, 8 do
local skillName = '英雄技能槽位' .. i

local mt = {
    -- 名称
    name = skillName,

    -- 技能图标
    art = [[ReplaceableTextures\CommandButtonsDisabled\DISBTNCancel.blp]],

    -- 技能说明
    title = skillName,
    tip = [[每次英雄转职后可以获得一个新的英雄技能]],

    -- 技能类型
    skillType = SKILL_TYPE_NO_FLAG,

    -- 施放类型
    targetType = SKILL_TARGET_PASSIVE,
    showHotKey = false,

    -- 数据
    cd = 99,

    -- presentSide = {{
    --     type = 'cd',
    --     name = '冷却时间：',
    -- }, {
    --     type = 'maxRange',
    --     name = '最大距离：',
    -- }},

}
mt.__index = mt
--------------------------------------------------------------------------------------
reg:initSkill(mt)

end