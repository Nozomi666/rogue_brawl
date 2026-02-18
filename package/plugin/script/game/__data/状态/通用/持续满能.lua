local buffName = '持续满能'

local buff = {
    name = buffName,
    noLv = true,
    effect = {{'overhead', [[Surge.mdx]]}},

}

local mt = buff
mt.__index = mt
--------------------------------------------------------------------------------------
function mt:onSwitch(isAdd)

    local unit = self.from
    local tgt = self.owner

    if isAdd then
        tgt:setStats(ST_MP_PCT, 100)
        tgt.bFullEnergy = true
    else
        tgt:setStats(ST_MP_PCT, 0)
        tgt.bFullEnergy = false
    end

end

--------------------------------------------------------------------------------------
function mt:onPulse()

end

--------------------------------------------------------------------------------------
as.dataRegister:initBuff(buff)

return buff
