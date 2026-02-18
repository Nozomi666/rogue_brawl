local mt = {}
mt.__index = mt
--------------------------------------------------------------------------------------
mt.MISSION_LIST = {}

--------------------------------------------------------------------------------------
mt.player = nil
mt.score = 0
mt.rmbScore = 0
--------------------------------------------------------------------------------------
function mt:new(p)
    -- init table
    local o = {}
    setmetatable(o, mt)
    --------------------------------------------------------------------------------------
    o.player = p

    -- o:calcTicketScore()
    o.score = o.score + 50

    return o
end
--------------------------------------------------------------------------------------
function mt:modScore(amt)
    gdebug('store manager mod score from %d, +%d', self.score, amt)
    self.score = self.score + amt
    return self.score
end
--------------------------------------------------------------------------------------
function mt:getScore()
    if localEnv then
        return 2700
    end

    if self.player:getPlatformName() == '绵绵绵绵丶#5296' then 
        return self.score + 900
    end

    return self.score
end
--------------------------------------------------------------------------------------
function mt:modRMBScore(amt)
    gdebug('store manager mod rmb score from %d, +%d', self.rmbScore, amt)
    self.rmbScore = self.rmbScore + amt
    return self.rmbScore
end
--------------------------------------------------------------------------------------
function mt:getRMBScore()
    return self.rmbScore
end
--------------------------------------------------------------------------------------
function mt:calcTicketScore()
    local player = self.player
    local ticketNum = GetLotteryUsedCount(player.handle)
    gdebug('store ticket num %d', ticketNum)

    self.rmbScore = self.rmbScore + ticketNum * 8

end
--------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------
return mt
