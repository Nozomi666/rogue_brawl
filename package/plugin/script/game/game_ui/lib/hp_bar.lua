--------------------------------------------------------------------------------------
class.hpBar = extends(class.panel) {

    barList = linked.create(),

    new = function(parent, base, fill, w, h, innerW, innerH, ownerUnit, path)

        local height = 200

        local panel = class.panel.new(parent, base, 0, 0, w, h)
        -- 改变panel对象的类
        panel.__index = class.hpBar

        panel.backFill = panel:add_texture([[arch_hero_exp_bar_white.tga]], 0, 0, innerW, innerH)
        panel.fill = panel:add_texture(fill, 0, 0, innerW, innerH)
        panel.w = innerW
        panel.h = innerH

        panel.customOffsetX = 0
        panel.customOffsetY = -50
        panel.customOffsetZ = 0

        fc.setFramePos(panel, ANCHOR.CENTER, panel, ANCHOR.CENTER, 0, 0)

        fc.setFramePos(panel.backFill, ANCHOR.CENTER, panel, ANCHOR.CENTER, 0, 0)
        fc.setFramePos(panel.fill, ANCHOR.CENTER, panel, ANCHOR.CENTER, 0, 0)
        if path then
            local circlePicPath = str.format([[challengeEnemyTitle\%s.tga]], path)
            panel.lvCircle = panel:add_texture(circlePicPath, 0, 0, 26, 26)
            fc.setFramePos(panel.lvCircle, {0.8, 0.5}, panel, {0, 0.5}, 0, 0)
        end
        panel.nowRate = 0.001
        panel.ownerUnit = ownerUnit

        panel.currentPct = ownerUnit:getStats(ST_HP_PCT)* 100
        panel.delayPct = ownerUnit:getStats(ST_HP_PCT)* 100
        panel.delayTime = 0.4

        class.hpBar.barList:add(panel)

        return panel
    end,

    updateAllBoard = function()

        local barList = class.hpBar.barList
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

            -- gdebug('hpBarLoop check unit: %s, set currentPct: %.2f, delayPct: %.2f', unit:getName(), hpBar.currentPct,
            --     hpBar.delayPct)

            hpBar:setVal(hpBar.currentPct, hpBar.delayPct)

            ::continue::
            hpBar = barList:next(hpBar)
        end
        -- print('update all hpbar')
    end,

}
--------------------------------------------------------------------------------------
local mt = class.hpBar
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

    -- gdebug('hpBar set val: set currentPct: %.2f, delayPct: %.2f', value, delayVal)

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
function mt:beforeDestroy()
    class.hpBar.barList:remove(self)
end
--------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------
