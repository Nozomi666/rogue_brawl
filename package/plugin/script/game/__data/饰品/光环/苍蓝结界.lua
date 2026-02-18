local name = '苍蓝结界'

local mt = {
    -- 名称
    name = name,
    type = [[heroAura]],
    archId = TEMP_ID,

    -- 图标
    art = [[ArchArt\accsArt\光环\1fanhuaguanghuan.blp]],
    artDark = [[ArchArt\accsArt\光环\dark\1fanhuaguanghuan.blp]],

    -- 说明
    title = name,

    -- 模型
    model = [[SUMMON~1.mdx]],



}
--------------------------------------------------------------------------------------
function mt:onToggle(isAdd)

    local p = self.p
    local maid = p.maid

end
--------------------------------------------------------------------------------------
TEMP_ID = TEMP_ID + 1
reg:addToPool('accs', mt)
-- reg:addToPool('heroAura', mt)
reg:initTableData('accsTable', mt)
--------------------------------------------------------------------------------------

return mt
