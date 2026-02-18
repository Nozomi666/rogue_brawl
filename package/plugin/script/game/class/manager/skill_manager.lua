local loops = require 'game.manager.loop_manager'

local SkillManager = {}
SkillManager.__index = SkillManager

local mt = SkillManager
mt.frameInterval = loops.frameInterval

-- 注册技能handle绑定的技能
mt.registry = {} -- static

-- variables
mt.owner = nil
mt.talentNum = 0

mt.nameOf = nil -- need init
mt.skillAt = nil -- need init
mt.comboList = nil -- need init
mt.cdTable = nil

-- local var
local TALENT_SLOT = 5
local COMBO_SLOT = 6

--------------------------------------------------------------------------------------
function mt:new(u)

    -- init table
    local o = {}
    setmetatable(o, self)

    -- init value
    o.owner = u
    o.nameOf = {}
    o.skillAt = {}
    o.comboList = {}
    o.cdTable = {}

    -- 新建技能1-6
    local skillName = '没有技能'

    for i = 1, 4 do
        o:addSkill(u, i, skillName)
    end

    local skill = o:addSkill(u, 7, '未解锁的技能槽1')
    local skill = o:addSkill(u, 8, '未解锁的技能槽2')

    local skillName = '没有天赋'
    o:addSkill(u, TALENT_SLOT, skillName)

    local skillName = '没有羁绊'
    o:addSkill(u, COMBO_SLOT, skillName)

    return o
end

--------------------------------------------------------------------------------------
function mt:skillj2t(skillJ)
    return mt.registry[skillJ]
end

--------------------------------------------------------------------------------------
function mt:addSkill(u, slot, skillName, skillLv)

    skillLv = skillLv or 1

    self = self == mt and u.skillManager or self

    local skillPack = as.dataRegister:getSkillByName(skillName)

    if self.skillAt[slot] then
        error(u:getName() .. "already has flexskill at slot: " .. slot)
    end

    local pId = u.owner.id
    local hId = u.hId
    local tId = (skillPack.targetType == 0) and 4 or (skillPack.targetType == 2) and 1 or skillPack.targetType
    -- 

    local skill = as.skill:new(u, (pId .. hId), (slot .. tId), skillPack, skillLv)
    skill.slotId = slot
    self.skillAt[slot] = skill
    self.nameOf[skillName] = skill

    self:updateCombo(skill, true)

    local prevCd = self.cdTable[skillName]
    if prevCd then
        skill:setCurrentCd(prevCd)
    end

    return skill

end

--------------------------------------------------------------------------------------
function mt:removeSkillById(u, slot)
    self = self == mt and u.skillManager or self

    if not self.skillAt[slot] then
        return nil
    end

    local skill = self.skillAt[slot]
    local skillName = skill:getName()

    local cd = skill:getCurrentCd()
    if cd > 0 then
        self.cdTable[skillName] = cd
    end

    skill:remove()
    self.skillAt[slot] = nil
    self.nameOf[skillName] = nil

    return skill
end

--------------------------------------------------------------------------------------
function mt:removeSkillByName(skillName)

    if not self.nameOf[skillName] then
        return nil
    end

    local skill = self.nameOf[skillName]
    local slot = skill.slotId

    return self:removeSkillById(self.owner, slot)
end

--------------------------------------------------------------------------------------
function mt:heroAddTalent(skillName)

    if (self.talentNum == 1) then
        gdebug("warning - unit already has talent")
        return
    end

    local talentName = skillName .. ' - [|cffffcc00天赋|r]'

    gdebug('add talent')
    self.talentNum = self.talentNum + 1

    -- delete skill
    self:removeSkillById(self.owner, TALENT_SLOT)
    local talent = self:addSkill(self.owner, TALENT_SLOT, skillName, 1)

    talent:setTitlePostfix(' - [|cffffcc00天赋|r]')

end

--------------------------------------------------------------------------------------
function mt:heroRemoveTalent()
    if self.talentNum < 1 then
        gdebug("warning - unit has no talent")
        return
    end

    gdebug('removing talent')
    self.talentNum = 0

    self:removeSkillById(self.owner, TALENT_SLOT)
    self:addSkill(self.owner, TALENT_SLOT, '没有天赋', 1)

end

--------------------------------------------------------------------------------------
function mt:getUnitSkill(u, skillName)
    if not u or not u.skillManager then
        return nil
    end

    return u.skillManager.nameOf[skillName]

end

--------------------------------------------------------------------------------------
function mt:setSkillLv(u, skillName, lv)

    if u.removed then
        mapdebug('u removed... cant set skill lv')
    end

    lv = lv or 1

    local skill = mt:getUnitSkill(u, skillName)
    skill:setLv(lv)
end

--------------------------------------------------------------------------------------
function mt:getEmptySkillSlot()

    for i = 1, 8 do
        if self.skillAt[i]:getName() == '没有技能' then
            return i
        end
    end

    return -1
end
--------------------------------------------------------------------------------------
local function updateCustomSkillTitle(skill)
    local skillPack = skill.skillPack
    local skillName = skillPack.name
    local elementType = skillPack.elementType
    local lv = skill.lv
    local rare = skillPack.rarity
    local title = str.format('%s%s|r[%s]', cst.SKILL_RARE_COLOR[rare], skillName, cst.ELEMENT_NAME[elementType])
    local postfix = str.format(' - [|cffffcc00等级 %d|r]', lv)

    skill:setTitle(title)
    skill:setTitlePostfix(postfix)
end
--------------------------------------------------------------------------------------
local function updateClassComboTitle(skill)
    local skillPack = skill.skillPack
    local skillName = skillPack.name
    local class = skillPack.class
    local subClass = skillPack.subClass
    local lv = skill.lv
    local title = str.format('%s - [|cffffcc00职业羁绊：|r%s + %s]', skillName, cst.STATS_NAME[class],
        cst.STATS_NAME[subClass])
    -- local postfix = str.format(' - [|cffffcc00等级 %d|r]', lv)

    skill:setTitle(title)
    -- skill:setTitlePostfix(postfix)
end
--------------------------------------------------------------------------------------
local function coloredSkill(skillPack)
    local name = skillPack.name
    local rarity = skillPack.rarity
    return str.format('%s%s|r', cst.SKILL_RARE_COLOR[rarity], name)
end
--------------------------------------------------------------------------------------
local skillFp = {
    [1] = 60,
    [2] = 150,
    [3] = 300,
    [4] = 600,
}
--------------------------------------------------------------------------------------
function mt:tryLearnSkill(u, skillPack)

    gdebug('--------------------------')

    self = u.skillManager
    local skillName = skillPack.name
    local p = u.owner
    local rarity = skillPack.rarity

    gdebug(str.format('player [%s]  %s try learn skill - [%s]', p:getName(), u:getName(), skillName))

    if self.nameOf[skillName] then
        -- 升级技能
        local oldSkill = self.nameOf[skillName]
        local oldLv = oldSkill.lv
        local newLv = oldLv + 1

        if oldLv == 5 then
            return -1, '升级[' .. coloredSkill(skillPack) .. ']失败，已经是满级了。'
        end

        local slot = oldSkill.slotId
        self:removeSkillByName(skillName, true)
        local newSkill = mt:addSkill(u, slot, skillName, newLv)

        updateCustomSkillTitle(newSkill)
        sound.playToPlayer(glo.gg_snd_skill_upgrade, p, 1, 0.05, true)
        local eff = {
            model = [[MegaHeal_Portrait.mdx]],
            bind = [[origin]],
        }
        fc.unitEffect(eff, u)
        u:modFp(skillFp[rarity])

        local tip =
            u:getName() .. ' 成功将[' .. coloredSkill(skillPack) .. ']的等级提升至|cffffff00 ' .. newLv ..
                ' |r级！。'

        if newLv >= cst.skillLvMax then
            tip =
                u:getName() .. ' 成功将[' .. coloredSkill(skillPack) .. ']的等级提升至|cffffff00 ' .. newLv ..
                    ' |r级！(|cff00ffff升满了！|r）。'
        end

        return 1, tip

    end

    -- 无槽位
    local slot = self:getEmptySkillSlot()
    if slot < 0 then
        return -1, u:getName() .. ' 学习[' .. coloredSkill(skillPack) .. ']失败，无空技能槽位。'
    end

    -- 学习新技能
    mt:removeSkillById(u, slot)
    local skill = mt:addSkill(u, slot, skillName, 1)
    if not skill then
        return 0, '获取技能失败；技能名：' .. skillName
    end

    updateCustomSkillTitle(skill)

    local elementType = skillPack.elementType
    p:updateElementCounts(elementType, 1)
    u:updateElementCounts(elementType, 1)

    sound.playToPlayer(glo.gg_snd_skill_upgrade, p, 1, 0.05, true)
    local eff = {
        model = [[MegaHeal_Portrait.mdx]],
        bind = [[origin]],
    }
    fc.unitEffect(eff, u)

    u:modFp(skillFp[rarity])

    u.owner.guideManager:checkComplete('技能')

    return 1, str.format('|cffffcc00%s|r 成功学习了 |cffffff00%s|r！', u:getName(), skillName)
end
--------------------------------------------------------------------------------------
function mt:removeCustomSkill(u, skillPack)
    self = u.skillManager

    local skillName = skillPack.name
    local skill = self.nameOf[skillName]

    if not skill then
        return
    end

    self:updateCombo(skill, false)
    local skill = self:removeSkillByName(skillName)

    if skill then
        -- removeCombo
        -- local pack = skillPack
        -- if pack.comboList then
        --     for _, comboKeys in ipairs(pack.comboList) do
        --         local comboName = comboKeys.name
        --         -- 检测到匹配combo，激活
        --         skill:removeCombo(comboName)
        --         gdebug('mod fp: ' .. skillFp[pack.rarity] * -1)
        --         self.owner:modFp(skillFp[pack.rarity] * -1)

        --         local keys = {
        --             u = u,
        --             skillPack = skillPack,
        --             isAdd = false,
        --         }
        --         xpcall(function()
        --             u:triggerEvent(cst.UNIT_EVENT_ON_TOGGLE_SKILL_COMBO, keys)
        --         end, function(msg)
        --             print(msg, debug.traceback())
        --         end)
        --     end
        -- end

        local emptySkill = mt:addSkill(u, skill.slotId, '没有技能', 1)
        return skill
    end

    return nil
end
--------------------------------------------------------------------------------------
-- 添加进循环
function mt:setInnerCd(keys, time)
    time = math.max(mt:getInnerCd(keys), time)

    keys:setCurrentCd(time)
end

--------------------------------------------------------------------------------------
-- 添加进循环
function mt:getInnerCd(keys)
    return keys:getCurrentCd()
end
--------------------------------------------------------------------------------------
function mt:hasCombo(comboName)
    -- gdebug('do test combo' .. comboName)
    if self.comboList[comboName] == comboName then
        -- gdebug('has combo yes')
        return true
    else
        -- gdebug('has combo flase')
        return false
    end

    return false
end
--------------------------------------------------------------------------------------
function mt:activateCombo(comboName)

    self.comboList[comboName] = comboName
    gdebug('do activating combo' .. self.comboList[comboName])

    local u = self.owner
    local p = u.owner
    local eff = {
        model = [[bd_yeqi03.mdx]],
        bind = [[origin]],
    }
    fc.unitEffect(eff, u)
    msg.notice(p, str.format('|cffffcc00%s|r 激活了技能羁绊 [|cffffff00%s|r]！', u:getName(), comboName))
    sound.playToPlayer(glo.gg_snd_unlock_skill_combo, p, 1, 0, true)

    -- 激活技能被动羁绊效果
    for _, skill in ipairs(self.skillAt) do
        local pack = skill.skillPack
        if pack.comboList then
            for _, comboKeys in ipairs(pack.comboList) do

                local compare = comboKeys.name

                -- 检测到匹配combo，激活
                if comboName == compare then
                    skill:addCombo(comboName)
                    gdebug('mod fp: ' .. skillFp[pack.rarity])
                    self.owner:modFp(skillFp[pack.rarity])

                    local keys = {
                        u = u,
                        skillPack = pack,
                        isAdd = true,
                    }

                    xpcall(function()
                        u:triggerEvent(cst.UNIT_EVENT_ON_TOGGLE_SKILL_COMBO, keys)
                    end, function(msg)
                        print(msg, debug.traceback())
                    end)

                end
            end

        end

    end
    -- return self.comboList[comboName] or false
end

--------------------------------------------------------------------------------------
function mt:removeCombo(comboName)
    gdebug('do deactivating combo' .. comboName)
    self.comboList[comboName] = nil
    local u = self.owner

    -- 激活技能被动羁绊效果
    for _, skill in ipairs(self.skillAt) do
        gdebug('do deactivating skill' .. skill.name)
        local pack = skill.skillPack
        if pack.comboList then
            for _, comboKeys in ipairs(pack.comboList) do

                local compare = comboKeys.name

                -- 检测到匹配combo，激活
                if comboName == compare then
                    skill:removeCombo(comboName)
                    gdebug('mod fp: ' .. skillFp[pack.rarity] * -1)
                    self.owner:modFp(skillFp[pack.rarity] * -1)

                    local keys = {
                        u = u,
                        skillPack = pack,
                        isAdd = false,
                    }
                    xpcall(function()
                        u:triggerEvent(cst.UNIT_EVENT_ON_TOGGLE_SKILL_COMBO, keys)
                    end, function(msg)
                        print(msg, debug.traceback())
                    end)
                end
            end

        end

    end
    -- return self.comboList[comboName] or false
end

--------------------------------------------------------------------------------------
function mt:updateCombo(triggerSkill, isAdd)
    gdebug('update combo')
    local trackList = {}

    for _, skill in ipairs(self.skillAt) do
        local pack = skill.skillPack
        local comboList = pack.comboList

        if pack.comboList then
            for _, comboKeys in ipairs(comboList) do

                local comboName = comboKeys.name

                -- 如果这个羁绊已经判定过了，不再判定
                if trackList[comboName] then
                    goto next_loop
                else
                    trackList[comboName] = true
                end

                -- 如果没有激活，判断是否生效并激活
                if not self:hasCombo(comboName) then
                    gdebug('test activating')
                    local pass = true
                    for _, comboSkill in ipairs(comboKeys.skills) do
                        if self.nameOf[comboSkill.name] == nil then
                            pass = false
                            break
                        end
                    end

                    if pass then

                        self:activateCombo(comboName)
                    end

                    -- 如果已经激活，判断是否失去生效并撤销
                else
                    gdebug('already has combo')

                    if not isAdd then
                        local pass = true
                        for _, comboSkill in ipairs(comboKeys.skills) do
                            if self.nameOf[comboSkill.name] == triggerSkill then
                                pass = false
                                break
                            end
                        end

                        if not pass then
                            self:removeCombo(comboName)
                        end
                    end

                end

                ::next_loop::

            end
        end

    end
end
--------------------------------------------------------------------------------------
function mt:getCustomSkills()
    local list = {}
    for i = 1, 4 do
        if self.skillAt[i]:getName() ~= '没有技能' and self.skillAt[i]:getName() ~= '未解锁的技能槽1' and
            self.skillAt[i]:getName() ~= '未解锁的技能槽2' then
            table.insert(list, self.skillAt[i])
        end
    end

    for i = 7, 8 do
        if self.skillAt[i]:getName() ~= '没有技能' and self.skillAt[i]:getName() ~= '未解锁的技能槽1' and
            self.skillAt[i]:getName() ~= '未解锁的技能槽2' then
            table.insert(list, self.skillAt[i])
        end
    end
    return list
end
--------------------------------------------------------------------------------------
function mt:tryDeleteSkill()
    local u = self.owner
    local p = u.owner

    local skillList = self:getCustomSkills()

    if #skillList < 1 then
        as.message.notice(p, '没有可以删除的技能')
        return
    end

    local box = p.pickBox

    local callBack = function(keys)
        local self = keys.self
        local u = self.owner
        local p = self.owner.owner
        local skill = keys.skill
        local skillPack = skill.skillPack
        local skillName = skillPack.name
        local rarity = skillPack.rarity
        local skillLv = skill.lv
        local sellRate = 0.8
        local gold = npc.skillShop.skillPrice[rarity] * skillLv * sellRate

        if self:removeCustomSkill(u, skillPack) then

            as.message.notice(p, str.format('删除技能[%s%s|r]成功，获得|cffffff00%d金币|r。',
                cst.SKILL_RARE_COLOR[rarity], skillName, gold))
            p:modResource(cst.RES_GOLD, gold)

            local elementType = skillPack.elementType
            p:updateElementCounts(elementType, -1)
            u:updateElementCounts(elementType, -1)

            u:modFp(skillFp[rarity] * -1)

        end
    end

    local keylist = {KEY.Q, KEY.W, KEY.E, KEY.R, KEY.D, KEY.F}

    box:clean()
    box:setTitle('选择要删除的技能')
    for i, skill in ipairs(skillList) do
        local tip = str.format('%s - [等级 %d]', skill:getName(), skill.lv)

        local slotId = skill.slotId
        if slotId > 6 then
            slotId = slotId - 2
        end

        box:addBtn(tip, callBack, {
            optionId = i,
            skill = skill,
            self = self,
        }, keylist[slotId])
    end

    box:addBtn('取消', nil, {
        optionId = 0,
    }, KEY.ESC)

    box:showBox()

end
--------------------------------------------------------------------------------------
function mt:getCdSkills()
    local list = {}
    for i = 1, 8 do
        local skill = self.skillAt[i]
        if skill and skill:getCurrentCd() > 0 then
            table.insert(list, skill)
        end
    end

    return list
end
--------------------------------------------------------------------------------------
function mt:getReadySkills()
    local list = {}
    local mp = self.owner:getStats(cst.ST_MP)

    for i = 1, 8 do
        local skill = self.skillAt[i]
        if not skill then
            gdebug('auto cast get no skill')
            gdebug(str.format('player name: %s, unit name: %s', self.owner.owner:getName(), self.owner:getName()))
        end
        local mpNeed = skill:getData('cost')
        if skill:getCurrentCd() <= 0 and skill.skillPack.targetType ~= 0 and mp >= mpNeed then
            table.insert(list, skill)
        end
    end

    return list
end
--------------------------------------------------------------------------------------
function mt:getRandomCdSkill()
    local list = self:getCdSkills()
    return next(list) ~= nil and list[math.random(#list)] or nil
end
--------------------------------------------------------------------------------------
function mt:getComboByName(comboName)
    for i, pool in ipairs(skillComboPool) do
        for j, pack in ipairs(pool) do
            if pack.name == comboName then
                gdebug('find combo success')
                return pack
            end
        end
    end

    return nil
end
--------------------------------------------------------------------------------------
function mt:addClassCombo(u, comboName)
    self = u.skillManager
    local skillPack = as.dataRegister:getSkillByName(comboName)
    local skillName = comboName

    local p = u.owner

    -- 无槽位
    local slot = COMBO_SLOT

    -- 学习新技能
    mt:removeSkillById(u, slot)
    local skill = mt:addSkill(u, slot, skillName, 1)
    if not skill then
        return 0, '获取技能失败；技能名：' .. skillName
    end

    updateClassComboTitle(skill)

    u:modFp(100)

    msg.notice(p, str.format('|cffffff00%s|r 解锁了职业羁绊 |cff00ff80%s|r ！', u:getName(), comboName))

    local eff = {
        model = [[AZ_shenshengxili.MDX]],
    }

    fc.unitEffect(eff, u)
    ui.btnRbHint.hideSlot(p, 6)

    sound.playToPlayer(glo.gg_snd_unlock_class_combo, p, 1, 0, true)

    return 1, '解锁了职业羁绊|cffffff00' .. skillName .. '|r！'
end
--------------------------------------------------------------------------------------
function mt:upgradeClassCombo(u)
    self = u.skillManager
    local p = u.owner
    local slot = COMBO_SLOT
    local skill = self.skillAt[slot]
    local oldLv = skill.lv
    local newLv = oldLv + 1
    local skillName = skill.name

    self:removeSkillById(u, COMBO_SLOT)
    skill = mt:addSkill(u, slot, skillName, newLv)

    updateClassComboTitle(skill)

    u:modFp(200 * newLv)

    msg.notice(p,
        str.format('|cffffff00%s|r 将职业羁绊 |cff00ff80%s|r 升到了 |cffffff00%d|r 级！', u:getName(),
            skillName, newLv))

    local eff = {
        model = [[AZ_shenshengxili.MDX]],
    }

    fc.unitEffect(eff, u)

    sound.playToPlayer(glo.gg_snd_unlock_class_combo, p, 1, 0, true)

end
--------------------------------------------------------------------------------------
function mt:removeClassCombo(u)
    self = u.skillManager

    local skill = self:removeSkillById(u, COMBO_SLOT)

    if skill then
        local emptySkill = mt:addSkill(u, skill.slotId, '没有技能', 1)
        return skill
    end

    return nil
end
--------------------------------------------------------------------------------------
function mt:updateCastRange()
    for i = 1, 8 do
        local skill = self.skillAt[i]
        if skill then
            skill:updateCastRange()
        end
    end
end
--------------------------------------------------------------------------------------
return mt

