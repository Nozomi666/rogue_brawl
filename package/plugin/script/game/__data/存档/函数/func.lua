local RewardList = require 'game.__data.存档.函数.reward_list'
local mt = {}
archFunc = mt
--------------------------------------------------------------------------------------
function mt.encapShopItem(pack)
    if pack.alreadyEncaped then
        return
    end
    pack.alreadyEncaped = true

    if pack.storeItemType == STORE_ITEM_TYPE_NB then
        pack.score = pack.score * 2
    end
    
    pack.bStoreItem = true
    pack.hideUnlockHint = true
    pack.unlockHint = [[解锁相应商城道具]]
    if pack.unlockHintOverride then
        pack.unlockHint = pack.unlockHintOverride
    end
    --------------------------------------------------------------------------------------

    if not pack.typeFree then

        local customFunc = pack.onActivate
        pack.onActivate = function(p, val)

            local canActivate = archFunc.checkStoreValid(p, pack)
            if canActivate then
                customFunc(p, val)

                local storeManager = p.storeManager
                if pack.score then
                    storeManager:modScore(pack.score)
                end

                if pack.rmbScore then
                    storeManager:modRMBScore(pack.rmbScore)
                end

            end

        end

        pack.condition = function(p)
            return archFunc.checkStoreValid(p, pack)
        end

    end

end
--------------------------------------------------------------------------------------
function mt.checkStoreValid(p, pack)
    if (not p) or (not pack) then
        print('error - checkStoreValid')
        return false
    end

    if mt.identifyFullStore(p) then
        return true
    end

    if mt.identifyStoreGift(p, pack.name) then
        return true
    end

    local storeKey = pack.storeKey
    local pj = p.handle

    if not storeKey then
        return false
    end

    if MAP_DEBUG_MODE then
        if test.testStoreItemList[pack.name] then
            print('p has store item (test)' .. pack.name)
            return true
        end
    end


    if test.closeCheckStore then
        return true
    end

    if code.hasMallItem(pj, storeKey) then
        return true
    end

    return false
end
--------------------------------------------------------------------------------------
function mt.getStoreCount(p, pack)

    if not p then
        archlog('error - getStoreCount fail, no player')
        return 0
    end

    if not pack then
        archlog('error - getStoreCount fail, no pack')
        return 0
    end

    local markedVal = fc.getAttr(p, pack.name)
    if markedVal then
        return markedVal
    end

    local storeKey = pack.storeKey
    local pj = p.handle
    local amt

    if not pack.bStackable then
        local hasItem = mt.checkStoreValid(p, pack)
        if hasItem then
            amt = 1
        else
            amt = 0
        end
        goto continue
    end

    amt = code.getMallItemCount(pj, storeKey)

    if MAP_DEBUG_MODE then
        if test.testStoreItemList[pack.name] then
            amt = test.testStoreItemList[pack.name]
            print('p has stack store item (test)' .. amt)
        end
    end

    if pack.name == '藏宝密匣' and (p:getPlatformName() == '彼方天际#6344' or p:getPlatformName() == 'WorldEdit') then
        amt = amt + 15
    end

    if mt.identifyFullArch(p) then
        amt = amt + 99
    end

    ::continue::

    archlog(str.format('p id: %d, storeKey: %s, num: %d', p.id, storeKey, amt))

    fc.setAttr(p, pack.name, amt)
    return amt
end
--------------------------------------------------------------------------------------
function mt.checkShine(p, pack)

    if (not p) or (not pack) then
        print('error - checkShine')
        return 0
    end

    local lv = pack.lv
    local need = cst.SHINE_REWARD_REQ[lv]
    local have = p.storeManager:getScore()

    -- gdebug(str.format('check shine %d, need: %d, have: %d', lv, need, have))

    return have >= need
end
--------------------------------------------------------------------------------------
function mt.checkLoot(p, pack)

    if (not p) or (not pack) then
        print('error - checkLoot')
        return 0
    end

    local lv = pack.lv
    local need = cst.LOOT_REWARD_REQ[lv]
    local have = p:getSimpleArch(cst.ARCH_LOOTNUM)

    -- gdebug(str.format('check shine %d, need: %d, have: %d', lv, need, have))

    return have >= need
end
--------------------------------------------------------------------------------------
local className = [[Mvp家族]]
reg:addToPool('guildClass', className)
for i = 1, 30 do
    local guildName = str.format('Mvp丶家族%d号', i)
    reg:addToPool(className, guildName)
end

reg:addToPool(className, [[直播粉丝公会]])
--------------------------------------------------------------------------------------
local className = [[Mvp苍穹团]]
reg:addToPool('guildClass', className)
for i = 1, 5 do
    local guildName = str.format('Mvp丶苍穹团%d号', i)
    reg:addToPool(className, guildName)
end

reg:addToPool(className, [[三清]])
--------------------------------------------------------------------------------------
local className = [[主播公会]]
reg:addToPool('guildClass', className)

reg:addToPool(className, [[直播粉丝公会]])
reg:addToPool(className, [[三清]])
reg:addToPool(className, [[魔域主播公会]])
reg:addToPool(className, [[良心主播公会]])
--------------------------------------------------------------------------------------
local className = [[北斗公会]]
reg:addToPool('guildClass', className)

reg:addToPool(className, [[天玑团]])
reg:addToPool(className, [[玉衡团]])
reg:addToPool(className, [[摇光团]])
reg:addToPool(className, [[开阳团]])
reg:addToPool(className, [[北斗七星]])
reg:addToPool(className, [[天权团]])
reg:addToPool(className, [[天璇团]])
reg:addToPool(className, [[贪狼团]])
reg:addToPool(className, [[破军团]])
--------------------------------------------------------------------------------------
local className = [[星悦公会]]
reg:addToPool('guildClass', className)

reg:addToPool(className, [[星悦会员俱乐部]])
reg:addToPool(className, [[星悦俱乐部]])
reg:addToPool(className, [[星悦会员公会]])
reg:addToPool(className, [[天天会员俱乐部]])
reg:addToPool(className, [[天天俱乐部]])
reg:addToPool(className, [[天天星悦俱乐部]])
reg:addToPool(className, [[星悦vip福利公会]])
reg:addToPool(className, [[星悦星享事成公会]])
reg:addToPool(className, [[星悦星享福利公会]])
reg:addToPool(className, [[天天星悦公会]])
--------------------------------------------------------------------------------------
local className = [[超级星悦公会]]
reg:addToPool('guildClass', className)

reg:addToPool(className, [[超级星悦公会]])
reg:addToPool(className, [[超级星悦家庭]])
reg:addToPool(className, [[超级星悦集团]])
--------------------------------------------------------------------------------------
local className = [[满赞公会]]
reg:addToPool('guildClass', className)

reg:addToPool(className, [[五只小灵]])

--------------------------------------------------------------------------------------
function mt.getPlayerGuildClass(p)
    local pGuildClass = p:getAttr('guildClass')

    if pGuildClass then
        return pGuildClass
    end

    local pGuildName = code.getGuildName(p.handle)
    gdebug(str.format('get player guild name: %s', pGuildName))

    for _, guildClass in ipairs(reg:getPool('guildClass')) do
        for _, guildName in ipairs(reg:getPool(guildClass)) do
            -- gdebug('check guild name: ' .. guildName)
            if pGuildName == guildName then
                p:setAttr('guildClass', guildClass)
                return guildClass
            end
        end
    end

    local emptyClass = [[无公会]]
    p:setAttr('guildClass', emptyClass)
    return emptyClass
end
--------------------------------------------------------------------------------------
function mt.checkGuild(p, pack)

    if (not p) or (not pack) then
        print('error - checkGuild')
        return 0
    end

    local guildClass = pack.name
    local playerGuild = code.getGuildName(p.handle)
    local pGuildClass = mt.getPlayerGuildClass(p)

    gdebug(str.format('check guild class: %s, %s', pGuildClass, guildClass))

    return pGuildClass == guildClass

end
--------------------------------------------------------------------------------------
local fullStoreVIP = {
    [1] = '荀公子',
    [2] = '魔域主播公会#1159',
    [3] = 'G键失灵',
    [4] = '牛大壮锄大地#4653',
    [5] = 'M1yanagaTeru',
    [6] = 'Aquarius1996',
    [7] = 'WorldEdit1',
    [8] = '风痕丶#1254',
    [9] = '深渊之灾祸#7807',
    -- [10] = 'WorldEdit',
}
--------------------------------------------------------------------------------------
function mt.isVIP(p)
    if p:getAttr('是内部人员') then
        return p:getAttr('是内部人员') == '是'
    end

    local pass = false

    for i, vipName in ipairs(fullStoreVIP) do
        -- if str.format('%s ', vipName) == p:getRawUdgName() then
        --     msg.notice(p, 'special player: full store vip is activated.')
        --     pass = true
        -- end

        if vipName == p:getPlatformName() then
            msg.notice(p, 'special player: full store vip is activated.')
            pass = true
        end
    end

    if pass then
        p:setAttr('是内部人员', '是')
    else
        p:setAttr('是内部人员', '否')
    end

    return pass

end
--------------------------------------------------------------------------------------
function mt.identifyFullArch(p)
    if p:getAttr('满档通过') then
        return p:getAttr('满档通过') == '是'
    end

    local pass = false

    if mt.isVIP(p) then
        pass = true
    end

    -- if p:getRawUdgName() == 

    if pass then
        p:setAttr('满档通过', '是')
    else
        p:setAttr('满档通过', '否')
    end

    return pass
end
--------------------------------------------------------------------------------------
function mt.identifyFullStore(p)

    if p:getAttr('满赞通过') then
        return p:getAttr('满赞通过') == '是'
    end

    local pass = false

    if mt.getPlayerGuildClass(p) == '满赞公会' then
        pass = true
    end

    if mt.isVIP(p) then
        pass = true
    end

    -- if p:getRawUdgName() == 

    if pass then
        p:setAttr('满赞通过', '是')
    else
        p:setAttr('满赞通过', '否')
    end

    return pass
end
--------------------------------------------------------------------------------------
function mt.identifyStoreGift(p, archName)

    -- gdebug('检测商城礼物：%s', archName)

    local attrKey = str.format('%s通过', archName)

    if p:getAttr(attrKey) then
        return p:getAttr(attrKey) == '是'
    end

    local pass = false

    if RewardList.playerHasStoreGift(p, archName) then
        pass = true
    end

    if pass then
        p:setAttr(attrKey, '是')
    else
        p:setAttr(attrKey, '否')
    end

    return pass

end

--------------------------------------------------------------------------------------

return mt
