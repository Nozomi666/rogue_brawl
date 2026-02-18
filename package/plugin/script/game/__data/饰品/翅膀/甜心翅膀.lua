

local name = '甜心翅膀'

local mt = {
    -- 名称
    name = name,
    type = [[wings]],
    archId = TEMP_ID,

    -- 图标
    art = [[tianxinshipin.tga]],
    artDark = [[tianxinshipin.tga]],

    -- 说明
    title = name,
    relatedArchName = [[甜心翅膀]],
    tip = [[持有相应商城道具]],

    -- 模型
    model = [[AZ_Sgb1.mdx]],


}
if localEnv then
    mt.relatedArchName = [[预约人数1000]]
end
--------------------------------------------------------------------------------------
function mt:onToggle(isAdd)

    local p = self.p
    local maid = p.maid

end
--------------------------------------------------------------------------------------
TEMP_ID = TEMP_ID + 1
reg:addToPool('accs', mt)
reg:addToPool('wings', mt)
reg:initTableData('accsTable', mt)
--------------------------------------------------------------------------------------

return mt
