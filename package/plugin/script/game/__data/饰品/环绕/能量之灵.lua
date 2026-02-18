

local name = '能量之灵'

local mt = {
    -- 名称
    name = name,
    type = [[rounder]],
    archId = TEMP_ID,

    -- 图标
    art = [[ArchArt\accsArt\环绕\1nengliangzhiling.blp]],
    artDark = [[ArchArt\accsArt\环绕\dark\1nengliangzhiling.blp]],

    -- 说明
    title = name,
    relatedArchName = [[星数奖励1-10]],
    tip = [[通过星数奖励1-10-在第一章集齐十颗星星获得]],

    -- 模型
    model = [[484.mdx]],
    bind = [[origin]],


}
--------------------------------------------------------------------------------------
function mt:onToggle(isAdd)

    local p = self.p
    local maid = p.maid



end
--------------------------------------------------------------------------------------
TEMP_ID = TEMP_ID + 1
reg:addToPool('accs', mt)
reg:addToPool('rounder', mt)
reg:initTableData('accsTable', mt)
--------------------------------------------------------------------------------------

return mt
