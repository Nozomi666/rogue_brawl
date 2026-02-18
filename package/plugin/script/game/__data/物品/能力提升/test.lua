local mt = test

--------------------------------------------------------------------------------------
-- @param
function mt:testPowerUp(keys)
    local p = keys.p
    -- local unit = p.lastPick
    -- local growWeapon = unit.growWeapon
    -- local growArmor = unit.growArmor
    -- local chargeNumber = tonumber(keys.args[1] or 10000)

    -- growWeapon:modUses(chargeNumber)
    -- growWeapon.killCharge = growWeapon.oldCharge or 0 + chargeNumber

    -- growArmor:modUses(chargeNumber)
    -- growArmor.killCharge = growArmor.oldCharge or 0 + chargeNumber

    fc.createItemToPoint('力量卷轴（大）', p.rewardPoint, p)
    fc.createItemToPoint('敏捷卷轴（大）', p.rewardPoint, p)
    fc.createItemToPoint('智力卷轴（大）', p.rewardPoint, p)
    -- fc.createItemToPoint('全能手册（大）', p.rewardPoint, p)
    -- fc.createItemToPoint('智慧结晶（大）', p.rewardPoint, p)

    -- fc.createItemToPoint('遗失的钱袋（大）', p.rewardPoint, p)
    -- fc.createItemToPoint('遗失的珠宝袋（大）', p.rewardPoint, p)
    -- fc.createItemToPoint('污秽精华（大）', p.rewardPoint, p)

end
--------------------------------------------------------------------------------------
function mt:testConsume(keys)
    local p = keys.p

    for i = 1, 20 do
        fc.createItemToPoint('抽奖券', p.rewardPoint, p)
    end

end
--------------------------------------------------------------------------------------
test.act['powerup'] = mt.testPowerUp
test.act['consume'] = mt.testConsume