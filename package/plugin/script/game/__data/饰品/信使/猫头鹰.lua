

local name = '猫头鹰'

local mt = {
    -- 名称
    name = name,
    type = [[maidSkin]],
    archId = TEMP_ID,

    -- 图标
    art = [[ArchArt\accsArt\助手\4maotouying.blp]],
    artDark = [[ArchArt\accsArt\助手\dark\4maotouying.blp]],

    -- 说明
    title = name,
    unlockTip = [[]],
    relatedArchName = [[传承弓箭]],
    tip = [[通过传承弓箭-购买商城道具传承弓箭获得]],

    -- 模型
    model = [[3333.mdx]],
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
