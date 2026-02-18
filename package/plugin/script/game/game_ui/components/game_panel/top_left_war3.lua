--------------------------------------------------------------------------------------
class.top_left_war3 = extends(class.panel) {

    new = function(parent)
        -- 底图是一张黑色的图片 这个可以写死
        local panel = class.panel.new(parent, [[]], 1, 1, 1, 1)
        -- 改变panel对象的类
        panel.__index = class.top_left_war3
        panel:construct()
        panel:draw()
        panel:show()
        return panel
    end,

}
local mt = class.top_left_war3
------------------------------------------------------------------------------------
function mt:measure()

    self.baseW = 1066
    self.baseH = 770
end
--------------------------------------------------------------------------------------
function mt:draw()
    self:measure()
    --------------------------------------------------------------------------------------
    local f10Btn = self.f10Btn
    f10Btn:set_control_size(180 * 0.8, 43 * 0.8)
    fc.setFramePos(f10Btn, ANCHOR.TOP_LEFT, MAIN_UI, ANCHOR.TOP_LEFT, 280, 2)
    --------------------------------------------------------------------------------------
    local f11Btn = self.f11Btn
    f11Btn:set_control_size(180 * 0.8, 43 * 0.8)
    fc.setFramePos(f11Btn, ANCHOR.TOP_LEFT, f10Btn, ANCHOR.TOP_RIGHT, 10, 0)
    --------------------------------------------------------------------------------------
    local f12Btn = self.f12Btn
    f12Btn:set_control_size(180 * 0.8, 43 * 0.8)
    fc.setFramePos(f12Btn, ANCHOR.TOP_LEFT, f11Btn, ANCHOR.TOP_RIGHT, 10, 0)
    --------------------------------------------------------------------------------------

end
--------------------------------------------------------------------------------------
function mt:construct()
    --------------------------------------------------------------------------------------
    local f10Btn = class.button.new(self, [[ui\misc\caidan2.tga]], 0, 0, 1, 1)
    f10Btn:set_active_image([[ui\misc\caidan1.tga]])
    self.f10Btn = f10Btn
    function f10Btn:on_button_clicked()
        japi.SendMessage(0x0100, KEY['F10'], 1)
        japi.SendMessage(0x0101, KEY['F10'], 1)
    end
    --------------------------------------------------------------------------------------
    local f11Btn = class.button.new(self, [[ui\misc\mengyou2.tga]], 0, 0, 1, 1)
    f11Btn:set_active_image([[ui\misc\mengyou1.tga]])
    self.f11Btn = f11Btn
    function f11Btn:on_button_clicked()
        japi.SendMessage(0x0100, KEY['F11'], 1)
        japi.SendMessage(0x0101, KEY['F11'], 1)
    end
    --------------------------------------------------------------------------------------
    local f12Btn = class.button.new(self, [[ui\misc\liaotian2.tga]], 0, 0, 1, 1)
    f12Btn:set_active_image([[ui\misc\liaotian1.tga]])
    self.f12Btn = f12Btn
    function f12Btn:on_button_clicked()
        japi.SendMessage(0x0100, KEY['F12'], 1)
        japi.SendMessage(0x0101, KEY['F12'], 1)
    end
    --------------------------------------------------------------------------------------
end
------------------------------------------------------------------------------------
GUI.UITopLeftWar3 = mt.create(MAIN_UI)
GUI.UITopLeftWar3:show()

-----------------------------------------------------e---------------------------------
return mt
