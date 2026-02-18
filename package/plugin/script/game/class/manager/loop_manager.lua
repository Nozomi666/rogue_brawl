local mt = {}
as.loops = mt

mt.timer = nil
mt.timerUI = nil

local enums = {}
local uiActs = {}
local uiActsFast = {}
--------------------------------------------------------------------------------------
function mt:registerTickLoop(name, ob)
    table.insert(enums, ob)
end
--------------------------------------------------------------------------------------
function mt:registerUILoop(name, ob)
    table.insert(uiActs, ob)
end
--------------------------------------------------------------------------------------
function mt:registerUIFastLoop(name, ob)
    table.insert(uiActsFast, ob)
end
--------------------------------------------------------------------------------------
function mt:init()
    local refreshInterval = FRAME_INTERVAL_NORMAL * 1000
    mt.timer = ac.loop(refreshInterval, function()
        for _, act in ipairs(enums) do
            act()
        end
    end)

    local refreshInterval = FRAME_INTERVAL_UI * 1000

    local GetWindowWidth = japi.GetWindowWidth
    local GetWindowHeight = japi.GetWindowHeight
    local IsWindowMode = japi.IsWindowMode
    local SetWindowSize = japi.SetWindowSize

    mt.timerUI = ac.loop(refreshInterval, function()
        for _, act in ipairs(uiActs) do
            act()
        end

        if code.checkIsReply() == 1 then
            local w, h = GetWindowWidth(), GetWindowHeight()
            if w / h ~= 16 / 9 and (IsWindowMode()) then
                SetWindowSize(w, w * 9 / 16)
                -- SetWindowSize(h / 9 * 16, h)

                -- gdebug('adjust ui window')
                -- local initX, initY = japi.GetWindowX(), japi.GetWindowY() - japi.GetWindowHeight()
                -- local x, y = initX - math.floor((w - GetWindowWidth()) / 2),
                --     initY - math.floor((h - GetWindowHeight()) / 2)
                -- if x < 0 then
                --     x = 0
                -- end
                -- if y < 0 then
                --     y = 0
                -- end

                -- japi.SetWindowPos(0, x, y, 0, 0, 0x0001)
            end
        end

    end)

    local refreshInterval = FRAME_INTERVAL_NORMAL * 1000
    mt.timerUIFast = ac.loop(refreshInterval, function()
        for _, act in ipairs(uiActsFast) do
            act()
        end
    end)

end
--------------------------------------------------------------------------------------
function mt:resetLootInterval(interval)
    local refreshInterval = interval * 1000
    mt.timer:remove()

    mt.timer = ac.loop(refreshInterval, function()
        for _, act in ipairs(enums) do
            act()
        end
    end)
    FRAME_INTERVAL_NORMAL = interval
end
--------------------------------------------------------------------------------------
mt:init()
mt:registerTickLoop('projLoop', as.projManager.update)
mt:registerTickLoop('lightningLoop', ac.lightning.update)
--------------------------------------------------------------------------------------
mt:registerUILoop('unitInfoLoop', GUI.UnitInfo.update)
mt:registerUILoop('playerChatLoop', GUI.PlayerChat.update)
mt:registerUILoop('hpBarLoop', class.hpBar.updateAllBoard)
mt:registerUILoop('heroHpBarLoop', class.heroHpBar.updateAllBoard)
mt:registerUILoop('bossHpBarLoop', class.bossHpBar.updateAllBoard)
mt:registerUILoop('finalHpBarLoop', class.finalHpBar.updateAllBoard)
mt:registerUILoop('updateProgressCircles', GUI.SkillBtn.updateProgressCircles)
mt:registerUILoop('eliteHpBarLoop', class.eliteEnemyHpBar.updateAllBoard)
mt:registerUILoop('UISequenceFrame', GUI.SequenceFrame.update)
mt:registerUILoop('debuffTimerLoop', class.debuffTimer.updateAllBoard)
mt:registerUILoop('UIHelperLoop', uiHelper.update)
--------------------------------------------------------------------------------------
mt:registerUIFastLoop('--', GUI.PickBlessPanel.updateFrame)
mt:registerUIFastLoop('UISequenceFrameFast', GUI.SequenceFrame.updateFast)
mt:registerUIFastLoop('flowTextLoop', class.flowtext_number.updateAllBoard)
mt:registerUIFastLoop('UIHelperLoopFast', uiHelper.updateFast)
--------------------------------------------------------------------------------------
-- as.loops:registerTickLoop('dmgDelay', as.damage.update)

return mt
