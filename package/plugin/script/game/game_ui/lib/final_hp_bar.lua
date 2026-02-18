--------------------------------------------------------------------------------------
class.finalHpBar = extends(class.panel) {

    barList = linked.create(),

    new = function(parent, ownerUnit)

        local base = [[final_base.tga]]
        local w = 1000
        local h = 75
        local innerW = 650
        local innerH = 34

        local panel = class.panel.new(parent, base, 0, 0, 1, 1)
        -- 改变panel对象的类
        panel.__index = class.finalHpBar
        --[[boss_hpbarcover.tga]]
        panel.backFill = panel:add_texture([[final_base.tga]], 0, 18, innerW, innerH + 10)
        panel.fill = panel:add_texture([[final_hpbar.tga]], 0, 18, innerW, innerH)
        panel.bfcv = panel:add_texture([[black_front_cover.tga]], 0, 0, w, h)
        panel.fcv = panel:add_texture([[front_cover.tga]], 0, 0, w, h)
        panel.text = panel:add_text('0', 0, 0, 1, 1, 11, 'center')
        panel.timer = panel:add_texture([[final_timer.tga]], 0, 0, 208, 36)
        panel.time = panel:add_text('0', 0, 0, 1, 1, 11, 'center')
        -- panel.backFill = panel:add_texture([[final_base.tga]], -100, -282, innerW, innerH + 10)
        -- panel.fill = panel:add_texture([[final_hpbar.tga]], -100, -282, innerW, innerH)
        -- panel.bfcv = panel:add_texture([[black_front_cover.tga]], -100, -300, w, h)
        -- panel.fcv = panel:add_texture([[front_cover.tga]], -100, -300, w, h)
        panel.w = innerW
        panel.h = innerH
        -- panel.h2 = innerH2
        -- panel.fillMp = panel:add_texture([[boss_mpbar.tga]], 0, 0, innerW, innerH2)
        -- panel.fillMp = panel:add_texture([[hero_mana_bar.tga]], 0, 0, innerW, innerH2)

        -- panel.lvCircle = panel:add_texture([[arch_hero_exp_base.tga]], 0, 0, 26, 26)
        -- panel.lvText = panel:add_text('1', 0, 0, 20, 20, 9, 'center')
        -- panel.lvText:set_size(1.4, 'resource\\UI\\FZDHTJW.TTF')

        fc.setFramePos(panel.backFill, ANCHOR.TOP_CENTER, MAIN_UI, ANCHOR.TOP_CENTER, 0, 102)
        fc.setFramePos(panel.fill, ANCHOR.TOP_CENTER, MAIN_UI, ANCHOR.TOP_CENTER, 0, 102)
        fc.setFramePos(panel.bfcv, ANCHOR.TOP_CENTER, MAIN_UI, ANCHOR.TOP_CENTER, 0, 80)
        fc.setFramePos(panel.fcv, ANCHOR.TOP_CENTER, MAIN_UI, ANCHOR.TOP_CENTER, 0, 80)
        fc.setFramePos(panel.text, ANCHOR.TOP_CENTER, MAIN_UI, ANCHOR.TOP_CENTER, 0, 120)
        fc.setFramePos(panel.timer, ANCHOR.TOP_CENTER, MAIN_UI, ANCHOR.TOP_CENTER, 0, 150)
        fc.setFramePos(panel.time, ANCHOR.TOP_CENTER, MAIN_UI, ANCHOR.TOP_CENTER, 5, 168)
        -- fc.setFramePos(panel.backFill, ANCHOR.TOP_CENTER, MAIN_UI, ANCHOR.TOP_CENTER, -100, -282)
        -- fc.setFramePos(panel.fill, ANCHOR.TOP_CENTER, MAIN_UI, ANCHOR.TOP_CENTER, -100, -282)
        -- fc.setFramePos(panel.bfcv, ANCHOR.TOP_CENTER, MAIN_UI, ANCHOR.TOP_CENTER, -100, -300)
        -- fc.setFramePos(panel.fcv, ANCHOR.TOP_CENTER, MAIN_UI, ANCHOR.TOP_CENTER, -100, -300)
        -- fc.setFramePos(panel.fillMp, ANCHOR.TOP_CENTER, panel.fill, ANCHOR.BOT_CENTER, 0, 0)
        -- fc.setFramePos(panel.fillMp, ANCHOR.TOP_CENTER, panel.fill, ANCHOR.BOT_CENTER, 0, 1)
        -- fc.setFramePos(panel.lvCircle, ANCHOR.RIGHT, panel, ANCHOR.LEFT, 0, 0)
        -- fc.setFramePos(panel.lvText, ANCHOR.CENTER, panel.lvCircle, ANCHOR.CENTER, -6, 1)

        panel.nowRate = 0.001
        panel.ownerUnit = ownerUnit

        panel.currentPct = ownerUnit:getStats(ST_HP_PCT)* 100
        panel.delayPct = ownerUnit:getStats(ST_HP_PCT)* 100
        panel.delayTime = 0.4

        class.finalHpBar.barList:add(panel)

        -- panel:set_level(UI_LEVEL_HERO_HP_GUI)

        return panel
    end,

    updateAllBoard = function()

        local barList = class.finalHpBar.barList
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
            hpBar.text:set_text(ConvertBigNumberToText(math.floor(unit:getStats(ST_HP))) .. "    " ..
                                    math.floor(unit:getStats(ST_HP_PCT)* 100) .. "%")
            if unit.timeLimit then
                hpBar.time:set_text("|cffffffff" .. unit.timeLimit .. "|r")
            else
                if EnemyManager.finalBossTime < 20 then
                    hpBar.time:set_text("|cffc90909" .. EnemyManager.finalBossTime .. "|r")
                elseif EnemyManager.finalBossTime < 60 then
                    hpBar.time:set_text("|cfffc7201" .. EnemyManager.finalBossTime .. "|r")
                else
                    hpBar.time:set_text("|cff5ffc04" .. EnemyManager.finalBossTime .. "|r")
                end
            end

            -- hpBar.fillMp:set_control_size(hpBar.w * math.max(unit:getStats(ST_MP_PCT) / 100,0.001), hpBar.h2)

            ::continue::
            hpBar = barList:next(hpBar)
        end
        -- print('update all hpbar')
    end

}
--------------------------------------------------------------------------------------
local mt = class.finalHpBar
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
    self.fill:set_control_size(self.w * rate1, self.h)
    -- self.backFill:set_control_size(self.w * rate2, self.h)
end
--------------------------------------------------------------------------------------
function mt:setFull(word)
    local rate = 1
    -- 改变图层尺寸 为进度值百分比
    self.fill:set_control_size(self.w * rate, self.h)
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
