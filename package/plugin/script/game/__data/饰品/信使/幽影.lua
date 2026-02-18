

local name = '幽影'

local mt = {
    -- 名称
    name = name,
    type = [[maidSkin]],
    archId = TEMP_ID,

    -- 图标
    art = [[ArchArt\accsArt\助手\18youying.blp]],
    artDark = [[ArchArt\accsArt\助手\dark\18youying.blp]],

    -- 说明
    title = name,
    unlockTip = [[]],
    relatedArchName = [[签到14日]],
    tip = [[通过签到14日-完成第十四天的签到获得]],

    -- 模型
    model = [[1090.mdx]],
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
