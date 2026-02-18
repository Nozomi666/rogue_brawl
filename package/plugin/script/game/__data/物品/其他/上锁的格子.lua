local itemName = '上锁的格子'

local mt = {
    -- 名称
    name = itemName,

    id = -1,
    stackable = true,
    tip = '上锁的格子',
    undragable = true,

}
mt.__index = mt
local itemModel = mt

--------------------------------------------------------------------------------------
function mt:getSkilltipInfo()
    -- if self.unit.name =='地卜师' then
    --     return {
    --         icon = fc.getItemSlkData(self.name, 'Art'),
    --         title = self.name,
    --         tip = '该英雄最多可以解锁4个装备栏',
    --     }
    -- end

    return {
        icon = fc.getItemSlkData(self.name, 'Art'),
        title = self.name,
        tip = self.tip,
    }
end
--------------------------------------------------------------------------------------
setmetatable(mt, as.item)
reg:initItem(mt)
