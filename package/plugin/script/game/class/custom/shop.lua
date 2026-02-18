local mt = {}

require 'game.class.custom.unit'
mt.__index = mt
setmetatable(mt, cg.Unit)
cg.Shop = mt

mt.parent = cg.Unit

mt.skillBtn = nil
--------------------------------------------------------------------------------------
function mt:new(keys)

    local name = keys.name
    gdebug('shop name is: ' .. name)
    local pack = fc.getAttr('shop_pack', name)
    local uType = pack.uType
    local player = keys.player

    gdebug('shop uType is: ' .. uType)

    -- init table
    local o = cg.Unit:createUnit(player, uType, keys.point, keys.face)
    setmetatable(o, pack)

    o.skillBtn = {}

    if o.onInit then
        o:onInit(keys)
    end

    player[name] = o

    o.hide_life_bar = true
    o.bHideHpText = true
    -- -- 初始化按钮
    -- for i = 1, 12 do

    --     local function initAct(skill)
    --         -- mt:setOptionEmpty(skill)
    --         skill.btnId = i
    --         skill.callback = mt.onClick
    --     end

    --     -- local skillBtn = as.skill:new(o, 'SkillShop', pId .. '@' .. i, {}, 1, initAct)
    --     -- skillBtn.banCastEffect = true;
    --     -- o.skillBtn[i] = skillBtn

    --     -- if i ~= 4 and i ~= 8 then
    --     --     skillBtn:setCd(1)
    --     -- end

    -- end


    local eventPack = {
        name = 'on_pick_event',
        condition = UNIT_EVENT_ON_PICK,
        callback = mt.onMousePick,
        self = self,
    }
    o:addEvent(eventPack)

    return o
end
--------------------------------------------------------------------------------------
function mt:onMousePick(p, u, isPick)
    local self = u

    if u.owner ~= p then
        return
    end

    for i = 1, 12 do
        local skillBtn = self.skillBtn[i]
        if skillBtn then
            if isPick then
                skillBtn:onUnitGetPicked()
            else
                skillBtn:onUnitCancelPicked()
            end
        end
    end

    -- if p:isLocal() then
    --     if isPick then
    --         GUI.ShopBuyer:show()
    --         GUI.BodyReformPanel:hide()
    --         toolbox:hide()
    --     else
    --         GUI.ShopBuyer:hide()
    --         GUI.BodyReformPanel:show()
    --     end
    -- end

end
--------------------------------------------------------------------------------------
function mt:createShops()

    local list = {}

    local shopFace = {
        [1] = 270,
        [2] = 270,
        [3] = 90,
        [4] = 90
    }


    -- for i = 1, 4 do
    --     local point = gm.mapArea:getShopPosition({
    --         pId = i,
    --         shopId = 1
    --     })

    --     local unitJ = CreateUnit(Player(PLAYER_NEUTRAL_PASSIVE), ID('h003'), point[1], point[2], shopFace[i])
    --     local unit = cg.BaseUnit:link(unitJ)
    --     unit.shopName = '装备商店'
    --     unit:addEvent({
    --         name = 'on_pick_event',
    --         condition = UNIT_EVENT_ON_PICK,
    --         callback = cg.Shop.onSelectDummyShop,
    --         self = unit
    --     })
    --     unit.hide_life_bar = true
    --     unit.bHideHpText = true

    --     local point = unit:getloc()
    --     local pointT = fc.polarPoint(point, 80, 90)
    --     unit.shopEffect = fc.pointEffect({
    --         model = [[zbchenghao.mdx]],
    --         size = 2,
    --         time = -1,
    --     }, pointT)
    -- end

    -- for i = 1, 4 do
    --     local point = gm.mapArea:getShopPosition({
    --         pId = i,
    --         shopId = 2
    --     })

    --     local unitJ = CreateUnit(Player(PLAYER_NEUTRAL_PASSIVE), ID('h003'), point[1], point[2], shopFace[i])
    --     local unit = cg.BaseUnit:link(unitJ)
    --     unit.shopName = '荣誉商店'
    --     unit:addEvent({
    --         name = 'on_pick_event',
    --         condition = UNIT_EVENT_ON_PICK,
    --         callback = cg.Shop.onSelectDummyShop,
    --         self = unit
    --     })
    --     unit.hide_life_bar = true
    --     unit.bHideHpText = true

    --     local point = unit:getloc()
    --     local pointT = fc.polarPoint(point, 80, 90)
    --     fc.pointEffect({
    --         model = [[sd.mdx]],
    --         size = 2,
    --         time = -1,
    --     }, pointT)
    -- end


end
--------------------------------------------------------------------------------------
function mt:initBtn(keys)
    local slotId = keys.slotId
    local btnCode = self.btnCode
    local pId = self.player.id

    local skillBtn
    if not self.skillBtn[slotId] then
        skillBtn = cg.SkillBtn:newFlexBtn(self, btnCode, str.format('%d@%d', pId, slotId), slotId)
        self.skillBtn[slotId] = skillBtn
    else
        skillBtn = self.skillBtn[slotId]
    end

    keys.skillBtn = skillBtn
    skillBtn.shopKeys = keys

    if keys.onRefresh then
        keys.onRefresh(self, skillBtn)
    end
    

    return skillBtn
end
--------------------------------------------------------------------------------------
function mt:initializeCD(skillBtn, time)
    skillBtn:setCd(time)
    skillBtn:updateCd(time)
    ac.wait(ms(time), function()
        skillBtn:setCd(0)
    end)
end
--------------------------------------------------------------------------------------
function mt:onClick(keys)

    local self = keys.u
    local p = self.owner

end
--------------------------------------------------------------------------------------
function mt:onSelectDummyShop(p, u, isPick)
    -- gdebug('dummy 商店 click')
    local shopName = u.shopName
    local realShop = p[shopName]

    p:forcePickUnit(realShop)
end
--------------------------------------------------------------------------------------
