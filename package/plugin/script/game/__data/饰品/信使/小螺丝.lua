

local name = '小螺丝'

local mt = {
    -- 名称
    name = name,
    type = [[maidSkin]],
    archId = TEMP_ID,

    -- 图标
    art = [[ArchArt\accsArt\助手\19xiaoluosi.blp]],
    artDark = [[ArchArt\accsArt\助手\dark\19xiaoluosi.blp]],

    -- 说明
    title = name,
    unlockTip = [[]],
    relatedArchName = [[第1章无尽30波]],
    tip = [[通过第1章无尽30波-完成第1章节无尽突破30层成就获得]],

    -- 模型
    model = [[1049.mdx]],
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
