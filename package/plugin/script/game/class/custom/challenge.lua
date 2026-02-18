local mt = {}
Challenge = mt

mt.currentCd = 0
mt.loopList = {}
mt.hardLv = 1
mt.autoStart = false

mt.__index = mt
--------------------------------------------------------------------------------------
function mt:new(keys)
    local o = {}
    setmetatable(o, keys.challengePack)

    o:onNew(keys)

    return o
end
--------------------------------------------------------------------------------------
function mt:onNew(keys)
    self.player = keys.player
    self.currentCd = self.startCd

    self.enemyGroup = {}
    self.bStart = false

    table.insert(mt.loopList, self)
end
--------------------------------------------------------------------------------------
function mt:onRegister(pack)
    reg:addToPool('challenge_list', pack)
    reg:addToPool(str.format('challenge_class_%s', pack.type), pack)
    fc.setAttr('challenge_pack', pack.name, pack)
    setmetatable(pack, Challenge)
end
--------------------------------------------------------------------------------------
function mt:onTryStart()

    if self.player.hero and self.player.hero.isFishing then
        msg.notice(self.player, '钓鱼期间不可以开启挑战。')
        return
    end

    gdebug('challegne on Try Start, now cd: ' .. self.currentCd .. 'name: ' .. self.name)
    if self.currentCd > 0 then
        return
    end

    self.currentCd = self.cd
    if fc.getAttr(self.player, "赶时间") then
        -- gdebug("trigger 赶时间")
        self.currentCd = math.floor(self.currentCd * 0.9)
    end

    if fc.getAttr(self.player, "上古法袍") then
        -- gdebug("trigger 赶时间")
        self.currentCd = math.floor(self.currentCd * 0.95)
    end


    if self.onStart then
        self:onStart(self.player, self.hardLv)
        self.hardLv = self.hardLv

        if self.player:isLocal() then
            GUI.ChallengePanel:updateBoard()
        end
        sound.playToPlayer(glo.gg_snd_challenge_start, self.player, 1, 0, true)
    end

    return self.currentCd
end
--------------------------------------------------------------------------------------
function mt:onTryStop()
    if self.bStart then
        self:onToggleStart()
    end
end
--------------------------------------------------------------------------------------
function mt:onToggleStart()
    if not self.bStart then
        if self.player.hero and self.player.hero.isFishing then
            msg.notice(self.player, '钓鱼期间不可以开启挑战。')
            return
        end
        
        if self.player.hero:isDead() then
            msg.notice(self.player, '英雄阵亡时无法进行冲层。')
            return
        end

        if not self:checkCondition() then
            msg.notice(self.player, '暂不满足开启挑战条件。')
            return
        end

        self.bStart = true
        self:onStart(self.player, self.hardLv)


    else
        self:onTryClearChallenge()
        self.bStart = false
    end

    return self.bStart
end
--------------------------------------------------------------------------------------
function mt:getInfo()
    local info = self:getInfoStats({
        hardLv = self.hardLv,
    })
    return info
end
--------------------------------------------------------------------------------------
function mt:onToggleAutoStart()
    self.autoStart = not self.autoStart
end
--------------------------------------------------------------------------------------
function mt:onLoop()
    if self.currentCd > 0 then
        self.currentCd = self.currentCd - 1
    end

    if self.currentCd <= 0 and self.autoStart then
        self:onTryStart()
    end

end
--------------------------------------------------------------------------------------
function mt:startLoop()

    mt.timer = ac.loop(ms(1), function()
        if gm.gameStarted then
            for i, challenge in ipairs(mt.loopList) do

                xpcall(function()
                    challenge:onLoop()
                end, traceError)
            end
        end

    end)
end
--------------------------------------------------------------------------------------
function mt:checkCondition()
    -- print('check relic default true condition')
    return true
end
--------------------------------------------------------------------------------------
mt.startLoop()
--------------------------------------------------------------------------------------
return mt
