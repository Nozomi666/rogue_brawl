
local mt = {}
mt.__index = mt

mt.list = nil
mt.max = 0

function mt:new()

    -- init table
    local o = {}
    setmetatable(o, self)

    o.list = {}

    return o
end

function mt:addItem(item, weight)
    if weight <= 0 then return end

    self.max = self.max + weight
    table.insert(self.list, item)
end










return mt