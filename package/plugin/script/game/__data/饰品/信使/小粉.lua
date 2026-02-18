

local name = '小粉'

local mt = {
    -- 名称
    name = name,
    type = [[maidSkin]],
    archId = TEMP_ID,

    -- 图标
    art = [[ArchArt\accsArt\助手\xiaofen.tga]],
    artDark = [[ArchArt\accsArt\助手\dark\xiaofendark.tga]],

    -- 说明
    title = name,
    unlockTip = [[]],
    relatedArchName = [[61存档200件]],
    tip = [[通过收集61存档200件获得]],

    -- 模型
    model = [[cwchangsunhuanghouOK.mdx]],
    modelSize = 2.2,
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
