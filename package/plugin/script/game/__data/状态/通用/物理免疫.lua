

local buffName = '物理免疫'

local buff = {
    name = buffName,
	noLv = true,
	
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
		tgt.immuneCounterPhysical = tgt.immuneCounterPhysical + 1
	else
		tgt.immuneCounterPhysical = tgt.immuneCounterPhysical - 1
		
	end 

end

--------------------------------------------------------------------------------------
function mt:onPulse()
	
end


--------------------------------------------------------------------------------------
as.dataRegister:initBuff(buff)


return buff