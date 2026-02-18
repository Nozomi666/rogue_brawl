local mt = {}
as.msg = mt
local DEFAUTL_TIME = 10
local ARCH_TIME = 30

--------------------------------------------------------------------------------------
function mt.error(p, msg, time)
    if not p then
        return
    end

    time = time or DEFAUTL_TIME
    msg = string.format('|cffff8080错误：|r%s', msg)
    -- DisplayTimedTextToPlayer(p.handle, 0, 0, time, msg)

    GUI.GameMessage:newMessage(MESSAGE_TYPE_ERROR, p, msg, time)

end
--------------------------------------------------------------------------------------
function mt.warning(p, msg, time)
    if not p then
        return
    end

    time = time or 30
    msg = string.format('|cffff0000警告：|r%s', msg)
    if p == cst.ALL_PLAYERS then
        for i = 1, 4 do
            local p2 = as.player:getPlayerById(i)
            -- DisplayTimedTextToPlayer(p2.handle, 0, 0, time, msg)
        end
    else
        -- DisplayTimedTextToPlayer(p.handle, 0, 0, time, msg)
    end

    GUI.GameMessage:newMessage(MESSAGE_TYPE_WARNNING, p, msg, time)

end
--------------------------------------------------------------------------------------
function mt.notice(p, msg, time)
    if not p then
        return
    end

    time = time or DEFAUTL_TIME
    msg = string.format('|cffffcc00提示：|r%s', msg)

    if p == cst.ALL_PLAYERS then
        for i = 1, 4 do
            local p2 = as.player:getPlayerById(i)
            -- DisplayTimedTextToPlayer(p2.handle, 0, 0, time, msg)
        end
    else
        -- DisplayTimedTextToPlayer(p.handle, 0, 0, time, msg)
    end

    GUI.GameMessage:newMessage(MESSAGE_TYPE_NOTICE, p, msg, time)

end
--------------------------------------------------------------------------------------
function mt.arch(p, msg, time)
    if not p then
        return
    end

    time = time or ARCH_TIME
    msg = string.format('|cff00ffd5存档：|r%s', msg)

    if p == cst.ALL_PLAYERS then
        for i = 1, 4 do
            local p2 = as.player:getPlayerById(i)
            -- DisplayTimedTextToPlayer(p2.handle, 0, 0, time, msg)
        end
    else
        -- DisplayTimedTextToPlayer(p.handle, 0, 0, time, msg)
    end

    GUI.GameMessage:newMessage(MESSAGE_TYPE_ARCH, p, msg, time)

end
--------------------------------------------------------------------------------------
function mt.reward(p, msg, time)
    if not p then
        return
    end

    time = time or DEFAUTL_TIME
    msg = string.format('|cffd1ff05奖励：|r%s', msg)

    if p == cst.ALL_PLAYERS then
        for i = 1, 4 do
            local p2 = as.player:getPlayerById(i)
            -- DisplayTimedTextToPlayer(p2.handle, 0, 0, time, msg)
        end
    else
        -- DisplayTimedTextToPlayer(p.handle, 0, 0, time, msg)
    end

    GUI.GameMessage:newMessage(MESSAGE_TYPE_REWARD, p, msg, time)

end
--------------------------------------------------------------------------------------
local rareText = {
    [1] = '（|cffffffff普通|r）',
    [2] = '（|cff94cf6c稀有|r）',
    [3] = '（|cff00ccff罕见|r）',
    [4] = '（|cffcc99ff史诗|r）',
    [5] = '（|cffFF9705传说|r）',
}
--------------------------------------------------------------------------------------
function mt.rareReward(p, msg, rare)
    if not p then
        return
    end

    local time = DEFAUTL_TIME
    msg = string.format('%s%s', rareText[rare], msg)

    if p == cst.ALL_PLAYERS then
        for i = 1, 4 do
            local p2 = as.player:getPlayerById(i)
            -- DisplayTimedTextToPlayer(p2.handle, 0, 0, time, msg)
        end
    else
        -- DisplayTimedTextToPlayer(p.handle, 0, 0, time, msg)
    end

    GUI.GameMessage:newMessage(MESSAGE_TYPE_NOTICE, p, msg, time)
end
--------------------------------------------------------------------------------------
function mt.send(p, msg, time)
    if not p then
        return
    end

    time = time or DEFAUTL_TIME
    msg = msg

    if p == cst.ALL_PLAYERS then
        for i = 1, 4 do
            local p2 = as.player:getPlayerById(i)
            -- DisplayTimedTextToPlayer(p2.handle, 0, 0, time, msg)
        end
    else
        -- DisplayTimedTextToPlayer(p.handle, 0, 0, time, msg)
    end

    GUI.GameMessage:newMessage(MESSAGE_TYPE_NOTICE, p, msg, time)
end
--------------------------------------------------------------------------------------

return mt
