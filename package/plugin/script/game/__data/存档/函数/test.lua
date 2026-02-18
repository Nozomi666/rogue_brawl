local mt = test

mt.manualLoadArch = false

mt.cheatStore = true
if not MAP_DEBUG_MODE then
    mt.cheatStore = false
end

mt.cheatArch = true
if not MAP_DEBUG_MODE then
    mt.cheatArch = false
end

mt.testStoreItemList = {}
mt.testStoreItemList['藏宝密匣'] = 3
-- mt.testStoreItemList['敏捷药水'] = 50
-- mt.testStoreItemList['智力药水'] = 50
-- mt.testStoreItemList['森林礼遇'] = true

mt.testStoreItemList['魔法熔炉'] = true
mt.testStoreItemList['能量饮料'] = true
mt.testStoreItemList['练功木桩'] = true
mt.testStoreItemList['红龙血液'] = true
-- mt.testStoreItemList['神鬼头盔'] = true
-- mt.testStoreItemList['寒冰印记'] = true
-- mt.testStoreItemList['暗影印记'] = true

-- mt.testStoreItemList['飞弹石碣'] = true
-- mt.testStoreItemList['法球石碣'] = true
-- mt.testStoreItemList['炸弹石碣'] = true
-- mt.testStoreItemList['箭术石碣'] = true

-- mt.testStoreItemList['四叶草'] = true
mt.testStoreItemList['封印之杖'] = true

--------------------------------------------------------------------------------------
function mt:loadArchs(keys)
    local p = keys.p

    p:loadArchs()
    p.archEquipManager:init()
end
--------------------------------------------------------------------------------------
function mt:addGameExp(keys)
    local p = keys.p
    local val = keys.args[1] and tonumber(keys.args[1]) or 500

    p:modSimpleArch(INT_STORAGE.ACTIVITY_EXP, val)
end
--------------------------------------------------------------------------------------
function mt:refreshUnix(keys)
    local p = keys.p
    local pj = p.handle
    local storageName = INT_STORAGE.UNIX_DAY

    local oldUnixDay = code.loadServerInt(pj, storageName)
    if oldUnixDay then
        gdebug('oldUnixDay is: ' .. oldUnixDay)
    else
        gdebug('oldUnixDay is nil, set to 0')
        oldUnixDay = 0
    end

    local nowUnixDay = 0

    gdebug(str.format('update old unix day to new unix day: %d -> %d', oldUnixDay, nowUnixDay))
    code.saveServerInt(pj, storageName, nowUnixDay)

    -- local refreshList = reg:getPool('arch_day_clear_list')

    -- for _, arch in ipairs(refreshList) do
    --     local archName = arch.name
    --     gdebug('clear day arch: %s', archName)
    --     p.archManager:setSimpleArch(archName, 0)
    -- end

end
--------------------------------------------------------------------------------------
function mt:unlockDayReward(keys)
    local p = keys.p
    -- p:tryUnlockArch('开黑')
    -- p:tryUnlockArch('带新')
    -- p:tryUnlockArch('屠戮')
    -- p:tryUnlockArch('通关')

    p:modSimpleArch(INT_STORAGE.ACTIVITY_EXP, 10)
end
--------------------------------------------------------------------------------------
function mt:lookupGameExp(keys)
    local p = keys.p
    local archGameLvManager = p.archGameLvManager
    msg.notice(p, str.format('当前游戏等级：%d，游戏经验：%d', archGameLvManager.lv,
        p:getFixedSimpleArch(INT_STORAGE.ACTIVITY_EXP)))
end
--------------------------------------------------------------------------------------
function mt:refreshDay(keys)
    local p = keys.p
    local archManager = p.archManager
    archManager:refreshCurrentDay()

end
--------------------------------------------------------------------------------------
function mt:unlockWelfare(keys)
    local p = keys.p
    p:forceUnlockArch('加群礼包')
    p:forceUnlockArch('收藏礼包')
    p:forceUnlockArch('评论礼包')
    p:forceUnlockArch('发帖礼包')
    p:forceUnlockArch('签到礼包')
    p:forceUnlockArch('公众号礼包')
    p:forceUnlockArch('内测礼包')
    p:forceUnlockArch('加精礼包')
    p:forceUnlockArch('会员礼包')

end
--------------------------------------------------------------------------------------
function mt:collectShard(keys)
    local p = keys.p

    p:modSimpleArch(INT_STORAGE.COLLECT_SHARD, 100000, false, true)
    p:modSimpleArch(INT_STORAGE.COLLECT_SHARD_MAX, 100000, false, true)
end
--------------------------------------------------------------------------------------
function mt:dropArchEquipRandom(keys)
    local p = keys.p
    p.fakeMapLv = 2
    p.archEquipManager:dropArchEquipRandom(1, 5, 30, 80)
end
--------------------------------------------------------------------------------------
function mt:cheatHero(keys)
    local p = keys.p
    p:setArchVal('被锁英雄记录', 21)
end
--------------------------------------------------------------------------------------
function mt:unlockStore(keys)
    local p = keys.p
    mt.cheatStore = true
    local archName = keys.args[1]

    p:forceUnlockArch(archName)

end
--------------------------------------------------------------------------------------
function mt:addEquipDust(keys)
    local p = keys.p
    p.archEquipManager:addDust(50.2523)
end
--------------------------------------------------------------------------------------
function mt:storeAll(keys)
    local p = keys.p
    mt.cheatStore = true
    mt.closeCheckStore = true

    local testList = reg:getPool(BOOL_STORAGE.STORE_REWARD_1)

    for i, pack in ipairs(testList) do
        local archName = pack.name
        p:forceUnlockArch(archName)
    end

end
--------------------------------------------------------------------------------------
function mt:clearShine(keys)
    local p = keys.p
    code.saveServerString(p.handle, BOOL_STORAGE.SHINE, '')
end
--------------------------------------------------------------------------------------
function mt:heroFrag(keys)
    local p = keys.p

    p:modSimpleArch(INT_STORAGE.HERO_FRAG_R, 20)

end
--------------------------------------------------------------------------------------
function mt:fishScore(keys)
    local p = keys.p

    p:modSimpleArch(INT_STORAGE.DIAOYUSCORE, 200)
    p:modSimpleArch(INT_STORAGE.JINLISCORE, 200)
end
--------------------------------------------------------------------------------------
function mt:activateOldCollection(keys)
    local p = keys.p

    p:tryUnlockArch('老随机藏品1')
    p:tryUnlockArch('老随机藏品2')
    p:tryUnlockArch('老随机藏品3')

end
--------------------------------------------------------------------------------------
function mt:transferOldCollection(keys)
    local p = keys.p

    for i = 30, 77 do
        local val = arch.loadArch(p.handle, BOOL_STORAGE.WIN_ACHIEVEMENT_1, i)
        gdebug('col i:%d, val:%d', i, val and 1 or 0)
    end

    local curIndex = 30
    for i = 1, 8 do
        local list = TONGGUAN_CHENGJIU_LIST[i]
        for j = 1, 6 do
            local packName = list[j]
            gdebug('check packname: ' .. packName)
            gdebug('curIndex: ' .. curIndex)
            local pack = reg:getTableData('archData', packName)
            local hasOldArch = arch.loadArch(p.handle, BOOL_STORAGE.WIN_ACHIEVEMENT_1, curIndex)
            if hasOldArch then
                gdebug('has old arch: ' .. packName)
                p:modArchVal(packName, 1)
            end
            curIndex = curIndex + 1
        end

    end

end
--------------------------------------------------------------------------------------
function mt:docheat(keys)
    local p = keys.p
    -- code.saveServerInt(p.handle, INT_STORAGE.OUTFIT_SHARD, 10000000)
    code.saveServerInt(p.handle, INT_STORAGE.OUTFIT_SHARD, -100)
end
--------------------------------------------------------------------------------------
function mt:cancelcheat(keys)
    local p = keys.p
    code.saveServerInt(p.handle, INT_STORAGE.OUTFIT_SHARD, 3000)
    code.saveServerInt(p.handle, INT_STORAGE.CHEAT2, 0)
end
--------------------------------------------------------------------------------------
function mt:add520(keys)
    local p = keys.p

    p:modSimpleArch(INT_STORAGE.ONLINE_TIME_520, 400)
end
--------------------------------------------------------------------------------------
test.act['loadarch'] = mt.loadArchs
test.act['gameexp'] = mt.addGameExp
test.act['refreshunix'] = mt.refreshUnix
test.act['dayreward'] = mt.unlockDayReward
test.act['lookupgameexp'] = mt.lookupGameExp
test.act['refreshday'] = mt.refreshDay
test.act['welfare'] = mt.unlockWelfare
test.act['shard'] = mt.collectShard
test.act['dropequip'] = mt.dropArchEquipRandom
test.act['cheathero'] = mt.cheatHero
test.act['store'] = mt.unlockStore
test.act['storeall'] = mt.storeAll
test.act['sta'] = mt.storeAll
test.act['cshine'] = mt.clearShine
test.act['hfrag'] = mt.heroFrag
test.act['edust'] = mt.addEquipDust
test.act['dy'] = mt.fishScore
test.act['oldc'] = mt.activateOldCollection
test.act['oldt'] = mt.transferOldCollection
test.act['docheat'] = mt.docheat
test.act['cancelcheat'] = mt.cancelcheat
test.act['add520'] = mt.add520

