

local name = '血月能量'

local mt = {
    -- 名称
    name = name,
    type = [[rounder]],
    archId = TEMP_ID,

    -- 图标
    art = [[xueyuenengliang.blp]],
    artDark = [[xueyuenengliangdark.blp]],

    -- 说明
    title = name,
    relatedArchName = [[第1章无尽200波]],
    tip = [[通过第1章无尽200波]],

    -- 模型
    model = [[xueyuenengliang.mdx]],
    bind = [[origin]],


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
reg:addToPool('rounder', mt)
reg:initTableData('accsTable', mt)
--------------------------------------------------------------------------------------

return mt
