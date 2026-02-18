--------------------------------------------------------------------------------------
class.skillTipbox = extends(class.panel) {

    new = function(parent)
        -- 底图是一张黑色的图片 这个可以写死
        local panel = class.panel:builder{
            _type = 'tooltip_backdrop',
            x = 1390,
            y = 400,
            w = 530,
            h = 400,
            level = 5,
            is_show = true,
            alpha = 0.9,

            title = {
                type = 'text',
                x = 85,
                y = 14,
                text = '测试标题',
                align = 'topleft',
                font_size = 13,
            },

            titleHint = {
                type = 'text',
                x = 128,
                y = 58,
                text = '测试标题附属22222',
                align = 'topleft',
                font_size = 12,
            },

            resourceTip1 = {
                type = 'text',
                x = 128,
                y = 58,
                text = '测试标题附属22222',
                align = 'topleft',
                font_size = 12,
            },

            resourceTip2 = {
                type = 'text',
                x = 128,
                y = 58,
                text = '测试标题附属33333',
                align = 'topleft',
                font_size = 12,
            },

            tip = {
                type = 'text',
                x = 14,
                y = 100,
                w = 530,
                text = '测试文本测试文本测试文本测试文本测试文本测试文本测试文本测试文本测试文本',
                align = 'topleft',
                font_size = 11,
            },
        }
        -- 改变panel对象的类
        panel.__index = class.skillTipbox
        panel:construct()
        panel:draw()
        panel:show()
        return panel
    end,

}
local mt = class.skillTipbox
------------------------------------------------------------------------------------
function mt:measure()
    self.x1 = 0.08
    self.y1 = 0.004

    self.w1 = 28
    self.h1 = 28

    self.w2 = 190
    self.h2 = 20

    self.x2 = 240
    self.y2 = 10

end
--------------------------------------------------------------------------------------
function mt:draw()
    self:measure()

    local cutLine = self.cutLine
    cutLine:set_control_size(510, 2)
    fc.setFramePos(cutLine, ANCHOR.TOP_LEFT, self.icon, ANCHOR.BOT_LEFT, 0, 13)

    local resourceIcon1 = self.resourceIcon1
    fc.setFramePos(resourceIcon1, ANCHOR.BOT_LEFT, self.icon, ANCHOR.BOT_RIGHT, 5, 0)

    fc.setFramePos(self.resourceTip1, ANCHOR.TOP_LEFT, self.resourceIcon1, ANCHOR.TOP_RIGHT, 1, 6)

    local titleHint = self.titleHint
    titleHint:set_control_size(100, 1)
    fc.setFramePos(titleHint, ANCHOR.TOP_LEFT, resourceIcon1, ANCHOR.TOP_LEFT, 3, 5)

    local cdIcon = self.cdIcon
    cdIcon:set_control_size(28, 28)
    fc.setFramePos(cdIcon, ANCHOR.TOP_RIGHT, self, ANCHOR.TOP_RIGHT, -70, 12)

    local cdText = self.cdText
    cdText:set_control_size(100, 1)
    fc.setFramePos(cdText, ANCHOR.TOP_LEFT, cdIcon, ANCHOR.TOP_RIGHT, 2, 5)

    local mpIcon = self.mpIcon
    mpIcon:set_control_size(28, 28)
    fc.setFramePos(mpIcon, ANCHOR.TOP_LEFT, cdIcon, ANCHOR.BOT_LEFT, 0, 5)

    local mpText = self.mpText
    mpText:set_control_size(100, 1)
    fc.setFramePos(mpText, ANCHOR.TOP_LEFT, mpIcon, ANCHOR.TOP_RIGHT, 2, 5)

end
--------------------------------------------------------------------------------------
function mt:construct()

    local icon = self:add_texture(TEMPLATE_BTN_PATH, 12, 12, 64, 64)
    self.icon = icon

    local cutLine = self:add_texture([[wide_cut_line.tga]], 12, 52, 500, 10)
    self.cutLine = cutLine

    local resourceIcon1 = self:add_texture(TEMPLATE_BTN_PATH, 12, 12, 32, 32)
    self.resourceIcon1 = resourceIcon1

    local resourceIcon2 = self:add_texture(TEMPLATE_BTN_PATH, 12, 12, 32, 32)
    self.resourceIcon2 = resourceIcon2

    local title = self.title
    -- title:set_size(1.2)

    local tip = self.tip
    -- tip:set_size(1)

    local titleHint = self.titleHint
    -- titleHint:set_size(1.1)

    local resourceTip1 = self.resourceTip1
    -- resourceTip1:set_size(1.1)

    local resourceTip2 = self.resourceTip2
    -- resourceTip2:set_size(1.1)

    local cdIcon = self:add_texture([[icon_cd.tga]], 1, 1, 1, 1)
    self.cdIcon = cdIcon

    local mpIcon = self:add_texture([[icon_mp.tga]], 1, 1, 1, 1)
    self.mpIcon = mpIcon

    local cdText = self:add_text('12.5秒', 0, 0, 1, 1, 10, 'topleft')
    self.cdText = cdText
    -- cdText:set_size(1, 'fonts.TTF')

    local mpText = self:add_text('200', 0, 0, 1, 1, 10, 'topleft')
    self.mpText = mpText
    -- mpText:set_size(1, 'fonts.TTF')
    --------------------------------------------------------------------------------------
    -- 数字
    -- local title = self:add_text('描述标题', 0, 0, 1, 1, 14, 'topright')
    -- self.title = title

    --------------------------------------------------------------------------------------
    -- -- 图标
    -- local icon = class.button.new(self, [[gold_icon.tga]], 0, 0, 1, 1)
    -- self.icon = icon

    self:draw()

end
--------------------------------------------------------------------------------------
function mt:makeTip(keys)
    local title = keys.title
    local tip = keys.tip
    local width = keys.width
    local icon = keys.icon
    local mpText = keys.mpText
    local cdText = keys.cdText
    local resourceIcon1 = keys.resourceIcon1
    local resourceTip1 = keys.resourceTip1
    local resourceIcon2 = keys.resourceIcon2
    local resourceTip2 = keys.resourceTip2
    local titleHint = keys.titleHint

    self.title:set_width(width or 515)
    self.tip:set_width(width or 515)
    self:set_width((width or 515) + 20)

    self.icon:set_normal_image(icon)

    self.title:set_text(title)
    self.tip:set_text(tip)


    if resourceIcon1 then
        self.resourceIcon1:set_normal_image(resourceIcon1)
        self.resourceIcon1:show()
        if resourceTip1 then
            self.resourceTip1:set_text(resourceTip1)
        end
        if resourceIcon1 == RESOURCE_ICON_SKILL_POINT then
            fc.setFramePos(self.resourceTip1, ANCHOR.TOP_LEFT, self.resourceIcon1, ANCHOR.TOP_RIGHT, 1, 9)
        else
            fc.setFramePos(self.resourceTip1, ANCHOR.TOP_LEFT, self.resourceIcon1, ANCHOR.TOP_RIGHT, 1, 6)
        end
    else
        self.resourceIcon1:hide()
        self.resourceTip1:set_text('')
    end

    if resourceIcon2 then
        fc.setFramePos(self.resourceIcon2, ANCHOR.TOP_LEFT, self.resourceIcon1, ANCHOR.TOP_RIGHT,
            15 + self.resourceTip1:get_width(), 0)
        fc.setFramePos(self.resourceTip2, ANCHOR.TOP_LEFT, self.resourceIcon2, ANCHOR.TOP_RIGHT, 1, 6)

        self.resourceIcon2:set_normal_image(resourceIcon2)
        self.resourceIcon2:show()
        if resourceTip2 then
            self.resourceTip2:set_text(resourceTip2)
        end
    else
        self.resourceIcon2:hide()
        self.resourceTip2:set_text('')
    end

    if cdText then
        self.cdText:set_text(cdText)
        self.cdText:show()
        self.cdIcon:show()
    else
        self.cdText:hide()
        self.cdIcon:hide()
    end

    if mpText then
        self.mpText:set_text(mpText)
        self.mpText:show()
        self.mpIcon:show()
    else
        self.mpText:hide()
        self.mpIcon:hide()
    end

    if titleHint then
        self.titleHint:set_text(titleHint)
        self.titleHint:show()
    else
        self.titleHint:hide()
    end

    local height = self.tip:get_height() + 112
    self:set_height(height)

    self:moveToDefault()
    self:show()
end
--------------------------------------------------------------------------------------
function mt:moveToDefault()
    local shiftX_backdrop = uiHelper.screenWidthPercent(-0.001)
    local shiftY_backdrop = uiHelper.screenHeightPercent(-0.268)
    fc.setFramePosPct(self, ANCHOR.BOT_RIGHT, MAIN_UI, ANCHOR.BOT_RIGHT, -0.001, -0.268)
end
------------------------------------------------------------------------------------
skillTipbox = mt.create()
skillTipbox:moveToDefault()
skillTipbox:hide()
-- skillTipbox:show()

-- skillTipbox:makeTip({
--     icon = TEMPLATE_BTN_PATH,
--     title = '测试标题(|cffffcc00Z|r) |cffccccccLv1|r',
--     tip = '测试文本测试文本测试文本测试文本测试文本测试文本测试文本测试文本测试文本|n神射手|n神射手',
--     resourceIcon1 = [[UI\Feedback\Resources\ResourceGold.blp]],
--     resourceTip1 = 'x3（鼠标右键升级）',
--     -- resourceIcon2 = [[UI\Feedback\Resources\ResourceLumber.blp]],
--     -- resourceTip2 = '1000',  
--     cdText = '10.5秒',
--     mpText = '120',
-- })

-- GUI.ResourceGold:hide()
--------------------------------------------------------------------------------------
return mt
