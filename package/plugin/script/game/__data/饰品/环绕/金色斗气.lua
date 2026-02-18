

local name = '金色斗气'

local mt = {
    -- 名称
    name = name,
    type = [[rounder]],
    archId = TEMP_ID,

    -- 图标
    art = cst.BTN_PREFIX_ACTIVE .. [[xingxingdiandeng]],
    artDark = cst.BTN_PREFIX_DARK .. [[xingxingdiandeng]],

    -- 说明
    title = name,

    -- 模型
    model = [[AZ_Goods_springwater_Target(1).mdx]],
    bind = [[origin]],


}
--------------------------------------------------------------------------------------
function mt:onToggle(isAdd)

    local p = self.p
    local maid = p.maid



end
--------------------------------------------------------------------------------------
TEMP_ID = TEMP_ID + 1
reg:addToPool('accs', mt)
reg:addToPool('rounder', mt)
reg:initTableData('accsTable', mt)
--------------------------------------------------------------------------------------

return mt
