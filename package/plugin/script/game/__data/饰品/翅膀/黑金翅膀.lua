

local name = '黑金翅膀'

local mt = {
    -- 名称
    name = name,
    type = [[wings]],
    archId = TEMP_ID,

    -- 图标
    art = [[ArchArt\accsArt\翅膀\2heijinchibang.blp]],
    artDark = [[ArchArt\accsArt\翅膀\dark\2heijinchibang.blp]],

    -- 说明
    title = name,
    relatedArchName = [[百宝衣]],
    tip = [[通过百宝衣-购买商城道具百宝衣获得]],

    -- 模型
    model = [[199.mdx]],


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
