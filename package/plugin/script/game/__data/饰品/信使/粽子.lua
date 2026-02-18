

local name = '粽子'

local mt = {
    -- 名称
    name = name,
    type = [[maidSkin]],
    archId = TEMP_ID,

    -- 图标
    art = [[ArchArt\accsArt\助手\2.tga]],
    artDark = [[ArchArt\accsArt\助手\dark\1.tga]],

    -- 说明
    title = name,
    unlockTip = [[]],
    relatedArchName = [[粽子选手]],
    tip = [[通过商城道具粽子选手获得]],

    -- 模型
    model = [[JD_zongzi_01.mdx]],
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
