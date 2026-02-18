--------------------------------------------------------------------------------------
class.custom_pickbox = extends(class.panel) {

    new = function(parent)
        -- 底图是一张黑色的图片 这个可以写死
        local panel = class.panel.new(parent, [[]], 1, 1, 1, 1)
        -- 改变panel对象的类
        panel.__index = class.custom_pickbox
        panel:construct()
        panel:draw()
        panel:show()
        return panel
    end,

}
local mt = class.custom_pickbox
------------------------------------------------------------------------------------
function mt:measure()

    self.baseW = 551
end
--------------------------------------------------------------------------------------
function mt:draw()
    self:measure()
    --------------------------------------------------------------------------------------
    fc.setFramePos(self, ANCHOR.CENTER, MAIN_UI, ANCHOR.CENTER, 0, 0)

    --------------------------------------------------------------------------------------
    self.topPart:set_control_size(self.baseW, 52)
    fc.setFramePos(self.topPart, ANCHOR.CENTER, self, ANCHOR.TOP_CENTER, 0, -300)
    --------------------------------------------------------------------------------------
    self.midPart:set_control_size(self.baseW, 400)
    fc.setFramePos(self.midPart, ANCHOR.TOP_CENTER, self.topPart, ANCHOR.BOT_CENTER, 0, 0)
    --------------------------------------------------------------------------------------
    self.botPart:set_control_size(self.baseW, 22)
    fc.setFramePos(self.botPart, ANCHOR.TOP_CENTER, self.midPart, ANCHOR.BOT_CENTER, 0, 0)
    --------------------------------------------------------------------------------------
    self.title:set_control_size(1, 1)
    fc.setFramePos(self.title, ANCHOR.TOP_LEFT, self.topPart, ANCHOR.CENTER, 0, 30)

    for i = 1, 10 do
        local btn = self.btnList[i]
        btn:set_control_size(551, 57)
        fc.setFramePos(btn, ANCHOR.CENTER, self.topPart, ANCHOR.TOP_CENTER, 0, 60 + (i - 1) * 80)
        btn.tip:set_control_size(1, 1)
        fc.setFramePos(btn.tip, ANCHOR.TOP_LEFT, btn, ANCHOR.CENTER, 0, 0)

    end
    --------------------------------------------------------------------------------------
    -- local backgroundCoverBtn = self.backgroundCoverBtn
    -- backgroundCoverBtn:set_control_size(self.baseW, self.baseH)
    -- backgroundCoverBtn:set_alpha(0)
    -- fc.setFramePos(backgroundCoverBtn, ANCHOR.CENTER, self, ANCHOR.CENTER, 0, 0)
    --------------------------------------------------------------------------------------

    --------------------------------------------------------------------------------------

end
--------------------------------------------------------------------------------------
function mt:construct()
    --------------------------------------------------------------------------------------
    self.backgroundCoverBtn = class.button.new(self, 'black.blp', 0, 0, 1, 1)
    --------------------------------------------------------------------------------------
    self.topPart = class.panel.new(self, [[ui\CustomPickBox\up.tga]], 1, 1, 1, 0.1)
    self.midPart = class.panel.new(self, [[ui\CustomPickBox\mid.tga]], 1, 1, 1, 0.1)
    self.botPart = class.panel.new(self, [[ui\CustomPickBox\bot.tga]], 1, 1, 1, 0.1)
    self.midPart:hide()
    --------------------------------------------------------------------------------------
    self.title = class.text.new(self, '选择框标题', 0, 0, 1, 1, 12, 'center')
    --------------------------------------------------------------------------------------
    self.btnList = {}
    for i = 1, 10 do
        local btn = class.button.new(self, [[ui\CustomPickBox\mid_off.blp]], 0, 0, 1, 1)
        table.insert(self.btnList, btn)
        btn.tip = class.text.new(btn, '选择框按钮xxxxx', 0, 0, 1, 1, 12, 'center')

        btn.sync_key = 'custom_pickbox_btn' .. i
        btn.btnId = i

        btn:set_hover_image([[ui\CustomPickBox\mid.blp]])

        function btn:on_sync_button_clicked(player)
            self.parent:onClickOptionBtn(player.handle, btn.btnId)
        end
    end
    --------------------------------------------------------------------------------------
end
--------------------------------------------------------------------------------------
function mt:updateTitle()
    local player = fc.getLocalPlayer()
    self.title:set_text(player.pickBox.title or '')
end
--------------------------------------------------------------------------------------
function mt:updateBtnInfo()

    local player = fc.getLocalPlayer()
    if not player.pickBox then
        return
    end
    local pickBoxBtnList = player.pickBox.btnList

    local num = #pickBoxBtnList
    if num > 10 then
        num = 10
    end

    if num == 0 then
        self:hide()
        return
    end

    self:show()

    self.midPart:set_control_size(self.baseW, 0 + num * 57)
    fc.setFramePos(self.midPart, ANCHOR.CENTER, MAIN_UI, ANCHOR.CENTER, 0, -80)
    --------------------------------------------------------------------------------------
    fc.setFramePos(self.topPart, ANCHOR.BOT_CENTER, self.midPart, ANCHOR.TOP_CENTER, 0, 0)
    fc.setFramePos(self.botPart, ANCHOR.TOP_CENTER, self.midPart, ANCHOR.BOT_CENTER, 0, 0)
    fc.setFramePos(self.title, ANCHOR.TOP_LEFT, self.topPart, ANCHOR.CENTER, 0, 7)

    for i = 1, 10 do
        local btn = self.btnList[i]
        if i <= num then
            btn:show()
            fc.setFramePos(btn, ANCHOR.TOP_CENTER, self.topPart, ANCHOR.BOT_CENTER, 0, 0 + (i - 1) * 57)
            btn.tip:set_text(pickBoxBtnList[i].tip or '')
            self.title:set_text(player.pickBox.title or '')
            fc.setFramePos(btn.tip, ANCHOR.TOP_LEFT, btn, ANCHOR.CENTER, 0, 0)
        else
            btn:hide()
        end
    end

end
--------------------------------------------------------------------------------------
function mt:onClickOptionBtn(pj, btnId)
    local player = as.player:pj2t(pj)
    local pickBoxBtnList = player.pickBox.btnList
    local entry = pickBoxBtnList[btnId]
    if not entry then
        if player:isLocal() then
            self:hide()
        end
        return
    end

    player.pickBox:customUIBtnClicked(btnId)

end
------------------------------------------------------------------------------------
GUI.CustomPickbox = mt.create(MAIN_UI)
GUI.CustomPickbox:hide()
--------------------------------------------------------------------------------------
-- if gm.started then
--     GUI.CustomPickbox:updateBtnInfo()
-- end

-- GUI.CustomPickbox:updateBtnInfo()

-----------------------------------------------------e---------------------------------
return mt
