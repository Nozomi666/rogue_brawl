

local name = '魔能之翼'

local mt = {
    -- 名称
    name = name,
    type = [[wings]],
    archId = TEMP_ID,

    -- 图标
    art = [[monengzhiyi.blp]],
    artDark = [[monengzhiyi.blp]],

    -- 说明
    title = name,
    relatedArchName = [[沙漠高阶第20级]],
    tip = [[沙丘通行证高级20级奖励]],

    -- 模型
    model = [[Mr.War3JD01.mdx]],


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
