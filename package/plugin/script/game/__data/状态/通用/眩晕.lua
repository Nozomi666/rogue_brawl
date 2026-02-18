

local buffName = '眩晕'

local buff = {
    name = buffName,
	noLv = true,
	control = true,
	
	effect = {
	},

}

local mt = buff
mt.__index = mt
--------------------------------------------------------------------------------------
function mt:onSwitch(isAdd)
	
	local unit = self.from
	local tgt = self.owner
	local eff = {
        model = [[263.mdx]],
        bind = 'overhead',
		mustShow = true,
		time= -1,
    }

	if isAdd then 
		self.eff = as.effect:unitEffect(eff, tgt)
		japi.EXPauseUnit(tgt.handle, true)
	else
		fc.removeEffect(self.eff)
		japi.EXPauseUnit(tgt.handle, false)

		if tgt:isAlive() and tgt.atkPoint then
			tgt:setAtkPoint(tgt.atkPoint)
		end
		
	end 


end

--------------------------------------------------------------------------------------
function mt:onPulse()
	
end


--------------------------------------------------------------------------------------
as.dataRegister:initBuff(buff)


return buff