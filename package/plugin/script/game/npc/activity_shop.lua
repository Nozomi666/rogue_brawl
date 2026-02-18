local mt = {}

local Unit = require 'game.class.unit'

mt.__index = mt
setmetatable(mt, Unit)

mt.parent = Unit
mt.curseList = nil
mt.owner = nil

mt.skillBtn = nil

mt.ROUTE_MAIN = 'route_main'
mt.ROUTE_PART = 'route_part'

mt.TYPE_MOONCAKE = 'mooncake'

mt.route = mt.ROUTE_MAIN

mt.partList = nil -- list
mt.partNow = nil

--------------------------------------------------------------------------------------
function mt:new(uId, pId, p)

    -- init table
    local o = mt.parent:new(uId)
    setmetatable(o, self)

    o.skillBtn = {}
    o.owner = p

    -- 初始化按钮
    for i = 1, 12 do

        local function initAct(skill)
            -- mt:setOptionEmpty(skill)
            skill.btnId = i
            skill.callback = mt.onClick
        end

        local skillBtn = as.skill:new(o, 'ActivityShop', pId .. '@' .. i, {}, 1, initAct)
        skillBtn.banCastEffect = true;
        o.skillBtn[i] = skillBtn
    end

    o.partList = {}

    table.insert(o.partList, mt:initPart(archListName.MOONCAKE_REWARD))
    o.mainBook = book.new(o.partList, 8)

    -- self.route = mt.ROUTE_PART
    -- self.partNow = o.partList[1]

    -- o:initPool()
    o:refreshUI(-1)

    return o
end
--------------------------------------------------------------------------------------
function mt:initPart(listName)
    local part = {}

    local infoPack = fc.getAttr(listName, 'info')
    local archSet = reg:getPool(listName)
    part.info = infoPack
    part.book = book.new(archSet, 8)

    return part
end
--------------------------------------------------------------------------------------
function mt:onClick(keys)
    local self = keys.u
    local p = self.owner
    local skillBtn = keys.skill
    local btnId = skillBtn.btnId

    if self.route == mt.ROUTE_MAIN then
        self:clickMain(btnId)
        self:refreshUI(-1)

    elseif self.route == mt.ROUTE_PART then
        self:clickPart(btnId)
        self:refreshUI(-1)
    end

end

--------------------------------------------------------------------------------------
function mt:getTitle(archPack)
    local title = archPack.title

    return title
end
--------------------------------------------------------------------------------------
function mt:getTip(archPack, scoreName, scoreHave)
    local p = self.owner
    local tip = str.format('%s奖励：|r%s', cst.COLOR_TEAL, archPack.tip)

    local scoreNeed = archPack.scoreNeed

    if archPack.tempLock then
        tip = tip .. str.format('|n|n%s%s|r', cst.COLOR_GRAY, archPack.tempLock)
    else
        if not p:hasArch(archPack.name) then
            tip = tip .. str.format('|n|n%s需要持有：|r%d%s', cst.COLOR_ORANGE, archPack.scoreNeed, scoreName)
            tip = tip .. str.format('|n%s当前持有：|r%d%s', cst.COLOR_SEA, scoreHave, scoreName)
    
            if scoreHave >= scoreNeed then
                tip = tip .. str.format('|n|n%s左键点击来激活|r', cst.COLOR_LIME)
            else
                tip = tip .. str.format('|n|n%s未达到目标|r', cst.COLOR_GRAY)
            end
    
        else
            tip = tip .. str.format('|n|n%s当前持有：|r%d%s', cst.COLOR_SEA, scoreHave, scoreName)
            tip = tip .. str.format('|n|n%s已激活！|r', cst.COLOR_YELLOW)
        end
    end



    return tip
end
--------------------------------------------------------------------------------------
function mt:getArt(archPack, scoreHave)

    local p = self.owner

    local scoreNeed = archPack.scoreNeed

    if archPack.tempLock then
        return str.format('%s%s', cst.BTN_PREFIX_PASSIVE, archPack.art)
    end

    if not p:hasArch(archPack.name) and scoreHave < scoreNeed  then
        return str.format('%s%s', cst.BTN_PREFIX_PASSIVE, archPack.art)
    else
        return str.format('%s%s', cst.BTN_PREFIX_ACTIVE, archPack.art)
    end

    return archPack.art
end
--------------------------------------------------------------------------------------
function mt:clickPart(slotId)
    local p = self.owner
    local skillBtn = self.skillBtn[slotId]
    local part = self.partNow
    local book = book
    book = part.book
    local list = book:getCurrentPage()
    local scoreArch = part.info.scoreArch

    if slotId <= 8 then
        local pack = list[slotId]

        if pack.tempLock then
            return
        end

        local scoreNeed = pack.scoreNeed
        local scoreHave = p:getSimpleArch(scoreArch)
        if scoreHave >= scoreNeed then
            p:tryUnlockArch(pack.name)
        end

    elseif slotId == 9 then
        book:pageLeft()
    elseif slotId == 10 then
        book:pageRight()
    elseif slotId == 12 then
        -- self.route = mt.ROUTE_MAIN
    end

end
--------------------------------------------------------------------------------------
function mt:refreshPart(slotId)
    local p = self.owner
    local skillBtn = self.skillBtn[slotId]
    local title, tip, art = '', '', ''
    local part = self.partNow
    local book = part.book
    local list = book:getCurrentPage()

    local scoreArch = part.info.scoreArch
    local scoreHave = p:getSimpleArch(scoreArch)

    if slotId <= 8 then

        local pack = list[slotId]
        if pack then

            title = self:getTitle(pack)
            tip = self:getTip(pack, part.info.scoreName, scoreHave)
            art = self:getArt(pack, scoreHave)

            skillBtn:show()
        else
            skillBtn:hide()
        end

    elseif slotId == 9 then
        title = '上一页'
        tip = '查看上一页'
        art = [[ReplaceableTextures\CommandButtons\BTNshipinzuofanye.blp]]
        skillBtn:show()
    elseif slotId == 10 then
        title = '下一页'
        tip = '查看下一页'
        art = [[ReplaceableTextures\CommandButtons\BTNshipinyoufanye.blp]]
        skillBtn:show()
    elseif slotId == 12 then
        title = part.info.title
        tip = part.info.detail
        art = part.info.detailArt
        skillBtn:show()
    elseif slotId == 11 then
        skillBtn:hide()

        -- title = '返回主页'
        -- tip = '返回主页面'
        -- art = [[ReplaceableTextures\CommandButtons\BTNshipinfanhui.blp]]
        -- skillBtn:show()
    else
        skillBtn:hide()
    end

    as.skill.setTitle(skillBtn, title)
    as.skill.setTip(skillBtn, tip)
    as.skill.setArt(skillBtn, art)

    -- 刷新等级
    skillBtn.owner:setAbilityLevel(skillBtn.handle, 2)
    skillBtn.owner:setAbilityLevel(skillBtn.handle, 1)

end
--------------------------------------------------------------------------------------
function mt:clickMain(slotId)
    local skillBtn = self.skillBtn[slotId]
    local mainBook = self.mainBook
    local list = mainBook:getCurrentPage()

    if slotId <= 8 then
        local part = list[slotId]
        if part then
            self.route = mt.ROUTE_PART
            self.partNow = part
        end
    end

end
--------------------------------------------------------------------------------------
function mt:refreshMain(slotId)
    local skillBtn = self.skillBtn[slotId]
    local title, tip, art = '', '', ''
    local mainBook = self.mainBook
    local list = mainBook:getCurrentPage()

    if slotId <= 8 then

        local part = list[slotId]
        if part then
            local info = part.info
            title = info.title
            tip = info.tip
            art = info.art
            skillBtn:show()
        else
            skillBtn:hide()
        end

    else
        skillBtn:hide()
    end

    as.skill.setTitle(skillBtn, title)
    as.skill.setTip(skillBtn, tip)
    as.skill.setArt(skillBtn, art)

    -- 刷新等级
    skillBtn.owner:setAbilityLevel(skillBtn.handle, 2)
    skillBtn.owner:setAbilityLevel(skillBtn.handle, 1)
end
--------------------------------------------------------------------------------------
function mt:refreshUI(slotId)

    if slotId == -1 then
        for i = 1, 12 do
            self:refreshUI(i)
        end
        return
    end

    gdebug(str.format('route: %s', self.route))

    if self.route == mt.ROUTE_MAIN then
        self:refreshMain(slotId)
    elseif self.route == mt.ROUTE_PART then
        self:refreshPart(slotId)
    end

end
--------------------------------------------------------------------------------------

return mt
