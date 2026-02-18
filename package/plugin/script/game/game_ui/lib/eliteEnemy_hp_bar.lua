--------------------------------------------------------------------------------------
class.eliteEnemyHpBar = extends(class.panel) {

    barList = linked.create(),

    new = function(parent, ownerUnit, path, keys)

        local height = 0
        local base = [[jingyingdi.tga]]
        local w = 145
        local h = 22
        local innerW = 130
        local innerH = 11

        local panel = class.panel.new(parent, base, 0, 0, w, h)
        -- 改变panel对象的类
        panel.__index = class.eliteEnemyHpBar

        -- panel.backFill = panel:add_texture([[player_hpbarbase.tga]], 0, 0, innerW + 15, innerH + 3)
        panel.backFill = panel:add_texture([[arch_hero_exp_bar_white.tga]], 0, 0, innerW, innerH)
        panel.fill = panel:add_texture([[jingyingxuetiao.tga]], 0, 0, innerW, innerH)
        -- panel.backFill = panel:add_texture([[arch_hero_exp_bar_red.tga]], 0, 0, innerW, innerH)
        -- panel.fill = panel:add_texture([[hero_hp_bar.tga]], 0, 0, innerW, innerH)
        panel.w = innerW
        panel.h = innerH
        fc.setFramePos(panel.fill, {0.5, -0.2}, panel, {0.5, 0}, 0, 3)
        fc.setFramePos(panel.backFill, {0.5, -0.2}, panel, {0.5, 0}, 0, 3)
        if path then
            local circlePicPath = str.format([[challengeEnemyTitle\%s.tga]], path)
            panel.lvCircle = panel:add_texture(circlePicPath, 0, 0, 44, 44)
            fc.setFramePos(panel.lvCircle, {0.8, 0.5}, panel, {0, 0.5}, 0, 0)
            if keys then
                local offSetX = 0
                local offSetY = 0
                if keys.circlePicOffsetX then
                    offSetX = keys.circlePicOffsetX
                end
                if keys.circlePicOffsetY then
                    offSetY = keys.circlePicOffsetY
                end

                fc.setFramePos(panel.lvCircle, {0.8, 0.5}, panel, {0, 0.5}, offSetX, offSetY)
            end
        end
        if ownerUnit.timeLimit then
            local sizeRate = 0.7
            panel.timer = panel:add_texture([[final_timer.tga]], 0, 0, 208 * sizeRate, 36 * sizeRate)
            panel.time = panel:add_text('0', 0, 0, 1, 1, 8, 'center')
            panel.time:set_size(1, 'resource\\UI\\FZDHTJW.TTF')
            fc.setFramePos(panel.timer, ANCHOR.TOP_CENTER, panel, ANCHOR.TOP_CENTER, 0, 17)
            fc.setFramePos(panel.time, ANCHOR.TOP_CENTER, panel, ANCHOR.TOP_CENTER, 3, 29)
        end
        -- panel.fillMp = panel:add_texture([[player_mpbar.tga]], 0, 0, 97, 3)

        -- panel.lvText = panel:add_text('1', 0, 0, 20, 20, 9, 'center')
        -- panel.lvText:set_size(1.4, 'resource\\UI\\FZDHTJW.TTF')

        -- fc.setFramePos(panel.backFill, ANCHOR.TOP_CENTER, panel, ANCHOR.TOP_CENTER, 0, 3)

        -- fc.setFramePos(panel.fillMp, ANCHOR.TOP_CENTER, panel.fill, {0.5, 1.2}, 0, 1)

        -- fc.setFramePos(panel.lvText, ANCHOR.CENTER, panel.lvCircle, ANCHOR.CENTER, -6, 1)

        panel.nowRate = 0.001
        panel.ownerUnit = ownerUnit

        panel.currentPct = ownerUnit:getStats(ST_HP_PCT)* 100
        panel.delayPct = ownerUnit:getStats(ST_HP_PCT)* 100
        panel.delayTime = 0.4

        class.eliteEnemyHpBar.barList:add(panel)

        panel:set_level(UI_LEVEL_HERO_HP_GUI)

        return panel
    end,

    updateAllBoard = function()

        local barList = class.eliteEnemyHpBar.barList
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
            if unit.timeLimit then
                hpBar.time:set_text("|cffffffff" .. unit.timeLimit .. "|r")
            end
            -- hpBar.fillMp:set_control_size(hpBar.w * math.max(unit:getStats(ST_MP_PCT) / 100,0.001), hpBar.h2)

            ::continue::
            hpBar = barList:next(hpBar)
        end
        -- print('update all hpbar')
    end,

}
--------------------------------------------------------------------------------------
local mt = class.eliteEnemyHpBar
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
    self.backFill:set_control_size(self.w * rate2, self.h)
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
    class.eliteEnemyHpBar.barList:remove(self)
end
--------------------------------------------------------------------------------------
