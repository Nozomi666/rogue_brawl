local mt = {}
mt.__index = mt
BlessManager = mt
mt.blessOptionQueue = nil
mt.blessPointQueue = nil
mt.selectedRootBlessClassList = nil
mt.mixBlessClassList = nil
mt.extraBlessChanceWeightPool = nil
--------------------------------------------------------------------------------------
mt.blessLvWeightPool = {
    [1] = WeightPool:new({{1, 80}, {2, 15}, {3, 5}}),
    [2] = WeightPool:new({{1, 50}, {2, 35}, {3, 10}, {4, 5}}),
    [3] = WeightPool:new({{1, 20}, {2, 40}, {3, 25}, {4, 10}, {5, 5}}),
    [4] = WeightPool:new({{1, 20}, {2, 25}, {3, 30}, {4, 15}, {5, 10}}),
    [5] = WeightPool:new({{1, 10}, {2, 15}, {3, 35}, {4, 20}, {5, 15}}),

}
mt.blessLvChart = LevelChart:new({
    [1] = 0,
    [2] = 11,
    [3] = 26,
    [4] = 36,
    [5] = 46,
})
--------------------------------------------------------------------------------------
function mt:new(player)
    local p = player
    local pId = p.id

    -- init table
    local o = {}
    setmetatable(o, self)

    o.player = player
    o:init()
    return o
end
--------------------------------------------------------------------------------------
function mt:init()
    self.blessPointQueue = linked.create()
    self.blessOptionQueue = linked.create()
    self.selectedRootBlessClassList = {}
    self.selectedRootBlessClassHashTable = {}

    self.blessPointNum = 0
    self.blessClassWeightPool = WeightPool:new({{'bless_pool_support', 100}})
    self.mixBlessClassList = {BLESS_CLASS_ARROW, BLESS_CLASS_ARCANE, BLESS_CLASS_SUMMON}

    self.extraBlessChanceWeightPool = WeightPool:new()
end
--------------------------------------------------------------------------------------
function mt:addRandomRootBlessPoint()
    self:addBlessOption({'暴风雪', '苍狼之魂', '初级箭术'})
    self:addBlessPoint()
end
--------------------------------------------------------------------------------------
function mt:addBlessPoint(blessPower, optionKeys)
    local hero = self.player.hero
    if not blessPower then
        blessPower = hero:getBlessPower()
    end

    local blessPoint = {
        blessPower = blessPower,
        optionKeys = optionKeys or {},
    }

    self.blessPointNum = self.blessPointNum + 1
    self.blessPointQueue:add(blessPoint)

    if self.player:isLocal() then
        GUI.PickBlessBtn:updateBoard()
    end

end
--------------------------------------------------------------------------------------
function mt:addBlessOption(optionList)
    local options = {}
    for _, optionName in ipairs(optionList) do
        table.insert(options, optionName)
    end

    self.blessOptionQueue:add(options)
end
--------------------------------------------------------------------------------------
function mt:drawBless(keys)
    local player = self.player
    local hero = player.hero

    if not keys then
        keys = {}
    end
    if not keys.forceRefresh then
        if player.blessOptions then
            msg.notice(player, '请先完成上一个赐福的选择。')
            return
        end
    end

    local cost = 1

    if not keys.noCostPoint then
        if self.blessPointNum < cost then
            msg.notice(player, str.format('赐福点数不足（需要至少%d）。', cost))
            return
        end
    end

    player.blessOptions = {}

    local hasRareGetLv = false

    local blessOptionQueue = self.blessOptionQueue
    local quickQueue = blessOptionQueue:at(1)
    if quickQueue then
        -- 指定出赐福
        blessOptionQueue:remove(quickQueue)
        -- print('has queue')
        for _, blessName in ipairs(quickQueue) do
            local bless = fc.getAttr('skill_pack', blessName)
            table.insert(player.blessOptions, {
                bless = bless,
                getLv = self:generateBlessOptionLv(bless),
            })

        end

    else

        self:resetPoolCursor()
        -- 随机出赐福
        local bless

        local countAdd = 0

        local blessClassWeightPool = self.blessClassWeightPool
        for i = 1, 3 do

            local targetClass = blessClassWeightPool:rngSelect()
            local blessPower = hero:getBlessPower() * math.randomReal(0.8, 1.2)
            gdebug('blessPower: ' .. blessPower)
            local blessPowerLv = self.blessLvChart:getLvByGivenExp(blessPower)
            gdebug('blessPowerLv: ' .. blessPowerLv)
            local rareLv = self.blessLvWeightPool[blessPowerLv]:rngSelect()
            gdebug('rareLv: ' .. rareLv)

            if targetClass and self.player.banedCombo[targetClass] then
                targetClass = BLESS_CLASS_SUPPORT
                gdebug('player ban class on target, trigger override: ' .. cst:getConstName(targetClass))
            end

            if targetClass == BLESS_CLASS_OTHER then
                targetClass = fc.rngSelect(self.mixBlessClassList)
                gdebug('target blessClass is mix: ')
            end

            gdebug('getEntryNum is: ' .. self.extraBlessChanceWeightPool:getEntryNum())

            if self.extraBlessChanceWeightPool:getEntryNum() > 0 and math.random(100) <= 100 then
                targetClass = self.extraBlessChanceWeightPool:rngSelect()
                gdebug('target blessClass is extra: ' .. cst:getConstName(targetClass))
            end

            gdebug('target blessClass is: ' .. cst:getConstName(targetClass))
            local rareLv = 1
            local blessCands = self:getBlessCands(targetClass, rareLv, player.blessOptions)
            gdebug('blessCands num: ' .. #blessCands)

            if #blessCands == 0 then
                --  bless = fc.getAttr('skill_pack', [[极速武器]])
                blessCands = self:getBlessCands(BLESS_CLASS_SUPPORT, 1, player.blessOptions)
                bless = fc.rngSelect(blessCands)
                gdebug('bless is nil, use lv1 support bless: ' .. bless.name)
            else
                bless = fc.rngSelect(blessCands)
                gdebug('bless is: ' .. bless.name)
            end

            table.insert(player.blessOptions, {
                bless = bless,
            })
        end

        for i = 1, 3 do
            local blessOption = player.blessOptions[i]
            local getLv = self:generateBlessOptionLv(blessOption.bless)
            blessOption.getLv = getLv
            if getLv > 1 then
                hasRareGetLv = true
            end
        end

    end
    if not keys.noCostPoint then
        self.blessPointNum = self.blessPointNum - cost
    end

    -- if not hasRareGetLv then
    --     sound.playToPlayer(glo.gg_snd_pick_show_normal, player, 1, 0, true)
    -- else
    --     sound.playToPlayer(glo.gg_snd_pick_show_rare, player, 1, 0, true)
    -- end

    if self.player:isLocal() then
        GUI.PickBlessBtn:updateBoard()
        GUI.PickBlessPanel:updateBoard()
        GUI.PickBlessPanel:show()
    end
end
--------------------------------------------------------------------------------------
-- bless func
function mt:generateBlessOptionLv(bless, isRare)
    local rng = math.randomReal(0, 100)

    local doubleChance = BLESS_DOUBLE_CRIT_BASE_CHANCE
    local tripleChance = BLESS_TRIPLE_CRIT_BASE_CHANCE

    local player = self.player
    local hero = player.hero

    if isRare then
        doubleChance = doubleChance * 0.2
        tripleChance = tripleChance * 0.2
    end

    local getLv = 1

    if rng <= doubleChance then
        getLv = math.max(getLv, 2)
    end

    if rng <= tripleChance then
        getLv = math.max(getLv, 3)
    end

    local bodySkill = hero:getSkill(bless.name)
    if bodySkill then
        if bless.maxLv and bless.maxLv > 0 then
            getLv = math.min(bless.maxLv - bodySkill.lv, getLv)
        end
    end

    if bless.isRare then
        getLv = 1
    end

    -- gdebug('get lv is: ' .. getLv)

    return getLv
end
--------------------------------------------------------------------------------------
function mt:pickBless(btnId)

end
--------------------------------------------------------------------------------------
function mt:onHeroGetBless(blessName)
    local bless = fc.getAttr('skill_pack', blessName)
    if not bless then
        gdebug('onHeroGetBless: no bless found for name: ' .. blessName)
        return
    end

    if bless.isRootBless then
        if #self.selectedRootBlessClassList < 3 then
            table.insert(self.selectedRootBlessClassList, bless.blessClassProvide[1])
            table.removeTarget(self.mixBlessClassList, bless.blessClassProvide[1])
            self.selectedRootBlessClassHashTable[bless.blessClassProvide[1]] = true
            self:updateBlessWeightPool()
        else
            warn('onHeroGetBless: selected root bless class list is full（detect > 3).')
        end

    end

end
--------------------------------------------------------------------------------------
function mt:resetPoolCursor()
    for _, blessClass in ipairs(reg:getPool('bless_class')) do
        gdebug('reset bless class option cursor: ' .. cst:getConstName(blessClass))
        fc.setAttr('bless_class_option_cursor', blessClass, 0)
    end
end
--------------------------------------------------------------------------------------
function mt:updateBlessWeightPool()
    if #self.selectedRootBlessClassList == 0 then

    elseif #self.selectedRootBlessClassList == 1 then
        local weightPool = WeightPool:new()
        self.blessClassWeightPool = weightPool
        weightPool:addEntry(BLESS_CLASS_SUPPORT, 100)
        weightPool:addEntry(self.selectedRootBlessClassList[1], 100)
        weightPool:addEntry(BLESS_CLASS_OTHER, 50)
        gdebug('updateBlessWeightPool to root 1.')
    end
end
--------------------------------------------------------------------------------------
function mt:getRandomBlessByType()

end
--------------------------------------------------------------------------------------
function mt:getBlessCands(blessClass, rareLv, currentList)
    if not currentList then
        currentList = {}
    end
    local player = self.player
    local hero = player.hero
    local poolName = cst:getConstTag(blessClass, 'poolName') .. rareLv
    local pool = reg:getPool(poolName)
    local cands = {}
    for i, bless in ipairs(pool) do
        if bless.isRootBless then
            goto continue
        end

        if bless.maxLv and bless.maxLv > 0 then
            local currentBless = hero:getSkill(bless.name)
            if currentBless and currentBless.lv >= bless.maxLv then
                goto continue
            end
        end

        if bless.requireRootBless then
            if not self.selectedRootBlessClassHashTable[bless.blessClassProvide[1]] then
                gdebug('bless require root bless not selected: ' .. bless.name)
                goto continue
            end
        end

        cands[#cands + 1] = bless
        ::continue::
    end

    for i = #currentList, 1, -1 do
        local bless = currentList[i].bless
        table.removeTarget(cands, bless)
    end

    return cands
end
--------------------------------------------------------------------------------------
