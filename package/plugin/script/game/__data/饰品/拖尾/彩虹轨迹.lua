

local name = '彩虹轨迹'

local mt = {
    -- 名称
    name = name,
    type = [[tail]],
    archId = TEMP_ID,

    -- 图标
    art = [[ArchArt\accsArt\拖尾\caihongguiji.blp]],
    artDark = [[ArchArt\accsArt\拖尾\caihongguiji.blp]],

    -- 说明
    title = name,
    relatedArchName = [[四叶草]],
    tip = [[通过四叶草-购买商城道具四叶草获得]],
    -- 模型
    model = [[AZ_DD018.MDX]],
    bind = [[chest]],


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
