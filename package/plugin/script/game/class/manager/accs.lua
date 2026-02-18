local mt = {}
mt.__index = mt

mt.accsManager = nil
mt.cfg = nil
mt.book = nil
mt.packNow = nil

--------------------------------------------------------------------------------------
function mt:new(accsManager, cfg)
    -- init table

    local o = {}
    setmetatable(o, self)

    o.cfg = cfg
    o.accsManager = accsManager
    o.p = accsManager.p

    local setName = cfg.setName
    local dataSet = reg:getPool(setName)

    o.book = book.new(dataSet, 8)

    return o
end
--------------------------------------------------------------------------------------
function mt:toggle(pack)

    local p = self.p

    if not pack then
        return
    end

    if not self:isUnlocked(pack) then
        return
    end

    if not p.hero then
        return
    end

    if self.packNow then

        if self.packNow == pack then
            self:onDrop()
            return
        else
            self:onDrop()
        end

    end

    self:onEquip(pack)
end
--------------------------------------------------------------------------------------
function mt:onEquip(pack)

    if not pack then
        return
    end
    local name = pack.name
    local p = self.p

    if not self:isUnlocked(pack) then
        return
    end

    if pack.onToggle then
        pack.onToggle(self, true)
    end

    self.packNow = pack

    local p = self.p
    local name = pack.title
    msg.notice(p, str.format('成功装备了饰品[%s%s|r]。', cst.COLOR_YELLOW, name))
    gdebug(str.format('成功装备了饰品[%s%s|r], type: %s, archId: %d。', cst.COLOR_YELLOW, name, pack.type,
        pack.archId))

end
--------------------------------------------------------------------------------------
function mt:onDrop(saveRecord)
    local pack = self.packNow
    if not pack then
        return
    end

    if pack.onToggle then
        pack.onToggle(self, false)
    end

    self.packNow = nil

    local p = self.p
    local name = pack.title
    msg.notice(p, str.format('成功卸下了饰品[%s%s|r]。', cst.COLOR_YELLOW, name))

end
--------------------------------------------------------------------------------------
function mt:saveToArch(typeStr)
    local p = self.p
    local pack = self.packNow

    local phandle = p.handle
    local storageName = str.format('accs %s', typeStr)
    local storageId

    if pack then
        storageId = pack.archId
    else
        storageId = 0
    end

    code.saveServerInt(p.handle, storageName, storageId)

end
--------------------------------------------------------------------------------------
function mt:getTitle(pack)
    local word
    local p = self.p
    local name = pack.name

    if self:isUnlocked(pack) then
        if self.packNow == pack then
            word = str.format('卸下%s', pack.title)
        else
            word = str.format('装备%s', pack.title)
        end
    else
        word = str.format('%s%s|r', cst.COLOR_GRAY, pack.title)
    end

    return word
end
--------------------------------------------------------------------------------------
function mt:getTip(pack)
    local word = ''
    local p = self.p
    local name = pack.name
    if self:isUnlocked(pack) then
        if pack.unlockTip then
            word = word .. str.format('%s已激活：|r%s', cst.COLOR_YELLOW, pack.unlockTip)
        end
    else
        if pack.unlockTip then
            word = word ..
                       str.format('%s解锁效果：|r%s|n|n%s还未解锁|r', cst.COLOR_GRAY, pack.unlockTip,
                    cst.COLOR_GRAY)
        end
    end

    return word
end
--------------------------------------------------------------------------------------
function mt:getArt(pack)
    local word = ''
    local p = self.p
    local name = pack.name

    if self:isUnlocked(pack) then
        word = pack.art
    else
        word = pack.artDark
    end

    return word
end
--------------------------------------------------------------------------------------
function mt:isUnlocked(pack)
    local p = self.p
    local name = pack.name
    local relatedArchName = pack.relatedArchName

    if relatedArchName then
        name = relatedArchName
    end

    -- if localEnv then
    --     return true
    -- end

    return p:hasArch(name)
end
--------------------------------------------------------------------------------------
-- function mt:onClick(btnId)

--     local pack = self.pack

--     if pack.onClick then
--         pack.onClick(self, btnId)
--     end

-- end
-- --------------------------------------------------------------------------------------
-- function mt:onUpdate(btnId)
--     local pack = self.pack

--     if pack.onUpdate then
--         pack.onUpdate(self, btnId)
--     end
-- end
--------------------------------------------------------------------------------------

return mt
