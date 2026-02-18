

local name = '珊瑚之翅'

local mt = {
    -- 名称
    name = name,
    type = [[wings]],
    archId = TEMP_ID,

    -- 图标
    art = [[ArchArt\accsArt\翅膀\5shanhuzhichi.blp]],
    artDark = [[ArchArt\accsArt\翅膀\dark\5shanhuzhichi.blp]],

    -- 说明
    title = name,
    relatedArchName = [[加精礼包]],
    tip = [[通过加精礼包-在社区发帖并被加精获得]],

    -- 模型
    model = [[cb7.mdx]],


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
