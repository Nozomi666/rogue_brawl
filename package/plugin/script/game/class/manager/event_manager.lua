require 'game.__api.event'
require 'game.__api.ui_event'

local mt = {}
as.eventManager = mt

mt.uiCallback = {} -- 储存UI事件回调函数
mt.uiCallbackKeys = {} -- 储存上述函数的输入值
--------------------------------------------------------------------------------------
mt.registerUICalllback = function(frame, eventId, callback, params)

    if (mt.uiCallback[frame] == nil) then
        mt.uiCallback[frame] = {}
    end

    if (mt.uiCallbackKeys[frame] == nil) then
        mt.uiCallbackKeys[frame] = {}
    end

    mt.uiCallback[frame][eventId] = callback
    mt.uiCallbackKeys[frame][eventId] = params
end
--------------------------------------------------------------------------------------
-- 事件 单位准备施法
local trig = CreateTrigger()
dbg.handle_ref(trig)
TriggerRegisterAnyUnitEventBJ(trig, EVENT_PLAYER_UNIT_SPELL_CAST)
TriggerAddAction(trig, as.event.unitPreCastSpell)

-- 事件 单位施法
local trig = CreateTrigger()
dbg.handle_ref(trig)
TriggerRegisterAnyUnitEventBJ(trig, EVENT_PLAYER_UNIT_SPELL_EFFECT)
TriggerAddAction(trig, as.event.unitCastSpell)

-- 事件 单位被攻击
local trig = CreateTrigger()
dbg.handle_ref(trig)
TriggerRegisterAnyUnitEventBJ(trig, EVENT_PLAYER_UNIT_ATTACKED)
TriggerAddAction(trig, as.event.unitAtked)

-- 事件 单位死亡
local trig = CreateTrigger()
dbg.handle_ref(trig)
TriggerRegisterAnyUnitEventBJ(trig, EVENT_PLAYER_UNIT_DEATH)
TriggerAddAction(trig, as.event.unitDie)

-- 事件 单位使用物品
local trig = CreateTrigger()
dbg.handle_ref(trig)
TriggerRegisterAnyUnitEventBJ(trig, EVENT_PLAYER_UNIT_USE_ITEM)
TriggerAddAction(trig, as.event.useItem)

-- 事件 单位获得物品
local trig = CreateTrigger()
dbg.handle_ref(trig)
TriggerRegisterAnyUnitEventBJ(trig, EVENT_PLAYER_UNIT_PICKUP_ITEM)
TriggerAddAction(trig, as.event.getItem)

-- 事件 单位失去物品
local trig = CreateTrigger()
dbg.handle_ref(trig)
TriggerRegisterAnyUnitEventBJ(trig, EVENT_PLAYER_UNIT_DROP_ITEM)
TriggerAddAction(trig, as.event.dropItem)

-- 事件 英雄升级
local trig = CreateTrigger()
dbg.handle_ref(trig)
TriggerRegisterAnyUnitEventBJ(trig, EVENT_PLAYER_HERO_LEVEL)
TriggerAddAction(trig, as.event.heroLvUp)

-- 事件 点命令
local trig = CreateTrigger()
dbg.handle_ref(trig)
TriggerRegisterAnyUnitEventBJ(trig, EVENT_PLAYER_UNIT_ISSUED_POINT_ORDER)
TriggerAddAction(trig, as.event.pointOrder)

-- 事件 禁止控英雄
local trig = CreateTrigger()
dbg.handle_ref(trig)
TriggerRegisterAnyUnitEventBJ(trig, EVENT_PLAYER_UNIT_ISSUED_POINT_ORDER)
TriggerRegisterAnyUnitEventBJ(trig, EVENT_PLAYER_UNIT_ISSUED_ORDER)
TriggerRegisterAnyUnitEventBJ(trig, EVENT_PLAYER_UNIT_ISSUED_TARGET_ORDER)
TriggerAddAction(trig, as.event.stopOperateHero)

-- 事件 科技研究完成
local trig = CreateTrigger()
dbg.handle_ref(trig)
TriggerRegisterAnyUnitEventBJ(trig, EVENT_PLAYER_UNIT_RESEARCH_FINISH)
TriggerAddAction(trig, as.event.techFinish)

-- 注册单位受到伤害
--------------------------------------------------------------------------------------
local conditionFunc = Condition(as.event.unitTakeDmg)
function mt:ujRegisterDmgEvent(uj)
    -- gdebug('u reg dmg evenet')

    local trig = CreateTrigger()
    dbg.handle_ref(trig)
    -- TriggerAddAction(trig, as.event.unitTakeDmg)
    TriggerAddCondition(trig, conditionFunc)
    TriggerRegisterUnitEvent(trig, uj, EVENT_UNIT_DAMAGED)

    return trig
end
--------------------------------------------------------------------------------------
-- 注册鼠标进入技能按钮事件（异步）
local eventId = 2
for y = 0, 3 do
    for x = 0, 2 do
        local frame = japi.FrameGetCommandBarButton(x, y)
        if frame > 0 then
            japi.RegisterFrameEvent(frame)

            local callback = as.uiEvent.skillBtnIn
            local params = {
                x = x,
                y = y,
            }

            mt.registerUICalllback(frame, eventId, callback, params)

        end
    end
end
--------------------------------------------------------------------------------------
-- 注册鼠标离开技能按钮事件（异步）
local eventId = 3
for y = 0, 3 do
    for x = 0, 2 do
        local frame = japi.FrameGetCommandBarButton(x, y)
        if frame > 0 then
            japi.RegisterFrameEvent(frame)

            local callback = as.uiEvent.skillBtnOut
            local params = {
                x = x,
                y = y,
            }

            mt.registerUICalllback(frame, eventId, callback, params)

        end
    end
end
--------------------------------------------------------------------------------------
-- 注册鼠标进入物品按钮事件（异步）
local eventId = 2
for i = 0, 5 do
    local frame = japi.FrameGetItemBarButton(i)
    if frame > 0 then
        japi.RegisterFrameEvent(frame)

        local callback = as.uiEvent.itemBtnIn
        local params = {
            id = i,
        }

        mt.registerUICalllback(frame, eventId, callback, params)

    end
end
--------------------------------------------------------------------------------------
-- 注册鼠标离开物品按钮事件（异步）
local eventId = 3
for i = 0, 5 do
    local frame = japi.FrameGetItemBarButton(i)
    if frame > 0 then
        japi.RegisterFrameEvent(frame)

        local callback = as.uiEvent.itemBtnOut
        local params = {
            id = i,
        }

        mt.registerUICalllback(frame, eventId, callback, params)

    end
end
--------------------------------------------------------------------------------------

return mt
