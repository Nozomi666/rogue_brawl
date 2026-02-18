local buffName = '免疫'

local buff = {
    name = buffName,
    noLv = true,

    effect = {{'origin', [[39.mdx]]}},
    mustShowEffect = true,

}

local mt = buff
mt.__index = mt
--------------------------------------------------------------------------------------
function mt:onSwitch(isAdd)

    local unit = self.from
    local tgt = self.owner

    -- gdebug('免疫 switch')

    if isAdd then
        tgt.immuneCounter = tgt.immuneCounter + 1
    else
        tgt.immuneCounter = tgt.immuneCounter - 1

    end

end

--------------------------------------------------------------------------------------
function mt:onPulse()

end

--------------------------------------------------------------------------------------
as.dataRegister:initBuff(buff)

return buff
