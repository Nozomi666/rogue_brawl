

local name = '精灵射手'

local mt = {
    -- 名称
    name = name,
    type = [[title]],
    archId = TEMP_ID,

    -- 图标
    art = [[jinglingyouxia.blp]],
    artDark = [[jinglingyouxia.blp]],

    -- 说明
    title = name,
    relatedArchName = [[神灵布偶]],
    tip = [[解锁相应商城道具]],

    -- 模型
    model = [[jlss.mdx]],
    bind = [[overhead]],


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
reg:addToPool('title', mt)
reg:initTableData('accsTable', mt)
--------------------------------------------------------------------------------------

return mt
