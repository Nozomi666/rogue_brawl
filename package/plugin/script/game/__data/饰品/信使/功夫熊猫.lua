

local name = '功夫熊猫'

local mt = {
    -- 名称
    name = name,
    type = [[maidSkin]],
    archId = TEMP_ID,

    -- 图标
    art = [[ArchArt\accsArt\助手\xiongmaozhanshi.blp]],
    artDark = [[ArchArt\accsArt\助手\dark\xiongmaozhanshi.blp]],

    -- 说明
    title = name,
    unlockTip = [[]],
    relatedArchName = [[闪耀奖励23]],
    tip = [[闪耀积分达到1400]],

    -- 模型
    model = [[longzhanshi.mdx]],
    modelSize = 1,
    -- replaceUnitType = [[e002]],
    uiSize = 0.4,

}
if localEnv then
    mt.relatedArchName = [[预约人数1000]]
end
--------------------------------------------------------------------------------------
TEMP_ID = TEMP_ID + 1
reg:addToPool('accs', mt)
reg:addToPool('maidSkin', mt)
reg:initTableData('accsTable', mt)
--------------------------------------------------------------------------------------

return mt
