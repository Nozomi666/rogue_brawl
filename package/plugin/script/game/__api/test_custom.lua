local util = require 'ac.utility'
require 'game.__api.random_arch'

local mt = {}
mt.__index = mt

local comboTestList = {}

mt.allowCheat = false -- init in game manager
mt.allowRepeatArch = false

mt.bCheckDmg = false


mt.testArg = {}

TestPoint = ac.point:new(-2000, 2000)

--------------------------------------------------------------------------------------
function mt:switchDeepDebug()
    MAP_DEEP_DEBUG = not MAP_DEEP_DEBUG
    print('切换deep debug 至 ' .. (MAP_DEEP_DEBUG and 'ture' or 'false'))
end
--------------------------------------------------------------------------------------
function mt:switchDebugMode()
    MAP_DEBUG_MODE = not MAP_DEBUG_MODE
    print('切换debug mode 至 ' .. (MAP_DEEP_DEBUG and 'ture' or 'false'))
end
--------------------------------------------------------------------------------------
function mt:switchTraceBack()
    MAP_TRACE_BACK = not MAP_TRACE_BACK
    print('切换trace back 至 ' .. (MAP_DEEP_DEBUG and 'ture' or 'false'))
end

--------------------------------------------------------------------------------------
function mt:addDummy(keys)
    local dest = as.point:getUnitLoc(keys.p:getLastPick())

    local amt = keys.args[1] or 1

    for i = 1, amt do
        local u = as.unit:createUnit(as.player:getPlayerById(PLAYER_NEUTRAL_AGGRESSIVE), 'w003', dest, 0)
        u:modStats(ST_HP_MAX, 100000)
        u:modStats(ST_PHY_DEF, 100)
        u:modStats(ST_MAG_DEF, 100)
    end

end

--------------------------------------------------------------------------------------
function mt:addEnemy(keys)
    local dest = as.point:getUnitLoc(keys.p:getLastPick())

    local amt = keys.args[1] or 1
    local atk = keys.args[2] or 0

    for i = 1, amt do
        local dest2 = fc.polarPoint(dest, math.random(100, 400), math.random(360))
        local u = as.unit:createUnit(as.player:getPlayerById(PLAYER_NEUTRAL_AGGRESSIVE), 'w003', dest2, 0)
        u:setStats(ST_HP_MAX, 100000000)
        u:modStats(ST_BASE_PHY_DEF, 100)
        u:modStats(ST_BASE_MAG_DEF, 100)
        u:setStats(ST_MOVE_SPEED, 5)
        -- u:modStats(cst.ST_ARM, 100)
        -- u:modStats(cst.ST_MAG_DEF, 100)
        -- u:modStats(cst.ST_ATK, atk)
    end

    -- EnemyManager.enemyNum = EnemyManager.enemyNum + amt

end

--------------------------------------------------------------------------------------
function mt:switchFlowText(keys)
    keys.p:switchFlowtext()
end
--------------------------------------------------------------------------------------
function mt:kill(keys)
    local u = keys.p:getLastPick()
    local p = keys.p
    u:kill(p.hero)
end
--------------------------------------------------------------------------------------
function mt:revive(keys)
    local p = keys.p
    local u = p.hero
    if u:isDead() then
        u:revive(u:getloc())
    end

end
--------------------------------------------------------------------------------------
function mt:refreshUnit(keys)
    local u = keys.p:getLastPick()
    u:modStats(ST_HP, 99999)
    u:modStats(ST_MP, 99999)
    u:refreshAllHeroSkills()

end
--------------------------------------------------------------------------------------
function mt:giveExp(keys)
    local u = keys.p:getLastPick()
    local amt = tonumber(keys.args[1])
    u:addExp(amt)
end
--------------------------------------------------------------------------------------
function mt:setHp(keys)
    local u = keys.p:getLastPick()
    local amt = tonumber(keys.args[1])
    SetUnitLifePercentBJ(u.handle, amt)
    SetUnitManaPercentBJ(u.handle, amt)
end
--------------------------------------------------------------------------------------
function mt:ast(keys)
    local u = keys.p:getLastPick()
    local amt = tonumber(keys.args[1])
    u:modStats(ST_ALL, amt)
end
--------------------------------------------------------------------------------------
function mt:record(keys)
    local u = keys.p:getLastPick()

    if u.type == 'hero' then
        u:printStats()
    end
end
--------------------------------------------------------------------------------------
function mt:checkFps(keys)
    japi.ShowFpsText(true)

    local fps = japi.GetFps()

    if keys.p:isLocal() then
        GUI.FPS:show()
    end

    ac.loop(ms(0.1), function()
        GUI.FPS:update()
    end)
    print('current fps is: ' .. fps)
end
--------------------------------------------------------------------------------------
function mt:checkJAPI()
    for k, v in pairs(japi) do
        print(k, v)
    end
end
--------------------------------------------------------------------------------------
function mt:checkDZ()
    for k, v in pairs(dz) do
        print(k, v)
    end
end
--------------------------------------------------------------------------------------
local shiftX, shiftCount = 200, 0
--------------------------------------------------------------------------------------
function mt:debugLog()
    for k, v in ipairs(as.dataRegister.log) do
        gdebug(v)
    end
end
--------------------------------------------------------------------------------------
function mt:roundStart(keys)
    local p = keys.p
    p:onRoundStart()

end
--------------------------------------------------------------------------------------
function mt:roundEnd(keys)
    local p = keys.p
    p:onRoundEnd()
end
--------------------------------------------------------------------------------------
function mt:makeEquip(keys)
    local p = keys.p
    local equipName = keys.args[1]

    local data = {
        name = equipName,
        point = p.rewardPoint,
    }
    as.equip:makeEquip(data)

end
--------------------------------------------------------------------------------------
function mt:spdMax(keys)
    local u = keys.p:getLastPick()
    u:modStats(ST_ATK_SPEED, 600)
end
--------------------------------------------------------------------------------------
function mt:anim(keys)
    local aid = tonumber(keys.args[1])
    -- local fortest = tonumber(keys.args[2])
    local u = keys.p:getLastPick()

    -- gdebug('fortest: ' .. fortest)
    SetUnitAnimationByIndex(u.handle, aid)
end
--------------------------------------------------------------------------------------
function mt:skip(keys)
    local time = nil
    if keys.args[1] then
        time = tonumber(keys.args[1])
    end

    gm.stateTimer = time or 1
end
--------------------------------------------------------------------------------------
function mt:skipBoss(keys)
    local time = nil
    if keys.args[1] then
        time = tonumber(keys.args[1])
    end

    EnemyManager.finalBossTime = time or 1
end
--------------------------------------------------------------------------------------
function mt:wave(keys)
    if keys.args[1] then
        local wave = tonumber(keys.args[1])

        as.enemyManager:setWave(wave)
    end

end
--------------------------------------------------------------------------------------
function mt:endlessWave(keys)
    if keys.args[1] then
        local endlessWave = tonumber(keys.args[1])

        EnemyManager.endlessWaveNum = endlessWave
        gm.endlessWave = endlessWave
        EnemyManager.endlessWaveNum = endlessWave
    end

end
--------------------------------------------------------------------------------------
function mt:infigold(keys)
    local p = keys.p
    local val = 100000000
    if keys.args[1] then
        val = tonumber(keys.args[1])
    end

    p:setStats(RES_GOLD, val)
    p:setStats(RES_CRYSTAL, val)
    p:setStats(RES_KILL, val)
    p:modStats(RES_ROLL, val)
end
--------------------------------------------------------------------------------------
function mt:unlockElement(keys)
    local p = keys.p
    local list = cst.ELEMENT_NAME

    local box = p.pickBox
    box:clean()
    box:setTitle('选择解锁元素羁绊')

    local callBack = function(keys)
        local elId = keys.elId
        p:updateElementCounts(elId, 3)

    end

    for k, v in pairs(list) do
        box:addBtn(v, callBack, {
            elId = k,
        }, cst.PICK_BOX_HOT_KEY.NULL)
    end

    box:showBox()

end
--------------------------------------------------------------------------------------
function mt:pause(keys)
    gm.pause = not gm.pause
    if gm.pause then
        msg.notice(cst.ALL_PLAYERS, '游戏暂停')
    else
        msg.notice(cst.ALL_PLAYERS, '游戏恢复')
    end
end
--------------------------------------------------------------------------------------
function mt:checkUnitEventList(keys)
    local p = keys.p
    local u = keys.p:getLastPick()

    local eventList = u.eventList
    if not eventList then
        BJDebugMsg('没有事件列表')
        return
    end

    for condition, list in pairs(eventList) do
        BJDebugMsg('事件条件：' .. cst:getConstName(condition))
        for name, entry in pairs(list) do
            BJDebugMsg('- ' .. name)
        end
    end
end
--------------------------------------------------------------------------------------
function mt:clearArch(keys)
    local p = keys.p
    p.archManager:clearArchs()
end
--------------------------------------------------------------------------------------
function mt:setArch(keys)
    local p = keys.p
    local archName = keys.args[1]
    local archVal = tonumber(keys.args[2])

    p.archManager:setArchVal(archName, archVal)
end
--------------------------------------------------------------------------------------
function mt:modArch(keys)
    local p = keys.p
    local archName = keys.args[1]
    local archVal = tonumber(keys.args[2])

    p.archManager:modArchVal(archName, archVal)
end
--------------------------------------------------------------------------------------
function mt:unlockArch(keys)
    local p = keys.p
    local archName = keys.args[1]

    p.archManager:forceUnlockArch(archName)
end
--------------------------------------------------------------------------------------
function mt:activateArch(keys)
    local p = keys.p
    local archName = keys.args[1]
    local pack = reg:getTableData('archData', archName)

    if pack.onActivate then
        xpcall(function()
            pack.onActivate(p)
        end, function(msg)
            print(msg, debug.traceback())
        end)
    end
end
--------------------------------------------------------------------------------------
function mt:unlockMapRewards(keys)
    local p = keys.p
    local targetLv = tonumber(keys.args[1])

    local list = reg:getPool(archListName.MAP_LV)

    local mapLv = targetLv

    p.fakeMapLv = targetLv

    for _, pack in ipairs(list) do
        local archName = pack.name
        gdebug('test map lv unlock: ' .. archName)

        local lv = pack.lv

        if mapLv >= lv then
            msg.notice(p, str.format('解锁了地图等级奖励：%d -> %s', pack.lv, pack.tip))
            pack.onActivate(p)
        end
    end

end
--------------------------------------------------------------------------------------
function mt:win()
    gm.gameWin()
end
--------------------------------------------------------------------------------------
function mt:lose(keys)
    local p = keys.p
    gm.gameLose(p, 'test lose')
end
--------------------------------------------------------------------------------------
function mt:enterEndless()
    msg.notice(cst.ALL_PLAYERS, '测试直接进入无尽模式')
    gm:enterGameState(GAME_STATE_ENDLESS)
end
--------------------------------------------------------------------------------------
function mt:makeItem(keys)
    local p = keys.p
    local name = keys.args[1]
    local amt = keys.args[2] or 1

    -- local iType = reg:getItemType(name)

    for i = 1, 20 do
        fc.rewardItem([[惊喜装备盲盒]], p, p.rewardPoint)
    end

    -- fc.rewardItem("初级装备盲盒", p, p.rewardPoint)
    -- fc.rewardItem("初级装备盲盒", p, p.rewardPoint)
    -- fc.rewardItem("初级装备盲盒", p, p.rewardPoint)
    -- fc.rewardItem("初级躯改盲盒", p, p.rewardPoint)
    -- fc.rewardItem("初级躯改盲盒", p, p.rewardPoint)
    -- fc.rewardItem("初级躯改盲盒", p, p.rewardPoint)

end
--------------------------------------------------------------------------------------
function mt:makebug(keys)
    local p = keys.p

    ac.timer(ms(1), 1, function()
        print(str.format('do a bug %d', 'bug'))
    end)

end
--------------------------------------------------------------------------------------
function mt:setafk(keys)
    local p = keys.p
    local val = tonumber(keys.args[1])

    p.afkCount = val

end
--------------------------------------------------------------------------------------
function mt:clearSimpleArch(keys)
    local p = keys.p
    p.archManager:clearSimpleArch()
end
--------------------------------------------------------------------------------------
function mt:setTestArg(keys)
    local id = tonumber(keys.args[1])
    local val = tonumber(keys.args[2])
    mt.testArg[id] = val
end
--------------------------------------------------------------------------------------
function mt:setFrameInterval(keys)
    local interval = tonumber(keys.args[1])
    as.loops:resetLootInterval(interval)
end
--------------------------------------------------------------------------------------
function mt:setFrameIntervalLow(keys)
    local interval = tonumber(0.12)
    as.loops:resetLootInterval(interval)
end
--------------------------------------------------------------------------------------
function mt:setFrameIntervalMid(keys)
    local interval = tonumber(0.06)
    FRAME_INTERVAL_NORMAL = 0.06
    as.loops:resetLootInterval(interval)
end
--------------------------------------------------------------------------------------
function mt:setFrameIntervalHigh(keys)
    local interval = tonumber(0.03)
    FRAME_INTERVAL_NORMAL = 0.03
    as.loops:resetLootInterval(interval)
end
--------------------------------------------------------------------------------------
function mt:testBoss(keys)
    local p = keys.p
    local enemy = EnemyManager:createBoss(p, '专业挨揍人')
end
--------------------------------------------------------------------------------------
function mt:testFinal(keys)
    local p = keys.p
    local enemy = EnemyManager:createFinalBoss()
end
--------------------------------------------------------------------------------------
function mt:testWaveBoss(keys)
    local p = keys.p
    local enemy = EnemyManager:createRandomBoss()
end
--------------------------------------------------------------------------------------
function mt:forceAsync(keys)
    local p = keys.p
    if p:isLocal() then
        local abc = math.random(100)
    end
end
--------------------------------------------------------------------------------------
function mt:checkDmg()
    mt.bCheckDmg = not mt.bCheckDmg

end
--------------------------------------------------------------------------------------
function mt:dmg(keys)
    local u = keys.p:getLastPick()
    local amt = keys.args[1] or 1
    ApplyDamage({
        unit = u,
        tgt = u,
        dmg = amt,
        dmgType = DMG_TYPE_MAGICAL,
    })
end
--------------------------------------------------------------------------------------
function mt:testRightClick()
    local x, y = game.get_mouse_pos()
    gdebug(str.format('test mouse x is:%f, y is %f', x, y))

    local console = require 'ui.tool.console'
    local but = console.get('技能按钮', 0, 0)

    gdebug(str.format('test but w:%f, h:%f, x:%f, y:%f', but.w, but.h, but.x, but.y))

end
--------------------------------------------------------------------------------------
function mt:addSkill(keys)
    local p = keys.p
    local unit = p.hero
    local skName = keys.args[1] or ''
    unit:addSkill(skName)
end
--------------------------------------------------------------------------------------
function mt:allyEnemy(keys)
    local p = keys.p

    local enemyName = '死亡天使'
    local enemyPack = reg:getTableData('enemyData', enemyName)
    local point = gm.mapArea.testPoint
    local pp = fc.polarPoint(point, 800, 0)

    local enemyStats = EnemyManager:makeEnemyStats({
        enemyPack = enemyPack,
        isChallenger = true,
        diffNum = EnemyManager.diffNum,
        waveHp = 10000,
        waveAtk = 100,
        waveDef = 10,
        notApplyEnemyTypeRate = true,
    })

    local enemy = EnemyManager:createEnemy({
        pTarget = p,
        enemyName = enemyName,
        enemyStats = enemyStats,
        bornPoint = point,
        tgtPoint = point,
        testAllyEnemy = true,
    })

    enemy:modStats(ST_HP_MAX, 10000000)
    enemy:modStats(ST_BASE_PHY_DEF, 100)
    enemy:modStats(ST_BASE_MAG_DEF, 100)

    enemy:changeOwner(p)

    if IsUnitEnemy(enemy.handle, ConvertedPlayer(1)) then
        gdebug('巨魔测试 enemy is enemy')
    else
        gdebug('巨魔测试 enemy is ally')
    end

    test.testingEnemyAllySkill = true

    local u = as.unit:createUnit(as.player:getPlayerById(PLAYER_NEUTRAL_AGGRESSIVE), 'w003', pp, 0)
    u.name = p.hero.name
    u:modStats(ST_HP_MAX, 100000)
    u:modStats(ST_MP_MAX, 1000)
    u:modStats(ST_MP, 1000)
    u:modStats(ST_BASE_PHY_DEF, 100)
    u:modStats(ST_BASE_MAG_DEF, 100)
    u.player = cst.PLAYER_9

end
--------------------------------------------------------------------------------------
function mt:skipEndless(keys)
    EnemyManager.endlessWaveCountdown = 0
end
--------------------------------------------------------------------------------------
function mt:skipLoseBuffer(keys)
    EnemyManager.enemyNum = 9999
    gm.loseBufferTime = 0
end
--------------------------------------------------------------------------------------
function mt:checkLeak(keys)
    display_jass_object()
end
--------------------------------------------------------------------------------------
function mt:cacheSeed(keys)
    RandomArch:cacheSeed()

    -- jass.SetRandomSeed(12345)

    -- for i = 1, 3 do
    --     gdebug('seed i: %d', math.random(-2147483648, 2147483647))
    -- end

    -- RandomArch:recoverSeed()

end
--------------------------------------------------------------------------------------
function mt:crash(keys)
    local p = keys.p
    print(p.hero.handle)
    AddSpecialEffect('123', '223')
end
--------------------------------------------------------------------------------------
function mt:mmp(keys)
    code.customMiniMap()
end
--------------------------------------------------------------------------------------
function mt:modAtk(keys)
    local u = keys.p:getLastPick()
    local amt = tonumber(keys.args[1])
    -- u:modStats(ST_ALL, amt)
    u:modStats(ST_BASE_ATK, amt)
end
--------------------------------------------------------------------------------------
function mt:modHpMax(keys)
    local u = keys.p:getLastPick()
    local amt = tonumber(keys.args[1])
    -- u:modStats(ST_ALL, amt)
    u:modStats(ST_BASE_HP_MAX, amt)
end
--------------------------------------------------------------------------------------

mt.act = {
    debug = mt.switchDebugMode, -- 开关debug模式
    deep = mt.switchDeepDebug,
    trace = mt.switchTraceBack,
    fps = mt.checkFps,
    japi = mt.checkJAPI,
    dz = mt.checkDZ,
    log = mt.debugLog,
    st = mt.record,
    dmg = mt.dmg,

    dum = mt.addDummy, -- 创（x） 个靶子
    enm = mt.addEnemy, -- 创（x） 个敌人
    flowtext = mt.switchFlowText,

    exp = mt.giveExp, -- 增加选中单位经验（x）
    ast = mt.ast,
    kill = mt.kill, -- 杀死选中单位
    
    rs = mt.roundStart,
    re = mt.roundEnd,
    r = mt.refreshUnit,
    revive = mt.revive,
    hp = mt.setHp, -- 设置选中单位生命百分比到（x）%
    equip = mt.makeEquip,
    spdmax = mt.spdMax,
    a = mt.anim,
    skip = mt.skip, -- 跳过当前波数倒计时
    skipendless = mt.skipEndless,
    skipbuffer = mt.skipLoseBuffer,
    skipboss = mt.skipBoss,
    wave = mt.wave, -- 跳到（x）波
    ewave = mt.endlessWave, -- 跳到（x）波无尽
    endless = mt.enterEndless, -- 直接进入无尽
    pause = mt.pause, -- 暂停计时器
    event = mt.checkUnitEventList, -- 查看单位事件
    boss = mt.testBoss,
    fi = mt.testFinal,
    wa = mt.testWaveBoss,

    -- 测试
    infigold = mt.infigold, -- 无限资源


    cleararch = mt.clearArch, -- 清空删档
    setarch = mt.setArch, -- 设置存档数值（name）（val）
    modarch = mt.modArch, -- 增减存档数值（name）（val）
    unlockarch = mt.unlockArch, -- 解锁存档（name）
    activatearch = mt.activateArch, -- 单次激活存档奖励（name）
    win = mt.win, -- 直接胜利
    lose = mt.lose,

    item = mt.makeItem, -- 创建物品 （x）(y)个
    makebug = mt.makebug,

    setafk = mt.setafk, -- 设置离线时间x秒
    clearint = mt.clearSimpleArch,


    arg = mt.setTestArg, -- 设置测试参数<x>数值为<y>

    framecd = mt.setFrameInterval,
    highframe = mt.setFrameIntervalHigh,
    midframe = mt.setFrameIntervalMid,
    lowframe = mt.setFrameIntervalLow,

    forceasync = mt.forceAsync,

    checkdmg = mt.checkDmg,
    trc = mt.testRightClick,


    addsk = mt.addSkill,
    allyenemy = mt.allyEnemy,

    leak = mt.checkLeak,
    seed = mt.cacheSeed,

    crash = mt.crash, --故意测试原生函数崩溃

    mmp = mt.mmp, -- 小地图测试
}
--------------------------------------------------------------------------------------
function mt:enterMsg(p, msg)
    local args = as.util:splitStr(msg)
    local cmd = table.remove(args, 1)

    if not MAP_DEBUG_MODE then
        return
    end

    if mt.act[cmd] then
        local keys = {
            mt = mt,
            p = p,
            msg = msg,
            args = args,
        }
        mt.act[cmd](mt, keys)
    end
end
--------------------------------------------------------------------------------------

return mt
