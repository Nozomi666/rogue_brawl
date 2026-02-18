local mt = test
--------------------------------------------------------------------------------------
function mt:citem(keys)

    local iName = keys.args[1]
    local num = tonumber(keys.args[2] or 1)
    local player = keys.p
    if not iName then
        iName = '威能宝石'

    end
    local point = player.maid:getloc()

    for i = 1, num do
        fc.createItemToUnit(iName, player.hero, player)
    end

    fc.createItemToUnit('威能宝石', player.hero, player)
    fc.createItemToUnit('威能宝石', player.hero, player)
    fc.createItemToUnit('威能宝石', player.hero, player)
    fc.createItemToUnit('威能宝石', player.hero, player)

end
--------------------------------------------------------------------------------------
test.act['citem'] = mt.citem
