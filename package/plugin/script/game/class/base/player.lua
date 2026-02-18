require 'game.class.base.obj'
require 'game.class.manager.game_manager'
require 'game.class.base.pick_box'

local mt = {}
mt.__index = mt
setmetatable(mt, cg.BaseObj)
cg.BasePlayer = mt

local event = require 'game.__api.event'
-- local relicManager = require 'game.manager.relic_manager'
-- local deckManager = require 'game.manager.deck_manager'
-- local positionBuffManager = require 'game.manager.position_buff_manager'
-- local challengeManager = require 'game.manager.challenge_manager'
-- local archManager = require 'game.manager.arch_manager'
-- local collectionManager = require 'game.manager.collection_manager'
-- local guideManager = require 'game.manager.guide_manager'
local storeManager = require 'game.class.manager.arch.store_manager'

-- 通用 -----------------------------
mt.handle = 0
mt.id = 0
mt.flowTextHandle = nil

mt.eventList = nil -- init by mt:addEvent

-- 类型
mt.type = 'player'

-- 最后选择单位
mt.lastPick = nil
mt.statsIconCd = nil
mt.statsIconFreeze = nil
mt.maid = nil
mt.statsTable = nil

-- 漂浮文字
mt.flowtextOff = false
mt.effectOptmize = false
mt.closeAllEffect = false
mt.closeMusic = false
mt.badCredit = false

mt.autocastDelay = 5

mt.techDebt = 0
mt.extraTechPoint = 0

mt.maxDeck = 12

mt.skipRest = false
mt.pressedAlt = false

mt.cheatArch = false
mt.cheatEvidence = nil
mt.cheatObvious = nil

mt.baseNotDamaged = true

mt.activityDmg = 0
mt.activityDmgNeed = 5000000
mt.activityMooncake = 10
mt.dmgCalc = 0
mt.avatar = [[ReplaceableTextures\CommandButtons\BTNnvputouxiang.blp]]

-- 玩家列表
mt.pList = {}

-- 独特 -----------------------------
mt.enemies = nil

-- 选择框
mt.pickBox = nil

mt.relicManager = nil
mt.positionBuffManager = nil
mt.deckManager = nil
mt.challengeManager = nil
mt.archManager = nil
mt.collectionManager = nil
mt.guideManager = nil

-- 初始英雄点
mt.heroStartPoint = {}

-- 奖励点
mt.rewardPoint = nil
mt.equipPoint = nil

mt.dmgRecordPhy = 0
mt.dmgRecordMag = 0
mt.lastDmgRank = 0
mt.dmgRank = 0

mt.barPctLast = 0
mt.barPct = 0
mt.barGreenPctLast = 0
mt.barGreenPct = 0
mt.barBluePctLast = 0
mt.barBluePct = 0

mt.afkCount = 0

mt.alive = false

mt.shareItem = false
mt.archRewardList = nil

local colorId = {}
colorId[1] = '|cffff0000'
colorId[2] = '|cff0042ff'
colorId[3] = '|cff1ce6b9'
colorId[4] = '|cff8000ff'

--------------------------------------------------------------------------------------
function mt:new(id)

    local o = getmetatable(mt).new(self)

    gdebug('create new player, id: ' .. id)

    local o = {}
    setmetatable(o, self)

    local pJ = ConvertedPlayer(id)
    o.handle = pJ

    HandleRegTable(o.handle, o)
    o.id = id
    mt.pList[id] = o

    o.statsTable = {}

    o.rawName = GetPlayerName(ConvertedPlayer(id)) .. " "
    o.platformName = japi.RequestExtraStringData(81, o.handle, nil, nil, false, 0, 0, 0)
    if localEnv then
        o.platformName = 'WorldEdit'
    end
    print('set platform name to: ')
    print(o.platformName)

    local p = o

    -- init trig
    local trig = CreateTrigger()
    TriggerAddAction(trig, event.playerChat)
    TriggerRegisterPlayerChatEvent(trig, pJ, "", false)
    dbg.handle_ref(trig)

    local trig = CreateTrigger()
    TriggerAddAction(trig, event.playerPickUnit)
    TriggerRegisterPlayerSelectionEventBJ(trig, pJ, true)
    dbg.handle_ref(trig)

    -- init pickbox for player
    if o.id <= 4 then
        o.pickBox = PickBox:new(p)

        if p:isOnline() then
            -- 初始化商店
            -- local shopJ = glo.udg_skillShop[pId]
            -- p.skillShop = npc.skillShop:new(shopJ, pId)

            -- local shopJ = glo.udg_stoneTower[pId]
            -- p.stoneTower = npc.stoneTower:new(shopJ, pId)

            -- local shopJ = glo.udg_huntTower[pId]
            -- p.huntTower = npc.huntTower:new(shopJ, pId)

            -- local shopJ = glo.udg_blackShop[pId]
            -- p.blackShop = npc.blackShop:new(shopJ, pId)

            -- local shopJ = glo.udg_curseTower[pId]
            -- p.curseTower = npc.curseTower:new(shopJ, pId, p)

            -- local shopJ = glo.udg_royalReward[pId]
            -- p.royalReward = npc.royalReward:new(shopJ, pId, p)

            -- local shopJ = glo.udg_activityShop[pId]
            -- p.activityShop = npc.activityShop:new(shopJ, pId, p)

            -- local shopJ = glo.udg_techBuilding[pId]
            -- p.techBuilding = as.unit:uj2t(glo.udg_techBuilding[pId])
            -- p.techBuilding.uidanger = true

            -- p.relicManager = relicManager:new(p)
            -- p.positionBuffManager = positionBuffManager:new(p)
            -- p.deckManager = deckManager:new(p)
            -- p.challengeManager = challengeManager:new(p)
            -- p.archManager = archManager:new(p)
            -- p.collectionManager = collectionManager:new(p)
            -- p.guideManager = guideManager:new(p)
            p.storeManager = storeManager:new(p)

            p.alive = true

            if not gm.host then
                gm.host = p
            end

            gdebug('player online ' .. p.id)
        else
            if p:isBot() then
                gm.botNum = gm.botNum + 1
                gdebug('bot num: ' .. gm.botNum)
            end

        end

    end

    o.flowTextHandle = GetForceOfPlayer(pJ)
    dbg.handle_ref(o.flowTextHandle)

    o.archRewardList = {}

    return p
end
--------------------------------------------------------------------------------------
function mt:getPickBox()
    return self.pickBox
end
--------------------------------------------------------------------------------------
function mt:onGameStart()
    -- 选完难度游戏开始
    if not self:isOnline() then
        return
    end

    gdebug(str.format('player on game start: %s', self:getName()))

    if not (gm.diffSetting.less1_3) then
        SetPlayerTechResearchedSwap(ID('R00A'), 1, self.handle)
    end
    SetPlayerTechResearchedSwap(ID('R00B'), 1, self.handle)

    -- init archs
    self.deckManager:pickDeck(1)
    ui.customDeck.startPage(self)

    if self:isLocal() then
        ui.archBoard.panel.pageBtn[1]:on_button_clicked()
    end

    self.curseTower.expMax = gm.gameChapter.curseExpMax
    self.curseTower.roundGrowExp = gm.diffSetting.curseRoundGrowExp
    self.curseTower:setPool(reg:getPool(gm.gameChapter.cursePool))

    local keys = {
        p = self,
    }
    xpcall(function()
        self:triggerEvent(cst.PLAYER_EVENT_GAME_START, keys)
    end, function(msg)
        print(msg, debug.traceback())
    end)

    if gm.shareHp then
        self.maid:initTeamHp()
    end

    -- collection chance
    self.collectionManager:gameStart()

    self.guideManager:start()

    self.maid:updateHP()

    antiCheat.reviewCheatResult(self)

end
--------------------------------------------------------------------------------------
function mt:updateMapStatistics(eventKey, val)

    val = math.floor(val)
    local pj = self.handle

    print(str.format('[update map statistics] - player: %s,eventKey: %s, val: %d', self:getName(), eventKey, val))

    code.updateMapStatistics(pj, eventKey, val)

end
--------------------------------------------------------------------------------------
function mt:getPlayerById(pId)

    return mt.pList[pId]
end
--------------------------------------------------------------------------------------
function mt:pj2t(pj)
    return HandleGetTable(pj) or nil
end
--------------------------------------------------------------------------------------
function mt:getLocalPlayer()
    return mt:pj2t(GetLocalPlayer())
end
--------------------------------------------------------------------------------------
function fc.getLocalPlayer()
    return mt:getLocalPlayer()
end
--------------------------------------------------------------------------------------
function mt:isLocal()
    return self == mt:pj2t(GetLocalPlayer())
end
--------------------------------------------------------------------------------------
function mt:setLastPick(u)
    self.lastPick = u
end

--------------------------------------------------------------------------------------
function mt:getLastPick()
    return self.lastPick
end

--------------------------------------------------------------------------------------
function mt:switchFlowtext()
    self.flowtextOff = not self.flowtextOff
    as.message.notice(self, '漂浮文字已' .. (self.flowtextOff and '关闭' or '开启'))
end

--------------------------------------------------------------------------------------
-- 可见性检查
-- 位置的可见性
--	目标位置
function mt:is_visible(where)
    local x, y = where:get_point():get()
    return jass.IsVisibleToPlayer(x, y, self.handle)
end
--------------------------------------------------------------------------------------
function mt:onRoundStart()

end
--------------------------------------------------------------------------------------
function mt:onRoundEnd()

end
--------------------------------------------------------------------------------------
function mt:getRewardPoint()
    return self.rewardPoint
end
--------------------------------------------------------------------------------------
function mt:pickHero()
    local u = self.maid
    self:setAttribute('正在转职', true)
    u:tryPickHero()
end
--------------------------------------------------------------------------------------
function mt:isOnline()
    local pJ = self.handle
    return (GetPlayerSlotState(pJ) == PLAYER_SLOT_STATE_PLAYING) and (GetPlayerController(pJ) == MAP_CONTROL_USER)
end
--------------------------------------------------------------------------------------
function mt:isBot()
    local pJ = self.handle
    return (GetPlayerController(pJ) == MAP_CONTROL_COMPUTER)
end
--------------------------------------------------------------------------------------
function mt:isAlive()
    local pJ = self.handle
    return (GetPlayerSlotState(pJ) == PLAYER_SLOT_STATE_PLAYING) and (GetPlayerController(pJ) == MAP_CONTROL_USER) and
               self.alive
end
--------------------------------------------------------------------------------------
function mt:getName()
    return str.format('%s%s|r', colorId[self.id], GetPlayerName(self.handle))
end
--------------------------------------------------------------------------------------
function mt:getNameWithColon()
    return str.format('%s%s: |r', colorId[self.id], GetPlayerName(self.handle))
end
--------------------------------------------------------------------------------------
function mt:getUdgName()
    return str.format('%s%s|r', colorId[self.id], self.rawName)
end
--------------------------------------------------------------------------------------
function mt:getRawUdgName()
    return self.rawName
end
--------------------------------------------------------------------------------------
function mt:getPlatformName()
    return self.platformName
end
--------------------------------------------------------------------------------------
function mt:moveCamera(point, time)
    time = time or 0
    local pointJ = Location(point[1], point[2])
    dbg.handle_ref(pointJ)
    PanCameraToTimedLocForPlayer(self.handle, pointJ, time)
    RemoveLocation(pointJ)
    dbg.handle_unref(pointJ)
end
--------------------------------------------------------------------------------------
function mt:pressTilde()
    local p = self

    if not p.maid then
        return
    end

    SelectUnitForPlayerSingle(p.maid.handle, p.handle)

    if not p.tildeTimer then
        p.tildeTimer = ac.wait(ms(0.5), function()
            p.tildeTimer = nil
        end)
    else
        p:moveCamera(p.maid:getloc())
        p.tildeTimer:remove()
        p.tildeTimer = nil
    end
end
--------------------------------------------------------------------------------------
function mt:modArchVal(archName, val)
    self.archManager:modArchVal(archName, val, false)
end
--------------------------------------------------------------------------------------
function mt:modArchValNow(archName, val)
    self.archManager:modArchVal(archName, val, true)
end
--------------------------------------------------------------------------------------
function mt:setArchVal(archName, val)
    self.archManager:setArchVal(archName, val, false)
end
--------------------------------------------------------------------------------------
function mt:setArchValNow(archName, val)
    self.archManager:setArchVal(archName, val, true)
end
--------------------------------------------------------------------------------------
function mt:getArchVal(archName)
    return self.archManager:getArchVal(archName)
end
--------------------------------------------------------------------------------------
function mt:hasArch(archName)
    if not self.archManager then
        return
    end

    return self.archManager.archVal[archName] and (not self.archManager.archValInvalidTable[archName])
end
--------------------------------------------------------------------------------------
function mt:hasArchRegardlessInvalid(archName)
    return self.archManager.archVal[archName]
end
--------------------------------------------------------------------------------------
function mt:tryUnlockArch(archName)
    return self.archManager:tryUnlockArch(archName)
end
--------------------------------------------------------------------------------------
function mt:lockArch(archName)
    self.archManager:lockArch(archName)
end
--------------------------------------------------------------------------------------
function mt:forceUnlockArch(archName)
    self.archManager:forceUnlockArch(archName)
end
--------------------------------------------------------------------------------------
function mt:getRawMapLv()
    local mapLv = 0
    mapLv = code.getMapLv(self.handle)
    mapLv = math.max(mapLv, 1)

    return mapLv
end
--------------------------------------------------------------------------------------
function mt:getMapLv()
    local mapLv = 0
    if MAP_DEBUG_MODE then

        if self.fakeMapLv then
            mapLv = self.fakeMapLv
        else
            mapLv = 95
        end
    else
        mapLv = code.getMapLv(self.handle)

        if ANCHOR_PLAYER_LIST[self:getRawUdgName()] then
            mapLv = mapLv + 30
        end

        mapLv = math.max(mapLv, 1)
    end

    gdebug('有护肝礼包吗')
    if self:hasStoreItem('护肝礼包') then
        mapLv = mapLv + 2
        gdebug('有护肝礼包')
    end

    gdebug('有甜心翅膀吗')
    -- if self:hasStoreItem('甜心翅膀') then
    --     mapLv = mapLv + 1
    --     gdebug('有甜心翅膀')
    -- end

    if self:getSimpleArch(INT_STORAGE.ONLINE_TIME_520) >= 600 then
        mapLv = mapLv + 1
        gdebug('有甜心翅膀')
    end

    gdebug('有远古号角吗')
    if self:hasStoreItem('远古号角') then
        mapLv = mapLv + 1
        gdebug('有远古号角')
    end

    gdebug('有魔能石板吗')
    if self:hasStoreItem('魔能石板') then
        mapLv = mapLv + 1
        gdebug('有魔能石板')
    end

    gdebug('有粽叶吗')
    if self:hasStoreItem('粽叶') then
        gdebug('有粽叶')
        mapLv = mapLv + 5
    end

    if self:getPlatformName() == '蛋黄奶油包#8246' then
        mapLv = mapLv + 2
    end

    --[[if localEnv then
        mapLv = 1
    end]]

    return mapLv

end
--------------------------------------------------------------------------------------
function mt:getPlatformSign(mode)
    if localEnv then
        return 25
    end

    return code.getPlatformSign(self.handle, mode)
end
--------------------------------------------------------------------------------------
function mt:getPlatformId()
    return arch.getPlayerPlatformId(self.handle)
end
--------------------------------------------------------------------------------------
function mt:hasStoreItem(archName)
    local pack = reg:getTableData('archData', archName)

    if not pack then
        return false
    end

    return archFunc.checkStoreValid(self, pack)
end
--------------------------------------------------------------------------------------
function mt:resetAfkCount()
    self.afkCount = 0
end
--------------------------------------------------------------------------------------
function mt:kickedOut()
    msg.notice(cst.ALL_PLAYERS, str.format('%s 因挂机时间过久而被踢出游戏。', self:getName()))
    gm.gameLose(self, '太长时间没有操作了，游戏失败。')
    self.kicked = true

    if gm.shareHp then
        self.maid:updateTeamHpAfterKick()
    end

    local g = self.enemies
    local gCopy = {}

    for _, enemy in ipairs(g) do
        table.insert(gCopy, enemy)
    end

    for _, enemy in ipairs(gCopy) do
        enemy:kill()
    end

end
--------------------------------------------------------------------------------------
function mt:getStoreCount(archName)
    local pack = reg:getTableData('archData', archName)
    if not pack then
        return 0
    end

    return archFunc.getStoreCount(self, pack)
end
--------------------------------------------------------------------------------------
function mt:modSimpleArch(archName, val, delay, ignoreDayMaxStorage)
    return self.archManager:modSimpleArch(archName, val, delay, ignoreDayMaxStorage)
end
--------------------------------------------------------------------------------------
function mt:setSimpleArch(archName, val, delay)
    return self.archManager:setSimpleArch(archName, val, delay)
end
--------------------------------------------------------------------------------------
function mt:getFixedSimpleArch(archName)
    return self.archManager:getFixedSimpleArch(archName)
end
--------------------------------------------------------------------------------------
function mt:getSimpleArch(archName)
    return self.archManager:getSimpleArch(archName)
end
--------------------------------------------------------------------------------------
function mt:forcePickUnit(unit)
    SelectUnitForPlayerSingle(unit.handle, self.handle)
end
--------------------------------------------------------------------------------------
function mt:isNotEnemyPlayer()
    if self.id >= 1 and self.id <= 4 then
        return true
    end

    return false
end
--------------------------------------------------------------------------------------
function mt:leaveGame()
    self.alive = false

    table.removeTarget(gm.alivePlayerList, self)
end
--------------------------------------------------------------------------------------
function mt:isCheatInt()
    return code.loadServerInt(self.handle, INT_STORAGE.CHEAT2) > 0
end
--------------------------------------------------------------------------------------
function mt:isCheat()

    local detectCheat = false

    -- if self:getSimpleArch(INT_STORAGE.CHEAT) > 0 then
    --     detectCheat = true
    -- end

    -- if code.loadServerInt(self.handle, INT_STORAGE.CHEAT2) > 0 then
    --     detectCheat = true
    --     --gdebug('cheat 11111')
    -- else
    --     --gdebug('cheat 22222')
    -- end

    if self.mustCheat then
        detectCheat = true
    end

    if CHEAT_WHITE_LIST_PLAYER[self:getPlatformName()] then
        detectCheat = false
        gdebug('cheat white list player: ' .. self:getPlatformName())
    end

    return detectCheat
end
--------------------------------------------------------------------------------------
function mt:getSimpleArchDayLeft(archName)
    local val = self:getSimpleArch(archName)
    local pack = reg:getTableData('archData', archName)
    local dayMaxStorage = pack.dayMaxStorage
    local dayCurrent = self:getSimpleArch(dayMaxStorage)
    local dayMax = pack.getDayMax(self)
    local maxMod = dayMax - dayCurrent
    return maxMod
end
--------------------------------------------------------------------------------------
function mt:passRandomPassiveTest(baseChance)
    if baseChance <= 0 then
        return false
    end
    local actualChance = baseChance
    return math.randomPct() <= actualChance
end
--------------------------------------------------------------------------------------
function mt:failRandomPassiveTest(baseChance)
    return not (self:passRandomPassiveTest(baseChance))
end
--------------------------------------------------------------------------------------
-- name
-- art
-- tip
-- amt
-- stackable
function mt:recordArchReward(rewardInfo)
    local hasPrevious = false

    if rewardInfo.stackable then
        for _, enumRewardInfo in ipairs(self.archRewardList) do
            if enumRewardInfo.name == rewardInfo.name then
                hasPrevious = true
                enumRewardInfo.amt = enumRewardInfo.amt + rewardInfo.amt
                break
            end
        end
    end

    if hasPrevious then
        return
    end

    self.archRewardList[#self.archRewardList + 1] = rewardInfo

end
--------------------------------------------------------------------------------------
return mt
