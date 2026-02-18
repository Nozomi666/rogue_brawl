--------------------------------------------------------------------------------------
class.revive_time = extends(class.panel) {

    new = function(parent)
        -- 底图是一张黑色的图片 这个可以写死
        local panel = class.panel.new(parent, [[empty.blp]], 1, 1, 1, 1)
        -- 改变panel对象的类
        panel.__index = class.revive_time
        panel:construct()
        panel:draw()
        panel:show()
        return panel
    end

}
local mt = class.revive_time
------------------------------------------------------------------------------------
function mt:measure()
    self.x1 = 0
    self.y1 = 0

end
--------------------------------------------------------------------------------------
function mt:draw()
    self:measure()

    self.alphaVal = 0.01
    self.cd = 0
    self:set_control_size(1, 1)
    fc.setFramePosPct(self, ANCHOR.CENTER, MAIN_UI, ANCHOR.CENTER, 0, 0)

    --------------------------------------------------------------------------------------
    -- 数字
    local number = self.number
    number:set_control_size(1, 1)
    fc.setFramePos(number, ANCHOR.TOP_LEFT, self, ANCHOR.CENTER, self.x1, self.y1)

end
--------------------------------------------------------------------------------------
function mt:construct()

    --------------------------------------------------------------------------------------
    -- 数字
    local number = self:add_text('|cffffff0010.0|r', 0, 0, 1, 1, 16, 'center')
    self.number = number

end
--------------------------------------------------------------------------------------
function mt:setTime(word)
    self.number:set_text(word)
end
--------------------------------------------------------------------------------------
function mt:update(immediate)
    -- local self = GUI.DashCd
    -- if self.alphaVal <= 0 then
    --     return
    -- end
    -- local deltaTime = FRAME_INTERVAL_UI
    -- if not immediate then
    --     self.alphaVal = math.max(0, self.alphaVal - deltaTime)
    --     self.cd = math.max(0, self.cd - deltaTime)
    -- end

    -- self:set_alpha(self.alphaVal)
    -- self.number:set_text(str.format('%.1f', self.cd))

end
------------------------------------------------------------------------------------
GUI.ReviveTime = mt.create()
GUI.ReviveTime:hide()
--------------------------------------------------------------------------------------
return mt
