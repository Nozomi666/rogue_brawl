

local name = '招财娃娃'

local mt = {
    -- 名称
    name = name,
    type = [[maidSkin]],
    archId = TEMP_ID,

    -- 图标
    art = [[ArchArt\accsArt\助手\9zhaocaiwawa.blp]],
    artDark = [[ArchArt\accsArt\助手\dark\9zhaocaiwawa.blp]],

    -- 说明
    title = name,
    unlockTip = [[]],
    relatedArchName = [[海盗宝藏]],
    tip = [[通过海盗宝藏-购买商城道具海盗宝藏获得]],

    -- 模型
    model = [[JD-YNE.mdx]],
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
