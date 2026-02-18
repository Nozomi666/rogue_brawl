local japi = require 'jass.japi'


local mt = {}

mt.create = function()
    local tool = class.panel:builder{
        _type = 'tooltip_backdrop',
        x = 1390,
        y = 400,
        w = 530,
        h = 400,
        level = 5,
        is_show = false,
        alpha = 0.9,
    
        icon = {
            type = 'texture',
            x = 15,
            y = 40,
            w = 18,
            h = 18,
            normal_image = 'xxx.blp',
            text = {
                type = 'text',
                x = 25,
                y = -2,
                w = 100,
                h = 24,
                font_size = 11,
                align = 'left',
                text = '',
            },
        },
    
        title = {
            type = 'text',
            x = 8,
            y = 8,
            text = '测试标题',
            align = 'topleft',
            font_size = 12,
        },
    
        tip = {
            type = 'text',
            x = 8,
            y = 54,
            w = 530,
            align = 'topleft',
            font_size = 12,
        },
    }
    --------------------------------------------------------------------------------------
    function tool:tooltip(title, tip, width)
        tool.title:set_width(width or 515)
        tool.tip:set_width(width or 515)
        tool:set_width((width or 515) + 20)
        -- tool.tip:set_width(1111)
        tool.icon:hide()
        tool.title:set_text(title)
        tool.tip:set_text(tip)
    
        local height = tool.tip:get_height() + 64
        tool:set_height(height)
    
        -- tool:show()
    end
    --------------------------------------------------------------------------------------
    function tool:tooltipNoTitle(tip, width)
        tool.tip:set_width(width or 515)
        tool:set_width((width or 515) + 20)
        -- tool.tip:set_width(1111)
        tool.icon:hide()
        tool.title:hide()
        tool.tip:set_text(tip)

        fc.setFramePos(tool.tip, ANCHOR.TOP_LEFT, tool, ANCHOR.TOP_LEFT, 8, 8)
    
        local height = tool.tip:get_height() + 4
        tool:set_height(height)
    
        -- tool:show()
    end
    --------------------------------------------------------------------------------------
    function tool:moveToDefault()
        local shiftX_backdrop = uiHelper.screenWidthPercent(-0.001)
        local shiftY_backdrop = uiHelper.screenHeightPercent(-0.268)
        fc.setFramePosPct(tool, ANCHOR.BOT_RIGHT, MAIN_UI, ANCHOR.BOT_RIGHT, -0.001, -0.268)
    end
    --------------------------------------------------------------------------------------
    function tool:hideOriginTooltip()
        local frame = dz.DzFrameGetTooltip()
        dz.DzFrameSetAbsolutePoint(frame, 8, -0.01, -0.01)
    end
    --------------------------------------------------------------------------------------
    function tool:showOriginTooltip()
        local frame = dz.DzFrameGetTooltip()
        dz.DzFrameSetAbsolutePoint(frame, 8, 0.8, 0.16)
    end
    --------------------------------------------------------------------------------------
    -- 隐藏时 将原生提示框恢复
    -- function tool:hide()
    --     if self.timer then
    --         self.timer:remove()
    --         self.timer = nil
    --     end
    --     class.panel.hide(self)
    -- end
    
    return tool
end


return mt


