local mt = {}
UnitManager = mt
--------------------------------------------------------------------------------------
mt.playerUnitList = linked.create()
mt.enemyUnitList = linked.create()
--------------------------------------------------------------------------------------
function mt:updatePerHalfSec()
    self:loopUnitGroup(self.playerUnitList)
    self:loopUnitGroup(self.enemyUnitList)
end
--------------------------------------------------------------------------------------
function mt:loopUnitGroup(unitGroup)

    -- if localEnv then
    --     gdebug('unitGroup num: ' .. #unitGroup)
    -- end

    for unit in pairs(unitGroup) do
        unit:onEveryHalfSec()
    end

end
--------------------------------------------------------------------------------------
function mt:addUnit(unit)
    local isEnemy = IsUnitEnemy(unit.handle, ConvertedPlayer(1))
    unit.markEnemyInUnitManager = isEnemy

    if unit.isShop then
        return
    end

    if unit.isSwarm then
        return
    end

    if isEnemy then
        --gdebug('add to enemy list' .. unit:getName())
        mt.enemyUnitList:add(unit)
    else
        --gdebug('add to ally list' .. unit:getName())
        mt.playerUnitList:add(unit)
    end

    unit:updateLastMomentPosition()

end
--------------------------------------------------------------------------------------
function mt:removeUnit(unit)
    if unit.isShop then
        return
    end
    
    if unit.isSwarm then
        return
    end

    local isEnemy = unit.markEnemyInUnitManager
    local result 
    if isEnemy then
        result=mt.enemyUnitList:remove(unit)
        --gdebug('remove from enemy list' .. unit:getName())
    else
        result=mt.playerUnitList:remove(unit)
        --gdebug('remove from ally list' .. unit:getName())
    end

    if not result then
        print('remove unit from manager error - ' .. unit.name)
        debug.traceback()
    end
end
--------------------------------------------------------------------------------------


--------------------------------------------------------------------------------------
ac.loop(ms(0.5),function ()
    UnitManager:updatePerHalfSec()
end)
--------------------------------------------------------------------------------------
return mt