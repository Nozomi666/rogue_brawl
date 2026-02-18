local mt = {
    chargeMax = 200
}
mt.__index = mt
PowerUp = mt
setmetatable(mt, as.item)
mt.type = 'power_up'
--------------------------------------------------------------------------------------
POWER_UP_SHOT_MIN = {
    [1] = 2,
    [2] = 2,
    [3] = 2
}

POWER_UP_SHOT_MAX = {
    [1] = 4,
    [2] = 4,
    [3] = 4
}

POWER_UP_BULLET_SIZE = {
    [1] = 1,
    [2] = 2,
    [3] = 3,
}

--------------------------------------------------------------------------------------
function mt:register(pack)
    local rare = pack.rare
    reg:addToPool(str.format('power_up_%d', rare), pack)
    as.dataRegister:initItem(pack)
end
--------------------------------------------------------------------------------------
function mt:onPickUp(u)

    -- if self.pickupEffect then
    --     fc.safeExecute(function ()
    --         self:pickupEffect(u)
    --     end)
    -- end

    local p = u.owner
    local hero = p.hero

    local rare = self.rare
    local shotMin = POWER_UP_SHOT_MIN[rare]
    local shotMax = POWER_UP_SHOT_MAX[rare]

    local shot = math.random(shotMin, shotMax)
    local point = self.dropPos

    ac.timer(ms(0.35), shot, function()
        self:onShot(point, hero)
    end)

    if not fc.isInCd(u, 'power_up_auto_pickup_cd') then
        fc.setInnerCd(u, 'power_up_auto_pickup_cd', 0.2)

        local list = as.item:getItemInRange(point, 800)

        for k, itemJ in ipairs(list) do
            local item = as.item:j2t(itemJ)
            if item.type == 'power_up' then
                item:tryForceGiveTo(u)
            end
        end

    end

    -- local keys = {
    --     u = tgt,
    --     pack = pack
    -- }
    -- tgt:triggerSafeEvent(cst.UNIT_EVENT_ON_USE_POWER_UP, keys)

    return 1
end
--------------------------------------------------------------------------------------
function mt:onShot(point, hero)

    local statsType = self.statsType
    local statsVal = self.statsVal
    local onHit

    -- sound.playToPlayer(glo.gg_snd_power_up_start, p, 1, 0.05, true)

    onHit = function(bullet)
        local tgt = bullet.tgt
        local extraRate = 0
        if fc.setAttr(tgt.player, '心灵法杖') then
            extraRate = extraRate + 0.15
        end

        extraRate = extraRate * (1 + hero:getStats(ST_POWER_UP_RATE))
        if self.customHitEffect then
            self:customHitEffect(hero)
        else
            if type(statsType) ~= 'table' then
                tgt:growStats(self.name, statsType, statsVal * (1 + extraRate))
            else
                for i, type in ipairs(statsType) do
                    tgt:growStats(self.name, statsType[i], statsVal[i] * (1 + extraRate))
                end
            end
        end

        local eff = {
            model = [[[AKE]war3AKE.com - 2976746289954316987259771.mdl]],
            bind = [[chest]]
        }
        fc.unitEffect(eff, tgt)

        -- sound.playToPlayer(glo.gg_snd_power_up_hit, p, 1, 0.05, true)
    end

    local pointT = hero:getloc()
    local angRng = math.random(-110, 110)
    local face = point / pointT - 0 + angRng
    local s = 2000 - (90 - math.abs(angRng)) / 90 * 1000
    local point2 = fc.polarPoint(point, math.random(350, 400), face)

    local bulletData = {
        mode = cst.BULLET_BACK_TURN,
        owner = hero,
        tgt = hero,
        point = point,
        point2 = point2,
        model = self.bulletModel,

        height = 80,
        size = POWER_UP_BULLET_SIZE[self.rare],
        face = face,
        hitRange = 80,

        r = 0,
        s = s,
        ss = 0,
        --------------------------------------------------------------------------------------
        onHit = onHit
    }

    as.projManager:makeProjectile(bulletData)

end
--------------------------------------------------------------------------------------

return mt
