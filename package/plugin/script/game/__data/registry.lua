local mt = {}

local noNameCounter = 0

mt.skillbookCounter = {}
mt.skillbookInfo = {}
mt.skillPackItemType = {}
mt.skillData = {}
mt.skillPool = {}
mt.classComboPool = {}
mt.elementCombo = {}
mt.itemTypeCallback = {}
mt.itemTypePack = {}
mt.packItemType = {}

mt.equipCounter = {}
mt.equipInfo = {}
mt.equipData = {}
mt.equipPool = {
    [1] = {},
    [2] = {},
    [3] = {},
    [4] = {},
    [5] = {},
    [6] = {},
    [7] = {},
    [8] = {},
    [9] = {},
    [10] = {},
}

mt.heroData = {}
mt.buffData = {}
mt.itemData = {}
mt.enemyData = {}
mt.chapterData = {}
mt.enemySkill = {}

mt.skillTestList = {}
mt.equipTestList = {}
mt.stoneTestList = {}
mt.itemTestList = {}
mt.collectionTestList = {}
--------------------------------------------------------------------------------------

if true then
    -- table.insert(mt.itemTestList, 'C级被动技能书')
    -- table.insert(mt.itemTestList, 'C级被动技能书')
    -- table.insert(mt.itemTestList, 'C级主动技能书')
    -- table.insert(mt.itemTestList, 'C级主动技能书')
    -- table.insert(mt.itemTestList, 'A级主动技能书')
    -- table.insert(mt.itemTestList, 'A级主动技能书')
end

local skillModels = {glo.udg_SkillBookModel_C, glo.udg_SkillBookModel_B, glo.udg_SkillBookModel_A,
                     glo.udg_SkillBookModel_S, glo.udg_SkillBookModel_R}
-- local rarityName = {'D', 'C', 'B', 'A', 'S', 'SS', 'SSS', 'R', 'SR', 'SSR'}
local rarityName = {'1', '2', '3', '4', '5', '6', '7', '8', '9', '10'}
-- local collectionModels = {glo.udg_CollectionModel_D, glo.udg_CollectionModel_C, glo.udg_CollectionModel_B,
--                           glo.udg_CollectionModel_A, glo.udg_CollectionModel_S, glo.udg_CollectionModel_R}
local equipModels = {glo.udg_EquipModel_1, glo.udg_EquipModel_2, glo.udg_EquipModel_3, glo.udg_EquipModel_4,
                     glo.udg_EquipModel_5, glo.udg_EquipModel_6, glo.udg_EquipModel_7, glo.udg_EquipModel_8,
                     glo.udg_EquipModel_9, glo.udg_EquipModel_10}

--------------------------------------------------------------------------------------
function mt:makeNoName()
    noNameCounter = noNameCounter + 1
    return noNameCounter
end
--------------------------------------------------------------------------------------
function mt.makeTestItems()
    local p = as.player:getPlayerById(1)
    for _, itemName in ipairs(mt.itemTestList) do
        fc.createItemToPoint(itemName, TestPoint, p)
    end
end

--------------------------------------------------------------------------------------
mt.archCounterSkillPack = 0
--------------------------------------------------------------------------------------
function mt:addToSkillPool(pack)
    table.insert(mt.skillPool, pack)
end
--------------------------------------------------------------------------------------
function mt:addToClassComboPool(pack)
    table.insert(mt.classComboPool, pack)

    local tableName = str.format('%d + %d', pack.class, pack.subClass)

    if not mt[tableName] then
        mt[tableName] = {}
    end

    table.insert(mt[tableName], pack)
end
--------------------------------------------------------------------------------------
function mt:initBuff(pack)
    local name = pack.name
    fc.setAttr('buff_pack', name, pack)
    setmetatable(pack, cg.Buff)
end
--------------------------------------------------------------------------------------
function mt:initShop(pack)
    local name = pack.name
    fc.setAttr('shop_pack', name, pack)
    setmetatable(pack, cg.Shop)
end
--------------------------------------------------------------------------------------
function mt:initEquip(pack, tag)

    mt.equipData[pack.name or mt:makeNoName()] = pack
    setmetatable(pack, Equip)

    if pack.isElementModeEquip then
        pack.art = str.format([[ReplaceableTextures\CommandButtons\BTNeeq_%d_%d.blp]], pack.rare, math.random(1, 3))
    end

    reg:initItem(pack)
    fc.setAttr('equip_pack', pack.name, pack)

    mt:makeEquip(pack, tag)
end
--------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------
function mt:initArchEquip(pack)
    local poolName = str.format('archEquip_%d', pack.mapLv)
    gdebug('poolName = ' .. poolName)
    reg:addToPool(poolName, pack)
    local archEquipPool = reg:getPool(poolName)
    pack.mapId = #archEquipPool

    gdebug('init arch equip %s, map id: %d', pack.name, pack.mapId)
    local poolName = 'allArchEquipPool'
    reg:addToPool(poolName, pack)
end
--------------------------------------------------------------------------------------
function mt:initSkill(pack)
    local name = pack.name
    fc.setAttr('skill_pack', name, pack)

    if pack.skillType == SKILL_TYPE_BLESS and (not pack.bNoPool) then
        reg:addToPool('bless_pool', pack)

        if pack.rare then
            local poolName = cst:getConstTag(pack.blessClassProvide[1], 'poolName') .. pack.rare
            reg:addToPool(poolName, pack)
        end

        local poolName = cst:getConstTag(pack.blessClassProvide[1], 'poolName')
        reg:addToPool(poolName, pack)
    end

    if pack.skillType == SKILL_TYPE_MEMORY and (not pack.bNoPool) then
        reg:addToPool('memory_pool', pack)
    end

    if pack.skillType == SKILL_TYPE_CUSTOM then
        local rare = pack.rare
        local actType = 'active'
        if pack.targetType == SKILL_TARGET_PASSIVE then
            actType = 'passive'
        end
        local poolName = str.format('skill_pool_%s_%d', actType, rare)
        reg:addToPool(poolName, pack)

        -- reg:makeSkillBook(pack)
    end

    if pack.skillType == SKILL_TYPE_HERO_TALENT then
        -- local classTip = '|cffffcc00派系：|r'
        -- local className = cst:getConstName(pack.tagType)
        -- classTip = str.format('%s %s', classTip, className)

        pack.tip = str.format('%s', pack.tip)
    end

    if pack.skillType == SKILL_TYPE_BOSS_ACTIVE then
        reg:addToPool('skill_type_boss_active', pack)
    end
    if pack.skillType == SKILL_TYPE_BOSS_GENERAL then
        reg:addToPool('skill_type_boss_general', pack)
    end
    if pack.skillType == SKILL_TYPE_BOSS_SPECIAL then
        reg:addToPool('skill_type_boss_special', pack)
    end
    if pack.skillType == SKILL_TYPE_BOSS_GROUP then
        reg:addToPool('skill_type_boss_group', pack)
    end
    pack.id = fc.makeSkillId({
        name = pack.name,
    })
    -- gdebug('pack.name = '..pack.name)
    -- gdebug('pack.id = '..pack.id)
    if pack.isFixedCharge == false then
        reg:addToPool('chaos_mode_talend_pool', pack)
    end
    setmetatable(pack, cg.Skill)
end
--------------------------------------------------------------------------------------
function mt:initHero(pack)
    local name = pack.name

    fc.setAttr('hero_pack', name, pack)
    reg:addToPool('hero_pack', pack)

    local uniqueId = TEMP_ID
    TEMP_ID = TEMP_ID + 1

    if fc.getAttr('hero_unique_id', uniqueId) then
        error('heroname: ' .. name)
        error('repeat unique id detected: ' .. uniqueId)
    end

    fc.setAttr('hero_unique_id', uniqueId, pack)

    -- local jType = pack.typeId
    -- local model = slk.unit[ID(jType)]['File']
    -- local eff = AddSpecialEffect(model, cst.TEST_LOC2:get())
    -- dbg.handle_ref(eff)
    -- DestroyEffect(eff)

    -- dbg.handle_unref(eff)

end
--------------------------------------------------------------------------------------
function mt:initEnemy(pack)
    mt.enemyData[pack.name or mt:makeNoName()] = pack
end
--------------------------------------------------------------------------------------
function mt:getHeroByName(name)
    return mt.heroData[name]
end

--------------------------------------------------------------------------------------
function mt:getBuffByName(name)
    return mt.buffData[name]
end

--------------------------------------------------------------------------------------
function mt:getEquipByName(name)
    return mt.equipData[name]
end

--------------------------------------------------------------------------------------
function mt:getSkillByName(name)
    return mt.skillData[name]
end
--------------------------------------------------------------------------------------
function mt:initUnit(pack)
    reg:initTableData('unitPack', pack)
    local objId = pack.objId
    pack.unitType = str.format('w%03d', objId)
end
--------------------------------------------------------------------------------------
function mt:initTableData(table, pack)
    if not mt[table] then
        mt[table] = {}
    end

    mt[table][pack.name or mt:makeNoName()] = pack
end
--------------------------------------------------------------------------------------
function mt:getTableData(table, name)
    return mt[table][name]
end
--------------------------------------------------------------------------------------
function mt:getSkillDataByName(skillName, dataName)

    return mt.skillData[skillName][dataName]
end

--------------------------------------------------------------------------------------
function mt:addToPool(poolName, pack)
    if not mt[poolName] then
        mt[poolName] = {}
    end

    table.insert(mt[poolName], pack)
end
--------------------------------------------------------------------------------------
function mt:removeTgtFromPool(poolName, pack)
    if not mt[poolName] then
        mt[poolName] = {}
    end
    table.removeTarget(mt[poolName], pack)
end
--------------------------------------------------------------------------
function mt:getPool(poolName)
    return mt[poolName]
end
--------------------------------------------------------------------------------------
function mt:resetPool(poolName)
    mt[poolName] = {}
    return mt[poolName]
end
--------------------------------------------------------------------------------------
mt.archSkillPack = {}

--------------------------------------------------------------------------------------
function mt:makeSkillBook(pack)

    local skillName = pack.name

    gdebug('make skillbook' .. skillName)

    -- closure
    local convertColor = function(name)
        return cst.COLOR_CODE[name]
    end

    local plainTip = string.gsub(pack.tip, '%<([%w_.>]*)%>', convertColor)

    local tip = plainTip .. '|n|n|cff94e9de可以共享给队友|r'

    local rareLv = pack.rare
    if rareLv == 0 then
        print('WARNING - register skill rarelv = 0')
        return
    end

    mt.skillbookCounter[rareLv] = (mt.skillbookCounter[rareLv] or 0) + 1

    local itemTypeJ = skillModels[rareLv][mt.skillbookCounter[rareLv]]
    -- local title = string.format('%s%s技能书|r [%s]', cst.SKILL_RARE_COLOR[rareLv], pack.name)
    local rareText = cst.SKILL_RARE_TEXT[rareLv]
    local skillTypeText = '|cffffcc00主动|r'
    if pack.targetType == SKILL_TARGET_PASSIVE then
        skillTypeText = '|cff99ccff00被动|r'
    end
    local title = str.format('%s技能书[%s][%s]', skillName, rareText, skillTypeText)

    -- init model 
    local dummy = CreateItem(itemTypeJ, 0.00, 0.00)
    dbg.handle_ref(dummy)
    RemoveItem(dummy)
    dbg.handle_unref(dummy)

    local description = plainTip

    description = string.gsub(description, '%<([%w_.>]*)%>', convertColor)

    japi.EXSetItemDataString(itemTypeJ, 1, pack.art)
    japi.EXSetItemDataString(itemTypeJ, 2, title)
    japi.EXSetItemDataString(itemTypeJ, 3, tip)
    japi.EXSetItemDataString(itemTypeJ, 4, title)
    japi.EXSetItemDataString(itemTypeJ, 5, description)

    mt.skillbookInfo[itemTypeJ] = pack
    mt.skillPackItemType[pack] = itemTypeJ

    local testList = mt.skillTestList

    for _, testName in ipairs(testList) do
        local makeBook = false

        if pack.name == testName then
            makeBook = true
        end

        if makeBook then
            gdebug('create book template')
            local created = CreateItem(itemTypeJ, -4000, 4000)
            dbg.handle_ref(created)
        end
    end

    pack.itemTypeJ = itemTypeJ
    mt:registerItemTypeCallback(itemTypeJ, mt.useSkillBook)

    mt.itemData[title] = pack

end
--------------------------------------------------------------------------------------
mt.archCollection = {
    [1] = {},
    [2] = {},
    [3] = {},
    [4] = {},
    [5] = {},
}

local collectionScore = {
    [1] = 100,
    [2] = 200,
    [3] = 400,
    [4] = 800,
    [5] = 1400,
    [6] = 2600,
}

--------------------------------------------------------------------------------------
function mt:makeCollection(pack)

    reg:initTableData('collection', pack)
    reg:addToPool(str.format('collectionPool%d', pack.rarity), pack)

    -- register arch
    local rarity = pack.rarity
    local archCollection = mt.archCollection[rarity]
    table.insert(archCollection, pack)
    local archId = #archCollection
    pack.archId = archId
    pack.archName = str.format('collection_%d_%d', rarity, archId)
    pack.score = collectionScore[rarity]

    if rarity >= 5 then
        pack.useHigh = true
        if rarity == 5 then
            reg:addToPool('CollectionS', pack)
        end
    end
    print(str.format('reg collection: %s, archId: %d', pack.name, pack.archId))

    -- if pack.fun then
    --     pack.tip = pack.tip .. str.format('|n|n|cffc0c0c0%s|r', pack.fun)
    --     pack.lockedTip = pack.tip .. str.format('|n|n|cffc0c0c0待发现|r')
    -- end

    local comboInfo = ''
    local comboShort = ''
    local skillName = pack.name

    local tip = fc.makePackTip(pack)

    tip = tip .. '|n|n|cffffcc00左键使用来永久|r|cff00ffff置入藏品背包|r'

    for i = 1, 1 do

        local rareLv = pack.rarity + 1
        if rareLv == 0 then
            print('WARNING - register collection rarelv = 0')
            return
        end

        local itemTypeJ = collectionModels[rarity][archId]
        -- local itemTypeJ = skillModels[rareLv][archId]
        local title = string.format('[%s%s级|r] %s [|cff00ffff藏品装备|r]', cst.EQUIP_RARE_COLOR[rareLv],
            rarityName[rareLv], pack.name)
        local title2 = string.format('[%s%s级|r] %s', cst.EQUIP_RARE_COLOR[rareLv], rarityName[rareLv], pack.name)
        pack.title = title2

        -- init model 
        local dummy = CreateItem(itemTypeJ, 0.00, 0.00)
        dbg.handle_ref(dummy)
        RemoveItem(dummy)
        dbg.handle_unref(dummy)

        local description = tip

        japi.EXSetItemDataString(itemTypeJ, 1, pack.art)
        japi.EXSetItemDataString(itemTypeJ, 2, title)
        japi.EXSetItemDataString(itemTypeJ, 3, tip)
        japi.EXSetItemDataString(itemTypeJ, 4, title)
        japi.EXSetItemDataString(itemTypeJ, 5, description)

        local testList = mt.collectionTestList

        for _, testName in ipairs(testList) do
            local makeBook = false

            if pack.name == testName then
                makeBook = true
            end

            if makeBook then
                local created = CreateItem(itemTypeJ, -7500, 8000)
                dbg.handle_ref(created)
            end
        end

        -- local created = CreateItem(itemTypeJ, -7500, 8000)
        -- dbg.handle_ref(created)

        mt:registerItemTypeCallback(itemTypeJ, itemFunc.useCollection)

        mt.itemTypePack[itemTypeJ] = pack
        pack.itemType = itemTypeJ
        as.dataRegister:initItem(pack)

        -- for _, testPack in ipairs(testList2) do
        --     local makeBook = false

        --     local testName = testPack[1]
        --     local testX = testPack[2]
        --     local testY = testPack[3]

        --     if pack.name == testName then
        --         makeBook = true
        --     end

        --     if makeBook then
        --         local created = CreateItem(itemTypeJ, testX, testY)
        --         dbg.handle_ref(created)
        --     end
        -- end

        -- pack.itemTypeJ = itemTypeJ
        -- mt:registerItemTypeCallback(itemTypeJ, mt.useSkillBook)

    end
end

--------------------------------------------------------------------------------------
local charmStoneCounter = 0
--------------------------------------------------------------------------------------
function mt:makeCharmStone(pack)
    local name = pack.name

    charmStoneCounter = charmStoneCounter + 1
    local itemTypeJ = glo.udg_CharmStoneModel[charmStoneCounter]

    -- init model 
    local dummy = CreateItem(itemTypeJ, 0.00, 0.00)
    dbg.handle_ref(dummy)
    RemoveItem(dummy)
    dbg.handle_unref(dummy)

    local tip = ''
    local statsType = pack.statsType
    local statsVal = pack.statsVal
    if cst:getConstTag(statsType, 'isPct') then
        tip = str.format('%s+%s', cst:getConstName(statsType), as.util:convertPct(statsVal))
    else
        tip = str.format('%s+%.0f', cst:getConstName(statsType), statsVal)
    end
    pack.tip = tip

    japi.EXSetItemDataString(itemTypeJ, 1, pack.icon)
    japi.EXSetItemDataString(itemTypeJ, 2, name)
    japi.EXSetItemDataString(itemTypeJ, 3, pack.tip)
    japi.EXSetItemDataString(itemTypeJ, 4, name)
    japi.EXSetItemDataString(itemTypeJ, 5, pack.tip)

    pack.itemTypeJ = itemTypeJ

    local testList = mt.stoneTestList
    local makeModel = false
    for _, testName in ipairs(testList) do
        if pack.name == testName then
            makeModel = true
        end
        if makeModel then
            local created = CreateItem(itemTypeJ, -7500, 8000)
            dbg.handle_ref(created)
        end
    end

    mt:registerItemTypeCallback(itemTypeJ, itemFunc.useCharmStone)

    mt.itemTypePack[itemTypeJ] = pack
    mt.packItemType[pack] = itemTypeJ

    pack.isCharmStone = true
    as.dataRegister:initItem(pack)

end
--------------------------------------------------------------------------------------
function mt:getItemPack(itemName)
    return mt.itemData[itemName]
end
--------------------------------------------------------------------------------------
function mt:getItemType(itemName)
    if not mt.itemData[itemName] then
        if not itemName then
            error('get no item type: ' .. 'no name')
        else
            error('get no item type: ' .. itemName)
        end

    end

    if mt.itemData[itemName].id == -1 then
        -- gdebug('detect late generate item id' .. itemName)
        local idata = LoadStr(glo.udg_HTItemModel, StringHash('CItem'), StringHash(itemName))
        if idata then
            -- gdebug(idata)
            mt.itemData[itemName].id = idata
        else
            error('late getItemType no item data: ' .. itemName)
        end
    end

    return ID(mt.itemData[itemName].id)
end
--------------------------------------------------------------------------------------
function mt.getpackItemType(pack)
    return mt.packItemType[pack]
end

--------------------------------------------------------------------------------------
function mt:getSkillBookPack(itemTypeJ)
    return mt.skillbookInfo[itemTypeJ]
end
--------------------------------------------------------------------------------------
function mt:getSkillPackItemType(skillPack)
    return mt.skillPackItemType[skillPack]
end

--------------------------------------------------------------------------------------
function mt.useSkillBook(keys)
    local result = 0
    local fail = false
    local msg
    local u = keys.u
    local p = keys.u.owner
    local skillPack = mt:getSkillBookPack(keys.itemTypeJ)

    if not skillPack then
        fail = true
        msg = '技能书无绑定技能'
    end

    if fail then
        as.message.error(p, msg)
        return -1, msg
    end

    -- courier use skillbook
    --------------------------------------------------------------------------------------
    if u.type ~= 'hero' then

        local callback = function(keys)
            keys.keys.u = keys.u
            mt.useSkillBook(keys.keys)
        end

        local keylist = {KEY.Q, KEY.W, KEY.E}

        local box = p.pickBox
        local skillName = skillPack.name
        local heros = p:getHeroList()
        box:clean()
        box:setTitle('选择要学习【' .. skillName .. '】的角色')
        for i, u in ipairs(heros) do
            local tip = u:getNameLv()
            local sk = as.skillManager:getUnitSkill(u, skillName)
            if sk then
                if sk.lv < 5 then
                    tip = tip .. ' （可升级）'
                else
                    tip = tip .. ' （已满级）'
                end

            end

            box:addBtn(tip, callback, {
                keys = keys,
                u = u,
            }, keylist[i])
        end

        box:addBtn('取消', nil, {
            optionId = 0,
        }, KEY.ESC)

        box:showBox()
        return
    end
    --------------------------------------------------------------------------------------

    result, msg = as.skillManager:tryLearnSkill(u, skillPack)

    -- 检测是否使用失败
    if result ~= 1 then
        as.message.error(p, msg)
        return result, msg
    end

    -- 使用成功
    as.message.notice(p, msg)
    keys.item:delete()
    -- RemoveItem(keys.itemJ)

    local eff = {
        model = [[Abilities\Spells\Demon\DarkPortal\DarkPortalTarget.mdl]],
    }
    as.effect:unitEffect(eff, u)

    return result, msg
end

--[[///<summary>物品图标</summary>
    #define ITEM_DATA_ART 1

    ///<summary>物品提示</summary>
    #define ITEM_DATA_TIP 2

    ///<summary>物品扩展提示</summary>
    #define ITEM_DATA_UBERTIP 3

    ///<summary>物品名字</summary>
    #define ITEM_DATA_NAME 4

    ///<summary>物品说明</summary>
    #define ITEM_DATA_DESCRIPTION 5]]

--------------------------------------------------------------------------------------
local tempArt = {}

tempArt[1] = [[ReplaceableTextures\CommandButtons\BTNequip_1.blp]]
tempArt[2] = [[ReplaceableTextures\CommandButtons\BTNequip_2.blp]]
tempArt[3] = [[ReplaceableTextures\CommandButtons\BTNequip_3.blp]]
tempArt[4] = [[ReplaceableTextures\CommandButtons\BTNequip_4.blp]]
tempArt[5] = [[ReplaceableTextures\CommandButtons\BTNequip_5.blp]]
tempArt[6] = [[ReplaceableTextures\CommandButtons\BTNequip_6.blp]]
tempArt[7] = [[ReplaceableTextures\CommandButtons\BTNequip_7.blp]]
tempArt[8] = [[ReplaceableTextures\CommandButtons\BTNequip_8.blp]]
tempArt[9] = [[ReplaceableTextures\CommandButtons\BTNequip_9.blp]]
tempArt[10] = [[ReplaceableTextures\CommandButtons\BTNequip_10.blp]]

--------------------------------------------------------------------------------------
function mt:makeEquip(pack, tag)

    -- closure
    local convertColor = function(name)
        return cst.COLOR_CODE[name]
    end

    -- local plainTip = string.gsub(pack.itemTip, '%<([%w_.>]*)%>', convertColor)

    local tip = Equip:makeEquipTip(pack)

    local rareLv = pack.rare
    local name = pack.name

    mt.equipCounter[rareLv] = (mt.equipCounter[rareLv] or 0) + 1

    local itemTypeJ = equipModels[rareLv][mt.equipCounter[rareLv]]
    local title = string.format('%s [%s%s级装备|r]', pack.name, cst.EQUIP_RARE_COLOR[rareLv], rarityName[pack.rare])

    -- init model 
    local dummy = CreateItem(itemTypeJ, 0.00, 0.00)
    dbg.handle_ref(dummy)
    RemoveItem(dummy)
    dbg.handle_unref(dummy)

    local description = tip

    description = string.gsub(description, '%<([%w_.>]*)%>', convertColor)

    pack.title = title
    pack.detail = tip
    pack.detailNoRoll = Equip:makeEquipTip(pack, true)
    pack.groundTip = pack.detailNoRoll

    -- add reforge func
    -- if rareLv >= 5 then
    --     pack.onUse = itemFunc.reforgeItem
    --     tip = tip .. '|n|n|cff94e9de左键点击以重铸这个装备|r'
    -- end

    japi.EXSetItemDataString(itemTypeJ, 1, tempArt[rareLv])
    japi.EXSetItemDataString(itemTypeJ, 1, pack.art)
    japi.EXSetItemDataString(itemTypeJ, 2, title)
    japi.EXSetItemDataString(itemTypeJ, 3, tip)
    japi.EXSetItemDataString(itemTypeJ, 4, title)
    japi.EXSetItemDataString(itemTypeJ, 5, description)

    -- 设置物品类型模板对应的技能和等级
    local keys = {
        name = pack.name,
    }

    if tag ~= 'noPool' then
        table.insert(mt.equipPool[rareLv], name)
    end

    mt.equipInfo[itemTypeJ] = keys
    pack.itemTypeJ = itemTypeJ

    if rareLv == 10 then
        pack.bCanEat = true
    end

    local testList = mt.equipTestList
    local makeBook = false
    for _, testName in ipairs(testList) do
        if pack.name == testName then

            local data = {
                name = pack.name,
                point = cst.TEST_LOC,
            }
            Equip:makeEquip(data)
        end
    end

end

--------------------------------------------------------------------------------------
function mt:getRandomEquip(rareLv)
    local pool = mt.equipPool[rareLv]
    local name = pool[math.random(#pool)]
    -- gdebug('random equip name: ' .. name)
    return name
end
--------------------------------------------------------------------------------------

function mt:preprocessSkillCombo(skillPack)
    -- as.comboPreprocess:makeComboList(skillPack)
end
--------------------------------------------------------------------------------------
function mt:registerElementCombo(pack)
    local elementType = pack.elementType
    mt.elementCombo[elementType] = pack
end
--------------------------------------------------------------------------------------
function mt:getElementComboPack(elementType)
    return mt.elementCombo[elementType]
end
--------------------------------------------------------------------------------------
function mt:initItem(pack)
    mt.itemData[pack.name] = pack

    if not pack.groundTip then
        pack.groundTip = pack.tip
    end

end
--------------------------------------------------------------------------------------
function mt:registerItemTypeCallback(itemTypeJ, callback)
    mt.itemTypeCallback[itemTypeJ] = callback
end
--------------------------------------------------------------------------------------
function mt:initVisitor(pack)
    local name = pack.name
    setmetatable(pack, Visitor)
    local poolName = str.format('visitor_pool_%d', pack.rare)
    -- gdebug('add body reform pool name: ' .. poolName)
    reg:addToPool(poolName, pack)
    fc.setAttr('visitor_pack', name, pack)
end
--------------------------------------------------------------------------------------
return mt
