

local name = '小凤凰'

local mt = {
    -- 名称
    name = name,
    type = [[maidSkin]],
    archId = TEMP_ID,

    -- 图标
    art = [[xiaofenghuang.blp]],
    artDark = [[xiaofenghuang.blp]],

    -- 说明
    title = name,
    unlockTip = [[]],
    relatedArchName = [[燃烧之刃]],
    tip = [[持有商城道具【燃烧之刃】解锁]],

    -- 模型
    model = [[war3mapImported\fmhx.mdl]],
    modelSize = 3,
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
