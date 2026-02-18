local mt = {}

--------------------------------------------------------------------------------------
function mt.addEnemySkill(u, skillName, isBoss)
    local pack = as.dataRegister:getTableData('enemySkill', skillName)
    print('add eskill' .. skillName)
    local abId = pack.abId
    UnitAddAbility(u.handle, ID(abId))

    local o = {}
    setmetatable(o, pack)

    o.owner = u
    o.skillName = skillName
    o.pack = pack

    pack.onSwitch(o, true)

    if not u.enemySkillList then
        u.enemySkillList = {}
    end

    table.insert(u.enemySkillList, o)

    if isBoss then
        if not u.readySkills then
            u.readySkills = {}
        end

        if pack.onSpell then
            table.insert(u.readySkills, o)
        end

    end

    return o
end
--------------------------------------------------------------------------------------
function mt:teamBossDmged(keys)
    local enemy = keys.tgt

    ui.bossHp.onUpdate()

    if enemy:getLostHpPercent() >= 0.5 and (not enemy.phase2) then
        enemy.phase2 = true
        enemy:modStats(cst.ST_DEF_RATE, 30)
        local ePack = enemy.pack

        if ePack.skillHalf then
            for _, skillName in ipairs(ePack.skillHalf) do
                eSkill.addEnemySkill(enemy, skillName, true)
            end
        end

        for i = 1, 5 do
            local bulletData = {
                owner = enemy,
                model = [[tx003.mdx]],
                height = 0,
                size = 1,
                face = i * 72,
                turnSpeed = 200,
                point = enemy:getloc(),
    
                mode = cst.BULLET_SHOCK_WAVE,
                speed = 1200,
                hitRange = 1,
                direction = i * 72,
                maxRange = 800,
    
            }
            as.projManager:makeProjectile(bulletData)
        end

        -- player unit event
        for _, p in ipairs(fc.getAlivePlayers()) do
            for _, hero in ipairs(p.heroList) do
                local keys = {
                    u = hero,
                }
                hero:triggerSafeEvent(cst.UNIT_EVENT_ON_BOSS_RAGE_ONE, keys)
            end
        end


    end

    if enemy:getLostHpPercent() >= 0.9 and (not enemy.phase3) then
        enemy.phase3 = true
        local ePack = enemy.pack

        if ePack.skillLow then
            for _, skillName in ipairs(ePack.skillLow) do
                eSkill.addEnemySkill(enemy, skillName, true)
            end
        end

        for i = 1, 5 do
            local bulletData = {
                owner = enemy,
                model = [[tx003.mdx]],
                height = 0,
                size = 1,
                face = i * 72,
                turnSpeed = 200,
                point = enemy:getloc(),
    
                mode = cst.BULLET_SHOCK_WAVE,
                speed = 1200,
                hitRange = 1,
                direction = i * 72,
                maxRange = 800,
    
            }
            as.projManager:makeProjectile(bulletData)
        end

    end

end
--------------------------------------------------------------------------------------
function mt:teamBossPreAtk(keys)
    local enemy = keys.u

    if fc.isInCd(enemy, 'bossSkills') then
        return
    end

    local readySkills = enemy.readySkills

    if not next(readySkills) then
        return
    end

    local skill = fc.rngSelect(readySkills)
    local skillPack = skill.pack
    gdebug(skill.skillName .. ' try cast')

    -- remove skill
    table.removeTarget(readySkills, skill)
    local cd = skillPack.cd

    if as.test.testingBoss then
        cd = 3
    end

    if enemy.phase3 then
        cd = cd * 0.8
    end

    local cdPct = math.clamp(1 + enemy:getStats(cst.ST_ENEMY_CD_SPEED), 0.2, 2)
    cd = cd * cdPct
    gdebug('final boss cd pct: ' .. cdPct)

    ac.timer(ms(cd), 1, function()
        if enemy:isAlive() and enemy.teamBoss then
            table.insert(readySkills, skill)
            gdebug(skill.skillName .. ' re add')
        else
            gdebug(skill.skillName .. ' not re add bc die')
            gdebug(enemy:getName())
        end
    end)

    -- cast spell
    skillPack:onSpell({
        u = enemy,
    })
    SetUnitAnimationByIndex(enemy.handle, skillPack.animId)
    fc.setInnerCd(enemy, 'bossSkills', math.random(3, 4))

end
--------------------------------------------------------------------------------------

return mt
