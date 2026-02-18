local name = '萤火之辉'

local mt = {
    -- 名称
    name = name,
    type = [[heroAura]],
    archId = TEMP_ID,

    -- 图标
    art = [[yinghuozhihui.blp]],
    artDark = [[yinghuozhihui.blp]],

    -- 说明
    title = name,
    relatedArchName = [[沙漠初阶第20级]],
    tip = [[沙丘通行证初级20级奖励]],
    -- 模型
    model = [[JD_magicmatrix19.mdx]],



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
reg:addToPool('heroAura', mt)
reg:initTableData('accsTable', mt)
--------------------------------------------------------------------------------------

return mt
