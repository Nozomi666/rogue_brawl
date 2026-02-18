

local name = '深蓝幽静'

local mt = {
    -- 名称
    name = name,
    type = [[wings]],
    archId = TEMP_ID,

    -- 图标
    art = [[ArchArt\accsArt\翅膀\6shenlanyoujing.blp]],
    artDark = [[ArchArt\accsArt\翅膀\dark\6shenlanyoujing.blp]],

    -- 说明
    title = name,
    relatedArchName = [[地图奖励9]],
    tip = [[通过地图奖励9-地图等级达到10级获得]],

    -- 模型
    model = [[45.mdx]],


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
