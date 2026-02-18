

local name = '小雪狐'

local mt = {
    -- 名称
    name = name,
    type = [[maidSkin]],
    archId = TEMP_ID,

    -- 图标
    art = [[ArchArt\accsArt\助手\huli.tga]],
    artDark = [[ArchArt\accsArt\助手\dark\huli2.tga]],

    -- 说明
    title = name,
    unlockTip = [[]],
    relatedArchName = [[小雪狐]],
    tip = [[通过地图福利获得]],

    -- 模型
    model = [[CS_XUEHU.mdx]],
    -- replaceUnitType = [[e002]],
    modelSize = 1,
    uiSize = 0.4,

}
--------------------------------------------------------------------------------------
TEMP_ID = TEMP_ID + 1
reg:addToPool('accs', mt)
reg:addToPool('maidSkin', mt)
reg:initTableData('accsTable', mt)
--------------------------------------------------------------------------------------

return mt
