

local name = '见习牧师'

local mt = {
    -- 名称
    name = name,
    type = [[maidSkin]],
    archId = TEMP_ID,

    -- 图标
    art = [[ArchArt\accsArt\助手\12jianximushi.blp]],
    artDark = [[ArchArt\accsArt\助手\dark\12jianximushi.blp]],

    -- 说明
    title = name,
    unlockTip = [[]],
    relatedArchName = [[地图奖励14]],
    tip = [[通过地图奖励14-地图等级达到20级获得]],

    -- 模型
    model = [[JD-jingdain-xfzn 1_111.mdx]],
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
