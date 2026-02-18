-- 隐藏旧攻击防御
local atkFrame = dz.DzSimpleTextureFindByName("InfoPanelIconBackdrop", 0)
dz.DzFrameSetAbsolutePoint(atkFrame, 4, -0.01, -0.01)
local defFrame = dz.DzSimpleTextureFindByName("InfoPanelIconBackdrop", 2)
dz.DzFrameSetAbsolutePoint(defFrame, 4, -0.01, -0.01)
-- 隐藏英雄三围面板
local frame = dz.DzSimpleTextureFindByName("InfoPanelIconHeroIcon", 6)
dz.DzFrameSetAbsolutePoint(frame, 4, -0.01, -0.01)

local frame = dz.DzFrameGetTooltip()
dz.DzFrameSetAbsolutePoint(frame, 8, 0.8, 0.16)
-- dz.DzFrameSetAbsolutePoint(frame, 8, -0.01, -0.01)
-- dz.DzFrameSetAbsolutePoint(frame, 8, 0.8, 0.16)

--------------------------------------------------------------------------------------
class.unit_info = extends(class.panel) {

    new = function(parent)
        -- 底图是一张黑色的图片 这个可以写死
        local panel = class.panel.new(parent, nil, 1, 1, 1, 1)
        -- 改变panel对象的类
        panel.__index = class.unit_info
        panel:construct()
        panel:draw()
        panel:show()
        return panel
    end

}
local mt = class.unit_info
------------------------------------------------------------------------------------
function mt:measure()
    self.w1 = 66 * screenRatio
    self.h1 = 66

    self.x2 = 25 * screenRatio
    self.y2 = -18

    self.x3 = 35 * screenRatio
    self.y3 = 3

    self.x4 = 0
    self.y4 = 56

    self.y5 = -56

    self.x6 = 10
    self.y6 = 22

    self.y7 = 50

end
--------------------------------------------------------------------------------------
function mt:draw()
    self:measure()

    --------------------------------------------------------------------------------------
    -- 名称
    local unitName = self.unitName
    unitName:set_control_size(100, 10)
    fc.setFramePosPct(unitName, ANCHOR.CENTER, MAIN_UI, ANCHOR.CENTER, 0.0, 0.322)

    --------------------------------------------------------------------------------------
    -- 攻击属性
    local atkIcon = self.atkIcon
    atkIcon:set_control_size(self.w1, self.h1)
    fc.setFramePosPct(atkIcon, ANCHOR.CENTER, MAIN_UI, ANCHOR.CENTER, -0.08, 0.39)
    --------------------------------------------------------------------------------------
    local atkTitle = self.atkTitle
    atkTitle:set_control_size(100, 10)
    fc.setFramePos(atkTitle, ANCHOR.TOP_LEFT, atkIcon, ANCHOR.CENTER, self.x2, self.y2)
    --------------------------------------------------------------------------------------
    local atkTip = self.atkTip
    atkTip:set_control_size(100, 10)
    fc.setFramePos(atkTip, ANCHOR.TOP_LEFT, atkIcon, ANCHOR.CENTER, self.x3, self.y3)

    --------------------------------------------------------------------------------------
    -- 防御属性
    local defIcon = self.defIcon
    defIcon:set_control_size(self.w1, self.h1)
    fc.setFramePos(defIcon, ANCHOR.CENTER, atkIcon, ANCHOR.CENTER, self.x4, self.y4)
    --------------------------------------------------------------------------------------
    local defTitle = self.defTitle
    defTitle:set_control_size(100, 10)
    fc.setFramePos(defTitle, ANCHOR.TOP_LEFT, defIcon, ANCHOR.CENTER, self.x2, self.y2)
    --------------------------------------------------------------------------------------
    local defTip = self.defTip
    defTip:set_control_size(100, 10)
    fc.setFramePos(defTip, ANCHOR.TOP_LEFT, defIcon, ANCHOR.CENTER, self.x3, self.y3)

    --------------------------------------------------------------------------------------
    -- 英雄属性
    local heroIcon = self.heroIcon
    heroIcon:set_control_size(self.w1, self.h1)
    fc.setFramePosPct(heroIcon, ANCHOR.CENTER, MAIN_UI, ANCHOR.CENTER, 0.015, 0.412)
    --------------------------------------------------------------------------------------
    local strTitle = self.strTitle
    strTitle:set_control_size(100, 10)
    fc.setFramePos(strTitle, ANCHOR.TOP_LEFT, heroIcon, ANCHOR.CENTER, self.x2, self.y5)
    --------------------------------------------------------------------------------------
    local strTip = self.strTip
    strTip:set_control_size(100, 10)
    fc.setFramePos(strTip, ANCHOR.TOP_LEFT, strTitle, ANCHOR.TOP_LEFT, self.x6, self.y6)
    --------------------------------------------------------------------------------------
    local agiTitle = self.agiTitle
    agiTitle:set_control_size(100, 10)
    fc.setFramePos(agiTitle, ANCHOR.TOP_LEFT, strTitle, ANCHOR.TOP_LEFT, 0, self.y7)
    --------------------------------------------------------------------------------------
    local agiTip = self.agiTip
    agiTip:set_control_size(100, 10)
    fc.setFramePos(agiTip, ANCHOR.TOP_LEFT, agiTitle, ANCHOR.TOP_LEFT, self.x6, self.y6)
    --------------------------------------------------------------------------------------
    local intTitle = self.intTitle
    intTitle:set_control_size(100, 10)
    fc.setFramePos(intTitle, ANCHOR.TOP_LEFT, agiTitle, ANCHOR.TOP_LEFT, 0, self.y7)
    --------------------------------------------------------------------------------------
    local intTip = self.intTip
    intTip:set_control_size(100, 10)
    fc.setFramePos(intTip, ANCHOR.TOP_LEFT, intTitle, ANCHOR.TOP_LEFT, self.x6, self.y6)

    --------------------------------------------------------------------------------------
    local expBar = self.expBar
    fc.setFramePos(expBar, ANCHOR.CENTER, heroIcon, ANCHOR.TOP_LEFT, 8, -40)

    --------------------------------------------------------------------------------------
    local expTip = self.expTip
    expTip:set_control_size(100, 10)
    fc.setFramePos(expTip, ANCHOR.TOP_LEFT, heroIcon, ANCHOR.TOP_LEFT, -40, -44)

end
--------------------------------------------------------------------------------------
function mt:construct()

    --------------------------------------------------------------------------------------
    -- 名字
    local unitName = self:add_text('单位名称', 0, 0, 1, 1, 14, 'center')
    self.unitName = unitName

    --------------------------------------------------------------------------------------
    -- 攻击属性
    local atkIcon = class.button.new(self, [[IcoAtk.tga]], 0, 0, 1, 1)
    self.atkIcon = atkIcon
    --------------------------------------------------------------------------------------
    local atkTitle = self:add_text('|cffffcc00攻击力：|r(+4002%)', 0, 0, 1, 1, 10, 'topleft')
    self.atkTitle = atkTitle
    --------------------------------------------------------------------------------------
    local atkTip = self:add_text('1000万 |cff51ff00+1500亿|r', 0, 0, 1, 1, 10, 'topleft')
    self.atkTip = atkTip

    --------------------------------------------------------------------------------------
    -- 防御属性
    local defIcon = class.button.new(self, [[IcoDef.tga]], 0, 0, 1, 1)
    self.defIcon = defIcon
    --------------------------------------------------------------------------------------
    local defTitle = self:add_text('|cffffcc00护甲：|r(+225%)', 0, 0, 1, 1, 10, 'topleft')
    self.defTitle = defTitle
    --------------------------------------------------------------------------------------
    local defTip = self:add_text('145 |cff51ff00+88|r', 0, 0, 1, 1, 10, 'topleft')
    self.defTip = defTip

    --------------------------------------------------------------------------------------
    -- 英雄属性
    local heroInfo = class.panel.new(self, nil, 0, 0, 1, 1)
    self.heroInfo = heroInfo

    --------------------------------------------------------------------------------------
    local heroIcon = class.button.new(heroInfo, [[IcoStr.tga]], 0, 0, 1, 1)
    self.heroIcon = heroIcon
    --------------------------------------------------------------------------------------
    local strTitle = heroInfo:add_text('|cffffcc00力量：|r', 0, 0, 1, 1, 10, 'topleft')
    self.strTitle = strTitle
    --------------------------------------------------------------------------------------
    local strTip = heroInfo:add_text('1000万 |cff51ff00+1500亿|r', 0, 0, 1, 1, 10, 'topleft')
    self.strTip = strTip
    --------------------------------------------------------------------------------------
    local agiTitle = heroInfo:add_text('|cffffcc00敏捷：|r', 0, 0, 1, 1, 10, 'topleft')
    self.agiTitle = agiTitle
    --------------------------------------------------------------------------------------
    local agiTip = heroInfo:add_text('1330万 |cff51ff00+1500亿|r', 0, 0, 1, 1, 10, 'topleft')
    self.agiTip = agiTip
    --------------------------------------------------------------------------------------
    local intTitle = heroInfo:add_text('|cffffcc00智力：|r', 0, 0, 1, 1, 10, 'topleft')
    self.intTitle = intTitle
    --------------------------------------------------------------------------------------
    local intTip = heroInfo:add_text('5400万 |cff51ff00+1500亿|r', 0, 0, 1, 1, 10, 'topleft')
    self.intTip = intTip

    --------------------------------------------------------------------------------------
    -- expBar bar
    local base = [[arch_hero_exp_base.tga]]
    local fill = [[arch_hero_exp_bar.tga]]
    local w = 380 * screenRatio
    local h = 25
    local textSize = 9

    local expBar = class.progressBar.add_child(heroInfo, base, fill, w, h, w - 3, h - 3)
    self.expBar = expBar
    expBar:setVal(0, 0)

    --------------------------------------------------------------------------------------
    -- exp tip
    local expTip = heroInfo:add_text('等级1 0/200', 0, 0, 1, 1, 11, 'center')
    self.expTip = expTip

    -- self.showInfoCount = 0
    self.atkInfoOn = false
    self.defInfoOn = false
    function atkIcon:on_button_mouse_enter()
        self.parent:showAtkInfo()
        self.parent.atkInfoOn = true
    end

    function atkIcon:on_button_mouse_leave()
        self.parent.atkInfoOn = false
        if (not self.parent.atkInfoOn) and (not self.parent.defInfoOn) then
            toolbox:hide()
        end
    end

    function defIcon:on_button_mouse_enter()
        self.parent.defInfoOn = true
        self.parent:showDefInfo()
    end

    function defIcon:on_button_mouse_leave()
        self.parent.defInfoOn = false
        if (not self.parent.atkInfoOn) and (not self.parent.defInfoOn) then
            toolbox:hide()
        end
    end

    function heroIcon:on_button_mouse_enter()
        self.parent.parent.heroInfoOn = true
        self.parent.parent:showHeroInfo()
    end

    function heroIcon:on_button_mouse_leave()
        self.parent.parent.heroInfoOn = false
        if (not self.parent.parent.atkInfoOn) and (not self.parent.parent.defInfoOn) then
            toolbox:hide()
        end
    end

    reg:addToPool('ui_render_list', self)
end
------------------------------------------------------------------------------------
GUI.UnitInfo = mt.create()
GUI.UnitInfo:show()
--------------------------------------------------------------------------------------
return mt
