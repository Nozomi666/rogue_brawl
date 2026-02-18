local mt = {}

local Unit = require 'game.class.unit'

mt.__index = mt
setmetatable(mt, Unit)

mt.parent = Unit
mt.curseList = nil
mt.exp = 0
mt.expMax = 100
mt.expLv = 0
mt.owner = nil
mt.cursePool = reg:getPool('cursePool1')
mt.curseMaxLv = 10

mt.roundGrowExp = 0
mt.growSpeed = 1

--------------------------------------------------------------------------------------
function mt:new(uId, pId, p)

    -- init table
    local o = mt.parent:new(uId)
    setmetatable(o, self)

    o.skillBtn = {}
    o.curseList = {}
    o.owner = p

    -- 初始化按钮
    for i = 1, 12 do

        local function initAct(skill)
            -- mt:setOptionEmpty(skill)
            skill.btnId = i
            skill.callback = mt.onClick
        end

        local skillBtn = as.skill:new(o, 'CurseTower', pId .. '@' .. i, {}, 1, initAct)
        skillBtn.banCastEffect = true;
        o.skillBtn[i] = skillBtn
    end

    -- o:initPool()
    o:refreshUI(-1)

    return o
end
--------------------------------------------------------------------------------------
function mt:setPool(pool)
    self.cursePool = pool
end

--------------------------------------------------------------------------------------
function mt:expFull()
    local p = self.owner
    msg.notice(p, str.format('|cffad5353诅咒之塔|r的能量已充满！'))

    local needRng = true
    local rngCount = 0
    local curseName = '无名诅咒'
    while needRng do
        local pack = fc.rngSelect(self.cursePool)
        curseName = pack.name
        local curse = self:hasCurse(curseName)

        if not curse then
            break
        end

        if curse.lv < self.curseMaxLv then
            break
        end

        rngCount = rngCount + 1
        if rngCount > 10 then
            break
        end
    end

    local curse = self:hasCurse(curseName)
    if curse and curse.lv >= self.curseMaxLv then
        curseName = '破败诅咒'
    end

    gdebug('do add curse ' .. curseName)
    self:addCurse(curseName, 1)

    msg.notice(p, str.format('|cffad5353诅咒之塔|r剩余能量：%d/%d', self.exp, self.expMax))
end
--------------------------------------------------------------------------------------
function mt:addExp(amt)
    local p = self.owner

    amt = amt * self.growSpeed
    amt = math.floor(amt)

    self.exp = self.exp + amt
    msg.notice(p,
        str.format('|cffad5353诅咒之塔|r的能量增加了[|cffffff00%d|r]点。当前能量：%d/%d', amt,
            self.exp, self.expMax))

    while self.exp >= self.expMax do
        self.exp = self.exp - self.expMax
        self.expLv = self.expLv + 1
        self:expFull()
    end

    ui.curse.updateExp(p)

end
--------------------------------------------------------------------------------------
function mt:removeExp(amt)
    local p = self.owner
    amt = math.floor(amt)
    self.exp = math.max(0, self.exp - amt)

    msg.notice(p,
        str.format('|cffad5353诅咒之塔|r的能量减少了[|cff00ff4c%d|r]点。当前能量：%d/%d', amt,
            self.exp, self.expMax))

    ui.curse.updateExp(p)
end
--------------------------------------------------------------------------------------
function mt:onRoundEnd()

    if self.roundGrowExp ~= 0 then
        self:addExp(self.roundGrowExp)
    end

end
--------------------------------------------------------------------------------------
function mt:addCurse(curseName, lv)
    local p = self.owner

    local curse = self:hasCurse(curseName)

    if not curse then
        curse = as.curse:new(p, curseName, lv)
        curse:activate()
        table.insert(self.curseList, curse)
        msg.notice(p, str.format('新的诅咒[|cffff4343%s|r]已降临至战场！', curseName))
    else
        curse:modLv(lv)
        local curseLv = curse.lv
        msg.notice(p, str.format('诅咒[|cffff4343%s|r]的等级提升至[|cffffff00%d|r]级！', curseName, curseLv))
    end

    sound.playToPlayer(glo.gg_snd_curse_upgrade, p, 1, 0, false)

    local _, curseSlotId = self:hasCurse(curseName)
    self:refreshUI(curseSlotId)

    ui.curse.updateCurse(p)

    return curse
end
--------------------------------------------------------------------------------------
function mt:removeCurse(curseName, lv)
    local p = self.owner
    local curse = self:hasCurse(curseName)
    if not curse then
        gdebug('remove null curse')
        return
    end

    lv = math.min(lv, curse.lv)
    curse:modLv(lv * -1)
    local curseLv = curse.lv
    if curseLv <= 0 then
        msg.notice(p, str.format('诅咒[|cffff4343%s|r]已经被移除！', curseName))
        table.removeTarget(self.curseList, curse)
    else
        msg.notice(p, str.format('诅咒[|cffff4343%s|r]的等级降低至[|cff33ff00%d|r]级！', curseName, curseLv))
    end


    self:refreshUI(-1)
    ui.curse.updateCurse(p)
end
--------------------------------------------------------------------------------------
function mt:hasCurse(curseName)
    local curse = nil
    local slotId = -1
    for i, c in ipairs(self.curseList) do
        if c.name == curseName then
            curse = c
            slotId = i
            break
        end
    end

    return curse, slotId
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
    local title, tip, icon

    local curse = self.curseList[slotId]

    if curse then
        local pack = curse.pack
        local curseLv = curse.lv
        local curseName = curse.name
        local curseArt = pack.art
        local curseTip = fc.makePackTip(pack)
        title = str.format('%s - [|cffffcc00等级%d|r]', curseName, curseLv)
        tip = curseTip
        icon = curseArt
    else
        title = [[没有诅咒]]
        tip = [[这也许只是暂时的。]]
        icon = [[ReplaceableTextures\CommandButtons\BTNzanwuzuzhou.blp]]
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
