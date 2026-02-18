--------------------------------------------------------------------------------------
class.mini_map = extends(class.panel) {

    new = function(parent)
        -- 底图是一张黑色的图片 这个可以写死
        local panel = class.panel.new(parent, 'minimap_1.tga', 1, 1, 256, 256)
        -- 改变panel对象的类
        panel.__index = class.mini_map
        panel:construct()
        panel:draw()
        panel:show()
        return panel
    end,

}
local mt = class.mini_map
------------------------------------------------------------------------------------
function mt:measure()
    self.x1 = 39
    self.y1 = -12

    self.w1 = 221 * screenRatio
    self.h1 = 191

end
--------------------------------------------------------------------------------------
function mt:draw()
    self:measure()

    --------------------------------------------------------------------------------------
    self:set_control_size(self.w1, self.h1)
    fc.setFramePos(self, ANCHOR.BOT_LEFT, MAIN_UI, ANCHOR.BOT_LEFT, self.x1, self.y1)
end
--------------------------------------------------------------------------------------
function mt:construct()

end
------------------------------------------------------------------------------------
GUI.miniMap = mt.create()
GUI.miniMap:hide()
--------------------------------------------------------------------------------------
return mt
