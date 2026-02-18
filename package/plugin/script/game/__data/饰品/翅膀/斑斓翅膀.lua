
local name = '斑斓翅膀'

local mt = {
    -- 名称
    name = name,
    type = [[wings]],
    archId = TEMP_ID,

    -- 图标
    art = [[ArchArt\accsArt\翅膀\13banlanchibang.tga]],
    artDark = [[ArchArt\accsArt\翅膀\dark\13banlanchibang.tga]],

    -- 说明
    title = name,
    relatedArchName = [[沼泽高阶第5级]],
    tip = [[通过沼泽高阶第5级-达成高阶沼泽通行证第五级获得]],
    
    -- 模型
    model = [[jfcb2.mdx]],


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
