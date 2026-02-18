local name = '樱花之舞'

local mt = {
    -- 名称
    name = name,
    type = [[heroAura]],
    archId = TEMP_ID,

    -- 图标
    art = [[ArchArt\accsArt\光环\9yinghuazhiwu.blp]],
    artDark = [[ArchArt\accsArt\光环\dark\9yinghuazhiwu.blp]],

    -- 说明
    title = name,
    relatedArchName = [[地图奖励17]],
    tip = [[通过地图奖励17-地图等级达到30级获得]],
    -- 模型
    model = [[372.mdx]],



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
