
local mt = {}
as.castHelper = mt

--------------------------------------------------------------------------------------
function mt:init()
    --mt.dummy = CreateUnit(Player(PLAYER_NEUTRAL_PASSIVE), ID('e001'), 0, 0, 0)
end

--------------------------------------------------------------------------------------
function mt:targetCast(unit, tgt, ability, keys)
    if not unit.handle or not tgt.handle then mapdebug('target cast no unit or tgt') return end
    local lv = keys and keys.lv or 1
    local life = keys and keys.life or 2

    local dummy = as.unit:createJUnit(as.unit.getPlayer(unit), 'e000', as.point:getUnitLoc(unit), as.util:angleBetweenUnits(unit, tgt))
    dbg.handle_ref(dummy)
    ShowUnit(dummy, false)

    if keys then
        lv = keys.lv or lv
    end

    local order = slk.ability[ability].Order
    UnitAddAbility(dummy, ID(ability))
    IssueTargetOrder(dummy, order, tgt.handle)


    ac.timer(ms(life), 1, function ()
        RemoveUnit(dummy)
        dbg.handle_unref(dummy)
    end)
end



return mt