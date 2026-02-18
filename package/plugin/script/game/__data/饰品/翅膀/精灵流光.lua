

local name = '精灵流光'

local mt = {
    -- 名称
    name = name,
    type = [[wings]],
    archId = TEMP_ID,

    -- 图标
    art = [[ArchArt\accsArt\翅膀\11jinglingliuguang.blp]],
    artDark = [[ArchArt\accsArt\翅膀\dark\11jinglingliuguang.blp]],

    -- 说明
    title = name,
    relatedArchName = [[5-3日补偿礼包]],
    tip = [[通过5-3日补偿礼包获得]],

    -- 模型
    model = [[285.mdx]],


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
