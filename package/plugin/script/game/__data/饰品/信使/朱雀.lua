

local name = '朱雀'

local mt = {
    -- 名称
    name = name,
    type = [[maidSkin]],
    archId = TEMP_ID,

    -- 图标
    art = [[ArchArt\accsArt\助手\zhuque.blp]],
    artDark = [[ArchArt\accsArt\助手\dark\zhuque.blp]],

    -- 说明
    title = name,
    unlockTip = [[]],
    relatedArchName = [[地图奖励27]],
    tip = [[地图等级达到75级解锁]],

    -- 模型
    model = [[104.mdx]],
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
