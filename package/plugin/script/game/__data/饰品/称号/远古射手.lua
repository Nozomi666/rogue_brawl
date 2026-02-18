

local name = '远古射手'

local mt = {
    -- 名称
    name = name,
    type = [[title]],
    archId = TEMP_ID,

    -- 图标
    art = [[yuangutubiao.blp]],
    artDark = [[yuangutubiao.blp]],

    -- 说明
    title = name,
    relatedArchName = [[内测等级50]],
    tip = [[通过内测等级50-在内测期间地图等级达到50级获得]],

    -- 模型
    model = [[chenghaomoban.mdx]],
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
