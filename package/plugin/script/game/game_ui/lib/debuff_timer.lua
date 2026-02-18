--------------------------------------------------------------------------------------
class.debuffTimer = extends(class.panel) {

    barList = linked.create(),

    new = function(parent, ownerUnit, keys)

        local height = 0
        local base = [[]]
        local w = 1
        local h = 1
        local innerW = 1
        local innerH = 1

        local panel = class.panel.new(parent, base, 0, 0, w, h)
        -- 改变panel对象的类
        panel.__index = class.debuffTimer

        local sizeRate = 0.7
        panel.timer = panel:add_texture([[final_timer.tga]], 0, 0, 208 * sizeRate, 36 * sizeRate)
        panel.time = panel:add_text('0', 0, 0, 1, 1, 8, 'center')
        panel.time:set_size(1, 'resource\\UI\\FZDHTJW.TTF')
        fc.setFramePos(panel.timer, ANCHOR.TOP_CENTER, panel, ANCHOR.TOP_CENTER, 0, 27)
        fc.setFramePos(panel.time, ANCHOR.TOP_CENTER, panel, ANCHOR.TOP_CENTER, 3, 39)

        panel.nowRate = 0.001
        panel.ownerUnit = ownerUnit

        class.debuffTimer.barList:add(panel)

        panel:set_level(UI_LEVEL_HERO_HP_GUI)

        return panel
    end,

    updateAllBoard = function()

        local barList = class.debuffTimer.barList
        local hpBar = barList:at(1)

        local count = 0
        while hpBar do

            count = count + 1
            if count > 200 then
                -- gdebug('hp bar infinate loop')
            end

            local unit = hpBar.ownerUnit
            if not hpBar.is_show then
                goto continue
            end

            if unit.guancetimer then
                hpBar.time:set_text("|cffffffff" .. string.format("%.2f", unit.guancetimer) .. "|r")
            end

            if unit.yinyangxianggeTime then
                hpBar.time:set_text("|cffffffff" .. string.format("%.0f", unit.yinyangxianggeTime) .. "|r")
            end

            ::continue::
            hpBar = barList:next(hpBar)
        end

    end,

}
--------------------------------------------------------------------------------------
local mt = class.debuffTimer
--------------------------------------------------------------------------------------
function mt:beforeDestroy()
    class.debuffTimer.barList:remove(self)
end
--------------------------------------------------------------------------------------
