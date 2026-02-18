

local name = '猫娘'

local mt = {
    -- 名称
    name = name,
    type = [[maidSkin]],
    archId = TEMP_ID,

    -- 图标
    art = [[ArchArt\accsArt\助手\maoniang.tga]],
    artDark = [[ArchArt\accsArt\助手\dark\maoniang.tga]],

    -- 说明
    title = name,
    unlockTip = [[]],
    relatedArchName = [[闪耀奖励25]],
    tip = [[闪耀积分2000分解锁]],

    -- 模型
    model = [[hero_yxcc (2).mdx]],
    modelSize = 2,
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
