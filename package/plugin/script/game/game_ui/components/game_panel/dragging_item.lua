--------------------------------------------------------------------------------------
class.dragging_item = extends(class.panel) {

    new = function(parent)
        -- 底图是一张黑色的图片 这个可以写死
        local panel = class.panel.new(parent, TEMPLATE_BTN_PATH, 1, 1, 64, 64)
        -- 改变panel对象的类
        panel.__index = class.dragging_item
        panel:construct()
        panel:draw()
        panel:show()
        return panel
    end,

}
local mt = class.dragging_item
------------------------------------------------------------------------------------
function mt:measure()
    self.x1 = 325
    self.y1 = 0

    -- self.x1 = 1275
    -- self.y1 = -237

    -- fc.getItemSlkData(self.name, 'Art')

    self.w1 = 64 * screenRatio
    self.h1 = 64

end
--------------------------------------------------------------------------------------
function mt:draw()
    self:measure()

    --------------------------------------------------------------------------------------
    self:set_control_size(self.w1, self.h1)
    fc.setFramePos(self, ANCHOR.CENTER, MAIN_UI, ANCHOR.CENTER, 0, 0)
    --------------------------------------------------------------------------------------
    self.unitHint:set_control_size(64, 64)
end
--------------------------------------------------------------------------------------
function mt:construct()
    local unitHint = class.texture.new(self, [[drag_aim.tga]], 1, 1, 0, 0)
    self.unitHint = unitHint
end
--------------------------------------------------------------------------------------
function mt:onDragFinish()
    self:hide()
end
--------------------------------------------------------------------------------------
function mt:onDragUpdate(hasUnit, x, y)
    fc.setFramePos(self, ANCHOR.TOP_LEFT, MAIN_UI, ANCHOR.TOP_LEFT, x, y)
    fc.setFramePos(self.unitHint, ANCHOR.CENTER, self, ANCHOR.TOP_RIGHT, 0, 0)
    if hasUnit then
        self.unitHint:show()
    else
        self.unitHint:hide()
    end

    if hasUnit then
        self:set_normal_image([[drag_aim_yellow.tga]])
        fc.setFramePos(self, ANCHOR.TOP_LEFT, MAIN_UI, ANCHOR.TOP_LEFT, x - 32, y - 32)
    else
        self:set_normal_image(self.normalArt)
    end

    self.unitHint:hide()
    self:show()
end
--------------------------------------------------------------------------------------
function mt:onDragStart(item, x, y)
    -- gdebug('dragging item ui: ' .. item.art)
    -- local art = item:getArt()
    -- if not art then
    --     art = [[ReplaceableTextures\CommandButtons\BTNCrystalBall.blp]]
    -- end
    local art = [[ReplaceableTextures\CommandButtons\BTNCrystalBall.blp]]
    self:set_normal_image(art)
    self.normalArt = art
    -- local x, y, scale = message.world_to_screen(x, y, 0)
    -- fc.setFramePos(self, ANCHOR.CENTER, MAIN_UI, ANCHOR.CENTER, 0,0)
    -- fc.setFramePosPct(self, ANCHOR.TOP_LEFT, MAIN_UI, ANCHOR.TOP_LEFT, x / 0.8, y / 0.6)
    fc.setFramePos(self, ANCHOR.TOP_LEFT, MAIN_UI, ANCHOR.TOP_LEFT, x, y)
    fc.setFramePos(self.unitHint, ANCHOR.TOP_RIGHT, self, ANCHOR.TOP_RIGHT, 0, 0)
    self.unitHint:hide()
    self:hide()

end
------------------------------------------------------------------------------------
GUI.dragging_item = mt.create()
GUI.dragging_item:hide()
--------------------------------------------------------------------------------------
return mt
