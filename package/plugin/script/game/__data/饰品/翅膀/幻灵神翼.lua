

local name = '幻灵神翼'

local mt = {
    -- 名称
    name = name,
    type = [[wings]],
    archId = TEMP_ID,

    -- 图标
    art = [[huanlingshenyi.tga]],
    artDark = [[huanlingshenyi.tga]],
    -- 说明
    title = name,
    relatedArchName = [[魔法熔炉]],
    tip = [[通过购买商城道具魔法熔炉获得]],

    -- 模型
    model = [[huanling518.mdx]],


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
