local mt = test

--------------------------------------------------------------------------------------
-- @param
function mt:testEquip2(keys)
    local p = keys.p
    -- local unit = p.lastPick
    -- fc.flyItemByName('中级装备盲盒', p, p.hero:getloc(), p.rewardPoint)
    -- fc.flyItemByName('初级装备盲盒', p, p.hero:getloc(), p.rewardPoint)
    -- fc.flyItemByName('高级装备盲盒', p, p.hero:getloc(), p.rewardPoint)
    -- fc.flyItemByName('装备盲盒', p, p.hero:getloc(), p.rewardPoint)
    -- fc.flyItemByName('激励礼盒', p, p.hero:getloc(), p.rewardPoint)
    -- fc.flyItemByName('升级石', p, p.hero:getloc(), p.rewardPoint)
    -- fc.flyItemByName('命运石', p, p.hero:getloc(), p.rewardPoint)
    -- fc.flyItemByName('红包', p, p.hero:getloc(), p.rewardPoint)
    -- fc.flyItemByName('空间杀器', p, p.hero:getloc(), p.rewardPoint)

end
--------------------------------------------------------------------------------------
function mt:testEquip(keys)
    local p = keys.p
    local unit = p.maid
    local itemName = keys.args[1]
    local num = tonumber(keys.args[2] or 1)

    if itemName then
        for i = 1, num do
            local args = {
                name = itemName,
                holder = unit,
                owner = p,
            }
            local equip = as.equip:makeEquip(args)
        end

    else
        local list = {
            '王权印戒',
            '狮鹫战甲',
            '黑曜重弩',
            '猎魔银枪',
            '冥烛之杖',
            '烬影大剑',
            '堕翼封印卷',
            '水银箭矢',
            '兽魂灵龛',
            '波动斗篷',
            '鹰眼',
        }
        for i = 1, #list, 1 do
            local args = {
                name = list[i],
                holder = unit,
                owner = p,
            }
            local equip = as.equip:makeEquip(args)
        end
    end

end
--------------------------------------------------------------------------------------
function mt:testEat(keys)
    local p = keys.p
    local hero = p.hero
    local item = as.item:getUnitSlotItem(hero, 1)

    item:tryEat(p)

end
--------------------------------------------------------------------------------------
function mt:testRollPoint(keys)
    local p = keys.p
    local hero = p.hero
    p:modStats(RES_ROLL, 100)
end
--------------------------------------------------------------------------------------
function mt:testElementModeEquip(keys)
    local p = keys.p
    local unit = p.hero
    local args = {
        name = '6阶元素装备',
        holder = unit,
        owner = p,
    }
    local equip = as.equip:makeElementAbyssModeEquip(args)
end
--------------------------------------------------------------------------------------
test.act['eq'] = mt.testEquip
test.act['eat'] = mt.testEat
test.act['rollpt'] = mt.testRollPoint

test.act['ee'] = mt.testElementModeEquip
