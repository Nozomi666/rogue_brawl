

local name = '虚龙之翼'

local mt = {
    -- 名称
    name = name,
    type = [[wings]],
    archId = TEMP_ID,

    -- 图标
    art = [[ArchArt\accsArt\翅膀\8xulongzhiyi.blp]],
    artDark = [[ArchArt\accsArt\翅膀\dark\8xulongzhiyi.blp]],

    -- 说明
    title = name,
    relatedArchName = [[签到4日]],
    tip = [[通过签到4日-完成第四天的签到获得]],
    
    -- 模型
    model = [[[cb]molongxuying.mdx]],


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
