local util = require 'as.utility'
local Item = require 'game.class.base.item'

local mt = {}
mt.__index = mt
setmetatable(mt, Item)
Equip = mt
as.equip = mt

mt.enchantManager = nil
mt.isEquip = true
--------------------------------------------------------------------------------------
function mt:getData(name)

    local data = self[name]
    local val = data
    return val or 0
end
--------------------------------------------------------------------------------------
function mt:makeEquipTip(pack, hideRollText)

    local tip = ''
    local skillTip = pack.tip
    local statsNum = 0

    -- closure
    local convertRate = function(name)
        return mt.getData(pack, name)
    end

    -- closure
    local convertColor = function(name)
        return cst.COLOR_CODE[name]
    end

    if skillTip then
        -- set tip

        skillTip = string.gsub(skillTip, '%<([%w_.>]*)%>', convertColor)
        skillTip = string.gsub(skillTip, '%$([%w_]*)%$', convertRate)
        skillTip = string.gsub(skillTip, '%%([%w_.]*)%%', convertPct)
    else
        skillTip = ''
    end

    local color = '|cffffcc00'
    local hasBaseStats = false

    if pack.stats then
        for k, v in ipairs(pack.stats) do
            hasBaseStats = true
            local dataType = v[1]
            local keys = cst:getConstKeys(dataType)
            local name = keys.name or 'missing name'
            local showPct = false

            local val = v[2]
            local numPrefix = '+'

            if tonumber(val) < 0 then
                color = '|cffd01000'
                numPrefix = '-'
                val = math.abs(val)
            end

            local valStr = keys.isPct and convertPct(val) or val

            -- if keys.isPct then
            --     valStr = util:convertPct(val)
            -- else
            --     if val > 1 then
            --         valStr = val
            --     else
            --         valStr = str.format("%.1f", val)
            --     end
            -- end

            -- gdebug('create[%s],%s', cst:getConstName(dataType), valStr)

            -- if dataType == cst.ST_MP_REGEN then
            --     valStr = str.format('%.1f', val)
            --     showPct = true
            -- end

            if keys.isPct then
                showPct = true
            end

            if not showPct then
                if val >= 1 then
                    valStr = math.floor(valStr)
                    tip = tip ..
                              string.format('%s%s%s %d %s%s', statsNum == 0 and '' or '\n', numPrefix, color, valStr,
                            '|r', name)
                else
                    tip = tip ..
                              string.format('%s%s%s %.1f %s%s', statsNum == 0 and '' or '\n', numPrefix, color, valStr,
                            '|r', name)
                end

            else
                tip = tip ..
                          string.format('%s%s%s %s %s%s', statsNum == 0 and '' or '\n', numPrefix, color, valStr, '|r',
                        name)
            end

            statsNum = statsNum + 1
        end
    end

    if pack.tip ~= '' and pack.tip ~= nil then
        if hasBaseStats then
            tip = tip .. '\n\n' .. skillTip
        else
            tip = tip .. '\n' .. skillTip
        end

    end

    if pack.rare >= 6 and (not pack.isElementModeEquip) then
        if not hideRollText then
            local cost = EQUIP_RES_ROLL_COST_BY_RARE[pack.rare]
            local costTip = str.format(
                '|n|n|cff94e9de左键双击以重铸这个装备，消耗|r|cffffff77%d|cff94e9de枚重铸点数|r',
                cost)
            tip = tip .. costTip
        end
    end
    self.clickPoint = 0
    return tip, skillTip
end
--------------------------------------------------------------------------------------
--[[local keys = {
            u = u,
            itemJ = itemJ,
            itemTypeJ = itemTypeJ,
        }]]
--------------------------------------------------------------------------------------
function mt:heroGetEquip(keys)
    local u = keys.u
    local data = as.dataRegister.equipInfo[keys.itemTypeJ]
    local pack = as.dataRegister.equipData[data.name]
    local count = as.item:itemCountOnUnit(u, keys.itemTypeJ)
    gdebug('pack pickup: ' .. pack.name)
    self.clickPoint = 0
    -- 增加属性
    if keys.item.isElementModeEquip then
        gdebug('get isElementModeEquip?')
        for k, v in ipairs(keys.item.stats) do
            local statsType = v[1]
            local val = v[2]

            gdebug(str.format('mod type %s, val: %.0f', cst:getConstName(statsType), val))

            u:modStats(statsType, val)
        end
    else
        for k, v in ipairs(pack.stats) do
            local statsType = v[1]
            local val = v[2]

            u:modStats(statsType, val)
        end
    end

    gdebug('item count: ' .. count)

    -- 唯一事件
    if count == 1 and self:uniqueDeterMine(u, keys.itemTypeJ) then
        if pack.onSwitch then
            xpcall(function()
                pack.onSwitch(keys.item, true)
            end, function(msg)
                print(msg, debug.traceback())
            end)

            gdebug('item passive set on ')
            keys.item.passiveOn = true
        end
    end

    if pack.onMultiSwitch then
        pack.onMultiSwitch(keys.item, true)
    end

    -- 附魔
    local item = keys.item
    local enchantManager = item.enchantManager
    if enchantManager then
        enchantManager:setActive()
    end

    -- 携带顶级装备成就
    if pack.rare == 7 then
        if not u.rare7EquipHoldAmt then
            u.rare7EquipHoldAmt = 0
        end

        u.rare7EquipHoldAmt = u.rare7EquipHoldAmt + 1

        if u.rare7EquipHoldAmt >= 3 then
            u.player:tryUnlockArch('闪耀I')
        end

        if u.rare7EquipHoldAmt >= 6 then
            u.player:tryUnlockArch('闪耀II')
        end

    end

    if pack.rare == 8 then
        if not u.rare8EquipHoldAmt then
            u.rare8EquipHoldAmt = 0
        end

        u.rare8EquipHoldAmt = u.rare8EquipHoldAmt + 1

        if u.rare8EquipHoldAmt >= 3 then
            u.player:tryUnlockArch('闪耀III')
        end

        if u.rare8EquipHoldAmt >= 6 then
            u.player:tryUnlockArch('闪耀IV')
        end

    end

    local fpVal = GetFightPower('zb' .. pack.rare)
    u:modFp(fpVal)

end
--------------------------------------------------------------------------------------
function mt:heroEat(unit)
    local itemTypeJ = self.itemTypeJ

    self.eatBy = unit

    table.insert(unit.eatItemList, self)
    unit.player:tryUnlockArch('躯改计划')
    if #unit.eatItemList >= 3 then
        unit.player:tryUnlockArch('赛博人')
    end

    local fpVal = GetFightPower('zb' .. self.pack.rare)
    unit:modFp(fpVal)

    local count = as.item:itemCountOnUnit(unit, itemTypeJ)

    fc.setAttr(unit, self.name .. 'eat', self)

    -- 增加属性
    for k, v in ipairs(self.stats) do
        local statsType = v[1]
        local val = v[2]

        unit:modStats(statsType, val)
    end

    gdebug('eat ' .. self.name)
    if self:uniqueDeterMine(unit, itemTypeJ) then
        xpcall(function()
            self.onSwitch(self, true)
        end, function(msg)
            print(msg, debug.traceback())
        end)
        gdebug('item passive set on ')
        self.passiveOn = true
        unit[itemTypeJ] = true
        -- if self.onSwitch then
        --     xpcall(function()
        --         self.onSwitch(self, true)
        --     end, function(msg)
        --         print(msg, debug.traceback())
        --     end)

        --     gdebug('item passive set on ')
        --     self.passiveOn = true
        -- end
    else
        gdebug('item passive not set on ')
    end
    -- -- 唯一事件
    -- if count == 1 then
    --     if self.onSwitch then
    --         xpcall(function()
    --             self.onSwitch(self, true)
    --         end, function(msg)
    --             print(msg, debug.traceback())
    --         end)

    --         gdebug('item passive set on ')
    --         self.passiveOn = true
    --     end
    -- end

    if self.onMultiSwitch then
        self.onMultiSwitch(self, true)
    end

    -- 吞噬效果
    if self.onEat then
        xpcall(function()
            self:onEat()
        end, function(msg)
            print(msg, debug.traceback())
        end)
    end

    msg.notice(unit.player, '装备入体成功！')

end
--------------------------------------------------------------------------------------
function mt:getHolder()
    if self.eatBy then
        return self.eatBy
    end

    return self.holder
end
--------------------------------------------------------------------------------------
function mt:heroDropEquip(keys)
    local u = keys.u
    local data = as.dataRegister.equipInfo[keys.itemTypeJ]
    local pack = as.dataRegister.equipData[data.name]
    local count = as.item:itemCountOnUnit(u, keys.itemTypeJ)
    -- gdebug('pack drop: ' .. pack.name)

    if self.forceDropping then
        gdebug('force dropping equip')
        return
    end

    -- 增加属性
    if keys.item.isElementModeEquip then
        for k, v in ipairs(keys.item.stats) do
            local statsType = v[1]
            local val = v[2] * -1

            gdebug(str.format('mod type %s, val: %.0f', cst:getConstName(statsType), val))

            u:modStats(statsType, val)
        end

    else
        for k, v in ipairs(pack.stats) do
            local statsType = v[1]
            local val = v[2] * -1

            u:modStats(statsType, val)
        end
    end

    -- gdebug('item count: ' .. count )

    -- 唯一事件
    if count == 1 and self:uniqueDeterMine(u, keys.itemTypeJ) then
        if pack.onSwitch then
            xpcall(function()
                pack.onSwitch(keys.item, false)
            end, function(msg)
                print(msg, debug.traceback())
            end)

            keys.item.passiveOn = false
            -- gdebug('item passive set off')
        end
    else
        if keys.item.passiveOn then

            local other = as.item:otherSameItem(u, keys.item)
            if other then
                -- gdebug('item passive set swap ')
                xpcall(function()
                    pack.onSwitch(keys.item, false)
                    pack.onSwitch(other, true)
                end, function(msg)
                    print(msg, debug.traceback())
                end)

                if pack.onInherit then
                    pack.onInherit(nil, keys.item, other)
                end

                keys.item.passiveOn = false
                other.passiveOn = true
            else
                -- gdebug('item name: ' .. self.name)
                -- as.message.error(u.owner, 'error - can\'t find equip passive replacement')
            end
        end
    end

    if pack.onMultiSwitch then
        pack.onMultiSwitch(keys.item, false)
    end

    -- 携带SSS装备成就
    if pack.rare == 7 then
        if not u.rare7EquipHoldAmt then
            u.rare7EquipHoldAmt = 0
        end
        u.rare7EquipHoldAmt = u.rare7EquipHoldAmt - 1
    end
    if pack.rare == 8 then
        if not u.rare8EquipHoldAmt then
            u.rare8EquipHoldAmt = 0
        end
        u.rare8EquipHoldAmt = u.rare8EquipHoldAmt - 1
    end
    -- -- 附魔
    -- local item = keys.item
    -- local enchantManager = item.enchantManager
    -- if enchantManager then
    --     enchantManager:setDeactive()
    -- end

    local fpVal = GetFightPower('zb' .. pack.rare)
    u:modFp(fpVal * -1)

end

--------------------------------------------------------------------------------------
function mt:makeEquip(keys)
    local pack = as.dataRegister.equipData[keys.name]
    local name = keys.name
    if keys.isInit == true then

    end
    local itemTypeJ = pack.itemTypeJ
    keys.pluginOnBirth = function(eq)
        eq.isEquip = true
        eq.pack = as.dataRegister:getEquipByName(name)
        setmetatable(eq, eq.pack)
    end

    local equip = Item:makeItem(itemTypeJ, keys)

    if pack.rare >= 6 then
        local keys = {
            -- maxEnchant = 1,
            maxEnchant = pack.rare - 5,
        }
        pack.onUse = self.reforgeItem
        -- tip = tip .. '|n|n|cff94e9de左键点击以重铸这个装备|r'
        -- equip.enchantManager = EnchantManager:new(equip, keys)
    end
    return equip
end
--------------------------------------------------------------------------------------
function mt:createRandomEquip(point, rare, p, holder)
    local equipName = p:getRandomEquip(rare).name

    local args = {
        name = equipName,
        point = point,
        owner = p,
        holder = holder,
    }

    local equip = as.equip:makeEquip(args)
    return equip

end
--------------------------------------------------------------------------------------
function mt:getRarity()
    return self.pack.rare
end
--------------------------------------------------------------------------------------
function mt:getName()
    return self.pack.name
end
--------------------------------------------------------------------------------------
function mt:getNameWithRare()
    return self.pack.title
end
--------------------------------------------------------------------------------------
function mt:tryRefreshEnchant(p)
    if not self:testOwner(p) then
        msg.notice(p, '这件装备不属于你，无法附魔。')
        return
    end

    if not self.enchantManager then
        msg.notice(p, '这件装备无法附魔。')
        return
    end

    local enchantManager = self.enchantManager
    local price = enchantManager:getRefreshPrice()
    gdebug('refresh price is: ' .. price)

    if p:getResource(cst.RES_LUMBER) < price then
        msg.error(p, '木材不足。')
        return
    end

    enchantManager:refreshEnchant()
    p:modResource(cst.RES_LUMBER, price * -1)

    self:updateEnchantShow()

end
--------------------------------------------------------------------------------------
-- async
function mt:updateEnchantShow()
    local u = self:getHolder()
    if not u then
        return
    end
    local p = u.owner
    if not p:isLocal() then
        return
    end

    if not self.enchantManager then
        return
    end

    local enchantManager = self.enchantManager
    local title, tip = enchantManager:generateTitleTip()

    local shiftX_backdrop = uiHelper.screenWidthPercent(-0.275)
    local shiftY_backdrop = uiHelper.screenHeightPercent(-0.268)

    ui.tool.tooltip(class, title, tip)
    uiHelper:setFrameAnchor(toolbox, uiHelper.anchorPos.BOT_RIGHT, MAIN_UI, uiHelper.anchorPos.BOT_RIGHT,
        shiftX_backdrop, shiftY_backdrop)

end
--------------------------------------------------------------------------------------
function mt:tryEat(player)
    local unit = player.hero
    local name = self.name
    local hasEaten = fc.getAttr(unit, name .. 'eat')
    if hasEaten then
        msg.error(player, '已经吞噬过该装备了。')
        return -1
    end

    if not self.bCanEat then
        msg.error(player, '该装备不可吞噬')
        return -1
    end

    local count = as.item:itemCountOnUnit(player.hero, self.itemTypeJ) +
                      as.item:itemCountOnUnit(player.maid, self.itemTypeJ)

    if count > 1 then
        msg.error(player, '持有超过一件同名装备，请先脱下其中的一件再吞噬。')
        return -1
    end

    self:unbindHandle()

    self:heroEat(unit)
    return 1

end
--------------------------------------------------------------------------------------
function mt:uniqueDeterMine(unit, itemTypeJ)
    if not unit[itemTypeJ] then
        return true
    else
        return false
    end
end
--------------------------------------------------------------------------------------
function mt.reforgeItem()
    local uj = GetTriggerUnit()
    local itemJ = GetManipulatedItem()
    local itemTypeJ = GetItemTypeId(GetManipulatedItem())
    local item = as.item:j2t(itemJ)
    local unit = as.unit:uj2t(uj)

    if item.isElementModeEquip then
        return
    end

    gdebug('click reforge item');
    if not unit.clickReforgeOnce then
        unit.clickReforgeCountDown = ac.wait(ms(0.3), function()
            unit.clickReforgeOnce = false
        end)
        unit.clickReforgeOnce = true
        return
    else
        if unit.clickReforgeCountDown then
            unit.clickReforgeCountDown:remove()
            unit.clickReforgeOnce = false
        end
    end

    --------------------------------------------------------------------------------------
    local reforgePoint = unit.player:getStats(RES_ROLL)
    local cost = EQUIP_RES_ROLL_COST_BY_RARE[item.rare]
    if reforgePoint < cost then
        msg.error(unit.player, str.format('重铸点数不足。'))
        return
    end
    local pass = false
    if unit.linghunre and math.random(100) <= 7 then
        gdebug("灵魂提炼生效，不消耗重铸点数")
        pass = true
    end
    if unit.player:hasArch('工匠之锤') and math.random(100) <= 35 then
        msg.notice(unit.player, '工匠之锤特殊效果触发，本次重铸不消耗重铸点')
        pass = true
    end
    if not pass then
        unit.player:modStats(RES_ROLL, cost * -1)
    end
    --------------------------------------------------------------------------------------
    local rare = item.rare
    local position = item:getItemSoftId()
    item:unbindHandle()
    local player = unit.player
    local equipName = item.name
    local pack = player:getRandomEquip(rare)
    while item.name == equipName or pack.isElementModeEquip do
        pack = player:getRandomEquip(rare)
        equipName = pack.name
    end

    if item.name == '赐福火漆' and (not fc.getAttr(unit.player, '赐福火漆')) then
        fc.setAttr(unit.player, '赐福火漆', true)
        msg.notice(unit.player, '获得了|cffffff001|r个赐福点。')
        unit.player.hero:addBlessPoint()
    end

    if item.name == '纯宝密匣' and (not fc.getAttr(unit.player, '纯宝密匣')) then
        fc.setAttr(unit.player, '纯宝密匣', true)
        msg.notice(unit.player, '获得了|cffffff001|r个宝物点。')
        unit.player.hero:addRelicPoint({
            refresh = false,
        })
    end

    local args = {
        name = equipName,
        holder = unit,
        owner = player,
    }
    local word = FightPowerDefine['zb' .. rare].name
    msg.notice(unit.player, str.format('恭喜你获得了%s-%s%s', word, cst.EQUIP_RARE_COLOR[rare], equipName))
    local equip = as.equip:makeEquip(args)
end
--------------------------------------------------------------------------------------
function mt:createElementEquipStats(rank)
    local stats = {}
    local rareChangeToAugmentRate = cst.elementAbyssModeEquipStatsAugmentRateByRank[rank]
    rareChangeToAugmentRate = rareChangeToAugmentRate * 100
    for i = 1, rank, 1 do
        if math.random(100) < 70 then
            local statsPack = cst.baseStatsPool[math.random(#cst.baseStatsPool)]
            local num = math.random(100, rareChangeToAugmentRate)
            gdebug('num = ' .. num)
            local newStatsPack = {}
            newStatsPack[2] = statsPack[2] * (num / 100)
            newStatsPack[1] = statsPack[1]
            table.insert(stats, newStatsPack)
        else
            local statsPack = cst.rareStatsPool[math.random(#cst.rareStatsPool)]
            local num = math.random(100, rareChangeToAugmentRate)
            gdebug('num = ' .. num)
            local newStatsPack = {}
            newStatsPack[2] = statsPack[2] * (num / 100)
            newStatsPack[1] = statsPack[1]
            table.insert(stats, newStatsPack)
        end
    end
    for k, v in pairs(stats) do

    end

    for i, v in ipairs(cst.baseStatsPool) do
        local keys = cst:getConstKeys(v[1])
        local name = keys.name or 'missing name'
        local val = v[2]
        gdebug('name = ' .. name .. ', val = ' .. val)
    end

    return stats
end
--------------------------------------------------------------------------------------
function mt:makeElementAbyssModeEquip(keys)
    local pack = as.dataRegister.equipData[keys.name]
    local name = keys.name
    if keys.isInit == true then

    end
    local stats = self:createElementEquipStats(pack.rare)
    local itemTypeJ = pack.itemTypeJ
    keys.pluginOnBirth = function(eq)
        eq.isEquip = true
        eq.pack = as.dataRegister:getEquipByName(name)
        eq.stats = stats
        setmetatable(eq, eq.pack)
    end

    local equip = Item:makeItem(itemTypeJ, keys)
    equip.isElementModeEquip = true
    equip.isEquip = false

    return equip
end
--------------------------------------------------------------------------------------
function mt:getElementEqTip()

    local tip = ''
    local skillTip = ''
    local statsNum = 0
    local pack = self

    -- closure
    local convertRate = function(name)
        return mt.getData(pack, name)
    end

    -- closure
    local convertColor = function(name)
        return cst.COLOR_CODE[name]
    end

    -- closure
    local convertPct = function(name)
        local val = (tonumber(name) * 1)
        local formatted
        if (val % 1 < 0.01) then
            formatted = string.format("%.0f%%", (tonumber(name) * 1))
        else
            formatted = string.format("%.01f%%", (tonumber(name) * 1))
        end

        return formatted
    end

    if skillTip then
        -- set tip

        skillTip = string.gsub(skillTip, '%<([%w_.>]*)%>', convertColor)
        skillTip = string.gsub(skillTip, '%$([%w_]*)%$', convertRate)
        skillTip = string.gsub(skillTip, '%%([%w_.]*)%%', convertPct)
    else
        skillTip = ''
    end

    local color = '|cffffcc00'
    local hasBaseStats = false

    if pack.stats then
        for k, v in ipairs(pack.stats) do
            hasBaseStats = true
            local dataType = v[1]
            local keys = cst:getConstKeys(dataType)
            local name = keys.name or 'missing name'
            local showPct = false

            local val = v[2]
            local numPrefix = '+'

            if tonumber(val) < 0 then
                color = '|cffd01000'
                numPrefix = '-'
                val = math.abs(val)
            end

            local valStr = keys.isPct and convertPct(val) or val

            if keys.isPct then
                showPct = true
            end

            if not showPct then
                if val >= 1 then
                    valStr = math.floor(valStr)
                    tip = tip ..
                              string.format('%s%s%s %d %s%s', statsNum == 0 and '' or '\n', numPrefix, color, valStr,
                            '|r', name)
                else
                    tip = tip ..
                              string.format('%s%s%s %.1f %s%s', statsNum == 0 and '' or '\n', numPrefix, color, valStr,
                            '|r', name)
                end

            else
                tip = tip ..
                          string.format('%s%s%s %s %s%s', statsNum == 0 and '' or '\n', numPrefix, color, valStr, '|r',
                        name)
            end

            statsNum = statsNum + 1
        end
    end

    if pack.tip ~= '' and pack.tip ~= nil then
        if hasBaseStats then
            tip = tip .. '\n\n' .. skillTip
        else
            tip = tip .. '\n' .. skillTip
        end

    end

    self.clickPoint = 0
    return tip
end
--------------------------------------------------------------------------------------
-- async
function mt:getSkilltipInfo()
    local tip = self:makeEquipTip(self.pack, false, self.owner)

    return {
        icon = self.art,
        title = self.name,
        tip = tip,
    }
end
--------------------------------------------------------------------------------------
return mt
