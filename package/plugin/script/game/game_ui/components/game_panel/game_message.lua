--------------------------------------------------------------------------------------
class.game_message = extends(class.panel) {

    new = function(parent)
        -- 底图是一张黑色的图片 这个可以写死
        local panel = class.panel.new(parent, nil, 1, 1, 1, 1)
        -- 改变panel对象的类
        panel.__index = class.game_message
        panel:construct()
        panel:draw()
        panel:show()
        return panel
    end,

}
local mt = class.game_message
------------------------------------------------------------------------------------
function mt:measure()

end
--------------------------------------------------------------------------------------
function mt:draw()
    self:measure()

end
--------------------------------------------------------------------------------------
function mt:construct()
    -- for i = 1, 10 do
    --     local textFrame = self:add_text('', 0, 0, 1, 1, 12, 'left')
    --     self.msgFrame[i] = textFrame
    -- end

    self.msgList = linked.create()

    -- reg:addToPool('ui_render_list', self)
end
--------------------------------------------------------------------------------------
function mt:newMessage(messageType, player, word, time)

    local msgEntry = self:add_texture([[UI\misc\game_mseesage_base.tga]], 0, 0, 150, 34)
    msgEntry.msgText = msgEntry:add_text('', 0, 0, 1, 1, 11, 'left')
    msgEntry.msgText:set_control_size(300, 20)
    msgEntry.msgText:set_text(word)
    msgEntry.opacity = 0
    msgEntry.currentIndex = 0
    msgEntry.isLocal = false
    msgEntry.enterProgress = 0
    msgEntry:hide()

    self.msgList:add(msgEntry, 1)

    if player == cst.ALL_PLAYERS or player:isLocal() then

        -- self:updateList()
        msgEntry:show()
        msgEntry.isLocal = true
        local msgList = self.msgList
        local listEntry = msgList:at(1)
        while listEntry do
            if listEntry then
                listEntry.currentIndex = listEntry.currentIndex + 1
            end
            listEntry = msgList:next(listEntry)
        end

        -- DisplayTimedTextToPlayer(player.handle, 0, 0, time, 'add message: ' .. word)
        self:update(true)

    end

    -- local time = 4

    ac.wait(ms(time), function()
        local opacity = 1
        ac.loop(ms(0.03), function(t)
            opacity = opacity - 0.09
            msgEntry.opacity = opacity
            msgEntry.quitProgress = 1 - opacity
            if opacity <= 0 then
                -- if msgEntry.isLocal then

                --     -- DisplayTimedTextToPlayer(player.handle, 0, 0, time, 'tiem up: ' .. word)
                -- end
                self.msgList:remove(msgEntry)
                t:remove()
            end
        end)
    end)

end
--------------------------------------------------------------------------------------
function mt.update(notAutoUpdate)

    local self = GUI.GameMessage

    local msgList = self.msgList
    local listEntry = msgList:at(1)
    -- gdebug('msgList count: %d', #msgList)
    while listEntry do
        local currentIndex = listEntry.currentIndex
        local needUpdatePos = false
        if currentIndex > 12 or (not listEntry.isLocal) then
            listEntry:hide()
        else
            listEntry:show()
            needUpdatePos = true
        end

        if needUpdatePos then
            local x = 145
            local y = 100 + (currentIndex - 1) * -34
            if listEntry.quitProgress then
                x = 145 + -75 * listEntry.quitProgress
            end

            if listEntry.enterProgress then
                if not notAutoUpdate then
                    listEntry.enterProgress = listEntry.enterProgress + 0.2
                end
                x = 145 + 37.5 * (1 - listEntry.enterProgress)
                listEntry.opacity = math.min(1 * listEntry.enterProgress, 1)
                if listEntry.enterProgress >= 1 then
                    listEntry.enterProgress = nil
                end
            end

            -- DisplayTimedTextToPlayer(fc.getLocalPlayer().handle, 0, 0, 10, 'currentIndex: ' .. currentIndex)
            listEntry:set_width(listEntry.msgText:get_width() * 1.25 + 10)
            fc.setFramePos(listEntry, ANCHOR.TOP_LEFT, MAIN_UI, ANCHOR.LEFT, x, y)
            fc.setFramePos(listEntry.msgText, ANCHOR.LEFT, listEntry, ANCHOR.LEFT, 2, 0)
            listEntry:set_alpha(listEntry.opacity)
        end

        listEntry = msgList:next(listEntry)
    end

end
------------------------------------------------------------------------------------
GUI.GameMessage = mt.create()
GUI.GameMessage:show()
--------------------------------------------------------------------------------------
return mt
