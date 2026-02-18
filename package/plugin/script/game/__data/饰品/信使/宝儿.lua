

local name = '宝儿'

local mt = {
    -- 名称
    name = name,
    type = [[maidSkin]],
    archId = TEMP_ID,

    -- 图标
    art = [[ArchArt\accsArt\助手\15baoer.blp]],
    artDark = [[ArchArt\accsArt\助手\dark\15baoer.blp]],

    -- 说明
    title = name,
    unlockTip = [[]],
    relatedArchName = [[签到7日]],
    tip = [[通过签到7日-完成第七天的签到获得]],

    -- 模型
    model = [[cw_xiaoyu.mdx]],
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
