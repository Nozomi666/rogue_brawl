

local buffName = '暂停'

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
		japi.EXPauseUnit(tgt.handle, true)
	else
		japi.EXPauseUnit(tgt.handle, false)
	end 


end

--------------------------------------------------------------------------------------
function mt:onPulse()
	
end


--------------------------------------------------------------------------------------
as.dataRegister:initBuff(buff)


return buff