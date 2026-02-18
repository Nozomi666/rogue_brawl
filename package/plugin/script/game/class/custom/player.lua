require('game.class.base.player')
require('game.class.base.weight_pool')
require('game.class.custom.shop')
require 'game.class.custom.challenge'
require 'game.class.manager.arch_manager'
require 'game.class.manager.bless_manager'
-- require('class.custom.stand_spot')

--------------------------------------------------------------------------------------
-- extend cg.BaseUnit
local mt = {}
mt.__index = mt
setmetatable(mt, cg.BasePlayer)
cg.Player = mt
as.player = mt
--------------------------------------------------------------------------------------
mt.homeBase = nil
mt.hero = nil
mt.shopBuyerMaid = false
mt.activateAchivementNum = 0
mt.bMainChallengeStart = false
mt.autoCast = true
mt.flowTextCount = 0
mt.totalGameDmg = 0
mt.baseArea = nil
--------------------------------------------------------------------------------------
-- hero card UI
mt.unlockedHeroCount = 0

-- 存档成就相关
mt.hasHeroDied = false
mt.currentTutorial = 0

mt.standSpotList = nil
--------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------
function mt:new(pId)
    -- init table
    local o = getmetatable(mt).new(self, pId)

    o.generalTalentList = {}
    o.standSpotList = {}

    return o
end
--------------------------------------------------------------------------------------
function mt:init()
    for i = 1, 15 do
        local pId = i
        local player = mt:new(pId)

        --    if i == 7 then
        --         cst.COMPUTER_ALLY_PLAYER = player
        --     end

        if i == 9 then
            cst.PLAYER_9 = player
        end

        if i == 12 then
            cst.NEUTRAL_AGGRESSIVE = player
        end

        if i == 15 then
            cst.NEUTRAL_PASSIVE = player
        end

        if i == 1 then
            self.enemyBornMinAngle = 45
            self.enemyBornMaxAngle = 225
        end

        if i == 1 then
            self.enemyBornMinAngle = 45
            self.enemyBornMaxAngle = 225
        end

    end

    for i = 1, 4 do
        local enemyId = i + 8
        local humanPlayer = as.player:getPlayerById(i)
        local enemyPlayer = as.player:getPlayerById(enemyId)
        humanPlayer.enemyPlayer = enemyPlayer

        humanPlayer.archManager = as.archManager:new(humanPlayer)
    end

end
--------------------------------------------------------------------------------------
function mt:enterGame()
    if not self:isOnline() then
        return
    end

    ac.loop(ms(1), function()
        self:onTick()
    end)

end
--------------------------------------------------------------------------------------
function mt:startGame()

    self.blessManager = BlessManager:new(self)
    local heroPack = fc.getAttr('hero_pack', '狂战士')
    self:pickHero({
        hero = heroPack,
        isLocked = false,
    })

    -- local bossPool = gm.chapter.bossPool
    -- fc.shuffleTable(bossPool)

    -- local list = {}
    -- for i = 1, 3, 1 do
    --     table.insert(list, bossPool[i])
    -- end

    -- self.playerBossList = list

    if self:hasArch('物品共享') then
        self.shareItem = true
    else
        self.shareItem = false
    end

    if self:hasArch('关闭自动施法') then
        self.autoCast = false
    else
        self.autoCast = true
    end

    if self:hasArch('关闭特效') then
        self.closeAllEffect = true
    else
        self.closeAllEffect = false
    end

    if self:hasArch('关闭文字') then
        self.flowtextOff = true
    else
        self.flowtextOff = false
    end

    if localEnv then
        self.flowtextOff = false
    end

    -- GUI.GameSettingPanel:update(self)

end
--------------------------------------------------------------------------------------
function mt:loadArchs()
    xpcall(function()
        self.archManager:init()
    end, function(msg)
        print(msg, debug.traceback())
    end)
    msg.notice(self, '存档加载完毕！')

end
--------------------------------------------------------------------------------------
function mt:awake()
    if not self:isOnline() then
        return
    end

    -- self.visitorPool = {
    --     [1] = {},
    --     [2] = {},
    --     [3] = {},
    -- }

    -- for _, playerPool in ipairs(self.visitorPool) do
    --     local generalPool = reg:getPool('visitor_pool_%d') -- str format
    --     for _, pack in ipairs(generalPool) do
    --         playerPool[#playerPool + 1] = pack
    --     end
    -- end

    self:modStats(RES_GOLD, 500)
    self:modStats(RES_LUMBER, 0)
    self:modStats(RES_KILL, 0)

    if localEnv then
        self:modStats(RES_GOLD, 500000)
        self:modStats(RES_LUMBER, 500)
        self:modStats(RES_KILL, 50000)
    end

    self:loadChallenge()

end
--------------------------------------------------------------------------------------
function mt:onSelectMapArea()

    self.heroBornPoint = gm.mapArea:getHeroBornPoint(self)
    self.cornerAreaCenter = gm.mapArea:getCornerAreaCenter(self)
    self.cornerAreaCorner = gm.mapArea:getCornerAreaCorner(self)
    self.oppositeCornerAreaCorner = gm.mapArea:getOppositeCornerAreaCorner(self)
    self.rewardPoint = gm.mapArea:getRewardPoint(self)
    self.maidBornPoint = gm.mapArea:getRewardPoint(self)
    self.rewardPointEquip = gm.mapArea:getRewardPointEquip(self)
    self.rewardPointBodyReform = gm.mapArea:getRewardPointBodyReform(self)

    self.baseArea = RectArea:newByCenter(gm.mapArea.base_center[self.id], 2000, 200)

    local pId = self.id

    -- self.honorShop = cg.Shop:new({
    --     name = '荣誉商店',
    --     player = self,
    --     point = gm.mapArea:getShopPosition({
    --         pId = self.id,
    --         shopId = 2,
    --     }),
    --     face = 0,
    -- })

end
--------------------------------------------------------------------------------------
function mt:loadChallenge()
    self.challengeList = {}
    self['challenge_list_normal'] = {}
    self['challenge_list_special'] = {}
    self['challenge_list_tower'] = {}
    self['challenge_list_skill'] = {}

    local challengeList = reg:getPool('challenge_list') or {}
    for i, challengePack in ipairs(challengeList) do
        local challenge = Challenge:new({
            challengePack = challengePack,
            player = self,
        })
        table.insert(self.challengeList, challenge)
        table.insert(self[str.format('challenge_list_%s', challenge.type)], challenge)
    end

end
--------------------------------------------------------------------------------------
function mt:pickHero(info)
    local pack

    local heroName = info.hero.name
    gdebug('player pick hero: ' .. heroName)
    pack = fc.getAttr('hero_pack', heroName)
    if not pack then
        warn('pick hero fail, no pack: ' .. heroName)
        return
    end

    -- if self:isLocal() then
    --     if not self:hasArch('加群礼包') then
    --         GUI.AddQQBtn:startLight()
    --         GUI.AddQQBtn2:show()
    --     end
    -- end

    if (not getmetatable(pack)) then
        setmetatable(pack, cg.Hero)
    end

    local uType = [[H000]]
    local point = self.heroBornPoint

    local heroJ = CreateUnit(self.handle, ID(uType), point[1], point[2], 0)
    local hero = cg.Hero:link(heroJ)
    setmetatable(hero, pack)
    self.hero = hero
    hero:init({
        player = self,
    })

    return hero
end
--------------------------------------------------------------------------------------
function mt:addEnemy(enemy, kv)
    local enemyList = self.enemyList
    enemyList[enemy] = kv
    return enemyList
end
--------------------------------------------------------------------------------------
function mt:removeEnemy(enemy)
    local enemyList = self.enemyList
    local kv = enemyList[enemy]
    enemyList[enemy] = nil
    return kv
end
--------------------------------------------------------------------------------------
function mt:onTick(gameTime)

end
--------------------------------------------------------------------------------------
function fc.getAlivePlayers()
    if gm.gameStarted then
        return gm.alivePlayerList
    end

    local g = {}
    for i = 1, 4 do
        local p = as.player:getPlayerById(i)
        if p:isAlive() then
            g[#g + 1] = p
        end
    end
    return g
end
--------------------------------------------------------------------------------------
function fc.getOnlinePlayers()
    local g = {}
    for i = 1, 4 do
        local p = as.player:getPlayerById(i)
        if p:isOnline() then
            g[#g + 1] = p
        end
    end
    return g
end
--------------------------------------------------------------------------------------
function mt:receiveShopItem(itemName)
    local receiver = self.hero
    if self.shopBuyerMaid then
        receiver = self.maid
    end
    return fc.createItemToUnit(itemName, receiver, self)
end
--------------------------------------------------------------------------------------
function mt:receiveRewardItem(itemName)
    msg.reward(self, str.format('获得了【%s】。', itemName))
    return fc.createItemToPoint(itemName, self.rewardPoint, self)
end
--------------------------------------------------------------------------------------
function mt:getRandomEnemyBornPoint()
    local pointCenter = gm.mapArea.enemy_born_point[self.id]

    local point = fc.polarPoint(pointCenter, math.random(-700, 700), 0)
    point = fc.polarPoint(point, math.random(-150, 150), 90)

    return point

end
--------------------------------------------------------------------------------------
function mt:tryStartChallenge(challengeName)
    local challengeList = self.challengeList

    gdebug('player tryStartChallenge %s', challengeName)
    local hasChallengeStarted = false

    for _, challenge in ipairs(challengeList) do
        if challenge.name == challengeName then
            challenge:onTryStart()
            hasChallengeStarted = true
        end
    end

    if not hasChallengeStarted then
        gdebug('player tryStartChallenge fail, no challenge: %s', challengeName)
    end
end
--------------------------------------------------------------------------------------
function mt:toggleChallenge(challengeName)
    local challenge = self:getChallenge(challengeName)
    return challenge:onToggleStart()
end
--------------------------------------------------------------------------------------
function mt:getChallenge(challengeName)
    local challengeList = self.challengeList
    for _, challenge in ipairs(challengeList) do
        if challenge.name == challengeName then
            return challenge
        end
    end
end
--------------------------------------------------------------------------------------
function mt:checkChallengeCondition(challengeName)
    local challenge = self:getChallenge(challengeName)
    -- if not challenge.checkCondition then
    --     return
    -- end

    return challenge:checkCondition()
end
--------------------------------------------------------------------------------------
function mt:getRandomEquip(rare)
    local goodPack

    while not goodPack do

        local equipName = as.dataRegister:getRandomEquip(rare)
        local pack = fc.getAttr('equip_pack', equipName)
        local failTest = false

        if pack.relatedCombo then
            gdebug('pack has relatedCombo' .. #pack.relatedCombo)
            for i, combo in ipairs(pack.relatedCombo) do
                gdebug('pack has relatedCombo %s', cst:getConstName(combo))
                if self:isBannedCombo(combo) then
                    failTest = true
                    gdebug('get rng item failed: %s', cst:getConstName(combo))
                end
            end
        end

        if pack.notInPool then
            gdebug('get rng item not in pool: %s', equipName)
            failTest = true
        end

        if not failTest then
            goodPack = pack
        end
    end

    return goodPack
end
--------------------------------------------------------------------------------------
function mt:getShopBuyer()
    if self.shopBuyerMaid then
        return self.maid
    else
        return self.hero
    end
end
--------------------------------------------------------------------------------------
function mt:completeTutorial(tutorialId, isFinal)
    if not self.tutorialSkipList then
        self.tutorialSkipList = {}
    end

    self.tutorialSkipList[tutorialId] = true

    if self.currentTutorial ~= tutorialId then
        return
    end

    repeat
        self.currentTutorial = self.currentTutorial + 1
    until not self.tutorialSkipList[self.currentTutorial]

    if self.currentTutorial ~= 2 and self.currentTutorial ~= 4 and self.currentTutorial ~= 5 then
        if self:isLocal() then
            GUI.Tutorial:showTutorial(self.currentTutorial)
        end
    else
        if self:isLocal() then
            GUI.Tutorial:hideTutorial()
        end
    end

end

--------------------------------------------------------------------------------------
function mt:onPlatformIdLoaded()
    if #fc.getAlivePlayers() >= 2 then
        self:tryUnlockArch('开黑')

        local hasOtherLowerGameLvPlayer = false
        for i, otherPlayer in ipairs(fc.getAlivePlayers()) do
            if otherPlayer ~= self and otherPlayer:getGameLevel() < self:getGameLevel() then
                hasOtherLowerGameLvPlayer = true
            end
        end

        if hasOtherLowerGameLvPlayer then
            self:tryUnlockArch('带新')
        end

    end
end
--------------------------------------------------------------------------------------
function mt:onKillBoss(isFinalBoss, bossLv)
    -- 存档计数

end
--------------------------------------------------------------------------------------
function mt:onGameWin()

    local stName = str.format('PASS_%d_%d', gm.chapter.id, EnemyManager.diffNum)
    self:updateMapStatistics(stName, 1)

end
--------------------------------------------------------------------------------------
function mt:onGameLose()

end
--------------------------------------------------------------------------------------
function mt:onCompleteEndless()

end
--------------------------------------------------------------------------------------
function mt:getGameLevel()
    if not self.archGameLvManager then
        print(str.format('获取玩家【%s】游戏等级失败，无archGameLvManager', self:getName()))
        return 0
    end

    return self.archGameLvManager.lv

end
--------------------------------------------------------------------------------------
function mt:leaveGame()
    local base = getmetatable(mt)
    base.leaveGame(self)

    if self.hero then
        self.hero:hide()
    end

    if self.maid then
        self.maid:pause()
        self.maid:hide()
    end

    self:closeAllChallenge()
    self:clearAllEnemies()
    gm:setloseBufferTime()
end
--------------------------------------------------------------------------------------
function mt:clearAllEnemies()
    EnemyManager:clearPlayerAllEnemies(self)
end
--------------------------------------------------------------------------------------
function mt:closeAllChallenge()

end
--------------------------------------------------------------------------------------
function mt:getGameLv()
    if not self.archGameLvManager then
        return 1
    end

    return self.archGameLvManager.lv
end
--------------------------------------------------------------------------------------
function mt:setArchInvalid(archName)
    if not self.archManager then
        error('setArchInvalid fail, not arch manager ')
        return
    end

    return self.archManager:setArchInvalid(archName)
end
--------------------------------------------------------------------------------------
function mt:getTotalGameDmg()
    return self.totalGameDmg
end
--------------------------------------------------------------------------------------
function mt:addGold(amt, showPoint, isFix)
    if not isFix then
        amt = amt * math.max((1 + self:getStats(PST_GOLD_RATE)), 0.01)
    end

    if gm.startedEndless then
        amt = amt * 0.2
    end

    self:modStats(RES_GOLD, amt)

    self:triggerEvent(PLAYER_EVENT_ON_GET_GOLD, {})

    if showPoint and amt > 0 then
        showPoint = fc.polarPoint(showPoint, 100, 225)
        as.flowText.printGold(showPoint, amt)
    end

    local hero = self.hero
    if hero then
        hero:triggerEvent(UNIT_EVENT_ON_GET_GOLD, {
            unit = hero,
            amt = amt,
        })
    end

end
--------------------------------------------------------------------------------------
function mt:addLumber(amt, showPoint, isFix)
    if not isFix then
        amt = amt * math.max((1 + self:getStats(PST_LUMBER_RATE)), 0.01)
    end

    if gm.startedEndless then
        amt = amt * 0.2
    end

    amt = math.floor(amt)

    if showPoint and amt > 0 then
        if showPoint and amt > 0 then
            showPoint = fc.polarPoint(showPoint, 200, 270)
            as.flowText.printCrystal(showPoint, amt)

        end

    end

    local hero = self.hero
    if hero then
        hero:triggerEvent(UNIT_EVENT_ON_GET_LUMBER, {
            unit = hero,
            amt = amt,
        })
    end

end
--------------------------------------------------------------------------------------
function mt:addKill(amt, showPoint, isFix)
    if not isFix then
        amt = amt * math.max((1 + self:getStats(PST_KILL_RATE)), 0.01)
    end

    if gm.startedEndless then
        amt = amt * 0.2
    end

    if showPoint and amt > 0 then
        as.flowText.makeClassicFlowText({
            text = str.format('|cffff0080+%d 杀敌|r', math.floor(amt)),
            point = showPoint,
            size = 10,
            speed = 90,
            angle = math.random(250, 270),
            fadeTime = 1,
            time = 2,
        })
    end

    local hero = self.hero
    if hero then
        hero:triggerEvent(UNIT_EVENT_ON_GET_KILL, {
            unit = hero,
            amt = amt,
        })
    end

    GUI.multiUsePanel:updateKill(self, amt)
end
--------------------------------------------------------------------------------------
-- 是否最高战力玩家
function mt:isHighestFP()
    local highestFP = self.hero.fp
    for i, otherPlayer in ipairs(fc.getAlivePlayers()) do
        if otherPlayer.hero.fp > highestFP then
            return false
        end
    end
    return true
end
--------------------------------------------------------------------------------------
mt:init()
--------------------------------------------------------------------------------------
return mt
