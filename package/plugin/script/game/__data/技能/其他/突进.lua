local skillName = '突进'

local mt = {
    -- 名称
    name = skillName,

    -- 技能图标
    art = [[ReplaceableTextures\CommandButtons\BTNtiaoyue.blp]],

    -- 技能说明
    title = skillName,
    tip = [[朝鼠标所指的方向迅速前进一段距离。可充能<NUM>2<R>次。]],

    -- 技能类型
    skillType = SKILL_TYPE_NO_FLAG,

    -- 施放类型
    targetType = SKILL_TARGET_POINT,
    hideDashHotkey = true,

    -- 数据
    cd = 5,
    range = 9999,
    maxRange = 1400,
    maxCharge = 2,

    -- -- 展示数据
    -- presentMain = {{
    --     type = 'rate1',
    --     name = '弹射攻击几率：',
    --     isPct = true,
    -- }, {
    --     type = 'rate2',
    --     name = '弹射攻击次数：',
    -- }},

    presentSide = {{
        type = 'cd',
        name = '冷却时间：'
    }, {
        type = 'maxRange',
        name = '最大距离：'
    }}

}
-- if localEnv then
--     mt.cd = 0.1
-- end

mt.__index = mt
--------------------------------------------------------------------------------------
function mt:onSwitch(isAdd)
    local unit = self.unit
    local eventPack = {
        name = 'on_pick_event',
        condition = UNIT_EVENT_ON_PICK,
        callback = mt.onMousePick
    }

    if isAdd then
        unit:addEvent(eventPack)
    else
        unit:removeEvent(eventPack)
    end
end
--------------------------------------------------------------------------------------
function mt:beforeCast(keys)
    local unit = self.unit
    local dest = keys.dest

    self:tryDash(dest[1], dest[2])
end
--------------------------------------------------------------------------------------
function mt:getTitle(lv)
    return str.format(str.format('%s(|cffffcc00D|r)', self.title))
end
--------------------------------------------------------------------------------------
function mt:onKeyDown(mouseX, mouseY)

    self:tryDash(mouseX, mouseY)
end
--------------------------------------------------------------------------------------
function mt:tryDash(x, y)
    local unit = self.unit

    if unit.isDashing then
        return
    end

    if unit.isFishing then
        return
    end

    if unit:hasBuff(cst.BUFF_ROOT) then
        msg.notice(unit.player, '缠绕状态下无法突进。')
        return
    end

    if unit:hasBuff(cst.BUFF_STUN) then
        msg.notice(unit.player, '眩晕状态下无法突进。')
        return
    end

    if unit:hasBuff(cst.BUFF_PAUSE) then
        msg.notice(unit.player, '暂停状态下无法突进。')
        return
    end

    if unit:hasBuff(cst.BUFF_SILENCE) then
        msg.notice(unit.player, '沉默状态下无法突进。')
        return
    end

    if self:isInCd() then
        if unit.owner:isLocal() then
            GUI.DashCd:onDashFail(self.currentChargeCd)
        end
    end

    if (not self:isInCd()) and unit:isAlive() and (not unit.bSilenced) then
        self:onTrigger(x, y)
    end
end
--------------------------------------------------------------------------------------
-- function mt:beforeCast()
--     -- local unit = self.unit
--     -- unit:issueImmediateOrder('stop')
-- end
--------------------------------------------------------------------------------------
function mt:onTrigger(mouseX, mouseY)

    local unit = self.unit
    local point = unit:getloc()
    local pointT = ac.point:new(mouseX, mouseY)
    local angle = point / pointT
    local maxRange = math.max(self.maxRange + unit:getStats(ST_DASH_RANGE), 10)
    local distance = math.min(maxRange, math.max(30, (point * pointT) - 50))

    local dSpeed = 100

    local face = unit:getface()
    local backDirection = pointT / point
    local moveFace = angle
    local cosVal = math.cos(face - backDirection)
    if cosVal > 0 then
        moveFace = angle - 180
    end

    local eff = {
        model = [[ChargerWindCasterArt.mdx]],
        size = 1,
        face = angle,
        time = -1,
        height = 20
    }
    eff = fc.pointEffect(eff, point)

    local eff2 = {
        model = [[AZ_SylvanusWindrunnePFr_R2.mdx]],
        size = 1,
        face = angle,
        height = 30
    }
    fc.pointEffect(eff2, point)

    unit:issueImmediateOrder('stop')
    unit.isDashing = true

    local tick = 0
    ac.loop(ms(0.02), function(timer)

        -- tick = tick + 1
        distance = distance - dSpeed
        point = fc.polarPoint(point, dSpeed, angle)

        if unit:isDead() then
            self:endCharge(timer, eff)
            return
        end

        if not point:isWalkable() then
            gdebug('point is not walkable')
            self:endCharge(timer, eff)
            return
        end

        if distance <= 0 then
            self:endCharge(timer, eff)
            return
        end

        unit:move(point, moveFace)
        as.effect:moveEffect(eff, point)

    end)
    local cd = self.cd
    local dashCdReduce = unit:getStats(ST_DASH_CD_REDUCE)
    local cdReduce = cd * dashCdReduce / 100
    cd = cd - cdReduce
    self:setInCd(cd)

    unit:triggerEvent(UNIT_EVENT_ON_DASH_START, {})

end
--------------------------------------------------------------------------------------
function mt:endCharge(timer, eff)
    timer:remove()
    fc.removeEffect(eff)
    local unit = self.unit
    unit:issueImmediateOrder('stop')

    unit:triggerEvent(UNIT_EVENT_ON_DASH_END, {})
    unit.isDashing = false
end
--------------------------------------------------------------------------------------
function mt:onMousePick(p, u, isPick)
    if u.owner ~= p then
        return
    end

    if p:isLocal() then
        
    end


end
--------------------------------------------------------------------------------------
reg:initSkill(mt)
