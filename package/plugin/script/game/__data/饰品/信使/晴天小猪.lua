

local name = '晴天小猪'

local mt = {
    -- 名称
    name = name,
    type = [[maidSkin]],
    archId = TEMP_ID,

    -- 图标
    art = [[ArchArt\accsArt\助手\13qingtianxiaozhu.blp]],
    artDark = [[ArchArt\accsArt\助手\dark\13qingtianxiaozhu.blp]],

    -- 说明
    title = name,
    unlockTip = [[]],
    relatedArchName = [[地图奖励5]],
    tip = [[通过地图奖励5-地图等级达到2级获得]],

    -- 模型
    model = [[JD-2020-FEIZHU.mdx]],
    modelSize = 2,
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
