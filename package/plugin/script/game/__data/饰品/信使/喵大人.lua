

local name = '喵大人'

local mt = {
    -- 名称
    name = name,
    type = [[maidSkin]],
    archId = TEMP_ID,

    -- 图标
    art = [[ArchArt\accsArt\助手\24BUGlibao.blp]],
    artDark = [[ArchArt\accsArt\助手\dark\24BUGlibao.blp]],

    -- 说明
    title = name,
    unlockTip = [[]],
    relatedArchName = [[反馈BUG礼包]],
    tip = [[通过反馈BUG礼包-在官方群内提交有效bug获得]],

    -- 模型
    model = [[1087.mdx]],
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
