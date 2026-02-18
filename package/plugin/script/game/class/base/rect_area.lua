local mt = {}
mt.__index = mt
RectArea = mt

mt.centerPoint = nil

--------------------------------------------------------------------------------------
function mt:newByCenter(centerPoint, w, h)
    local o = {}
    setmetatable(o, mt)

    local centerX, centerY = centerPoint[1], centerPoint[2]

    local startX = centerX - w / 2
    local startY = centerY - h / 2
    local endX = centerX + w / 2
    local endY = centerY + h / 2

    o.startX = startX
    o.startY = startY
    o.endX = endX
    o.endY = endY
    o.centerPoint = centerPoint

    return o

end
--------------------------------------------------------------------------------------
function mt:containPoint(point)
    local x, y = point[1], point[2]

    return self.startX <= x and x <= self.endX and self.startY <= y and y <= self.endY
end
--------------------------------------------------------------------------------------
function mt:getRngPoint(margin)
    margin = margin or 0

    local minX = self.startX + margin
    local minY = self.startY + margin
    local maxX = self.endX - margin
    local maxY = self.endY - margin

    local rngPoint = ac.point:new(math.random(math.floor(minX), math.floor(maxX)),
        math.random(math.floor(minY), math.floor(maxY)))
    return rngPoint
end

--------------------------------------------------------------------------------------

return mt
