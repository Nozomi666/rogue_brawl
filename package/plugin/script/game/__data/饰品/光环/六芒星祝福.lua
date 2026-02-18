local name = '六芒星祝福'

local mt = {
    -- 名称
    name = name,
    type = [[heroAura]],
    archId = TEMP_ID,

    -- 图标
    art = [[ArchArt\accsArt\光环\3liumangxingzhufu.blp]],
    artDark = [[ArchArt\accsArt\光环\dark\3liumangxingzhufu.blp]],

    -- 说明
    title = name,
    relatedArchName = [[封印之杖]],
    tip = [[通过封印之杖-购买商城道具封印之杖获得]],
    -- 模型
    model = [[519.mdx]],



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
