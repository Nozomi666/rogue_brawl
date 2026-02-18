local mt = {}

mt.equipWeight = {}

for i = 1, 75 do
    table.insert(mt.equipWeight, 1)
end
for i = 1, 20 do
    table.insert(mt.equipWeight, 2)
end
for i = 1, 5 do
    table.insert(mt.equipWeight, 3)
end
--------------------------------------------------------------------------------------
function mt:buyEquip(keys)
    local p = keys.p

    local hold = p:getResource(cst.RES_GOLD)
    local shot = keys.cfg.shot
    local price = keys.cfg.gold * shot
    local lv = keys.cfg.lv - 1

    if hold < price then
        as.message.error(p, '购买失败，金币不足。')
        return
    end

    -- shop success
    p:modResource(cst.RES_GOLD, price * -1)

    p.guideManager:checkComplete('装备')

    local c = 0

    local presentChance = keys.cfg.rewardChance
    if presentChance and p:getAttr('幸运挂饰') then
        presentChance = presentChance * 1.5
    end
    

    ac.timer(ms(0.03), shot, function()
        c = c + 1
        local pool = mt.equipWeight
        local equipLv = pool[math.random(#pool)]
        equipLv = equipLv + lv
        local equip = as.equip:createRandomEquip(p.equipPoint, equipLv, p)

        msg.notice(p,str.format('你获得了装备 %s 。', equip:getNameWithRare()))



    end)
end
--------------------------------------------------------------------------------------
function mt:buyUnlockSkill(keys)
    -- local p = keys.p
    -- local hold = p:getResource(cst.RES_GOLD)
    -- local cfg = keys.cfg
    -- local gold = cfg.gold
    -- local slot = cfg.slot

    -- local hasHero = false

    -- local box = p.pickBox
    -- box:clean()
    -- box:setTitle('选择要转职的英雄')
    -- for _, hero in ipairs(cands) do

    -- end
    -- box:addBtn('取消', nil, nil, KEY.ESC)
    -- box:showBox()


    -- for _, hero in ipairs(p.heroList) do
    --     local skill = hero.skillManager.skillAt[slot]
    --     if skill.pack.lockedSlot then
    --         hasHero = true

    --         local keys = {
    --             u = hero,
    --             p = p,
    --             gold=gold,
    --             slot = slot
    --         }
    --         box:addBtn(hero:getNameLv(), mt.confirmTransfer, keys, cst.PICK_BOX_HOT_KEY.NULL)
    --     end
    -- end
    
end
--------------------------------------------------------------------------------------
function mt.confirmTransfer(keys)
    local u = keys.u
    local p = keys.p
    local gold = keys.gold 
    local lum = keys.lum

    if p:getResource(cst.RES_GOLD) < gold then
        as.message.error(p, '购买失败，金币不足。')
        return
    end

    if p:getResource(cst.RES_LUMBER) < lum then
        as.message.error(p, '购买失败，木材不足。')
        return
    end

    p:modResource(cst.RES_GOLD, gold * -1)
    p:modResource(cst.RES_LUMBER, lum * -1)


    p:setAttribute('正在转职', true)
    --gdebug('选择了英雄 ' .. keys.u:getNameLv())
    u:tryUpClass()
end
--------------------------------------------------------------------------------------
function mt:buyUpclass(keys)
    local p = keys.p
    local cfg = keys.cfg
    local gold = cfg.gold 
    local lum = cfg.lum
    local lv = cfg.lv

    if p:getResource(cst.RES_GOLD) < gold then
        as.message.error(p, '购买失败，金币不足。')
        return
    end

    if p:getResource(cst.RES_LUMBER) < lum then
        as.message.error(p, '购买失败，木材不足。')
        return
    end

    local cands = {}
    
    if not next(cands) then
        as.message.error(p, '没有符合转职条件的英雄。')
        return -1
    end

    if p:getAttribute('正在转职') then
        as.message.error(p, '请先完成上一个英雄的转职。')
        return -1
    end

    local box = p.pickBox
    box:clean()
    box:setTitle('选择要转职的英雄')
    for _, hero in ipairs(cands) do
        local keys = {
            u = hero,
            p = p,
            gold=gold,
            lum = lum,
        }
        box:addBtn(hero:getNameLv(), mt.confirmTransfer, keys, cst.PICK_BOX_HOT_KEY.NULL)
    end
    box:addBtn('取消', nil, nil, KEY.ESC)
    box:showBox()

end
--------------------------------------------------------------------------------------

return mt
