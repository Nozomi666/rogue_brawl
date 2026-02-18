

local name = '神秘羽翼'

local mt = {
    -- 名称
    name = name,
    type = [[wings]],
    archId = TEMP_ID,

    -- 图标
    art = [[shenmiyuyi.blp]],
    artDark = [[shenmiyuyi.blp]],
    -- 说明
    title = name,
    relatedArchName = [[预约人数1000]],
    tip = [[6-17补偿]],

    -- 模型
    model = [[war3AKE.com - WingOfTheLucifer.mdx]],


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
