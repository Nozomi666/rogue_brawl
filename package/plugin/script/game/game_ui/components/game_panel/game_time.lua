--------------------------------------------------------------------------------------
class.game_time = extends(class.panel) {

    new = function(parent)
        -- 底图是一张黑色的图片 这个可以写死
        local panel = class.panel.new(parent, nil, 1, 1, 1, 1)
        -- 改变panel对象的类
        panel.__index = class.game_time
        panel:construct()
        panel:draw()
        panel:show()
        return panel
    end,

}
local mt = class.game_time
------------------------------------------------------------------------------------
function mt:measure()
    self.x1 = -0.15
    self.y1 = 0.06

end
--------------------------------------------------------------------------------------
function mt:draw()
    self:measure()
    --------------------------------------------------------------------------------------
    -- 敌人数量
    local gameTimeTip = self.gameTimeTip
    gameTimeTip:set_control_size(100, 10)
    fc.setFramePosPct(gameTimeTip, ANCHOR.TOP_LEFT, MAIN_UI, ANCHOR.TOP_RIGHT, self.x1, self.y1)

end
--------------------------------------------------------------------------------------
function mt:construct()
    --------------------------------------------------------------------------------------
    -- 敌人数量
    --------------------------------------------------------------------------------------
    local gameTimeTip = self:add_text('|cffffcc00游戏时间：|r0 分 0 秒', 0, 0, 1, 1, 16, 'topleft')
    self.gameTimeTip = gameTimeTip

    reg:addToPool('ui_render_list', self)
end
--------------------------------------------------------------------------------------
function mt:updateBoard(msg)
    self.gameTimeTip:set_text(msg)
end
------------------------------------------------------------------------------------
GUI.GameTime = mt.create()
GUI.GameTime:show()
--------------------------------------------------------------------------------------
return mt
