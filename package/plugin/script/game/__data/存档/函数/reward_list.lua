require 'game.__data.存档.函数.1_内测'
require 'game.__data.存档.函数.2_商城'
require 'game.__data.存档.函数.3_满赞'
require 'game.__data.存档.函数.4_福利'
require 'game.__data.存档.函数.5_特殊'

--------------------------------------------------------------------------------------
local rewardTypeId = {
    ['小凤凰'] = {}
}
--------------------------------------------------------------------------------------
local list = rewardTypeId['小凤凰']
list['12345678'] = true
--------------------------------------------------------------------------------------
-- 主播福利
ANCHOR_PLAYER_LIST = {}
local list = ANCHOR_PLAYER_LIST
-- list[str.format('%s ', 'WorldEdit')] = true
-- list[str.format('%s ', '大圣归来丶')] = true
-- list[str.format('%s ', '薙切绘里奈丶')] = true
-- list[str.format('%s ', '嗜血残忍小乳猪')] = true
-- list[str.format('%s ', '半神亦半仙')] = true

--------------------------------------------------------------------------------------
-- 英雄碎片补正
HERO_FRAG_FIX_PLAYER_LIST = {}
local list = HERO_FRAG_FIX_PLAYER_LIST
list[str.format('%s ', 'WorldEdit')] = true
list[str.format('%s ', '顾大叔')] = true
list[str.format('%s ', '吉川春代')] = true

--------------------------------------------------------------------------------------
local mt = {}
--------------------------------------------------------------------------------------
function mt.playerHasStoreGift(p, archName)
    local pass = false

    gdebug('check playerHasStoreGift player: %s, archName: %s', p:getName(), archName)

    local list = SHOT_GIFT_LIST[archName]
    if list then
        -- if list[str.format('%s', p:getRawUdgName())] then
        --     gdebug('new reward check name pass player: %s, archName: %s', p:getName(), archName)
        --     pass = true
        -- end

        if list[p:getPlatformName()] then
            gdebug('new reward check name pass player: %s, archName: %s', p:getName(), archName)
            pass = true
        end

    end

    local list = SHOT_GIFT_LIST_ID[archName]
    if list then
        if list[str.format('%s', p:getPlatformId())] then
            gdebug('new reward check id pass')
            pass = true
        end
    end

    local archPack = reg:getTableData('archData', archName)
    if archPack then
        if archPack.storeItemType == STORE_ITEM_TYPE_NB and archPack.storeKey ~= 'NBOFF' then
            local list = ALL_NB_PLAYER_LIST
            if list[p:getPlatformName()] then
                gdebug('nb item pass player: %s, archName: %s', p:getName(), archName)
                pass = true
                if archPack.noWelfareUnlock then
                    if p:getPlatformName() == '彼方天际#6344' or p:getPlatformName() == '快乐的养猪佬#9441' then
                        
                    else
                        pass = false
                    end
                end
            end

            local list = ALL_NB_PLAYER_ID_LIST
            if list[str.format('%s', p:getPlatformId())] then
                gdebug('nb item pass player: %s, by platform id', p:getName())
                pass = true
                if archPack.noWelfareUnlock then
                    if p:getPlatformName() == '彼方天际#6344' or p:getPlatformName() == '快乐的养猪佬#9441' then
                        
                    else
                        pass = false
                    end
                end
            end

        end

        if archPack.storeItemType == STORE_ITEM_TYPE_UR and archPack.storeKey ~= 'NBOFF' then
            gdebug('check ur item: ' .. archName)
            local list = ALL_UR_PLAYER_LIST
            if list[p:getPlatformName()] then
                gdebug('ur item pass player: %s, archName: %s', p:getName(), archName)
                pass = true
                if archPack.noWelfareUnlock then
                    if p:getPlatformName() == '彼方天际#6344' or p:getPlatformName() == '快乐的养猪佬#9441' then
                        
                    else
                        pass = false
                    end
                end
            end

        end

        if archPack.storeItemType == STORE_ITEM_TYPE_SSR and archPack.storeKey ~= 'NBOFF' then
            gdebug('check ur item: ' .. archName)
            local list = ALL_SSR_PLAYER_LIST
            if list[p:getPlatformName()] then
                gdebug('ur item pass player: %s, archName: %s', p:getName(), archName)
                pass = true
                if archPack.noWelfareUnlock then
                    if p:getPlatformName() == '彼方天际#6344' or p:getPlatformName() == '快乐的养猪佬#9441' then
                        
                    else
                        pass = false
                    end
                end
            end

        end

        if archPack.pointItem == STORE_ITEM_TYPE_POINT and archPack.storeKey ~= 'NBOFF' then
            gdebug('check ur item: ' .. archName)
            local list = ALL_POINT_PLAYER_LIST
            if list[p:getPlatformName()] then
                gdebug('ur item pass player: %s, archName: %s', p:getName(), archName)
                pass = true
                if archPack.noWelfareUnlock then
                    if p:getPlatformName() == '彼方天际#6344' or p:getPlatformName() == '快乐的养猪佬#9441' then
                        
                    else
                        pass = false
                    end
                end
            end

        end

        if archPack.inChest2 and archPack.storeKey ~= 'NBOFF' then
            -- gdebug('check inChest2 item: '.. archName)
            local list = ALL_CHEST_2_PLAYER_LIST
            if list[p:getPlatformName()] then
                gdebug('chest2 item pass player: %s, archName: %s', p:getName(), archName)
                pass = true

                if archPack.noWelfareUnlock then
                    if p:getPlatformName() == '彼方天际#6344' or p:getPlatformName() == '快乐的养猪佬#9441' then
                        
                    else
                        pass = false
                    end
                end
            end
        end

        if archPack.inChest2 and archPack.storeKey ~= 'NBOFF' then
            -- gdebug('check inChest2 item: '.. archName)
            local list = ALL_CHEST_2_PLAYER_ID_LIST
            if list[str.format('%s', p:getPlatformId())] then
                gdebug('chest2 item pass player: %s, archName: %s', p:getName(), archName)
                pass = true
            end
        end
    end

    if archName == [[屠魔手套]] then
        local list = TUMO_PLAYER_LIST
        if list[p:getPlatformName()] then
            gdebug('ur item pass player: %s, archName: %s', p:getName(), archName)
            pass = true
        end
    end

    if archName == [[闪耀之剑]] then
        local list = SHANYAO_SWORD_PLAYER_LIST
        if list[p:getPlatformName()] then
            gdebug('ur item pass player: %s, archName: %s', p:getName(), archName)
            pass = true
        end
    end

    if archName == [[心灵法杖]] then
        local list = XINLING_PLAYER_LIST
        if list[p:getPlatformName()] then
            gdebug('ur item pass player: %s, archName: %s', p:getName(), archName)
            pass = true
        end
    end

    if archName == [[能量齿轮]] then
        local list = NENGLIANG_PLAYER_LIST
        if list[p:getPlatformName()] then
            gdebug('ur item pass player: %s, archName: %s', p:getName(), archName)
            pass = true
        end
    end

    if archName == [[术士手册]] then
        local list = SHUSHI_PLAYER_LIST
        if list[p:getPlatformName()] then
            gdebug('ur item pass player: %s, archName: %s', p:getName(), archName)
            pass = true
        end
    end

    return pass
end
--------------------------------------------------------------------------------------

return mt
--------------------------------------------------------------------------------------
