local mt = {}
WeightPool = mt
mt.__index = mt

mt.weightList = nil
--------------------------------------------------------------------------------------
function mt:new(tbl)
    local o = {}
    setmetatable(o, mt)

    o:onNew(tbl)

    return o
end
--------------------------------------------------------------------------------------
function mt:onNew(tbl)
    self.weightList = {}
    if tbl then
        for _, entry in ipairs(tbl) do
            if entry[2] ~= 0 then
                self.weightList[#self.weightList + 1] = entry
            else
                --gdebug('weight pool new entry amount is 0, name: %s', entry[1])
            end
        end
    end
end
--------------------------------------------------------------------------------------
function mt:getEntryNum()
    return #self.weightList
end
--------------------------------------------------------------------------------------
function mt:addEntry(name, amount)
    if amount == 0 then
        --gdebug('weight pool add entry amount is 0, name: %s', name)
        return
    end
    self.weightList[#self.weightList + 1] = {name, amount}
end
--------------------------------------------------------------------------------------
function mt:removeEntry(name)
    for i = #self.weightList, 1, - 1 do
        if self.weightList[i].name == name  then
            table.remove(self.weightList, i)
        end
    end
end
--------------------------------------------------------------------------------------
function mt:rngSelect()
    local totalWeight = 0
    for _, entry in ipairs(self.weightList) do
        local entryWeight = entry[2]
        totalWeight = totalWeight + entryWeight
    end

    local rngVal = math.randomReal(0, totalWeight)

    local selectedEntry
    for _, entry in ipairs(self.weightList) do
        local entryWeight = entry[2]
        if rngVal <= entryWeight then
            selectedEntry = entry
            break
        end
        rngVal = rngVal - entryWeight
    end

    if not selectedEntry then
        gdebug('trigger no select entry')
        gdebug('rngVal: ' .. rngVal)
        selectedEntry = self.weightList[1]
    end

    return selectedEntry[1]
end
--------------------------------------------------------------------------------------
function mt:printPool()
    gdebug('权重池分布如下：')
    for _, entry in ipairs(self.weightList) do
        local entryName = entry[1]
        local entryWeight = entry[2]

        if entryWeight then
            gdebug('entryName: %s, entryNum: %.1f', tostring(entryName), entryWeight)
        else
            gdebug('entryName: %s, entryNum: nil', tostring(entryName))
        end

    end
end
--------------------------------------------------------------------------------------
function mt:getWeight(entryName)
    for _, entry in ipairs(self.weightList) do
        if entry[1] == entryName then
            return entry[2]
        end
    end
    return 0
end
--------------------------------------------------------------------------------------
return mt
