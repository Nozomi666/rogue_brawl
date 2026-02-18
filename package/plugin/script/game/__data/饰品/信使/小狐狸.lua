

local name = '小狐狸'

local mt = {
    -- 名称
    name = name,
    type = [[maidSkin]],
    archId = TEMP_ID,

    -- 图标
    art = [[ArchArt\mapfuli\xiaohuli.tga]],
    artDark = [[ArchArt\mapfuli\xiaohuli.tga]],

    -- 说明
    title = name,
    unlockTip = [[]],
    relatedArchName = [[5-9补偿礼包]],
    tip = [[自动激活]],

    -- 模型
    model = [[169.mdx]],
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
