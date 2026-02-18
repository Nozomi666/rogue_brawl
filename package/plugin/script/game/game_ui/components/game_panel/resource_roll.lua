--------------------------------------------------------------------------------------
class.resource_roll = extends(class.panel) {

    new = function(parent)
        -- 底图是一张黑色的图片 这个可以写死
        local panel = class.panel.new(parent, nil, 1, 1, 1, 1)
        -- 改变panel对象的类
        panel.__index = class.resource_roll
        panel:construct()
        panel:draw()
        panel:show()
        return panel
    end

}
local mt = class.resource_roll
------------------------------------------------------------------------------------
function mt:measure()
    self.x1 = 0.188 + 0.105 * 2
    self.y1 = 0.002

    self.w1 = 34
    self.h1 = 34

    self.w2 = 145
    self.h2 = 22

    self.x2 = 720
    self.y2 = 10

end
--------------------------------------------------------------------------------------
function mt:draw()
    self:measure()

    local backHover = self.backHover
    backHover:set_control_size(self.w2, self.h2)
    backHover:set_alpha(0)
    fc.setFramePosPct(backHover, ANCHOR.TOP_LEFT, MAIN_UI, ANCHOR.TOP_CENTER, self.x1, self.y1)
    --------------------------------------------------------------------------------------
    -- 按钮
    local icon = self.icon
    icon:set_control_size(self.w1, self.h1)
    fc.setFramePosPct(icon, ANCHOR.TOP_LEFT, MAIN_UI, ANCHOR.TOP_CENTER, self.x1, self.y1)
    --------------------------------------------------------------------------------------
    local number = self.number
    number:set_control_size(100, 10)
    fc.setFramePos(number, ANCHOR.TOP_LEFT, MAIN_UI, ANCHOR.TOP_CENTER, self.x2, self.y2)

end
--------------------------------------------------------------------------------------
function mt:construct()

    --------------------------------------------------------------------------------------
    -- 图标
    local icon = class.button.new(self, [[reforge_stone_icon.tga]], 0, 0, 1, 1)
    self.icon = icon
    --------------------------------------------------------------------------------------
    -- 数字
    local number = self:add_text('0', 0, 0, 1, 1, 11, 'topright')
    self.number = number
    --------------------------------------------------------------------------------------
    -- 背景
    local backHover = class.button.new(self, [['']], 0, 0, 1, 1)
    self.backHover = backHover

    function backHover:on_button_mouse_enter()
        self.parent:onShowTip()
    end

    function backHover:on_button_mouse_leave()
        toolbox:hide()
    end

    reg:addToPool('ui_render_list', self)
end
--------------------------------------------------------------------------------------
function mt:updateBoard()
    local p = as.player:getLocalPlayer()
    local amt = math.floor(p:getStats(RES_ROLL))

    self.number:set_text(amt)
end
--------------------------------------------------------------------------------------
function mt:onShowTip()
    toolbox:tooltip('重铸点数', '重铸点数可以用来重铸装备。')
    fc.setFramePos(toolbox, ANCHOR.TOP_LEFT, self.backHover, ANCHOR.BOT_LEFT, -150, 20)
    toolbox:show()

end
------------------------------------------------------------------------------------
GUI.ResourceRoll = mt.create()
GUI.ResourceRoll:hide()
--------------------------------------------------------------------------------------
return mt
