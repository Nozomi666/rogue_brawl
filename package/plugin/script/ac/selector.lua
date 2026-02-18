local jass = require 'jass.common'
local dbg = require 'jass.debug'
local math = math
local table = table
local table_insert = table.insert
local table_sort = table.sort
local setmetatable = setmetatable
local ipairs = ipairs
local math_angle = ac.math_angle
local math_abs = math.abs
local math_random = math.random

local dummy_group = jass.CreateGroup()
dbg.handle_ref(dummy_group)
local GroupEnumUnitsInRange = jass.GroupEnumUnitsInRange
local FirstOfGroup = jass.FirstOfGroup
local GroupRemoveUnit = jass.GroupRemoveUnit
-- local ac_unit = ac.unit
local ac_unit = as.unit

local mt = {}
local api = {}
mt.__index = api

api.type = 'selector'

api.filter_in = 0

api.center = {}
function api.center:get_point()
    return ac.point(0, 0)
end

api.r = 99999

-- 筛选条件
api.filters = nil

-- 允许选择无敌单位
api.is_allow_god = false
api.is_allow_dead = false

-- 自定义条件
function api:add_filter(f)
    table_insert(self.filters, f)
    return self
end

-- 圆形范围
--	圆心
--	半径
function api:inRange(p, r)
    error('inRange is deprecated, use inRangeEnemy or inRangeAlly instead.')
    self.filter_in = -1
    self.center = p
    self.r = r
    return self
end

function api:inRangeEnemy(p, r, u)
    self.filter_in = 0
    self.center = p
    self.r = r
    self.catchEnemy = true
    self.baseUnit = u
    self.catchAll = false
    return self
end

function api:inRangeAlly(p, r, u)
    self.filter_in = 0
    self.center = p
    self.r = r
    self.catchEnemy = false
    self.baseUnit = u
    self.catchAll = false
    return self
end

function api:inRangeAll(p, r, u)
    self.filter_in = 0
    self.center = p
    self.r = r
    self.baseUnit = u
    self.catchAll = true
    return self
end

function api:allPlayerHeros()
    self.filter_in = 3
    return self
end

function api:teamHeros(p)
    self.filter_in = 4
    self.player = p
    return self
end

-- 扇形范围
--	圆心
--	半径
--	角度
--	区间
function api:in_sector(p, r, angle, section)
    self.filter_in = 1
    self.center = p
    self.r = r
    self.angle = angle
    self.section = section
    return self
end

-- 直线范围
--	起点
--	角度
--	长度
--	宽度
function api:in_line_enemy(u, p, angle, len, width)
    self.filter_in = 2
    self.center = p
    self.angle = angle
    self.len = len
    self.width = width
    self.baseUnit = u
    self.catchEnemy = true
    return self
end

function api:in_line(u, p, angle, len, width)
    self.filter_in = 2
    self.center = p
    self.angle = angle
    self.len = len
    self.width = width
    self.baseUnit = u
    self.catchAll = true
    return self
end

-- 不是指定单位
--	单位
function api:is_not(u)
    return self:add_filter(function(dest)
        return dest ~= u
    end)
end

function api:isNot(u)
    return self:add_filter(function(dest)
        return dest ~= u
    end)
end

-- 非幻象
function api:isNotIllusion()
    return self:add_filter(function(dest)
        return not dest.isIllusion
    end)
end

-- 自定义条件
function api:condition(func)
    return self:add_filter(func)
end

-- 是敌人
--	参考单位/玩家
function api:isEnemy(u)
    return self:add_filter(function(dest)
        return dest:isEnemy(u)
    end)
end

-- 是友军
--	参考单位/玩家
function api:isAlly(u)
    return self:add_filter(function(dest)
        return dest:isAlly(u)
    end)
end

-- custom
function api:isTideEnemy()
    return self:add_filter(function(dest)
        return dest.bTideEnemy
    end)
end

function api:isHero()
    return self:add_filter(function(dest)
        return dest:isHero()
    end)
end

function api:isPlayerAliveHero()
    return self:add_filter(function(dest)
        return dest:isHero() and dest.player:isAlive()
    end)
end

-- 不在单位组内
function api:notInGroup(g)
    return self:add_filter(function(dest)
        return g[dest] == nil
    end)
end

-- 是boss
function api:isBoss()
    return self:add_filter(function(dest)
        return dest.eType and dest.eType == ENEMY_TYPE_BOSS
    end)
end

-- --必须是英雄
-- function api:of_hero()
-- 	return self:add_filter(function(dest)
-- 		return dest:is_type('英雄')
-- 	end)
-- end

-- --必须不是英雄
-- function api:of_not_hero()
-- 	return self:add_filter(function(dest)
-- 		return not dest:is_type('英雄')
-- 	end)
-- end

-- --必须是建筑
-- function api:of_building()
-- 	return self:add_filter(function(dest)
-- 		return dest:is_type('建筑')
-- 	end)
-- end

-- --必须不是建筑
-- function api:of_not_building()
-- 	return self:add_filter(function(dest)
-- 		return not dest:is_type('建筑')
-- 	end)
-- end

-- 必须是可见的
-- function api:of_visible(u)
-- 	return self:add_filter(function(dest)
-- 		return dest:is_visible(u)
-- 	end)
-- end

-- function api:of_illusion()
-- 	return self:add_filter(function(dest)
-- 		return dest:is_illusion()
-- 	end)
-- end

-- function api:of_not_illusion()
-- 	return self:add_filter(function(dest)
-- 		return not dest:is_illusion()
-- 	end)
-- end

-- 可以是无敌单位
function api:allow_god()
    self.is_allow_god = true
    return self
end

-- 可以是死亡单位
function api:allow_dead()
    self.is_allow_dead = true
    return self
end

-- 对选取到的单位进行过滤
function api:do_filter(u)

    if (not self.is_allow_god) and ((GetUnitAbilityLevel(u.handle, ID('Avul')) ~= 0)) then -- temp 检测无敌
        return false
    end
    if not self.is_allow_dead and not u:isAlive() then
        return false
    end
    -- 忽视蝗虫
    for i = 1, #self.filters do
        local filter = self.filters[i]
        if not filter(u) then
            return false
        end
    end
    return true
end

-- 对选取到的单位进行排序
function api:set_sorter(f)
    self.sorter = f
    return self
end

-- 排序权重：和poi的距离
function api:sort_farest(poi)
    local poi = poi:get_point()
    return self:set_sorter(function(u1, u2)
        return u1:get_point() * poi > u2:get_point() * poi
    end)
end

-- 排序权重：和poi的距离
function api:sort_nearest(poi)
    local poi = poi:get_point()
    return self:set_sorter(function(u1, u2)
        return u1:get_point() * poi < u2:get_point() * poi
    end)
end

-- 排序权重：血百分比最少的
function api:sort_hp_lowest_pct()
    return self:set_sorter(function(u1, u2)
        return u1:getStats(ST_HP_PCT) < u2:getStats(ST_HP_PCT)
    end)
end

-- 排序权重：血百分比最多的
function api:sort_hp_most_pct()
    return self:set_sorter(function(u1, u2)
        return u1:getStats(ST_HP_PCT) > u2:getStats(ST_HP_PCT)
    end)
end

-- 排序权重：血数值最少的
function api:sort_hp_lowest()
    return self:set_sorter(function(u1, u2)
        return u1:getStats(ST_HP) < u2:getStats(ST_HP)
    end)
end

-- 排序权重：血数值最多的
function api:sort_hp_most()
    return self:set_sorter(function(u1, u2)
        return u1:getStats(ST_HP) > u2:getStats(ST_HP)
    end)
end

-- 排序权重：1、英雄 2、和poi的距离
function api:sort_nearest_hero(poi)
    local poi = poi:get_point()
    return self:set_sorter(function(u1, u2)
        if u1:is_hero() and not u2:is_hero() then
            return true
        end
        if not u1:is_hero() and u2:is_hero() then
            return false
        end
        return u1:get_point() * poi < u2:get_point() * poi
    end)
end

function api:sort_nearest_type_hero(poi)
    local poi = poi:get_point()
    return self:set_sorter(function(u1, u2)
        if u1:is_type('英雄') and not u2:is_type('英雄') then
            return true
        end
        if not u1:is_type('英雄') and u2:is_type('英雄') then
            return false
        end
        return u1:get_point() * poi < u2:get_point() * poi
    end)
end

local selectFunc = {}

selectFunc[0] = function(self, select_unit)
    --	圆形选取
    local p = self.center:get_point()
    local x, y = p()
    local r = self.r
    local catchEnemy = self.catchEnemy
    local catchAll = self.catchAll
    local baseUnit = self.baseUnit

    -- if gm.state == GAME_STATE_ARTIFACT then
    --     r = r + 500
    -- end

    if PROCESS_SELECTOR_WAY == 1 then

        --------------------------------------------------------------------------------------
        -- 新版处理方式
        if catchAll then
            for unit in pairs(UnitManager.playerUnitList) do
                if unit.lastMomentPosition * p <= r and unit:isAlive() and self:do_filter(unit) then
                    select_unit(unit)
                end
            end
            for unit in pairs(UnitManager.enemyUnitList) do
                if unit.lastMomentPosition * p <= r and unit:isAlive() and self:do_filter(unit) then
                    select_unit(unit)
                end
            end
        else
            if IsUnitEnemy(baseUnit.handle, ConvertedPlayer(1)) then
                catchEnemy = not catchEnemy
            end
            local catchGroup = UnitManager.playerUnitList
            if catchEnemy then
                catchGroup = UnitManager.enemyUnitList
            end

            for unit in pairs(catchGroup) do
                if unit.lastMomentPosition * p <= r and unit:isAlive() and self:do_filter(unit) then
                    select_unit(unit)
                end
            end
        end
    elseif PROCESS_SELECTOR_WAY == 0 then
        --------------------------------------------------------------------------------------
        -- 老版处理方式
        GroupEnumUnitsInRange(dummy_group, x, y, r, nil)
        local u
        while true do
            u = FirstOfGroup(dummy_group)
            if u == 0 then
                break
            end
            GroupRemoveUnit(dummy_group, u)
            -- local u = ac_unit(u) 
            u = as.unit:uj2t(u) or as.unit:new(u)
            -- if u and u:is_in_range(p, r) and self:do_filter(u) then
            if u and self:do_filter(u) then
                if catchAll or (catchEnemy and u:isEnemy(baseUnit)) or (not catchEnemy and u:isAlly(baseUnit)) then
                    select_unit(u)
                end
            end
        end
    end

end
--------------------------------------------------------------------------------------
function fc.filterGroupInLine(group, start, length, width, angle)
    if not group then
        return {}
    end
    local target = as.point:polarPoint(start, length, angle)
    local x1, y1 = start()
    local x2, y2 = target()

    local a, b = y1 - y2, x2 - x1
    local c = -a * x1 - b * y1
    local l = (a * a + b * b) ^ 0.5
    local w = width / 2
    local r = length / 2

    local x, y = (x1 + x2) / 2, (y1 + y2) / 2
    local p = ac.point:new(x, y)

    local maxwr = math.max(w, r)

    local newGroup = {}
    for i = #group, 1, -1 do
        local unit = group[i]
        if unit.lastMomentPosition * p <= maxwr then
            local pt = unit.lastMomentPosition
            local x, y = pt[1], pt[2]
            local d = math_abs(a * x + b * y + c) / l

            if d <= w then
                newGroup[#newGroup + 1] = unit
            end
        end
    end

    return newGroup
end
--------------------------------------------------------------------------------------
-- 进行选取
function api:select(select_unit)
    if self.filter_in == 0 then
        selectFunc[self.filter_in](self, select_unit)
    elseif self.filter_in == 1 then
        --	扇形选取
        local p = self.center:get_point()
        local x, y = p()
        local r = self.r
        local angle = self.angle
        local section = self.section / 2
        GroupEnumUnitsInRange(dummy_group, x, y, r, nil)
        local u
        while true do
            u = FirstOfGroup(dummy_group)

            if u == 0 then
                break
            end
            GroupRemoveUnit(dummy_group, u)
            local u = as.unit:uj2t(u) or as.unit:new(u)
            -- if u and u:is_in_range(p, r) and math_angle(angle, p / u:get_point()) <= section and self:do_filter(u) then
            if u and math_angle(angle, p / u:getLoc()) <= section and self:do_filter(u) then
                select_unit(u)
            end
        end
    elseif self.filter_in == 2 then
        --	直线选取
        local start = self.center:get_point()
        local target = as.point:polarPoint(start, self.len, self.angle)
        local x1, y1 = start()
        local x2, y2 = target()

        local a, b = y1 - y2, x2 - x1
        local c = -a * x1 - b * y1
        local l = (a * a + b * b) ^ 0.5
        local w = self.width / 2
        local r = self.len / 2

        local x, y = (x1 + x2) / 2, (y1 + y2) / 2
        local p = ac.point:new(x, y)

        local baseUnit = self.baseUnit
        local catchEnemy = self.catchEnemy
        if IsUnitEnemy(baseUnit.handle, ConvertedPlayer(1)) then
            catchEnemy = not catchEnemy
        end
        local catchAll = self.catchAll
        local catchGroup
        if not catchAll then
            catchGroup = UnitManager.playerUnitList
            if catchEnemy then
                catchGroup = UnitManager.enemyUnitList
            end
            for unit in pairs(catchGroup) do

                if unit.lastMomentPosition * p <= math.max(w, r) and unit:isAlive() then

                    local pt = unit.lastMomentPosition
                    local x, y = pt[1], pt[2]
                    local d = math_abs(a * x + b * y + c) / l

                    if d <= w and self:do_filter(unit) then
                        select_unit(unit)
                    end
                end
            end

        else
            for unit in pairs(UnitManager.playerUnitList) do

                if unit.lastMomentPosition * p <= math.max(w, r) and unit:isAlive() then

                    local pt = unit.lastMomentPosition
                    local x, y = pt[1], pt[2]
                    local d = math_abs(a * x + b * y + c) / l

                    if d <= w and self:do_filter(unit) then
                        select_unit(unit)
                    end
                end
            end

            for unit in pairs(UnitManager.enemyUnitList) do

                if unit.lastMomentPosition * p <= math.max(w, r) and unit:isAlive() then

                    local pt = unit.lastMomentPosition
                    local x, y = pt[1], pt[2]
                    local d = math_abs(a * x + b * y + c) / l

                    if d <= w and self:do_filter(unit) then
                        select_unit(unit)
                    end
                end
            end
        end

    elseif self.filter_in == 3 then
        -- 选取所有玩家英雄
        for i = 1, 4 do
            local p = as.player:getPlayerById(i)

            local u = p.hero
            if u then
                if self:do_filter(u) then
                    select_unit(u)
                end
            end
        end

    elseif self.filter_in == 4 then
        local p = self.player
        for _, u in ipairs(p.heroList) do
            if self:do_filter(u) then
                select_unit(u)
            end
        end

    end
end

function api:get()
    local units = {}
    self:select(function(u)
        table_insert(units, u)
    end)
    if self.sorter then
        table_sort(units, self.sorter)
    end
    return units
end

-- 选取并遍历
function api:ipairs()
    return ipairs(self:get())
end

-- 选取并选出随机单位
function api:random()
    local g = self:get()
    if #g > 0 then
        return g[math_random(1, #g)]
    end
    return nil
end

-- 获取其中单位数量
function api:getSize()
    local g = self:get()
    return #g
end

-- 选取并选出第一个单位
function api:firstRemove()
    local g = self:get()
    if #g > 0 then
        local id = 1
        local selected = g[id]
        self:is_not(selected)
        return selected
    end
    return nil
end

-- 选取并选出随机单位
function api:randomRemove()
    local g = self:get()
    if #g > 0 then
        local id = math_random(1, #g)
        local selected = g[id]
        self:is_not(selected)
        return selected
    end
    return nil
end

-- 血量百分比最低单位
function api:lowestHp()
    local g = self:get()
    if #g > 0 then
        local u = g[1]
        for i = 1, #g do
            if g[i]:getHpPercent() < u:getHpPercent() then
                u = g[i]
            end
        end
        return u
    end
    return nil
end

function ac.selector()
    return setmetatable({
        filters = {},
    }, mt)
end
