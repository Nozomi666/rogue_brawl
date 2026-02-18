

local buffName = '沉默'

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


	if isAdd then 
		as.castHelper:targetCast(unit, tgt, 'A050')
		tgt.bSilenced = true
	else
		UnitRemoveAbility(tgt.handle, ID('B000'))
		tgt.bSilenced = false
	end 

end

--------------------------------------------------------------------------------------
function mt:onPulse()
	
end


--------------------------------------------------------------------------------------
as.dataRegister:initBuff(buff)


return buff