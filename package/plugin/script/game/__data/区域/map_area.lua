require 'game.class.base.rect_area'

local mt = {}
MapArea = mt

mt.centerPoint = nil

mt.playerAngle = {
    [1] = 135,
    [2] = 45,
    [3] = 315,
    [4] = 225,
}

mt.shopAngle = {
    [1] = 125,
    [2] = 35,
    [3] = 305,
    [4] = 215,
}

mt.shopDirection = {
    [1] = 0,
    [2] = 270,
    [3] = 180,
    [4] = 90,
}

mt.shopInterval = 700

mt.__index = mt
--------------------------------------------------------------------------------------
function mt:new(keys)
    local o = {}
    local pack = fc.getAttr('map_area', keys.name)

    if not pack then
        error('no map area pack: ' .. keys.name)
        return
    end

    setmetatable(o, pack)

    o:onNew(keys)

    return o
end
--------------------------------------------------------------------------------------
function mt:onNew(keys)
    local centerX = self.startX + self.length / 2
    local centerY = self.startY + self.length / 2

    self.centerPoint = ac.point:new(centerX, centerY)
    -- self.testPoint = fc.polarPoint(self.centerPoint, 2300, 90)
    -- fc.pointEffect({
    --     model = [[Abilities\Weapons\WitchDoctorMissile\WitchDoctorMissile.mdl]],
    --     size = 5,
    --     time = -1
    -- }, self.centerPoint)

    self.cornerCenter = {}
    for i = 1, 4 do
        self.cornerCenter[i] = fc.polarPoint(self.centerPoint, 4200, self.playerAngle[i])
        -- fc.pointEffect({
        --     model = [[Abilities\Weapons\WitchDoctorMissile\WitchDoctorMissile.mdl]],
        --     size = 3,
        --     time = -1
        -- }, self.cornerCenter[i])
    end

    self.centerArea = RectArea:newByCenter(self.centerPoint, 5000, 5000)
    self.cornerArea = {}
    for i = 1, 4 do
        self.cornerArea[i] = RectArea:newByCenter(self.cornerCenter[i], 1500, 1500)
    end

    self.rewardPoint = {}
    -- self.rewardPointBodyReform = {}
    self.rewardPointEquip = {}
    for i = 1, 4 do

        -- self.rewardPoint[i] = fc.polarPoint(self.rewardAnchor[i], 0, self.playerAngle[i] - 135)
        self.rewardPoint[i] = self.reward_point_main[i]

        -- self.rewardPointEquip[i] = fc.polarPoint(self.rewardPoint[i], 600, self.playerAngle[i] - 135)
        self.rewardPointEquip[i] = self.reward_point_equip[i]

        -- for j = 1, 4 do
        --     local edge = fc.polarPoint(self.rewardPointEquip[i], 280, j * 90 + 45)

        --     fc.pointEffect({
        --         model = [[Doodads\Cinematic\GlowingRunes\GlowingRunes1.mdl]],
        --         size = 1.5,
        --         time = -1,
        --     }, edge)
        -- end

        -- for j = 1, 4 do
        --     local edge = fc.polarPoint(self.rewardPoint[i], 280, j * 90 + 45)

        --     fc.pointEffect({
        --         model = [[Doodads\Cinematic\GlowingRunes\GlowingRunes3.mdl]],
        --         size = 1.5,
        --         time = -1,
        --     }, edge)
        -- end

        -- self.rewardPointBodyReform[i] = fc.polarPoint(self.rewardPointEquip[i], 600, self.playerAngle[i] - 135)
        -- for j = 1, 4 do
        --     local edge = fc.polarPoint(self.rewardPointBodyReform[i], 300, j * 90 + 45)

        --     fc.pointEffect({
        --         model = [[Doodads\Cinematic\GlowingRunes\GlowingRunes2.mdl]],
        --         size = 1.5,
        --         time = -1,
        --     }, edge)
        -- end


    end

    -- for i = 1, 4 do
    --     local centerEdge = fc.polarPoint(centerPoint, centerSideLength / 2, i * 90)

    --     -- fc.pointEffect({
    --     --     model = [[Abilities\Weapons\WitchDoctorMissile\WitchDoctorMissile.mdl]],
    --     --     size = 3,
    --     --     time = -1
    --     -- }, centerEdge)
    -- end

    -- for i = 1, 4 do
    --     local cornerCenter = self.cornerCenter[i]
    --     for j = 1, 4 do
    --         local cornerEdge = fc.polarPoint(cornerCenter, cornerSideLength / 2, j * 90)
    --         -- fc.pointEffect({
    --         --     model = [[Abilities\Weapons\WitchDoctorMissile\WitchDoctorMissile.mdl]],
    --         --     size = 3,
    --         --     time = -1
    --         -- }, cornerEdge)
    --     end

    -- end

end
--------------------------------------------------------------------------------------
function mt:setInUse()
    local startX = self.startX
    local startY = self.startY
    local length = self.length

    local leftDownX = startX
    local leftDownY = startY
    local leftUpX = startX
    local yExpand = 500
    local leftUpY =  startY + length + yExpand
    local rightUpX = startX + length
    local rightUpY =  startY + length + yExpand
    local rightDownX = startX + length
    local rightDownY = startY
    -- SetCameraBounds(leftDownX, leftDownY, leftUpX, leftUpY, rightUpX, rightUpY, rightDownX, rightDownY)

    -- code.setMiniMapIcon([[war3mappreview.tga]])

    for _, p in ipairs(fc.getAlivePlayers()) do
        -- p:moveCamera(self.centerPoint)
        p:onSelectMapArea()
    end

    self:containPoint(self.centerPoint)

end
--------------------------------------------------------------------------------------
function mt:getHeroBornPoint(player)
    local pId = player.id

    local point = fc.polarPoint(self.centerPoint, 300, self.playerAngle[pId])

    return point
end
--------------------------------------------------------------------------------------
function mt:getMaidBornPoint(player)
    local pId = player.id

    local point = fc.polarPoint(self.centerPoint, 2600, self.playerAngle[pId])

    return point
end
--------------------------------------------------------------------------------------
function mt:getCornerAreaCenter(player)
    local pId = player.id
    return self.cornerCenter[pId]
end
--------------------------------------------------------------------------------------
function mt:getRewardPoint(player)
    local pId = player.id
    return self.rewardPoint[pId]
end
--------------------------------------------------------------------------------------
function mt:getRewardPointEquip(player)
    local pId = player.id
    return self.rewardPointEquip[pId]
end
--------------------------------------------------------------------------------------
function mt:getRewardPointBodyReform(player)
    local pId = player.id
    -- return self.rewardPointBodyReform[pId]
    return self.rewardPoint[pId]
end
--------------------------------------------------------------------------------------
function mt:getCornerAreaCorner(player)
    local pId = player.id

    local point = fc.polarPoint(self.centerPoint, 5000, self.playerAngle[pId])

    return point
end
--------------------------------------------------------------------------------------
function mt:getOppositeCornerAreaCorner(player)
    local pId = player.id

    local point = fc.polarPoint(self.centerPoint, 5000, self.playerAngle[pId] + 180)

    return point
end
--------------------------------------------------------------------------------------
function mt:getShopPosition(keys)
    local pId = keys.pId
    local shopId = keys.shopId

    local shopKey = str.format('shop_point_%d', shopId)

    local point

    if self[shopKey] then
        point = self[shopKey][pId]
        gdebug('shop pos 11111')
    else
        local point0 = fc.polarPoint(self.centerPoint, 3000, self.shopAngle[pId])
        point = fc.polarPoint(point0, self.shopInterval * (shopId - 1) + 950, self.shopDirection[pId])
        gdebug('shop pos 22222')
    end

    return point
end
--------------------------------------------------------------------------------------
function mt:containPoint(point)
    local centerPoint = self.centerPoint

    if self.centerArea:containPoint(point) then
        gdebug('center area contain point')
        return true
    end

    for i = 1, 4 do
        if self.cornerArea[i]:containPoint(point) then
            gdebug('side area contain point')
            return true
        end
    end

    return false
end
--------------------------------------------------------------------------------------
function mt:findClosestPointInMapArea(point)
    local x, y = point[1], point[2]

    local tgtPoint = self.centerPoint
    local distance = 99999

    local safePoint, safeDistance = self:findClosestPointInRectArea(point, self.centerArea)
    if safeDistance <= distance then
        distance = safeDistance
        tgtPoint = safePoint
    end

    for i = 1, 4 do
        local safePoint, safeDistance = self:findClosestPointInRectArea(point, self.cornerArea[i])
        if safeDistance <= distance then
            distance = safeDistance
            tgtPoint = safePoint
        end
    end

    return tgtPoint
end
--------------------------------------------------------------------------------------
function mt:findClosestPointInRectArea(point, area)
    local x, y = point[1], point[2]
    local safePointX = math.clamp(x, area.startX, area.endX)
    local safePointY = math.clamp(y, area.startY, area.endY)
    local safePoint = ac.point:new(safePointX, safePointY)
    local safeDistance = point * safePoint

    return safePoint, safeDistance
end
--------------------------------------------------------------------------------------
function mt:onRegister(pack)
    fc.setAttr('map_area', pack.name, pack)
    setmetatable(pack, MapArea)
end
--------------------------------------------------------------------------------------
return mt
