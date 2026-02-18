--------------------------------------------------------------------------------------
class.skill_btn = extends(class.panel) {

    new = function(parent)
        -- 底图是一张黑色的图片 这个可以写死
        local panel = class.panel.new(parent, '', 1, 1, 1, 1)
        -- 改变panel对象的类
        panel.__index = class.skill_btn
        panel:construct()
        panel:draw()
        panel:show()
        return panel
    end,

}
local mt = class.skill_btn

--------------------------------------------------------------------------------------
function mt:draw()

end
--------------------------------------------------------------------------------------
function mt:construct()
    self.btnFrame = {}
    self.hintAnim = {}
    self.hintAnimBlue = {}
    self.progressCircle = {}
    self.refreshLight = {}
    for i = 1, 12 do
        self.btnFrame[i] = self:createFrame(i)
    end

    for i = 9, 12 do
        self:createHintAnim(i)
    end

    for i = 5, 8 do
        self:createHintAnimBlue(i)
    end

    for i = 1, 8 do
        self.refreshLight[i] = self:createRefreshLight(i)
    end

    self:createProgressCircle(6)

end
--------------------------------------------------------------------------------------
function mt:createFrame(id)

    local frame = class.texture:builder{
        parent = self,
        x = 0,
        y = 0,
        w = 64,
        h = 64,
        normal_image = [[yellow_border.blp]],
        is_show = false,
        level = 1,

    }

    local x = (id - 1) % 4
    local y = math.floor((id - 1) / 4)

    -- gdebug(str.format('new btn: x:%d, y:%d', x, y))

    local startX = uiHelper.screenWidthPercent(0.27) * -1
    local startY = uiHelper.screenHeightPercent(0.242) * -1

    local intervalX = uiHelper.screenWidthPercent(0.046) -1
    local intervalY = uiHelper.screenHeightPercent(0.07) +12

    local shiftX = startX + intervalX * x
    local shiftY = startY + intervalY * y

    uiHelper:setFrameAnchor(frame, uiHelper.anchorPos.TOP_LEFT, uiHelper.GAME_UI, uiHelper.anchorPos.BOT_RIGHT, shiftX,
        shiftY)

    return frame
end
--------------------------------------------------------------------------------------
function mt:createRefreshLight(id)
    --------------------------------------------------------------------------------------
    -- 流光
    -- local animation = self:add_model([[UI_ButtonEffect_chengse.mdx]])
    -- animation:set_scale(0.88 * 0.1, 1 * 0.95, 0.1)
    -- fc.setFramePos(animation, ANCHOR.TOP_LEFT, self.btnFrame[id], ANCHOR.TOP_LEFT, 36, 16)
    -- animation:show()

    local animation = self:add_texture([[war3mapimported\UI_ButtonEffect1_06.blp]], 0, 0, 78, 64)
    fc.setFramePos(animation, ANCHOR.TOP_LEFT, self.btnFrame[id], ANCHOR.TOP_LEFT, -8, -8)
    animation:hide()

    -- local c = 0
    -- ac.loop(ms(0.03), function ()
    --     animation:set_normal_image(str.format([[war3mapimported\UI_ButtonEffect1_%02d.blp]], c))
    --     c = c + 1
    --     if c > 15 then
    --         c = 0
    --     end
    -- end)

    return animation
end
--------------------------------------------------------------------------------------
function mt:startRefreshLight()
    self.refreshlightAnimIndex = 0
    self.bUpdateFrame = true

end
--------------------------------------------------------------------------------------
function mt:updateRefreshLight()
    for i = 1, 8 do
        local anim = self.refreshLight[i]
        anim:show()
        anim:set_normal_image(str.format([[war3mapimported\UI_ButtonEffect1_%02d.blp]], self.refreshlightAnimIndex))
    end

    self.refreshlightAnimIndex =  self.refreshlightAnimIndex + 1
    if self.refreshlightAnimIndex > 15 then
        self.refreshlightAnimIndex = nil
        self.bUpdateFrame = false
        for i = 1, 8 do
            local anim = self.refreshLight[i]
            anim:hide()
        end
    end
end
--------------------------------------------------------------------------------------
function mt:createHintAnim(id)
    --------------------------------------------------------------------------------------
    -- 流光
    local animation = self:add_model([[T5.mdx]])
    self.hintAnim[id] = animation
    animation:set_scale(0.88 * 0.95, 1 * 0.95, 1)
    fc.setFramePos(animation, ANCHOR.TOP_LEFT, self.btnFrame[id], ANCHOR.TOP_LEFT, -8, 62)
    animation:hide()

    return animation
end
--------------------------------------------------------------------------------------
function mt:createHintAnimBlue(id)
    --------------------------------------------------------------------------------------
    -- 钻石
    local animation = self:add_model([[STM108.mdx]])
    self.hintAnimBlue[id] = animation
    animation:set_scale(0.88 * 0.95, 1 * 0.95, 1)
    fc.setFramePos(animation, ANCHOR.TOP_LEFT, self.btnFrame[id], ANCHOR.TOP_LEFT, -8, 62)
    animation:hide()
end
--------------------------------------------------------------------------------------
function mt:createProgressCircle(id)
    --------------------------------------------------------------------------------------
    -- 绿圈
    local progressCircle = self:add_texture([[war3mapimported\lvse123_00000.blp]], 0, 0, 48, 48)
    self.progressCircle[id] = progressCircle
    fc.setFramePos(progressCircle, ANCHOR.CENTER, self.btnFrame[id], ANCHOR.TOP_RIGHT, -4, 4)

    --------------------------------------------------------------------------------------
    -- 覆盖
    local coverBlack = progressCircle:add_texture([[black_circle_cover.tga]], 0, 0, 16, 16)
    fc.setFramePos(coverBlack, ANCHOR.CENTER, progressCircle, ANCHOR.CENTER, 0, 0)

    --------------------------------------------------------------------------------------
    -- 数字
    local chargeNumber = progressCircle:add_text('1', 0, 0, 1, 1, 8, 'center')
    progressCircle.chargeNumber = chargeNumber
    chargeNumber:set_size(1.2, 'resource\\UI\\FZDHTJW.TTF')
    fc.setFramePos(chargeNumber, ANCHOR.TOP_LEFT, progressCircle, ANCHOR.CENTER, 0, -1)

    progressCircle:hide()

end
--------------------------------------------------------------------------------------
function mt:updateProgressCircles()
    self = GUI.SkillBtn
    local player = fc.getLocalPlayer()
    local hero = player.hero
    if not hero then
        return
    end

    if player.lastPick == hero then
        -- local skill = hero:getSkill('突进')
        -- local pct = ((skill.cd - skill.currentChargeCd) / skill.cd) * 100
        -- local chargeNumber = skill.currentLeftCharge
        -- self:updateProgressCircle(6, pct, chargeNumber)
        -- self.progressCircle[6]:show()
    else
        self.progressCircle[6]:hide()
    end

end
--------------------------------------------------------------------------------------
function mt:updateProgressCircle(id, pct, chargeNumber)
    local progressCircle = self.progressCircle[id]
    pct = math.clamp(math.floor(pct), 1, 100)
    progressCircle:set_normal_image(PROGRESS_ART[pct])
    progressCircle.chargeNumber:set_text(chargeNumber)
end
--------------------------------------------------------------------------------------
function mt:showHintAnim(id)
    self.hintAnim[id]:show()
end
--------------------------------------------------------------------------------------
function mt:hideHintAnim(id)
    self.hintAnim[id]:hide()
end
--------------------------------------------------------------------------------------
function mt:showHintAnimBlue(id)
    self.hintAnimBlue[id]:show()
end
--------------------------------------------------------------------------------------
function mt:hideHintAnimBlue(id)
    self.hintAnimBlue[id]:hide()
end
------------------------------------------------------------------------------------
GUI.SkillBtn = mt.create()
GUI.SkillBtn:show()
--------------------------------------------------------------------------------------

return mt
