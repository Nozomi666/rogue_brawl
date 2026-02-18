

local name = '向我开炮'

local mt = {
    -- 名称
    name = name,
    type = [[maidSkin]],
    archId = TEMP_ID,

    -- 图标
    art = [[ArchArt\accsArt\助手\25xiangwokaipao.blp]],
    artDark = [[ArchArt\accsArt\助手\dark\25xiangwokaipao.blp]],

    -- 说明
    title = name,
    unlockTip = [[]],
    relatedArchName = [[闪耀奖励7]],
    tip = [[通过闪耀奖励7-闪耀积分达到7级获得]],

    -- 模型
    model = [[xiangwokaipao.mdx]],
    modelSize = 1.2,
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
