

local name = '幻蓝之翅'

local mt = {
    -- 名称
    name = name,
    type = [[wings]],
    archId = TEMP_ID,

    -- 图标
    art = [[ArchArt\accsArt\翅膀\3huanlanzhichi.blp]],
    artDark = [[ArchArt\accsArt\翅膀\dark\3huanlanzhichi.blp]],

    -- 说明
    title = name,
    relatedArchName = [[内测礼包]],
    tip = [[通过内测贡献-参与游戏内测获得]],

    -- 模型
    model = [[Cosmic Wings.mdx]],


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
