local name = '神圣涟漪'

local mt = {
    -- 名称
    name = name,
    type = [[heroAura]],
    archId = TEMP_ID,

    -- 图标
    art = [[ArchArt\accsArt\光环\7shenshenglianyi.blp]],
    artDark = [[ArchArt\accsArt\光环\dark\7shenshenglianyi.blp]],

    -- 说明
    title = name,
    relatedArchName = [[神迹牢笼]],
    tip = [[通过神迹牢笼-购买商城道具神迹牢笼获得]],
    -- 模型
    model = [[A (52).mdx]],



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
