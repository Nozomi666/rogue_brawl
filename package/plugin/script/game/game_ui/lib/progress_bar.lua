--------------------------------------------------------------------------------------
class.progressBar = extends(class.panel) {

    new = function(parent, base, fill, w, h, innerW, innerH)

        local height = 200

        local panel = class.panel.new(parent, base, 0, 0, w, h)
        -- 改变panel对象的类
        panel.__index = class.progressBar

    

        if innerW and innerH then
            panel.fill = panel:add_texture(fill, 0, 0, innerW, innerH)
            panel.w = innerW
            panel.h = innerH

            fc.setFramePos(panel.fill, ANCHOR.CENTER, panel, ANCHOR.CENTER, 0, 0)
        else
            panel.fill = panel:add_texture(fill, 0, 0, w, h)
            panel.w = w
            panel.h = h
        end


        panel.nowRate = 0.001

        return panel
    end,

}
--------------------------------------------------------------------------------------
local mt = class.progressBar
--------------------------------------------------------------------------------------
function mt:resizeWindow(w, h)
    local panel = self
    panel:set_control_size(w, h)
    panel.fill:set_control_size(w * self.nowRate, h)

    panel.w = w
    panel.h = h

end
--------------------------------------------------------------------------------------
function mt:setVal(value, max_value)
    local rate = 0
    if max_value > 0 then
        rate = value / max_value
    end

    rate = math.max(0.001, rate)
    self.nowRate = rate

    -- 改变图层尺寸 为进度值百分比
    self.fill:set_control_size(self.w * rate, self.h)
end
--------------------------------------------------------------------------------------
function mt:setFull(word)
    local rate = 1
    -- 改变图层尺寸 为进度值百分比
    self.fill:set_control_size(self.w * rate, self.h)
end
--------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------
