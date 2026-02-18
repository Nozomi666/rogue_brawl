local mt = {}

local Unit = require 'game.class.unit'

mt.__index = mt
setmetatable(mt, Unit)

mt.parent = Unit
mt.tag = cst.TAG_SKILL_SHOP

mt.qualityPool = {
    [1] = {},
    [2] = {},
}

mt.skillBtn = nil
mt.skillPrice = {400, 1000, 2500, 6000}
mt.allTags = {cst.ST_STR, cst.ST_AGI, cst.ST_INT}

mt.PRESENT_BTN_SHIFT = 8

mt.skillPool = nil


-- 初级池子概率
for i = 1, 75 do
    table.insert(mt.qualityPool[1], 1)
end
for i = 1, 20 do
    table.insert(mt.qualityPool[1], 2)
end
for i = 1, 5 do
    table.insert(mt.qualityPool[1], 3)
end

-- 高级池子概率
for i = 1, 20 do
    table.insert(mt.qualityPool[2], 1)
end
for i = 1, 40 do
    table.insert(mt.qualityPool[2], 2)
end
for i = 1, 35 do
    table.insert(mt.qualityPool[2], 3)
end
for i = 1, 5 do
    table.insert(mt.qualityPool[2], 4)
end
--------------------------------------------------------------------------------------
function mt:randomSkillPack(class, lv, p)
    self = p.skillShop
    if class == cst.ST_ALL then
        class = mt.allTags[math.random(#mt.allTags)]
    end

    local skillPool = self.skillPool[class][lv]
    local skillPack = skillPool[#skillPool]
    gdebug('random skillpack: ' .. skillPack.name)

    return skillPack
end
--------------------------------------------------------------------------------------
function mt:randomSkillBookItemType(class, lv, p)
    local skillPack = mt:randomSkillPack(class, lv, p)
    local itemType = as.dataRegister:getSkillPackItemType(skillPack)
    return itemType
end

--------------------------------------------------------------------------------------
function mt:refreshSkillBook(keys)

   


    local u = keys.u
    local p = keys.p
    local cfg = keys.cfg

    local self = p.skillShop

    local price = cfg.lumb
    local drawLv = cfg.drawLv
    local drawClass = cfg.drawClass

    local hold = p:getResource(cst.RES_LUMBER)

    if not cfg.isFree then
        if hold < price then
            as.message.error(p, '刷新技能失败，木材不足。')
            return
        end

        if p:hasRelic('回收装置') and math.randomPct() < 0.1 then
            msg.notice(p, str.format('宝物 |cffffff00%s|r 的效果得到了触发。', '回收装置'))
            price = 0
        end

        p:modResource(cst.RES_LUMBER, price * -1)
    end

    -- 技能池洗牌
    if drawClass ~= cst.ST_ALL then
        for r = 1, 4 do
            local shufflePool = self.skillPool[drawClass][r]
            fc.shuffleTable(shufflePool)

        end
    else

        for _, st in ipairs(mt.allTags) do
            for r = 1, 4 do
                local shufflePool = self.skillPool[st][r]
                fc.shuffleTable(shufflePool)
            end
        end

    end

    -- 开始刷新技能
    local qualityPool = mt.qualityPool[drawLv]
    for i = 1, 4 do
        local quality
        if not cfg.fixRare then
            quality = qualityPool[math.random(#qualityPool)]

            if drawLv == 2 and p:hasRelic('橙色尖碑') and math.randomPct() < 0.02 then
                quality = 4
            end
            -- if drawLv == 2 then
            --     if quality == 3 then
            --         local chance = as.util:prdCheck(u.handle)
            --         -- gdebug(str.format('legend random chance: %f', chance * 100))
            --         if as.util:prdRoll(u.handle, PRD_CHANCE.PCT_5) then
            --             quality = quality + 1
            --         end
            --     else
            --         if as.util:randomPct() <= 0.05 then
            --             quality = quality + 1
            --         end
            --     end

            -- end
        else
            quality = cfg.fixRare
        end

        -- gdebug(str.format('quality: %d', quality))

        local drawClassReal = drawClass
        if drawClass == cst.ST_ALL then
            drawClassReal = mt.allTags[math.random(#mt.allTags)]
        end
        local skillPool = self.skillPool[drawClassReal][quality]
        local skillPack = skillPool[i]
        local btnId = i + self.PRESENT_BTN_SHIFT

        self.skillBtn[btnId].skillPack = skillPack
        self:updatePresentSlot(i)
    end

    ui.skillHint.update(self.owner)

end
--------------------------------------------------------------------------------------
function mt:getSkillBookPrice(skillPack)
    return self.skillPrice[skillPack.rarity]
end
--------------------------------------------------------------------------------------
function mt:updatePresentSlot(slotId)
    local btnId = slotId + self.PRESENT_BTN_SHIFT
    local skillBtn = self.skillBtn[btnId]
    local skillPack = skillBtn.skillPack
    local skillTip = as.skill.generateTip(skillBtn, 1)
    local rare = skillPack.rarity
    local elementType = skillPack.elementType
    local price = mt:getSkillBookPrice(skillPack)
    local skillName = skillPack.name
    local priceTip = string.format('|cffff9900购买需要：|r|cffffff00%d金币|r', price)
    local entireTip = string.format('%s\n\n%s', skillTip, priceTip)
    local title =
        string.format('购买%s%s|r[%s]', cst.SKILL_RARE_COLOR[rare], skillName, cst.ELEMENT_NAME[elementType])

    if skillPack == nil then
        self:setOptionEmpty(skillBtn)
        return
    end

    as.skill.setTitle(skillBtn, title)
    as.skill.setTip(skillBtn, entireTip)
    as.skill.setArt(skillBtn, skillPack.art)

end
--------------------------------------------------------------------------------------
local function compareElement(a, b)
    -- print(a.name)
    -- print(as.dataRegister:getSkillDataByName(a.name, 'rarity'))
    return as.dataRegister:getSkillDataByName(a.name, 'elementType') <
               as.dataRegister:getSkillDataByName(b.name, 'elementType')
end
--------------------------------------------------------------------------------------
function mt:sortPool()

    local statsList = {cst.ST_STR, cst.ST_AGI, cst.ST_INT}

    for _, stats in ipairs(statsList) do
        for j = 1, 4 do
            table.sort(mt.skillPool[stats][j], compareElement)
            gdebug('sort pool: ' .. j)
        end

        for j = 1, 4 do
            for _, pack in ipairs(mt.skillPool[stats][5 - j]) do
                table.insert(mt.skillPool[stats]['all'], pack)
            end
        end

    end

end
--------------------------------------------------------------------------------------
function mt:initPool(loadMt)

    -- 技能池分类
    for i, skillPack in ipairs(as.dataRegister.skillPool) do
        local rare = skillPack.rarity
        local class = skillPack.class
        -- gdebug(skillPack.name)

        table.insert(self.skillPool[class][rare], skillPack)
        if loadMt then
            table.insert(mt.skillPool[class][rare], skillPack)
        end
    end

    if loadMt then
        mt:sortPool()
        as.deck:regskillNumMax()
    end

end
--------------------------------------------------------------------------------------
function mt:botBtnOnClick(keys)

    local self = keys.u
    local p = self.owner
    local skillBtn = keys.skill
    local btnId = skillBtn.btnId
    local skillPack = skillBtn.skillPack
    if not skillPack then
        return
    end
    local skillName = skillPack.name
    local price = mt:getSkillBookPrice(skillPack)

    local hold = p:getResource(cst.RES_GOLD)

    if hold < price then
        as.message.error(p, '学习技能失败，金币不足。')
        return
    end

    -- show pick box
    local p = self.owner
    local box = p.pickBox
    local heroList = p.heroList

    local callBack = function(keys)
        local optionId = keys.optionId
        local hero = keys.hero

        -- cancel
        if optionId == 0 then
            return
        end

        -- directly learn mode
        if optionId > 0 then
            local hold = p:getResource(cst.RES_GOLD)

            if hold < price then
                as.message.error(p, str.format('学习技能[%s%s|r]失败，金币不足。',
                    cst.SKILL_RARE_COLOR[skillPack.rarity], skillName))
                return
            end

            local u = hero
            if not u then
                as.message.error(p, '获取英雄失败')
                return
            end

            local outcome, msg = u.skillManager:tryLearnSkill(u, skillPack)
            if outcome == 1 then
                p:modResource(cst.RES_GOLD, price * -1)
                as.message.notice(p, msg)
                self:clearAllOptions()
            else
                as.message.error(p, msg)
            end
            -- 学习成功以后设置空槽

        end

        -- buy skillbook mode
        if optionId == -1 then
            local hold = p:getResource(cst.RES_GOLD)

            if hold < price then
                as.message.error(p, str.format('学习技能[%s%s|r]失败，金币不足。',
                    cst.SKILL_RARE_COLOR[skillPack.rarity], skillName))
                return
            end

            p:modResource(cst.RES_GOLD, price * -1)
            local itemType = as.dataRegister:getSkillPackItemType(skillPack)
            local item = p.maid:addItem(itemType)
            item.share = true
            as.message.notice(p, str.format('你获得了[%s%s|r]技能书！', cst.SKILL_RARE_COLOR[skillPack.rarity],
                skillName))
            self:clearAllOptions()

        end

        -- gdebug('try learn' .. skillName)
        -- mt:addHero(p, mt.baseHeroType[keys])
    end

    box:clean()
    box:setTitle(str.format('选择一个英雄来学习|cffffff00%s|r', skillName))

    local keylist = {KEY.Q, KEY.W, KEY.E}

    for i, hero in ipairs(heroList) do
        local tip = hero:getName()

        local sk = as.skillManager:getUnitSkill(hero, skillName)
        local canUpgrade = false
        if sk then
            if sk.lv < cst.skillLvMax then
                tip = tip .. ' （可升级）'
                canUpgrade = true
            else
                tip = tip .. ' （已满级）'
            end

        end

        local hasCombo = false
        if skillPack and skillPack.comboList then
            for _, combo in ipairs(skillPack.comboList) do
                for _, skill in ipairs(combo.skills) do
                    if hero:hasSkill(skill.name) and skill.name ~= skillPack.name then
                        hasCombo = true
                    end
                end
            end
        end

        if hasCombo and (not canUpgrade) then
            tip = tip .. ' （有羁绊）'
        end

        box:addBtn(tip, callBack, {
            optionId = 1,
            hero = hero,
            btnId = btnId,
        }, keylist[i])
    end

    box:addBtn('获得技能书', callBack, {
        optionId = -1,
        btnId = btnId,
    }, KEY.B)

    box:addBtn('取消', callBack, {
        optionId = 0,
    }, KEY.ESC)
    box:showBox()

end

--------------------------------------------------------------------------------------
function mt:clearAllOptions()
    for btnId = 9, 12 do
        local skillBtn = self.skillBtn[btnId]
        skillBtn.skillPack = nil
        self:setOptionEmpty(skillBtn)
    end

    ui.skillHint.update(self.owner)

end
--------------------------------------------------------------------------------------
function mt:checkUpgrade()
    local upgrade = {}

    for i = 1, 4 do
        local skillBtn = self.skillBtn[8 + i]
        local skillPack = skillBtn.skillPack

        if skillPack then
            for _, hero in ipairs(self.owner.heroList) do
                if hero:hasSkill(skillPack.name) and hero:hasSkill(skillPack.name).lv < cst.skillLvMax then
                    upgrade[i] = true
                    gdebug('i = true: ' .. i)
                end
            end
        end

    end

    return upgrade
end
--------------------------------------------------------------------------------------
function mt:checkCombo()
    local upgrade = {}

    for i = 1, 4 do
        local skillBtn = self.skillBtn[8 + i]
        local skillPack = skillBtn.skillPack

        if skillPack and skillPack.comboList then
            for _, hero in ipairs(self.owner.heroList) do

                for _, combo in ipairs(skillPack.comboList) do
                    for _, skill in ipairs(combo.skills) do
                        if hero:hasSkill(skill.name) and skill.name ~= skillPack.name and (not hero:hasSkill(skillPack.name)) then
                            upgrade[i] = true
                        end
                    end
                end

            end
        end

    end

    return upgrade
end
--------------------------------------------------------------------------------------
function mt:setOptionEmpty(skillBtn)
    as.skill.setTitle(skillBtn, '技能待刷新')
    as.skill.setTip(skillBtn, '在上方刷新')
    as.skill.setArt(skillBtn, [[ReplaceableTextures\PassiveButtons\PASBTNjinengdaishuaxin.blp]])

    -- 刷新等级
    skillBtn.owner:setAbilityLevel(skillBtn.handle, 2)
    skillBtn.owner:setAbilityLevel(skillBtn.handle, 1)
end
--------------------------------------------------------------------------------------
function mt:mouseInTool(btnId)
    local skillBtn = self.skillBtn[btnId]
    if not skillBtn then
        return
    end

    local presentSkillPack = skillBtn.skillPack

    if (presentSkillPack == nil) then
        return
    end

    if (presentSkillPack.comboList) then
        class.ui_base['updateComboList'](class, self.owner, presentSkillPack)
    end
end
--------------------------------------------------------------------------------------
function mt:new(uId, pId)

    -- init table
    local o = mt.parent:new(uId)
    setmetatable(o, self)

    o.skillBtn = {}

    o.skillPool = {
        [cst.ST_STR] = {
            [1] = {},
            [2] = {},
            [3] = {},
            [4] = {},
        },
        [cst.ST_AGI] = {
            [1] = {},
            [2] = {},
            [3] = {},
            [4] = {},
        },
        [cst.ST_INT] = {
            [1] = {},
            [2] = {},
            [3] = {},
            [4] = {},
        },
    }

    local loadMt = false
    if not mt.skillPool then
        mt.skillPool = {
            [cst.ST_STR] = {
                [1] = {},
                [2] = {},
                [3] = {},
                [4] = {},
                ['all'] = {},
            },
            [cst.ST_AGI] = {
                [1] = {},
                [2] = {},
                [3] = {},
                [4] = {},
                ['all'] = {},
            },
            [cst.ST_INT] = {
                [1] = {},
                [2] = {},
                [3] = {},
                [4] = {},
                ['all'] = {},
            },

        }
        loadMt = true
    end

    -- 初始化抽取按钮

    -- 初始化购买按钮
    for i = 9, 12 do

        local function initAct(skill)
            mt:setOptionEmpty(skill)
            skill.btnId = i
            skill.callback = mt.botBtnOnClick
        end

        local skillBtn = as.skill:new(o, 'SkillShop', pId .. '@' .. i, {}, 1, initAct)
        skillBtn.banCastEffect = true;
        o.skillBtn[i] = skillBtn
    end

    o:initPool(loadMt)

    return o
end

--------------------------------------------------------------------------------------
function mt:dummy()
end

return mt
