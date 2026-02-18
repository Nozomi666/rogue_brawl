

local name = '电飞鼠'

local mt = {
    -- 名称
    name = name,
    type = [[maidSkin]],
    archId = TEMP_ID,

    -- 图标
    art = [[ArchArt\accsArt\助手\2dianfeishu.blp]],
    artDark = [[ArchArt\accsArt\助手\dark\2dianfeishu.blp]],

    -- 说明
    title = name,
    unlockTip = [[]],
    relatedArchName = [[加群礼包]],
    tip = [[通过加群礼包-加入任意官方群获得]],

    -- 模型
    model = [[season ecmsad.mdx]],
    modelSize = 2.5,
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
