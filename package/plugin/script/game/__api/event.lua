require 'game.__api.damage_process'

local mt = {}
as.event = mt

--------------------------------------------------------------------------------------
function mt:unitPreCastSpell()
    local uj = GetTriggerUnit()
    local skillj = GetSpellAbilityId()
    local x = GetSpellTargetX()
    local y = GetSpellTargetY()

    local skillBtn = fc.getAttr('skill_btn_obj', skillj)
    local u = as.unit:uj2t(uj)

    if (skillBtn) then
        local keys = {
            u = u,
            dest = as.point:new(x, y, 0),
            trueCast = true,
        }
        skillBtn:beforeCast(keys)

        --     skill:preventCastPassive()

    end
    -- -- has ability trigger
    -- if as.abiCallbacks.callback[I2ID(skillj)] then
    --     local keys = {
    --         u = u,
    --         p = u:getPlayer(),
    --         skillID = I2ID(skillj),
    --         cfg = as.abiCallbacks.callback[I2ID(skillj)],
    --     }

    --     as.abiCallbacks:castSpell(keys)
    -- end

    -- -- cancel passive act
    -- local skill = as.skillManager:skillj2t(skillj)
    -- local u = as.unit:uj2t(uj)

    -- if (skill) then
    --     skill:preventCastPassive()

    --     if skill.pack.clickEvent then
    --         skill.pack.clickEvent(skill, u)
    --     end
    -- end

end
--------------------------------------------------------------------------------------
function mt:unitAtked()
    local uj = GetTriggerUnit()
    local atkerj = GetAttacker()
    local u = as.unit:uj2t(uj)
    local atker = as.unit:uj2t(atkerj)

    atker:preAtk(u)
end

--------------------------------------------------------------------------------------
function mt:unitCastSpell()

    local uj = GetTriggerUnit()
    local tj = GetSpellTargetUnit()
    local ij = GetSpellTargetItem()
    local x = GetSpellTargetX()
    local y = GetSpellTargetY()
    local skillj = GetSpellAbilityId()

    local skillBtn = fc.getAttr('skill_btn_obj', skillj)
    local u = as.unit:uj2t(uj)
    local tgt = as.unit:uj2t(tj)

    -- if not u then
    --     fc.asyncCheck(string.format('%s 向 %s 施法: %s ；无unit table', GetUnitName(uj), GetUnitName(tj),
    --         GetAbilityName(skillj)))
    --     gdebug('uid: ' .. uj)
    --     return
    -- else
    --     fc.asyncCheck(string.format('%s 向 %s 施法: %s，属于玩家：%s', GetUnitName(uj), GetUnitName(tj),
    --         GetAbilityName(skillj), u.owner:getName()))
    --     gdebug('uid: ' .. uj)
    -- end

    -- is custom skill
    if (skillBtn) then
        local keys = {
            u = u,
            tgt = tgt,
            dest = as.point:new(x, y, 0),
            skillBtn = skillBtn,
            trueCast = true,
        }
        skillBtn:onCast(keys)

        -- u:onCast(keys)
    end

    as.ability:checkRawAbilityCallback({
        u = u,
        ij = ij,
        tgt = tgt,
        dest = as.point:new(x, y, 0),
        abilityIdString = I2ID(skillj),
    })

end

--------------------------------------------------------------------------------------
function mt:unitDie()
    local uj = GetTriggerUnit()
    local u = as.unit:uj2t(uj)

    if u then
        local killer = u.lastDmgFrom
        local keys = {
            killer = killer,
            u = u,
            p = killer and killer.owner or nil,
        }

        u:onDie(keys)

    end
end

--------------------------------------------------------------------------------------
function mt:getItem()

    local uj = GetTriggerUnit()
    local itemJ = GetManipulatedItem()
    local itemTypeJ = GetItemTypeId(itemJ)

    local u = as.unit:uj2t(uj)
    local item = as.item:j2t(itemJ)
    local p = u.owner

    if not item:testOwner(p) then
        -- gdebug('getting other player item')
        msg.notice(p, '这件物品不属于你。')
        item:forceDrop()
        return
    end
    -- gdebug('getting self item')

    if item.owner ~= p then
        -- gdebug('设置临时持有者')
        item.tempOwner = p
    end

    if u then
        item:setHolder(u)
        item:setUpdateSlot()

        local keys = {
            u = u,
            itemJ = itemJ,
            itemTypeJ = itemTypeJ,
            item = item,
        }
        item:onPickUp(u)

        if u.type == 'hero' and as.dataRegister.equipInfo[itemTypeJ] then
            local result, msg = as.equip:heroGetEquip(keys)
            gdebug(string.format('%s, %s', result, msg))
        end
        -- u:onDie(keys)

    end

    local p = u.owner
    -- ui.quickPass.updateHide(p)

    if u.type == 'hero' and u.inFight then
        ac.wait(2, function()
            u:setAtkPoint(u.atkPoint)
        end)
    end

end

--------------------------------------------------------------------------------------
function mt:dropItem()
    local uj = GetTriggerUnit()
    local u = as.unit:uj2t(uj)
    local itemJ = GetManipulatedItem()
    local itemTypeJ = GetItemTypeId(itemJ)

    if slk.item[itemTypeJ]['powerup'] == '1' then
        gdebug('drop power up')
        return
    end

    local item = as.item:j2t(itemJ)

    if not item:testOwner(u.owner) then
        print('froping other player item')
        return
    end

    if u then

        local keys = {
            u = u,
            itemJ = itemJ,
            itemTypeJ = itemTypeJ,
            item = item,
        }

        if u.type == 'hero' and as.dataRegister.equipInfo[itemTypeJ] then
            local result, msg = as.equip:heroDropEquip(keys)
            -- gdebug(string.format('%s, %s', result, msg))
        end
        -- u:onDie(keys)
        item:onDrop(u)

    end

    local p = u.owner
    -- ui.quickPass.updateHide(p)

    item.tempOwner = nil
    -- gdebug('set temp owner nil')

end

--------------------------------------------------------------------------------------
function mt:useItem()
    local uj = GetTriggerUnit()
    local itemJ = GetManipulatedItem()
    local itemTypeJ = GetItemTypeId(GetManipulatedItem())
    local item = as.item:j2t(itemJ)
    local u = as.unit:uj2t(uj)

    if u then
        local keys = {
            u = u,
            itemJ = itemJ,
            itemTypeJ = itemTypeJ,
            item = item,
        }

        -- if as.dataRegister.skillbookInfo[itemTypeJ] then
        --     local result, msg = as.dataRegister:useSkillBook(keys)
        --     gdebug(string.format('%s, %s', result, msg))
        -- end

        if as.dataRegister.itemTypeCallback[itemTypeJ] then
            local callback = as.dataRegister.itemTypeCallback[itemTypeJ]
            callback(keys)
        end

        item:onUse(u)

    end

    if u.type == 'hero' and u.inFight then
        if as.test.canFreeMove then
            return
        end

        ac.wait(2, function()
            u:setAtkPoint(u.atkPoint)
        end)
    end

end

local EVENT_DAMAGE_DATA_VAILD = 0
local EVENT_DAMAGE_DATA_IS_PHYSICAL = 1
local EVENT_DAMAGE_DATA_IS_ATTACK = 2
local EVENT_DAMAGE_DATA_IS_RANGED = 3
local EVENT_DAMAGE_DATA_DAMAGE_TYPE = 4
local EVENT_DAMAGE_DATA_WEAPON_TYPE = 5
local EVENT_DAMAGE_DATA_ATTACK_TYPE = 6

--------------------------------------------------------------------------------------
function mt:unitTakeDmg()
    if jass.GetEventDamage() == 0 then
        return
    end

    local uj = GetEventDamageSource()
    local tgtj = GetTriggerUnit()
    local u = as.unit:uj2t(uj)
    local tgt = as.unit:uj2t(tgtj)

    local atkType = ConvertAttackType(japi.EXGetEventDamageData(EVENT_DAMAGE_DATA_ATTACK_TYPE))
    if atkType == ATTACK_TYPE_PIERCE then
        local dmg = jass.GetEventDamage()

        -- print('deal dmg: ' .. dmg)
        japi.EXSetEventDamage(0)

        u:triggerEvent(UNIT_EVENT_BEFORE_LAUNCH_ATK, {
            unit = u,
            tgt = tgt,
            isAtk = true,
            safeExecute = true,
        })

        u:onShootAtkLaunch(tgt, {
            dmg = u:getStats(ST_ATK),
            isAtk = true,
        })
        return
    else
        japi.EXSetEventDamage(0)
        local keys = {
            unit = u,
            tgt = tgt,
            dmg = u:getStats(ST_ATK),
            dmgType = DMG_TYPE_PHYSICAL,
            isAtk = true,
        }
        ApplyDamage(keys)
        return
    end

    -- local isAtk = 0 ~= japi.EXGetEventDamageData(EVENT_DAMAGE_DATA_IS_ATTACK)
    -- local dmgType = cst.DMG_TYPE_PHYSICAL

    -- if dmgTypeJ == DAMAGE_TYPE_MAGIC then
    --     dmgType = cst.DMG_TYPE_MAGICAL

    -- elseif dmgTypeJ == DAMAGE_TYPE_DIVINE then
    --     dmgType = cst.DMG_TYPE_PURE
    -- end

    -- if u and tgt then
    --     local keys = u.dmgKeys or {}

    --     keys.u = u
    --     keys.tgt = tgt
    --     keys.dmg = dmg
    --     keys.isAtk = isAtk
    --     keys.dmgType = dmgType
    --     -- keys.elementType = keys.elementType or cst.ELEMENT_NIL
    --     keys.elementType = nil

    --     -- as.damage:processDmg(keys)

    -- end
end

--------------------------------------------------------------------------------------
function mt:playerChat()

    -- local u = testUnit
    local pJ = GetTriggerPlayer()
    local msg = GetEventPlayerChatString()
    local p = cg.Player:pj2t(pJ)

    local displayMsg = str.format('%s%s', p:getNameWithColon(), msg)
    GUI.PlayerChat:newMessage(displayMsg)

    local head = string.sub(msg, 1, 1)
    local payload = string.sub(msg, 2)

    if head == '-' then
        as.test:enterMsg(p, payload)
        as.command:enterMsg(p, payload)
    end

    gdebug(string.format('head: %s', head))

    -- as.msg.send(cst.ALL_PLAYERS, displayMsg, 10)

end

--------------------------------------------------------------------------------------
function mt:pickBoxClick()
    local boxJ = GetClickedDialogBJ()
    local btnJ = GetClickedButtonBJ()
    local box = PickBox:boxj2t(boxJ)

    box:btnClicked(btnJ)
end

--------------------------------------------------------------------------------------
function mt:heroLvUp() -- 已废弃
    local uJ = GetTriggerUnit()
    local u = as.unit:uj2t(uJ)

    -- u:levelUp()
end

--------------------------------------------------------------------------------------
function mt:playerPickUnit()
    local pJ = GetTriggerPlayer()
    local uJ = GetTriggerUnit()
    local p = as.player:pj2t(pJ)
    local u = as.unit:uj2t(uJ)

    local lastU = p.lastPick

    p:setLastPick(u)
    p:resetAfkCount()

    if lastU then
        if lastU.eventList[UNIT_EVENT_ON_PICK] then

            for _, pack in ipairs(lastU.eventList[UNIT_EVENT_ON_PICK]) do
                local packName = pack.name
                xpcall(function()
                    pack.callback(pack, p, lastU, false)
                end, function(msg)
                    print(msg, debug.traceback())
                end)

            end
        end
    end

    if u.eventList[UNIT_EVENT_ON_PICK] then
        for _, pack in ipairs(u.eventList[UNIT_EVENT_ON_PICK]) do
            local packName = pack.name
            xpcall(function()
                pack.callback(pack.self, p, u, true)
            end, function(msg)
                print(msg, debug.traceback())
            end)

        end
    end

    if p:isLocal() then
        GUI.GroundItemInfo:hide()
        if lastU ~= p.lastPick then
            toolbox:hide()
        end
    end

    -- -- ui info update
    -- -- ui.stats_icon:onPickUnit(p, u)

    -- ui.quickPass.updateHide(p)

    -- ui.skillHint.update(p)

    -- ui.collectionInv.updateCollectionSlot(p)

end
--------------------------------------------------------------------------------------
function code.enemyEnterBase()
    local uJ = GetTriggerUnit()
    local u = as.unit:uj2t(uJ)
    local p = u.owner

    -- if p == cst.PLAYER_ENEMY then
    --     as.enemyManager.enterBase(u)
    -- end

    return
end
--------------------------------------------------------------------------------------
function code.allyEnterCamp()
    local uJ = GetTriggerUnit()

    -- if true then
    --     return
    -- end

    if GetOwningPlayer(uJ) == Player(9) then
        return
    end

    local u = as.unit:uj2t(uJ)
    local p = u.owner

    if u.type == 'hero' then
        u:enterCamp()
    end

    if u:hasBuff(cst.BUFF_SUMMON) or u:hasBuff('幻象') then
        as.summonManager.vanish(u)

    end

end
--------------------------------------------------------------------------------------
function code.pressTilde(pJ)
    local p = as.player:pj2t(pJ)
    p:pressTilde()
end
--------------------------------------------------------------------------------------
function code.changeWindowSize(pJ)
    local p = as.player:pj2t(pJ)
    uiHelper.changeWindowSize(p)
end
--------------------------------------------------------------------------------------
function code.pressAlt(pJ)
    local p = as.player:pj2t(pJ)
    gdebug('player press alt')
    p.pressedAlt = true
end
--------------------------------------------------------------------------------------
function code.releaseAlt(pJ)
    local p = as.player:pj2t(pJ)
    p.pressedAlt = false
end
--------------------------------------------------------------------------------------
function mt:pointOrder()
    local uJ = GetTriggerUnit()
    local u = as.unit:uj2t(uJ)


    if u.type == 'maid' and OrderId2StringBJ(GetIssuedOrderIdBJ()) == "smart" then
        local pointJ = GetOrderPointLoc()
        dbg.handle_ref(pointJ)
        u:blink(fc.convertJPoint(pointJ))
        RemoveLocation(pointJ)
        dbg.handle_unref(pointJ)
    end

end
-------------------------------------------------------------------------------------
-- not event
function mt:issueAtk(u)

    gdebug('try issue atk')

    if not u.inFight then
        return
    end

    if not u.stopOperateHeroTimer then
        u.stopOperateHeroTimer = ac.wait(ms(1), function()
            u.stopOperateHeroTimer = nil
            if not as.util:isInCd(u, 'fight_spell') then
                u:setAtkPoint(u.atkPoint)
            else
                mt:issueAtk(u)
            end
        end)
    end
end

--------------------------------------------------------------------------------------
function mt:stopOperateHero()

    if true then
        return
    end

    local uJ = GetTriggerUnit()
    if not IsUnitType(GetTriggerUnit(), UNIT_TYPE_HERO) then
        return
    end

    local u = as.unit:uj2t(uJ)
    -- gdebug(str.format('%s do act: %s', u:getName(), OrderId2StringBJ(GetIssuedOrderIdBJ())))

    if as.test.canFreeMove then
        return
    end

    if u.type == 'hero' and u.inFight then
        if OrderId2StringBJ(GetIssuedOrderIdBJ()) == "smart" then
            ac.wait(2, function()
                u:setAtkPoint(u.atkPoint)
            end)

            if GetOrderTargetItem() ~= 0 then
                UnitAddItem(uJ, GetOrderTargetItem())
            end
        elseif OrderId2StringBJ(GetIssuedOrderIdBJ()) ~= "attack" then

            mt:issueAtk(u)

        end
    end

end

--------------------------------------------------------------------------------------
function mt:techFinish()
    local uj = GetTriggerUnit()
    local techJ = GetResearched()
    local u = as.unit:uj2t(uj)

    -- has ability trigger
    if as.abiCallbacks.callback[I2ID(techJ)] then
        local keys = {
            u = u,
            p = u:getPlayer(),
            tech = I2ID(techJ),
            cfg = as.abiCallbacks.callback[I2ID(techJ)],
        }

        as.abiCallbacks:castSpell(keys)
    end

end
--------------------------------------------------------------------------------------
function code.itemMouseIn(i)
    local pj = dz.DzGetTriggerUIEventPlayer()
    local p = as.player:pj2t(pj)
    p.mouseInItemSlot = i
    -- gdebug('code item mouse in ' .. i)

    local u = p.lastPick
    if not u then
        return
    end

    local itemHandle = UnitItemInSlotBJ(u.handle, p.mouseInItemSlot)
    if GetItemName(itemHandle) == nil then
        return
    end

    local item = as.item:j2t(itemHandle)
    if p.hero and item.isEquip and item.rare >= 10 then
        local hero = p.hero
        local itemName = item.name
        local hasEaten = fc.getAttr(hero, itemName .. 'eat')
        if hasEaten then
            toolbox:tooltip('已入体', '该装备已入体', 300)
            fc.setFramePos(toolbox, ANCHOR.BOT_LEFT, MAIN_UI, ANCHOR.CENTER, 110, 250)
            toolbox:show()
        end
    end

    -- local item = as.item:j2t(itemHandle)
    if item.isElementModeEquip then
        local title = str.format([[|cffffcc00提供属性：|r]])
        local tip = as.equip.getElementEqTip(item)
        if p:isLocal() then
            toolbox:tooltip(title, tip, 300)
            fc.setFramePos(toolbox, ANCHOR.BOT_LEFT, MAIN_UI, ANCHOR.CENTER, 110, 250)
            toolbox:show()
        end

    end

end
--------------------------------------------------------------------------------------
function code.itemMouseOut()
    local pj = dz.DzGetTriggerUIEventPlayer()
    local p = as.player:pj2t(pj)
    p.mouseInItemSlot = nil

    if p.rightClickTimer then
        p.rightClickTimer:remove()
        p.rightClickTimer = nil
    end

    if p:isLocal() then
        toolbox:hide()
    end

    -- gdebug('code item mouse out ')
end
--------------------------------------------------------------------------------------
function code.skillMouseIn(x, y)
    local pj = dz.DzGetTriggerUIEventPlayer()
    local p = as.player:pj2t(pj)
    p.mouseInSkillSlotX = x
    p.mouseInSkillSlotY = y
    gdebug(str.format('code skill mouse in: %d, %d', x, y))
end
--------------------------------------------------------------------------------------
function code.skillMouseOut()
    local pj = dz.DzGetTriggerUIEventPlayer()
    local p = as.player:pj2t(pj)
    p.mouseInSkillSlotX = nil
    p.mouseInSkillSlotY = nil
    -- gdebug('code skill mouse out ')
end
--------------------------------------------------------------------------------------
function code.leftClick()
    local pj = dz.DzGetTriggerKeyPlayer()
    local p = as.player:pj2t(pj)
    p:resetAfkCount()

    if p == as.player:getLocalPlayer() then
        local itemHandle = japi.GetTargetObject()

        local itemName = GetItemName(itemHandle)
        if itemName ~= nil then
            GUI.GroundItemInfo:update(itemHandle)
            GUI.GroundItemInfo:show()
            GUI.EnemySkills:hide()
        else
            GUI.GroundItemInfo:hide()
        end
    end

    if p.rightClickTimer then
        p.rightClickTimer:remove()
        p.rightClickTimer = nil
    end

end

--------------------------------------------------------------------------------------
function code.rightClick()
    local pj = dz.DzGetTriggerKeyPlayer()
    local p = as.player:pj2t(pj)
    p:resetAfkCount()

    -- item quick pass
    if p.mouseInItemSlot then
        local u = p.lastPick
        if not u then
            return
        end

        local itemHandle = UnitItemInSlotBJ(u.handle, p.mouseInItemSlot)
        if GetItemName(itemHandle) == nil then
            return
        end

        local item = as.item:j2t(itemHandle)
        if item:getSlkData('droppable') == '0' then
            return
        end

        if not p.rightClickTimer then
            p.rightClickTimer = ac.wait(ms(0.4), function()
                p.rightClickTimer = nil
            end)
        else

            item:checkQuickPass()
            p.rightClickTimer:remove()
            p.rightClickTimer = nil
        end

    end

    if p.mouseInSkillSlotX and p.mouseInSkillSlotY then
        local u = p.lastPick
        if not u then
            return
        end

        if u == p.hero then
            if p.mouseInSkillSlotX == 2 then
                u:tryRerollCustomSkill(p.mouseInSkillSlotY + 1)
            end

        end
    end

end
--------------------------------------------------------------------------------------
function code.gameDebug(s)
    gdebug(s)
end
--------------------------------------------------------------------------------------
function code.updatePlatformId(pId, platformIdStr)

    print(str.format('receive updatePlatformId sync'))

    if not platformIdStr then
        print(str.format('同步更新玩家【%d】平台ID失败：无字符串', pId))
        return
    end

    if #platformIdStr < 1 and (not localEnv) then
        print(str.format('同步更新玩家【%d】平台ID失败：%s', pId, platformIdStr))
        return
    end

    if not arch.platformIdTable[pId] then
        print(str.format('同步更新玩家【%d】平台ID成功：%s', pId, platformIdStr))
        arch.platformIdTable[pId] = platformIdStr
    end

end
--------------------------------------------------------------------------------------
function code.getPlatformId()
    return japi.GetUserIdEx()
end
--------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------
return mt
