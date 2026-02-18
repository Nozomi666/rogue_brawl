local Unit = require 'game.class.base.unit'
require 'game.class.custom.unit'

local mt = {}

mt.__index = mt
setmetatable(mt, cg.Unit)
as.maid = mt

mt.parent = Unit

mt.type = 'maid'

mt.hId = 0
mt.bHideHpText = true

mt.accsManager = nil
mt.accsBtn = nil
mt.skillBtn = nil

--------------------------------------------------------------------------------------
function mt:create(p)
    if not p then
        return
    end

    local u = cg.Unit:createUnit(p, 'e000', p.maidBornPoint, 0)
    local uJ = u.handle

    setmetatable(u, self)

    u:hide()

    -- add skill
    UnitAddAbility(uJ, ID('AInv'))
    UnitAddAbility(uJ, ID('Avul'))

    -- UnitAddAbility(uJ, ID('m002')) -- 丢弃物品
    -- UnitAddAbility(uJ, ID('m001')) -- 拾起物品

    -- UnitAddAbility(uJ, ID('m004')) -- 合成物品（地面）


    -- UnitAddAbility(uJ, ID('m003')) -- 合成物品（身上）
    -- UnitAddAbility(uJ, ID('m006')) -- 整理物品


    local pId = p.id


    u:init()

    return u
end
--------------------------------------------------------------------------------------
function mt:init()
    local p = self.owner

    self:setStats(ST_MOVE_SPEED, 522)
    self:setStats(ST_HP_MAX, 99999)
    self:setStats(ST_HP_REGEN, 99999)
    self.skillBtn = {}


    -- 选择单位事件
    local eventPack = {
        name = 'on_pick_event',
        condition = UNIT_EVENT_ON_PICK,
        callback = mt.onMousePick,
    }
    self:addEvent(eventPack)





end
--------------------------------------------------------------------------------------
function mt:onMousePick(p, u, isPick)

    p.shopAutoBuyer = u

end
--------------------------------------------------------------------------------------
function mt.mergeEquipToTop(keys)
    local u = keys.u
    local p = u.owner
    local point = keys.dest

    local list = as.item:getItemInRange(point, 400)
    local set = {}
    local bodyReformSet = {}
    local maxRarity = cst.MAX_EQUIP_LV
    local secondMax = maxRarity - 1
    local maxRarityBodyReform = cst.MAX_BODY_REFORM_LV
    local secondMaxBodyReform = maxRarityBodyReform - 1

    for i = 1, maxRarity do
        set[i] = {}
    end

    for i = 1, maxRarityBodyReform do
        bodyReformSet[i] = {}
    end

    local skills = {}

    for i = 1, 4 do
        skills[i] = {}
    end

    for k, itemJ in ipairs(list) do

        local item = as.item:j2t(itemJ)

        if item.isEquip and item:testOwner(p) then
            local rarity = item:getRarity()
            table.insert(set[rarity], item)
        end

        if item.pack and item:testOwner(p) and item.pack.isBodyReform then
            local rarity = item.rare
            table.insert(bodyReformSet[rarity], item)
            gdebug('add to pool bodyreform: ' .. item.name)
        end

        if item.pack and item:testOwner(p) and item.pack.isSkillbook then
            table.insert(skills[item.pack.rarity], item)
        end

    end

    local mergeOnce = false
    local mergedSet = {}
    local mergedBody = {}

    for rarity = 1, secondMax do
        local cand = set[rarity] or {}

        while #cand >= 3 do

            local newItem = mt.doMerge(u, cand, rarity)
            if set[rarity + 1] then
                table.insert(set[rarity + 1], newItem)
            end

            table.insert(mergedSet, newItem)

            newItem:move(point)
            mergeOnce = true

        end

    end

    for rarity = 1, secondMaxBodyReform do
        local cand = bodyReformSet[rarity] or {}
        while #cand >= 3 do
            local mergedItem = mt.mergeBodyReform(u, cand, rarity, point)

            if bodyReformSet[rarity + 1] then
                table.insert(bodyReformSet[rarity + 1], mergedItem)
            end

            table.insert(mergedBody, mergedItem)

            mergeOnce = true
        end
    end

    if mergeOnce then
        sound.playToPlayer(glo.gg_snd_merge_item, p, 1, 0.05, true)

        local eff = {
            model = [[UltimateEarthFlash.mdx]],
            time = 0.5,
        }

        for _, mergedItem in ipairs(mergedSet) do
            if not mergedItem.removed then
                msg.notice(u.owner, str.format('你成功合成了装备 %s ！', mergedItem:getNameWithRare()))
            end
        end

        fc.pointEffect(eff, point)
    end
end
--------------------------------------------------------------------------------------
function mt.mergeEquip(keys)
    local u = keys.u
    local p = u.owner
    local point = keys.dest

    local list = as.item:getItemInRange(point, 400)
    local set = {}
    local bodyReformSet = {}
    local maxRarity = cst.MAX_EQUIP_LV
    local secondMax = maxRarity - 1
    local maxRarityBodyReform = cst.MAX_BODY_REFORM_LV
    local secondMaxBodyReform = maxRarityBodyReform - 1

    for i = 1, maxRarity do
        set[i] = {}
    end

    for i = 1, maxRarityBodyReform do
        bodyReformSet[i] = {}
    end

    local skills = {}

    for i = 1, 4 do
        skills[i] = {}
    end

    for k, itemJ in ipairs(list) do

        local item = as.item:j2t(itemJ)

        if item.isEquip and item:testOwner(p) then
            local rarity = item:getRarity()
            if rarity <= maxRarity then
                table.insert(set[rarity], item)
            end
        end

        if item.pack and item:testOwner(p) and item.pack.isBodyReform then
            local rarity = item.rare
            table.insert(bodyReformSet[rarity], item)

        end

        if item.pack and item:testOwner(p) and item.pack.isSkillbook then
            -- gdebug('merge skillbook')
            table.insert(skills[item.pack.rarity], item)
        end

    end

    local mergeOnce = false
    local mergedSet = {}
    local mergedBody = {}

    for rarity = 1, secondMax do
        local cand = set[rarity] or {}

        while #cand >= 3 do

            local newItem = mt.doMerge(u, cand, rarity)
            table.insert(mergedSet, newItem)

            newItem:move(point)
            mergeOnce = true

        end

    end

    for rarity = 1, secondMaxBodyReform do
        local cand = bodyReformSet[rarity] or {}
        while #cand >= 3 do
            local mergedItem = mt.mergeBodyReform(u, cand, rarity, point)
            mergeOnce = true

            table.insert(mergedBody, mergedItem)
        end
    end

    if mergeOnce then
        sound.playToPlayer(glo.gg_snd_merge_item, p, 1, 0.05, true)

        local eff = {
            model = [[UltimateEarthFlash.mdx]],
            time = 0.5,
        }

        for _, mergedItem in ipairs(mergedSet) do
            if not mergedItem.removed then
                msg.notice(u.owner, str.format('你成功合成了装备 %s ！', mergedItem:getNameWithRare()))
            end
        end

        --[[for _, mergedItem in ipairs(mergedBody) do
            if not mergedItem.removed then
                msg.notice(u.owner, str.format('你成功合成了躯改 %s ！', mergedItem:getNameWithRare()))
            end
        end]]

        fc.pointEffect(eff, point)
    end

end
--------------------------------------------------------------------------------------
function mt.dropAll(keys)

    print('call maid drop')

    local self = keys.u
    local point = keys.dest
    local x, y = point[1], point[2]
    for i = 1, 6 do
        SetItemPosition(UnitItemInSlotBJ(self.handle, i), x, y)
    end

end
--------------------------------------------------------------------------------------
function mt.pickUp(keys)
    local self = keys.u
    local u = keys.u
    local point = keys.dest
    local list = as.item:getItemInRange(point, 400)

    print('call maid pickup')

    for k, itemJ in ipairs(list) do
        if GetItemName(itemJ) then
            local item = as.item:j2t(itemJ)
            if item:testOwner(u.owner) then
                UnitAddItem(u.handle, itemJ)
            end
        else
            print('ignore no name (nil) item pickup')
        end

    end
end
--------------------------------------------------------------------------------------
function mt:castSpell(keys)
    gdebug('maid skill')
    local act = mt.spellList[keys.skillID]
    act(mt, keys)

end
--------------------------------------------------------------------------------------
function mt.tryHoldMerge(keys)
    local u = keys.u
    local self = u
    gdebug('on try hold merge')
    local p = u.owner
    local set = {}
    local bodyReformSet = {}
    local list = {}

    local skills = {}

    for i = 1, 4 do
        skills[i] = {}
    end

    for i = 1, 6 do
        local ij = UnitItemInSlotBJ(self.handle, i)
        if ij ~= 0 then
            table.insert(list, ij)
        end
    end

    local maxRarity = cst.MAX_EQUIP_LV
    local secondMax = maxRarity - 1

    local maxRarityBodyReform = cst.MAX_BODY_REFORM_LV
    local secondMaxBodyReform = maxRarityBodyReform - 1

    for i = 1, maxRarity do
        set[i] = {}
    end

    for i = 1, maxRarityBodyReform do
        bodyReformSet[i] = {}
    end

    local foundMergeItem = false
    for i = 1, 5 do
        if list[i] then
            local item1 = as.item:j2t(list[i])
            for j = i + 1, 6 do
                if not foundMergeItem then
                    if list[j] then
                        local item2 = as.item:j2t(list[j])
                        for k = j + 1, 6 do
                            if not foundMergeItem then
                                if list[k] then
                                    local item3 = as.item:j2t(list[k])

                                    if item1.isEquip and item2.isEquip and item3.isEquip and item1:getRarity() ==
                                        item2:getRarity() and item1:getRarity() == item3:getRarity() then
                                        table.insert(set[item1:getRarity()], item1)
                                        table.insert(set[item1:getRarity()], item2)
                                        table.insert(set[item1:getRarity()], item3)
                                        foundMergeItem = true
                                        break
                                    end

                                    if item1.isBodyReform and item2.isBodyReform and item3.isBodyReform and item1.rare ==
                                        item2.rare and item1.rare == item3.rare then
                                        table.insert(bodyReformSet[item1.rare], item1)
                                        table.insert(bodyReformSet[item1.rare], item2)
                                        table.insert(bodyReformSet[item1.rare], item3)
                                        foundMergeItem = true
                                        break
                                    end

                                end
                            end

                        end
                    end

                end

            end
        end

    end

    local mergeOnce = false

    for rarity = 1, secondMax do
        local cand = set[rarity] or {}
        while #cand >= 3 do

            local mergedItem = mt.doMerge(u, cand, rarity)
            mergeOnce = true
            msg.notice(u.owner, str.format('你成功合成了装备 %s ！', mergedItem:getNameWithRare()))
            break
        end

        if mergeOnce then
            sound.playToPlayer(glo.gg_snd_merge_item, p, 1, 0.05, true)
            local eff = {
                model = [[UltimateEarthFlash.mdx]],
                time = 0.5,
            }

            fc.pointEffect(eff, u:getloc())
            break
        end

    end
end
--------------------------------------------------------------------------------------
function mt:doMerge(cand, rarity, args)
    local u = self
    local p = u.owner


    for i = 1, 3 do
        local item = table.remove(cand, 1)
        if item.pack and item.pack.onMerge then
            fc.safeExecute(function()
                item.pack.onMerge(item, u)
            end)
        end

        if i ~= 3 then
            item:delete()
        end

    end

    local newName = p:getRandomEquip(rarity + 1).name

    local pack = fc.getAttr('equip_pack', newName)

    local args = {
        name = newName,
        holder = u,
        owner = u.owner,
    }

    local newItem = as.equip:makeEquip(args)

    return newItem

end
--------------------------------------------------------------------------------------
function mt:blink(point)
    local u = self

    if u:getloc() * point < 1000 then
        return
    end

    local eff = {
        model = [[Abilities\Spells\NightElf\Blink\BlinkTarget.mdl]],
    }
    fc.pointEffect(eff, point)
    local angle = u:getloc() / point
    u:move(point)
    ac.wait(ms(0.1), function()
        japi.EXSetUnitFacing(u.handle, angle)
    end)

end
--------------------------------------------------------------------------------------
function mt:toggleSetting(keys)
    local u = keys.u
    local p = u.owner

    if p:isLocal() then
        if ui.gameSetting.panel:get_is_show() then
            ui.gameSetting.panel:hide()
        else
            ui.gameSetting.panel:show()
        end
    end

end
--------------------------------------------------------------------------------------
function mt:setItemShare(keys)
    local u = keys.u
    local p = u.owner
    p.shareItem = true

    UnitRemoveAbility(u.handle, ID('A0IX'))
    UnitAddAbility(u.handle, ID('A0IY'))

    msg.notice(p, '开启了物品共享。')
end
--------------------------------------------------------------------------------------
function mt:setItemNotShare(keys)
    local u = keys.u
    local p = u.owner
    p.shareItem = false

    UnitRemoveAbility(u.handle, ID('A0IY'))
    UnitAddAbility(u.handle, ID('A0IX'))

    msg.notice(p, '关闭了物品共享。')
end
--------------------------------------------------------------------------------------
function mt.sortItems(keys)
    local u = keys.u
    local p = u.owner
    local point = p.rewardPoint
    local point2 = p.rewardPointEquip
    local point3 = p.rewardPointBodyReform
    local list = as.item:getItemInRange(point, 2000)

    for k, itemJ in ipairs(list) do

        local item = as.item:j2t(itemJ)

        if item.isBodyReform then
            item:move(point3)
        elseif item.isEquip then
            item:move(point2)
        else
            item:move(point)
        end

    end

end
--------------------------------------------------------------------------------------
function mt.onToggleFish(keys)
    local u = keys.u
    local p = u.owner
    local hero = p.hero
    if not hero then
        msg.error(p, '需要先选择英雄。')
        return
    end

    if hero:isDead() then
        msg.error(p, '需要英雄复活。')
        return
    end

    if not hero.isFishing then
        if gm.state ~= GAME_STATE_NORMAL and gm.state ~= GAME_STATE_PREGAME and gm.state ~= GAME_STATE_ENDLESS then
            msg.error(p, '当前游戏阶段不能钓鱼。')
            return
        end

        hero:startFish()
    else
        hero:endFish()
    end

end
--------------------------------------------------------------------------------------
function mt.skipToFinalBoss(keys)
    local unit = keys.u
    local player = unit.owner
    local hero = player.hero

    -- if gm.quickMode then
    --     msg.error(player, '已经开启了快速模式。')
    --     return
    -- end

    -- if not gm.host == player then
    --     msg.error(player, '你不是主机，无法使用该功能。')
    --     return
    -- end

    -- if player:getMapLv() < 5 then
    --     msg.error(player, '地图等级未满足需求。')
    --     return
    -- end

    -- if EnemyManager.diffHeatMode then
    --     msg.error(player, '地狱模式无法启用该功能')
    --     return
    -- end

    -- local cpId = gm.chapter.id
    -- local diffId = EnemyManager.diffNum
    -- if diffId >= 7 then
    --     cpId = cpId + 1
    -- end
    -- if diffId == 6 then
    --     diffId = 8
    -- else
    --     diffId = (diffId + 2) % 8
    -- end

    -- -- gdebug('cpId = ' .. cpId)
    -- -- gdebug('diffId = ' .. diffId)

    -- local arch = str.format([[%d-%d-%d]], cpId, diffId, 1)
    -- if not player:hasArch(arch) then
    --     msg.error(player, '未通关当前难度+2的更高难度。')
    --     return
    -- end

    -- if EnemyManager.waveNum < 10 then
    --     msg.error(player, '第十波后才能开启。')
    --     return
    -- end

    -- if gm.state ~= GAME_STATE_NORMAL or (not (EnemyManager.waveNum < 31)) then
    --     msg.error(player, '当前阶段不能开启。')
    --     return
    -- end

    -- gm.quickMode = true
    -- EnemyManager:setWave(31)

end
--------------------------------------------------------------------------------------
-- override, assync
function mt:mouseInTool(btnId)
    local player = self.player
    local skillBtn = self.skillBtn[btnId]

    if btnId == 1 then
        skillTipbox:makeTip({
            title = '拾起物品(|cffffcc00Q|r)',
            tip = [[拾起地上的物品]],
            icon = [[ReplaceableTextures\CommandButtons\BTNPickUpItem.blp]],
        })
        toolbox:hideOriginTooltip()
    elseif btnId == 2 then
        skillTipbox:makeTip({
            title = '丢弃物品(|cffffcc00W|r)',
            tip = [[丢弃地上的物品]],
            icon = [[ReplaceableTextures\CommandButtons\BTNAttackGround.blp]],
        })
        toolbox:hideOriginTooltip()
    elseif btnId == 3 then
        skillTipbox:makeTip({
            title = '合成物品(|cffffcc00E|r)',
            tip = [[将2个同品质的装备合成成为更高品质的装备]],
            icon = [[ReplaceableTextures\CommandButtons\BTNMagicImmunity.blp]],
        })
        toolbox:hideOriginTooltip()
    elseif btnId == 4 then
        skillTipbox:makeTip({
            title = '合成物品（地面）(|cffffcc00R|r)',
            tip = [[合成地面上相同品质的装备为更高品质的装备]],
            icon = [[ReplaceableTextures\CommandButtons\BTNMagicImmunity.blp]],
        })
        toolbox:hideOriginTooltip()
    elseif btnId == 12 then
        skillTipbox:makeTip({
            title = '整理物品(|cffffcc00V|r)',
            tip = [[整理地上的物品]],
            icon = [[ReplaceableTextures\CommandButtons\BTNCallToArms.blp]],
        })
        toolbox:hideOriginTooltip()
    end

end
--------------------------------------------------------------------------------------
as.ability:registerRawAbilityCallback('m002', mt.dropAll)
as.ability:registerRawAbilityCallback('m001', mt.pickUp)

as.ability:registerRawAbilityCallback('m006', mt.sortItems)
as.ability:registerRawAbilityCallback('m003', mt.tryHoldMerge)
as.ability:registerRawAbilityCallback('m004', mt.mergeEquip)
as.ability:registerRawAbilityCallback('A098', mt.filterBodyReform)

mt.spellList = {
    ['m002'] = mt.dropAll,
    ['m001'] = mt.pickUp,
}
--------------------------------------------------------------------------------------

return mt
