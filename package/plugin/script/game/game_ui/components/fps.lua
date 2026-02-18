
--------------------------------------------------------------------------------------
class.fps = extends(class.panel) {

    new = function(parent)
        -- 底图是一张黑色的图片 这个可以写死
        local panel = class.panel.new(parent, '', 1, 1, 1, 1)
        -- 改变panel对象的类
        panel.__index = class.fps
        panel:construct()
        panel:draw()
        panel:show()
        return panel
    end,

}
local mt = class.fps
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
    fc.setFramePosPct(self, ANCHOR.TOP_LEFT, MAIN_UI, ANCHOR.TOP_CENTER, 0, 0)

    --------------------------------------------------------------------------------------
    -- 文本
    local fpsText = self.fpsText
    fpsText:set_control_size(200, 10)
    fc.setFramePos(fpsText, ANCHOR.CENTER, MAIN_UI, ANCHOR.TOP_CENTER, 0, 100)


end
--------------------------------------------------------------------------------------
function mt:construct()
    
    --------------------------------------------------------------------------------------
    local fpsText = self:add_text('Fps: ', 0, 0, 1, 1, 11, 'center')
    self.fpsText = fpsText

end
--------------------------------------------------------------------------------------
function mt:update()
    local fps = japi.GetFps()
    self.fpsText:set_text(str.format('|cffffff00Fps: %.2f|r', fps))
end


------------------------------------------------------------------------------------
GUI.FPS = mt.create()
GUI.FPS:hide()
--------------------------------------------------------------------------------------
return mt
