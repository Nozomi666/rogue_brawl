

local name = '二小姐'

local mt = {
    -- 名称
    name = name,
    type = [[maidSkin]],
    archId = TEMP_ID,

    -- 图标
    art = [[ArchArt\accsArt\助手\27erxiaojie.blp]],
    artDark = [[ArchArt\accsArt\助手\dark\27erxiaojie.blp]],


    -- 说明
    title = name,
    unlockTip = [[]],
    relatedArchName = [[内测贡献]],
    tip = [[通过内测贡献-在内测期间做出巨大贡献获得]],

    -- 模型
    model = [[665.mdx]],
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
