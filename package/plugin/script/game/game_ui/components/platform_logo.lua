--------------------------------------------------------------------------------------
class.platform_logo = extends(class.panel) {

    new = function(parent)
        -- 底图是一张黑色的图片 这个可以写死
        local panel = class.panel.new(parent, 'platform_logo.tga', 1, 1, 114, 30)
        -- 改变panel对象的类
        panel.__index = class.platform_logo
        panel:construct()
        panel:draw()
        panel:show()
        return panel
    end,

}
local mt = class.platform_logo
------------------------------------------------------------------------------------
function mt:measure()
    self.x1 = 330
    self.y1 = 5

    -- self.x1 = 1275
    -- self.y1 = -237

    self.w1 = 114 * screenRatio
    self.h1 = 30

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
GUI.platform_logo = mt.create()
GUI.platform_logo:hide()
--------------------------------------------------------------------------------------
return mt
