

local name = '魔龙'

local mt = {
    -- 名称
    name = name,
    type = [[maidSkin]],
    archId = TEMP_ID,

    -- 图标
    art = [[ArchArt\accsArt\助手\32molong.tga]],
    artDark = [[ArchArt\accsArt\助手\dark\32molong.tga]],

    -- 说明
    title = name,
    unlockTip = [[]],
    relatedArchName = [[沼泽高阶第20级]],
    tip = [[通过沼泽高阶第20级-达成高阶沼泽通行证第二十级获得]],

    -- 模型
    model = [[deathguai1.mdx]],
    uiSize = 1,

}
--------------------------------------------------------------------------------------
TEMP_ID = TEMP_ID + 1
reg:addToPool('accs', mt)
reg:addToPool('maidSkin', mt)
reg:initTableData('accsTable', mt)
--------------------------------------------------------------------------------------

return mt
