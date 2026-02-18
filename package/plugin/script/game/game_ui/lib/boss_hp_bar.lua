--------------------------------------------------------------------------------------
class.bossHpBar = extends(class.panel) {

    barList = linked.create(),

    new = function(parent, ownerUnit)

        local height = 200
        local base = [[boss_hpbarbase.tga]]

        local panel = class.panel.new(parent, base, 0, 0, 230, 25)
        -- 改变panel对象的类
        panel.__index = class.bossHpBar
        --[[boss_hpbarcover.tga]]

        panel.fill = panel:add_texture([[boss_hpbar.tga]], 0, 0, 230, 25)
        panel.fcv = panel:add_texture([[boss_hpbarcover.tga]], 0, 0, 230, 25)
        panel.cir = panel:add_texture(ownerUnit.headIcon and ownerUnit.headIcon or [[piccir.tga]], 0, 0, 64, 64)
        panel.text = panel:add_text('0', 0, 0, 1, 1, 10, 'center')
        panel.w = 235
        panel.h = 25

        -- panel.h2 = innerH2

        -- panel.fillMp = panel:add_texture([[hero_mana_bar.tga]], 0, 0, innerW, innerH2)

        -- panel.lvCircle = panel:add_texture([[arch_hero_exp_base.tga]], 0, 0, 26, 26)
        -- panel.lvText = panel:add_text('1', 0, 0, 20, 20, 9, 'center')
        -- panel.lvText:set_size(1.4, 'resource\\UI\\FZDHTJW.TTF')
        -- fc.setFramePos(panel.fillMp, ANCHOR.TOP_CENTER, panel, ANCHOR.TOP_CENTER, 15, 25)

        -- fc.setFramePos(panel.back, ANCHOR.TOP_CENTER, panel, ANCHOR.TOP_CENTER, 0, 0)
        -- fc.setFramePos(panel.backFill, ANCHOR.TOP_CENTER, panel, ANCHOR.TOP_CENTER, 0, 0)
        fc.setFramePos(panel.fill, ANCHOR.LEFT, panel, ANCHOR.LEFT, 0, 0)
        fc.setFramePos(panel.fcv, ANCHOR.TOP_CENTER, panel, ANCHOR.TOP_CENTER, 0, 0)
        fc.setFramePos(panel.cir, ANCHOR.RIGHT, panel, ANCHOR.LEFT, 30, -10)
        fc.setFramePos(panel.text, ANCHOR.TOP_CENTER, panel, ANCHOR.TOP_CENTER, 0, 12)

        -- fc.setFramePos(panel.fillMp, ANCHOR.TOP_CENTER, panel.fill, ANCHOR.BOT_CENTER, 0, 1)
        -- fc.setFramePos(panel.lvCircle, ANCHOR.RIGHT, panel, ANCHOR.LEFT, 0, 0)
        -- fc.setFramePos(panel.lvText, ANCHOR.CENTER, panel.lvCircle, ANCHOR.CENTER, -6, 1)

        panel.nowRate = 0.001
        panel.ownerUnit = ownerUnit

        panel.currentPct = ownerUnit:getStats(ST_HP_PCT) * 100
        panel.delayPct = ownerUnit:getStats(ST_HP_PCT)* 100
        panel.delayTime = 0.4

        class.bossHpBar.barList:add(panel)

        -- panel:set_level(UI_LEVEL_HERO_HP_GUI)

        return panel
    end,

    updateAllBoard = function()

        local barList = class.bossHpBar.barList
        local hpBar = barList:at(1)

        while hpBar do

            local unit = hpBar.ownerUnit
            if not hpBar.is_show then
                goto continue
            end

            hpBar.currentPct = unit:getStats(ST_HP_PCT)* 100
            if hpBar.currentPct >= hpBar.delayPct then
                hpBar.delayPct = hpBar.currentPct
                hpBar.delayTime = 0.4
            else
                if hpBar.delayTime > 0 then
                    hpBar.delayTime = hpBar.delayTime - FRAME_INTERVAL_UI
                else
                    hpBar.delayPct = hpBar.delayPct - 5
                end
            end

            hpBar:setVal(hpBar.currentPct, hpBar.delayPct)

            -- hpBar.fillMp:set_control_size(hpBar.w * math.max(unit:getStats(ST_MP_PCT) / 100,0.001), hpBar.h)
            -- hpBar.fillMp:set_control_size(190 * math.max(100 / 100,0.001), 10)

            hpBar.text:set_text(ConvertBigNumberToText(math.floor(unit:getStats(ST_HP))))
            -- hpBar.text:set_text(string.format('%d', math.floor(unit:getStats(ST_HP))))

            ::continue::
            hpBar = barList:next(hpBar)
        end
        -- print('update all hpbar')
    end,

}
--------------------------------------------------------------------------------------
local mt = class.bossHpBar
--------------------------------------------------------------------------------------
function mt:resizeWindow(w, h)
    local panel = self
    panel:set_control_size(w, h)
    panel.fill:set_control_size(w * self.nowRate, h)

    panel.w = w
    panel.h = h

end
--------------------------------------------------------------------------------------
function mt:setVal(value, delayVal)

    local rate1 = math.max(0.001, value / 100)
    local rate2 = math.max(0.001, delayVal / 100)

    -- 改变图层尺寸 为进度值百分比
    self.fill:set_control_size(self.w * rate1 * 0.975, self.h)
    -- self.backFill:set_control_size(self.w * rate2, self.h)
end
--------------------------------------------------------------------------------------
function mt:setFull(word)
    local rate = 1
    -- 改变图层尺寸 为进度值百分比
    self.fill:set_control_size(self.w * rate * 0.975, self.h)
end
--------------------------------------------------------------------------------------
function mt:updateHeroLv(lv)
    -- self.lvText:set_text(lv)
end
--------------------------------------------------------------------------------------
function mt:beforeDestroy()
    class.hpBar.barList:remove(self)
end
--------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------
