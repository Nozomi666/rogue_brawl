--------------------------------------------------------------------------------------
class.multiUsePanel = extends(class.panel) {

    new = function(parent)
        -- 底图是一张黑色的图片 这个可以写死
        local panel = class.panel.new(parent, [[multi_base.tga]], 0, 0, 1, 1)
        -- 改变panel对象的类
        panel.__index = class.multiUsePanel
        panel:construct()
        panel:draw()
        panel:show()
        return panel
    end

}
local mt = class.multiUsePanel
------------------------------------------------------------------------------------
function mt:measure()
    self.x1 = -0.1715
    self.y1 = 0.055

    self.w1 = 326
    self.h1 = 190

end
--------------------------------------------------------------------------------------
function mt:draw()
    self:measure()
    self:set_control_size(self.w1, self.h1)
    fc.setFramePosPct(self, ANCHOR.TOP_LEFT, MAIN_UI, ANCHOR.TOP_RIGHT, self.x1, self.y1)
    fc.setFramePos(self.cover, ANCHOR.TOP_CENTER, self, ANCHOR.TOP_CENTER, 0, 0)
    fc.setFramePosPct(self.v, ANCHOR.TOP_LEFT, self, ANCHOR.TOP_CENTER, -0.08, 0.006)
    --fc.setFramePosPct(self.gameTimeTip, ANCHOR.TOP_RIGHT, self, ANCHOR.TOP_CENTER, 0.065, 0.006)

    fc.setFramePosPct(self.p1name, ANCHOR.TOP_LEFT, self, ANCHOR.TOP_CENTER, -0.08, 0.055)
    fc.setFramePosPct(self.p1fp, ANCHOR.TOP_CENTER, self, ANCHOR.TOP_CENTER, -0.024, 0.055)
    fc.setFramePosPct(self.p1kill, ANCHOR.TOP_CENTER, self, ANCHOR.TOP_CENTER, 0.016, 0.055)
    fc.setFramePosPct(self.p1lv, ANCHOR.TOP_CENTER, self, ANCHOR.TOP_CENTER, 0.045, 0.055)
    fc.setFramePosPct(self.p1mt, ANCHOR.TOP_CENTER, self, ANCHOR.TOP_CENTER, 0.067, 0.055)

    fc.setFramePosPct(self.p2name, ANCHOR.TOP_LEFT, self, ANCHOR.TOP_CENTER, -0.08, 0.08)
    fc.setFramePosPct(self.p2fp, ANCHOR.TOP_CENTER, self, ANCHOR.TOP_CENTER, -0.024, 0.08)
    fc.setFramePosPct(self.p2kill, ANCHOR.TOP_CENTER, self, ANCHOR.TOP_CENTER, 0.016, 0.08)
    fc.setFramePosPct(self.p2lv, ANCHOR.TOP_CENTER, self, ANCHOR.TOP_CENTER, 0.045, 0.08)
    fc.setFramePosPct(self.p2mt, ANCHOR.TOP_CENTER, self, ANCHOR.TOP_CENTER, 0.067, 0.08)

    fc.setFramePosPct(self.p3name, ANCHOR.TOP_LEFT, self, ANCHOR.TOP_CENTER, -0.08, 0.105)
    fc.setFramePosPct(self.p3fp, ANCHOR.TOP_CENTER, self, ANCHOR.TOP_CENTER, -0.024, 0.105)
    fc.setFramePosPct(self.p3kill, ANCHOR.TOP_CENTER, self, ANCHOR.TOP_CENTER, 0.016, 0.105)
    fc.setFramePosPct(self.p3lv, ANCHOR.TOP_CENTER, self, ANCHOR.TOP_CENTER, 0.045, 0.105)
    fc.setFramePosPct(self.p3mt, ANCHOR.TOP_CENTER, self, ANCHOR.TOP_CENTER, 0.067, 0.105)

    fc.setFramePosPct(self.p4name, ANCHOR.TOP_LEFT, self, ANCHOR.TOP_CENTER, -0.08, 0.13)
    fc.setFramePosPct(self.p4fp, ANCHOR.TOP_CENTER, self, ANCHOR.TOP_CENTER, -0.024, 0.13)
    fc.setFramePosPct(self.p4kill, ANCHOR.TOP_CENTER, self, ANCHOR.TOP_CENTER, 0.016, 0.13)
    fc.setFramePosPct(self.p4lv, ANCHOR.TOP_CENTER, self, ANCHOR.TOP_CENTER, 0.045, 0.13)
    fc.setFramePosPct(self.p4mt, ANCHOR.TOP_CENTER, self, ANCHOR.TOP_CENTER, 0.067, 0.13)

end
--------------------------------------------------------------------------------------
function mt:construct()
    local player
    self.cover = self:add_texture([[multi_cover.tga]], 0, 0, 326, 29)
    if not MAP_DEBUG_MODE then
        self.vtext = str.format('版本号: %s', gm.version)
        self.v = self:add_text(str.format('版本号: %s', gm.version), 0, 0, 1, 1, 9)
    else
        self.vtext = str.format('测试版: %s', gm.version)
        self.v = self:add_text(str.format('测试版: %s', gm.version), 0, 0, 1, 1, 9)
    end

    --self.gameTimeTip = self:add_text('|cffffcc00游戏时间：|r0 分 0 秒', 0, 0, 1, 1, 9)

    local player
    self.p1name = self:add_text('', 0, 0, 1, 1, 8, 'topleft')
    self.p1fp = self:add_text('', 0, 0, 1, 1, 8)
    self.p1kill = self:add_text('', 0, 0, 1, 1, 8)
    self.p1lv = self:add_text('', 0, 0, 1, 1, 8)
    self.p1mt = self:add_text('', 0, 0, 1, 1, 8)
    player = as.player:getPlayerById(1)
    if player:isOnline() then
        self.p1name:set_text(player:getName())
        self.p1fp:set_text('0')
        self.p1kill:set_text('0')
        self.p1killnum = 0
        self.p1lv:set_text('1')
        self.p1mt:set_text('0')
    end

    self.p2name = self:add_text('', 0, 0, 1, 1, 8)
    self.p2fp = self:add_text('', 0, 0, 1, 1, 8)
    self.p2kill = self:add_text('', 0, 0, 1, 1, 8)
    self.p2lv = self:add_text('', 0, 0, 1, 1, 8)
    self.p2mt = self:add_text('', 0, 0, 1, 1, 8)
    player = as.player:getPlayerById(2)
    if player:isOnline() then
        self.p2name:set_text(player:getName())
        self.p2fp:set_text('0')
        self.p2kill:set_text('0')
        self.p2killnum = 0
        self.p2lv:set_text('1')
        self.p2mt:set_text('0')
    end

    self.p3name = self:add_text('', 0, 0, 1, 1, 8)
    self.p3fp = self:add_text('', 0, 0, 1, 1, 8)
    self.p3kill = self:add_text('', 0, 0, 1, 1, 8)
    self.p3lv = self:add_text('', 0, 0, 1, 1, 8)
    self.p3mt = self:add_text('', 0, 0, 1, 1, 8)
    player = as.player:getPlayerById(3)
    if player:isOnline() then
        self.p3name:set_text(player:getName())
        self.p3fp:set_text('0')
        self.p3kill:set_text('0')
        self.p3killnum = 0
        self.p3lv:set_text('1')
        self.p3mt:set_text('0')
    end

    self.p4name = self:add_text('', 0, 0, 1, 1, 8)
    self.p4fp = self:add_text('', 0, 0, 1, 1, 8)
    self.p4kill = self:add_text('', 0, 0, 1, 1, 8)
    self.p4lv = self:add_text('', 0, 0, 1, 1, 8)
    self.p4mt = self:add_text('', 0, 0, 1, 1, 8)
    player = as.player:getPlayerById(4)
    if player:isOnline() then
        self.p4name:set_text(player:getName())
        self.p4fp:set_text('0')
        self.p4kill:set_text('0')
        self.p4killnum = 0
        self.p4lv:set_text('1')
        self.p4mt:set_text('0')
    end

end
--------------------------------------------------------------------------------------
function mt:updateFp(player,fp)
    if player.id == 1 then
        self.p1fp:set_text(fp)
    elseif player.id == 2 then
        self.p2fp:set_text(fp)
    elseif player.id == 3 then
        self.p3fp:set_text(fp)
    elseif player.id == 4 then
        self.p4fp:set_text(fp)
    end
end
--------------------------------------------------------------------------------------
function mt:updateKill(player,num)
    if player.id == 1 then
        self.p1killnum = self.p1killnum + num
        player.totalkill = self.p1killnum
        self.p1kill:set_text(string.format('%.0f',self.p1killnum))
    elseif player.id == 2 then
        self.p2killnum = self.p2killnum + num
        player.totalkill = self.p2killnum
        self.p2kill:set_text(string.format('%.0f',self.p2killnum))
    elseif player.id == 3 then
        self.p3killnum = self.p3killnum + num
        player.totalkill = self.p3killnum
        self.p3kill:set_text(string.format('%.0f',self.p3killnum))
    elseif player.id == 4 then
        self.p4killnum = self.p4killnum + num
        player.totalkill = self.p4killnum
        self.p4kill:set_text(string.format('%.0f',self.p4killnum))
    end
end
--------------------------------------------------------------------------------------
function mt:updateLv(player,lv)
    if player.id == 1 then
        self.p1lv:set_text(lv)
    elseif player.id == 2 then
        self.p2lv:set_text(lv)
    elseif player.id == 3 then
        self.p3lv:set_text(lv)
    elseif player.id == 4 then
        self.p4lv:set_text(lv)
    end
end
--------------------------------------------------------------------------------------
function mt:updateMt(player,mt)
    if player.id == 1 then
        self.p1mt:set_text(mt)
    elseif player.id == 2 then
        self.p2mt:set_text(mt)
    elseif player.id == 3 then
        self.p3mt:set_text(mt)
    elseif player.id == 4 then
        self.p4mt:set_text(mt)
    end
end
--------------------------------------------------------------------------------------
function mt:updateTime(msg)
    self.v:set_text(self.vtext .. "    " .. msg)
end
--------------------------------------------------------------------------------------
GUI.multiUsePanel = mt.create()
GUI.multiUsePanel:show()

--------------------------------------------------------------------------------------
return mt