--------------------------------------------------------------------------------------
local maidW = 84 * screenRatio
local maidH = 138
--------------------------------------------------------------------------------------
local panel = class.panel:builder{
    x = 0,
    y = 0,
    w = maidW,
    h = maidH,
    level = 0,
    is_show = true,
    -- alpha = 1,

    btn = {
        type = 'button',
        x = 0,
        y = 0,
        w = maidW,
        h = maidH,
        normal_image = [[maid_icon.tga]],
        sync_key = 'maid_btn',
    },

    -- hint = {
    --     type = 'text',
    --     x = 0,
    --     y = 0,
    --     text = [[按'~'选中信使]],
    --     align = 'center',
    --     level = 0,
    --     font_size = 10,
    -- },

}

local onClick = function(pj)
    local p = as.player:pj2t(pj)
    p:pressTilde()
end

function panel.btn:on_sync_button_clicked(player)
    onClick(player.handle)
end

fc.setFramePosPct(panel, ANCHOR.BOT_LEFT, MAIN_UI, ANCHOR.BOT_LEFT, 0.005, -0.22)
-- fc.setFramePos(panel.hint, ANCHOR.BOT_LEFT, panel, ANCHOR.BOT_LEFT, 10, -8)
