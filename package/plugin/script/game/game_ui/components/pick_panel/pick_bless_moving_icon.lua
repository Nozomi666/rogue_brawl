--------------------------------------------------------------------------------------
class.pick_bless_moving_btn = extends(class.panel) {

    entryList = linked.create(),

    new = function(parent)
        -- 底图是一张黑色的图片 这个可以写死
        local panel = class.panel.new(parent, nil, 1, 1, 1, 1)
        -- 改变panel对象的类
        panel.__index = class.pick_bless_moving_btn
        panel:construct()
        panel:draw()
        panel:show()

        class.pick_bless_moving_btn.entryList:add(panel)

        return panel
    end,

    updateAllBoard = function()

        local barList = class.pick_bless_moving_btn.entryList
        local entry = barList:at(1)

        local removeList = {}
        while entry do
            entry:onUpdateFrame()
            if not entry.bUpdateFrame then
                table.insert(removeList, entry)
            end
            entry = barList:next(entry)
        end

        for i, entry in ipairs(removeList) do
            class.pick_bless_moving_btn.entryList:remove(entry)
            entry:destroy()
        end
        -- print('update all hpbar')
    end,

}
local mt = class.pick_bless_moving_btn
------------------------------------------------------------------------------------
function mt:measure()

    self.w1 = 80 * screenRatio
    self.h1 = 80

end
--------------------------------------------------------------------------------------
function mt:draw()
    self:measure()

    --------------------------------------------------------------------------------------
    -- 按钮
    self:set_control_size(self.w1, self.h1)
    --------------------------------------------------------------------------------------

end
--------------------------------------------------------------------------------------
function mt:construct()

    self:set_normal_image('BlessArt\\bingjingzhalie.tga')
    fc.setFramePos(self, ANCHOR.CENTER, GUI.CollectionBlessBtn.statsBtn, ANCHOR.CENTER, 0, 0)
end
--------------------------------------------------------------------------------------
function mt:onStartMove(art, startParentFrame)
    -- if self.bUpdateFrame then
    --     return
    -- end

    self.bUpdateFrame = true
    self.state = 'move'
    fc.setFramePos(self, ANCHOR.CENTER, startParentFrame, ANCHOR.CENTER, 0, 0)
    local startX, startY = self:get_real_position()
    -- gdebug('startX: %.0f, startY: %.0f', startX, startY)

    fc.setFramePos(self, ANCHOR.CENTER, GUI.CollectionBlessBtn.statsBtn, ANCHOR.CENTER, 0, 25)
    local endX, endY = self:get_real_position()
    -- gdebug('endX: %.0f, endY: %.0f', endX, endY)

    self.endX = endX
    self.endY = endY
    self.nowAlpha = 1
    self.endAlpha = 0

    self:set_normal_image(art)
    self:set_alpha(1)
    self:set_real_position(startX, startY)
    self:show()

end
--------------------------------------------------------------------------------------
function mt:onUpdateFrame()
    if self.state == 'move' then
        local nowX, nowY = self:get_real_position()
        local endX, endY = self.endX, self.endY
        if (math.abs(nowX - endX) + math.abs(nowY - endY) < 3) then
            self.state = 'fade'
            return
        end

        local lerpRate = 0.15
        local targetX = math.lerp(nowX, endX, lerpRate)
        local targetY = math.lerp(nowY, endY, lerpRate)
        self:set_real_position(targetX, targetY)
    elseif self.state == 'fade' then
        local targetAlpha = math.lerp(self.nowAlpha, self.endAlpha, 0.15)
        self:set_alpha(targetAlpha)
        self.nowAlpha = targetAlpha

        if targetAlpha <= 0.01 then
            self:hide()
            self.bUpdateFrame = false
            return
        end
    end

end
------------------------------------------------------------------------------------
-- GUI.PickBlessMovingIcon = mt.create()
-- GUI.PickBlessMovingIcon:hide()
--------------------------------------------------------------------------------------
return mt
