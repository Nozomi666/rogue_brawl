

local name = '头号玩家'

local mt = {
    -- 名称
    name = name,
    type = [[title]],
    archId = TEMP_ID,

    -- 图标
    art = [[touhaowanjia.blp]],
    artDark = [[touhaowanjiadark.blp]],

    -- 说明
    title = name,
    relatedArchName = [[国王之冠]],
    tip = [[通过五一活动奖励（4）获得]],

    -- 模型
    model = [[touhaowanjia.mdx]],
    bind = [[overhead]],
    offsetY = 50,

}
--if localEnv then
--    mt.relatedArchName = [[预约人数1000]]
--end

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
