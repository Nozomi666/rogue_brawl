-- local skillShop = require 'game.npc.skill_shop'
local mt = {}
as.uiEvent = mt

--------------------------------------------------------------------------------------
-- async
mt.skillBtnIn = function(frame, keys)
    -- gdebug(str.format('skill btn in: %d, %d', keys.x, keys.y))
    local btnX, btnY = keys.x, keys.y
    local btnId = btnX * 4 + btnY + 1

    local p = as.player:getLocalPlayer()
    local u = p.lastPick
    if not u then
        return
    end

    if u.mouseInTool then
        u:mouseInTool(btnId)
    end

end
--------------------------------------------------------------------------------------
-- async
mt.skillBtnOut = function(frame, keys)
    -- gdebug(str.format('skill btn out: %d, %d', keys.x, keys.y))
    local p = as.player:getLocalPlayer()
    local u = p.lastPick
    if not u then
        return
    end

    skillTipbox:hide()
    toolbox:showOriginTooltip()

end
--------------------------------------------------------------------------------------
-- async
mt.itemBtnIn = function(frame, keys)
    -- gdebug(str.format('skill btn in: %d, %d', keys.x, keys.y))

    local btnId = keys.id + 1
    -- gdebug('item in' .. btnId)

    local p = as.player:getLocalPlayer()
    local u = p.lastPick
    if not u then
        return
    end

    local itemHandle = UnitItemInSlotBJ(u.handle, btnId)
    if GetItemName(itemHandle) == nil then
        return
    end

    local item = HandleGetTable(itemHandle)
    if not item then
        warn('mouse in no item, assync')
        print(GetItemName(itemHandle))
        return
    end

    if item.getSkilltipInfo then
        local info = item:getSkilltipInfo()
        skillTipbox:makeTip(info)

        toolbox:hideOriginTooltip()
    end

    if item.getExtraInfo then
        local title, tip = item:getExtraInfo()
        if title then
            toolbox:tooltip(title, tip)
            fc.setFramePos(toolbox, ANCHOR.BOT_RIGHT, skillTipbox, ANCHOR.BOT_LEFT, 0, 0)
            toolbox:show()
        end

    end

end
--------------------------------------------------------------------------------------
-- async
mt.itemBtnOut = function(frame, keys)
    -- gdebug('item out ')
    toolbox:hide()
    skillTipbox:hide()
    local p = as.player:getLocalPlayer()
    local u = p.lastPick
    if not u then
        return
    end

    toolbox:showOriginTooltip()
    -- GUI.InventoryInfo:mouseLeftLocal(p)
end
--------------------------------------------------------------------------------------
-- mt.asyncMouseDownOnItemSlot = function(itemSlotId, uiX, uiY)
--     local player = fc.getLocalPlayer()
--     local unit = player.lastPick
--     if not unit then
--         -- gdebug('asyncMouseDownOnItemSlot fail, no unit')
--         return
--     end
--     if unit.player ~= player then
--         -- gdebug('asyncMouseDownOnItemSlot fail, picking other player unit')
--         return
--     end

--     local item = unit:getItemBySlot(itemSlotId)
--     if not item then
--         -- gdebug('asyncMouseDownOnItemSlot fail, no item')
--         return
--     end

--     if item.undragable then
--         -- gdebug('asyncMouseDownOnItemSlot fail, item undragable')
--         return
--     end

--     as.uiEvent.localSelectItem = item
--     as.uiEvent.localSelectItemId = itemSlotId
--     -- gdebug('asyncMouseDownOnItemSlot success: ' .. item.name)

--     GUI.dragging_item:onDragStart(item, uiX, uiY)

-- end
-- --------------------------------------------------------------------------------------
-- mt.asyncMouseMove = function(uiX, uiY)
--     -- if as.uiEvent.localSelectItem then
--     --     gdebug('asyncMouseMove(drag item): ' .. uiX .. ', ' .. uiY)
--     -- end
--     if not as.uiEvent.localSelectItem then
--         return
--     end

--     local handle = dz.DzGetUnitUnderMouse()
--     -- print(handle)
--     local hasUnit = false
--     local luaObj = HandleGetTable(handle)
--     if luaObj then
--         if luaObj.baseType == 'unit' then
--             hasUnit = true
--         end
--     end

--     GUI.dragging_item:onDragUpdate(hasUnit, uiX, uiY)
-- end
-- --------------------------------------------------------------------------------------
-- mt.asyncMouseUp = function(x, y)
--     local selectItem = as.uiEvent.localSelectItem
--     as.uiEvent.localSelectItem = nil

--     GUI.dragging_item:onDragFinish()
--     if not selectItem then
--         -- gdebug('asyncMouseUp fail, no item')
--         return
--     end

--     if not selectItem.trackingId then
--         -- gdebug('asyncMouseUp fail, no item trackingId')
--         return
--     end

--     --------------------------------------------------------------------------------------
--     -- drop to unit
--     local handle = dz.DzGetUnitUnderMouse()
--     -- print(handle)
--     local luaObj = HandleGetTable(handle)
--     if luaObj then
--         if luaObj.type == 'maid' or luaObj.type == 'hero' then
--             -- selectItem:tryForceGiveTo(luaObj)
--             local msgStr = luaObj.trackingId .. '|' .. selectItem.trackingId
--             japi.DzSyncData("SyncMouseDragItemToUnit", msgStr)
--             return
--         end
--     end

--     local worldX, worldY = game.screen_to_world(x, y)
--     if not fc.isMouseInBottomUI(x, y) then
--         --------------------------------------------------------------------------------------
--         -- drop to point
--         local msgStr = selectItem.trackingId .. '|' .. math.round(worldX) .. '|' .. math.round(worldY)
--         japi.DzSyncData("SyncMouseDragItemToPoint", msgStr)
--         return
--     else
--         --------------------------------------------------------------------------------------
--         -- drop in inventory
--         local itemSlotId = fc.getMouseInItemSlot(x, y)
--         if itemSlotId and itemSlotId ~= as.uiEvent.localSelectItemId then
--             -- perform swap:
--             local msgStr = selectItem.trackingId .. '|' .. as.uiEvent.localSelectItemId .. '|' .. itemSlotId
--             japi.DzSyncData("SyncMouseDragItemToInventory", msgStr)
--         end

--     end
--     -- gdebug('asyncMouseUp success: ' .. x .. ', ' .. y .. ', world: ' .. worldX .. ', ' .. worldY)
--     -- selectItem:forceDrop(ac.point:new(worldX, worldY))

-- end
--------------------------------------------------------------------------------------
mt.receiveMouseDragItemToUnit = function()
    local eventPlayer = japi.DzGetTriggerSyncPlayer()
    local eventMsg = japi.DzGetTriggerSyncData()
    gdebug('receiveMouseDragItemToUnit: ' .. eventMsg)
    local dataKeys = as.util:splitStr(eventMsg, '|')
    local unitId = tonumber(dataKeys[1])
    local itemId = tonumber(dataKeys[2])
    gdebug('receiveMouseDragItemToUnit parse: ' .. unitId .. ', ' .. itemId)
    local luaObj = gm.trackingIdTable[unitId]
    if luaObj then
        if luaObj.type == 'maid' or luaObj.type == 'hero' then
            local item = gm.trackingIdTable[itemId]
            if item then
                if not item.removed then
                    as.player:pj2t(eventPlayer).completeOnceDragItemToUnit = true
                    if luaObj:getEmptyItemSlotNum() > 0 then
                        item:tryForceGiveTo(luaObj)
                    else
                        item:forceDrop(luaObj:getloc())
                    end

                else
                    gdebug('receiveMouseDragItemToUnit fail, item removed')
                    return
                end
            else
                gdebug('receiveMouseDragItemToUnit fail, no item object')
            end
        else
            gdebug('receiveMouseDragItemToUnit fail, no unit object')
        end
    else
        gdebug('receiveMouseDragItemToUnit fail, no unitHandle')
    end
end
--------------------------------------------------------------------------------------
mt.receiveMouseDragItemToPoint = function()
    local eventPlayer = japi.DzGetTriggerSyncPlayer()
    local eventMsg = japi.DzGetTriggerSyncData()
    gdebug('receiveMouseDragItemToPoint: ' .. eventMsg)
    local dataKeys = as.util:splitStr(eventMsg, '|')
    local itemId = tonumber(dataKeys[1])
    local worldX = tonumber(dataKeys[2])
    local worldY = tonumber(dataKeys[3])

    local item = gm.trackingIdTable[itemId]
    if item then
        if not item.removed then
            item:forceDrop(ac.point:new(worldX, worldY))
            as.player:pj2t(eventPlayer).completeOnceDragItemToPoint = true
        else
            gdebug('receiveMouseDragItemToPoint fail, item removed')
            return
        end
    else
        gdebug('receiveMouseDragItemToPoint fail, no item object')
    end
end
--------------------------------------------------------------------------------------
mt.receiveMouseDragItemToInventory = function()
    local eventPlayer = japi.DzGetTriggerSyncPlayer()
    local eventMsg = japi.DzGetTriggerSyncData()
    gdebug('receiveMouseDragItemToInventory: ' .. eventMsg)
    local dataKeys = as.util:splitStr(eventMsg, '|')
    local itemId = tonumber(dataKeys[1])
    local fromInvId = tonumber(dataKeys[2])
    local toInvId = tonumber(dataKeys[3])
    local item = gm.trackingIdTable[itemId]
    if item then
        if not item.removed then
            item:moveToInventory(fromInvId, toInvId)
            as.player:pj2t(eventPlayer).completeOnceDragItemToInventory = true
        else
            gdebug('receiveMouseDragItemToInventory fail, item removed')
            return
        end
    else
        gdebug('receiveMouseDragItemToInventory fail, no item object')
    end
end
--------------------------------------------------------------------------------------
-- 给予物品（给单位）
local trig = CreateTrigger()
japi.DzTriggerRegisterSyncData(trig, "SyncMouseDragItemToUnit", false)
jass.TriggerAddAction(trig, mt.receiveMouseDragItemToUnit)
dbg.handle_ref(trig)
--------------------------------------------------------------------------------------
-- 给予物品（给地面）
local trig = CreateTrigger()
japi.DzTriggerRegisterSyncData(trig, "SyncMouseDragItemToPoint", false)
jass.TriggerAddAction(trig, mt.receiveMouseDragItemToPoint)
dbg.handle_ref(trig)
--------------------------------------------------------------------------------------
-- 调换物品栏内位置
local trig = CreateTrigger()
japi.DzTriggerRegisterSyncData(trig, "SyncMouseDragItemToInventory", false)
jass.TriggerAddAction(trig, mt.receiveMouseDragItemToInventory)
dbg.handle_ref(trig)
--------------------------------------------------------------------------------------

return mt
