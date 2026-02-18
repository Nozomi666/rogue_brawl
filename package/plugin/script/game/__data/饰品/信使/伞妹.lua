

local name = '伞妹'

local mt = {
    -- 名称
    name = name,
    type = [[maidSkin]],
    archId = TEMP_ID,

    -- 图标
    art = [[ArchArt\accsArt\助手\26sanmei.blp]],
    artDark = [[ArchArt\accsArt\助手\dark\26sanmei.blp]],

    -- 说明
    title = name,
    unlockTip = [[]],
    relatedArchName = [[闪耀奖励16]],
    tip = [[通过闪耀奖励16-闪耀积分达到16级获得]],

    -- 模型
    model = [[970.mdx]],
    modelSize = 1,
    -- replaceUnitType = [[e002]],
    uiSize = 0.4,

}
if localEnv then
    mt.relatedArchName = [[科技点福利]]
end
--------------------------------------------------------------------------------------
TEMP_ID = TEMP_ID + 1
reg:addToPool('accs', mt)
reg:addToPool('maidSkin', mt)
reg:initTableData('accsTable', mt)
--------------------------------------------------------------------------------------

return mt
