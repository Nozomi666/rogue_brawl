

local name = '飞天猫'

local mt = {
    -- 名称
    name = name,
    type = [[maidSkin]],
    archId = TEMP_ID,

    -- 图标
    art = [[ArchArt\accsArt\助手\3feitianmao.blp]],
    artDark = [[ArchArt\accsArt\助手\dark\3feitianmao.blp]],

    -- 说明
    title = name,
    unlockTip = [[]],
    relatedArchName = [[收割之镰]],
    tip = [[通过收割之镰-购买商城道具收割之镰获得]],

    -- 模型
    model = [[3 (147).mdx]],
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
