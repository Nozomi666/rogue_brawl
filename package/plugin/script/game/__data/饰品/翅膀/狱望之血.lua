

local name = '狱望之血'

local mt = {
    -- 名称
    name = name,
    type = [[wings]],
    archId = TEMP_ID,

    -- 图标
    art = [[ArchArt\accsArt\翅膀\9yuwangzhixue.blp]],
    artDark = [[ArchArt\accsArt\翅膀\dark\9yuwangzhixue.blp]],
    -- 说明
    title = name,
    relatedArchName = [[火凤天临]],
    tip = [[通过火凤天临-购买商城道具火凤天临获得]],

    -- 模型
    model = [[Chaos Wings.mdx]],


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
