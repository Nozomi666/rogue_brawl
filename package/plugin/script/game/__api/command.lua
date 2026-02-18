local util = require 'ac.utility'

local mt = {}
mt.__index = mt

--------------------------------------------------------------------------------------
function mt:effoff(keys)
    local p = keys.p
    -- p.effectOptmize = true
    p.closeAllEffect = true

    as.message.notice(p, '部分特效已关闭。')
end

--------------------------------------------------------------------------------------
function mt:effon(keys)
    local p = keys.p
    -- p.effectOptmize = false
    p.closeAllEffect = false

    as.message.notice(p, '全部特效已开启。')
end
--------------------------------------------------------------------------------------
function mt:pureon(keys)
    local p = keys.p
    p.closeAllEffect = true
    p.flowtextOff = true
    as.message.notice(p, '纯净模式已开启。')
end
--------------------------------------------------------------------------------------
function mt:pureoff(keys)
    local p = keys.p
    p.closeAllEffect = false
    p.flowtextOff = false
    as.message.notice(p, '纯净模式已关闭。')
end
--------------------------------------------------------------------------------------
function mt:autocast(keys)
    local p = keys.p
    local time = tonumber(keys.args[1])
    if not time then
        str.format('设定自动施法禁用时间失败，未指定禁用时长。')
    end

    time = math.clamp(time, 0, 30)
    p.autocastDelay = time
    msg.notice(p,
        str.format('成功将每回合的自动施法禁用时间设定为[%s%d|r]秒（下回合生效）',
            cst.COLOR_YELLOW, time))

end
--------------------------------------------------------------------------------------
function mt:qqunReward(keys)
    local p = keys.p
    p:tryUnlockArch('加群礼包')
end
--------------------------------------------------------------------------------------
function mt:ttrpgReward(keys)
    local p = keys.p
    p:tryUnlockArch('公众号礼包')
end
--------------------------------------------------------------------------------------
function mt:buchangReward(keys)
    local p = keys.p
    if TESTING_SERVER then
        p:tryUnlockArch('补偿礼包4-5')
    end
end
--------------------------------------------------------------------------------------
function mt:buchang2Reward(keys)
    local p = keys.p
    if TESTING_SERVER then
        p:tryUnlockArch('补偿礼包4-7')
    end
end
--------------------------------------------------------------------------------------
function mt:buchang3Reward(keys)
    local p = keys.p
    if TESTING_SERVER then
        p:tryUnlockArch('补偿礼包4-8')
    end
end
--------------------------------------------------------------------------------------
function mt:buchang4Reward(keys)
    local p = keys.p
    if TESTING_SERVER then
        p:tryUnlockArch('补偿礼包4-10')
    end
end
--------------------------------------------------------------------------------------
function mt:buchang5Reward(keys)
    local p = keys.p
    if TESTING_SERVER then
        p:tryUnlockArch('补偿礼包4-16')
    end
end
--------------------------------------------------------------------------------------
function mt:buchang6Reward(keys)
    local p = keys.p
    if TESTING_SERVER then
        p:tryUnlockArch('补偿礼包4-16V2')
    end
end
--------------------------------------------------------------------------------------
function mt:buchang425Reward(keys)
    local p = keys.p
    p:tryUnlockArch('补偿礼包4-25')
end
--------------------------------------------------------------------------------------
function mt:buchang4252Reward(keys)
    local p = keys.p
    p:tryUnlockArch('补偿礼包4-25-2')
end
--------------------------------------------------------------------------------------
function mt:fuli(keys)
    local p = keys.p
    p:tryUnlockArch('补偿礼包4-25')
    p:tryUnlockArch('补偿礼包4-25-2')
    p:tryUnlockArch('科技点福利')
end
--------------------------------------------------------------------------------------
function mt:fish(keys)
    local p = keys.p
    msg.notice(p, '当前钓鱼积分: ' .. p:getSimpleArch(INT_STORAGE.DIAOYUSCORE) ..
        str.format('\n今日获取钓鱼积分：%d/%d', p:getSimpleArch(INT_STORAGE.DIAOYUSCORE_DAY), MAX_DAY_DY_SCORE))
    msg.notice(p, '当前答题积分: ' .. p:getSimpleArch(INT_STORAGE.JINLISCORE) ..
        str.format('\n今日获取答题积分：%d/%d', p:getSimpleArch(INT_STORAGE.JINLISCORE_DAY), MAX_DAY_DY_SCORE))
end
--------------------------------------------------------------------------------------
function mt:KKReward(keys)
    local p = keys.p
    gdebug('try activate: ' .. 'KK公众号礼包')
    p:tryUnlockArch('KK公众号礼包')
end
--------------------------------------------------------------------------------------
function mt:myid(keys)
    local p = keys.p
    msg.notice(p, str.format('你的平台id为[%s]', p:getPlatformId()))
end
--------------------------------------------------------------------------------------
local testAllowList = {
    ['风痕丶 '] = true,
    ['牛大壮锄大地 '] = true,
    ['深渊之灾祸 '] = true,
    ['魔域主播公会 '] = true,
    ['望舒河 '] = true,
    ['开心超人 '] = true,
    ['巴鲁托 '] = true,
    ['老肥 '] = true,
    ['Zero '] = true,
    ['zero '] = true,
}
--------------------------------------------------------------------------------------
function mt:setTestMode(keys)
    if localEnv then
        MAP_DEBUG_MODE = true
        msg.notice(cst.ALL_PLAYERS, '测试模式已开启。')
    else
        local p = keys.p
        if testAllowList[p:getRawUdgName()] then
            MAP_DEBUG_MODE = true
            msg.notice(cst.ALL_PLAYERS, '测试模式已开启。')
        end
    end
end
--------------------------------------------------------------------------------------
function mt:clearArch(keys)
    local p = keys.p
    local box = p.pickBox
    box:clean()
    box:setTitle('清空哪个存档')

    local callBackClearCollectShard = function(keys)
        p:setSimpleArch(INT_STORAGE.COLLECT_SHARD, 0)
        p:setSimpleArch(INT_STORAGE.COLLECT_SHARD_DAY_MAX, 0)
    end

    local callBackClearCrystal = function(keys)
        p:setSimpleArch(INT_STORAGE.OUTFIT_SHARD, 0)
        p:setSimpleArch(INT_STORAGE.COLLECT_SHARD_DAY_MAX, 0)
        p:setSimpleArch(INT_STORAGE.OUTFIT_EXCHANGE_1_DAY, 0)
        p:setSimpleArch(INT_STORAGE.OUTFIT_EXCHANGE_2_DAY, 0)
    end

    local YXHYD = function(keys)
        p:setSimpleArch(INT_STORAGE.ACTIVITY_EXP, 0)
    end

    local hero = function(keys)
        p:setSimpleArch(INT_STORAGE.HERO_FRAG_R, 0)
        p:setSimpleArch(INT_STORAGE.HERO_FRAG_SR, 0)
        p:setSimpleArch(INT_STORAGE.HERO_FRAG_SSR, 0)
        p:setSimpleArch(INT_STORAGE.HERO_EXCHANGE_FRAG_SR, 0)
        p:setSimpleArch(INT_STORAGE.HERO_EXCHANGE_FRAG_SSR, 0)
    end

    box:addBtn('清空全部藏品碎片', callBackClearCollectShard, {
        entryId = 1,
    }, nil)

    box:addBtn('清空晶石', callBackClearCrystal, {
        entryId = 2,
    }, nil)

    box:addBtn('清空游戏活跃度', YXHYD, {
        entryId = 3,
    }, nil)

    box:addBtn('清空英雄碎片', hero, {
        entryId = 4,
    }, nil)

    local onLineTime = function(keys)
        p:setSimpleArch(INT_STORAGE.ONLINE_TIME_60MIN_COUNT, 0)
    end

    box:addBtn('清空在线60分钟天数', hero, {
        entryId = 5,
    }, nil)

    local boss = function(keys)
        p:setSimpleArch(INT_STORAGE.KILL_BOSS_TOTAL, 0)
    end

    box:addBtn('清空杀死BOSS总次数', hero, {
        entryId = 6,
    }, nil)

    local winGameTotal = function(keys)
        p:setSimpleArch(INT_STORAGE.WIN_COUNT_TOTAL, 0)
    end

    box:addBtn('清空通关次数', hero, {
        entryId = 7,
    }, nil)

    box:addBtn('取消', nil, nil, KEY.ESC)

    box:showBox()
end
--------------------------------------------------------------------------------------
function mt:clearArch2(keys)
    local p = keys.p
    local box = p.pickBox
    box:clean()
    box:setTitle('清空哪个存档')

    local clearUnixDay = function(keys)
        p:setSimpleArch(INT_STORAGE.UNIX_DAY, gm.gameUnixDay)
    end

    box:addBtn('清空天数统计', clearUnixDay, {
        entryId = 1,
    }, nil)

    box:addBtn('取消', nil, nil, KEY.ESC)

    box:showBox()
end
--------------------------------------------------------------------------------------
function mt:hideLose(keys)
    local p = keys.p
    p.hideLose = true
    as.message.notice(p, '游戏失败不再弹窗提示。')
end
--------------------------------------------------------------------------------------
function mt:clearHeroFrag(keys)
    local p = keys.p
    local box = p.pickBox
    box:clean()
    box:setTitle('是否清除英雄碎片')

    local callbackEndless = function(keys)
        p:setSimpleArch(INT_STORAGE.HERO_FRAG_SR, 0)
        p:setSimpleArch(INT_STORAGE.HERO_FRAG_SSR, 0)
        p:setSimpleArch(INT_STORAGE.HERO_FRAG_R, 0)
        p:setSimpleArch(INT_STORAGE.HERO_EXCHANGE_FRAG_SR, 0)
        p:setSimpleArch(INT_STORAGE.HERO_EXCHANGE_FRAG_SSR, 0)
    end
    box:addBtn('确认', callbackEndless, {
        entryId = 1,
    }, KEY.ENTER)

    box:addBtn('取消', nil, nil, KEY.ESC)

    box:showBox()
end
--------------------------------------------------------------------------------------
function mt:resetarch(keys)
    local p = keys.p
    -- if not p.cheatArch then
    --     return
    -- end

    -- local confirmFunc2 = function(keys)
    --     p.archManager:clearArchs()
    --     msg.notice(p, '存档已清除。')

    -- end

    -- local confirmFunc1 = function(keys)
    --     local box = p.pickBox
    --     box:clean()
    --     box:setTitle(str.format('再次确定要清除存档？（操作不可逆）'))
    --     box:addBtn('否', nil, {}, cst.PICK_BOX_HOT_KEY.NULL)
    --     box:addBtn('是', confirmFunc2, {}, cst.PICK_BOX_HOT_KEY.NULL)
    -- end

    -- local box = p.pickBox
    -- box:clean()
    -- box:setTitle(str.format('确定要清除存档？（操作不可逆）'))
    -- box:addBtn('是', confirmFunc1, {}, cst.PICK_BOX_HOT_KEY.NULL)
    -- box:addBtn('否', nil, {}, cst.PICK_BOX_HOT_KEY.NULL)

end
--------------------------------------------------------------------------------------
function mt:checkAfk(keys)
    local p = keys.p

    for _, checkP in ipairs(fc.getAlivePlayers()) do

        local checkPName = checkP:getName()
        -- if checkP ~= p then
        if true then
            local afkCount = checkP.afkCount
            local checkPId = checkP.id

            if afkCount > 300 then
                msg.notice(p, str.format(
                    '%s 已经至少5分钟没有继续操作。输入"-kick %d"来将其踢出游戏。', checkPName,
                    checkPId))
            elseif afkCount > 180 then
                msg.notice(p, str.format(
                    '%s 已经至少3分钟没有进行操作。达到5分钟时可将其踢出游戏。', checkPName))
            else
                msg.notice(p, str.format('%s 没有处于挂机状态。', checkPName))
            end

        end
    end

end
--------------------------------------------------------------------------------------
function mt:tryKick(keys)
    local p = keys.p

    if not keys.args[1] then
        return
    end

    local pId = math.floor(tonumber(keys.args[1]))
    if pId < 0 or pId > 4 then
        return
    end

    local tgtP = as.player:getPlayerById(pId)
    if not tgtP then
        return
    end

    if tgtP == p then
        msg.notice(p, '你不能踢出自己。')
        return
    end

    local afkCount = tgtP.afkCount

    if afkCount > 300 then
        tgtP:kickedOut()
    end

end
--------------------------------------------------------------------------------------
function mt:addQQ(keys)
    local p = keys.p
    if p:isLocal() then
        code.qqLink(QQ_LINK)
    end
end
--------------------------------------------------------------------------------------
function mt:bodyOutfit(keys)
    local p = keys.p
    p.archOutfitManager:printBodyOutfit()
end
--------------------------------------------------------------------------------------
function mt:check520(keys)
    local p = keys.p
    msg.notice(p, str.format('当前520记录游戏时间：%d分钟', p:getSimpleArch(INT_STORAGE.ONLINE_TIME_520)))
end
--------------------------------------------------------------------------------------
function mt:postTest(keys)
    local p = keys.p
    local u = p.hero

    local json = require 'tool.json'
    local base64 = require 'tool.base64'
    local params = json.encode({
        ['data'] = {
            [1] = '2',
            [2] = '2s',
            [3] = '2x',
        },
    })

    local params = json.encode({
        ['uid'] = '2',
        ['name'] = 'zzzz333',
    })

    base64.enc(params)

    local url = 'http://localhost:8080/map/select'
    -- local param = 'value1=abc&value2=def'

    post_message(url, params, function(result)
        print('post result: ')
        print(result)
    end)

end
--------------------------------------------------------------------------------------

mt.act = {
    effoff = mt.effoff,
    effon = mt.effon,
    -- pureon = mt.pureon,
    -- pureoff = mt.pureoff,
    -- autocast = mt.autocast,
    yynb = mt.qqunReward,
    ttrpg = mt.ttrpgReward,
    myid = mt.myid,
    test = mt.setTestMode,
    buchang45 = mt.buchangReward,
    buchang47 = mt.buchang2Reward,
    buchang488 = mt.buchang3Reward,
    buchang410 = mt.buchang4Reward,
    buchang416 = mt.buchang5Reward,
    dsadas1231 = mt.buchang6Reward,
    buchang425 = mt.buchang425Reward,
    buchang4252 = mt.buchang4252Reward,
    kkyy = mt.KKReward,
    fuli = mt.fuli,
    fish = mt.fish,
    -- hidelose = mt.hideLose,
    afk = mt.checkAfk,
    kick = mt.tryKick,
    qq = mt.addQQ,
    qingkongcundang = mt.clearArch,
    qingkongcundang2 = mt.clearArch2,
    llzb = mt.bodyOutfit,
    posttest = mt.postTest,
    ['520'] = mt.check520,
}
--------------------------------------------------------------------------------------
function mt:enterMsg(p, msg)
    -- gdebug(str.format('enter msg: %s', msg))
    local args = as.util:splitStr(msg)
    local cmd = table.remove(args, 1)

    if mt.act[cmd] then
        local keys = {
            mt = mt,
            p = p,
            msg = msg,
            args = args,
        }
        mt.act[cmd](mt, keys)
    end

end
--------------------------------------------------------------------------------------

return mt
