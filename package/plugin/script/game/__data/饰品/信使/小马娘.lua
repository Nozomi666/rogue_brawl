

local name = '小马娘'

local mt = {
    -- 名称
    name = name,
    type = [[maidSkin]],
    archId = TEMP_ID,

    -- 图标
    art = [[ArchArt\accsArt\助手\5xiaomaniang.blp]],
    artDark = [[ArchArt\accsArt\助手\dark\5xiaomaniang.blp]],

    -- 说明
    title = name,
    unlockTip = [[]],
    relatedArchName = [[等级奖励30]],
    tip = [[通过等级奖励30-游戏等级达到30级获得]],

    -- 模型
    model = [[sd_tannhauser.mdx]],
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
