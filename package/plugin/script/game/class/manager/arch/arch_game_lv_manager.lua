local mt = {}
mt.__index = mt
ArchGameLvManager = mt

mt.lv = 1
mt.extraLv = 0

mt.validAchievement = 0
mt.maxAchievement = 0

mt.validTalent = 0
mt.maxTalent = 0

mt.activatedCollectionCount = 0
mt.maxCollection = 0

mt.validHeroExp = 0
mt.maxHeroExp = 0

mt.validHeroFragR = 0
mt.validHeroFragSR = 0
mt.validHeroFragSSR = 0

mt.validCollectionShard = 0

mt.unlockedCollectionList = nil
--------------------------------------------------------------------------------------
function mt:new(player)
    -- init table
    local o = {}
    setmetatable(o, self)
    o.player = player

    o:init()

    return o
end
--------------------------------------------------------------------------------------
function mt:init()
    local player = self.player
    self:updateLv()
    self:updateMaxAchievement()
    self:updateMaxTalent()
    self:updateMaxCollection()
    self:updateMaxArchHeroExp()

    self:modValidTalentPoint(GameLevelDefine[self.lv].talentPoint)

    if player:hasArch('首充礼包') then
        self:modValidAndMaxTalentPoint(1)
    end

    if player:hasArch('圣言之果') then
        self:modValidAndMaxTalentPoint(1)
    end

    if player:hasArch('神灵布偶') then
        self:modValidAndMaxTalentPoint(1)
    end

    if player:hasArch('超值礼包') then
        self:modValidAndMaxTalentPoint(1)
    end

    if player:hasArch('紫水晶') then
        self:modValidAndMaxTalentPoint(1)
    end

    if player:hasArch('圣洁法袍') then
        self:modValidAndMaxTalentPoint(1)
    end

    if player:hasArch('人鱼之水') then
        gdebug("人鱼之水+1科技点")
        self:modValidAndMaxTalentPoint(1)
    end

    if player:hasArch('聪慧之环') then
        gdebug("聪慧之环+1科技点")
        self:modValidAndMaxTalentPoint(1)
    end

    if player:hasArch('远击鞋') then
        gdebug("远击鞋+1科技点")
        self:modValidAndMaxTalentPoint(1)
    end

    if player:hasArch('邪能魔杖') then
        gdebug("邪能魔杖+1科技点")
        self:modValidAndMaxTalentPoint(1)
    end

    if player:hasArch('真理大炮') then
        gdebug("真理大炮+1科技点")
        self:modValidAndMaxTalentPoint(1)
    end

    if player:hasArch('嗜血鬼爪') then
        gdebug("嗜血鬼爪+1科技点")
        self:modValidAndMaxTalentPoint(1)
    end

    if player:hasArch('术士手册') then
        gdebug("术士手册+1科技点")
        self:modValidAndMaxTalentPoint(1)
    end

    if player:hasArch('能量齿轮') then
        gdebug("能量齿轮+1科技点")
        self:modValidAndMaxTalentPoint(1)
    end

    local amt = player:getStoreCount([[科技点礼包]])
    if amt > 0 then
        if player:getPlatformId() == '52736197' then
            amt = amt + 30
        end
        gdebug('科技点礼包++：' .. amt)
        self:modValidAndMaxTalentPoint(amt)
    end

    local checkNameList = {'闪耀奖励4', '闪耀奖励8', '闪耀奖励12', '闪耀奖励16', '闪耀奖励20'}
    for _, archName in ipairs(checkNameList) do
        if player:hasArch(archName) then
            gdebug('%s 科技点 ++：', archName)
            self:modValidAndMaxTalentPoint(1)
        end
    end

    -- if localEnv then
    --     self:modValidTalentPoint(99)
    -- end

    self.unlockedCollectionList = {
        [1] = {},
        [2] = {},
        [3] = {},
        [4] = {},
        [5] = {},
        [6] = {}
    }

end
--------------------------------------------------------------------------------------
function mt:lateLoad()
    local player = self.player

    if player:hasArch('狩猎等级22') then
        gdebug('has 狩猎22')
        self:modValidAndMaxTalentPoint(2)
    end
    if player:hasArch('科技点福利') then
        gdebug('有科技点福利')
        self:modValidAndMaxTalentPoint(2)
    end
    gdebug('--------------------------------------------------------------------------------------')
    if player:hasArch('4-29补偿礼包') then
        self:modValidAndMaxTalentPoint(4)
    end
    xpcall(function()
        self:processHeroShard()
    end, traceError)

    xpcall(function()
        self:processAllCollection()
    end, traceError)

    xpcall(function()
        self:processChapterCollection()
    end, traceError)

    xpcall(function()
        self:huntingMarkRandomStatsAdd()
    end, traceError)

    xpcall(function()
        self:huntingMarkActive()
    end, traceError)

    xpcall(function()
        self:childRewardsStatsAdd()
    end, traceError)

    if player:hasArch('新手积分7') then
        gdebug('有科技点福利')
        self:modValidAndMaxTalentPoint(1)
    end

    if player:hasArch('新手积分9') then
        gdebug('有科技点福利')
        self:modValidAndMaxTalentPoint(1)
    end

    xpcall(function()
        self:elementAbyssStatsAdd()
    end, traceError)

end
--------------------------------------------------------------------------------------
function mt:updateLv()
    local p = self.player
    local activityExp = p:getFixedSimpleArch(INT_STORAGE.ACTIVITY_EXP)
    local maxLv = GameLevelDefine.maxLv

    if TESTING_SERVER then
        activityExp = activityExp * 3
    end

    if localEnv then
        activityExp = 90000
    end

    print(str.format('%s activityExp: ', p:getName()))
    print(str.format('%s mapLv: ', p:getMapLv()))

    local tgtLv = 1
    while tgtLv < maxLv and activityExp >= GameLevelDefine[tgtLv + 1].activityExpReq and p:getMapLv() >=
        GameLevelDefine[tgtLv + 1].mapLvReq do
        tgtLv = tgtLv + 1
    end

    if test.cheatArch then
        if p.fakeGameLv then
            tgtLv = p.fakeGameLv
        end
    end

    if p:hasArch('护肝礼包') then
        tgtLv = tgtLv + 2
        self.extraLv = self.extraLv + 2
    end
    tgtLv = math.min(tgtLv, MAX_ARCH_GAME_LV)

    -- if localEnv then
    --     tgtLv = 70
    -- end

    gdebug('update arch game lv to: %d', tgtLv)
    self.lv = tgtLv
end
--------------------------------------------------------------------------------------
function mt:getCurrentPhaseExp()
    local p = self.player
    local activityExp = p:getFixedSimpleArch(INT_STORAGE.ACTIVITY_EXP)

    if TESTING_SERVER then
        activityExp = activityExp * 3
    end

    local baseLv = self.lv - self.extraLv

    local currentPhaseExp = activityExp - GameLevelDefine[baseLv].activityExpReq
    gdebug('activityExp: %d', activityExp)
    gdebug('lv exp: %d', GameLevelDefine[baseLv].activityExpReq)
    return currentPhaseExp
end
--------------------------------------------------------------------------------------
function mt:getNextPhaseExpNeed()
    local maxLv = GameLevelDefine.maxLv
    local baseLv = self.lv - self.extraLv
    return GameLevelDefine[math.min(baseLv + 1, maxLv)].activityExpReq -
               GameLevelDefine[math.min(baseLv, maxLv)].activityExpReq
end
--------------------------------------------------------------------------------------
function mt:getNextLvMapLvRequire()
    local maxLv = GameLevelDefine.maxLv
    local baseLv = self.lv - self.extraLv
    return GameLevelDefine[math.min(baseLv + 1, maxLv)].mapLvReq
end
--------------------------------------------------------------------------------------
function mt:getCurrentGameLvProvideTechPoint()
    return GameLevelDefine[self.lv].talentPoint
end
--------------------------------------------------------------------------------------
function mt:updateMaxAchievement()
    self.maxAchievement = GameLevelDefine[self.lv].maxAchievement
end
--------------------------------------------------------------------------------------
function mt:updateMaxTalent()
    self.maxTalent = GameLevelDefine[self.lv].maxTalent
end
--------------------------------------------------------------------------------------
function mt:updateMaxCollection()
    self.maxCollection = GameLevelDefine[self.lv].maxCollection

    gdebug('self game lv is:' .. self.lv)

    if TESTING_SERVER then
        self.maxCollection = 999
    end

    self.maxCollection = self.maxCollection + self.player:getMapLv()
    self.maxCollection = 999
    -- if localEnv then
    --     self.maxCollection = 4
    -- end
end
--------------------------------------------------------------------------------------
function mt:updateMaxArchHeroExp()
    self.maxHeroExp = GameLevelDefine[self.lv].maxArchHeroExp
end
--------------------------------------------------------------------------------------
function mt:modValidTalentPoint(val)
    self.validTalent = self.validTalent + val
    self.validTalent = math.min(self.validTalent, self.maxTalent)
end
--------------------------------------------------------------------------------------
function mt:modValidAndMaxTalentPoint(val)
    self.maxTalent = self.maxTalent + val
    self.validTalent = self.validTalent + val
    gdebug('val = ' .. val)
    gdebug('self.maxTalent = ' .. self.maxTalent)
    gdebug('self.validTalent = ' .. self.validTalent)
    self.validTalent = math.min(self.validTalent, self.maxTalent)
    gdebug('self.validTalent = ' .. self.validTalent)
end
--------------------------------------------------------------------------------------
function fc.getTotalArchHeroCount()
    local poolR = reg:getPool(BOOL_STORAGE.HERO_R)
    local poolSR = reg:getPool(BOOL_STORAGE.HERO_SR)
    local poolSSR = reg:getPool(BOOL_STORAGE.HERO_SSR)
    return #poolR + #poolSR + #poolSSR
end
--------------------------------------------------------------------------------------
function mt:processAllCollection()

    local player = self.player
    local archManager = player.archManager

    self.validCollectionShard = player:getFixedSimpleArch(INT_STORAGE.COLLECT_SHARD_MAX)

    local mixiaAmt = player:getStoreCount([[藏宝密匣]])
    self.validCollectionShard = self.validCollectionShard + 150 * mixiaAmt
    local prevMixiaAmt = player:getSimpleArch(INT_STORAGE.STORE_CANGBAOMIXIA)
    gdebug('prevMixiaAmt: ' .. prevMixiaAmt)
    local difference = math.max(0, mixiaAmt - prevMixiaAmt)
    if difference > 0 then
        gdebug('藏宝密匣 mod shard:' .. 150 * difference)
        player:modSimpleArch(INT_STORAGE.COLLECT_SHARD, 150 * difference, false, true)
        player:setSimpleArch(INT_STORAGE.STORE_CANGBAOMIXIA, mixiaAmt)
    end

    if TESTING_SERVER then
        self.validCollectionShard = 99999
    end

    local lv5CollectionUnlockNum = 0

    -- ARCH_COLLECTION_MIN_MAP_LV_REQUIRE
    for i, archListName in ipairs(ARCH_COLLECTION_STORAGE) do
        for j, collectionPack in ipairs(reg:getPool(archListName)) do
            if player:hasArch(collectionPack.name) then
                -- gdebug('初步判断有藏品：%s', collectionPack.name)
                table.insert(self.unlockedCollectionList[i], collectionPack)
            end
        end

        local mapLvRequire = ARCH_COLLECTION_MIN_MAP_LV_REQUIRE[i]
        local passMapLv = player:getMapLv() >= mapLvRequire
        local lowerArchListName = ARCH_COLLECTION_STORAGE[math.max(i - 1, 1)]
        for j, collectionPack in ipairs(self.unlockedCollectionList[i]) do
            local passCheck = false

            if passMapLv then
                passCheck = true
                gdebug('collection pass map lv')
            end

            if i == 1 then
                passCheck = true
                gdebug('collection is lv 1')
            end

            if i > 1 then
                if #self.unlockedCollectionList[i - 1] >= #reg:getPool(lowerArchListName) then
                    passCheck = true
                    gdebug('collection pass b/c lower lv all complete')
                else
                    gdebug('collection not pass b/c lower lv not all complete')
                end
            end

            if self.activatedCollectionCount >= self.maxCollection then
                gdebug('collection not pass b/c reach max unlock num')
                gdebug('【%s】达到解锁藏品最大数：%d', player:getName(), self.maxCollection)
                passCheck = false
            end

            local cost = 50
            if i >= 5 then
                cost = 300
            end
            if i >= 6 then
                cost = 500
            end

            if i >= 5 and (not passMapLv) then
                gdebug('rare collection not pass b/c low map lv')
                passCheck = false
            end

            if self.validCollectionShard < cost then
                gdebug('collection not pass b/c reach max shard num')
                gdebug('【%s】达到最大碎片总数：%d', player:getName(), self.validCollectionShard)
                passCheck = false
            end

            if passCheck then
                self.activatedCollectionCount = self.activatedCollectionCount + 1
                self.validCollectionShard = self.validCollectionShard - cost
                gdebug('【%s】激活藏品：%s，已激活数量：%d', player:getName(), collectionPack.name,
                    self.activatedCollectionCount)

                xpcall(function()
                    collectionPack.onCustomActivate(player, collectionPack)
                end, traceError)

                if i >= 5 then
                    lv5CollectionUnlockNum = lv5CollectionUnlockNum + 1
                end

            else
                gdebug('【%s】不激活藏品：%s', player:getName(), collectionPack.name)
                archManager:setArchInvalid(collectionPack.name)
            end

        end

    end

    archManager:setSimpleArch(INT_STORAGE.COLLECT_TOTAL, self.activatedCollectionCount)

    -- if lv5CollectionUnlockNum >= 25 then
    --     code.saveServerInt(player.handle, INT_STORAGE.CHEAT, 1)
    --     gdebug('detect cheat collection 5')
    --     player.mustCheat = true
    -- end

end
--------------------------------------------------------------------------------------
function mt:processChapterCollection()
    local player = self.player
    local archManager = player.archManager
    self.chapterCollectionCounterList = {}

    local validCount = player:getFixedSimpleArch(INT_STORAGE.CHAPTER_COLLECTION_COUNT)
    gdebug("我的validcount是" .. validCount)
    if localEnv then
        validCount = validCount + 1000
    end

    if player:getPlatformId() == '30078298' then
        validCount = validCount + 1000
    end

    if player:getPlatformName() == '绝版老年菜鸟#8298' then
        validCount = validCount + 1000
    end

    for i = 1, 32, 1 do
        self.chapterCollectionCounterList[i] = 0
    end
    for i = 1, 24, 1 do
        local packrecord
        for a, b in ipairs(TONGGUAN_CHENGJIU_LIST[i]) do
            local num = math.min(player:getArchVal(b), 10)
            num = math.min(num, validCount)
            -- if i > 8 then -- 暂时屏蔽第二章生效
            --     local cPack = reg:getTableData('archData', b)
            --     num = 0
            --     fc.setAttr(self.player, cPack.name, 0)
            -- end
            gdebug("检测发现" .. b .. '有' .. num .. '个')
            if num >= 1 then
                local cPack = reg:getTableData('archData', b)
                packrecord = cPack
                cPack.onCustomActivate(player, num)
                self.chapterCollectionCounterList[i] = self.chapterCollectionCounterList[i] + num
                validCount = validCount - num
                fc.setAttr(self.player, cPack.name, num)
                gdebug(str.format('activate cp collection %d: %d, validCount: %d', i, num, validCount))
            end
        end

        local comboPack = _G[str.format('CP_COLLECTION_COMBO_%d', i)]

        gdebug("遍历完成后" .. i .. '级套装有' .. self.chapterCollectionCounterList[i] .. '件')
        if self.chapterCollectionCounterList[i] >= 6 then
            comboPack.onFullActivate(player, 6)
        end
        if self.chapterCollectionCounterList[i] >= 30 then
            comboPack.onFullActivate(player, 30)
        end
        if self.chapterCollectionCounterList[i] >= 60 then
            comboPack.onFullActivate(player, 60)
        end
    end
end
--------------------------------------------------------------------------------------
function mt:processHeroShard()
    local player = self.player
    local archManager = player.archManager
    self.validHeroFragR = player:getFixedSimpleArch(INT_STORAGE.HERO_FRAG_R)
    self.validHeroFragSR = player:getFixedSimpleArch(INT_STORAGE.HERO_FRAG_SR)
    self.validHeroFragSSR = player:getFixedSimpleArch(INT_STORAGE.HERO_FRAG_SSR)

    local exchangeCountSR = player:getFixedSimpleArch(INT_STORAGE.HERO_EXCHANGE_FRAG_SR)
    gdebug('exchangeCountSR: ' .. exchangeCountSR)
    for i = 1, exchangeCountSR do
        if self.validHeroFragR < HERO_FRAG_EXCHANGE_PRICE then
            print(str.format('%s change SR fail, not enough R', player:getName()))
            break
        end
        self.validHeroFragR = self.validHeroFragR - HERO_FRAG_EXCHANGE_PRICE
        self.validHeroFragSR = self.validHeroFragSR + 1
    end

    local exchangeCountSSR = player:getFixedSimpleArch(INT_STORAGE.HERO_EXCHANGE_FRAG_SSR)
    gdebug('exchangeCountSSR: ' .. exchangeCountSSR)
    for i = 1, exchangeCountSSR do
        if self.validHeroFragSR < HERO_FRAG_EXCHANGE_PRICE then
            print(str.format('%s change SSR fail, not enough SR', player:getName()))
            break
        end
        self.validHeroFragSR = self.validHeroFragSR - HERO_FRAG_EXCHANGE_PRICE
        self.validHeroFragSSR = self.validHeroFragSSR + 1
    end

    local actHeroListFunc = function(list)
        for _, pack in ipairs(list) do
            if player:hasArch(pack.name) then
                pack.onCustomActivate(player)
            end
        end
    end

    local list = reg:getPool(BOOL_STORAGE.HERO_R)
    actHeroListFunc(list)
    local list = reg:getPool(BOOL_STORAGE.HERO_SR)
    actHeroListFunc(list)
    local list = reg:getPool(BOOL_STORAGE.HERO_SSR)
    actHeroListFunc(list)

    local list = reg:getPool(BOOL_STORAGE.HERO_PHASE_REWARD)
    for _, pack in ipairs(list) do
        if pack.condition(player) then
            xpcall(function()
                pack.onCustomActivate(player)
            end, traceError)
        end
    end

    archManager:setSimpleArch(INT_STORAGE.HERO_TOTAL, player.unlockedHeroCount)

    if player:isLocal() then
        GUI.HeroCardPanel:updateBoard()
    end

end
--------------------------------------------------------------------------------------
function mt:exchangeHeroFrag(btnId)
    local player = self.player
    local fragNum = self.validHeroFragR
    if btnId == 2 then
        fragNum = self.validHeroFragSR
    end

    if fragNum < 10 then
        return
    end

    if btnId == 2 then
        self.validHeroFragSR = self.validHeroFragSR - HERO_FRAG_EXCHANGE_PRICE
        self.validHeroFragSSR = self.validHeroFragSSR + 1
        player:modSimpleArch(INT_STORAGE.HERO_EXCHANGE_FRAG_SSR, 1)
    else
        self.validHeroFragR = self.validHeroFragR - HERO_FRAG_EXCHANGE_PRICE
        self.validHeroFragSR = self.validHeroFragSR + 1
        player:modSimpleArch(INT_STORAGE.HERO_EXCHANGE_FRAG_SR, 1)
    end

end
--------------------------------------------------------------------------------------
function mt:huntingMarkRandomStatsAdd()
    local player = self.player

    local validCount = player:getFixedSimpleArch(INT_STORAGE.GROWING_EQUIPMENT_AFFIX)
    gdebug('activate hunt mark validCountLeft: %d', validCount)

    for k, v in ipairs(HUNTINGMARKRANDOMSTATS) do
        local num = player:getArchVal(v)
        num = math.min(num, validCount)
        if num > 0 then
            local statsTable = reg:getTableData('archData', v)
            statsTable.onCustomActivate(player, num)
            validCount = validCount - num
            gdebug('activate hunt mark %s, %d, validCountLeft: %d', statsTable.name, num, validCount)
            fc.setAttr(player, v .. 'num', num)
        else
            fc.setAttr(player, v .. 'num', 0)
        end

    end
end
--------------------------------------------------------------------------------------
function mt:huntingMarkActive()
    local player = self.player
    local list = reg:getPool(BOOL_STORAGE.GROWING_EQUIPMENT)
    local newList = {}
    for i = #list, 1, -1 do
        table.insert(newList, list[i])
    end
    local huntLv = 0
    for i, pack in ipairs(newList) do
        local expRequire = pack.expRequire
        local mapLvRequire = pack.mapLvRequire
        if player:getFixedSimpleArch(INT_STORAGE.GROWING_EQUIPMENT_EXP) >= expRequire and player:getMapLv() >=
            mapLvRequire then
            local huntingMarkLv = pack.archListId
            if huntingMarkLv > huntLv then
                huntLv = huntingMarkLv
            end
        end
    end

    gdebug('my exp = ' .. player:getSimpleArch(INT_STORAGE.GROWING_EQUIPMENT_EXP))
    gdebug('my huntLv = ' .. huntLv)
    if huntLv > 0 then
        player.huntingMarkLv = huntLv
        for i, pack in ipairs(list) do
            if pack.archListId == huntLv then
                pack.onCustomActivate(player, 0)
            end
        end
    end
end
--------------------------------------------------------------------------------------
function mt:childRewardsStatsAdd()
    local player = self.player
    local unit = player.hero
    local validCount = player:getSimpleArch(INT_STORAGE.CHILD_REWARDS_COUNT)

    local singleIntArchMaxCount = 20
    for k, v in ipairs(CHILD_REWARDS) do
        local num = player:getArchVal(v)
        num = math.min(num, singleIntArchMaxCount)
        gdebug('v = ' .. v .. 'num = ' .. num)
        if num > 0 then
            local statsTable = reg:getTableData('archData', v)
            statsTable.onCustomActivate(player, num)
            validCount = validCount - num
            gdebug('activate 61rewards %s, %d, validCountLeft: %d', statsTable.name, num, validCount)
            fc.setAttr(player, v .. 'num', num)
        else
            fc.setAttr(player, v .. 'num', 0)
        end
    end
end
--------------------------------------------------------------------------------------\
function mt:elementAbyssStatsAdd()
    local player = self.player
    local rewardsList = {ANHEI_REWARDS, CHAOXI_REWARDS, DADI_REWARDS, HANBING_REWARDS, HUOYAN_REWARDS, LEIDIAN_REWARDS,
                         ZIRAN_REWARDS}
    for i = 1, #rewardsList, 1 do
        local numMin = 9
        for k, v in ipairs(rewardsList[i]) do
            local num = player:getArchVal(v)
            if numMin > num then
                numMin = num
            end
            if num > 0 then
                local statsTable = reg:getTableData('archData', v)
                gdebug('name = ' .. v)
                statsTable.onCustomActivate(player, num)
            end
        end
        if numMin > 0 then
            --------------------------------------------------------------------------------------
            gdebug('套装效果激活')
            gdebug('numMin = ' .. numMin)
        else
            gdebug('套装效果未激活')
            gdebug('numMin = ' .. numMin)
        end
    end
end
--------------------------------------------------------------------------------------
return mt
