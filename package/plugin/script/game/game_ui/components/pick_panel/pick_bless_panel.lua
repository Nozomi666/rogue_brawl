--------------------------------------------------------------------------------------
class.pick_bless_panel = extends(class.panel) {

    new = function(parent)
        -- 底图是一张黑色的图片 这个可以写死
        local panel = class.panel.new(parent, [[bless_frame_background.tga]], 1, 1, 1, 1)
        -- 改变panel对象的类
        panel.__index = class.pick_bless_panel
        panel:construct()
        panel:draw()
        return panel
    end
}
local mt = class.pick_bless_panel
------------------------------------------------------------------------------------
function mt:measure()

    self.x1 = 0
    self.y1 = 0.16

    self.w1 = 420 * screenRatio * 1
    self.h1 = 76 * 1

    self.w2 = 80 * screenRatio
    self.h2 = 80

    self.x2 = 0 * screenRatio
    self.y2 = 0

    self.x3 = 100 * screenRatio
    self.y3 = 0

    self.x4 = -2 * screenRatio

    self.x5 = 0
    self.y5 = -12

    self.w5 = 300
    self.h5 = 300

    self.w6 = 32
    self.h6 = 64

    self.x6 = 12
    self.y6 = 12
    --------------------------------------------------------------------------------------
    self.w7 = 40
    self.h7 = 40

    self.x7 = 390
    self.y7 = 60

end
--------------------------------------------------------------------------------------
function mt:draw()
    self:measure()

    --------------------------------------------------------------------------------------
    -- 主面板
    self:set_control_size(self.w1, self.h1)
    fc.setFramePosPct(self, ANCHOR.CENTER, MAIN_UI, ANCHOR.CENTER, self.x1, self.y1)

    --------------------------------------------------------------------------------------
    -- 挑战按钮

    for i, optionBtn in ipairs(self.optionBtn) do
        --------------------------------------------------------------------------------------
        -- 按钮本体
        optionBtn:set_control_size(self.w2, self.h2)
        local x2 = self.x2 + self.x3 * (i - 2)
        local y2 = self.y2
        fc.setFramePos(optionBtn, ANCHOR.CENTER, self, ANCHOR.CENTER, x2, y2)

        --------------------------------------------------------------------------------------
        -- 暴击图标
        local critIcon = optionBtn.critIcon
        critIcon:set_control_size(self.w5, self.h5)
        fc.setFramePos(critIcon, ANCHOR.CENTER, optionBtn, ANCHOR.TOP_CENTER, self.x5, self.y5)

        --------------------------------------------------------------------------------------
        -- 升级图标
        local uplvIcon = optionBtn.uplvIcon
        uplvIcon:set_control_size(self.w6, self.h6)
        fc.setFramePos(uplvIcon, ANCHOR.CENTER, optionBtn, ANCHOR.TOP_LEFT, self.x6, self.y6)

    end
    --------------------------------------------------------------------------------------
    -- 刷新按钮
    local refreshBtn = self.refreshBtn
    refreshBtn:set_control_size(self.w7, self.h7)

    fc.setFramePos(refreshBtn, ANCHOR.CENTER, self, ANCHOR.TOP_LEFT, self.x7, self.y7)
end
--------------------------------------------------------------------------------------
function mt:construct()

    --------------------------------------------------------------------------------------
    -- 挑战按钮
    --------------------------------------------------------------------------------------
    self.optionBtn = {}
    for i = 1, 3 do
        --------------------------------------------------------------------------------------
        -- 按钮本体
        local art = [[BlessArt\anyingzhijian.tga]]
        local darkArt = [[BlessArtDark\anyingzhijian.tga]]
        local optionBtn = class.button.new(self, art, 0, 0, 1, 1)
        self.optionBtn[i] = optionBtn
        optionBtn:set_active_image(darkArt)
        optionBtn.sync_key = 'pick_bless_btn' .. i

        function optionBtn:on_sync_button_clicked(player)
            self.parent:onClickOptionBtn(player.handle, i)
        end

        function optionBtn:on_button_mouse_enter()
            self.parent:onShowOptionBtnInfo(i)
        end

        function optionBtn:on_button_mouse_leave()
            toolbox:hide()
        end

        --------------------------------------------------------------------------------------
        -- 暴击图标
        local critIcon = optionBtn:add_texture([[bless_hint_x2.tga]], 0, 0, 1, 1)
        optionBtn.critIcon = critIcon
        critIcon.animSize = 1

        --------------------------------------------------------------------------------------
        -- 升级图标
        local uplvIcon = optionBtn:add_texture([[bless_hint_lv_up.tga]], 0, 0, 1, 1)
        optionBtn.uplvIcon = uplvIcon
        uplvIcon.alphaVal = 1
        uplvIcon.alphaDelta = -0.05
    end
    --------------------------------------------------------------------------------------
    self.refreshBtn = {}
    local art = [[shuaxinlight.tga]]
    local darkArt = [[shuaxindark.tga]]
    local refreshBtn = class.button.new(self, art, 0, 0, 1, 1)
    self.refreshBtn = refreshBtn
    refreshBtn:set_active_image(darkArt)
    refreshBtn.sync_key = 'pick_bless_refresh_btn' .. 1
    function refreshBtn:on_sync_button_clicked(player)
        self.parent:onClickrefreshBtn(player.handle)
    end

    function refreshBtn:on_button_mouse_enter()
        self.parent:onShowrefreshBtnInfo()
    end

    function refreshBtn:on_button_mouse_leave()
        toolbox:hide()
    end
    --------------------------------------------------------------------------------------
    reg:addToPool('ui_render_list', self)
end
--------------------------------------------------------------------------------------
function mt:onShowrefreshBtnInfo()
    local player = as.player:getLocalPlayer()
    local hero = player.hero
    local refreshNum = hero.reDrawBlessNum

    local refreshBtn = self.refreshBtn
    local title = '刷新当前赐福'
    local tip = str.format('|cffffcc00当前刷新次数为：|r' .. refreshNum)

    local refreshCost = 1
    if hero.pickingMemory then
        refreshCost = 2
        tip = str.format('%s（|cffffb67a本次刷新需要：|r%d）', tip, refreshCost)
    end

    toolbox:tooltip(title, tip)
    fc.setFramePos(toolbox, ANCHOR.BOT_LEFT, refreshBtn, ANCHOR.TOP_LEFT, 20, -5)
    toolbox:show()
end
--------------------------------------------------------------------------------------
function mt:onClickrefreshBtn(pj)
    local p = as.player:pj2t(pj)
    local refreshBtn = self.refreshBtn
    local unit = p.hero
    local refreshCost = 1
    local redrawMode = 'bless'

    if fc.isInCd(p, '赐福刷新cd') then
        msg.notice(p, '操作太快了，稍后尝试刷新')
        return
    end

    if unit.pickingMemory then
        refreshCost = 2
        redrawMode = 'memory'
    end

    if unit.reDrawBlessNum < refreshCost then
        msg.notice(p, '刷新次数不足')
        return
    end
    p.hero:drawBless({
        forceRefresh = true,
        noCostPoint = true,
        redrawMode = redrawMode
    })
    p.hero.reDrawBlessNum = p.hero.reDrawBlessNum - refreshCost

    if p:isLocal() then
        self:onShowrefreshBtnInfo()
    end

end
--------------------------------------------------------------------------------------
function mt:onShowOptionBtnInfo(i)
    local player = as.player:getLocalPlayer()
    local optionBtn = self.optionBtn[i]

    local title = optionBtn.title
    local tip = optionBtn.tip

    toolbox:tooltip(title, tip)
    fc.setFramePos(toolbox, ANCHOR.BOT_LEFT, optionBtn, ANCHOR.TOP_LEFT, 20, -5)
    toolbox:show()

end
--------------------------------------------------------------------------------------
function mt:onClickOptionBtn(pj, i)
    local p = as.player:pj2t(pj)
    local optionBtn = self.optionBtn[i]

    p.hero:pickBless(i)
    if p:isLocal() then
        self:hide()
        toolbox:hide()
    end
end
--------------------------------------------------------------------------------------
function mt:updateBoard()
    local player = as.player:getLocalPlayer()
    local blessOptions = player.blessOptions
    if gm.chaosMode == 1 then
        self.optionBtn[1]:hide()
        self.optionBtn[3]:hide()
        local optionBtn = self.optionBtn[2]
        local blessOption = blessOptions[2]
        local bless = blessOption.bless
        local tempName = [[anyingfeidan]]
        local art = str.format('BlessArt\\%s.tga', tempName)
        local lightArt = str.format('BlessArtLight\\%s.tga', tempName)
        local darkArt = str.format('BlessArtDark\\%s.tga', tempName)

        -- local art = [[BlessArt\anyingzhijian.tga]]
        -- local darkArt = [[BlessArtDark\anyingzhijian.tga]]

        optionBtn:set_normal_image(art)
        optionBtn:set_hover_image(lightArt)
        optionBtn:set_active_image(darkArt)

        local title = bless.name
        local getLv = blessOption.getLv
        local critIcon = optionBtn.critIcon
        if getLv > 1 then
            title = str.format('%s（|cff00eeff+%d级！|r）', title, getLv)
            critIcon:set_normal_image(str.format([[bless_hint_x%d.tga]], getLv))
            critIcon.animSize = 1

            critIcon:show()
        else
            critIcon:hide()
        end

        local blessSkill = player.hero:getSkill(bless.name)
        local blessLv = 0
        if blessSkill and blessSkill.lv >= 1 then
            blessLv = blessSkill.lv
        end

        local lvInfo = ''
        if blessLv >= 1 then
            lvInfo = str.format('（|cfff5ff97等级%d|r -> |cffffc774等级%d|r）', blessLv, blessLv + getLv)
        end

        optionBtn.title = str.format('%s%s', title, lvInfo)
        optionBtn.tip = ''

        local classTip
        if bless.blessClassProvide and #bless.blessClassProvide > 0 then
            classTip = '|cffffcc00派系：|r'
            local firstClass = nil
            for i, blessClass in ipairs(bless.blessClassProvide) do
                local className = cst:getConstName(blessClass)
                classTip = str.format('%s %s', classTip, className)
                if not firstClass then
                    firstClass = blessClass
                end
            end
            if bless.skillType == SKILL_TYPE_MEMORY and firstClass then
                classTip = str.format('%s（|cffb3ff00当前数量：|r%d）', classTip,
                    player.hero:getBlessClassLv(firstClass))
            end
        end

        if classTip then
            optionBtn.tip = str.format('%s%s|n|n', optionBtn.tip, classTip)
        end

        optionBtn.tip = str.format('%s%s', optionBtn.tip, bless:getUpgradeTip(blessLv, blessLv + getLv))

        if blessSkill and blessSkill.lv >= 1 then
            optionBtn.tip = str.format('%s', optionBtn.tip)
            -- optionBtn.tip = str.format('%s|n|n|cffa3fff3%s|r', optionBtn.tip, bless.upgradeTip)
            optionBtn.uplvIcon.alphaVal = 1
            optionBtn.uplvIcon.alphaDelta = -0.02
            optionBtn.uplvIcon:show()
        else
            optionBtn.uplvIcon:hide()
        end
    else
        for i, blessOption in ipairs(blessOptions) do
            local optionBtn = self.optionBtn[i]
            local bless = blessOption.bless

            local art = bless.art
            art = cst:getConstTag(bless.blessClassProvide[1],'tempArt')

            local normalArt = str.format('BlessArt\\%s.tga', art)
            local lightArt = str.format('BlessArtLight\\%s.tga', art)
            local darkArt = str.format('BlessArtDark\\%s.tga', art)

            -- local art = [[BlessArt\anyingzhijian.tga]]
            -- local darkArt = [[BlessArtDark\anyingzhijian.tga]]

            optionBtn:set_normal_image(normalArt)
            optionBtn:set_hover_image(lightArt)
            optionBtn:set_active_image(darkArt)

            local title = bless.name
            local getLv = blessOption.getLv
            local critIcon = optionBtn.critIcon
            if getLv > 1 then
                title = str.format('%s（|cff00eeff+%d级！|r）', title, getLv)
                critIcon:set_normal_image(str.format([[bless_hint_x%d.tga]], getLv))
                critIcon.animSize = 1

                critIcon:show()
            else
                critIcon:hide()
            end

            local blessSkill = player.hero:getSkill(bless.name)
            local blessLv = 0
            if blessSkill and blessSkill.lv >= 1 then
                blessLv = blessSkill.lv
            end

            local lvInfo = ''
            if blessLv >= 1 then
                lvInfo = str.format('（|cfff5ff97等级%d|r -> |cffffc774等级%d|r）', blessLv, blessLv + getLv)
            end

            optionBtn.title = str.format('%s%s', title, lvInfo)
            optionBtn.tip = ''

            local classTip
            if bless.blessClassProvide and #bless.blessClassProvide > 0 then
                classTip = '|cffffcc00派系：|r'
                local firstClass = nil
                for i, blessClass in ipairs(bless.blessClassProvide) do
                    local className = cst:getConstName(blessClass)
                    classTip = str.format('%s %s', classTip, className)
                    if not firstClass then
                        firstClass = blessClass
                    end
                end
                if bless.skillType == SKILL_TYPE_MEMORY and firstClass then
                    classTip = str.format('%s（|cffb3ff00当前数量：|r%d）', classTip,
                        player.hero:getBlessClassLv(firstClass))
                end
            end

            if classTip then
                optionBtn.tip = str.format('%s%s|n|n', optionBtn.tip, classTip)
            end

            optionBtn.tip = str.format('%s%s', optionBtn.tip, bless:getUpgradeTip(blessLv, blessLv + getLv))

            if blessSkill and blessSkill.lv >= 1 then
                optionBtn.tip = str.format('%s', optionBtn.tip)
                -- optionBtn.tip = str.format('%s|n|n|cffa3fff3%s|r', optionBtn.tip, bless.upgradeTip)
                optionBtn.uplvIcon.alphaVal = 1
                optionBtn.uplvIcon.alphaDelta = -0.02
                optionBtn.uplvIcon:show()
            else
                optionBtn.uplvIcon:hide()
            end

        end
    end

    mt.updateFrame()

end
--------------------------------------------------------------------------------------
function mt.updateFrame()

    if not GUI.PickBlessPanel.is_show then
        return
    end

    local self = GUI.PickBlessPanel
    for i = 1, 3 do
        local optionBtn = self.optionBtn[i]
        local critIcon = optionBtn.critIcon

        if critIcon.is_show then
            if critIcon.animSize > 0.2 then
                critIcon.animSize = critIcon.animSize - 0.05
            end

            critIcon:set_control_size(self.w5 * critIcon.animSize, self.h5 * critIcon.animSize)
            fc.setFramePos(critIcon, ANCHOR.CENTER, optionBtn, ANCHOR.TOP_CENTER, self.x5, self.y5)
        end

        local uplvIcon = optionBtn.uplvIcon
        if uplvIcon.is_show then
            uplvIcon.alphaVal = uplvIcon.alphaVal + uplvIcon.alphaDelta
            if uplvIcon.alphaVal <= 0 or uplvIcon.alphaVal >= 1 then
                uplvIcon.alphaDelta = uplvIcon.alphaDelta * -1
            end
            uplvIcon:set_alpha(uplvIcon.alphaVal)
        end
    end
end
------------------------------------------------------------------------------------
GUI.PickBlessPanel = mt.create()
GUI.PickBlessPanel:hide()
--------------------------------------------------------------------------------------
return mt
