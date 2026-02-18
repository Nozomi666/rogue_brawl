

local name = '小枪神'

local mt = {
    -- 名称
    name = name,
    type = [[maidSkin]],
    archId = TEMP_ID,

    -- 图标
    art = [[ArchArt\accsArt\助手\6xiaoqiangshen.blp]],
    artDark = [[ArchArt\accsArt\助手\dark\6xiaoqiangshen.blp]],

    -- 说明
    title = name,
    unlockTip = [[]],
    relatedArchName = [[鬼灭魔刃]],
    tip = [[通过鬼灭魔刃-购买商城道具鬼灭魔刃获得]],

    -- 模型
    model = [[azusa.mdx]],
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
