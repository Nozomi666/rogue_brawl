--------------------------------------------------------------------------------------
class.pick_bless_btn = extends(class.panel) {

    new = function(parent)
        -- 底图是一张黑色的图片 这个可以写死
        local panel = class.panel.new(parent, nil, 1, 1, 1, 1)
        -- 改变panel对象的类
        panel.__index = class.pick_bless_btn
        panel:construct()
        panel:draw()
        panel:show()
        return panel
    end

}
local mt = class.pick_bless_btn
------------------------------------------------------------------------------------
function mt:measure()
    self.x1 = 0
    self.y1 = 0.24

    self.w1 = 60 * screenRatio
    self.h1 = 60

    self.x2 = -16 * screenRatio
    self.y2 = -5

end
--------------------------------------------------------------------------------------
function mt:draw()
    self:measure()

    --------------------------------------------------------------------------------------
    -- 按钮
    local statsBtn = self.statsBtn
    statsBtn:set_control_size(self.w1 * statsBtn.sizeRate, self.h1 * statsBtn.sizeRate)
    fc.setFramePosPct(statsBtn, ANCHOR.CENTER, MAIN_UI, ANCHOR.CENTER, self.x1, self.y1)
    --------------------------------------------------------------------------------------
    local statsNum = self.statsNum
    statsNum:set_control_size(100, 10)
    fc.setFramePos(statsNum, ANCHOR.TOP_LEFT, statsBtn, ANCHOR.CENTER, statsNum.x2, statsNum.y2)
    statsNum:set_size(statsNum.fSize, 'resource\\UI\\FZDHTJW.TTF')

end
--------------------------------------------------------------------------------------
function mt:construct()

    --------------------------------------------------------------------------------------
    -- 按钮
    local statsBtn = class.button.new(self, [[cifuxuanze1.tga]], 0, 0, 1, 1)
    statsBtn.sizeRate = 1
    self.statsBtn = statsBtn
    statsBtn.sync_key = 'pick_bless_btn'
    -- statsBtn:set_hover_image([[cifudi.tga]])
    statsBtn:set_active_image([[cifuxuanze2.tga]])
    --------------------------------------------------------------------------------------
    -- 角标
    local totalCountTexture = class.texture:builder{
        parent = statsBtn,
        normal_image = [[zhuanjingxuanze3.tga]],
        x = 17,
        y = 33,
        w = 25,
        h = 25
    }
    --------------------------------------------------------------------------------------
    -- 数字
    local statsNum = statsBtn:add_text('1', 0, 0, 1, 1, 6, 'center')
    statsNum:set_size(2, 'resource\\UI\\FZDHTJW.TTF')
    self.statsNum = statsNum
    self.statsNum.x2 = -50.5 * screenRatio
    self.statsNum.y2 = 11
    self.statsNum.fSize = 1.4
    --------------------------------------------------------------------------------------
    function statsBtn:on_sync_button_clicked(player)
        self.parent:onClick(player.handle)
    end

    function statsBtn:on_button_mouse_enter()
        self.parent:onShowTip()
    end

    function statsBtn:on_button_mouse_leave()
        toolbox:hide()
    end

    function statsBtn:on_button_mousedown()
        statsBtn.sizeRate = 0.9
        -- self.parent.statsNum.x2 = -18 * screenRatio
        -- self.parent.statsNum.y2 = -5
        self.parent.statsNum.fSize = 1.2
        self.parent:draw()
    end

    function statsBtn:on_button_mouseup()
        statsBtn.sizeRate = 1
        -- self.parent.statsNum.x2 = -16 * screenRatio
        -- self.parent.statsNum.y2 = -5
        self.parent.statsNum.fSize = 1.4
        self.parent:draw()
    end

    reg:addToPool('ui_render_list', self)
end
--------------------------------------------------------------------------------------
function mt:updateBoard()
    local blessPointNum = fc.getLocalPlayer().blessManager.blessPointNum
    self.statsNum:set_text(str.format('%d', blessPointNum))
    if blessPointNum > 0 then
        self:show()
    else
        self:hide()
        toolbox:hide()
    end
end
--------------------------------------------------------------------------------------
function mt:onShowTip()
    toolbox:tooltip('赐福奖励', '点击选择一项赐福奖励。|n|n|cffdcffba每次升级时获得一点|r')
    fc.setFramePos(toolbox, ANCHOR.BOT_LEFT, self.statsBtn, ANCHOR.TOP_LEFT, 20, -5)
    toolbox:show()
end
--------------------------------------------------------------------------------------
function mt:onClick(pj)
    local p = as.player:pj2t(pj)

    p:completeTutorial(1, false)
    p.hero:drawBless()
end
------------------------------------------------------------------------------------
GUI.PickBlessBtn = mt.create()
GUI.PickBlessBtn:hide()
-- if localEnv then
--     GUI.PickBlessBtn:show()
-- end
--------------------------------------------------------------------------------------
return mt
