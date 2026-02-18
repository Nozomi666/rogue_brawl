local mt = {}
RandomArch = mt

mt.cachedSeed = nil
--------------------------------------------------------------------------------------
function mt:cacheSeed()
    if self.cachedSeed then
        gdebug('Cache Seed Fail; already has: ' .. self.cachedSeed)
        return
    end
    self.cachedSeed = math.random(-2147483648, 2147483647)
    -- gdebug('Cache Seed Success: ' .. self.cachedSeed)
end
--------------------------------------------------------------------------------------
function mt:recoverSeed()
    if not self.cachedSeed then
        gdebug('Recover Cache Seed Fail; already nil')
        return
    end

    jass.SetRandomSeed(self.cachedSeed)
    self.cachedSeed = nil
end
--------------------------------------------------------------------------------------
function KKApiCheckBackendLogicExists(whichPlayer, key)
    if localEnv then
        local storageName = 'local_int_' .. key
        local val = code.loadServerInt(whichPlayer, storageName)
        -- gdebug('KKApiCheckBackendLogicExists: ' .. storageName .. ' ' .. val)
        return val ~= 0
    end

    return japi.RequestExtraBooleanData(84, whichPlayer, key, nil, false, 0, 0, 0)
end
--------------------------------------------------------------------------------------
function KKApiRequestBackendLogic(whichPlayer, key, groupkey)
    if localEnv then
        local storageName = 'local_int_' .. key
        local val = math.random(0, 2147483647)
        code.saveServerInt(whichPlayer, storageName, val)

        local storageName = 'local_group_' .. key
        code.saveServerString(whichPlayer, storageName, groupkey)
        return true
    end

    return japi.RequestExtraBooleanData(83, whichPlayer, key, groupkey, false, 0, 0, 0)
end
--------------------------------------------------------------------------------------
function KKApiGetBackendLogicIntResult(whichPlayer, key)

    if localEnv then
        local storageName = 'local_int_' .. key
        local val = code.loadServerInt(whichPlayer, storageName)
        return val
    end

    return japi.RequestExtraIntegerData(85, whichPlayer, key, nil, false, 0, 0, 0)
end
--------------------------------------------------------------------------------------
function KKApiGetBackendLogicUpdateTime(whichPlayer, key)
    return japi.RequestExtraIntegerData(87, whichPlayer, key, nil, false, 0, 0, 0)
end
--------------------------------------------------------------------------------------
function KKApiGetBackendLogicGroup(whichPlayer, key)
    if localEnv then
        local storageName = 'local_group_' .. key
        local val = code.loadServerString(whichPlayer, storageName)
        return val
    end

    return japi.RequestExtraStringData(88, whichPlayer, key, nil, false, 0, 0, 0)
end
--------------------------------------------------------------------------------------
function KKApiRemoveBackendLogicResult(whichPlayer, key)

    if localEnv then
        local storageName = 'local_int_' .. key
        code.saveServerInt(whichPlayer, storageName, 0)

        local storageName = 'local_group_' .. key
        code.saveServerString(whichPlayer, storageName, '')
        return true
    end

    return japi.RequestExtraBooleanData(89, whichPlayer, key, nil, false, 0, 0, 0)
end
--------------------------------------------------------------------------------------
function KKApiRandomSaveGameCount(whichPlayer, groupkey)
    return japi.RequestExtraIntegerData(101, whichPlayer, groupkey, nil, false, 0, 0, 0)
end
--------------------------------------------------------------------------------------
local function BackendLogicRemoveEvent()
    local eventPlayer = japi.DzGetTriggerSyncPlayer()
    local eventKey = japi.DzGetTriggerSyncData()
    local randomInt = KKApiGetBackendLogicIntResult(eventPlayer, eventKey)
    local timeStamp = KKApiGetBackendLogicUpdateTime(eventPlayer, eventKey)
    local groupKey = KKApiGetBackendLogicGroup(eventPlayer, eventKey)

    gdebug('Remove BackendLogicUpdateEvent' .. GetPlayerName(eventPlayer) .. ' eventKey: ' .. eventKey)
    -- gdebug('Remove BackendLogicUpdateEvent' .. GetPlayerName(eventPlayer) .. ' randomInt: ' .. randomInt)
    -- gdebug('Remove BackendLogicUpdateEvent' .. GetPlayerName(eventPlayer) .. ' groupKey: ' .. groupKey)
    -- gdebug('Remove BackendLogicUpdateEvent' .. GetPlayerName(eventPlayer) .. ' timeStamp: ' .. timeStamp)

    local player = as.player:pj2t(eventPlayer)
    -- player.archOutfitManager:receiveDecomposeEvent({
    --     archKey = eventKey,
    --     seed = randomInt,
    --     timeStamp = timeStamp,
    --     groupName = groupKey,
    -- })

end
--------------------------------------------------------------------------------------
local function BackendLogicRemoveEventLocal()
    local eventPlayer = japi.DzGetTriggerSyncPlayer()
    local eventKey = japi.DzGetTriggerSyncData()
    local storageName = 'local_int_' .. eventKey
    local randomInt = code.loadServerInt(eventPlayer, storageName)
    local storageName = 'local_group_' .. eventKey
    local groupKey = code.loadServerString(eventPlayer, storageName)
    local storageName = 'local_stamp_' .. eventKey
    local timeStamp = code.loadServerInt(eventPlayer, storageName)

    gdebug('Remove BackendLogicUpdateEvent' .. GetPlayerName(eventPlayer) .. ' eventKey: ' .. eventKey)
    gdebug('Remove BackendLogicUpdateEvent' .. GetPlayerName(eventPlayer) .. ' randomInt: ' .. randomInt)
    gdebug('Remove BackendLogicUpdateEvent' .. GetPlayerName(eventPlayer) .. ' groupKey: ' .. groupKey)
    gdebug('Remove BackendLogicUpdateEvent' .. GetPlayerName(eventPlayer) .. ' timeStamp: ' .. timeStamp)

    local player = as.player:pj2t(eventPlayer)
    local removeFunc = fc.getAttr(groupKey, 'removeEvent')
    if not removeFunc then
        warn('BackendLogicRemoveEventLocal: removeFunc not found: ' .. groupKey)
        return
    end

    removeFunc(nil, {
        player = player,
        archKey = eventKey,
        seed = randomInt,
        timeStamp = timeStamp,
        groupName = groupKey,
    })

end

--------------------------------------------------------------------------------------
local function BackendLogicUpdateEvent()
    local eventPlayer = japi.DzGetTriggerSyncPlayer()
    local eventKey = japi.DzGetTriggerSyncData()
    local randomInt = KKApiGetBackendLogicIntResult(eventPlayer, eventKey)
    local timeStamp = KKApiGetBackendLogicUpdateTime(eventPlayer, eventKey)
    local groupKey = KKApiGetBackendLogicGroup(eventPlayer, eventKey)

    gdebug('BackendLogicUpdateEvent' .. GetPlayerName(eventPlayer) .. ' eventKey: ' .. eventKey)
    gdebug('BackendLogicUpdateEvent' .. GetPlayerName(eventPlayer) .. ' randomInt: ' .. randomInt)
    gdebug('BackendLogicUpdateEvent' .. GetPlayerName(eventPlayer) .. ' groupKey: ' .. groupKey)
    gdebug('BackendLogicUpdateEvent' .. GetPlayerName(eventPlayer) .. ' timeStamp: ' .. timeStamp)

    local player = as.player:pj2t(eventPlayer)
    local createFunc = fc.getAttr(groupKey, 'createEvent')
    if not createFunc then
        warn('BackendLogicUpdateEventLocal: createFunc not found: ' .. groupKey)
        return
    end

    createFunc(nil, {
        player = player,
        archKey = eventKey,
        seed = randomInt,
        timeStamp = timeStamp,
        groupName = groupKey,
    })

end
--------------------------------------------------------------------------------------
local function BackendLogicUpdateEventLocal()
    local eventPlayer = japi.DzGetTriggerSyncPlayer()
    local eventKey = japi.DzGetTriggerSyncData()
    local storageName = 'local_int_' .. eventKey
    local randomInt = code.loadServerInt(eventPlayer, storageName)
    local storageName = 'local_group_' .. eventKey
    local groupKey = code.loadServerString(eventPlayer, storageName)
    local storageName = 'local_stamp_' .. eventKey
    local timeStamp = code.loadServerInt(eventPlayer, storageName)

    gdebug('BackendLogicUpdateEvent' .. GetPlayerName(eventPlayer) .. ' eventKey: ' .. eventKey)
    gdebug('BackendLogicUpdateEvent' .. GetPlayerName(eventPlayer) .. ' randomInt: ' .. randomInt)
    gdebug('BackendLogicUpdateEvent' .. GetPlayerName(eventPlayer) .. ' groupKey: ' .. groupKey)
    gdebug('BackendLogicUpdateEvent' .. GetPlayerName(eventPlayer) .. ' timeStamp: ' .. timeStamp)

    local player = as.player:pj2t(eventPlayer)

    local createFunc = fc.getAttr(groupKey, 'createEvent')
    if not createFunc then
        warn('BackendLogicUpdateEventLocal: createFunc not found: ' .. groupKey)
        return
    end

    createFunc(nil, {
        player = player,
        archKey = eventKey,
        seed = randomInt,
        timeStamp = timeStamp,
        groupName = groupKey,
    })

end
--------------------------------------------------------------------------------------
function GetLotteryUsedCount(whichPlayer)
    return japi.RequestExtraIntegerData(68, whichPlayer, nil, nil, false, 0, 0, 0) +
               japi.RequestExtraIntegerData(68, whichPlayer, nil, nil, false, 1, 0, 0) +
               japi.RequestExtraIntegerData(68, whichPlayer, nil, nil, false, 2, 0, 0)
end
--------------------------------------------------------------------------------------
local trig = CreateTrigger()
japi.DzTriggerRegisterSyncData(trig, "DZBLU", true)
jass.TriggerAddAction(trig, BackendLogicUpdateEvent)
dbg.handle_ref(trig)

local trig = CreateTrigger()
japi.DzTriggerRegisterSyncData(trig, "DZBLUL", false)
jass.TriggerAddAction(trig, BackendLogicUpdateEventLocal)
dbg.handle_ref(trig)
--------------------------------------------------------------------------------------
local trig = CreateTrigger()
japi.DzTriggerRegisterSyncData(trig, "DZBLD", true)
jass.TriggerAddAction(trig, BackendLogicRemoveEvent)
dbg.handle_ref(trig)

local trig = CreateTrigger()
japi.DzTriggerRegisterSyncData(trig, "DZBLDL", false)
jass.TriggerAddAction(trig, BackendLogicRemoveEventLocal)
dbg.handle_ref(trig)

--------------------------------------------------------------------------------------
return mt
