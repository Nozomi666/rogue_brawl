--------------------------------------------------------------------------------------
-- local botInfo = class.panel.create([[Custom_UI_Bottom.tga]], 0, 0, 1, 1)
-- botInfo:set_control_size(1920, 336)
-- fc.setFramePos(botInfo, ANCHOR.BOT_LEFT, MAIN_UI, ANCHOR.BOT_LEFT, 0, 0)
--------------------------------------------------------------------------------------
for y = 0, 3 do
    for x = 0, 2 do
        local frame = japi.FrameGetCommandBarButton(x, y)
        if frame > 0 then
            japi.FrameSetButtonCooldownModelSize(frame, 0.9)
        end
    end
end

