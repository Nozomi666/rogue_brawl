local name = '守护之眼'

local mt = {
    -- 名称
    name = name,
    type = [[heroAura]],
    archId = TEMP_ID,

    -- 图标
    art = [[ArchArt\accsArt\光环\13shouhuzhiyan.blp]],
    artDark = [[ArchArt\accsArt\光环\dark\13shouhuzhiyandark.blp]],

    -- 说明
    title = name,
    relatedArchName = [[闪耀奖励3]],
    tip = [[闪耀积分达到3级]],
    -- 模型
    model = [[[gh]shouhuzhiyan.mdx]],



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
