

local buffName = '禁锢'

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
        model = [[EntanglingBonesTarget.mdx]],
        bind = 'origin',
		mustShow = true,
		time= -1,
    }

	if isAdd then 
		self.eff = as.effect:unitEffect(eff, tgt)
		japi.EXSetUnitMoveType(tgt.handle, 0x01)
		tgt.noMoveCounter = tgt.noMoveCounter + 1
	else
		fc.removeEffect(self.eff)
		tgt.noMoveCounter = tgt.noMoveCounter - 1
		if tgt.noMoveCounter == 0 then
			japi.EXSetUnitMoveType(tgt.handle, 0x02)
		end
		
	end 

end

--------------------------------------------------------------------------------------
function mt:onPulse()
	
end


--------------------------------------------------------------------------------------
as.dataRegister:initBuff(buff)


return buff