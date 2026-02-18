require 'game.__api.arch'
-- require 'game.class.manager.arch.arch_game_reward_manager'
-- require 'game.class.manager.arch.artifact_manager'
-- require 'game.class.manager.arch.hero_deck_manager'

local mt = {}
mt.__index = mt
as.archManager = mt

mt.owner = nil
mt.player = nil -- alias
mt.archVal = nil
mt.archSimple = nil
mt.bRefreshedDayReward = false
mt.bRefreshedWeekReward = false
mt.uploadTimer = {}

mt.allArchs = {}
mt.allSimpleArchs = nil
mt.bLoadComplete = false
mt.dayRefreshedTable = nil
mt.weekRefreshedTable = nil
mt.extraSimpleArchValList = nil
mt.playerStartUnixDay = 0
mt.playGameDay = 0

--------------------------------------------------------------------------------------
-- custom
mt.archPower = 0

--------------------------------------------------------------------------------------
function mt:new(p)
    -- init table
    local o = {}
    setmetatable(o, self)
    o.owner = p
    o.player = p

    o.archVal = {}
    o.archValInvalidTable = {}
    o.archSimple = {}
    o.uploadTimer = {}
    o.allSimpleArchs = {}
    o.autoUnlockList = {}
    o.forceUnlockStoreList = {}
    o.dayRefreshedTable = {}
    o.weekRefreshedTable = {}
    o.extraSimpleArchValList = {}

    return o
end
--------------------------------------------------------------------------------------
function mt:init()

    local player = self.player
    gdebug('init arch manager')

    self:loadStartPlayDay()
    self:loadUnixDay()
    self:loadUnixWeek()


    -- --------------------------------------------------------------------------------------
    -- 游戏等级
    -- local archGameRewardManager = ArchGameRewardManager:new(self.player)
    -- self.player.archGameRewardManager = archGameRewardManager
    -- self.archGameRewardManager = archGameRewardManager
    -- self.player.agrm = archGameRewardManager


    -- --------------------------------------------------------------------------------------
    self.bLoadComplete = true

    --------------------------------------------------------------------------------------
    -- auto unlock
    local list = self.autoUnlockList
    for _, pack in ipairs(list) do
        gdebug('try auto unlock: ' .. pack.name)

        xpcall(function()
            self:tryUnlockArch(pack.name, {
                hideHint = true,
            })
        end, traceError)

    end

    local forceUnlockStoreList = self.forceUnlockStoreList
    for _, pack in ipairs(forceUnlockStoreList) do
        local archName = pack.name
        gdebug('force unlock store arch: ' .. archName)
        self:setArchVal(archName, true)

        if pack.onUnlock then
            xpcall(function()
                pack.onUnlock(self.player, pack)
            end, function(msg)
                print(msg, debug.traceback())
            end)
        end
    end

    --------------------------------------------------------------------------------------
    -- late loads
    --------------------------------------------------------------------------------------
    -- xpcall(function()
    --     archGameRewardManager:lateLoad()
    -- end, traceError)

    ------------------------------------------------------------------------------------
    -- xpcall(function()
    --     artifactManager:lateLoad()
    --     -- if self.player:isLocal() then
    --     --     GUI.ArtifactBagPanel:updateBoard()
    --     -- end
    -- end, traceError)

    -- if player:isLocal() then
    --     GUI.ArtifactPanel:updateBoard()
    -- end

    -- xpcall(function()
    --     self.player.talentManager:lateLoad()
    --     if self.player:isLocal() then
    --         GUI.TalentTreePanel:updateBoard()
    --     end
    -- end, traceError)

end
--------------------------------------------------------------------------------------
function mt:lockArch(archName)
    self:setArchVal(archName, false)

end
--------------------------------------------------------------------------------------
function mt:tryUnlockArch(archName, keys)
    local p = self.owner

    if p:isCheat() then
        gdebug('作弊不解锁存档：' .. archName)
        return
    end
    if p:hasArchRegardlessInvalid(archName) and (not test.allowRepeatArch) then
        -- gdebug('already unlocked ' .. archName)
        return
    end

    local pack = reg:getTableData('archData', archName)
    if not pack then
        BJDebugMsg(str.format('玩家[%s]储存存档数值出现错误：%s', p:getName(), archName))
        return
    end

    local passCondition = true
    if pack.condition then
        passCondition = pack.condition(p, pack)
    end

    if not passCondition then
        return
    end

    self:setArchVal(archName, true, keys and keys.immediate)
    local title = pack.title

    --------------------------------------------------------------------------------------
    local showTip = true
    if keys and (not keys.hideHint) then
        showTip = false
    end

    if not title then
        showTip = false
    end

    if pack.hideUnlockHint then
        showTip = false
    end

    if showTip then
        msg.arch(p, str.format('你解锁了存档奖励【|cffffff00%s|r】！', title))
    end
    --------------------------------------------------------------------------------------

    if pack.onUnlock then
        gdebug('tryUnlockArch解锁成就：%s', archName)
        xpcall(function()
            pack.onUnlock(p, pack)
        end, function(msg)
            print(msg, debug.traceback())
        end)
    end

    self:activateArch(archName)

    return true
end
--------------------------------------------------------------------------------------
function mt:forceUnlockArch(archName)
    local p = self.owner

    gdebug('玩家【%s】强制解锁成就：%s', p, archName)

    local pack = reg:getTableData('archData', archName)
    if not pack then
        BJDebugMsg(str.format('玩家[%s]储存存档数值出现错误：%s', p:getName(), archName))
        return
    end

    self:setArchVal(archName, true)
    local title = pack.title

    if title then
        msg.arch(p, str.format('你解锁了永久奖励[|cffffff00%s|r]！', title))
    end

    if pack.onUnlock then
        xpcall(function()
            pack.onUnlock(p, pack)
        end, function(msg)
            print(msg, debug.traceback())
        end)
    end

    self:activateArch(archName)

end
--------------------------------------------------------------------------------------
function mt:loadArchList(listName, listType)
    gdebug('loadArchList: ' .. listName)

    if self.dayRefreshedTable[listName] then
        gdebug('cancel load day refreshed arch: ' .. listName)
        return
    end

    if self.weekRefreshedTable[listName] then
        gdebug('cancel load week refreshed arch: ' .. listName)
        return
    end

    xpcall(function()

        local list = reg:getPool(listName)
        if not list then
            BJDebugMsg('无存档list：' .. listName)
            return
        end
        local listType = cst.ARCH_TYPE_BOOL
        if fc.getAttr(listName, 'isNumberArch') then
            listType = cst.ARCH_TYPE_NUM
        end
        local p = self.owner
        local pJ = p.handle

        if listType == cst.ARCH_TYPE_BOOL then
            arch.loadBool(pJ, listName)
        elseif listType == cst.ARCH_TYPE_NUM then
            arch.loadNum(pJ, listName)
        end

        for i, pack in ipairs(list) do
            if listType == cst.ARCH_TYPE_NUM then
                self.archVal[pack.name] = 0
            end

            self:loadArch(pack.name, listType)

        end

        table.insert(mt.allArchs, listName)

    end, function(msg)
        print(msg, debug.traceback())
    end)

end
--------------------------------------------------------------------------------------
function mt:loadArch(archName, archListType)
    local p = self.owner
    if not p then
        return
    end

    xpcall(function()
        local pJ = p.handle

        local pack = reg:getTableData('archData', archName)

        if not pack then
            BJDebugMsg(str.format('玩家[%s]储存存档数值出现错误：%s', p:getName(), archName))
            return
        end

        local archListId = pack.archListId
        local archListName = pack.archListName
        local val

        if pack.bStoreItem and (not pack.typeFree) then
            val = archFunc.getStoreCount(p, pack)
            if val and val ~= 0 then
                local archRecordVal = arch.loadArch(pJ, archListName, archListId)
                if (not archRecordVal) or archRecordVal == 0 then
                    self.forceUnlockStoreList[#self.forceUnlockStoreList + 1] = pack
                end

            end
        else
            val = arch.loadArch(pJ, archListName, archListId)
        end

        local ignoreCondition = false
        if test.cheatArch then
            if p.fakeAchivementList then
                if p.fakeAchivementList[archName] then
                    val = p.fakeAchivementList[archName]
                    ignoreCondition = true
                    gdebug('load player [%s] fake achivement [%s]', p:getName(), archName)
                end
            end
        end

        if p:isCheat() then
            if archListType == cst.ARCH_TYPE_BOOL then
                gdebug('作弊清真值档')
                val = false
            else
                val = 0
                gdebug('作弊清数字档')
            end
        end

        if val and val ~= 0 then

            local passCondition = true
            if pack.condition then
                if not ignoreCondition then
                    passCondition = pack.condition(p, pack)
                end
            end

            if passCondition then
                self.archVal[archName] = val
                self:activateArch(archName, val)

            else
                archlog(
                    str.format('检测存档条件失败。玩家：%s 存档：%s', self.player:getName(), archName))
            end
        else

            if pack.bAutoUnlock then
                self.autoUnlockList[#self.autoUnlockList + 1] = pack
            end

        end

    end, function(msg)
        print(msg, debug.traceback())
    end)

    -- self:setArchVal(archName, val)

end
--------------------------------------------------------------------------------------
function mt:setArchVal(archName, val, isImmediate, modVal, ignoreLoadComplete)
    local p = self.owner
    local pJ = p.handle
    local pack = reg:getTableData('archData', archName)
    if self.player:isCheat() then
        gdebug('检测到作弊；设置存档不生效')
        return
    end

    if not pack then
        BJDebugMsg(str.format('玩家[%s]更新存档数值出现错误：%s', p:getName(), archName))
        return
    end

    if not ignoreLoadComplete then
        if not self.bLoadComplete then
            if localEnv then
                msg.error(p, str.format('保存存档【|cffffff00%s|r】失败；发生在读取存档完毕前',
                    archName), 66)
            end
            archlog(str.format('保存存档【|cffffff00%s|r】失败；发生在读取存档完毕前', archName))

            return
        end
    end

    -- if pack.bStoreItem and (not pack.typeFree) then
    --     archlog(str.format('store item can not set arch val: %s', archName))
    --     return
    -- end

    local archListName = pack.archListName
    local archListId = pack.archListId

    self.archVal[archName] = val
    arch.saveArch(pJ, archListName, archListId, val)

    if pack.onModVal then
        xpcall(function()
            pack.onModVal(p, modVal)
        end, function(msg)
            print(msg, debug.traceback())
        end)

    end

    self:uploadArch(archName, isImmediate)
end

--------------------------------------------------------------------------------------
function mt:getArchVal(archName)
    return self.archVal[archName]
end
--------------------------------------------------------------------------------------
function mt:modArchVal(archName, val, isImmediate)
    local p = self.owner
    local pJ = p.handle
    local prev = self.archVal[archName] or 0
    local pack = reg:getTableData('archData', archName)
    if not pack then
        archlog('玩家[%s]更新存档数值出现错误：%s，更改数值：%.0f', p:getName(), archName, val)
        BJDebugMsg(str.format('玩家[%s]更新存档数值出现错误：%s', p:getName(), archName))
        return
    end

    if pack.examModVal then
        val = pack.examModVal(p, val)
    end

    val = math.floor(val)

    local archListName = pack.archListName
    local after = prev + val

    self:setArchVal(archName, after, isImmediate, val)
    gdebug('after mod arch val: ' .. after)
end
--------------------------------------------------------------------------------------
function mt:uploadArch(archName, isImmediate)
    local p = self.owner
    local pack = reg:getTableData('archData', archName)
    if not pack then
        BJDebugMsg(str.format('玩家[%s]更新存档数值出现错误：%s', p:getName(), archName))
        return
    end

    local archListName = pack.archListName

    if isImmediate then
        self:uploadArchList(archListName)
        return
    end

    if self.uploadTimer[archListName] then
        return
    end

    gdebug('upload arch ' .. archName)

    self.uploadTimer[archListName] = ac.wait(ms(1), function()
        self:uploadArchList(archListName)
        self.uploadTimer[archListName] = nil
    end)

end
--------------------------------------------------------------------------------------
function mt:uploadArchList(listName)
    local p = self.owner
    local pJ = p.handle

    if p.cheatArch then
        return
    end

    gdebug('upload archlist: ' .. listName)
    -- print(debug.traceback())

    local listType = cst.ARCH_TYPE_BOOL
    if fc.getAttr(listName, 'isNumberArch') then
        listType = cst.ARCH_TYPE_NUM
    end

    if listType == cst.ARCH_TYPE_BOOL then
        arch.saveBool(pJ, listName)
    elseif listType == cst.ARCH_TYPE_NUM then
        arch.saveNum(pJ, listName)
    end

end
--------------------------------------------------------------------------------------
function mt:clearArchList(listName)
    local p = self.owner
    local pJ = p.handle
    -- arch.saveData(pJ, listName, '')

    code.saveServerString(p.handle, listName, '')

end
--------------------------------------------------------------------------------------
function mt:clearArchs()
    local p = self.owner

    for i, listName in ipairs(mt.allArchs) do
        self:clearArchList(listName)
    end

    for i = 1, 4 do
        code.saveServerString(p.handle, str.format('TFCDC%d', i), '')
    end

end
--------------------------------------------------------------------------------------
function mt.getPresentList(presentName)
    if fc.getStringVal(presentName) then
        return fc.getStringVal(presentName)
    end

    local cands = linked.create()

    local presentList = reg:getPool(presentName)
    for _, archListName in ipairs(presentList) do
        gdebug('archlistname: ' .. archListName)
        local archList = reg:getPool(archListName)
        for _, pack in ipairs(archList) do
            if not pack.prevArchName then
                cands:add(pack)
            else
                -- local prevArch = reg:getTableData('archData',pack.prevArchName)

                -- find
                -- cands:add(pack)
            end

        end
    end

    fc.setStringVal(presentList, cands)
    return cands

end
--------------------------------------------------------------------------------------
function mt:loadSimpleArch(archName)
    local p = self.owner
    local pj = p.handle

    if self.dayRefreshedTable[archName] then
        gdebug('cancel load day refreshed arch: ' .. archName)
        return
    end

    if self.weekRefreshedTable[archName] then
        gdebug('cancel load week refreshed arch: ' .. archName)
        return
    end

    local pack = reg:getTableData('archData', archName)
    if not pack then
        print(str.format('error - load simple arch no pack - archName: %s', archName))
        return
    end

    local val = code.loadServerInt(pj, archName)
    print(str.format('load simple arch: %s, %d', archName, val))

    if self.player:isCheat() then
        val = 0
        -- self.archSimple[archName] = 0
        gdebug('检测到作弊；读取整数存档不生效')
        return
    end

    if val < 0 then
        print(
            str.format('detect cheat: player: %s, archName: %s, val: %d', self.player:getPlatformName(), archName, val))
        val = 0
    end

    self.archSimple[archName] = val or 0
    self:activateArch(archName, val)

    table.insert(self.allSimpleArchs, archName)

end
--------------------------------------------------------------------------------------
function mt:uploadSimpleArch(archName)
    local p = self.owner
    local pj = p.handle

    local pack = reg:getTableData('archData', archName)
    if not pack then
        print(str.format('error - upload simple arch no pack - archName: %s', archName))
        return
    end

    local val = self.archSimple[archName]

    print(str.format('upload simple arch: %s, %d', archName, val))
    code.saveServerInt(pj, archName, val)
end
--------------------------------------------------------------------------------------
function mt:setSimpleArch(archName, val, delay, ignoreLoadComplete)
    local p = self.owner

    if not ignoreLoadComplete then
        if not self.bLoadComplete then
            if localEnv then
                msg.error(p, str.format('保存存档【|cffffff00%s|r】失败；发生在读取存档完毕前',
                    archName), 66)
                traceError()
            end

            archlog(str.format('保存存档【|cffffff00%s|r】失败；发生在读取存档完毕前', archName))
            return
        end
    end

    if self.player:isCheat() then
        gdebug('检测到作弊；设置存档不生效')
        return
    end

    self.archSimple[archName] = val

    if delay then
        if self.uploadTimer[archName] then
            return
        end

        self.uploadTimer[archName] = ac.wait(ms(1), function()
            self:uploadSimpleArch(archName)
            self.uploadTimer[archName] = nil
        end)
    else
        self:uploadSimpleArch(archName)
    end

end
--------------------------------------------------------------------------------------
function mt:modSimpleArch(archName, val, delay, ignoreDayMaxStorage, ignoreLoadComplete, ignoreRecord)
    local p = self.owner
    local pJ = p.handle
    local prev = self.archSimple[archName] or 0
    local pack = reg:getTableData('archData', archName)
    gdebug('set arch val: ' .. archName .. ' ' .. val)
    if not pack then
        BJDebugMsg(str.format('玩家[%s]更新存档数值出现错误：%s', p:getName(), archName))
        return
    end

    val = math.floor(val)

    local dayMaxStorage = pack.dayMaxStorage
    local weekMaxStorage = pack.weekMaxStorage
    if val > 0 and dayMaxStorage and (not ignoreDayMaxStorage) then
        gdebug(str.format('%s has dayMaxStorage.', archName))
        local dayCurrent = self:getSimpleArch(dayMaxStorage)
        local dayMax = pack.getDayMax(p)
        local maxMod = dayMax - dayCurrent
        gdebug(str.format('day current: %d', dayCurrent))
        gdebug(str.format('day max: %d', dayMax))
        gdebug(str.format('max mod: %d', maxMod))
        if val >= maxMod then
            local dayMaxPack = reg:getTableData('archData', dayMaxStorage)
            local dayMaxName = dayMaxPack.dayMaxName or dayMaxPack.name
            if not dayMaxPack.hideLimit then
                msg.notice(p, str.format('存档[|cffffff00%s|r]获取值已达今日上限。', dayMaxName))
            end
        end
        val = math.min(val, maxMod)
        if maxMod < 0 then
            print('detect cheating...')
            return
        end
        if maxMod == 0 then
            gdebug('%s hit daymax storage', archName)
            return
        end

        self:modSimpleArch(dayMaxStorage, val, false, false, ignoreLoadComplete, ignoreRecord)
    elseif val > 0 and weekMaxStorage and (not ignoreDayMaxStorage) then
        gdebug(str.format('%s has weekMaxStorage.', archName))
        local weekCurrent = self:getSimpleArch(weekMaxStorage)
        local weekMax = pack.getWeekMax(p)
        local maxMod = weekMax - weekCurrent
        gdebug(str.format('week current: %d', weekCurrent))
        gdebug(str.format('week: %d', weekMax))
        gdebug(str.format('max mod: %d', maxMod))
        if val >= maxMod then
            local weekMaxPack = reg:getTableData('archData', weekMaxStorage)
            local weekMaxName = weekMaxPack.weekMaxName or weekMaxPack.name
            if not weekMaxPack.hideLimit then
                msg.notice(p, str.format('存档[|cffffff00%s|r]获取值已达本周上限。', weekMaxName))
            end
        end
        val = math.min(val, maxMod)
        if maxMod < 0 then
            print('detect cheating...')
            return
        end
        if maxMod == 0 then
            gdebug('%s hit daymax storage', archName)
            return
        end

        self:modSimpleArch(weekMaxStorage, val, false, false, ignoreLoadComplete, ignoreRecord)

    end

    local after = prev + val

    if val > 0 then
        if pack.onAddVal then
            xpcall(function()
                pack.onAddVal(p, val, ignoreRecord)
            end, function(msg)
                print(msg, debug.traceback())
            end)

        end
    end

    gdebug(str.format('%s after mod arch val: %d', archName, after))
    self:setSimpleArch(archName, after, delay, false, ignoreLoadComplete)
    return after
end
--------------------------------------------------------------------------------------
function mt:getFixedSimpleArch(archName)

    local val = self:getSimpleArch(archName)

    return val
end
--------------------------------------------------------------------------------------
function mt:modOverflowSimpleArchVal(archName, val)
    if not self.extraSimpleArchValList[archName] then
        self.extraSimpleArchValList[archName] = 0
    end

    self.extraSimpleArchValList[archName] = self.extraSimpleArchValList[archName] + val

    local archPack = reg:getTableData('archData', archName)
    if archPack and archPack.onAddVal then
        xpcall(function()
            archPack.onAddVal(self.owner, val, true)
        end, function(msg)
            print(msg, debug.traceback())
        end)
    end

end
--------------------------------------------------------------------------------------
function mt:getSimpleArch(archName)
    local val = self.archSimple[archName] or 0
    if val < 0 then
        print(str.format('detect cheat: archName: %s, val: %d', archName, val))
        self.archSimple[archName] = 0
        code.saveServerInt(self.player.handle, archName, 0)
    end

    local pack = reg:getTableData('archData', archName)
    if pack and pack.onFixGet then
        -- gdebug('has onFixGet')
        val = pack.onFixGet(self.owner, val)
    end

    if pack and pack.startUnixTime and ((not localEnv) or (not TEST_ARCH_OVER_LIMIT)) then
        local earliestTime = pack.startUnixTime
        -- if TESTING_SERVER and pack.startUnixTimeTestServer then
        --     earliestTime = pack.startUnixTimeTestServer
        -- end

        local currentTime = os.time()
        if not localEnv then
            currentTime = gm.unixTime
        end

        local timeDiff = currentTime - earliestTime
        local timeDiffInDay = math.floor(timeDiff / 86400) + 1

        local playGameDay = self.playGameDay
        timeDiffInDay = math.min(timeDiffInDay, playGameDay)

        local dayMax = self:getSimpleArchDayMax(archName)
        local totalMax = dayMax * timeDiffInDay

        gdebug('check unix anti cheat: ' .. archName)
        gdebug('current val: ' .. val)
        gdebug('current timeDiffInDay: ' .. timeDiffInDay)
        gdebug('max day val: ' .. dayMax)
        gdebug('max val: ' .. totalMax)

        if val > totalMax then
            if pack.keepMax then
                val = totalMax
            else
                val = totalMax / 2
            end

            gdebug('find overrate, divide / 2')
        end
    -- elseif pack.startWeekTime and ((not localEnv) or (not TEST_ARCH_OVER_LIMIT)) then
    elseif pack.startWeekTime then
        local possibleMaxWeek = fc.getUnixWeekToNow(pack.startWeekTime)
        local weekMax = self:getSimpleArchWeekMax(archName)
        local totalMax = weekMax * possibleMaxWeek
        gdebug('check unix week anti cheat: ' .. archName)
        gdebug('current val: ' .. val)
        gdebug('current possibleMaxWeek: ' .. possibleMaxWeek)
        gdebug('max week val: ' .. weekMax)
        gdebug('max val: ' .. totalMax)

        if val > totalMax then
            -- if pack.keepMax then
            --     val = totalMax
            -- else
            --     val = totalMax * 2 / 3
            -- end

            val = totalMax

            gdebug('find overrate week (keep max)')
        end
    end

    local dataList = ADD_EXTRA_INT_ARCH[self.player:getPlatformName()]
    if dataList then
        if dataList[archName] then
            val = val + dataList[archName]
        end
    end

    local dataList = ADD_EXTRA_INT_ID_ARCH[self.player:getPlatformId()]
    if dataList then
        if dataList[archName] then
            val = val + dataList[archName]
        end
    end

    if self.extraSimpleArchValList[archName] then
        val = val + self.extraSimpleArchValList[archName]
        -- gdebug('extraSimpleArchValList: ' .. archName .. '额外提供： ' .. self.extraSimpleArchValList[archName])
    end

    return val
end
--------------------------------------------------------------------------------------
function mt:clearSimpleArch()
    for i, archName in ipairs(self.allSimpleArchs) do
        self:setSimpleArch(archName, 0)
    end
end
--------------------------------------------------------------------------------------
function mt:loadStartPlayDay()
    local p = self.owner
    local pj = p.handle
    local nowUnixDay = gm.gameUnixDay
    if nowUnixDay < -1 then
        msg.error(cst.ALL_PLAYERS, 'get nowUnixDay fail.')
        return
    end

    local playerStartUnixDay = code.loadServerInt(pj, INT_STORAGE.PLAYER_START_UNIX_DAY)
    if playerStartUnixDay == 0 then
        playerStartUnixDay = nowUnixDay - 2
        code.saveServerInt(pj, INT_STORAGE.PLAYER_START_UNIX_DAY, nowUnixDay - 2)
        print('set playerStartUnixDay to ' .. playerStartUnixDay)
    end
    self.playerStartUnixDay = playerStartUnixDay

    local earliestMapDay = math.floor(GENERAL_START_UNIX_TIME / 60 / 60 / 24)
    self.playerStartUnixDay = math.max(self.playerStartUnixDay, earliestMapDay)

    self.playGameDay = nowUnixDay - self.playerStartUnixDay
    self.playGameDay = math.max(self.playGameDay, 0)
    print('player playGameDay: ' .. self.playGameDay)
end
--------------------------------------------------------------------------------------
function mt:getPlayGameDay()
    return self.playGameDay
end
--------------------------------------------------------------------------------------
function mt:loadUnixWeek()
    local p = self.owner
    local pj = p.handle
    local storageName = INT_STORAGE.UNIX_WEEK
    local oldUnixWeek = code.loadServerInt(pj, storageName)
    if oldUnixWeek then
        gdebug('oldUnixWeek is: ' .. oldUnixWeek)
    else
        gdebug('oldUnixWeek is nil, set to 0')
        oldUnixWeek = 0
    end

    local nowUnixWeek = gm.gameUnixWeek
    if nowUnixWeek < -1 then
        msg.error(cst.ALL_PLAYERS, 'get nowUnixWeek fail.')
        return
    end

    if oldUnixWeek > nowUnixWeek then
        code.saveServerInt(pj, storageName, nowUnixWeek)
        return
    end

    if nowUnixWeek <= oldUnixWeek then
        gdebug('already the latest unixweek')
        return
    end

    gdebug(str.format('update old unix week to new unix week: %d -> %d', oldUnixWeek, nowUnixWeek))
    code.saveServerInt(pj, storageName, nowUnixWeek)

    self:refreshCurrentWeek()

end
--------------------------------------------------------------------------------------
function mt:refreshCurrentWeek()
    local p = self.owner
    local pj = p.handle

    print(str.format('玩家[%s]刷新每周存档', p:getName()))
    self.bRefreshedWeekReward = true
    --------------------------------------------------------------------------------------
    -- 每日计数的存档
    local refreshList = reg:getPool('arch_week_clear_list')

    for _, arch in ipairs(refreshList) do
        local archName = arch.name
        gdebug('clear week arch: %s', archName)
        self:setSimpleArch(archName, 0, false, true)
        self.weekRefreshedTable[archName] = true
    end

end
--------------------------------------------------------------------------------------
function mt:loadUnixDay()
    local p = self.owner
    local pj = p.handle
    local storageName = INT_STORAGE.UNIX_DAY
    local oldUnixDay = code.loadServerInt(pj, storageName)
    if oldUnixDay then
        gdebug('oldUnixDay is: ' .. oldUnixDay)
    else
        gdebug('oldUnixDay is nil, set to 0')
        oldUnixDay = 0
    end

    local nowUnixDay = gm.gameUnixDay
    if nowUnixDay < -1 then
        msg.error(cst.ALL_PLAYERS, 'get nowUnixDay fail.')
        return
    end

    if oldUnixDay > nowUnixDay then
        code.saveServerInt(pj, storageName, nowUnixDay)
        return
    end

    if nowUnixDay <= oldUnixDay then
        gdebug('already the latest unixday')
        return
    end

    gdebug(str.format('update old unix day to new unix day: %d -> %d', oldUnixDay, nowUnixDay))
    code.saveServerInt(pj, storageName, nowUnixDay)

    self:refreshCurrentDay()

end
--------------------------------------------------------------------------------------
function mt:refreshCurrentDay()
    local p = self.owner
    local pj = p.handle

    print(str.format('玩家[%s]刷新每日存档', p:getName()))
    self.bRefreshedDayReward = true
    --------------------------------------------------------------------------------------
    -- 每日计数的存档
    local refreshList = reg:getPool('arch_day_clear_list')

    for _, arch in ipairs(refreshList) do
        local archName = arch.name
        gdebug('clear day arch: %s', archName)
        self:setSimpleArch(archName, 0, false, true)
        self.dayRefreshedTable[archName] = true
    end

    code.saveServerString(pj, BOOL_STORAGE.DAILY_QUEST, '')
    self.dayRefreshedTable[BOOL_STORAGE.DAILY_QUEST] = true

end
--------------------------------------------------------------------------------------
function mt:activateArch(archName, val)
    local p = self.player
    local pack = reg:getTableData('archData', archName)

    if pack.onActivate then
        xpcall(function()
            if val and type(val) == 'number' then
                archlog('player: %d activate achievement: %s, val: %d', p.id, archName, val)
            else
                archlog('player: %d activate achievement: %s', p.id, archName)
            end

            if not val and pack.bStackable then
                val = 0
            end

            pack.onActivate(p, val, pack)
        end, function(msg)
            print(msg, debug.traceback())
        end)
    end

end
--------------------------------------------------------------------------------------
function mt:setArchInvalid(archName)
    self.archValInvalidTable[archName] = true
end
--------------------------------------------------------------------------------------
function mt:modArchPower(val)
    self.archPower = self.archPower + val

    -- if self.player:isLocal() then
    --     GUI.FightPower:updateBoard(self.archPower)
    -- end
    return self.archPower
end
--------------------------------------------------------------------------------------
-- custom
--------------------------------------------------------------------------------------
function mt:calcChapter1lWinGameStar()
    if self.chapter1totalWinStar then
        self.chapter1totalWinStar = self.chapter1totalWinStar + 1
    else
        self.chapter1totalWinStar = 1
    end
end
--------------------------------------------------------------------------------------
function mt:calcChapter2lWinGameStar()
    if self.chapter2totalWinStar then
        self.chapter2totalWinStar = self.chapter2totalWinStar + 1
    else
        self.chapter2totalWinStar = 1
    end
end
--------------------------------------------------------------------------------------
function mt:calcChapter3lWinGameStar()
    if self.chapter3totalWinStar then
        self.chapter3totalWinStar = self.chapter3totalWinStar + 1
    else
        self.chapter3totalWinStar = 1
    end
end
--------------------------------------------------------------------------------------
function mt:calcChapter4lWinGameStar()
    if self.chapter4totalWinStar then
        self.chapter4totalWinStar = self.chapter4totalWinStar + 1
    else
        self.chapter4totalWinStar = 1
    end
end
--------------------------------------------------------------------------------------
function mt:getChapterWinGameStar(chapterId)
    local totalWinStar = self['chapter' .. chapterId .. 'totalWinStar']
    if not totalWinStar then
        return 0
    end

    return totalWinStar
end
--------------------------------------------------------------------------------------
function mt:getSimpleArchDayLeft(archName)
    local p = self.player
    local pack = reg:getTableData('archData', archName)
    if not pack then
        BJDebugMsg(str.format('玩家[%s]getSimpleArchDayLeft数值出现错误：%s', p:getName(), archName))
        return
    end

    local dayMaxStorage = pack.dayMaxStorage
    if not dayMaxStorage then
        return 99999
    end

    local dayCurrent = self:getSimpleArch(dayMaxStorage)
    local dayMax = pack.getDayMax(p)
    local maxMod = dayMax - dayCurrent

    return maxMod
end
--------------------------------------------------------------------------------------
function mt:getSimpleArchDayMax(archName)
    local p = self.player
    local pack = reg:getTableData('archData', archName)

    if not pack.getDayMax then
        return 99999
    end

    local dayMax = pack.getDayMax(p)
    return dayMax
end
--------------------------------------------------------------------------------------
function mt:getSimpleArchWeekMax(archName)
    local p = self.player
    local pack = reg:getTableData('archData', archName)

    if not pack.getWeekMax then
        return 99999
    end

    local weekMax = pack.getWeekMax(p)
    return weekMax
end


--------------------------------------------------------------------------------------
return mt
