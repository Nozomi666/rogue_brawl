

local name = '死亡之翼'

local mt = {
    -- 名称
    name = name,
    type = [[wings]],
    archId = TEMP_ID,

    -- 图标
    art = [[ArchArt\accsArt\翅膀\7siwangzhiyi.blp]],
    artDark = [[ArchArt\accsArt\翅膀\dark\7siwangzhiyi.blp]],

    -- 说明
    title = name,
    relatedArchName = [[星数奖励1-20]],
    tip = [[通过星数奖励1-20-在第一章集齐二十颗星星获得]],

    -- 模型
    model = [[cb7.mdx]],


}
--------------------------------------------------------------------------------------
function mt:onToggle(isAdd)

    local p = self.p
    local maid = p.maid

end
--------------------------------------------------------------------------------------
TEMP_ID = TEMP_ID + 1
reg:addToPool('accs', mt)
reg:addToPool('wings', mt)
reg:initTableData('accsTable', mt)
--------------------------------------------------------------------------------------

return mt
