local name = '魔能粒子'

local mt = {
    -- 名称
    name = name,
    type = [[heroAura]],
    archId = TEMP_ID,

    -- 图标
    art = [[ArchArt\accsArt\光环\4monenglizi.blp]],
    artDark = [[ArchArt\accsArt\光环\dark\4monenglizi.blp]],

    -- 说明
    title = name,
    relatedArchName = [[创世晶核]],
    tip = [[通过创世晶核-购买商城道具创世晶核获得]],
    -- 模型
    model = [[monenglizi.mdx]],



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
