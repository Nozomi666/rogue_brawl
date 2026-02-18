

local name = '彩蝶之翼'

local mt = {
    -- 名称
    name = name,
    type = [[wings]],
    archId = TEMP_ID,

    -- 图标
    art = [[ArchArt\accsArt\翅膀\1caidiezhiyi.blp]],
    artDark = [[ArchArt\accsArt\翅膀\dark\1caidiezhiyi.blp]],

    -- 说明
    title = name,
    relatedArchName = [[等级奖励20]],
    tip = [[通过等级奖励20-游戏等级达到20级获得]],

    -- 模型
    model = [[326.mdx]],


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
