

local name = '娜娜'

local mt = {
    -- 名称
    name = name,
    type = [[maidSkin]],
    archId = TEMP_ID,

    -- 图标
    art = [[ReplaceableTextures\CommandButtons\BTNxinshinana.blp]],
    artDark = [[nana]],

    -- 说明
    title = name,
    unlockTip = [[英雄破阵时施放一次烟花庆祝，并有几率增加10木材。]],

    -- 模型
    model = [[units\human\Sorceress\Sorceress.mdx]],
    uiSize = 0.25,


}
--------------------------------------------------------------------------------------
TEMP_ID = TEMP_ID + 1
reg:addToPool('accs', mt)
-- reg:addToPool('maidSkin', mt)
reg:initTableData('accsTable', mt)
--------------------------------------------------------------------------------------

return mt
