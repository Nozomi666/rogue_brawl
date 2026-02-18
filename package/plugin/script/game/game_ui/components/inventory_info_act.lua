local mt = {}
--------------------------------------------------------------------------------------
GUI.InventoryInfo = mt
local outerPanel = class.panel.create(nil, 0, 0, 1920, 1080)
--------------------------------------------------------------------------------------
function mt:mouseEnterLocal(slotId)
    -- gdebug('mouse enter inveotry')
    local player = as.player:getLocalPlayer()

    local unit = player.lastPick
    if not unit then
        return
    end

    if unit.master then
        unit = unit.master
    end

    local item = as.item:getUnitSlotItem(unit, slotId)
    if not item then
        return
    end

    if item.bGrowEquip then
        self:showGrowWeaponInfo(item)
    end

end
--------------------------------------------------------------------------------------
function mt:showGrowWeaponInfo(item)
    local title, tip = item:getUIInfo()
    toolbox:tooltip(title, tip)
    toolbox:moveToDefault()
    toolbox:show()
    toolbox:hideOriginTooltip()
    -- gdebug('show grow weapon info')
end
--------------------------------------------------------------------------------------
-- sync
function mt:showGrowWeaponUpgradeAnimation(player, animModel)

    local path = animModel
    if not player:isLocal() then
        path = ''
    end
    local animation = outerPanel:add_model(path)
    animation:set_scale(1, 1, 1)
    fc.setFramePosPct(animation, ANCHOR.TOP_LEFT, MAIN_UI, ANCHOR.TOP_LEFT, 0.69, -0.235)

    ac.wait(ms(1), function()
        animation:set_model('')
        animation:destroy()
    end)

end
--------------------------------------------------------------------------------------
function mt:showGrowWeaponUpgradeCritAnimation(player, animModel)
    local path = animModel
    if not player:isLocal() then
        path = ''
    end
    local animation = outerPanel:add_model(path)
    animation:set_scale(0.4, 0.4, 0.4)
    fc.setFramePosPct(animation, ANCHOR.TOP_LEFT, MAIN_UI, ANCHOR.TOP_LEFT, 0.69, -0.305)

    ac.wait(ms(0.8), function()
        animation:set_model('')
        animation:destroy()
    end)
end
--------------------------------------------------------------------------------------

return
