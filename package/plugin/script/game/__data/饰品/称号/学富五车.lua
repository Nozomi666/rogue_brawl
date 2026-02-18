

local name = '学富五车'

local mt = {
    -- 名称
    name = name,
    type = [[title]],
    archId = TEMP_ID,

    -- 图标
    art = [[xuefuwuche.blp]],
    artDark = [[xuefuwuchedark.blp]],

    -- 说明
    title = name,
    relatedArchName = [[学富五车]],
    tip = [[解锁相应成就]],

    -- 模型
    model = [[xuefuwuche.mdx]],
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
