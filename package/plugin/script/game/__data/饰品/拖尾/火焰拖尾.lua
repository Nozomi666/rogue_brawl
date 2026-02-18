

local name = '火焰拖尾'

local mt = {
    -- 名称
    name = name,
    type = [[tail]],
    archId = TEMP_ID,

    -- 图标
    art = [[ArchArt\accsArt\拖尾\huoyantuowei.blp]],
    artDark = [[ArchArt\accsArt\拖尾\huoyantuowei.blp]],

    -- 说明
    title = name,
    relatedArchName = [[星数奖励1-30]],
    tip = [[通过星数奖励1-30-在第一章集齐三十颗星星获得]],

    -- 模型
    model = [[Windwalk Fire.mdx]],
    bind = [[origin]],


}
-- if localEnv then
--     mt.relatedArchName = [[等级奖励1]]
-- end
--------------------------------------------------------------------------------------
function mt:onToggle(isAdd)

    local p = self.p
    local maid = p.maid



end
--------------------------------------------------------------------------------------
TEMP_ID = TEMP_ID + 1
reg:addToPool('accs', mt)
reg:addToPool('tail', mt)
reg:initTableData('accsTable', mt)
--------------------------------------------------------------------------------------

return mt
