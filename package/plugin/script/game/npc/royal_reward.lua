local mt = {}

local Unit = require 'game.class.unit'

mt.__index = mt
setmetatable(mt, Unit)

mt.parent = Unit

mt.fpReq = {
    [1] = 6000,
    [2] = 25000,
    [3] = 60000,
    [4] = 120000,
}

mt.lv = 0
mt.owner = nil

mt.rewardList = {}

mt.artCanPick = {
    [1] = [[ReplaceableTextures\CommandButtons\BTNqishi1.blp]],
    [5] = [[ReplaceableTextures\CommandButtons\BTNqishi2.blp]],
    [9] = [[ReplaceableTextures\CommandButtons\BTNqishi3.blp]],

    [2] = [[ReplaceableTextures\CommandButtons\BTNbojue1.blp]],
    [6] = [[ReplaceableTextures\CommandButtons\BTNbojue2.blp]],
    [10] = [[ReplaceableTextures\CommandButtons\BTNbojue3.blp]],

    [3] = [[ReplaceableTextures\CommandButtons\BTNwangzi1.blp]],
    [7] = [[ReplaceableTextures\CommandButtons\BTNwangzi2.blp]],
    [11] = [[ReplaceableTextures\CommandButtons\BTNwangzi3.blp]],

    [4] = [[ReplaceableTextures\CommandButtons\BTNguowang1.blp]],
    [8] = [[ReplaceableTextures\CommandButtons\BTNguowang2.blp]],
    [12] = [[ReplaceableTextures\CommandButtons\BTNguowang3.blp]],

}

mt.artNoPick = {
    [1] = [[ReplaceableTextures\CommandButtons\BTNqishi0.blp]],
    [2] = [[ReplaceableTextures\CommandButtons\BTNbojue0.blp]],
    [3] = [[ReplaceableTextures\CommandButtons\BTNwangzi0.blp]],
    [4] = [[ReplaceableTextures\CommandButtons\BTNguowang0.blp]],
}

mt.artPicked = {
    [1] = [[ReplaceableTextures\CommandButtons\BTNxuanshangyilingqu.blp]],
    [2] = [[ReplaceableTextures\CommandButtons\BTNxuanshangyilingqu.blp]],
    [3] = [[ReplaceableTextures\CommandButtons\BTNxuanshangyilingqu.blp]],
    [4] = [[ReplaceableTextures\CommandButtons\BTNxuanshangyilingqu.blp]],
}

mt.artGiveUp = {
    [1] = [[ReplaceableTextures\PassiveButtons\PASBTNreward_ban.blp]],
    [2] = [[ReplaceableTextures\PassiveButtons\PASBTNreward_ban.blp]],
    [3] = [[ReplaceableTextures\PassiveButtons\PASBTNreward_ban.blp]],
    [4] = [[ReplaceableTextures\PassiveButtons\PASBTNreward_ban.blp]],
}

mt.rewardTitle = {
    [1] = [[骑士的奖赏]],
    [2] = [[公爵的奖赏]],
    [3] = [[王子的奖赏]],
    [4] = [[国王的奖赏]],
}

--------------------------------------------[固定奖励]------------------------------------------
mt.fixReward = {}

local rewardLv = 1
mt.fixReward[rewardLv] = {}

table.insert(mt.fixReward[rewardLv], {{'金币', 8000}, {'木材', 50}})
table.insert(mt.fixReward[rewardLv], {{'金币', 7000}, {'木材', 75}})
table.insert(mt.fixReward[rewardLv], {{'金币', 6000}, {'木材', 100}})
table.insert(mt.fixReward[rewardLv], {{'金币', 5000}, {'木材', 125}})
table.insert(mt.fixReward[rewardLv], {{'金币', 4000}, {'木材', 150}})
table.insert(mt.fixReward[rewardLv], {{'金币', 3000}, {'木材', 175}})
table.insert(mt.fixReward[rewardLv], {{'金币', 2000}, {'木材', 200}})

rewardLv = 2
mt.fixReward[rewardLv] = {}

table.insert(mt.fixReward[rewardLv], {{'金币', 16000}, {'木材', 100}})
table.insert(mt.fixReward[rewardLv], {{'金币', 14000}, {'木材', 150}})
table.insert(mt.fixReward[rewardLv], {{'金币', 12000}, {'木材', 200}})
table.insert(mt.fixReward[rewardLv], {{'金币', 10000}, {'木材', 250}})
table.insert(mt.fixReward[rewardLv], {{'金币', 8000}, {'木材', 300}})
table.insert(mt.fixReward[rewardLv], {{'金币', 6000}, {'木材', 350}})
table.insert(mt.fixReward[rewardLv], {{'金币', 4000}, {'木材', 400}})

rewardLv = 3
mt.fixReward[rewardLv] = {}

table.insert(mt.fixReward[rewardLv], {{'金币', 40000}, {'木材', 200}})
table.insert(mt.fixReward[rewardLv], {{'金币', 35000}, {'木材', 300}})
table.insert(mt.fixReward[rewardLv], {{'金币', 30000}, {'木材', 400}})
table.insert(mt.fixReward[rewardLv], {{'金币', 25000}, {'木材', 500}})
table.insert(mt.fixReward[rewardLv], {{'金币', 20000}, {'木材', 600}})
table.insert(mt.fixReward[rewardLv], {{'金币', 15000}, {'木材', 700}})
table.insert(mt.fixReward[rewardLv], {{'金币', 10000}, {'木材', 800}})

rewardLv = 4
mt.fixReward[rewardLv] = {}

table.insert(mt.fixReward[rewardLv], {{'金币', 80000}, {'木材', 350}})
table.insert(mt.fixReward[rewardLv], {{'金币', 70000}, {'木材', 525}})
table.insert(mt.fixReward[rewardLv], {{'金币', 60000}, {'木材', 700}})
table.insert(mt.fixReward[rewardLv], {{'金币', 50000}, {'木材', 875}})
table.insert(mt.fixReward[rewardLv], {{'金币', 40000}, {'木材', 1050}})
table.insert(mt.fixReward[rewardLv], {{'金币', 30000}, {'木材', 1225}})
table.insert(mt.fixReward[rewardLv], {{'金币', 20000}, {'木材', 1400}})

--------------------------------------------[随机奖励]------------------------------------------
mt.randomReward = {}

rewardLv = 1
mt.randomReward[rewardLv] = {}

table.insert(mt.randomReward[rewardLv], {{'神秘铸币', 4}})
table.insert(mt.randomReward[rewardLv], {{'未鉴定的符文石', 1}})
table.insert(mt.randomReward[rewardLv], {{'B级装备箱', 1}})
table.insert(mt.randomReward[rewardLv], {{'挑战令牌', 2}})
table.insert(mt.randomReward[rewardLv], {{'重铸石', 5}})
table.insert(mt.randomReward[rewardLv], {{'洗炼石', 5}})
table.insert(mt.randomReward[rewardLv], {{'初级属性提升物', 5}})
table.insert(mt.randomReward[rewardLv], {{'愈合之花', 1}})
table.insert(mt.randomReward[rewardLv], {{'史诗之书', 3}})

rewardLv = 2
mt.randomReward[rewardLv] = {}

table.insert(mt.randomReward[rewardLv], {{'神秘铸币', 8}})
table.insert(mt.randomReward[rewardLv], {{'未鉴定的符文石', 2}})
table.insert(mt.randomReward[rewardLv], {{'A级装备箱', 1}})
table.insert(mt.randomReward[rewardLv], {{'挑战令牌', 4}})
table.insert(mt.randomReward[rewardLv], {{'重铸石', 10}})
table.insert(mt.randomReward[rewardLv], {{'洗炼石', 10}})
table.insert(mt.randomReward[rewardLv], {{'中级属性提升物', 5}})
table.insert(mt.randomReward[rewardLv], {{'愈合之花', 2}})
table.insert(mt.randomReward[rewardLv], {{'史诗之书', 6}})

rewardLv = 3
mt.randomReward[rewardLv] = {}

table.insert(mt.randomReward[rewardLv], {{'神秘铸币', 12}})
table.insert(mt.randomReward[rewardLv], {{'未鉴定的符文石', 3}})
table.insert(mt.randomReward[rewardLv], {{'S级装备箱', 1}})
table.insert(mt.randomReward[rewardLv], {{'挑战令牌', 6}})
table.insert(mt.randomReward[rewardLv], {{'重铸石', 15}})
table.insert(mt.randomReward[rewardLv], {{'洗炼石', 15}})
table.insert(mt.randomReward[rewardLv], {{'高级属性提升物', 5}})
table.insert(mt.randomReward[rewardLv], {{'愈合之花', 4}})
table.insert(mt.randomReward[rewardLv], {{'传说之书', 3}})
table.insert(mt.randomReward[rewardLv], {{'羁绊之心', 1}})

rewardLv = 4
mt.randomReward[rewardLv] = {}

table.insert(mt.randomReward[rewardLv], {{'神秘铸币', 16}})
table.insert(mt.randomReward[rewardLv], {{'未鉴定的符文石', 4}})
table.insert(mt.randomReward[rewardLv], {{'R级装备箱', 1}})
table.insert(mt.randomReward[rewardLv], {{'挑战令牌', 8}})
table.insert(mt.randomReward[rewardLv], {{'重铸石', 20}})
table.insert(mt.randomReward[rewardLv], {{'洗炼石', 20}})
table.insert(mt.randomReward[rewardLv], {{'高级属性提升物', 10}})
table.insert(mt.randomReward[rewardLv], {{'愈合之花', 6}})
table.insert(mt.randomReward[rewardLv], {{'传说之书', 6}})
table.insert(mt.randomReward[rewardLv], {{'羁绊之心', 2}})

--------------------------------------------------------------------------------------
function mt:new(uId, pId, p)

    -- init table
    local o = mt.parent:new(uId)
    setmetatable(o, self)

    o.owner = p

    o.skillBtn = {}

    o.rewardList = {
        [1] = {},
        [2] = {},
        [3] = {},
        [4] = {},
    }

    o.rewardPicked = {
        [1] = -1,
        [2] = -1,
        [3] = -1,
        [4] = -1,
    }

    -- 初始化按钮
    for i = 1, 12 do
        local function initAct(skill)
            -- mt:setOptionEmpty(skill)
            skill.btnId = i
            skill.callback = mt.onClick
        end

        local skillBtn = as.skill:new(o, 'RoyalReward', pId .. '@' .. i, {}, 1, initAct)
        skillBtn.banCastEffect = true;
        o.skillBtn[i] = skillBtn
    end

    -- o:initPool()
    o:refreshUI(-1)

    return o
end
--------------------------------------------------------------------------------------
function mt:checkUpdate()
    local p = self.owner
    local fp = p:getAllFp()
    if self.lv >= 4 then
        return
    end

    local nextLv = self.lv + 1

    if fp >= mt.fpReq[nextLv] then
        self:upgrade()
    end

end
--------------------------------------------------------------------------------------
function mt:upgrade()
    local p = self.owner
    self.lv = self.lv + 1

    local lv = self.lv

    local fixRewardPool = mt.fixReward[lv]
    local randomRewardPool = mt.randomReward[lv]

    fc.shuffleTable(fixRewardPool)
    fc.shuffleTable(randomRewardPool)

    local rewardList = self.rewardList[lv]

    for i = 1, 3 do
        local fixRewardList = fixRewardPool[i]
        local randomRewardList = randomRewardPool[i]
        local rewardEntries = {}

        for _, reward in ipairs(fixRewardList) do
            table.insert(rewardEntries, reward)
        end

        for _, reward in ipairs(randomRewardList) do
            table.insert(rewardEntries, reward)
        end

        table.insert(rewardList, rewardEntries)
    end

    local fpReq = mt.fpReq[lv]
    local rewardTitle = mt.rewardTitle[lv]

    local eff = {
        model = [[tx (452).mdx]],
        size = 2,
        time = -1,
    }

    if not self.hintEff then
        self.hintEff = fc.pointEffect(eff, self:getloc())
    end

    msg.notice(p, str.format('团队战斗力达到了[|cffffff00%d|r]，可以领取[|cffffff00%s|r]了！',fpReq, rewardTitle), 30)

    sound.playToPlayer(glo.gg_snd_Quest_Complete, p, 1, 0, false)

    self:refreshUI(-1)

end
--------------------------------------------------------------------------------------
function mt:onClick(keys)
    local self = keys.u
    local p = self.owner
    local skillBtn = keys.skill
    local btnId = skillBtn.btnId

    local btnLv = mt.getBtnLv(btnId)
    local rewardId = mt.getRewardId(btnId)
    local lv = self.lv

    if lv < btnLv then
        return
    end

    if lv >= btnLv then
        if self.rewardPicked[btnLv] ~= -1 then
            gdebug('已经领取过了')
            return
        end
    end

    local confirmPick = function()
        local rewardList = self.rewardList[btnLv][rewardId]
        fc.rewardList(rewardList, p, self:getloc())

        self.rewardPicked[btnLv] = rewardId

        if self.hintEff then
            fc.removeEffect(self.hintEff)
            self.hintEff = nil
        end

        sound.playToPlayer(glo.gg_snd_royal_reward, p, 1, 0, false)

        self:refreshUI(-1)
    end

    local box = p.pickBox
    box:clean()
    box:setTitle(str.format('要领取这个奖励吗？|n同阶级奖励只能领取一个。'))
    box:addBtn('确定', confirmPick, {}, cst.PICK_BOX_HOT_KEY.NULL)

    box:addBtn('再考虑一下', nil, {
        btnId = btnId,
    }, KEY.ESC)

end
--------------------------------------------------------------------------------------
function mt.getBtnLv(slotId)
    local btnLv
    if slotId == 1 or slotId == 5 or slotId == 9 then
        btnLv = 1
    elseif slotId == 2 or slotId == 6 or slotId == 10 then
        btnLv = 2
    elseif slotId == 3 or slotId == 7 or slotId == 11 then
        btnLv = 3
    else
        btnLv = 4
    end

    return btnLv
end --------------------------------------------------------------------------------------
function mt.getRewardId(slotId)
    local rewardId
    if slotId == 1 or slotId == 2 or slotId == 3 or slotId == 4 then
        rewardId = 1
    elseif slotId == 5 or slotId == 6 or slotId == 7 or slotId == 8 then
        rewardId = 2
    elseif slotId == 9 or slotId == 10 or slotId == 11 or slotId == 12 then
        rewardId = 3
    end

    return rewardId
end
--------------------------------------------------------------------------------------
function mt:refreshUI(slotId)

    if slotId == -1 then
        for i = 1, 12 do
            self:refreshUI(i)
        end
        return
    end
    local skillBtn = self.skillBtn[slotId]
    local btnLv = mt.getBtnLv(slotId)

    local title, tip, icon

    local lv = self.lv
    local rewardId = mt.getRewardId(slotId)

    local rewardTitle = mt.rewardTitle[btnLv]

    if lv < btnLv then
        local fpReq = mt.fpReq[btnLv]
        title = str.format('%s- [|cffffcc00未达标|r]', rewardTitle)
        tip = str.format('在团队战斗力达到|cffffff00%d|r时可以解锁这个奖励。', fpReq)
        icon = mt.artNoPick[btnLv]
    end

    if lv >= btnLv then
        if self.rewardPicked[btnLv] == -1 then
            local rewardList = self.rewardList[btnLv]
            local rewardEntries = rewardList[rewardId]

            title = str.format('%s- [|cff3cff00可领取|r]', rewardTitle)

            local rewardTip = str.format('|cffffcc00获得奖励：|r')

            for _, reward in ipairs(rewardEntries) do
                local rewardName = reward[1]
                local rewardNum = reward[2]
                rewardTip = rewardTip .. str.format('|n%s×%d', rewardName, rewardNum)
            end

            tip = rewardTip
            tip = tip .. '|n|n|cffa6ff00左键点击来领取|r'
            icon = mt.artCanPick[slotId]
        else

            local rewardList = self.rewardList[btnLv]
            local rewardEntries = rewardList[rewardId]

            local rewardTip = str.format('|cffffcc00获得奖励：|r')

            for _, reward in ipairs(rewardEntries) do
                local rewardName = reward[1]
                local rewardNum = reward[2]
                rewardTip = rewardTip .. str.format('|n%s×%d', rewardName, rewardNum)
            end

            if self.rewardPicked[btnLv] == rewardId then
                title = str.format('%s- [|cff00ff88已领取|r]', rewardTitle)
                tip = rewardTip
                tip = tip .. '|n|n|cffffd000已经领取了这个奖励。|r'
                icon = mt.artPicked[btnLv]
            else
                title = str.format('%s- [|cffa1a1a1未选择|r]', rewardTitle)
                tip = rewardTip
                tip = tip .. '|n|n|cff969696没有选择这个奖励。|r'
                icon = mt.artGiveUp[btnLv]
            end

        end
    end

    as.skill.setTitle(skillBtn, title)
    as.skill.setTip(skillBtn, tip)
    as.skill.setArt(skillBtn, icon)

    -- 刷新等级
    skillBtn.owner:setAbilityLevel(skillBtn.handle, 2)
    skillBtn.owner:setAbilityLevel(skillBtn.handle, 1)

end
--------------------------------------------------------------------------------------

return mt
