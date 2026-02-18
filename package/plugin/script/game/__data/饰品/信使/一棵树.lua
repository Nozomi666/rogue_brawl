

local name = '一棵树'

local mt = {
    -- 名称
    name = name,
    type = [[maidSkin]],
    archId = TEMP_ID,

    -- 图标
    art = [[ArchArt\accsArt\助手\16yikeshu.blp]],
    artDark = [[ArchArt\accsArt\助手\dark\16yikeshu.blp]],

    -- 说明
    title = name,
    unlockTip = [[]],
    relatedArchName = [[地图奖励21]],
    tip = [[通过地图奖励21-地图等级达到45级获得]],

    -- 模型
    model = [[Tree_Pine.mdx]],
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
