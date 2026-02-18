local name = '蓝色符文'

local mt = {
    -- 名称
    name = name,
    type = [[heroAura]],
    archId = TEMP_ID,

    -- 图标
    art = [[ArchArt\accsArt\光环\14lansefuwen.tga]],
    artDark = [[ArchArt\accsArt\光环\14lansefuwen.tga]],

    -- 说明
    title = name,
    relatedArchName = [[沼泽初阶第20级]],
    tip = [[通过沼泽初阶第20级-达成初阶沼泽通行证第二十级获得]],
    -- 模型
    model = [[A (253).mdx]],



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
