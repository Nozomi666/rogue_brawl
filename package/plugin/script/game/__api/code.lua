local mt = {}

--------------------------------------------------------------------------------------
function code.onPlayerPressD(playerId, mouseX, mouseY)

    if glo.udg_PBAJ[playerId] then
        gdebug('按键屏蔽触发')
        return
    end
    local player = as.player:getPlayerById(playerId)
    local lastPick = player.lastPick
    local hero = player.hero

    if lastPick == hero then
        local dashSkill = hero:getSkill('突进')
        if dashSkill then
            dashSkill:onKeyDown(mouseX, mouseY)
        end
    end

end
--------------------------------------------------------------------------------------
function code.toggleStatsDetail(isShow)
    -- local func
    -- if isShow then
    --     GUI.StatsDetailPanel:update()
    --     GUI.StatsDetailPanel:show()
    -- else
    --     GUI.StatsDetailPanel:hide()
    -- end

    if GUI.StatsDetailPanel.is_show then
        glo.udg_blockScroll[fc.getLocalPlayer().id] = false
        GUI.StatsDetailPanel:hide()
    else
        glo.udg_blockScroll[fc.getLocalPlayer().id] = true
        GUI.StatsDetailPanel:update()
        GUI.StatsDetailPanel:show()
    end

end
--------------------------------------------------------------------------------------
function code.pressF2(pJ)
    local p = as.player:pj2t(pJ)
    local hero = p.hero
    if hero then
        hero:tpBack()
    end
end
--------------------------------------------------------------------------------------
function code.pressF4(pJ)
    local p = as.player:pj2t(pJ)
    if p:isLocal() then
        GUI.archComprehensiveBtn:onClick()
    end
end
--------------------------------------------------------------------------------------
function code.pressF7(pJ)
    local p = as.player:pj2t(pJ)
    if p:isLocal() then
        GUI.gameSettingBtn:onClick()
    end
end
--------------------------------------------------------------------------------------
function code.playerLeaveGame(pJ)
    local p = as.player:pj2t(pJ)
    p:leaveGame()
end
--------------------------------------------------------------------------------------
function code.guoqingTrigger(pJ, cmdId)
    local player = as.player:pj2t(pJ)

    local shardGet = player:getSimpleArch(INT_STORAGE.OCTOBER_SHARD_GET)
    local shardUsed = player:getSimpleArch(INT_STORAGE.OCTOBER_SHARD_USED)
    gdebug('shardGet: ', shardGet)
    gdebug('shardUsed: ', shardUsed)
    local itemName, itemPrice
    if cmdId == 0 then
        msg.notice(player, str.format('剩余灯笼数量: %d', shardGet - shardUsed))
        return
    end
    if cmdId == 1 then
        itemName = '中国结'
        itemPrice = 20
    elseif cmdId == 2 then
        itemName = '小红旗'
        itemPrice = 40
    elseif cmdId == 3 then
        itemName = '礼盒'
        itemPrice = 20
    elseif cmdId == 4 then
        itemName = '伴手礼'
        itemPrice = 40
    elseif cmdId == 5 then
        itemName = '小礼炮'
        itemPrice = 80
    end

    if player:hasArch(itemName) then
        msg.error(player, '你已经拥有这个物品了')
        return
    end

    if shardGet - shardUsed < itemPrice then
        msg.error(player, '灯笼数量不足')
        return
    end

    player:modSimpleArch(INT_STORAGE.OCTOBER_SHARD_USED, itemPrice)
    player:tryUnlockArch(itemName)
    msg.notice(player, str.format('购买成功, 花费%d灯笼', itemPrice))


end
--------------------------------------------------------------------------------------

return mt
