--------------------------------------------------------------------------------------
class.ui_template = extends(class.panel) {

    new = function(parent)
        -- 底图是一张黑色的图片 这个可以写死
        local panel = class.panel.new(parent, [[]], 1, 1, 1, 1)
        -- 改变panel对象的类
        panel.__index = class.ui_template
        panel:construct()
        panel:draw()
        panel:show()
        return panel
    end,

}
local mt = class.ui_template
------------------------------------------------------------------------------------
function mt:measure()

    self.baseW = 1066
    self.baseH = 770
end
--------------------------------------------------------------------------------------
function mt:draw()
    self:measure()
    --------------------------------------------------------------------------------------
    self:set_normal_image([[ui\banHero\base.tga]])
    self:set_control_size(self.baseW, self.baseH)
    fc.setFramePos(self, ANCHOR.CENTER, MAIN_UI, ANCHOR.CENTER, 0, 0)

    --------------------------------------------------------------------------------------
    local backgroundCoverBtn = self.backgroundCoverBtn
    backgroundCoverBtn:set_control_size(self.baseW, self.baseH)
    backgroundCoverBtn:set_alpha(0)
    fc.setFramePos(backgroundCoverBtn, ANCHOR.CENTER, self, ANCHOR.CENTER, 0, 0)
    --------------------------------------------------------------------------------------
    local closeBtn = self.closeBtn
    closeBtn:set_control_size(50, 50)
    fc.setFramePos(closeBtn, ANCHOR.CENTER, self, ANCHOR.TOP_RIGHT, -3, 0)
    --------------------------------------------------------------------------------------

end
--------------------------------------------------------------------------------------
function mt:construct()
    --------------------------------------------------------------------------------------
    self.backgroundCoverBtn = class.button.new(self, 'black.blp', 0, 0, 1, 1)
    --------------------------------------------------------------------------------------
    local closeBtn = class.button.new(self, [[UI\archArt\guanbi1.tga]], 0, 0, 1, 1)
    closeBtn:set_hover_image([[UI\archArt\guanbi2.tga]])
    self.closeBtn = closeBtn
    function closeBtn:on_button_clicked(player)
        self.parent:hide()
    end
    --------------------------------------------------------------------------------------
end
------------------------------------------------------------------------------------
GUI.UITemplate = mt.create(MAIN_UI)
GUI.UITemplate:show()

-----------------------------------------------------e---------------------------------
return mt
