local mt = {}

local Unit = require 'game.class.unit'

mt.__index = mt
setmetatable(mt, Unit)

mt.parent = Unit

mt.lock = true

local equipPrice = {
    [4] = 8000,
    [5] = 24000,
    [6] = 72000,
    [7] = 210000,
}

local goldPrice = {
    [4] = 4000,
    [5] = 12000,
    [6] = 36000,
    [7] = 72000,
}

local coinInteract = {
    [1] = glo.gg_snd_CoinsInteract_1,
    [2] = glo.gg_snd_CoinsInteract_2,
}

local heavyInteract = {
    [1] = glo.gg_snd_CrystalPieceBreak1,
    [2] = glo.gg_snd_CrystalPieceBreak2,
    [3] = glo.gg_snd_CrystalPieceBreak3,
}

mt.poolNormal = nil
mt.poolFree = nil
mt.poolRare = nil

mt.equipTimer = -1

local waveLim = 20

--------------------------------------------------------------------------------------
function mt:new(uId, pId)

    -- init table
    local o = mt.parent:new(uId)
    setmetatable(o, self)

    o.skillBtn = {}
    o.sellList = {}

    o.coinCharge = 0

    -- 初始化按钮
    for i = 1, 12 do

        local function initAct(skill)
            -- mt:setOptionEmpty(skill)
            skill.btnId = i
            skill.callback = mt.onClick
        end

        local skillBtn = as.skill:new(o, 'BlackShop', pId .. '@' .. i, {}, 1, initAct)
        skillBtn.banCastEffect = true;
        o.skillBtn[i] = skillBtn

        if i ~= 4 and i ~= 8 then
            skillBtn:setCd(1)
        end

    end

    o.poolNormal = {}
    local pool = reg:getPool('blackShopPool')

    for _, pack in ipairs(pool) do
        table.insert(o.poolNormal, pack)
    end

    o.poolFree = {}
    local pool = reg:getPool('blackShopPoolFree')

    for _, pack in ipairs(pool) do
        table.insert(o.poolFree, pack)
    end

    o.poolRare = {}
    local pool = reg:getPool('blackShopPoolRare')

    for _, pack in ipairs(pool) do
        table.insert(o.poolRare, pack)
    end

    -- o:initPool()
    ac.wait(100, function()
        o:refreshSellList(true)
        o:refreshUI(-1)
    end)

    return o
end
--------------------------------------------------------------------------------------
function mt.confirmSell(keys)
    local item = keys.item
    local p = keys.p
    local maid = keys.maid
    local pack = item.pack
    local self = keys.shop

    if not UnitHasItem(maid.handle, item.itemJ) then
        msg.error(p, '上架失败；装备未被持有。')
        return
    end

    item:remove()
    local btnId = p.id + 8

    for i = 1, 4 do
        local ps = as.player:getPlayerById(i)
        if ps:isOnline() then
            ps.blackShop.sellList[btnId] = pack
            ps.blackShop:refreshUI(-1)
        end

    end

    msg.notice(cst.ALL_PLAYERS, str.format('%s 在黑店上架了 %s 。', p:getName(), pack.title))

end
--------------------------------------------------------------------------------------
function mt:onClick(keys)

    local self = keys.u
    local p = self.owner
    local skillBtn = keys.skill
    local btnId = skillBtn.btnId

    local price

    if self.lock then
        if btnId == 1 then
            price = 1
            if p:getResource(cst.RES_COIN) < price then
                msg.error(p, '神秘铸币不足。')
                return
            end

            p:modResource(cst.RES_COIN, price * -1)
            msg.notice(p, '黑市已解锁成功！')
            self.lock = false
            sound.playToPlayer(glo.gg_snd_unlock_black_shop, p, 1, 0, true)
            self:refreshUI(-1)

            -- special event
            if p:hasArch('复刻之术') then
                local coin = 2
                p:modResource(cst.RES_COIN, coin)
                msg.reward(p,
                    str.format(
                        '科技[%s复刻之术|r]效果触发，获得了 |cffffff00%d枚|r |cffcc99ff神秘铸币|r。',
                        cst.COLOR_TEAL, coin))
            end

        end
    else

        if btnId == 4 then
            price = 1
            if p:getResource(cst.RES_COIN) < price then
                msg.error(p, '神秘铸币不足。')
                return
            end

            p:modResource(cst.RES_COIN, price * -1)

            if p:hasArch('天赐法典') and math.randomPct() < 0.15 then
                p:modResource(cst.RES_COIN, 1)
                msg.arch(p,str.format('[%s天赐法典|r]效果触发，返还了一枚神秘铸币。', cst.COLOR_YELLOW))
            end

            self:refreshSellList()
        end

        if btnId < 4 then
            local pack = self.sellList[btnId]
            if not pack then
                return
            end
            price = pack.price
            if p:getResource(cst.RES_COIN) < price then
                msg.error(p, '神秘铸币不足。')
                return
            end

            p:modResource(cst.RES_COIN, price * -1)

            pack:onBuy(self)
            sound.playToPlayer(coinInteract[math.random(1, 2)], p, 1, 0, true)

            self.sellList[btnId] = nil
            self:refreshUI(-1)
        end

        if btnId >= 5 and btnId <= 8 and gm.wave < waveLim then
            return
        end

        if btnId >= 5 and btnId <= 7 then
            local pack = self.sellList[btnId]
            if not pack then
                return
            end
            local rarity = pack.rarity
            price = equipPrice[rarity]

            if p:getResource(cst.RES_GOLD) < price then
                msg.error(p, '金币不足。')
                return
            end

            p:modResource(cst.RES_GOLD, price * -1)
            sound.playToPlayer(heavyInteract[math.random(1, 3)], p, 1, 0, true)

            local itemType = pack.itemTypeJ
            fc.flyItem(nil, p, p.blackShop, p.rewardPoint, function()
                local args = {
                    name = pack.name,
                    point = p.rewardPoint,
                    owner = p,
                    shop = self,
                }
                local equip = as.equip:makeEquip(args)
            end)

            self.sellList[btnId] = nil
            self:refreshUI(-1)

        end

        if btnId == 8 then
            price = self:getLumRefreshPrice()
            if p:getResource(cst.RES_LUMBER) < price then
                msg.error(p, '木材不足。')
                return
            end

            p:modResource(cst.RES_LUMBER, price * -1)
            self:refreshLumList()
        end

        if btnId >= 9 then
            local sellId = btnId - 8
            local sellP = as.player:getPlayerById(sellId)
            local pack = self.sellList[btnId]
            if not pack then
                if sellP == p then
                    local box = p.pickBox
                    box:clean()
                    box:setTitle(str.format('选择要上架的装备'))
                    local maid = p.maid
                    for i = 1, 6 do
                        local item = maid:getItemBySlot(i)

                        if item and item.isEquip and item.pack.rarity >= 4 then
                            local itemName = item.pack.title
                            box:addBtn(itemName, mt.confirmSell, {
                                item = item,
                                p = p,
                                maid = maid,
                            }, cst.PICK_BOX_HOT_KEY.NULL)
                        end
                    end

                    box:addBtn('取消', nil, {
                        btnId = btnId,
                    }, KEY.ESC)
                else
                    return
                end
            else

                if sellP == p then
                    sound.playToPlayer(heavyInteract[math.random(1, 3)], p, 1, 0, true)
                    local itemType = pack.itemTypeJ
                    fc.flyItem(nil, p, p.blackShop, p.rewardPoint, function()
                        local args = {
                            name = pack.name,
                            point = p.rewardPoint,
                            owner = p,
                            shop = self,
                        }
                        local equip = as.equip:makeEquip(args)
                    end)

                    for i = 1, 4 do
                        local ps = as.player:getPlayerById(i)
                        if ps:isOnline() then
                            ps.blackShop.sellList[btnId] = nil
                            ps.blackShop:refreshUI(-1)
                        end

                    end
                else
                    local rarity = pack.rarity
                    price = goldPrice[rarity]
                    if p:getResource(cst.RES_GOLD) < price then
                        msg.error(p, '金币不足。')
                        return
                    end

                    p:modResource(cst.RES_GOLD, price * -1)
                    sellP:modResource(cst.RES_GOLD, price)

                    sound.playToPlayer(heavyInteract[math.random(1, 3)], p, 1, 0, true)
                    local itemType = pack.itemTypeJ
                    fc.flyItem(nil, p, p.blackShop, p.rewardPoint, function()
                        local args = {
                            name = pack.name,
                            point = p.rewardPoint,
                            owner = p,
                            shop = self,
                        }
                        local equip = as.equip:makeEquip(args)
                    end)

                    msg.notice(sellP, str.format('%s 购买了你的装备 %s ，你获得了|cffffff00%d|r金币。',
                        p:getName(), pack.title, price))

                    for i = 1, 4 do
                        local ps = as.player:getPlayerById(i)
                        if ps:isOnline() then
                            ps.blackShop.sellList[btnId] = nil
                            ps.blackShop:refreshUI(-1)
                        end

                    end

                end
            end
        end
    end

end
--------------------------------------------------------------------------------------
function mt:tick()
    if self.equipTimer < 0 then
        return
    end

    self.equipTimer = self.equipTimer - 1
    if self.equipTimer == 0 then
        self:refreshLumList()
    end

    self:refreshUI(8)
end
--------------------------------------------------------------------------------------
function mt:refreshSellList(mute)

    local p = self.owner
    for i = 1, 3 do
        local pool
        local rng = math.randomPct()
        if rng < 0.79 then
            pool = self.poolNormal
        elseif rng < 0.94 then
            pool = self.poolFree
        else
            pool = self.poolRare
        end

        local pack = fc.rngSelect(pool)
        self.sellList[i] = pack

        local skillBtn = self.skillBtn[i]
        as.skillManager:setInnerCd(skillBtn, 1)
    end

    if not mute then
        sound.playToPlayer(glo.gg_snd_CoinsRefresh, p, 1, 0, true)
    end

    self:refreshUI(-1)
end
--------------------------------------------------------------------------------------
function mt:refreshLumList()

    local p = self.owner
    for i = 5, 7 do
        local rarity = math.random(4, 7)
        local equipName = as.dataRegister:getRandomEquip(rarity)
        local pack = as.dataRegister.equipData[equipName]
        local itemName = pack.name
        local itemTypeJ = pack.itemTypeJ
        self.sellList[i] = pack

        if gm.wave >= 20 then
            local skillBtn = self.skillBtn[i]
            as.skillManager:setInnerCd(skillBtn, 1)
        end

    end
    sound.playToPlayer(glo.gg_snd_CoinsRefresh, p, 1, 0, true)
    self.equipTimer = 300

    self:refreshUI(-1)
end
--------------------------------------------------------------------------------------
function mt:refreshUI(slotId)

    if slotId == -1 then
        for i = 1, 12 do
            self:refreshUI(i)
        end
        return
    end

    local skillBtn = self.skillBtn[slotId]
    local title, tip, icon

    if self.lock then
        if slotId == 1 then
            title = '解锁黑市（|cffcc99ff1神秘铸币|r）'
            tip =
                '黑市中贩售着各种强力的道具，你需要神秘铸币来购买它们。|n|n|cffa6ff00第5波敌人必定掉落神秘铸币。你也可以通过其他途径获取铸币以提前解锁黑市。|r'
            icon = [[ReplaceableTextures\CommandButtons\BTNjiesuoheidiandaoju.blp]]
        else
            title = '未解锁'
            tip = '黑市未解锁'
            icon = [[ReplaceableTextures\CommandButtons\BTNheidianyichushou.blp]]
        end
    else
        if slotId < 4 then
            local sellName, sellTip, price
            local pack = self.sellList[slotId]
            if pack then
                sellName = pack.name
                price = pack.price
                tip = pack.tip
                icon = pack.icon
                title = str.format('购买|cffffff00%s|r（|cffcc99ff%d神秘铸币|r）', sellName, price)
            else
                title = '已售完'
                tip = '下回合刷新'
                icon = [[ReplaceableTextures\CommandButtons\BTNheidianyichushou.blp]]
            end

        end

        if slotId == 4 then
            title = '刷新货物（|cffcc99ff1神秘铸币|r）'
            tip = '立即刷新黑市中贩卖的铸币货物。'
            icon = [[ReplaceableTextures\CommandButtons\BTNshuaxin.blp]]
        end

        if slotId >= 5 and slotId <= 7 then
            local sellName, sellTip, price
            local pack = self.sellList[slotId]
            if pack then
                sellName = pack.name
                local rarity = pack.rarity
                price = equipPrice[rarity]
                local itemTypeJ = pack.itemTypeJ
                tip = pack.detail
                icon = pack.art
                title = str.format('购买%s（|cffffff00%d金币|r）', pack.title, price)
            else
                title = '已售完'
                tip = '等待下一次刷新'
                icon = [[ReplaceableTextures\CommandButtons\BTNheidianyichushou.blp]]
            end

        end

        if slotId == 8 then
            local price = self:getLumRefreshPrice()
            title = str.format('刷新货物（|cff16a32e%d木材|r）', price)
            tip = str.format('立即刷新黑市中贩卖的成品货物。|n|n|cffffcc00被动刷新倒计时：|r%d',
                self.equipTimer)
            icon = [[ReplaceableTextures\CommandButtons\BTNshuaxin.blp]]
        end

        if slotId >= 5 and slotId <= 8 and gm.wave < waveLim then
            title = '购买成品装备（即将到来）'
            tip = '20波后解锁。'
            icon = [[ReplaceableTextures\CommandButtons\BTNdaichushoumucaizhuangbei.blp]]
        end

        if slotId >= 9 then
            local sellId = slotId - 8
            local sellP = as.player:getPlayerById(sellId)
            local sellName, sellTip, price
            local pack = self.sellList[slotId]
            if pack then
                sellName = pack.name
                local rarity = pack.rarity
                price = goldPrice[rarity]
                local itemTypeJ = pack.itemTypeJ
                tip = pack.detail
                icon = pack.art
                if sellP == as.player:getLocalPlayer() then
                    title = str.format('下架%s', pack.title, price)
                    tip = str.format('取回这个装备。')
                else
                    title = str.format('购买%s（|cffffff00%d金币|r）', pack.title, price)
                end

            else
                if sellP == as.player:getLocalPlayer() then
                    title = '上架装备'
                    tip = str.format('左键点击出售女仆身上的装备给其他玩家。等级至少为B级。')
                    icon = [[ReplaceableTextures\CommandButtons\BTNshangjiazhuangbei.blp]]
                else
                    title = '无出售装备'
                    tip = str.format('%s 没有出售任何装备。', sellP:getName())

                    icon = [[ReplaceableTextures\CommandButtons\BTNwuchushouzhuangbei.blp]]
                end

            end

        end

    end

    tip = '|n' .. tip

    as.skill.setTitle(skillBtn, title)
    as.skill.setTip(skillBtn, tip)
    as.skill.setArt(skillBtn, icon)
    -- 刷新等级
    skillBtn.owner:setAbilityLevel(skillBtn.handle, 2)
    skillBtn.owner:setAbilityLevel(skillBtn.handle, 1)

end
--------------------------------------------------------------------------------------
function mt:addPackToPool(poolName, pack)
    local pool = self[poolName]
    if not pool then
        return
    end

    table.insert(pool, pack)
end
--------------------------------------------------------------------------------------
function mt:getLumRefreshPrice()
    local price = 50
    if self.owner:hasArch('天赐法典') then
        price = price * 0.6
    end
    price = math.floor(price)
    return price
end

--------------------------------------------------------------------------------------

return mt
