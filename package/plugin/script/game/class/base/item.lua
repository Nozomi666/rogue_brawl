local mt = {}
mt.__index = mt
as.item = mt

mt.type = 'item'

mt.holder = nil
mt.owner = nil
mt.itemJ = nil
mt.itemTypeJ = nil
mt.pack = nil
mt.removed = false
mt.inventorySlot = -1

mt.objIdCount = 0
mt.objId = 0
mt.objTable = {}

mt.dropPos = ac.point:new(0, 0)

mt.stackable = nil

--------------------------------------------------------------------------------------
function mt:makeItem(itemTypeJ, keys)
    local x, y = 0, 0
    local itemJ = nil
    if keys.point then
        x, y = keys.point[1], keys.point[2]
    end

    itemJ = CreateItem(itemTypeJ, x, y)
    local item = mt:new(itemJ, keys)

    if not itemJ then
        return nil
    end

    if item.autoStack then
        item:tryAutoStack()
    end

    return item
end
--------------------------------------------------------------------------------------
function fc.createItemToPoint(itemName, point, player)
    local itemType = reg:getItemType(itemName)

    return mt:makeItem(itemType, {
        point = point,
        owner = player,
        itemName = itemName,
    })
end
--------------------------------------------------------------------------------------
function fc.createItemToUnit(itemName, unit, player)
    local itemType = reg:getItemType(itemName)

    return mt:makeItem(itemType, {
        holder = unit,
        owner = player,
        itemName = itemName,
    })
end
--------------------------------------------------------------------------------------
function mt:getArt()
    if self.art then
        return self.art
    end

    return fc.getItemSlkData(self.name, 'Art')
end
--------------------------------------------------------------------------------------
function mt:new(itemJ, keys)
    if not itemJ then
        return nil
    end

    if itemJ == 0 then
        return nil

    end

    if not keys then
        keys = {}
    end

    local itemName = GetItemName(itemJ)
    if keys.itemName then
        itemName = keys.itemName
    end
    self.name = itemName
    -- gdebug("init new item table for " .. itemName)

    -- init table
    local o = {}
    setmetatable(o, self)
    HandleRegTable(itemJ, o)

    dbg.gchash(o, itemJ)
    o.gchash = itemJ

    o.itemJ = itemJ
    o.itemTypeJ = GetItemTypeId(itemJ)
    o.name = itemName

    gm:trackNewObject(o)

    local pack = as.dataRegister:getItemPack(itemName)
    o.pack = pack or nil

    if o.pack then
        setmetatable(o, o.pack)
        -- gdebug('o has pack')
    else
        -- gdebug('o has no pack')

    end
    -- 

    mt.objIdCount = mt.objIdCount + 1
    o.objId = mt.objIdCount
    mt.objTable[o.objId] = o

    o.stackable = GetItemCharges(o.itemJ) ~= 0

    if o.onCreate then
        xpcall(function()
            o:onCreate()
        end, traceError)
    end

    o:updateDropPos()

    if keys then
        o.owner = keys.owner or nil

        if keys.pluginOnBirth then
            keys.pluginOnBirth(o)
        end

        if keys.holder then
            o:move(keys.holder:getloc())
            o:updateDropPosImmediate()
            UnitAddItem(keys.holder.handle, itemJ)
            o.owner = keys.holder.owner
        end

    end

    return o
end
--------------------------------------------------------------------------------------
function mt:updateDropPosImmediate()
    local x = GetItemX(self.itemJ)
    local y = GetItemY(self.itemJ)

    local point = ac.point:new(x, y)

    self.dropPos = point
end
--------------------------------------------------------------------------------------
function mt:updateDropPos()
    ac.wait(2, function()
        local x = GetItemX(self.itemJ)
        local y = GetItemY(self.itemJ)

        local point = ac.point:new(x, y)

        -- local throwInOther = false
        -- if self.owner then
        --     for i = 1, 4 do
        --         local rect = glo.udg_battleGround[i]
        --         if point:inRect(rect) and self.owner ~= as.player:getPlayerById(i) then
        --             throwInOther = true
        --         end
        --     end
        -- end

        -- if throwInOther then
        --     msg.error(self.owner, '你不可以把物品丢到其他玩家的作战区域。')
        --     point = self.owner.rewardPoint
        --     self:move(point)
        -- end

        self.dropPos = point
    end)

end
--------------------------------------------------------------------------------------
function mt:getItemSoftId()
    if not self.holder then
        return -1
    end

    for i = 1, 6 do
        if UnitItemInSlotBJ(self.holder.handle, i) == self.itemJ then
            -- gdebug('getItemSoftId to: ' .. i)
            return i
        end
    end

    return -1
end
--------------------------------------------------------------------------------------
function mt:setUpdateSlot()
    self.inventorySlot = self:getItemSoftId()

end
--------------------------------------------------------------------------------------
function mt:checkQuickPass()
    local lastSlot = self.inventorySlot
    local u = self.holder
    local p = u.owner

    gdebug('checkQuickPass')

    self:updateAllSoftId()
    -- self.inventorySlot = self:getItemSoftId()

    if lastSlot == self.inventorySlot then

        p:setAttribute('PASS_ITEM', self)
        gdebug('trigger quick pass')

        if u.type == 'hero' then
            self:tryGiveTo(p.maid)
        elseif u.type == 'maid' then
            self:tryGiveTo(p.hero)
        end

    end
end
--------------------------------------------------------------------------------------
function mt:tryForceGiveTo(tgt)
    UnitAddItem(tgt.handle, self.itemJ)
    return true
end
--------------------------------------------------------------------------------------
function mt:tryGiveTo(tgt)

    if tgt:getEmptyItemSlotNum() > 0 then
        UnitAddItem(tgt.handle, self.itemJ)
        return true
    else
        msg.error(tgt.owner, '传递目标物品栏已满。')
    end

    return false
end
--------------------------------------------------------------------------------------
function mt:getUnitSlotItem(unit, slotId)
    local ij = UnitItemInSlotBJ(unit.handle, slotId)
    -- gdebug('updateall: ' .. ij)
    if ij ~= 0 then
        local item = mt:j2t(ij)
        return item

    end
    return nil
end
--------------------------------------------------------------------------------------
function mt:updateAllSoftId()
    for i = 1, 6 do
        local ij = UnitItemInSlotBJ(self.holder.handle, i)
        -- gdebug('updateall: ' .. ij)
        if ij ~= 0 then
            local item = mt:j2t(ij)
            item:setUpdateSlot()
        end
    end
end
--------------------------------------------------------------------------------------
function mt:testOwner(p)

    if not self.owner then
        return true
    end

    if not self.cantShare then
        if self.tempOwner == p then
            return true
        else
            if self.owner ~= p then
                return self.owner.shareItem
            else
                return true
            end
        end

    end

    if p.type ~= 'player' then
        return false
    end

    -- gdebug(self.owner:getName())
    -- gdebug(p:getName())

    return self.owner == p
end

--------------------------------------------------------------------------------------
function mt:j2t(itemJ)
    if itemJ == 0 then
        return nil
    end
    if not HandleGetTable(itemJ) then
        print('------------------create weird item------------------')
        print(GetItemName(itemJ))
        traceError()
    end

    return HandleGetTable(itemJ) or mt:new(itemJ)
end
--------------------------------------------------------------------------------------
function mt:getSlkData(keyWord)
    return slk.item[self.itemTypeJ][keyWord]
end
--------------------------------------------------------------------------------------
function fc.getItemSlkData(itemName, keyWord)
    local itemTypeJ = ID(reg:getItemPack(itemName).id)
    return slk.item[itemTypeJ][keyWord]
end

--------------------------------------------------------------------------------------
function mt:setHolder(u)
    self.holder = u
end

--------------------------------------------------------------------------------------
function mt:removeHolder(u)
    self.holder = nil
end
--------------------------------------------------------------------------------------
function mt:move(point)
    local x, y = point[1], point[2]
    SetItemPosition(self.itemJ, x, y)
end

--------------------------------------------------------------------------------------
function mt:getName()
    return self.name
end

--------------------------------------------------------------------------------------
function mt:getHolder()
    return self.holder
end

--------------------------------------------------------------------------------------
function mt:getItemInRange(point, r)
    local area = YDWEGetRect(point[1], point[2], r * 2, r * 2)
    dbg.handle_ref(area)
    local list = {}

    local act = function()
        local itemJ = GetEnumItem()
        local x = GetItemX(itemJ)
        local y = GetItemY(itemJ)
        local itemPoint = ac.point:new(x, y)

        if GetItemLifeBJ(itemJ) > 0 and point * itemPoint <= r then
            table.insert(list, itemJ)
        end
    end

    EnumItemsInRectBJ(area, act)
    RemoveRect(area)
    dbg.handle_unref(area)

    return list
end

--------------------------------------------------------------------------------------
function mt:otherSameItem(u, item)

    local uJ = u.handle
    local itemJ = item.itemJ
    local itemTypeJ = item.itemTypeJ

    for i = 1, 6 do
        local otherJ = UnitItemInSlotBJ(uJ, i)
        if GetItemTypeId(otherJ) == itemTypeJ and mt:j2t(otherJ) ~= item then
            gdebug('find other same')
            return mt:j2t(otherJ)
        end
    end

    return nil
end
--------------------------------------------------------------------------------------
function mt:itemCountOnUnit(u, itemTypeJ)

    local uJ = u.handle
    local counter = 0

    for i = 1, 6 do
        if GetItemTypeId(UnitItemInSlotBJ(uJ, i)) == itemTypeJ then
            counter = counter + 1
        end
    end

    return counter
end
--------------------------------------------------------------------------------------
function mt:getCharges()
    return GetItemCharges(self.itemJ)
end
--------------------------------------------------------------------------------------
function mt:delete()
    gm:untrackObject(self)
    self.removed = true
    SetItemPosition(self.itemJ, 0, 0)
    RemoveItem(self.itemJ)
    HandleRemoveTable(self.itemJ)
    self.itemJ = nil

end
--------------------------------------------------------------------------------------
function mt:unbindHandle()
    SetItemPosition(self.itemJ, 0, 0)
    RemoveItem(self.itemJ)
    HandleRemoveTable(self.itemJ)
    self.itemJ = nil
end
--------------------------------------------------------------------------------------
function mt:remove()
    self:delete()
end
--------------------------------------------------------------------------------------
function mt:onUse(u)
    -- gdebug('item use')
    if not self.pack then
        -- gdebug('item use no pack')
        return
    end

    local result = 0

    if self.pack.useEffect then
        result = self.pack.useEffect(self, u)
    else
        result = -1
    end

    if result and result ~= -1 then
        if not self.stackable then
            self:modUses(-1)
        else
            if GetItemCharges(self.itemJ) == 0 then
                self:remove()
            end
        end

    else
        if self.stackable then
            self:modUses(1)
        end
    end

end
--------------------------------------------------------------------------------------
function mt:onPickUp(u)
    -- gdebug('item on pick up')
    if self.pack then
        local act = self.pack.effectPickUp
        if act then
            act(self, u)
        end
    end

    if self.stackable and self.name ~= 'BOSS宝箱1' and self.name ~= 'BOSS宝箱2' and self.name ~= 'BOSS宝箱3' then
        local groundItemlist = as.item:getItemInRange(self:getloc(), 500)

        for k, itemJ in ipairs(groundItemlist) do
            local otherItem = as.item:j2t(itemJ)
            if otherItem.name == self.name then
                SetItemCharges(self.itemJ, GetItemCharges(otherItem.itemJ) + GetItemCharges(self.itemJ))
                otherItem:remove()
            end
        end

        local other = mt:otherSameItem(u, self)
        if other then
            SetItemCharges(other.itemJ, GetItemCharges(other.itemJ) + GetItemCharges(self.itemJ))
            self:remove()
        end

    end

end
--------------------------------------------------------------------------------------
function mt:onDrop(u)

    if self.pack then
        local act = self.pack.effectDrop
        if act then
            act(self, u)
        end
    end

    self:removeHolder(u)
    self:setUpdateSlot()
    self:updateDropPos()

    -- ac.wait(ms(0.01), function ()
    --     if (u.player and u.player:isLocal()) then
    --         GUI.GroundItemInfo:hide()
    --     end
    -- end)

    if (u.player and u.player:isLocal()) then
        GUI.GroundItemInfo:hide()
    end

end
--------------------------------------------------------------------------------------
function mt:moveToInventory(fromId, toId)
    if not self.holder then
        return false
    end

    local unit = self.holder
    local toIdHasItem = unit:getItemBySlot(toId)

    if toIdHasItem then
        if toIdHasItem.undragable then
            return false
        end

        toIdHasItem:forceDrop(unit:getloc())
    end
    self:forceDrop(unit:getloc())

    local tempStuffList = {}
    for i = 1, 6 do
        if i == fromId then
            if toIdHasItem then
                toIdHasItem:tryGiveTo(unit)
            else
                local otherItem = unit:getItemBySlot(i)
                if not otherItem then
                    local banSlot = fc.createItemToUnit('上锁的格子', unit, unit.player)
                    table.insert(tempStuffList, banSlot)
                end
            end
        elseif i == toId then
            self:tryGiveTo(unit)
        else
            local otherItem = unit:getItemBySlot(i)
            if not otherItem then
                local banSlot = fc.createItemToUnit('上锁的格子', unit, unit.player)
                table.insert(tempStuffList, banSlot)
            end
        end
    end

    for i, item in ipairs(tempStuffList) do
        item:remove()
    end

end
--------------------------------------------------------------------------------------
function mt:forceDrop(dropPos)

    dropPos = dropPos or self.dropPos

    if slk.item[self.itemTypeJ]['powerup'] == '1' then
        gdebug('force drop power up')

        -- make a copy
        local itemTypeJ = self.itemTypeJ

        local keys = {
            point = self.dropPos,
            owner = self.owner,
        }

        self:remove()

        local pack = self.pack
        local newItem = mt:makeItem(itemTypeJ, keys)

        if pack.onInherit then
            local oldItem = self
            pack.onInherit(nil, oldItem, newItem)
        end

        return
    end

    self.forceDropping = true
    self:move(dropPos)
    self.forceDropping = false

end
--------------------------------------------------------------------------------------
function mt:modUses(amount)
    -- gdebug('mod use: ' .. amount)
    if amount < 0 and not self.stackable then
        -- gdebug('do delete')
        self:delete()
    else

        if GetItemCharges(self.itemJ) + amount <= 0 then
            self:delete()
        else
            SetItemCharges(self.itemJ, GetItemCharges(self.itemJ) + amount)
        end
    end
end
--------------------------------------------------------------------------------------
function mt:getUses()
    return GetItemCharges(self.itemJ)
end
--------------------------------------------------------------------------------------
mt.modCharges = mt.modUses
--------------------------------------------------------------------------------------
function fc.flyItemByName(itemName, p, from, to, callback, horSpeed, shootAngle, model, height)
    local itemType = reg:getItemType(itemName)
    fc.flyItem(itemType, p, from, to, callback, horSpeed, shootAngle, model, height, {
        itemName = itemName,
    })
end
--------------------------------------------------------------------------------------
function fc.flyItem(itemTypeJ, p, from, to, callback, horSpeed, shootAngle, model, height, addiKeys)

    height = height or 0
    from = from:get_point()
    to = to:get_point()

    local x, y = to[1], to[2]

    local onHit = function(bullet)
        if not callback then
            fc.createItemToPoint(addiKeys.itemName, to, p)
        else
            callback()
        end

        local eff = {
            model = [[Abilities\Spells\Other\Transmute\PileofGold.mdl]],
        }

        as.effect:pointEffect(eff, to)
    end

    if from * to < 5 then
        onHit()
        return
    end

    if not horSpeed then
        horSpeed = math.random(1200, 1400)
    end
    if not shootAngle then
        shootAngle = math.random(40, 50)
    end

    local bulletOwner
    if p and p.maid then
        bulletOwner = p.maid
    else
        bulletOwner = nil
    end

    local bulletData = {
        owner = bulletOwner,
        model = model and model or [[Firebrand Shot Yellow.mdx]],
        mode = cst.BULLET_THROW,

        height = 50 + height,
        size = 1,
        face = from / to,
        point = from,
        pointT = to,

        onHit = onHit,

        horSpeed = horSpeed,
        shootAngle = shootAngle,
    }
    local proj = as.projManager:makeProjectile(bulletData)

end
--------------------------------------------------------------------------------------
function fc.rewardItem(itemName, p, from)
    local point = p.rewardPoint

    if not from then
        from = point
    end

    local itemType = reg:getItemType(itemName)
    fc.flyItem(itemType, p, from, point, nil, nil, nil, nil, nil, {
        itemName = itemName,
    })

end
--------------------------------------------------------------------------------------
function mt:getloc()
    local pointJ = GetItemLoc(self.itemJ)
    dbg.handle_ref(pointJ)
    local point = ac.point:convertJPoint(pointJ)
    RemoveLocation(pointJ)
    dbg.handle_unref(pointJ)
    return point
end
--------------------------------------------------------------------------------------
function mt:makeStatsTip(stats)

    local tip = ''
    local statsNum = 0

    for k, v in ipairs(stats) do
        local color = '|cffffcc00'
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

        local valStr = keys.isPct and as.util:convertPct(val) or val

        if dataType == cst.ST_MP_REGEN then
            valStr = str.format('%.1f', val)
            showPct = true
        end

        if keys.isPct then
            showPct = true
        end

        if not showPct then
            valStr = math.floor(valStr)
            tip = string.format('%s%s%s %s%d%s %s', tip, statsNum == 0 and '' or '\n', numPrefix, color, valStr, '|r',
                name)
        else
            tip = string.format('%s%s%s %s%s%s %s', tip, statsNum == 0 and '' or '\n', numPrefix, color, valStr, '|r',
                name)
        end

        statsNum = statsNum + 1
    end

    return tip
end
--------------------------------------------------------------------------------------
fc.ConvertStatsToText = function(stats, val)
    local tip = ''
    local color = '|cffeeff00'
    local dataType = stats
    local keys = cst:getConstKeys(dataType)
    local name = keys.name or 'missing name'
    local showPct = false

    local numPrefix = '+'

    if tonumber(val) < 0 then
        color = '|cffd01000'
        numPrefix = '-'
        val = math.abs(val)
    end

    local valStr = keys.isPct and as.util:convertPct(val) or val

    if dataType == cst.ST_MP_REGEN then
        valStr = str.format('%.1f', val)
        showPct = true
    end

    if keys.isPct then
        showPct = true
    end

    if not showPct then
        if keys.showFloat then
            tip = string.format('%s %s%.2f%s %s', numPrefix, color, valStr, '|r', name)
        else
            if valStr > 1 then
                valStr = math.floor(valStr)
                tip = string.format('%s %s%d%s %s', numPrefix, color, valStr, '|r', name)
            else
                tip = string.format('%s %s%.1f%s %s', numPrefix, color, valStr, '|r', name)
            end
        end

    else
        tip = string.format('%s %s%s%s %s', numPrefix, color, valStr, '|r', name)
    end

    return tip
end
--------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------
return mt

