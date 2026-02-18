--------------------------------------------------------------------------------------
class.multiUseRemoveButton = extends(class.panel) {

    new = function(parent)
        -- 底图是一张黑色的图片 这个可以写死
        local panel = class.panel.new(parent, nil, 1, 1, 1, 1)
        -- 改变panel对象的类
        panel.__index = class.multiUseRemoveButton
        panel:construct()
        panel:draw()
        panel:show()
        return panel
    end

}
local mt = class.multiUseRemoveButton
------------------------------------------------------------------------------------
function mt:measure()
    self.x1 = -0.02
    self.y1 = 0.057

    self.w1 = 32
    self.h1 = 24

end
--------------------------------------------------------------------------------------
function mt:draw()
    self:measure()

    -------------------------------------------------------------------------------------
    -- 按钮
    local dcb = self.dcb
    dcb:set_control_size(self.w1, self.h1)
    fc.setFramePosPct(dcb, ANCHOR.TOP_LEFT, MAIN_UI, ANCHOR.TOP_RIGHT, self.x1, self.y1)
end
--------------------------------------------------------------------------------------
function mt:construct()

    --------------------------------------------------------------------------------------
    -- 按钮
    local dcb = class.button.new(self, [[multi_hide1.tga]], 0, 0, 1, 1)
    self.dcb = dcb
    dcb.sync_key = 'multiUseRemoveButton'
    dcb:set_hover_image([[multi_hide2.tga]])
    --dcb:set_active_image([[shanghaitongji2.tga]])

    function dcb:on_sync_button_clicked(player)
        self.parent:onClick(player.handle)
    end
end
--------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------
function mt:onClick(pj)
    local p = as.player:pj2t(pj)
    if p:isLocal() then
        GUI.multiUsePanel:hide()
        GUI.multiUseRemoveButton:hide()
        GUI.multiUseButton:show()
    end
end
--------------------------------------------------------------------------------------
GUI.multiUseRemoveButton = mt.create()
GUI.multiUseRemoveButton:show()

--------------------------------------------------------------------------------------
return mt