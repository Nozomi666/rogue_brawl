local buffName = '幻象'

local buff = {
    name = buffName,
    noLv = true,

    effect = {},

}

local mt = buff
mt.__index = mt
--------------------------------------------------------------------------------------
function mt:onSwitch(isAdd)

    local unit = self.from
    local tgt = self.owner

    if isAdd then
        local eff = {
            model = [[Flamestrike Fel I.mdx]],
        }
        as.effect:pointEffect(eff, tgt:getLoc())

    else
        ShowUnitHide(tgt.handle)
        local eff = {
            model = [[Abilities\Spells\Orc\MirrorImage\MirrorImageDeathCaster.mdl]],
        }
        as.effect:pointEffect(eff, tgt:getLoc())
        tgt:kill()
    end

end

--------------------------------------------------------------------------------------
function mt:onPulse()

end

--------------------------------------------------------------------------------------
as.dataRegister:initBuff(buff)

return buff
