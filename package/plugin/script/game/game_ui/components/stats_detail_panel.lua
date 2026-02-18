--------------------------------------------------------------------------------------
class.stats_detail_panel = extends(class.panel) {

    new = function(parent)
        -- 底图是一张黑色的图片 这个可以写死
        local panel = class.panel.new(parent, '', 1, 1, 356, 640)
        -- 改变panel对象的类
        panel.__index = class.stats_detail_panel
        panel:construct()
        panel:draw()
        panel:show()
        return panel
    end,

}
local mt = class.stats_detail_panel
------------------------------------------------------------------------------------
function mt:measure()
    self.w1 = 356
    self.h1 = 640

    self.w2 = 14
    self.h2 = 550 * 1.05
end
--------------------------------------------------------------------------------------
function mt:draw()
    self:measure()

    --------------------------------------------------------------------------------------
    -- 主面板
    fc.setFramePosPct(self, ANCHOR.CENTER, MAIN_UI, ANCHOR.CENTER, -0.32, -0.1)
    fc.setFramePos(self.scrollPanel, ANCHOR.TOP_LEFT, self, ANCHOR.TOP_LEFT, 0, 40)

    self.scrollBackground:set_control_size(self.w2, self.h2)
    fc.setFramePos(self.scrollBackground, ANCHOR.TOP_RIGHT, self, ANCHOR.TOP_RIGHT, -6, 20)
end
--------------------------------------------------------------------------------------
function mt:construct()

    --------------------------------------------------------------------------------------
    local background = self:add_texture([[scroll_page_base.tga]], 0, 0, self.w, self.h)
    -- background:set_alpha(0.4)

    self.dragFrame = self:add_title_button('', '', 0, 0, 356, 640, 20)

    local scrollBackground = self:add_texture([[scroll_btn_base.tga]], 0, 0, self.w2, self.h2)
    self.scrollBackground = scrollBackground

    self.scrollPanel = class.stats_detail.add_child(self)

end
--------------------------------------------------------------------------------------
function mt:update()
    self.scrollPanel:update()
end

------------------------------------------------------------------------------------
GUI.StatsDetailPanel = mt.create()
GUI.StatsDetailPanel:hide()
--------------------------------------------------------------------------------------
return mt
