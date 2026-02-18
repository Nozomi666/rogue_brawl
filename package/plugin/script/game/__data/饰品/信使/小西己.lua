

local name = '小西己'

local mt = {
    -- 名称
    name = name,
    type = [[maidSkin]],
    archId = TEMP_ID,

    -- 图标
    art = [[ArchArt\accsArt\助手\7xiaoxiji.blp]],
    artDark = [[ArchArt\accsArt\助手\dark\7xiaoxiji.blp]],

    -- 说明
    title = name,
    unlockTip = [[]],
    relatedArchName = [[星数奖励1-6]],
    tip = [[通过星数奖励1-6-在第一章集齐六颗星星获得]],

    -- 模型
    model = [[1 (66).mdx]],
    -- replaceUnitType = [[e002]],
    uiSize = 0.4,

}
--------------------------------------------------------------------------------------
TEMP_ID = TEMP_ID + 1
reg:addToPool('accs', mt)
reg:addToPool('maidSkin', mt)
reg:initTableData('accsTable', mt)
--------------------------------------------------------------------------------------

return mt
