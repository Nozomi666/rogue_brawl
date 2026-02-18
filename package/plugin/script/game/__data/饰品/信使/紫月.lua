

local name = '紫月'

local mt = {
    -- 名称
    name = name,
    type = [[maidSkin]],
    archId = TEMP_ID,

    -- 图标
    art = [[ArchArt\accsArt\助手\10ziyue.blp]],
    artDark = [[ArchArt\accsArt\助手\dark\10ziyue.blp]],

    -- 说明
    title = name,
    unlockTip = [[]],
    relatedArchName = [[萌宠紫月]],
    tip = [[通过萌宠紫月-购买商城道具萌宠紫月获得]],

    -- 模型
    model = [[cw.mdx]],
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
