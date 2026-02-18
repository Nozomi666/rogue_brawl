--------------------------------------------------------------------------------------
class.stats_detail_panel_btn = extends(class.panel) {

    new = function(parent)
        -- 底图是一张黑色的图片 这个可以写死
        local panel = class.panel.new(parent, nil, 1, 1, 1, 1)
        -- 改变panel对象的类
        panel.__index = class.stats_detail_panel_btn
        panel:construct()
        panel:draw()
        panel:show()
        return panel
    end,

}
local mt = class.stats_detail_panel_btn
------------------------------------------------------------------------------------
function mt:measure()
    self.x1 = 310
    self.y1 = -10

    self.w1 = 82 * screenRatio
    self.h1 = 72

    self.x2 = -16 * screenRatio
    self.y2 = -5

end
--------------------------------------------------------------------------------------
function mt:draw()
    self:measure()

    --------------------------------------------------------------------------------------
    -- 按钮
    local statsBtn = self.statsBtn
    statsBtn:set_control_size(self.w1 * statsBtn.sizeRate, self.h1 * statsBtn.sizeRate)
    fc.setFramePos(statsBtn, ANCHOR.BOT_LEFT, MAIN_UI, ANCHOR.BOT_LEFT, self.x1, self.y1)
    --------------------------------------------------------------------------------------

end
--------------------------------------------------------------------------------------
function mt:construct()

    --------------------------------------------------------------------------------------
    -- 按钮
    local statsBtn = class.button.new(self, [[TABstatsDetailNormal.tga]], 0, 0, 1, 1)
    statsBtn:set_hover_image(str.format([[TABstatsDetailLight.tga]]))
    statsBtn.sizeRate = 1
    self.statsBtn = statsBtn
    function statsBtn:on_button_clicked(player)
        self.parent:onClick()
    end

end
--------------------------------------------------------------------------------------
function mt:onClick()
    local p = as.player:getLocalPlayer()

    if GUI.StatsDetailPanel.is_show then
        glo.udg_blockScroll[fc.getLocalPlayer().id] = false
        GUI.StatsDetailPanel:hide()
    else
        glo.udg_blockScroll[fc.getLocalPlayer().id] = true
        GUI.StatsDetailPanel:update()
        GUI.StatsDetailPanel:show()
    end

end
--stats_detail_panel_btn
------------------------------------------------------------------------------------
GUI.statsDetailPanelBtn = mt.create()
GUI.statsDetailPanelBtn:hide()
--------------------------------------------------------------------------------------
return mt
