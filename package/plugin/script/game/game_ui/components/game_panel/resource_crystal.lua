--------------------------------------------------------------------------------------
class.resource_crystal = extends(class.panel) {

    new = function(parent)
        -- 底图是一张黑色的图片 这个可以写死
        local panel = class.panel.new(parent, nil, 1, 1, 1, 1)
        -- 改变panel对象的类
        panel.__index = class.resource_crystal
        panel:construct()
        panel:draw()
        panel:show()
        return panel
    end

}
local mt = class.resource_crystal
------------------------------------------------------------------------------------
function mt:measure()
    self.x1 = 0.155
    self.y1 = 0.005

    self.w1 = 28
    self.h1 = 28

    self.w2 = 145
    self.h2 = 22

    self.x2 = 340
    self.y2 = 13

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
    local icon = class.button.new(self, [[crystal_icon.tga]], 0, 0, 1, 1)
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
    local amt = math.floor(p:getStats(RES_LUMBER))

    if amt >= 100000 then
        amt = ConvertBigNumberToText(amt)
    end
    
    self.number:set_text(amt)
end
--------------------------------------------------------------------------------------
function mt:onShowTip()
    toolbox:tooltip('钻石', '钻石的获取途径较为稀有。')
    fc.setFramePos(toolbox, ANCHOR.TOP_LEFT, self.backHover, ANCHOR.BOT_LEFT, 0, 20)
    toolbox:show()

end
------------------------------------------------------------------------------------
GUI.ResourceCrystal = mt.create()
-- GUI.ResourceCrystal:hide()
--------------------------------------------------------------------------------------
return mt
