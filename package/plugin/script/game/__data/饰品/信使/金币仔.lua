

local name = '金币仔'

local mt = {
    -- 名称
    name = name,
    type = [[maidSkin]],
    archId = TEMP_ID,

    -- 图标
    art = [[ArchArt\accsArt\助手\20jinbizai.blp]],
    artDark = [[ArchArt\accsArt\助手\dark\20jinbizai.blp]],

    -- 说明
    title = name,
    unlockTip = [[]],
    relatedArchName = [[第2章无尽50波]],
    tip = [[通过第2章无尽50波]],

    -- 模型
    model = [[jbzai.mdx]],
    -- replaceUnitType = [[e002]],
    uiSize = 0.4,

}
if localEnv then
    mt.relatedArchName = [[预约人数1000]]
end
--------------------------------------------------------------------------------------
TEMP_ID = TEMP_ID + 1
reg:addToPool('accs', mt)
reg:addToPool('maidSkin', mt)
reg:initTableData('accsTable', mt)
--------------------------------------------------------------------------------------

return mt
