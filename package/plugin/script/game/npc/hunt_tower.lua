local mt = {}

local Unit = require 'game.class.unit'

mt.__index = mt
setmetatable(mt, Unit)

mt.parent = Unit
mt.uiPage = 1
mt.page = 1 -- hunt page

mt.bountyChallenge = nil
mt.bountyPassNum = 0
mt.bountyRarePool = nil
mt.bountyCands = nil

mt.huntData = nil
mt.bountyData = nil

mt.FP_GUIDE = {
    [1] = 500,
    [2] = 1500,
    [3] = 4000,
    [4] = 14000,
    [5] = 18000,
    [6] = 26000,
    [7] = 30000,
    [8] = 88000,
    [9] = 90000,
    [10] = 105000,
    [11] = 110000,
    [12] = 150000,
}

local rareText = {}
rareText[1] = [[|cffc5c5c5普通|r]]
rareText[2] = [[|cff57c2ff稀有|r]]
rareText[3] = [[|cffba76ff史诗|r]]
rareText[4] = [[|cffFF9705传说|r]]

--------------------------------------------------------------------------------------
function mt:new(uId, pId)

    -- init table
    local o = mt.parent:new(uId)
    setmetatable(o, self)

    o.skillBtn = {}
    o.huntData = as.dataRegister:getTableData('huntData', '猎魔挑战')
    o.bountyData = as.dataRegister:getTableData('huntData', '悬赏挑战')
    o.lastComplete = 0
    o.page = 1
    o.bountyRarePool = {}

    -- 初始化按钮
    for i = 1, 12 do

        local function initAct(skill)
            -- mt:setOptionEmpty(skill)
            skill.btnId = i
            skill.callback = mt.onClick
        end

        local skillBtn = as.skill:new(o, 'HuntTower', pId .. '@' .. i, {}, 1, initAct)
        skillBtn.banCastEffect = true;
        o.skillBtn[i] = skillBtn
    end

    -- o:initPool()
    o:refreshUI(-1)

    -- 选择单位事件
    local eventPack = {
        name = 'on_pick_event',
        condition = cst.UNIT_EVENT_ON_PICK,
        callback = mt.onMousePick,
    }
    o:addEvent(eventPack)

    o:refreshBountyRarePool()

    return o
end
--------------------------------------------------------------------------------------
function mt:onMousePick(p, u, isPick)
    if u.owner ~= p then
        return
    end

    if isPick then
        ui.misc_collection.showChallengeBtn(p)
    else
        ui.misc_collection.hideChallengeBtn(p)

    end

end
--------------------------------------------------------------------------------------
function mt:onClick(keys)
    local self = keys.u
    if self.uiPage == 2 then
        self:onClick_2(keys)
        return
    end

    local p = self.owner
    local skillBtn = keys.skill
    local btnId = skillBtn.btnId
    local entryId = (self.page - 1) * 12 + btnId

    if p.huntOn then
        msg.error(p, '还未完成已激活的猎魔挑战。')
        return
    end

    if self.lastComplete + 1 < entryId and (not self.freeHunt) then
        msg.error(p, '需要完成上一个猎魔挑战。')
        return
    end

    if self.lastComplete + 1 > entryId then
        msg.notice(p, '该猎魔挑战已完成。')
        return
    end

    msg.notice(p, '已就绪猎魔挑战。')
    sound.playToPlayer(glo.gg_snd_challenge_start, p, 1, 0, true)

    local enemyConfig = self.huntData.enemyConfig[entryId]
    local statsConfig = self.huntData.statsConfig[entryId]

    p.huntOn = true
    p.huntConfig = enemyConfig
    p.huntStats = statsConfig
    p.huntId = entryId

    -- make challenge
    local challengeManager = p.challengeManager
    local cName = '猎魔挑战'
    local cReward = self.huntData.rewardConfig[entryId]
    local challenge = challengeManager:addChallenge(cName, cReward, mt.completeHunt, mt.failHunt)

    local eName = enemyConfig.enemy
    local eNum = enemyConfig.num
    local eStats = statsConfig

    for i = 1, eNum do
        challenge:addEnemy(eName, eStats, nil)
    end

    challenge.entryId = entryId

    self:refreshUI(-1)

end
--------------------------------------------------------------------------------------
function mt.failHunt(challenge)
    local self = challenge.huntTower
    local entryId = challenge.entryId
    local p = self.owner
    p.huntOn = false
    p.huntId = -1
    msg.notice(p, str.format(
        '猎魔挑战 - [|cffffcc00%d|r] |cfff16767失败|r。你可以在接下来的回合中再次尝试挑战。',
        entryId))

    sound.playToPlayer(glo.gg_snd_challenge_fail, p, 1, 0, true)
    self:refreshUI(-1)
end
--------------------------------------------------------------------------------------
function mt.completeHunt(challenge)
    local self = challenge.huntTower
    local entryId = challenge.entryId
    local p = self.owner
    p.huntOn = false
    gdebug('complete hunt: ' .. entryId)
    msg.notice(p, str.format('成功完成了猎魔挑战 - [|cffffcc00%d|r]！', entryId))

    self.lastComplete = self.lastComplete + 1
    -- if self.lastComplete % 12 == 0 then
    --     self.page = self.page + 1
    -- end

    sound.playToPlayer(glo.gg_snd_challenge_pass, p, 1, 0, true)

    self:refreshUI(-1)
end
--------------------------------------------------------------------------------------
function mt.failBounty(challenge)
    local self = challenge.huntTower
    local p = self.owner
    self.bountyChallenge = nil
    msg.notice(p, str.format('悬赏挑战|cfff16767失败|r。'))

    sound.playToPlayer(glo.gg_snd_challenge_fail, p, 1, 0, true)
    self:refreshUI(-1)
end
--------------------------------------------------------------------------------------
function mt.completeBounty(challenge)
    local self = challenge.huntTower
    local p = self.owner
    self.bountyChallenge = nil

    msg.notice(p, str.format('成功完成了悬赏挑战！'))
    sound.playToPlayer(glo.gg_snd_challenge_pass, p, 1, 0, true)

    self.bountyPassNum = self.bountyPassNum + 1

    self:refreshUI(-1)
    self:refreshBountyRarePool()
end
--------------------------------------------------------------------------------------
function mt:refreshUI(slotId)

    if self.uiPage == 2 then
        self:refreshUI_2(slotId)
        return
    end

    if slotId == -1 then
        for i = 1, 12 do
            self:refreshUI(i)
        end
        return
    end

    local p = self.owner
    local entryId = (self.page - 1) * 12 + slotId
    local title, tip, icon
    local enemyConfig = self.huntData.enemyConfig[entryId]
    local rewardConfig = self.huntData.rewardConfig[entryId]

    if self.lastComplete < entryId then
        -- 未完成    
        title = str.format('猎魔挑战 - [|cffffcc00%d|r]', entryId)
        local enum = enemyConfig.num
        local eName = enemyConfig.enemy

        tip = str.format('迎战|cffffcc00%d|r只%s。|n|n|cffffcc00奖励：|r', enum, eName)

        for _, reward in ipairs(rewardConfig) do
            local rewardName = reward[1]
            local rewardNum = reward[2]
            tip = tip .. str.format('|n%s×%d', rewardName, rewardNum)
        end

        local fpGuide = mt.FP_GUIDE[entryId]
        tip = tip .. str.format('|n|n%s推荐战斗力：|r%d', cst.COLOR_ORANGE, fpGuide)

        if p.huntId == entryId then
            icon = [[ReplaceableTextures\CommandButtons\BTNtiaozhanzhong.blp]]
        else
            icon = [[ReplaceableTextures\CommandButtons\BTNzhuxian]] .. entryId .. [[.blp]]
        end

    else
        -- 已完成
        title = str.format('猎魔挑战 - [|cffffcc00%d|r] - [|cffbbff00已完成|r]', entryId)
        tip = '已完成'
        icon = [[ReplaceableTextures\CommandButtons\BTNyiwancheng.blp]]
    end

    local skillBtn = self.skillBtn[slotId]

    as.skill.setTitle(skillBtn, title)
    as.skill.setTip(skillBtn, tip)
    as.skill.setArt(skillBtn, icon)
    -- 刷新等级
    skillBtn.owner:setAbilityLevel(skillBtn.handle, 2)
    skillBtn.owner:setAbilityLevel(skillBtn.handle, 1)

end
--------------------------------------------------------------------------------------
function mt:pageTo(page)
    self.uiPage = page
    self:refreshUI(-1)

    if page == 1 then
        for i = 1, 12 do
            local skillBtn = self.skillBtn[i]
            skillBtn:show()
        end
    elseif page == 2 then
        for i = 4, 8 do
            local skillBtn = self.skillBtn[i]
            skillBtn:hide()
        end
        for i = 10, 12 do
            local skillBtn = self.skillBtn[i]
            skillBtn:hide()
        end

    end
end
--------------------------------------------------------------------------------------
function mt:onClick_2(keys)
    local self = keys.u

    local p = self.owner
    local skillBtn = keys.skill
    local btnId = skillBtn.btnId

    if btnId <= 3 then
        self:clickBounty(btnId)
    end

    if btnId == 9 then
        self:refreshBounty()
    end

end
--------------------------------------------------------------------------------------
function mt:refreshUI_2(slotId)

    if slotId == -1 then
        for i = 1, 12 do
            self:refreshUI_2(i)
        end
        return
    end

    local p = self.owner

    local title, tip, icon

    if slotId <= 3 then

        if self.bountyCands then
            local cfg = self.bountyCands[slotId]
            local eConfig = cfg.eConfig
            local sConfig = cfg.sConfig
            local rConfig = cfg.rConfig
            local rewardRate = cfg.rewardRate
            local eName = eConfig.enemy
            local eNum = eConfig.num
            local ePack = as.dataRegister:getTableData('enemyData', eName)
            local rare = cfg.rare
            local rareName = rareText[rare]
            local artWord = ePack.artWord
            local art = str.format([[ReplaceableTextures\CommandButtons\BTN%s%d.blp]], artWord, rare)

            local rewardTip = ''

            local hp = sConfig.hp
            local atk = sConfig.atk

            for _, reward in ipairs(rConfig) do
                local rewardName = reward[1]
                local rewardNum = reward[2]
                rewardTip = rewardTip .. str.format('|n%s×%d', rewardName, rewardNum)
            end

            title = str.format('悬赏挑战 - [%s][%s]', eName, rareName)
            tip = str.format(
                '|cffffcc00生命基准：|r%.0f|n|cffffcc00攻击基准：|r%.0f|n|cffffcc00敌人数量：|r%d|n|n|cffffcc00奖励：|r%s',
                hp, atk, eNum, rewardTip)
            icon = art
        else
            title = '还没有悬赏'
            tip = '在下方消耗挑战令牌来刷新悬赏怪。'
            icon = [[ReplaceableTextures\CommandButtons\BTNtiaozhandaishuaxin.blp]]
        end

    elseif slotId == 9 then
        local token = p:getResource(cst.RES_TOKEN)
        title = str.format('刷新悬赏（1悬赏令牌）')
        tip = str.format(
            '刷新出现的悬赏怪种类和稀有度。击败的悬赏怪越多，出现稀有敌人的几率越高。|n|n|cffffcc00当前完成悬赏数：|r%d|n|cffffcc00当前持有令牌数：|r%d',
            self.bountyPassNum, token)
        icon = [[ReplaceableTextures\CommandButtons\BTNshuaxintiaozhan.blp]]
    else
        title = ''
        tip = ''
        icon = [[black.blp]]
    end

    local skillBtn = self.skillBtn[slotId]
    -- print('refresh hunt ui: ' .. slotId)

    as.skill.setTitle(skillBtn, title)
    as.skill.setTip(skillBtn, tip)
    as.skill.setArt(skillBtn, icon)
    -- 刷新等级
    skillBtn.owner:setAbilityLevel(skillBtn.handle, 2)
    skillBtn.owner:setAbilityLevel(skillBtn.handle, 1)

end
--------------------------------------------------------------------------------------
function mt:clickBounty(btnId)
    local p = self.owner

    if not self.bountyCands then
        return
    end

    if self.bountyChallenge then
        msg.error(p, '还未完成已激活的悬赏挑战。')
        return
    end

    msg.notice(p, '已就绪悬赏挑战。')
    sound.playToPlayer(glo.gg_snd_challenge_start, p, 1, 0, true)

    local cfg = self.bountyCands[btnId]
    local eConfig = cfg.eConfig
    local sConfig = cfg.sConfig
    local rConfig = cfg.rConfig
    local eName = eConfig.enemy
    local eNum = eConfig.num
    local ePack = as.dataRegister:getTableData('enemyData', eName)
    local rare = cfg.rare
    local rareName = rareText[rare]

    -- make challenge
    local challengeManager = p.challengeManager
    local cName = '悬赏挑战'
    local cReward = rConfig
    local challenge = challengeManager:addChallenge(cName, cReward, mt.completeBounty, mt.failBounty)

    for i = 1, eNum do
        challenge:addEnemy(eName, sConfig, nil)
    end

    self.bountyChallenge = challenge

    self.bountyCands = nil

    self:refreshUI(-1)

end
--------------------------------------------------------------------------------------
function mt:refreshBounty()

    local p = self.owner
    local price = 1
    if p:getResource(cst.RES_TOKEN) < price then
        msg.error(p, '悬赏令牌不足。')
        return
    end

    -- special event
    if p:hasArch('情报线人') then
        if math.randomPct() < 0.15 then
            price = 0
            msg.reward(p, str.format('科技[%s复刻之术|r]效果触发，返还了[%s1|r]悬赏令牌。', cst.COLOR_TEAL, cst.COLOR_YELLOW))
        end

    end

    p:modResource(cst.RES_TOKEN, price * -1)

    local rarePool = self.bountyRarePool
    local cands = {}
    local eConfigList = self.bountyData.enemyConfig
    local sConfigList = self.bountyData.statsConfig
    fc.shuffleTable(eConfigList)

    for i = 1, 3 do
        local rare = rarePool[math.random(#rarePool)]
        local eConfig = eConfigList[i]
        local sConfig = sConfigList[rare]

        local rConfigList = eConfig.reward
        local rConfig = rConfigList[rare]

        local rewardRate = self.bountyData.rewardRate * self.bountyPassNum
        local hardRate = self.bountyData.hardRate * self.bountyPassNum
        gdebug('rewardRate: ' .. rewardRate)
        local waveRate = sConfig.waveRate

        local sConfigCopy = {
            hp = sConfig.hp * (1 + hardRate) + waveRate * gm.gameChapter.statsConfig[math.min(gm.wave, 40)].hp,
            atk = sConfig.atk * (1 + hardRate) + waveRate * gm.gameChapter.statsConfig[math.min(gm.wave, 40)].atk,
            def = sConfig.def
        }
        

        local rConfigMod = {}
        local rName = rConfig[1]
        local rNum = rConfig[2]
        rNum = math.floor(rNum * (1 + rewardRate))
        table.insert(rConfigMod, {rName, rNum})

        local eName = eConfig.enemy
        local cfg = {
            rare = rare,
            eConfig = eConfig,
            sConfig = sConfigCopy,
            rConfig = rConfigMod,
            rewardRate = rewardRate,
        }
        table.insert(cands, cfg)
        gdebug('rare: ' .. rare)
    end

    self.bountyCands = cands
    
    self:refreshUI(-1)
end
--------------------------------------------------------------------------------------
function mt:refreshBountyRarePool()
    local rarePool = {}
    self.bountyRarePool = rarePool

    -- rare
    local rareNum = math.min(10 + self.bountyPassNum * 3, 40)
    for i = 1, rareNum do
        table.insert(rarePool, 2)
    end
    -- epic
    local rareNum = math.min(2 + self.bountyPassNum * 2, 30)
    for i = 1, rareNum do
        table.insert(rarePool, 3)
    end
    -- legand
    local rareNum = math.min(0 + self.bountyPassNum * 1, 20)
    for i = 1, rareNum do
        table.insert(rarePool, 4)
    end
    -- normal
    local rareNum = 100 - #rarePool
    for i = 1, rareNum do
        table.insert(rarePool, 1)
    end

end
--------------------------------------------------------------------------------------

return mt
