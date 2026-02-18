
--------------------------------------------------------------------------------------
class.hp_info = extends(class.panel) {

    new = function(parent)
        -- 底图是一张黑色的图片 这个可以写死
        local panel = class.panel.new(parent, '', 1, 1, 1, 1)
        -- 改变panel对象的类
        panel.__index = class.hp_info
        panel:construct()
        panel:draw()
        panel:show()
        return panel
    end,

}
local mt = class.hp_info
------------------------------------------------------------------------------------
function mt:measure()
    self.w1 = 180
    self.h1 = 20


end
--------------------------------------------------------------------------------------
function mt:draw()
    self:measure()

    --------------------------------------------------------------------------------------
    -- 主面板
    self:set_control_size(self.w1, self.h1)
    fc.setFramePosPct(self, ANCHOR.TOP_LEFT, MAIN_UI, ANCHOR.CENTER, -0.197, 0.443)

    --------------------------------------------------------------------------------------
    -- 文本
    local hpText = self.hpText
    hpText:set_control_size(200, 10)
    fc.setFramePos(hpText, ANCHOR.TOP_LEFT, self, ANCHOR.TOP_LEFT, -12, 7)


end
--------------------------------------------------------------------------------------
function mt:construct()
    
    --------------------------------------------------------------------------------------
    local hpText = self:add_text('20000 / 20000', 0, 0, 1, 1, 11, 'center')
    self.hpText = hpText

    reg:addToPool('ui_render_list', self)
end


------------------------------------------------------------------------------------
GUI.HpInfo = mt.add_child(GUI.UnitInfo)
GUI.HpInfo:show()
--------------------------------------------------------------------------------------
return mt
