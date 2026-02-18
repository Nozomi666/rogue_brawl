local mt = test

--------------------------------------------------------------------------------------
-- @param
function mt:unlockEquipShop(keys)
    local player = keys.p
    -- local unit = p.lastPick
    -- local growWeapon = unit.growWeapon
    -- local growArmor = unit.growArmor
    -- local chargeNumber = tonumber(keys.args[1] or 10000)

    -- growWeapon:modUses(chargeNumber)
    -- growWeapon.killCharge = growWeapon.oldCharge or 0 + chargeNumber

    -- growArmor:modUses(chargeNumber)
    -- growArmor.killCharge = growArmor.oldCharge or 0 + chargeNumber

    local equipShop = player.equipShop
    if not equipShop.unlocked then
        equipShop.unlocked = true
        equipShop:onUnlock()
    end

end
--------------------------------------------------------------------------------------
test.act['unlockequip'] = mt.unlockEquipShop