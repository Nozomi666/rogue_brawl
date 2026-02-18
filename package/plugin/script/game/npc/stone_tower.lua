local mt = {}

local Unit = require 'game.class.unit'

mt.__index = mt
setmetatable(mt, Unit)

mt.parent = Unit

mt.maxLv = 5

mt.charmCondition = {
    [1] = 4,
    [2] = 9,
    [3] = 15,
    [4] = 22,
    [5] = 30,
}

--------------------------------------------------------------------------------------
function mt:new(uId, pId)

    -- init table
    local o = mt.parent:new(uId)
    setmetatable(o, self)

    o.skillBtn = {}
    o.stoneList = {}
    o.stoneNum = 0
    o.maxStone = 6
    o.charmList = {}

    o.charmAppeared = {}

    for i = 1, 5 do
        o.charmList[i] = nil
    end

    -- 初始化按钮
    for i = 1, 12 do

        local function initAct(skill)
            -- mt:setOptionEmpty(skill)
            skill.btnId = i
            skill.callback = mt.onClick
        end

        local skillBtn = as.skill:new(o, 'StoneTower', pId .. '@' .. i, {}, 1, initAct)
        skillBtn.banCastEffect = true;
        o.skillBtn[i] = skillBtn
    end

    -- 选择单位事件
    local eventPack = {
        name = 'on_pick_event',
        condition = cst.UNIT_EVENT_ON_PICK,
        callback = mt.onMousePick,
    }
    o:addEvent(eventPack)

    -- o:initPool()
    o:refreshUI(-1)

    return o
end
--------------------------------------------------------------------------------------
function mt:onMousePick(p, u, isPick)
    if u.owner ~= p then
        return
    end

    if isPick then
        self = u
        for slotId = 1, 12 do
            local skillBtn = self.skillBtn[slotId]

            local data = self.stoneList[slotId]
            local frame = ui.btnRbNumber.frame[slotId]
            if data then
                local lv = data.lv

                if p:isLocal() then
                    frame:set_normal_image(str.format([[BTNlv_hint_%d.blp]], lv))
                    frame:show()
                end

            else
                if p:isLocal() then
                    frame:hide()
                end

            end

        end

    else
        for i = 1, 12 do
            local frame = ui.btnRbNumber.frame[i]
            if p:isLocal() then
                frame:hide()
            end

        end

    end

end
--------------------------------------------------------------------------------------
function mt:onClick(keys)
    local self = keys.u
    local p = self.owner
    local skillBtn = keys.skill
    local btnId = skillBtn.btnId

    if btnId < 12 then
        if not self.stoneList[btnId] then
            return
        end

        local confirmRemove = function(keys)
            self:doRemoveStone(btnId)
        end

        local entry = self.stoneList[btnId]
        local stoneName = entry.stoneName

        local box = p.pickBox
        box:clean()
        box:setTitle(str.format('确定要摧毁 [|cffffff00%s|r] ？', stoneName))
        box:addBtn('是', confirmRemove, {
            btnId = btnId,
        }, cst.PICK_BOX_HOT_KEY.NULL)

        box:addBtn('否', nil, {
            btnId = btnId,
        }, KEY.ESC)
    end

    if btnId == 12 then
        local box = p.pickBox
        local have = p:getResource(cst.RES_WASH)

        if have <= 0 then
            msg.notice(p, '当前没有洗炼石。')
            return
        end

        if self.charmList[1] == nil then
            msg.notice(p, '当前没有元素赐福。')
            return
        end

        local confirmRemove = function(keys)
            p:modResource(cst.RES_WASH, -1)

            print('refresh charm')

            local wisp = self:removeElement(keys.removeId)
            print('removed wisp', wisp, keys.removeId)
            self:activateElement(keys.removeId, wisp)
            self:refreshUI(12)
        end

        box:clean()
        box:setTitle(str.format('消耗一枚|cff99ebff洗炼石|r来刷新赐福（当前拥有：%d）', have))

        for i = 1, 5 do
            local wisp = self.charmList[i]
            if wisp then

                local wispName = wisp.name
                local elementType = wisp.elementType
                local wispColor = '|cff61ffff'
                if wisp.isHigh then
                    wispColor = '|cffff619e'
                end
                local title = str.format('%s%s|r - [%s]', wispColor, wispName, cst.ELEMENT_NAME[elementType])

                box:addBtn(wispName, confirmRemove, {
                    removeId = i,
                }, cst.PICK_BOX_HOT_KEY.NULL)
            end
        end

        box:addBtn('取消', nil, {
            btnId = btnId,
        }, KEY.ESC)
    end

end
--------------------------------------------------------------------------------------
function mt:getStoneLv(stoneName)
    local p = self.owner

    local lv = 0
    for i = 1, self.maxStone do
        if self.stoneList[i] then
            if self.stoneList[i].stoneName == stoneName then
                lv = self.stoneList[i].lv
                break
            end
        end

    end

    return lv
end
--------------------------------------------------------------------------------------
function mt:tryActivateStone(stoneName)

    local p = self.owner

    local found = false
    local entry = nil
    local slotId = 1
    for i = 1, self.maxStone do
        if self.stoneList[i] then
            if self.stoneList[i].stoneName == stoneName then
                found = true
                entry = self.stoneList[i]
                slotId = i
                break
            end

        else
            -- slotId = i
            -- break
        end
    end

    if not found then
        for i = 1, self.maxStone do
            if not self.stoneList[i] then
                slotId = i
                break
            end
        end
    end

    if not found then
        if self.stoneNum >= self.maxStone then
            msg.error(p, '符文石槽位已满。')
            return -1
        else
            self:doActivateStone(stoneName, true, slotId)
            gdebug('slot id: ' .. slotId)
            return 1
        end
    else
        if entry.lv >= self.maxLv then
            msg.error(p, '符文石等级已满。')
            return -1
        else
            gdebug('slot id: ' .. slotId)
            self:doActivateStone(stoneName, false, slotId)
            return 1
        end
    end

end
--------------------------------------------------------------------------------------
function mt:doActivateStone(stoneName, isActivate, slotId)
    local p = self.owner
    if isActivate then
        self.stoneNum = self.stoneNum + 1
        self.stoneList[slotId] = {
            lv = 1,
            stoneName = stoneName,
            element1 = nil,
            element2 = nil,
        }
        msg.notice(p, str.format('你成功激活了 |cffffcc00%s|r ！', stoneName))
    else
        self.stoneList[slotId].lv = self.stoneList[slotId].lv + 1
        msg.notice(p, str.format('你成功将 |cffffcc00%s|r 升至 |cffffff00%d|r 级！', stoneName,
            self.stoneList[slotId].lv))

        -- if self.stoneList[slotId].lv == 2 or self.stoneList[slotId].lv == 4 then
        --     self:activateElement(slotId)
        -- end
    end
    self:updateCharm()

    local stonePack = as.dataRegister:getTableData('stone', stoneName)
    local statsType = stonePack.statsType
    local statsVal = stonePack.statsVal

    for _, u in ipairs(p.heroList) do
        u:modStats(statsType, statsVal)
    end

    if stonePack.onActivate then
        stonePack.onActivate(p, true, 1)
    end

    self:refreshUI(slotId)
    self:refreshUI(12)

end
--------------------------------------------------------------------------------------
function mt:doRemoveStone(slotId)
    local p = self.owner
    local stoneName = self.stoneList[slotId].stoneName
    local stoneLv = self.stoneList[slotId].lv

    local stonePack = as.dataRegister:getTableData('stone', stoneName)
    local statsType = stonePack.statsType
    local statsVal = stonePack.statsVal
    for _, u in ipairs(p.heroList) do
        u:modStats(statsType, statsVal * stoneLv * -1)
    end

    if stonePack.onActivate then
        stonePack.onActivate(p, false, stoneLv)
    end

    self.stoneList[slotId] = nil
    self.stoneNum = self.stoneNum - 1
    msg.notice(p, str.format('你成功摧毁移除了 |cffffcc00%s|r 。', stoneName))

    mt:onMousePick(p, self, true)

    self:refreshUI(slotId)
end
--------------------------------------------------------------------------------------
function mt:updateCharm()
    local ttlLv = self:getTotalLv()

    for i = 1, 5 do
        if ttlLv == mt.charmCondition[i] then
            if not self.charmList[i] then
                self:activateElement(i)

                local p = self.owner
                local keys = {
                    p = p,
                    lv = i,
                }
                p:triggerSafeEvent(cst.PLAYER_EVENT_ON_ADD_CHARM, keys)
            end
        end
    end
end
--------------------------------------------------------------------------------------
function mt:activateElement(slotId, eliminate)
    local p = self.owner
    local poolName = nil
    local elementSlot = nil

    if math.randomPct() < 0.8 then
        poolName = 'elementWispLow'
    else
        poolName = 'elementWispHigh'
    end

    local pool = as.dataRegister:getPool(poolName)
    local dup = true
    local wisp, wispName

    print('active element called')

    while dup do

        wisp = fc.rngSelect(pool)
        wispName = wisp.name
        print('while dup..' .. wispName)
        if not p:getAttribute(wispName) then
            dup = false
        end

        local appearTime = self.charmAppeared[wispName]
        if appearTime then
            --gdebug(str.format('charm appeared: %s, %d', wispName, appearTime))
            local refreshChance = math.clamp(0.7 + appearTime * 0.1, 0, 0.9)
            if math.randomPct() < refreshChance then
                dup = true
                --gdebug(str.format('charm get refreshed： %s', wispName))
            end
        end

        if eliminate and eliminate == wisp then
            dup = true
        end
    end

    self.charmList[slotId] = wisp
    p:setAttribute(wispName, true)

    self.charmAppeared[wispName] = (self.charmAppeared[wispName] or 0) + 1

    local elementType = wisp.elementType

    if poolName == 'elementWispLow' then
        msg.notice(p, str.format('符石魔塔激活了[%s]|cff61ffff初级元素赐福|r - |cffffff00%s|r ！',
            cst.ELEMENT_NAME[elementType], wispName))
        sound.playToPlayer(glo.gg_snd_ChoirZoomIn, p, 1, 0, true)
    else
        wisp.isHigh = true
        msg.notice(p, str.format('符石魔塔激活了[%s]|cffff619e高级元素赐福|r - |cffffff00%s|r ！',
            cst.ELEMENT_NAME[elementType], wispName))
        sound.playToPlayer(glo.gg_snd_ChoirZoomInTight, p, 1, 0, true)
    end

    p:updateElementCounts(elementType, 1)

    if wisp.onToggle then
        for _, hero in ipairs(p.heroList) do
            fc.safeExecute(function()
                wisp.onToggle(hero, true)
            end)
        end
    end

end
--------------------------------------------------------------------------------------
function mt:removeElement(slotId)
    local p = self.owner
    local wisp = self.charmList[slotId]
    local wispName = wisp.name
    local elementType = wisp.elementType
    p:updateElementCounts(elementType, -1)

    self.charmList[slotId] = nil
    p:setAttribute(wispName, false)

    if wisp.onToggle then
        for _, hero in ipairs(p.heroList) do
            fc.safeExecute(function()
                wisp.onToggle(hero, false)
            end)

        end
    end

    return wisp
end
--------------------------------------------------------------------------------------
function mt:doLateActivate(u)
    local list = self.stoneList
    for i, data in ipairs(list) do
        -- gdebug('late activate: ' .. stoneName)
        -- gdebug('late activate lv : ' .. data.lv)
        local stoneName = data.stoneName
        local stonePack = as.dataRegister:getTableData('stone', stoneName)
        local lv = data.lv
        local statsType = stonePack.statsType
        local statsVal = stonePack.statsVal

        u:modStats(statsType, statsVal * lv)
    end

    local list2 = self.charmList
    for i, wisp in ipairs(list2) do
        if wisp.onToggle then
            fc.safeExecute(function()
                wisp.onToggle(u, true)
            end)
        end
    end

end
--------------------------------------------------------------------------------------
-- closure
local convertColor = function(name)
    return cst.COLOR_CODE[name]
end
--------------------------------------------------------------------------------------
function mt:getTotalLv()
    local ttl = 0
    for slotId = 1, 11 do
        local data = self.stoneList[slotId]
        if data then
            ttl = ttl + data.lv
        end
    end

    return ttl
end
--------------------------------------------------------------------------------------
function mt:getTotalType()
    local ttl = 0
    for slotId = 1, 11 do
        local data = self.stoneList[slotId]
        if data then
            ttl = ttl + 1
        end
    end

    return ttl
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
    print('refresh stone ui: ' .. slotId)

    if slotId <= 11 then
        local data = self.stoneList[slotId]
        if data then
            local stoneName = data.stoneName
            local stonePack = as.dataRegister:getTableData('stone', stoneName)
            local lv = data.lv
            local statsType = stonePack.statsType
            local icon = stonePack.icon
            local statsVal = stonePack.statsVal * lv

            local title = str.format('%s - [|cffffcc00%d级|r]', stoneName, lv)
            local tip = '|cffffcc00基础效果：|r'

            if cst:getConstTag(statsType, 'isPct') then
                tip = tip .. str.format('%s+%s', cst:getConstName(statsType), as.util:convertPct(statsVal))
            else
                tip = tip .. str.format('%s+%.0f', cst:getConstName(statsType), statsVal)
            end

            -- -- 赐福text 1
            -- local sec
            -- if data.element1 then
            --     local wisp = data.element1
            --     local wispName = wisp.name
            --     local elementType = wisp.elementType
            --     local wispTip = wisp.tip
            --     wispTip = string.gsub(wispTip, '%<([%w_.>]*)%>', convertColor)
            --     sec = str.format('|cffe2ff61%s|r - [%s]|n|n%s', wispName, cst.ELEMENT_NAME[elementType], wispTip)
            -- else
            --     sec =
            --         '|cffe2ff61初级元素赐福|r - [|cff9c9c9c还未解锁|r]|n|n 在该符文石达到2级时解锁。'
            -- end
            -- tip = tip .. '|n|n' .. sec

            -- -- 赐福text 2
            -- local sec
            -- if data.element2 then
            --     local wisp = data.element2
            --     local wispName = wisp.name
            --     local elementType = wisp.elementType
            --     local wispTip = wisp.tip
            --     wispTip = string.gsub(wispTip, '%<([%w_.>]*)%>', convertColor)
            --     sec = str.format('|cffff9b61%s|r - [%s]|n|n%s', wispName, cst.ELEMENT_NAME[elementType], wispTip)
            -- else
            --     sec =
            --         '|cffff9b61高级元素赐福|r - [|cff9c9c9c还未解锁|r]|n|n 在该符文石达到4级时解锁。'
            -- end
            -- tip = tip .. '|n|n' .. sec

            tip = tip .. '|n|n|cffffcc00左键点击以摧毁该符文石。|r'

            as.skill.setTitle(skillBtn, title)
            as.skill.setTip(skillBtn, tip)
            as.skill.setArt(skillBtn, icon)
        else
            if slotId <= self.maxStone then
                as.skill.setTitle(skillBtn, '空槽位')
                as.skill.setTip(skillBtn, '这个槽位还没有符文石。')
                as.skill.setArt(skillBtn, [[ReplaceableTextures\CommandButtons\BTNkongdefuwencaowei.blp]])
            else
                as.skill.setTitle(skillBtn, '未解锁的槽位')
                as.skill.setTip(skillBtn, '这个槽位还没有解锁。')
                as.skill.setArt(skillBtn, [[ReplaceableTextures\CommandButtons\BTNweijiesuofuwencaowei.blp]])
            end
        end
    end

    if slotId == 12 then

        local ttlLv = self:getTotalLv()

        local tip = str.format(
            '根据符文石的总等级，魔塔将解锁元素赐福，赋予元素射弹的新的特性，并且提升相应的元素羁绊点。|n|n|cffffcc00当前符文总等级：|r%d|n|n',
            ttlLv)

        for i, v in ipairs(mt.charmCondition) do
            local info = '-未解锁'
            local color = '|cffc0c0c0'
            local color2 = '|cffc0c0c0'
            local wisp = self.charmList[i]
            local sec = ''
            if wisp then
                color = '|cff92e940'
                color2 = '|cffffffff'

                local wispName = wisp.name
                local elementType = wisp.elementType
                local wispTip = wisp.tip
                wispTip = string.gsub(wispTip, '%<([%w_.>]*)%>', convertColor)
                local wispColor = '|cff61ffff'
                if wisp.isHigh then
                    wispColor = '|cffff619e'
                end
                sec = str.format(' - %s%s|r - [%s]', wispColor, wispName, cst.ELEMENT_NAME[elementType])

                info = '-' .. wispTip
            end
            tip = tip .. str.format('%s符文总等级Lv%d|r%s|n%s%s|r|n', color, v, sec, color2, info)
        end

        tip = tip .. '|n|cffffcc00左键点击来洗炼元素赐福|r'

        as.skill.setTitle(skillBtn, '元素赐福')
        as.skill.setTip(skillBtn, tip)
        as.skill.setArt(skillBtn, [[ReplaceableTextures\CommandButtons\BTNyuansucifu.blp]])
    end

    -- 刷新等级
    skillBtn.owner:setAbilityLevel(skillBtn.handle, 2)
    skillBtn.owner:setAbilityLevel(skillBtn.handle, 1)

end
--------------------------------------------------------------------------------------
function mt:giveStone(stoneName)
    local p = self.owner
    local maid = p.maid
    local pack = reg:getTableData('stone', stoneName)
    local itemTypeJ = pack.itemTypeJ

    local stone = fc.rewardUnitItem(itemTypeJ, maid)

    stone.share = true
    msg.notice(p, '成功鉴定获得了 [|cffffff00' .. stoneName .. '|r]！')

end
--------------------------------------------------------------------------------------
function mt:addSlot()
    self.maxStone = self.maxStone + 1
    self:refreshUI(-1)
end

--------------------------------------------------------------------------------------

return mt
