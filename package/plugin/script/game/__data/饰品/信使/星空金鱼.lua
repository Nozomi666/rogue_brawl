

local name = '星空金鱼'

local mt = {
    -- 名称
    name = name,
    type = [[maidSkin]],
    archId = TEMP_ID,

    -- 图标
    art = [[ArchArt\accsArt\助手\31xingkongjinyu.blp]],
    artDark = [[ArchArt\accsArt\助手\dark\31xingkongjinyu.blp]],

    -- 说明
    title = name,
    unlockTip = [[]],
    relatedArchName = [[星空金鱼]],
    tip = [[通过星空金鱼-钓鱼积分完成星空金鱼成就获得]],

    -- 模型
    model = [[liyu.mdx]],
    uiSize = 1,

}
--------------------------------------------------------------------------------------
TEMP_ID = TEMP_ID + 1
reg:addToPool('accs', mt)
reg:addToPool('maidSkin', mt)
reg:initTableData('accsTable', mt)
--------------------------------------------------------------------------------------

return mt
