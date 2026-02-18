

local name = '骷髅晶翼'

local mt = {
    -- 名称
    name = name,
    type = [[wings]],
    archId = TEMP_ID,

    -- 图标
    art = [[ArchArt\accsArt\翅膀\4kuloujingyi.blp]],
    artDark = [[ArchArt\accsArt\翅膀\dark\4kuloujingyi.blp]],

    -- 说明
    title = name,
    relatedArchName = [[第2章无尽100波]],
    tip = [[完成第2章无尽100波获得]],

    -- 模型
    model = [[cb_03.mdx]],


}
if localEnv then
    mt.relatedArchName = [[预约人数1000]]
end
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
