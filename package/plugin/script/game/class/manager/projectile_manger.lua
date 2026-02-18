local runtime = require 'jass.runtime'
local dbg = require 'jass.debug'
local error_handle = runtime.error_handle
local mt = {}
mt.__index = mt
as.projManager = mt

mt.frame = 0
mt.frameMax = 990

local bulletList = linked.create()

local gchash = 0

--------------------------------------------------------------------------------------
function mt.init()

    -- 投射物的单位id
    mt.dummyId = 'e000'
    -- 无限循环
    mt.mover_group = {}
end

--------------------------------------------------------------------------------------
-- 添加进循环
function mt.add(mover_data)
    bulletList:add(mover_data)
    -- mt.mover_group[#mt.mover_group + 1] = mover_data
end

function mt.remove(mover_data)
    local removed = bulletList:remove(mover_data)
    -- local removed = table.removeTarget(mt.mover_group, mover_data)
    local body = mover_data.body
    mover_data.projectileRemoved = true
    fc.removeEffect(body)
end

local function mover_move()
    local tbl = {}

    local bullet = bulletList:at(1)
    while bullet do
        tbl[#tbl + 1] = bullet
        bullet = bulletList:next(bullet)
    end

    for _, mover_data in ipairs(tbl) do
        mover_data.tickSuccess = false
        xpcall(function()
            mt.next(mover_data)
            mover_data.tickSuccess = true
        end, traceError)

        if not mover_data.tickSuccess then
            mt.remove(mover_data)
        end

    end
end

--------------------------------------------------------------------------------------
local examError = function()

    -- gdebug('call examerror')
    local tbl = {}
    for _, mover_data in ipairs(mt.mover_group) do
        tbl[#tbl + 1] = mover_data
        -- gdebug('add group 1')
    end

    for i = 1, #tbl do
        -- gdebug('add group 2')
        -- if tbl[i].paused <= 0 then
        if tbl[i].updateFunc then
            -- gdebug('has onupdate')
            if not pcall(tbl[i].updateFunc, tbl[i]) then
                -- gdebug('do remove')
                mt.remove(tbl[i])
            end
        end
        -- end
    end

end
--------------------------------------------------------------------------------------
function mt.update()
    xpcall(mover_move, examError)
end
--------------------------------------------------------------------------------------
local function updateAct_throw(self)
    self.moves = self.moves and self.moves + 1 or 1

    local totalDis = self.point * self.pointT:get_point(true)
    local passPct = self.moves * FRAME_INTERVAL_NORMAL / self.shootTime
    local newAngle = self.point / self.pointT:get_point(true)
    local traveled = passPct * totalDis
    local newPoint = as.point:polarPoint(self.point, traveled, newAngle)
    local x, y = newPoint:get()

    local k = (1 / 4 * totalDis) * (totalDis / self.maxHeight)
    local fly = (1 / k) * (traveled ^ 2) * -1 + totalDis / k * traveled

    local atan = math.atan((fly - self.lastHeight), self.dSpeed) * -1

    japi.EXSetEffectZ(self.body, fly + self.height + self.linerDeltaHeight * passPct)
    -- japi.EXSetEffectZ(self.body, fly)
    japi.EXEffectMatReset(self.body)
    japi.EXSetEffectSize(self.body, self.size)
    japi.EXSetEffectXY(self.body, x, y)
    japi.EXEffectMatRotateY(self.body, atan)
    japi.EXEffectMatRotateZ(self.body, newAngle)

    self.lastHeight = fly

    -- 检测是否够接近
    if passPct >= 1 then
        --------------------------------------------------------------------------------------
        if self.onHit then
            self.onHit(self, self)
        end

        japi.EXSetEffectZ(self.body, self.tgtHeight)
        japi.EXSetEffectXY(self.body, self.pointT[1], self.pointT[2])
        mt.remove(self)
        return
    end
    -- shootTime = 1,
    -- shootAngle = 45,
end
--------------------------------------------------------------------------------------
local function updateAct_backTurn(self)
    local r = self.r
    local tgt = self.tgt
    if not tgt then
        mt.remove(self)
        return
    end

    if tgt.removed then
        mt.remove(self)
        return
    end

    local x_0, y_0 = self.x_0, self.y_0
    local s = self.s + self.ss * FRAME_INTERVAL_NORMAL
    local x_1, y_1 = tgt:getLoc():get()
    if self.microVerse then
        x_1, y_1 = self.microVerse.currentPoint:get()
    end
    local x_2, y_2 = self.x_2, self.y_2
    local time = (math.sqrt((x_1 - x_2) ^ 2 + (y_1 - y_2) ^ 2)) / s
    local d1 = math.sqrt((x_0 - x_2) ^ 2 + (y_0 - y_2) ^ 2)
    local d2 = math.sqrt((x_2 - x_1) ^ 2 + (y_2 - y_1) ^ 2)
    local r = math.min(r + FRAME_INTERVAL_NORMAL * (1 / time), 1)
    local a1 = math.atan(y_2 - y_0, x_2 - x_0)
    local a2 = math.atan(y_1 - y_2, x_1 - x_2)
    local x_3 = x_0 + math.cos(a1) * d1 * r
    local y_3 = y_0 + math.sin(a1) * d1 * r
    local x_4 = x_2 + math.cos(a2) * d2 * r
    local y_4 = y_2 + math.sin(a2) * d2 * r
    local d3 = math.sqrt((x_3 - x_4) ^ 2 + (y_3 - y_4) ^ 2)
    local a3 = math.atan(y_4 - y_3, x_4 - x_3)
    local x_5 = x_3 + math.cos(a3) * d3 * r
    local y_5 = y_3 + math.sin(a3) * d3 * r
    local x_6 = x_3 + math.cos(a3) * (d3 * r + 0.01)
    local y_6 = y_3 + math.sin(a3) * (d3 * r + 0.01)
    local a4 = math.atan(y_6 - y_5, x_6 - x_5)
    self.r = r
    self.s = s

    self.moves = self.moves and self.moves + 1 or 1

    japi.EXEffectMatReset(self.body)
    japi.EXSetEffectSize(self.body, self.size)
    japi.EXSetEffectXY(self.body, x_5, y_5)
    japi.EXEffectMatRotateZ(self.body, a4)
    if r >= 1 then
        if self.onHit then
            self.onHit(self, self)
        end

        mt.remove(self)
    end
end
--------------------------------------------------------------------------------------
local function updateAct_custom(self)
    if self.move then
        self.move(self)
    end

    -- gdebug('call update custom')
    if self.complete then
        mt.remove(self)
    end
end

--------------------------------------------------------------------------------------
local function updateAct_followTarget(self)

    if not self.tgt then
        mt.remove(self)
        return
    end

    if self.tgt.removed then
        mt.remove(self)
        return
    end

    -- 获取单位点
    local p1 = self.point
    local p2 = self.tgt:getloc()
    local angle = p1 / p2

    if self.frame > 150 then
        self.dTurnSpeed = 99
    end

    -- 施加转身速率限制
    self.face = angle

    -- 检测是否够接近
    local dis = p1 * p2
    if dis <= self.hitRange then
        --------------------------------------------------------------------------------------
        if self.onHit then
            xpcall(function()
                self.onHit(self, self)
            end, function(msg)
                print(msg, debug.traceback())
            end)

        end
        japi.EXEffectMatReset(self.body)
        japi.EXSetEffectZ(self.body, self.tgtHeight)
        japi.EXSetEffectXY(self.body, p2[1], p2[2])
        japi.EXEffectMatRotateZ(self.body, self.face)
        mt.remove(self)
        return
    end

    -- 移动
    local newPoint = fc.polarPoint(self.point, self.dSpeed, self.face)
    self.point = newPoint
    local x, y = newPoint:get()

    japi.EXEffectMatReset(self.body)
    japi.EXSetEffectSize(self.body, self.size)
    japi.EXSetEffectXY(self.body, x, y)

    local totalDis = self.totalDis
    local passPct = math.min(self.frame * FRAME_INTERVAL_NORMAL / self.shootTime, 1)
    local traveled = passPct * totalDis

    if self.shootAngle then
        if self.shootAngle > 0 then
            local k = (1 / 4 * totalDis) * (totalDis / self.maxHeight)
            local fly = (1 / k) * (traveled ^ 2) * -1 + totalDis / k * traveled
            local atan = math.atan((fly - self.lastHeight), self.dSpeed) * -1
            japi.EXEffectMatRotateY(self.body, atan)
            japi.EXSetEffectZ(self.body, fly + self.height + self.linerDeltaHeight * passPct)
            self.lastHeight = fly
        else
            self.shootAngle = nil
        end
    else
        japi.EXSetEffectZ(self.body, self.height + self.linerDeltaHeight * passPct)
    end

    japi.EXEffectMatRotateZ(self.body, self.face)

end
--------------------------------------------------------------------------------------
local function updateAct_spin(self)
    local newAngle = self.startAngle + self.dTurnSpeed * self.frame
    local newPoint = as.point:polarPoint(self.follow:getLoc(), self.r, newAngle)
    local x, y = newPoint:get()

    -- 检测是否飞到末尾
    if self.complete or (self.time >= 0 and self.frame * FRAME_INTERVAL_NORMAL > self.time) then
        --------------------------------------------------------------------------------------
        if self.onEnd then
            self.onEnd(self, self)
        end
        mt.remove(self)
        return
    end

    self.point = newPoint
    self.face = self.dTurnSpeed > 0 and (newAngle + 90) or (newAngle - 90)
    japi.EXEffectMatReset(self.body)
    japi.EXSetEffectSize(self.body, self.size)
    japi.EXSetEffectXY(self.body, x, y)
    japi.EXEffectMatRotateZ(self.body, self.face)
end

--------------------------------------------------------------------------------------
local function updateAct_shockWave(self)

    local deltaDistance = self.dSpeed

    if self.flyDistance + deltaDistance >= self.maxRange then
        deltaDistance = self.maxRange - self.flyDistance
    end

    self.flyDistance = self.flyDistance + deltaDistance

    -- 移动
    local newPoint = as.point:polarPoint(self.point, deltaDistance, self.face)

    if false then
        -- if self.allowReflect and (not newPoint:isWalkable()) then
        local oldAngle = self.face
        -- local eff = {
        --     model = [[Abilities\Spells\Other\TalkToMe\TalkToMe.mdl]],
        --     time = 0.1
        -- }
        -- fc.pointEffect(eff, newPoint)
        self.bouns = true
        local a = {}
        local z2 = {}
        local x2 = {}
        local y2 = {}
        local x = {}
        local y = {}
        local f = {}
        local xSpeed = self.dSpeed * math.cos(self.face)
        local ySpeed = self.dSpeed * math.sin(self.face)
        x[0] = newPoint[1]
        y[0] = newPoint[2]
        x[1] = newPoint[1]
        y[1] = newPoint[2]
        for loopA = 1, 8 do
            a[0] = 8 * loopA
            z2[0] = 99999

            for loopB = 1, 12 do
                a[loopB] = 0.5236 * loopB
                x2[loopB] = x[0] + a[0] * Cos(a[loopB])
                y2[loopB] = y[0] + a[0] * Sin(a[loopB])
                local loc = ac.point:new(x2[loopB], y2[loopB])
                if loc:isWalkable() then
                    z2[loopB] = 0
                else
                    z2[loopB] = 5
                end
                -- z2[loopB] = loc:getZ()
            end

            for loopB = 1, 12 do
                if z2[loopB] < z2[0] then
                    z2[0] = z2[loopB]
                end
            end

            for loopB = 1, 12 do
                a[13] = ((z2[loopB] - z2[0]) ^ 2 + a[0] ^ 2) ^ 0.5
                x[1] = x[1] - a[13] * Cos(a[loopB])
                y[1] = y[1] - a[13] * Sin(a[loopB])
            end

        end

        local randomAngleOffset = (math.randomReal(0, 1) - 0.5) * math.pi / 6

        f[0] = Atan2((y[1] - y[0]), (x[1] - x[0]))
        f[1] = Atan2(ySpeed, xSpeed)
        f[1] = 2 * f[0] - f[1] - math.pi + randomAngleOffset
        local newSpeedX = self.dSpeed * Cos(f[1])
        local newSpeedY = self.dSpeed * Sin(f[1])
        local nextMovePoint = ac.point:new(newPoint[1] + newSpeedX, newPoint[2] + newSpeedY)

        local newAngle = newPoint / nextMovePoint

        newPoint = nextMovePoint
        self.face = newAngle

        if self.onReflect then
            self.onReflect(self, self, oldAngle, newAngle)
        end

    end

    self.point = newPoint
    local x, y = newPoint:get()

    japi.EXEffectMatReset(self.body)
    japi.EXSetEffectSize(self.body, self.size)
    japi.EXSetEffectXY(self.body, x, y)
    japi.EXEffectMatRotateZ(self.body, self.face)

    -- 检测是否飞到末尾
    if self.flyDistance >= self.maxRange then
        --------------------------------------------------------------------------------------
        if self.onUpdate then
            self.onUpdate(self, self)
        end

        if self.onEnd then
            self.onEnd(self, self)
        end
        mt.remove(self)
        return
    end

end

local actList = {
    [cst.BULLET_FOLLOW_TARGET] = updateAct_followTarget,
    [cst.BULLET_SHOCK_WAVE] = updateAct_shockWave,
    [cst.BULLET_BACK_TURN] = updateAct_backTurn,
    [cst.BULLET_SPIN] = updateAct_spin,
    [cst.BULLET_THROW] = updateAct_throw,
    [cst.BULLET_CUSTOM] = updateAct_custom,
}
--------------------------------------------------------------------------------------
-- @param u: owner
-- @param point: starting point
-- @param keys: additon vals
function mt:makeProjectile(projectile)
    -- if not projectile.owner then
    --     return
    -- end

    if bulletList:find(projectile) then
        warn('repeat bullet data used')
        -- traceError('repeat bullet')
        return
    end

    if projectile.mode == cst.BULLET_SHOCK_WAVE then
        projectile.updateInterval = SHOCK_WAVE_FRAME_INTERVAL
    end

    if projectile.mode == cst.BULLET_BACK_TURN then
        projectile.x_0 = projectile.point[1]
        projectile.y_0 = projectile.point[2]
        projectile.x_2 = projectile.point2[1]
        projectile.y_2 = projectile.point2[2]
    end

    if projectile.mode == cst.BULLET_SPIN then
        projectile.point = as.point:polarPoint(projectile.follow:getLoc(), projectile.r, projectile.startAngle)
    end

    if projectile.mode == cst.BULLET_THROW then
        local dis = (projectile.point * projectile.pointT:get_point(true))
        projectile.shootTime = dis / projectile.horSpeed
        projectile.speed = projectile.horSpeed
        local halfDis = dis / 2
        projectile.maxHeight = math.tan(projectile.shootAngle) * halfDis
        projectile.lastHeight = 0
    end

    if projectile.mode == cst.BULLET_FOLLOW_TARGET then
        local unit = projectile.unit
        local tgt = projectile.tgt
        if (not tgt) or (tgt.removed) then
            return
        end

        projectile.point = projectile.point or unit:getloc()
        projectile.face = projectile.point / tgt:getloc()

        if projectile.shootAngle then
            local dis = (projectile.point * tgt:getloc())
            projectile.shootTime = dis / projectile.speed
            local halfDis = dis / 2
            projectile.maxHeight = math.tan(projectile.shootAngle) * halfDis
            projectile.lastHeight = 0
            projectile.totalDis = dis
        end

        projectile.tgtHeight = tgt:getHeight()
        if projectile.fixedBulletHeight then
            projectile.tgtHeight = projectile.height
        end

        projectile.linerDeltaHeight = projectile.tgtHeight - projectile.height

    end

    if projectile.mode == cst.BULLET_THROW then
        projectile.tgtHeight = projectile.tgtHeight or 0
        projectile.linerDeltaHeight = projectile.tgtHeight -- - projectile.height
    end

    if projectile.mode == cst.BULLET_SHOCK_WAVE then
        projectile.startPoint = projectile.point
        projectile.lastShockwavePoint = projectile.point

        if projectile.onUpdate then
            local onUpdateCore = projectile.onUpdate
            projectile.onUpdate = function(self)
                local lastShockwavePoint = self.lastShockwavePoint
                local currentShockwavePoint = self.point
                if not lastShockwavePoint then
                    lastShockwavePoint = self.startPoint
                end
                onUpdateCore(self)

                self.lastShockwavePoint = self.point
            end
        end

    end

    local eff = {
        model = projectile.model,
        height = projectile.height,
        size = projectile.size,
        face = projectile.face,
        mustShow = true,
        isProjectile = true,
        time = -1,
    }
    local body = as.effect:pointEffect(eff, projectile.point)
    projectile.body = body

    gchash = gchash + 1
    dbg.gchash(projectile, gchash)
    projectile.gchash = gchash
    setmetatable(projectile, mt)

    if projectile.onCreate then
        projectile.onCreate(projectile)
    end

    projectile.type = 'bullet'

    -- set projectile mode
    projectile.updateFunc = actList[projectile.mode]

    -- set projectile horizontal dspeed
    if projectile.horSpeed then
        projectile.dSpeed = projectile.horSpeed * FRAME_INTERVAL_NORMAL
    end

    -- set delta speed
    if projectile.speed then
        projectile.dSpeed = projectile.speed * FRAME_INTERVAL_NORMAL

        -- min hit range
        if projectile.hitRange then
            projectile.originHitRange = projectile.hitRange
            if projectile.updateInterval then
                projectile.hitRange = math.max(projectile.hitRange, projectile.dSpeed * projectile.updateInterval)
            else
                projectile.hitRange = math.max(projectile.hitRange, projectile.dSpeed)
            end
        end

    end

    -- set turn speed
    projectile.turnSpeed = projectile.turnSpeed or 99999
    projectile.dTurnSpeed = projectile.turnSpeed * FRAME_INTERVAL_NORMAL

    -- set fly distance
    projectile.flyDistance = 0

    mt.add(projectile)

    return projectile
end

--------------------------------------------------------------------------------------
-- self is projectile
function mt:next()
    self.frame = self.frame + 1

    if self.frame > 9999 then
        mt.remove(self)
        return
    end

    self.updateFunc(self)

    if self.onUpdate then
        if self.updateInterval then
            if self.frame % self.updateInterval == 0 then
                self.onUpdate(self)
            end
        else
            self.onUpdate(self)
        end

    end

end
--------------------------------------------------------------------------------------
mt:init()
--------------------------------------------------------------------------------------
return mt
