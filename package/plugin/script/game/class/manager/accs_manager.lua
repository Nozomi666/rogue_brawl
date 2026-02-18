local mt = {}
mt.__index = mt
AccsManager = mt

mt.p = nil
mt.player = nil
mt.route = nil
mt.accsNow = nil
mt.accsList = nil -- list
mt.accsHashTable = nil -- ht
mt.skillBtn = nil
mt.mainBook = nil

mt.ROUTE_MAIN = 'route_main'
mt.ROUTE_PART = 'route_part'

mt.TYPE_SKIN = 'maidSkin'
mt.TYPE_AURA = 'heroAura'
mt.TYPE_WINGS = 'wings'
mt.TYPE_ROUNDER = 'rounder'
mt.TYPE_TAIL = 'tail'
mt.TYPE_TITLE = 'title'

mt.currentBook = nil

--------------------------------------------------------------------------------------
function mt:new(player)
    local p = player
    local pId = p.id

    -- init table
    local o = {}
    setmetatable(o, self)

    o.skillBtn = {}
    o.route = mt.ROUTE_MAIN
    o.p = p
    o.player = p

    -- for i = 1, 11 do
    --     local pk = 'AccessoryBoard'
    --     local ck = pId .. '@' .. i
    --     local typeHandle = cg.SkillBtn:getSkillModel(pk, ck)
    --     local skillBtn = cg.SkillBtn:bindExist(u, typeHandle)
    --     skillBtn.banCastEffect = true
    --     skillBtn.skillPack.targetType = 0
    --     o.skillBtn[i] = skillBtn
    --     --------------------------------------------------------------------------------------
    --     skillBtn.btnId = i
    --     skillBtn.callback = mt.onClick
    --     --------------------------------------------------------------------------------------

    -- end

    o.accsList = {}
    o.accsHashTable = {}

    -- 
    o:initAccs(mt.TYPE_SKIN)
    o:initAccs(mt.TYPE_WINGS)
    o:initAccs(mt.TYPE_AURA)
    o:initAccs(mt.TYPE_ROUNDER)
    o:initAccs(mt.TYPE_TAIL)
    o:initAccs(mt.TYPE_TITLE)
    o.mainBook = book.new(o.accsList, 8)

    o.currentBook = book.new(reg:getPool('maidSkin'), 20)
    -- o:refreshUI(-1)

    return o
end
--------------------------------------------------------------------------------------
function mt:initAccs(type)

    local cfg = {}

    cfg.type = type

    if type == mt.TYPE_SKIN then
        cfg.title = [[更换皮肤]]
        cfg.tip = [[更换助手皮肤]]
        cfg.art = [[ReplaceableTextures\CommandButtons\BTNgenghuanpifu.blp]]
        cfg.setName = [[maidSkin]]
    elseif type == mt.TYPE_WINGS then
        cfg.title = [[更换翅膀]]
        cfg.tip = [[更换英雄翅膀]]
        cfg.art = [[ReplaceableTextures\CommandButtons\BTNgenghuanchibang.blp]]
        cfg.setName = [[wings]]
    elseif type == mt.TYPE_AURA then
        cfg.title = [[更换光环]]
        cfg.tip = [[更换英雄光环]]
        cfg.art = [[ReplaceableTextures\CommandButtons\BTNgenghuanguanghuan.blp]]
        cfg.setName = [[heroAura]]
    elseif type == mt.TYPE_ROUNDER then
        cfg.title = [[更换环绕]]
        cfg.tip = [[更换英雄环绕]]
        cfg.art = [[ReplaceableTextures\CommandButtons\BTNgenghuanhuanrao.blp]]
        cfg.setName = [[rounder]]
    elseif type == mt.TYPE_TAIL then
        cfg.title = [[更换拖尾]]
        cfg.tip = [[更换英雄拖尾]]
        cfg.art = [[ReplaceableTextures\CommandButtons\BTNgenghuantuowei.blp]]
        cfg.setName = [[tail]]
    elseif type == mt.TYPE_TITLE then
        cfg.title = [[更换称号]]
        cfg.tip = [[更换英雄称号]]
        cfg.art = [[ReplaceableTextures\CommandButtons\BTNgenghuanchenghao.blp]]
        cfg.setName = [[title]]
    end
    -- ...

    local accs = as.accs:new(self, cfg)
    self.accsHashTable[cfg.setName] = accs
    table.insert(self.accsList, accs)

end
--------------------------------------------------------------------------------------
function mt:loadLastGameSettings()
    self:readLastGameAccs(mt.TYPE_SKIN)
    self:readLastGameAccs(mt.TYPE_AURA)
    self:readLastGameAccs(mt.TYPE_WINGS)
    self:readLastGameAccs(mt.TYPE_ROUNDER)
    self:readLastGameAccs(mt.TYPE_TAIL)
    self:readLastGameAccs(mt.TYPE_TITLE)
end
--------------------------------------------------------------------------------------
function mt:dropAllAccs()
    self:dropAccs(mt.TYPE_SKIN)
    self:dropAccs(mt.TYPE_AURA)
    self:dropAccs(mt.TYPE_WINGS)
    self:dropAccs(mt.TYPE_ROUNDER)
    self:dropAccs(mt.TYPE_TAIL)
    self:dropAccs(mt.TYPE_TITLE)
end
--------------------------------------------------------------------------------------
function mt:getCurrentBook()
    return self.currentBook
end
--------------------------------------------------------------------------------------
function mt:setCurrentBook(className)
    self.currentBook = book.new(reg:getPool(className), 20)
end
--------------------------------------------------------------------------------------
function mt:hasEquipedAccs(accsName)
    local pack = reg:getTableData('accsTable', accsName)
    local player = self.player
    if not self:hasAccs(accsName) then
        return
    end

    local accsType = pack.type
    local accs = self.accsHashTable[accsType]

    local packNow = accs.packNow
    if packNow then
        local packName = packNow.name
        return packName == accsName
    end

    return
end
--------------------------------------------------------------------------------------
function mt:tryToggleAccs(accsName)
    local pack = reg:getTableData('accsTable', accsName)
    local player = self.player
    if not self:hasAccs(accsName) then
        return
    end

    local accsType = pack.type
    local accs = self.accsHashTable[accsType]

    accs:toggle(pack)

    self:saveAccs(accsType)

end
--------------------------------------------------------------------------------------
function mt:hasAccs(accsName)
    local pack = reg:getTableData('accsTable', accsName)
    local player = self.player
    local name = pack.name
    local relatedArchName = pack.relatedArchName

    if relatedArchName then
        name = relatedArchName
    end
    
    -- if localEnv then
    --     return true
    -- end

    return player:hasArch(name)
end
--------------------------------------------------------------------------------------
function mt:onClick(keys)
    local u = keys.u
    local p = u.owner
    local self = u.accsManager
    local skillBtn = keys.skillBtn
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
function mt:clickMain(slotId)
    local skillBtn = self.skillBtn[slotId]
    local mainBook = self.mainBook
    local list = mainBook:getCurrentPage()

    if slotId <= 8 then
        local accs = list[slotId]
        if accs then
            local cfg = accs.cfg
            self.route = mt.ROUTE_PART
            self.accsNow = accs

        end
    elseif slotId == 9 then
        self:readLastGameAccs(mt.TYPE_SKIN)
        self:readLastGameAccs(mt.TYPE_AURA)
        self:readLastGameAccs(mt.TYPE_WINGS)
        self:readLastGameAccs(mt.TYPE_ROUNDER)
        self:readLastGameAccs(mt.TYPE_TAIL)
        self:readLastGameAccs(mt.TYPE_TITLE)
    elseif slotId == 10 then
        self:saveAccs(mt.TYPE_SKIN)
        self:saveAccs(mt.TYPE_AURA)
        self:saveAccs(mt.TYPE_WINGS)
        self:saveAccs(mt.TYPE_ROUNDER)
        self:saveAccs(mt.TYPE_TAIL)
        self:saveAccs(mt.TYPE_TITLE)
    elseif slotId == 11 then
        self:dropAccs(mt.TYPE_SKIN)
        self:dropAccs(mt.TYPE_AURA)
        self:dropAccs(mt.TYPE_WINGS)
        self:dropAccs(mt.TYPE_ROUNDER)
        self:dropAccs(mt.TYPE_TAIL)
        self:dropAccs(mt.TYPE_TITLE)
    end

end
--------------------------------------------------------------------------------------
function mt:readLastGameAccs(typeStr)
    local player = self.p
    local archId = code.loadServerInt(player.handle, str.format('accs %s', typeStr))
    gdebug('读取上局饰品 typeStr %s', archId, typeStr)
    if archId > 0 then
        local accs = self.accsHashTable[typeStr]
        local accsPool = reg:getPool(typeStr)
        local accsPack = accsPool[archId]
        if accsPack then
            gdebug('读取上局饰品配置，id: %d, name: %s', archId, accsPack.name)

            if accs.packNow then
                accs:onDrop()
            end
            accs:toggle(accsPack)
        end
    end

end
--------------------------------------------------------------------------------------
function mt:dropAccs(typeStr)
    local accs = self.accsHashTable[typeStr]
    if accs.packNow then
        accs:onDrop()
    end
    accs:saveToArch(typeStr)
end
--------------------------------------------------------------------------------------
function mt:saveAccs(typeStr)
    local accs = self.accsHashTable[typeStr]
    accs:saveToArch(typeStr)
end
--------------------------------------------------------------------------------------
function mt:refreshMain(slotId)
    local skillBtn = self.skillBtn[slotId]
    local title, tip, art = '', '', ''
    local mainBook = self.mainBook
    local list = mainBook:getCurrentPage()

    if slotId <= 8 then

        local accs = list[slotId]
        if accs then
            local cfg = accs.cfg

            title = cfg.title
            tip = cfg.tip
            art = cfg.art
            skillBtn:show()
        else
            skillBtn:hide()
        end

    elseif slotId == 9 then
        title = '读取饰品配置'
        tip = '一键读取保存的饰品配置'
        art = [[ReplaceableTextures\CommandButtons\BTNDispelMagic.blp]]
        skillBtn:show()
    elseif slotId == 10 then
        title = '保存饰品配置'
        tip = '保存当前的饰品配置'
        art = [[ReplaceableTextures\CommandButtons\BTNInvisibility.blp]]
        skillBtn:show()
    elseif slotId == 11 then
        title = '卸下所有饰品'
        tip = '一键卸下所有饰品配置'
        art = [[ReplaceableTextures\CommandButtons\BTNInvisibility.blp]]
        skillBtn:show()
    else

        skillBtn:hide()
    end

    cg.SkillBtn.setTitle(skillBtn, title)
    cg.SkillBtn.setTip(skillBtn, tip)
    cg.SkillBtn.setArt(skillBtn, art)

    -- 刷新等级
    skillBtn.owner:setAbilityLevel(skillBtn.handle, 2)
    skillBtn.owner:setAbilityLevel(skillBtn.handle, 1)
end
--------------------------------------------------------------------------------------
function mt:clickPart(slotId)
    local skillBtn = self.skillBtn[slotId]
    local accs = self.accsNow
    local book = book
    book = accs.book
    local list = book:getCurrentPage()

    if slotId <= 8 then
        local pack = list[slotId]
        if pack then
            accs:toggle(pack)
        end

    elseif slotId == 9 then
        book:pageLeft()
    elseif slotId == 10 then
        book:pageRight()
    elseif slotId == 11 then
        self.route = mt.ROUTE_MAIN
    end

end
--------------------------------------------------------------------------------------
function mt:refreshPart(slotId)
    local skillBtn = self.skillBtn[slotId]
    local title, tip, art = '', '', ''
    local accs = self.accsNow
    local book = accs.book
    local list = book:getCurrentPage()

    if slotId <= 8 then

        local pack = list[slotId]
        if pack then

            title = accs:getTitle(pack)
            tip = accs:getTip(pack)
            art = accs:getArt(pack)

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
    elseif slotId == 11 then
        title = '返回主页'
        tip = '返回饰品界面的主页面'
        art = [[ReplaceableTextures\CommandButtons\BTNshipinfanhui.blp]]
        skillBtn:show()
    else
        skillBtn:hide()
    end

    cg.SkillBtn.setTitle(skillBtn, title)
    cg.SkillBtn.setTip(skillBtn, tip)
    cg.SkillBtn.setArt(skillBtn, art)

    -- 刷新等级
    skillBtn.owner:setAbilityLevel(skillBtn.handle, 2)
    skillBtn.owner:setAbilityLevel(skillBtn.handle, 1)

end
--------------------------------------------------------------------------------------
function mt:refreshUI(slotId)

    if slotId == -1 then
        for i = 1, 11 do
            self:refreshUI(i)
        end
        return
    end

    -- gdebug(str.format('route: %s', self.route))

    if self.route == mt.ROUTE_MAIN then
        self:refreshMain(slotId)
    elseif self.route == mt.ROUTE_PART then
        self:refreshPart(slotId)
    end

end
--------------------------------------------------------------------------------------

return mt
