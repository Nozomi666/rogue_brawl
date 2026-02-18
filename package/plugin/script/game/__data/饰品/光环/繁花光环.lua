local name = '繁花光环'

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

    relatedArchName = [[等级奖励10]],
    tip = [[游戏等级10级自动解锁]],

    -- 模型
    model = [[FHGH.mdx]],



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
