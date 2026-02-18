

local name = '混沌之眼'

local mt = {
    -- 名称
    name = name,
    type = [[wings]],
    archId = TEMP_ID,

    -- 图标
    art = [[ArchArt\accsArt\翅膀\10hundunzhiyan.blp]],
    artDark = [[ArchArt\accsArt\翅膀\dark\10hundunzhiyan.blp]],

    -- 说明
    title = name,
    relatedArchName = [[纪念怀表]],
    tip = [[通过五一活动奖励（3）获得]],

    -- 模型
    model = [[689.mdx]],


}
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
