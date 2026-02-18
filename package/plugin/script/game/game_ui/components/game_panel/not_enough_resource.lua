--------------------------------------------------------------------------------------
class.not_enough_resource = extends(class.panel) {

    new = function(parent)
        -- 底图是一张黑色的图片 这个可以写死
        local panel = class.panel.new(parent, [[not_enough_gold.tga]], 1, 1, 1, 1)
        -- 改变panel对象的类
        panel.__index = class.not_enough_resource
        panel:construct()
        panel:draw()
        panel:show()
        return panel
    end,

}
local mt = class.not_enough_resource
------------------------------------------------------------------------------------
function mt:measure()
    self.x1 = -1
    self.y1 = 0

    self.w1 = 180
    self.h1 = 60

end
--------------------------------------------------------------------------------------
function mt:draw()
    self:measure()

    self:set_control_size(self.w1, self.h1)
    fc.setFramePosPct(self, ANCHOR.CENTER, MAIN_UI, ANCHOR.CENTER, 0, 0)

end
--------------------------------------------------------------------------------------
function mt:construct()

end
--------------------------------------------------------------------------------------
function mt:updateFrame(path, btnId)
    self:set_normal_image(path)
    local btnFrame = GUI.SkillBtn.btnFrame[btnId]
    self.btnFrame = btnFrame
    self.phaseFading = true
    self.fadeAlpha = 1
    self.offSetVal = 50
    self.offSetDelta = -3
    self.offSetX = 0
    self:show()
    fc.setFramePos(self, ANCHOR.BOT_CENTER, btnFrame, ANCHOR.TOP_CENTER, self.offSetX, self.offSetVal)
end
--------------------------------------------------------------------------------------
function mt:updateFrameGrowEquip(btnFrame)
    self:set_normal_image(ART_NOT_ENOUGH_GOLD)
    self.btnFrame = btnFrame
    self.phaseFading = true
    self.fadeAlpha = 1
    self.offSetVal = 50
    self.offSetDelta = -3
    self.offSetX = 0
    self:show()
    fc.setFramePos(self, ANCHOR.BOT_CENTER, self.btnFrame, ANCHOR.TOP_CENTER, self.offSetX, self.offSetVal)
end
------------------------------------------------------------------------------------
GUI.NotEnoughResource = mt.create()
GUI.NotEnoughResource:hide()
--------------------------------------------------------------------------------------
return mt
