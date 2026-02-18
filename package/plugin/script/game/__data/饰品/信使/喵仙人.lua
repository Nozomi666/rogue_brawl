

local name = '喵仙人'

local mt = {
    -- 名称
    name = name,
    type = [[maidSkin]],
    archId = TEMP_ID,

    -- 图标
    art = [[ArchArt\accsArt\助手\miaoxianren.blp]],
    artDark = [[ArchArt\accsArt\助手\dark\miaoxianren.blp]],

    -- 说明
    title = name,
    unlockTip = [[]],
    relatedArchName = [[老图玩家福利]],
    tip = [[通过老图玩家福利获得]],

    -- 模型
    model = [[460.mdx]],
    -- replaceUnitType = [[e002]],
    uiSize = 1.4,

}
--------------------------------------------------------------------------------------
TEMP_ID = TEMP_ID + 1
reg:addToPool('accs', mt)
reg:addToPool('maidSkin', mt)
reg:initTableData('accsTable', mt)
--------------------------------------------------------------------------------------

return mt
