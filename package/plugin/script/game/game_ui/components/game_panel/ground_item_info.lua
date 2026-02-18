--------------------------------------------------------------------------------------
class.ground_item_info = extends(class.panel) {

    new = function(parent)
        -- 底图是一张黑色的图片 这个可以写死
        local panel = class.panel.new(parent, nil, 1, 1, 1, 1)
        -- 改变panel对象的类
        panel.__index = class.ground_item_info
        panel:construct()
        panel:draw()
        panel:show()
        return panel
    end,

}
local mt = class.ground_item_info
------------------------------------------------------------------------------------
function mt:measure()
    self.x1 = -0.05
    self.y1 = 0.32

    self.x2 = -0.1
    self.y2 = 0.32 + 0.04

end
--------------------------------------------------------------------------------------
function mt:draw()
    self:measure()
    --------------------------------------------------------------------------------------
    -- 标题
    local itemTitle = self.itemTitle
    itemTitle:set_control_size(200, 10)
    fc.setFramePosPct(itemTitle, ANCHOR.TOP_LEFT, MAIN_UI, ANCHOR.CENTER, self.x1, self.y1)

    --------------------------------------------------------------------------------------
    -- 提示
    local itemTip = self.itemTip
    itemTip:set_control_size(400, 300)
    fc.setFramePosPct(itemTip, ANCHOR.TOP_LEFT, MAIN_UI, ANCHOR.CENTER, self.x2, self.y2)

end
--------------------------------------------------------------------------------------
function mt:construct()
    --------------------------------------------------------------------------------------
    -- 标题
    --------------------------------------------------------------------------------------
    local itemTitle = self:add_text('物品名称', 0, 0, 1, 1, 16, 'center')
    self.itemTitle = itemTitle

     --------------------------------------------------------------------------------------
    -- 提示
    local itemTip = self:add_text('物品描述物品描述物品描述物品描述物品描述物品描述物品描述物品描述物品描述', 0, 0, 1, 1, 10, 'auto_newline')
    self.itemTip = itemTip

end
--------------------------------------------------------------------------------------
function mt:update(itemHandle)
    local itemTypeJ = GetItemTypeId(itemHandle)
    local title = GetItemName(itemHandle)
    local tip = slk.item[itemTypeJ]['Description']

    local item = as.item:j2t(itemHandle)

    if item and item.title then
        title = item.title
    end

    if item and item.groundTip then
        tip = item.groundTip
    end

    self.itemTitle:set_text(title)
    self.itemTip:set_text(tip)
end
------------------------------------------------------------------------------------
GUI.GroundItemInfo = mt.create()
GUI.GroundItemInfo:hide()
--------------------------------------------------------------------------------------
return mt
