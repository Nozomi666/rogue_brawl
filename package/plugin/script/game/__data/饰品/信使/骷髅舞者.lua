

local name = '骷髅舞者'

local mt = {
    -- 名称
    name = name,
    type = [[maidSkin]],
    archId = TEMP_ID,

    -- 图标
    art = [[ArchArt\accsArt\助手\17kulouwuzhe.blp]],
    artDark = [[ArchArt\accsArt\助手\dark\17kulouwuzhe.blp]],

    -- 说明
    title = name,
    unlockTip = [[]],
    relatedArchName = [[签到1日]],
    tip = [[通过签到1日-完成第一天的签到获得]],

    -- 模型
    model = [[124.mdx]],
    modelSize = 2,
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
