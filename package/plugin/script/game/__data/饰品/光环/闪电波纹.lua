local name = '闪电波纹'

local mt = {
    -- 名称
    name = name,
    type = [[heroAura]],
    archId = TEMP_ID,

    -- 图标
    art = [[ArchArt\accsArt\光环\6shandianbowen.blp]],
    artDark = [[ArchArt\accsArt\光环\dark\6shandianbowen.blp]],

    -- 说明
    title = name,
    relatedArchName = [[等级奖励40]],
    tip = [[通过等级奖励40-游戏等级达到40级获得]],
    -- 模型
    model = [[947.mdx]],



}
--------------------------------------------------------------------------------------
function mt:onToggle(isAdd)

    local p = self.p
    local maid = p.maid

end
--------------------------------------------------------------------------------------
TEMP_ID = TEMP_ID + 1
reg:addToPool('accs', mt)
reg:addToPool('heroAura', mt)
reg:initTableData('accsTable', mt)
--------------------------------------------------------------------------------------

return mt
