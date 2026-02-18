require('game.class.base.unit')
-- require('class.custom.hero')
-- require('class.custom.stand_spot')

--------------------------------------------------------------------------------------
-- extend cg.BaseUnit
local mt = {}
mt.__index = mt
mt.type = 'unit'
mt.baseType = 'unit'
setmetatable(mt, cg.BaseUnit)
cg.Unit = mt
as.customUnit = mt
--------------------------------------------------------------------------------------
function mt.onShockwaveShootHit(bullet, tgt)
    local unit = bullet.owner
    local dmg = bullet.dmg

    -- gdebug('onShockwaveShootHit dmg' .. dmg)
    local keys = {
        unit = unit,
        tgt = tgt,
        dmg = dmg,
        dmgType = bullet.dmgType,
        isAtk = bullet.isAtk,
    }
    ApplyDamage(keys)
end
--------------------------------------------------------------------------------------
function mt.onShockwaveShootUpdate(bullet)
    local unit = bullet.owner
    local hitList = bullet.hitList
    local onHit = bullet.onHit

    local lastShockwavePoint = bullet.lastShockwavePoint
    local currentShockwavePoint = bullet.point

    for _, tgt in ac.selector():in_line_enemy(unit, lastShockwavePoint, lastShockwavePoint / currentShockwavePoint,
        lastShockwavePoint * currentShockwavePoint, bullet.originHitRange):notInGroup(hitList):ipairs() do
        hitList[tgt] = true
        onHit(bullet, tgt)
    end

end
--------------------------------------------------------------------------------------
function mt.onShootAtkHit(bullet)
    local unit = bullet.owner
    local tgt = bullet.tgt
    local dmg = bullet.dmg

    local keys = {
        unit = unit,
        tgt = tgt,
        dmg = dmg,
        dmgType = DMG_TYPE_PHYSICAL,
        isAtk = bullet.isAtk,
    }
    ApplyDamage(keys)
    if bullet.jumpCount > 0 then
        local sGroup = unit.nearEnemyGroup
        local range = 600
        local group = fc.filterUnitGroupInRange(sGroup, tgt:getloc(), range)
        table.removeTarget(group, tgt)
        local tgt2 = fc.randomRemove(group)

        -- local group = ac.selector():inRange(tgt:getloc(), 600):isEnemy(unit):is_not(tgt)
        -- local tgt2 = group:randomRemove()
        if tgt2 then
            unit:onShootAtkLaunch(tgt2, {
                dmg = dmg,
                point = tgt:getloc(),
                isAtk = false,
                isBounceAtk = true,
                jumpCount = bullet.jumpCount - 1,
            })
        end
    end

    -- gdebug('on bullet hit')

    if bullet.isSplitAtk then
        unit:triggerEvent(UNIT_EVENT_ON_SPLIT_ATK, {
            unit = unit,
            tgt = tgt,
        })
    end

end
-- --------------------------------------------------------------------------------------
-- function mt:getShootPoint(tgt)
--     local face = fc.angleBetweenUnits(self, tgt)
--     return fc.polarPoint(self:getloc(), self.bulletOffsetX, face)
-- end
--------------------------------------------------------------------------------------
function mt:onShootAtkLaunch(tgt, keys)

    -- if localEnv then
    --     gdebug('onShootAtkLaunch triggered .. ' .. keys.dmg)
    -- end
    keys.tgt = tgt
    local dmg = keys.dmg
    local multiChance = self:getStats(ST_MULTI_ATK_CHANCE)
    local multiCount = self:getStats(ST_MULTI_ATK_COUNT)
    local multidmg = self:getStats(ST_MULTI_ATK_DMG)
    local splitChance = self:getStats(ST_SPLIT_ATK_CHANCE)
    local splitCount = self:getStats(ST_SPLIT_ATK_COUNT)
    local splitdmg = self:getStats(ST_SPLIT_ATK_DMG)
    local bounceChance = self:getStats(ST_BOUNCE_ATK_CHANCE)
    local bounceCount = self:getStats(ST_BOUNCE_ATK_COUNT)
    local bouncedmg = self:getStats(ST_BOUNCE_ATK_DMG)
    local jumpCount = keys.jumpCount or 0

    local face = fc.angleBetweenUnits(self, tgt)
    local point = keys.point or fc.polarPoint(self:getloc(), self.bulletOffsetX or 0, face)

    if keys.isAtk then
        if (not keys.isMultiAtk) and multiChance > 0 then

            local realCount = 0
            for i = 1, multiCount do
                if math.random(100) < multiChance then
                    realCount = realCount + 1
                end
            end

            if realCount > 0 then
                ac.timer(ms(0.2), realCount, function()
                    self:onShootAtkLaunch(tgt, {
                        isMultiAtk = true,
                        dmg = dmg * (1 + multidmg * 0.01),
                    })
                end)

            end
        end

        if (not keys.isSplitAtk) and splitChance > 0 then

            local realCount = 0
            for i = 1, splitCount do
                if math.random(100) < splitChance then
                    realCount = realCount + 1
                end
            end

            if localEnv then
                realCount = 2
            end

            if realCount > 0 then
                -- local group = ac.selector():inRange(point, self:getStats(ST_RANGE)):isEnemy(self):is_not(tgt)

                local sGroup = self.nearEnemyGroup
                local range = self:getStats(ST_RANGE)
                local group = fc.filterUnitGroupInRange(sGroup, self:getloc(), range)
                table.removeTarget(group, tgt)

                for i = 1, realCount do
                    local tgt2 = fc.randomRemove(group)
                    if tgt2 then
                        self:onShootAtkLaunch(tgt2, {
                            isSplitAtk = true,
                            dmg = dmg * (1 + splitdmg),
                        })
                    end
                end
            end

        end

        if (not keys.isBounceAtk) and bounceCount > 0 then
            for i = 1, bounceCount do
                if math.random(100) < bounceChance then
                    jumpCount = jumpCount + 1
                end
            end
        end

        -- if localEnv then
        --     jumpCount = 2 
        -- end

        keys.safeExecute = true
        keys.dmg = dmg
        self:triggerEvent(UNIT_EVENT_ON_LAUNCH_ATK, keys)
        dmg = keys.dmg
    end

    if keys.isSplitAtk then
        keys.isAtk = false
    end

    if keys.isBounceAtk then
        keys.isAtk = false
    end

    local bulletData = {
        mode = cst.BULLET_FOLLOW_TARGET,
        owner = self,
        tgt = tgt,
        model = self.bulletModel,
        size = self.bulletSize,
        point = point,
        height = self.bulletHeight,
        shootAngle = self.bulletAngle or 0,
        speed = self.bulletSpeed,
        hitRange = self.bulletHitRange,
        fixedBulletHeight = self.fixedBulletHeight,
        --------------------------------------------------------------------------------------
        onHit = mt.onShootAtkHit,
        jumpCount = jumpCount,
        dmg = dmg * (1 + bouncedmg),
        isAtk = keys.isAtk,
        isSplitAtk = keys.isSplitAtk,
    }
    local projectile = as.projManager:makeProjectile(bulletData)

end
--------------------------------------------------------------------------------------
return mt
