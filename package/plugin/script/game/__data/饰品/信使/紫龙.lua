

local name = '紫龙'

local mt = {
    -- 名称
    name = name,
    type = [[maidSkin]],
    archId = TEMP_ID,

    -- 图标
    art = [[ArchArt\accsArt\助手\28zilong.blp]],
    artDark = [[ArchArt\accsArt\助手\dark\28zilong.blp]],

    -- 说明
    title = name,
    unlockTip = [[]],
    relatedArchName = [[主播抽奖礼包]],
    tip = [[通过主播抽奖礼包获得]],

    -- 模型
    model = [[ml.mdx]],
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
