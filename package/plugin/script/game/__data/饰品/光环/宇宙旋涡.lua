local name = '宇宙旋涡'

local mt = {
    -- 名称
    name = name,
    type = [[heroAura]],
    archId = TEMP_ID,

    -- 图标
    art = [[ArchArt\accsArt\光环\10yuzhouxuanwo.blp]],
    artDark = [[ArchArt\accsArt\光环\dark\10yuzhouxuanwo.blp]],

    -- 说明
    title = name,
    relatedArchName = [[签到NA]],
    -- 模型
    model = [[872.mdx]],



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
