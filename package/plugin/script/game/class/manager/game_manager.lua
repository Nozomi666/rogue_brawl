require 'game.class.custom.hero'
require 'game.class.base.weight_pool'
require 'game.class.manager.unit_manager'
require 'game.class.manager.enemy_manager'
require 'game.class.manager.audio_manager'

local mt = {}
gm = mt
GameManager = mt

mt.version = str.format('v%s', GAME_VERSION)

mt.host = nil
mt.state = GAME_STATE_PREGAME
mt.stateTimer = 15
mt.tickInterval = GAME_TICK_INTERVAL

if localEnv then
    mt.stateTimer = 2
end

mt.gameMin = 0
mt.gameSec = 0
mt.time = 0
mt.gameUnixTime = 0
mt.gameUnixDay = 0
mt.gameUnixWeek = 0
mt.unixTime = 0
mt.botNum = 0

mt.loseBufferTime = 20
mt.loseBufferTimeMin = 20
mt.overEnemyNumTime = 0
mt.overEnemyNumIsTrigger = false
mt.fieldEffect = nil

mt.started = false
mt.allPlatformIdLoaded = false

mt.bKilledFinalBoss = false
mt.bGameLost = false
mt.quickMode = false

mt.alivePlayerList = {}
mt.hideEffectChance = 0
mt.tickCounter = 0
mt.chaosMode = 0
MAP_CENTER = ac.point:new(0, 0)

mt.trackingIdCount = 0
mt.freeIds = {} -- 空闲 id 列表
mt.trackingIdTable = {}
mt.initialPlayerNum = 0

--------------------------------------------------------------------------------------
function mt:init()
    -- 事件 游戏开始0秒
    local trig = CreateTrigger()
    TriggerRegisterTimerEventSingle(trig, 0.1)
    TriggerAddAction(trig, mt.awake)
    dbg.handle_ref(trig)

    -- code.setMiniMapIcon([[war3mappreview.tga]])

    mt.loadUnixTime()

    print('游戏版本：' .. mt.version)
    if MAP_DEBUG_MODE then
        print('测试版本')
    end

    if code.checkIsReply() == CLIENT_REPLY then
        REPLY_MODE = true
        gdebug('in reply mode')
    end

end
--------------------------------------------------------------------------------------
function mt:onStartTest()
    local testPoint = gm.mapArea.testPoint
    local pEnemy = cg.BasePlayer:getPlayerById(10)

    -- 靶子

    -- for i = 1, 1 do
    --     local unitJ = CreateUnit(pEnemy.handle, ID('n301'), testPoint[1] + 125 * i, testPoint[2] - 125 * i, 0)
    --     local unit = cg.BaseUnit:link(unitJ)
    --     unit.name = '腐朽村民'
    --     unit:setStats(ST_HP_MAX, 1000000)
    --     unit:setStats(ST_PHY_DEF, 100)
    --     unit:setStats(ST_MAG_DEF, 50)
    --     unit:setStats(ST_DEF_RATE, 100)
    --     unit:modStats(ST_ELEMENT_DMG_RESIST, 50)
    -- end

    reg.makeTestItems()
end
--------------------------------------------------------------------------------------
function mt.awake()
    japi.UnlockFps(true)
    japi.ShowFpsText(true)
    self = mt

    StopMusic(true)

    print('[Init] - game manager awake')

    GUI.setSkillIconPos()

    -- 玩家初始化
    for i = 1, 4 do
        -- 测试 创英雄
        local p = as.player:getPlayerById(i)

        xpcall(function()
            p:enterGame()
            if p:isAlive() then
                self.alivePlayerList[#self.alivePlayerList + 1] = p
            end
        end, function(msg)
            print(msg, debug.traceback())
        end)
    end
    mt:setloseBufferTime()
    -- mt.chapter = reg:getPool('chapters')[1]

    local pEnemy = cg.BasePlayer:getPlayerById(10)

    -- CD商店
    local unitJ = CreateUnit(pEnemy.handle, ID('n000'), 0, 0, 0)
    local unit = cg.BaseUnit:link(unitJ)
    SelectUnitSingle(unitJ)

    ac.wait(ms(0.5), function()
        for y = 0, 3 do
            for x = 0, 2 do
                local frame = japi.FrameGetCommandBarButton(x, y)
                if frame > 0 then
                    local cd = japi.FrameGetButtonCooldownModel(frame)
                    if cd > 0 then
                        japi.FrameSetModelScale(cd, 0.90, 1.22, 1)
                    end
                    -- japi.FrameSetButtonCooldownModelSize(frame, 0.75)
                end
            end
        end
        ClearSelection()
        unit:remove()
    end)

    print('平台ID加载中...')

    local loadTime = 0
    ac.loop(ms(0.5), function(t)
        local allPlatformIdLoaded = true
        loadTime = loadTime + 0.5
        for _, p in ipairs(fc.getAlivePlayers()) do
            if not p:getPlatformId() then
                allPlatformIdLoaded = false
            end
        end

        if allPlatformIdLoaded then
            print('所有玩家平台ID加载完毕...')
            msg.send(cst.ALL_PLAYERS, '所有玩家平台ID加载完毕。')
            glo.udg_allPlayerLoadedPlatformId = true
            mt.allPlatformIdLoaded = true
            t:remove()
        else
            print('平台ID加载中...')

            if loadTime >= 10 then
                msg.warning(cst.ALL_PLAYERS, '有玩家平台ID加载失败，建议重新启动游戏。')
            else
                msg.send(cst.ALL_PLAYERS, '玩家平台ID加载中...')
            end
        end

    end)

    self:pickChapter()

end
--------------------------------------------------------------------------------------
function mt:pickChapter()
    local p = gm.host

    -- local box = p.pickBox
    -- local chapters = reg:getPool('chapters')
    -- box:clean()
    -- mt.selectDiffText = '选择章节'
    -- -- box:setTitle(str.format('请在%d秒内%s', mt.selectDiffTime, mt.selectDiffText))
    -- box:setTitle(str.format('请选择章节'))

    -- local confirmChapter = function(keys)
    --     gm.chapter = keys.chapter
    --     msg.notice(cst.ALL_PLAYERS, str.format('%s 选择了 |cff00ffc8%s|r', p:getName(), keys.chapter.name))
    --     -- ui.curse.setChapter(keys.chapter.id)

    --     mt.pickDiff()
    -- end

    -- for _, chapter in ipairs(chapters) do
    --     local name = chapter.name

    --     box:addBtn(name, confirmChapter, {
    --         chapter = chapter,
    --     }, cst.PICK_BOX_HOT_KEY.NULL)

    -- end
    -- box:showBox()

    gm.chapter = fc.getChapterById(1)
    mt.pickDiff()
end
--------------------------------------------------------------------------------------
function mt.pickDiff()
    local p = gm.host
    local chapter = gm.chapter

    local box = p.pickBox
    box:clean()
    mt.selectDiffTime = 60
    mt.selectDiffText = '选择难度'
    box:setTitle(str.format('请在%d秒内%s', mt.selectDiffTime, mt.selectDiffText))
    local confirmDiff = function(keys)
        EnemyManager.diffNum = keys.diffNum
        msg.notice(cst.ALL_PLAYERS, str.format('%s 选择了 %s', p:getName(), keys.diffName))
        -- ui.waveInfo.updateDiffInfo()

        mt.startGame()
    end

    for i = 1, chapter.maxDiff do
        local name = chapter.diffName[i]

        box:addBtn(name, confirmDiff, {
            diffNum = i,
            diffName = name,
        }, cst.PICK_BOX_HOT_KEY.NULL)

    end
    --------------------------------------------------------------------------------------
    local backToPickChapter = function(keys)
        mt.pickChapter()
    end

    -- box:addBtn('返回选择章节', backToPickChapter, {}, cst.PICK_BOX_HOT_KEY.NULL)
    box:showBox()

end
--------------------------------------------------------------------------------------
function mt.startGame()

    mt.started = true

    EnemyManager:awake()

    local localPlayer = fc.getLocalPlayer()

    --------------------------------------------------------------------------------------
    local mapArea = MapArea:new({
        name = mt.chapter.mapAreaName,
    })
    mt.mapArea = mapArea
    mapArea:setInUse()

    ac.wait(ms(1), function()
        code.setMiniMapIcon(mapArea.miniMapPath)
    end)

    cg.Shop:createShops()
    -- GUI.chapterShow:update(mapArea.path)

    ac.loop(ms(0.5), function(t)
        if mt.allPlatformIdLoaded then
            for _, player in ipairs(fc.getAlivePlayers()) do
                if not test.manualLoadArch then
                    player:loadArchs()
                end

            end
            print('所有玩家平台ID读取完毕；玩家开始加载存档')

            for _, player in ipairs(fc.getAlivePlayers()) do
                player:onPlatformIdLoaded()
            end

            ac.wait(ms(0.5), function()
                for _, player in ipairs(fc.getAlivePlayers()) do
                    player:startGame()
                    -- player:pickHero('暗影牧师')
                end
            end)

            t:remove()
        end
    end)

    -- local player = cg.BasePlayer:getPlayerById(1)
    -- local hero = player:pickHero('边塞诗人')
    -- 
    ac.loop(ms(mt.tickInterval), function()
        GameManager:update()
        EnemyManager:update()
    end)

    ac.loop(ms(1), function()
        mt:onEverySecond()
    end)

    ac.loop(ms(60), function()
        mt:onEveryMinute()
    end)

    mt:startFieldEffect()
    EnemyManager:startModeNormal()

    AudioManager:start()

    if MAP_DEBUG_MODE then
        mt:onStartTest()
    end

    GUI.TopInfo:updateBoard(0, EnemyManager:getMaxEnemy(), 1, MAX_WAVE_NUM - 1)

    gm.gameStarted = true

end
--------------------------------------------------------------------------------------
function mt:update()

    self.tickCounter = self.tickCounter + 1

    self.gameSec = self.gameSec + self.tickInterval
    if self.gameSec >= 59.95 then
        self.gameSec = 0
        self.gameMin = self.gameMin + 1
    end

    if self.tickCounter % 10 == 0 then
        local fps = japi.GetFps()
        if fps <= 22 then
            local hideEffectChance = (22 - fps) * 15
            hideEffectChance = math.clamp(hideEffectChance, 10, 99)
            gm.hideEffectChance = hideEffectChance * 0.01
            -- gdebug('cuurent hide chance: ' .. gm.hideEffectChance)
            if self.gameMin >= 20 then
                self.detectedLowFps = true
            end
            gdebug('self.detectedLowFps')
        else
            gm.hideEffectChance = 0
        end
    end

    if self.state == GAME_STATE_PREGAME then
        if self.stateTimer > 0 then
            self.stateTimer = self.stateTimer - self.tickInterval
        else
            self:enterGameState(GAME_STATE_NORMAL)
        end

    elseif self.state == GAME_STATE_NORMAL then

    end

    for _, p in ipairs(fc.getAlivePlayers()) do
        p.flowTextCount = math.max(p.flowTextCount - 1, 0)
    end

end
--------------------------------------------------------------------------------------
function mt:enterGameState(targetState)
    self.state = targetState

    local prevState = self.state

    if targetState == GAME_STATE_NORMAL then
        gdebug('enterGameState GAME_STATE_NORMAL')
        EnemyManager:start()
        msg.notice(cst.ALL_PLAYERS, '开始战斗。')

    elseif targetState == GAME_STATE_HUNT_MODE_END then
        for _, player in ipairs(fc.getAlivePlayers()) do
            local pJ = player.handle
            CustomVictoryBJ(pJ, true, true)
        end
        GUI.GameWinPanel:updateBoard('win')
        GUI.GameWinPanel:show()

    elseif targetState == GAME_STATE_REST_AFTER_FINAL_BOSS then
        if self.quickMode then
            msg.notice(cst.ALL_PLAYERS, '恭喜通关！即将在|cffffff0030|r秒后退出游戏。', 30)
            msg.notice(cst.ALL_PLAYERS, '快速模式下无法进入无尽/历练。', 30)
            self:enterGameState(GAME_STATE_FINISH)
            ac.wait(ms(30), function()
                for i = 1, 4 do
                    local p = as.player:getPlayerById(i)
                    local pJ = p.handle
                    CustomVictoryBJ(pJ, true, true)
                end
            end)
        elseif (EnemyManager.diffNum == 1 or EnemyManager.diffNum == 2) and (not localEnv) then
            msg.notice(cst.ALL_PLAYERS, '恭喜通关！即将在|cffffff0030|r秒后退出游戏。', 30)
            msg.notice(cst.ALL_PLAYERS, str.format(
                '当前难度|cffec6666暂无|r|cff00d9ff无尽/历练模式|r（|cff00ffc8本章N3起解锁|r）。'),
                30)
            self:enterGameState(GAME_STATE_FINISH)
            ac.wait(ms(30), function()
                for i = 1, 4 do
                    local p = as.player:getPlayerById(i)
                    local pJ = p.handle
                    CustomVictoryBJ(pJ, true, true)
                end
            end)
        else
            ac.wait(ms(2), function()
                local player = gm.host
                if player:isLocal() then
                    GUI.PickModePanel:show()
                end
                local delay = 30
                if localEnv then
                    delay = 5
                end

                ac.wait(ms(delay), function()
                    if self.state ~= GAME_STATE_ENDLESS and self.state ~= GAME_STATE_RANDOM_BOSS then
                        GUI.PickModePanel:hide()
                        if self.state ~= GAME_STATE_RANDOM_BOSS then
                            self:enterEndlessMode()
                        end
                    end
                end)

            end)

        end

    elseif targetState == GAME_STATE_ENDLESS then
        msg.notice(cst.ALL_PLAYERS, '|cff00d9ff无尽模式|r开始了。')
        EnemyManager:startModeEndless()
    elseif targetState == GAME_STATE_POST_ENDLESS then

        EnemyManager:gameLoseFreezeEnemy()

        msg.notice(cst.ALL_PLAYERS, str.format(
            '|cff00d9ff无尽模式|r结束了，最终成绩：|cffffff00%d|r层。', EnemyManager.endlessWaveNum))

        for _, player in ipairs(fc.getAlivePlayers()) do
            player:onCompleteEndless()
        end
        self:enterGameState(GAME_STATE_FINISH)

    end

end
--------------------------------------------------------------------------------------
function mt:onEverySecond()

    if gm.pause then
        return
    end

    local msg = ''
    if self.state == GAME_STATE_PREGAME then
        msg = string.format('|cffffcc00开战倒计时：|r%d秒', math.floor(self.stateTimer))
    else
        self.time = self.time + 1
        msg = string.format('|cffffcc00游戏时间：|r%d分%d秒', self.gameMin, math.floor(self.gameSec))
    end

    if not mt.bGameLost then
        mt:checkLose()
    end

    if EnemyManager.enemyNum >= 120 then
        if FRAME_INTERVAL_NORMAL ~= 0.06 then
            FRAME_INTERVAL_NORMAL = 0.06
            as.loops:resetLootInterval(0.06)
        end
    else
        if FRAME_INTERVAL_NORMAL ~= 0.03 then
            FRAME_INTERVAL_NORMAL = 0.03
            as.loops:resetLootInterval(0.03)
        end
    end

    GUI.multiUsePanel:updateTime(msg)
    -- GUI.ChallengePanel:updateBoard()
end
--------------------------------------------------------------------------------------
function mt:onEveryMinute()
    for _, player in ipairs(fc.getAlivePlayers()) do
        -- player:modSimpleArch(INT_STORAGE.DAILY_ONLINE_TIME, 1)

        -- if player:getSimpleArch(INT_STORAGE.DAILY_ONLINE_TIME) >= 60 then
        --     player:tryUnlockArch('时长')
        --     player:modSimpleArch(INT_STORAGE.ONLINE_TIME_60MIN_COUNT, 1)
        -- end
    end

    if EnemyManager.huntMode then
        local interval = 30
        if localEnv then
            interval = 1
        end
        if self.gameMin % interval == 0 and self.gameMin > 0 then
            -- for _, player in ipairs(fc.getAlivePlayers()) do
            --     player:modSimpleArch(INT_STORAGE.COLLECT_SHARD, 3)
            --     player:modSimpleArch(INT_STORAGE.COLLECT_SHARD_MAX, 3)
            --     player.archEquipManager:addDust(15 + player:getMapLv())
            -- end
        end

        if self.gameMin >= 420 then
            self:enterGameState(GAME_STATE_HUNT_MODE_END)
        end
    end
end
--------------------------------------------------------------------------------------
function mt.gameLose(p, word)
    p.alive = false
    if p.maid then
        p.maid:pause()
    end

    if p.hero then
        p.hero:pause()
        p.hero:hide()
    end

    p:onGameLose()
    table.removeTarget(gm.alivePlayerList, p)

    msg.notice(p, word)
    -- if p:isLocal() then
    --     StopMusic(true)
    -- end

    local confirm = function(keys)
        CustomDefeatBJ(p.handle, "失败！")
    end

    local playerAmt = 0
    for _, player in ipairs(fc.getOnlinePlayers()) do
        playerAmt = playerAmt + 1
    end

    if #fc.getOnlinePlayers() == 4 then
        local total = #EnemyManager.enemies
        local count = 0
        for i, tgt in pairs(EnemyManager.enemies) do
            if tgt.pTarget == p then
                count = count + 1
            end
        end
        if count >= total / 2 then
            -- p:tryUnlockArch('漏勺')
        end

        for i, otherPlayer in ipairs(fc.getOnlinePlayers()) do
            if otherPlayer ~= p and otherPlayer:getGameLevel() < p:getGameLevel() - 10 then
                -- p:tryUnlockArch('会赢的')
                -- otherPlayer:tryUnlockArch('能赢不')
            end
        end
    end

    if p.huijinrutuSpent and p.huijinrutuSpent >= 10000000 then
        -- p:tryUnlockArch('挥金如土')
    end

    ac.wait(ms(4), function()

        GUI.GameWinPanel:updateBoard('lose')
        GUI.GameWinPanel:show()

        -- if not p.hideLose then
        --     local box = p.pickBox
        --     box:clean()
        --     box:setTitle(str.format(word))
        --     box:addBtn('继续观战', nil, {}, cst.PICK_BOX_HOT_KEY.NULL)

        --     box:addBtn('退出游戏', confirm, {}, cst.PICK_BOX_HOT_KEY.NULL)
        -- end

    end)

end
--------------------------------------------------------------------------------------
function mt:checkLose()

    if EnemyManager.enemyNum > EnemyManager:getMaxEnemy() then
        self.overEnemyNumIsTrigger = true
        if mt.loseBufferTime >= 0 then
            msg.warning(cst.ALL_PLAYERS,
                str.format('敌人数量超过上限，还剩[|cffff2020%d|r]秒失败。', mt.loseBufferTime))
        end

        if mt.loseBufferTime <= 0 then

            if self.state == GAME_STATE_NORMAL then

                mt.bGameLost = true
                local playerList = table.clone(fc.getAlivePlayers())
                for _, p in ipairs(playerList) do
                    xpcall(function()
                        mt.gameLose(p, '敌人数量超过上限过久，游戏失败。')
                    end, traceError)

                end

            elseif self.state == GAME_STATE_ENDLESS then
                if not EnemyManager.endlessEnd then
                    EnemyManager.endlessEnd = true
                    self:enterGameState(GAME_STATE_POST_ENDLESS)
                end

            end

            EnemyManager:gameLoseFreezeEnemy()

        end

        mt.loseBufferTime = mt.loseBufferTime - 1
        mt.closeToLose = true
        mt.overEnemyNumTime = mt.overEnemyNumTime + 1
        if mt.overEnemyNumTime >= 300 then
            for _, p in ipairs(fc.getAlivePlayers()) do
                -- p:tryUnlockArch([[赖着不死]])
            end
        end

    else
        if mt.closeToLose then
            mt.loseBufferTime = math.max(mt.loseBufferTime + 1, mt.loseBufferTimeMin)
            mt.closeToLose = false

        end

    end

end
--------------------------------------------------------------------------------------
function mt.gameWin()

    local playerAmt = 0
    local highMapLvPlayer = {}
    local lowMapLvPlayer = {}

    for _, p in ipairs(fc.getAlivePlayers()) do
        local mapLv = p:getMapLv()
        if mapLv > 7 then
            table.insert(highMapLvPlayer, p)
        end
        if mapLv <= 7 then
            table.insert(lowMapLvPlayer, p)
        end
        xpcall(function()
            p:onGameWin()
        end, traceError)
        playerAmt = playerAmt + 1

        p:tryUnlockArch(string.format('%d-%d-%d', gm.chapter.id, EnemyManager.diffNum, 1))
        local condition2 = self.overEnemyNumIsTrigger
        if condition2 == false then
            p:tryUnlockArch(string.format('%d-%d-%d', gm.chapter.id, EnemyManager.diffNum, 2))
        end
        local condition3 = EnemyManager.eliminateBattlefieldTime
        if condition3 >= 2 then
            p:tryUnlockArch(string.format('%d-%d-%d', gm.chapter.id, EnemyManager.diffNum, 3))
        end
        local condition4 = EnemyManager.quicklyKillFinalBoss
        if condition4 then
            p:tryUnlockArch(string.format('%d-%d-%d', gm.chapter.id, EnemyManager.diffNum, 4))
        end
        --------------------------------------------------------------------------------------
        if EnemyManager.diffNum >= 5 and EnemyManager.diffHeatLv > 0 then
            local diffList = {'I', 'II', 'III', 'IV'}
            local list2 = {'浅尝辄止', '渐入佳境', '深入探索', '登峰造极', '终极疯狂'}
            if gm.chapter.id == 2 then
                list2 = {'浅尝辄止2-', '渐入佳境2-', '深入探索2-', '登峰造极2-', '终极疯狂2-'}
            end
            if gm.chapter.id == 3 then
                list2 = {'浅尝辄止3-', '渐入佳境3-', '深入探索3-', '登峰造极3-', '终极疯狂3-'}
            end
            local diffHeatLv = EnemyManager.diffHeatLv
            local diffNum = EnemyManager.diffNum
            diffNum = diffNum - 4
            local currentDiff = diffList[diffNum]
            local listLength = 1
            if diffHeatLv == 80 then
                listLength = 5
            elseif diffHeatLv < 80 and diffHeatLv >= 60 then
                listLength = 4
            elseif diffHeatLv < 60 and diffHeatLv >= 40 then
                listLength = 3
            elseif diffHeatLv < 40 and diffHeatLv >= 20 then
                listLength = 2
            end

            local archNameList = {}
            for i = 1, listLength, 1 do
                local archName = list2[i] .. currentDiff
                table.insert(archNameList, archName)
            end
            for i, v in ipairs(archNameList) do
                p:tryUnlockArch(v)
            end
        end
    end

    if (#highMapLvPlayer ~= 0) and (#lowMapLvPlayer ~= 0) then
        for i = 1, #highMapLvPlayer, 1 do
            local p = highMapLvPlayer[i]
           --  p:modSimpleArch(INT_STORAGE.DAIXINCISHU, 1)
        end
        for i = 1, #lowMapLvPlayer, 1 do
            local p = lowMapLvPlayer[i]
            -- p:modSimpleArch(INT_STORAGE.BEIDAIXINCISHU, 1)
        end
    end

    if playerAmt >= 4 then
        for _, p in ipairs(fc.getAlivePlayers()) do
            p:tryUnlockArch('探险小队')
        end
    end

    local playerList = fc.getAlivePlayers()
    if #playerList then
        table.sort(playerList, function(a, b)
            return a:getMapLv() < b:getMapLv()
        end)
    end

    mt.bKilledFinalBoss = true

    ac.wait(ms(3), function()
        GUI.GameWinPanel:updateBoard('win')
        GUI.GameWinPanel:show()

        for _, player in ipairs(fc.getAlivePlayers()) do
            player.archRewardList = {}
        end
    end)

end
--------------------------------------------------------------------------------------
function mt.onKillFinalBoss()
    mt.gameWin()
end
--------------------------------------------------------------------------------------
function mt.setGameOver()
    gm.gameOver = true

    ac.wait(ms(30), function()
        for i = 1, 4 do
            local p = as.player:getPlayerById(i)
            local pJ = p.handle
            CustomVictoryBJ(pJ, true, true)
        end

    end)
end
--------------------------------------------------------------------------------------
function mt.loadUnixTime()
    local gameUnixTime = code.getUnixTime()
    if localEnv then
        gameUnixTime = os.time()
        -- gameUnixTime = 1746489599 - 3 * 60 * 60
        -- gameUnixTime = 1746489601 - 3 * 60 * 60
        gdebug('load local unixtime: ' .. gameUnixTime)
    end
    mt.unixTime = gameUnixTime
    -- gameUnixTime = 1683265313
    gameUnixTime = gameUnixTime + 3 * 60 * 60 -- 同步到北京时间
    mt.gameUnixTime = gameUnixTime
    mt.gameUnixDay = math.floor(gameUnixTime / 60 / 60 / 24)

    local diffTime = gameUnixTime - EARLIEST_WEEK_UNIX_TIME
    mt.gameUnixWeek = math.floor(diffTime / (7 * 24 * 60 * 60)) + 1

    -- mt.gameUnixDay = 19483

    print('unix时间：' .. mt.gameUnixTime)
    print('unix天数：' .. mt.gameUnixDay)
    print('unix周数：' .. mt.gameUnixWeek)
end
--------------------------------------------------------------------------------------
function mt:startFieldEffect()
    local chapterId = gm.chapter.id
    --[[if localEnv then
        chapterId = 2
    end]]

    -- local pool = reg:getPool(str.format('fieldEffect_%d', chapterId))
    -- local fieldEffect = fc.rngSelect(pool)

    -- gdebug('本局场地效果：' .. fieldEffect.name)
    -- gm.fieldEffect = fieldEffect
    -- fieldEffect:onSwitch(true)

end
--------------------------------------------------------------------------------------
function mt:getDiffRate()
    return gm.chapter.diffRate[EnemyManager.diffNum]
end
--------------------------------------------------------------------------------------
function mt:setloseBufferTime()
    local alivePlayerNum = #fc.getAlivePlayers()
    local loseBufferTime = 15 + alivePlayerNum * 5
    mt.loseBufferTime = loseBufferTime
end
--------------------------------------------------------------------------------------
function mt:enterEndlessMode()
    local delay = 20
    if localEnv then
        delay = 3
    end
    msg.notice(cst.ALL_PLAYERS, '20秒后进入无尽模式。')
    ac.wait(ms(delay), function()
        self:enterGameState(GAME_STATE_ENDLESS)
        for _, player in ipairs(fc.getAlivePlayers()) do
            player:triggerEvent(PLAYER_EVENT_ON_ENDLESS_START, {})
        end
    end)
end
--------------------------------------------------------------------------------------
function mt:trackNewObject(obj)
    if obj.trackingId then
        -- gdebug('trackNewObject fail, 已经有跟踪 id')
        return obj.trackingId
    end
    if #mt.freeIds > 0 then
        -- 如果有可复用的 id，从列表中取出
        obj.trackingId = table.remove(mt.freeIds)
        -- gdebug('复用 id: ' .. obj.trackingId)
    else
        -- 没有空闲 id，则生成一个新的 id
        mt.trackingIdCount = mt.trackingIdCount + 1
        obj.trackingId = mt.trackingIdCount
        -- gdebug('新 id: ' .. obj.trackingId)
    end
    mt.trackingIdTable[obj.trackingId] = obj
    return obj.trackingId
end
--------------------------------------------------------------------------------------
function mt:untrackObject(obj)
    if not obj.trackingId then
        -- gdebug('untrackObject fail, 没有跟踪 id')
        return
    end
    local id = obj.trackingId
    obj.trackingId = nil
    mt.trackingIdTable[id] = nil
    table.insert(mt.freeIds, id)
    -- gdebug('释放 id: ' .. id)
end
--------------------------------------------------------------------------------------
fc.getDiffRate = mt.getDiffRate
--------------------------------------------------------------------------------------
mt:init()

return mt
