local mt = {}
local event = require('game.__api.event')
PickBox = mt

mt.__index = mt

mt.owner = nil
mt.handle = nil
mt.btnList = nil
mt.title = nil
mt.protected = false

function mt:new(p)
    gdebug('create new pickbox, player: ' .. tostring(p))

    local o = {}
    setmetatable(o, self)

    o.owner = p
    o.handle = DialogCreate()
    o.btnList = {}

    HandleRegTable(o.handle, o)

    local trig = CreateTrigger()
    TriggerRegisterDialogEvent(trig, o.handle)
    TriggerAddAction(trig, event.pickBoxClick)
    dbg.handle_ref(trig)
    
    return o
end

--------------------------------------------------------------------------------------
function mt:boxj2t(boxJ)
    return HandleGetTable(boxJ) or nil
end
--------------------------------------------------------------------------------------
function mt:setProtected(isProtected)
    self.protected = isProtected
end

--------------------------------------------------------------------------------------
function mt:setTitle(words)
    if self.protected then
        return
    end
    -- DialogSetMessage(self.handle, words)
    self.title = words
    GUI.CustomPickbox:updateTitle(words)
end

--------------------------------------------------------------------------------------
function mt:addBtn(words, callback, keys, hotKey)
    if self.protected then
        return
    end

    if hotKey then
        if hotKey ~= cst.PICK_BOX_HOT_KEY.NULL then
            words = str.format('%s (%s)', words, KEY_STR[hotKey])
        end
    else
        hotKey = cst.PICK_BOX_HOT_KEY.NULL
    end
    
    -- local btnJ = DialogAddButton(self.handle, words, hotKey)
    local pack = {
        -- btnJ = btnJ,
        callback = callback,
        keys = keys,
        tip = words,
    }

    local list = self.btnList
    list[#list + 1] = pack


    -- DialogDisplay(self.owner.handle, self.handle, true)
end

--------------------------------------------------------------------------------------
function mt:showBox()
    -- DialogDisplay(self.owner.handle, self.handle, true)
    if self.owner:isLocal() then
        GUI.CustomPickbox:updateBtnInfo()
    end
end

--------------------------------------------------------------------------------------
function mt:btnClicked(btnJ)
    for i, pack in ipairs(self.btnList) do
        if pack.btnJ == btnJ then
            if pack.callback then
                pack.callback(pack.keys)
            end
            return
        end
    end
    
end
--------------------------------------------------------------------------------------
function mt:customUIBtnClicked(btnId)
    self:setProtected(false)
    local pack = self.btnList[btnId]
    self:clean()

    if pack then
        if pack.callback then
            pack.callback(pack.keys)
        end
    end

end
--------------------------------------------------------------------------------------
function mt:clean()
    if self.protected then
        return
    end

    self.btnList = {}
    self.title = ''
    if self.owner:isLocal() then
        GUI.CustomPickbox:hide()
    end
    -- for i, v in ipairs(self.btnList) do
    --     gdebug('dialog clean btn')
    --     gdebug(v.info)
    --     local btnJ = v.btnJ

    --     self.btnList[i] = nil
    -- end

    -- DialogClear(self.handle)
end

return mt