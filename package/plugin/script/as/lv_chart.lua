local mt = {}
LevelChart = mt

mt.__index = mt
mt.chartData = nil
mt.exp = 0
mt.lv = 0
mt.extraLv = 0
mt.maxLv = 0
--------------------------------------------------------------------------------------
function mt:new(chartData)
    local o = {}
    setmetatable(o, self)

    o.chartData = chartData
    return o
end
--------------------------------------------------------------------------------------
function mt:addExp(amt)
    self.exp = self.exp + amt
    self:updateLv()
    self.maxLv = #self.chartData

    return self.exp
end
--------------------------------------------------------------------------------------
function mt:updateLv()
    local newLv = self.lv
    for testLv, expReq in ipairs(self.chartData) do
        if self.exp >= expReq then
            newLv = testLv
        else
            break
        end
    end

    self.lv = newLv
end
--------------------------------------------------------------------------------------
function mt:getLvByGivenExp(val)
    
    local newLv = 0
    for testLv, expReq in ipairs(self.chartData) do
        if val >= expReq then
            newLv = testLv
        else
            break
        end
    end

    return newLv
end
--------------------------------------------------------------------------------------
function mt:getLv()
    return self.lv
end
--------------------------------------------------------------------------------------
function mt:addExtraLv(val)    
    self.extraLv = self.extraLv + val
end
--------------------------------------------------------------------------------------
function mt:getMergeLv()
    return self.lv + self.extraLv
end
--------------------------------------------------------------------------------------
function mt:getCurrentPhaseExp()
    if self.lv >= self.maxLv then
        return self.chartData[self.maxLv]
    end
    return self.exp - self.chartData[self.lv]
end
--------------------------------------------------------------------------------------
function mt:getCurrentPhaseNextLvExpNeed()
    local nextLv = self.lv + 1
    if self.lv >= self.maxLv then
        return self.chartData[self.lv]
    end

    return self.chartData[self.lv + 1] - self.chartData[self.lv]
end
--------------------------------------------------------------------------------------