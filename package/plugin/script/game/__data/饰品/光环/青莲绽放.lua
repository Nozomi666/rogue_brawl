local name = '青莲绽放'

local mt = {
    -- 名称
    name = name,
    type = [[heroAura]],
    archId = TEMP_ID,

    -- 图标
    art = [[ArchArt\accsArt\光环\5qinglianzhanfang.blp]],
    artDark = [[ArchArt\accsArt\光环\dark\5qinglianzhanfang.blp]],

    -- 说明
    title = name,
    relatedArchName = [[第1章无尽100波]],
    tip = [[通过第1章无尽100波-完成第1章节无尽突破100层成就获得]],
    -- 模型
    model = [[934.mdx]],



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
