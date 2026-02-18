local buffName = '召唤物'

local buff = {
    name = buffName,
    noLv = true,
    multiple = false,
    -- pulseInterval = 5,

    effect = {}

}

local mt = buff
mt.__index = mt
--------------------------------------------------------------------------------------
function mt:onSwitch(isAdd)

    local unit = self.from
    local tgt = self.owner

    -- gdebug('召唤物on switch 触发')

    if isAdd then
        local eff = {
            model = [[Flamestrike Mystic I.mdx]]
        }
        as.effect:pointEffect(eff, tgt:getLoc())
        -- gdebug('召唤物add')
    else
        -- gdebug('召唤物remove')
        self.owner:kill()
    end

end

--------------------------------------------------------------------------------------
function mt:onPulse()
    local unit = self.owner
    local master = self.from

end

--------------------------------------------------------------------------------------
as.dataRegister:initBuff(buff)

return buff
