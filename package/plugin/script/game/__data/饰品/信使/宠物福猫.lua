

local name = '宠物福猫'

local mt = {
    -- 名称
    name = name,
    type = [[maidSkin]],
    archId = TEMP_ID,

    -- 图标
    art = [[ArchArt\accsArt\助手\1chongwufumao.blp]],
    artDark = [[ArchArt\accsArt\助手\dark\1chongwufumao.blp]],

    -- 说明
    title = name,
    unlockTip = [[]],
    relatedArchName = [[黄金圣杯]],
    tip = [[通过黄金圣杯-购买商城道具黄金圣杯获得]],

    -- 模型
    model = [[3 (278).mdx]],
    modelSize = 1.5,
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
