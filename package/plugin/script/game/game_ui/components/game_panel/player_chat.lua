--------------------------------------------------------------------------------------
class.player_chat = extends(class.panel) {

    new = function(parent)
        -- 底图是一张黑色的图片 这个可以写死
        local panel = class.panel.new(parent, nil, 1, 1, 1, 1)
        -- 改变panel对象的类
        panel.__index = class.player_chat
        panel:construct()
        panel:draw()
        panel:show()
        return panel
    end

}
local mt = class.player_chat
------------------------------------------------------------------------------------
function mt:measure()
    self.x1 = 0.065
    self.y1 = 0.19

    self.dx2 = -20

end
--------------------------------------------------------------------------------------
function mt:draw()
    self:measure()

    self.msgFrame[1]:set_control_size(300, 10)
    fc.setFramePosPct(self.msgFrame[1], ANCHOR.LEFT, MAIN_UI, ANCHOR.LEFT, self.x1, self.y1)

    for i = 2, 10 do
        local msgFrame = self.msgFrame[i]
        local prevFrame = self.msgFrame[i - 1]
        msgFrame:set_control_size(300, 10)
        fc.setFramePos(msgFrame, ANCHOR.LEFT, prevFrame, ANCHOR.LEFT, 0, self.dx2)
    end

end
--------------------------------------------------------------------------------------
function mt:construct()

    self.msgFrame = {}
    for i = 1, 10 do
        local textFrame = self:add_text('', 0, 0, 1, 1, 12, 'left')
        self.msgFrame[i] = textFrame
    end

    self.msgList = linked.create()

    -- reg:addToPool('ui_render_list', self)
end
--------------------------------------------------------------------------------------
function mt:updateFrames()
    local msgList = self.msgList

    local msgEntry = msgList:at(1)

    -- print('update frame: ' .. msgEntry.word)
    local i = 1
    while msgEntry do
        if i <= 10 then
            self.msgFrame[i]:set_text(msgEntry.word)
            self.msgFrame[i].currentEntry = msgEntry
            msgEntry = msgList:next(msgEntry)
            i = i + 1
        else
            local removeEntry =msgEntry
            msgEntry = msgList:next(msgEntry)
            msgList:remove(removeEntry)
            -- print('remove entry: ' .. removeEntry.word)
        end

    end

    for j = i, 10 do
        self.msgFrame[j]:set_text('')
    end

end
--------------------------------------------------------------------------------------
function mt:newMessage(word)
    local msgEntry = {
        word = word,
        opacity = 1,
    }

    self.msgList:add(msgEntry, 1)

    self:updateFrames()

    ac.wait(ms(10), function ()
        local opacity = 1
        ac.timer(ms(0.1), 10, function ()
            opacity = opacity - 0.1
            msgEntry.opacity = opacity
            -- if opacity <= 0 then
            --     self.msgList:remove(msgEntry)
            -- end
        end)
    end)

    self:update()

end
--------------------------------------------------------------------------------------
function mt.update()
    local self = GUI.PlayerChat
    for i = 1, 10 do
        local msgFrame = self.msgFrame[i]
        local currentEntry = msgFrame.currentEntry
        if currentEntry then
            msgFrame:set_alpha(currentEntry.opacity)
        end
    end
end
------------------------------------------------------------------------------------
GUI.PlayerChat = mt.create()
GUI.PlayerChat:show()
--------------------------------------------------------------------------------------
return mt
