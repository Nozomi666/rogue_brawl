local mt = {}
as.enemyManager = mt
EnemyManager = mt
--------------------------------------------------------------------------------------
mt.enemies = {}
mt.stateTimer = 999
mt.diffNum = 1
mt.waveNum = 1
mt.enemyNum = 0
mt.maxEnemyNumList = {50, 75, 100, 125}
mt.maxEnemyOnField = 0
mt.bornPerSec = -1
mt.bornCd = 0
mt.bStopTide = false
mt.tickCount = 0
mt.finalBossTime = 180
mt.quicklyKillFinalBoss = false
mt.aliveBossCount = 0
mt.bossFightPassedTime = 0
mt.bBossPhase = false
mt.hideEffectChance = 0
mt.fadeUnitList = {}
--------------------------------------------------------------------------------------
-- endless
mt.waveMode = nil
mt.endlessWaveNum = 0
--------------------------------------------------------------------------------------
-- hunt mode
mt.huntMode = false
--------------------------------------------------------------------------------------
function mt:awake()

    if self.huntMode then
        GUI.ChallengePanel:hide()
    else
        for _, player in ipairs(fc.getAlivePlayers()) do
            local stName = str.format('PLAY_%d_%d', gm.chapter.id, EnemyManager.diffNum)
            player:updateMapStatistics(stName, 1)
        end
    end

end
--------------------------------------------------------------------------------------
function mt:start()
    -- dont delete

    gdebug('enter em start, %d', WAVE_INTERVAL)
    self.stateTimer = WAVE_INTERVAL

    if self.huntMode then
        self:startHuntWave()
        return
    end
    --------------------------------------------------------------------------------------

    self:setWave(1)

end
--------------------------------------------------------------------------------------
function mt:update()

    if gm.pause then
        return
    end

    for _, enemy in ipairs(self.fadeUnitList) do
        local fadeVal = enemy.fadeVal
        fadeVal = fadeVal + 0.05
        enemy.fadeVal = fadeVal
        enemy:setOpacity(fadeVal)
        if fadeVal >= 1 or enemy.removed then
            table.removeTarget(self.fadeUnitList, enemy)
        end
    end

    self.stateTimer = self.stateTimer - GAME_TICK_INTERVAL
    self.tickCount = self.tickCount + 1

    if self.tickCount % 60 == 0 then
        self:updateAtkOrders()

    end

end
--------------------------------------------------------------------------------------
function mt:getMaxEnemy()

    local playerNum = #fc.getAlivePlayers()
    playerNum = math.clamp(playerNum + gm.botNum, 1, 4)

    local maxEnemyNum = self.maxEnemyNumList[playerNum]

    -- if self.infinateMaxEnemy then
    --     maxEnemyNum = 999
    -- end

    if #fc.getAlivePlayers() <= 0 then
        maxEnemyNum = self.lastMomentMaxEnemyNum
    else
        for _, player in ipairs(fc.getAlivePlayers()) do
            maxEnemyNum = maxEnemyNum + player:getStats(PST_ENEMY_MAX)
        end
    end

    self.lastMomentMaxEnemyNum = maxEnemyNum

    return maxEnemyNum
end
--------------------------------------------------------------------------------------
function mt:onStartWave(oldWaveNum)
    local waveNum = self.waveNum

    if self.huntMode then
        return
    end

    local pList = fc.getAlivePlayers()
    for i = 1, #pList, 1 do
        local player = pList[i]
        player.dmgCalc = 0
        if player.hero then
            player.hero:triggerEvent(UNIT_EVENT_ON_ROUND_END, {
                round = waveNum,
            })
            player.hero:triggerEvent(UNIT_EVENT_ON_ROUND_START, {
                round = waveNum,
            })
        end
    end

    if waveNum == MAX_WAVE_NUM - 3 then
        AudioManager:playCloseToEndBgm()
    end

    if waveNum > MAX_WAVE_NUM then
        gdebug('exceed max wave num')
        return
    end

    if waveNum == MAX_WAVE_NUM then
        gdebug('create final boss max wave')
        for _, player in ipairs(fc.getAlivePlayers()) do
            player:endChallengeWhenEnterFinalBoss()
        end
        self.bStopTide = true
        self.bBossPhase = true
        self:createFinalBoss()
        return
    end


    if waveNum % 8 == 0 then
        for i, pTarget in ipairs(fc.getAlivePlayers()) do
            local bossLv = self.waveNum // 8
            local bossName = pTarget.playerBossList[bossLv]
            if gm.chaosMode == 1 then
                self:createBoss(pTarget)
            end
            self:createBoss(pTarget, bossName)
        end
        self.bBossPhase = true
        self.bossFightPassedTime = 0
        AudioManager:playBossBgm()
    end


end
--------------------------------------------------------------------------------------
function mt:setWave(num)
    if gm.bGameLost then
        return
    end

    local oldWaveNum = self.waveNum
    self.waveNum = num

    if WaveEnemyPerSec[num] then
        self.bornPerSec = WaveEnemyPerSec[num]

    end

    self:onStartWave(oldWaveNum)
end
--------------------------------------------------------------------------------------
function mt:onTickWaveNormal()


    if self.bBossPhase then
        self.bossFightPassedTime = self.bossFightPassedTime + gm.tickInterval
    end

end
--------------------------------------------------------------------------------------
function mt:onTickWaveHuntMode()

    if localEnv then
        self.bornCd = 0
    end

    if self.bornCd <= 0 then

        for i, pTarget in ipairs(fc.getAlivePlayers()) do
            self:createHuntAnimal(pTarget)
        end

        self.bornCd = 1 / 0.33
    else
        self.bornCd = self.bornCd - gm.tickInterval
    end
end
--------------------------------------------------------------------------------------
function mt:onPlayerReviveEnemyFollow(player)
    for i, enemy in ipairs(self.enemies) do
        if enemy.pTarget == player and enemy.chaseUnit and (not enemy:hasBuff('恐惧')) then
            enemy:issuePointOrder('move', enemy.chaseUnit:getloc())
        end
    end
end
--------------------------------------------------------------------------------------
function mt:onPlayerDieFollowOther(player)
    for i, enemy in ipairs(self.enemies) do
        if enemy.pTarget == player and enemy.chaseUnit and (not enemy:hasBuff('恐惧')) then
            local minDistance = 99999
            local targetHero = nil

            for _, otherPlayer in ipairs(fc.getAlivePlayers()) do
                if otherPlayer.hero and otherPlayer.hero:isAlive() then
                    local distance = enemy:getloc() * otherPlayer.hero:getloc()
                    if distance < minDistance then
                        minDistance = distance
                        targetHero = otherPlayer.hero
                    end
                end
            end

        end
    end
end
--------------------------------------------------------------------------------------
function mt:createTideEnemies(pTarget)



end
--------------------------------------------------------------------------------------
function mt:createFinalBoss()
    local enemyName = gm.chapter.finalBoss
    local enemyPack = reg:getTableData('enemyData', enemyName)

    AudioManager:playFinalBossBgm()

    local enemyStats = self:makeEnemyStats({
        enemyPack = enemyPack,
        waveNum = self.waveNum,
        diffNum = self.diffNum,
        bTeamEnemy = true,
    })
    if self.diffNum >= 4 then
        enemyStats.hp = enemyStats.hp * 1.3
    end

    local enemy = self:createEnemy({
        pTarget = cst.ALL_PLAYERS,
        enemyName = enemyName,
        enemyStats = enemyStats,
        bornPoint = gm.mapArea.centerPoint,
        tgtPoint = gm.mapArea.centerPoint,
        bFinalBoss = true,
        isBoss = true,
    })


    --------------------------------------------------------------------------------------
    enemy.hpBar:beforeDestroy()
    enemy.hpBar:destroy()
    local hpBar = class.finalHpBar.add_child(MAIN_UI, enemy)
    enemy.hpBar = hpBar
    -- hpBar:bind_unit_overhead(enemy)

    local eventPack = {
        name = '最终BOSS伤害统计',
        condition = UNIT_EVENT_ON_TAKE_DMG,
        callback = mt.onFinalBossTakeDmg,
        self = self,
    }
    enemy:addEvent(eventPack)
    enemy.bNoKicked = true
    enemy.bTeamEnemy = true

    enemy.onReward = function(killer, enemy)

        if gm.bGameLost == true then
            return
        end

        msg.notice(cst.ALL_PLAYERS, '击败了最终boss。')

        local totaldmg = 0

        for _, player in ipairs(fc.getAlivePlayers()) do

            player:onKillBoss(true, -1)
            player:modSimpleArch(INT_STORAGE.OCTOBER_SHARD_GET, 5)

            if self.finalBossTime <= 5 then
                -- player:tryUnlockArch('险胜')
            end

            if self.finalBossTime <= 10 then
                -- player:tryUnlockArch('极限猎杀I')
            end

            if self.finalBossTime <= 3 then
                -- player:tryUnlockArch('极限猎杀II')
            end

            if self.finalBossTimeMax - self.finalBossTime <= 5 then
                -- player:tryUnlockArch('速胜')
            end

            if player.finalbossdmg then
                totaldmg = totaldmg + player.finalbossdmg
            end

        end
        for _, player in ipairs(fc.getAlivePlayers()) do
            if not player.finalbossdmg then
                -- player:tryUnlockArch('大混子')
            end
            if player.finalbossdmg and player.finalbossdmg / (totaldmg - player.finalbossdmg) < 0.1 then
                -- player:tryUnlockArch('大混子')
            end
        end

        if self.finalBossTimeMax - self.finalBossTime <= 15 then
            self.quicklyKillFinalBoss = true
        end
        AudioManager:playRandomNormalBgm()

        gm:onKillFinalBoss()
    end

    fc.unitEffect({
        model = [[Abilities\Spells\Undead\RaiseSkeletonWarrior\RaiseSkeleton.mdl]],
        bind = 'origin',
    }, enemy)

    -- for _, p in ipairs(fc.getAlivePlayers()) do
    --     p:moveCamera(gm.mapArea.centerPoint, 1)
    --     if p:isLocal() then
    --         if GUI.HideTopLeftBtn.is_show then
    --             GUI.HideTopLeftBtn.btn:on_button_clicked()
    --         end
    --     end
    -- end

    -- 失败倒计时
    self.finalBossTimeMax = self.finalBossTime
    ac.loop(ms(1), function(t)
        if not enemy:isAlive() then
            t:remove()
            return
        end

        self.finalBossTime = self.finalBossTime - 1
        -- msg.notice(cst.ALL_PLAYERS, str.format('boss战剩余时间：%d', self.finalBossTime))

        if self.finalBossTime <= 0 then
            for _, p in ipairs(fc.getAlivePlayers()) do
                if enemy:getStats(ST_HP_PCT) > 70 then
                    -- p:tryUnlockArch('没能让你尽力真是抱歉')
                end
                gm.gameLose(p, '未能在限定时间内击杀最终boss。')
            end

            gm.bGameLost = true
            self:gameLoseFreezeEnemy()

            t:remove()

        end

    end)

    -- GUI.HideTopLeftBtn:forceHide()

    return enemy
end
--------------------------------------------------------------------------------------
function mt:onFinalBossTakeDmg(keys)
    local unit = keys.unit
    local player
    if unit.isSummon then
        player = unit.master.owner
    else
        player = unit.player
    end
    local hero = player.hero
    local enemy = keys.tgt
    local dmg = keys.dmg
    local dmgType = keys.dmgType
    local name = hero.name

    if not player.finalbossdmg then
        player.finalbossdmg = 0
    end
    player.finalbossdmg = player.finalbossdmg + dmg
end
--------------------------------------------------------------------------------------
function mt:createBoss(pTarget, enemyName)
    local enemyPack
    if enemyName then
        enemyPack = reg:getTableData('enemyData', enemyName)
    else
        enemyName = fc.rngSelect(gm.chapter.bossPool)
        enemyPack = reg:getTableData('enemyData', enemyName)

    end

    if pTarget:isLocal() then
        GUI.BossWarn:onStartMove(enemyPack.warnIcon)
    end

    local enemyStats = self:makeEnemyStats({
        enemyPack = enemyPack,
        waveNum = self.waveNum,
        diffNum = self.diffNum,
    })
    local bossLv = self.waveNum // 8

    local enemy = self:createEnemy({
        pTarget = pTarget,
        enemyName = enemyName,
        enemyStats = enemyStats,
        bornPoint = pTarget:getRandomEnemyBornPoint(),
        tgtPoint = pTarget.oppositeCornerAreaCorner,
        isBoss = true,
    })
    -- japi.EXSetUnitMoveType(enemy.handle,0x01)
    --------------------------------------------------------------------------------------
    enemy.hpBar:beforeDestroy()
    enemy.hpBar:destroy()
    local hpBar = class.bossHpBar.add_child(MAIN_UI, enemy)
    enemy.hpBar = hpBar
    hpBar:bind_unit_overhead(enemy)
    --------------------------------------------------------------------------------------
    enemy.bossLv = bossLv
    enemy.bNoKicked = true

    self.aliveBossCount = self.aliveBossCount + 1

    enemy.onReward = function(killer, enemy)
        local enemyStats = enemy.enemyStats
        local goldReward = enemyStats.goldReward or 0
        local expReward = enemyStats.expReward or 0
        local crystalReward = enemyStats.crystalReward or 0

        local player = pTarget
        local hero = player.hero

        hero:addGold(goldReward, enemy:getloc())
        hero:addLumber(crystalReward, enemy:getloc())
        hero:addExp(expReward, hero:getloc())
        hero:addBlessPoint()

        local bossLv = enemy.bossLv
        local reward = {}

        player:onKillBoss(false, bossLv)

        self.aliveBossCount = self.aliveBossCount - 1
        if self.aliveBossCount <= 0 then
            AudioManager:playRandomNormalBgm()
            self.bBossPhase = false
        end

    end

    fc.unitEffect({
        model = [[Abilities\Spells\Undead\RaiseSkeletonWarrior\RaiseSkeleton.mdl]],
        bind = 'origin',
    }, enemy)

    return enemy
end
--------------------------------------------------------------------------------------
function mt:createEnemy(keys)
    local pTarget = keys.pTarget
    local enemyName = keys.enemyName
    local enemyStats = keys.enemyStats
    local bornPoint = keys.bornPoint
    local tgtPoint = keys.tgtPoint
    local timeLimit = keys.timeLimit
    local pEnemy

    if pTarget == cst.ALL_PLAYERS then
        pEnemy = cst.PLAYER_9
    else
        pEnemy = pTarget.enemyPlayer
    end

    local enemyPack = reg:getTableData('enemyData', enemyName)

    local unitType = enemyPack.unitType
    local unit = cg.Unit:createUnit(pEnemy, unitType, bornPoint, math.random(360), keys)
    setmetatable(unit, enemyPack)
    enemyPack.__index = enemyPack
    setmetatable(enemyPack, cg.Unit)
    unit:onCreate()

    -- if enemyStats.isGiantCreep then

    --     SetUnitScale(unit.handle, 2, 2, 2)
    --     unit.isGiantCreep = true
    -- end

    unit.enemyStats = enemyStats
    unit.enemyPack = enemyPack
    unit.enemyType = unit.eType
    unit.pTarget = pTarget

    if keys.bChallenge then
        unit.bChallenge = true
    end

    unit:setStats(ST_BASE_HP_MAX, enemyStats.hp)
    unit:setStats(ST_BASE_ATK, enemyStats.atk)
    unit:setStats(ST_BASE_PHY_DEF, enemyStats.phyDef)
    unit:setStats(ST_BASE_MAG_DEF, enemyStats.magDef)
    unit:setStats(ST_MOVE_SPEED, enemyPack.moveSpeed)
    unit:setStats(ST_BASE_RANGE, enemyPack.range)

    unit:setStats(ST_ACC, enemyStats.acc or 0)
    unit:setStats(ST_BLOCK, enemyStats.block or 0)
    unit:setStats(ST_MOVE_SPEED_PCT, enemyStats.waveSpeedPct or 0)
    unit:setStats(ST_CRIT_EVADE, enemyStats.critEvade or 0)
    unit:setStats(ST_CRIT_RESIST, enemyStats.critResist or 0)
    unit:setStats(ST_PHY_RESIST, enemyStats.phyResist or 0)
    unit:setStats(ST_MAG_RESIST, enemyStats.magResist or 0)
    unit:setStats(ST_DMG_RATE, enemyStats.dmgRate or 0)
    unit:setStats(ST_DEF_RATE, enemyStats.defRate or 0)
    unit:setStats(ST_KNOCK_BACK_RESIST, enemyStats.kickBackResist or 0)

    if unitType == ENEMY_TYPE_ELITE then
        unit:modStats(ST_CONTROL_RESIST, DEFAULT_CONTROL_RESIST_ELITE)
    end
    if unitType == ENEMY_TYPE_BOSS then
        unit:modStats(ST_CONTROL_RESIST, DEFAULT_CONTROL_RESIST_BOSS)
    end

    if enemyPack.skill then
        for i, skillName in ipairs(enemyPack.skill) do
            unit:addSkill(skillName)
        end
    end


    -- if enemyPack.skillOrderList and #enemyPack.skillOrderList > 0 then
    if enemyPack.getNextCastSkill then
        unit.enemyCastCount = 0
        local cdSkill = unit:addSkill('敌人施法冷却')
        local a = math.randomReal(1, 2)
        -- gdebug('冷却时间 = ..' .. a)
        cdSkill:setInCd(0)

        local eventPack = {
            name = 'enemy_cast_atk',
            condition = UNIT_EVENT_ON_ATK,
            callback = mt.onEnemyTestCast,
            enemy = unit,
            cdSkill = cdSkill,
            self = self,
        }
        unit:addEvent(eventPack)

        local eventPack = {
            name = 'enemy_cast_damageed',
            condition = UNIT_EVENT_ON_TAKE_DMG,
            callback = mt.onEnemyTestCast,
            enemy = unit,
            cdSkill = cdSkill,
            self = self,
        }
        unit:addEvent(eventPack)
    end

    if not keys.testAllyEnemy then
        table.insert(self.enemies, unit)
    end

    unit.enemyCount = enemyPack.enemyCount
    -- if unit.isGiantCreep then
    --     unit.enemyCount = unit.enemyCount * 2
    -- end
    self:updateEnemyNum(unit.enemyCount)

    local eventPack = {
        name = 'enemy_death',
        condition = UNIT_EVENT_ON_DIE,
        callback = mt.onEnemyDie,
        enemy = unit,
        self = self,
    }

    unit:addEvent(eventPack)

    RemoveGuardPosition(unit.handle)
    if tgtPoint then
        unit:issuePointOrder('move', tgtPoint)
    end

    if timeLimit then
        self:bindLimitTimerWithoutText(unit, keys)
    end


    unit.targetArea = keys.targetArea

    return unit
end
--------------------------------------------------------------------------------------
function mt:bindLimitTimerWithoutText(unit, keys)
    unit.timeLimit = keys.timeLimit
    ac.loop(ms(1), function(t)
        if unit:isDead() then
            t:remove()
            return
        end

        unit.timeLimit = unit.timeLimit - 1

        if unit.timeLimit > 0 then
        else
            fc.pointEffect({
                model = [[Abilities\Spells\Human\MassTeleport\MassTeleportTarget.mdl]],
                size = 2,
            }, unit:getloc())

            unit.timeEndRemove = true
            unit:hide()
            unit:suicide()
            -- if unit.onReward then
            --     unit.onReward(keys.pTarget, unit)
            -- end

        end

    end)
end
--------------------------------------------------------------------------------------
-- discard
function mt:bindLimitTimerOld(unit, keys)
    unit.timeLimit = keys.timeLimit
    ac.loop(ms(1), function(t)
        if unit:isDead() then
            t:remove()
            return
        end

        unit.timeLimit = unit.timeLimit - 1

        if unit.timeLimit > 0 then
            local textKeys = {
                text = str.format('|cffc7c7c7%.0f|r', unit.timeLimit),
                point = fc.polarPoint(unit:getLoc(), 200, 120),
                size = 12,
                speed = 64,
                angle = 90,
                fadeTime = 1,
                time = 2,
            }
            as.flowText.makeClassicFlowText(textKeys)
        else
            fc.pointEffect({
                model = [[Abilities\Spells\Human\MassTeleport\MassTeleportTarget.mdl]],
                size = 2,
            }, unit:getloc())

            unit.timeEndRemove = true
            unit:hide()
            unit:suicide()

        end

    end)
end
--------------------------------------------------------------------------------------
function mt:makeEnemyStats(keys)

    local enemyPack = keys.enemyPack
    local enemyType = enemyPack.eType
    local waveNum = keys.waveNum
    local diffNum = keys.diffNum
    local diffMultiplier = keys.diffMultiplier or 1
    local chapter = gm.chapter
    local isChallenger = keys.isChallenger
    local diffHpRate = chapter.hpRate[diffNum]
    local diffAtkRate = chapter.atkRate[diffNum]
    local diffDefRate = chapter.defRate[diffNum]

    -- local waveHp = chapter.waveHp[waveNum]
    -- local waveAtk = chapter.waveAtk[waveNum]
    -- local waveDef = chapter.waveDef[waveNum]

    local waveHp
    local waveAtk
    local waveDef

    if waveNum then
        waveHp = chapter.waveHp[waveNum]
        waveAtk = chapter.waveAtk[waveNum]
        waveDef = chapter.waveDef[waveNum]

        if waveNum >= 21 then
            local extraHpRate = chapter.finalHpRaiseList[diffNum] * math.min((waveNum - 20), 10)
            -- gdebug('extra hp rate is: ' .. extraHpRate)
            waveHp = waveHp * (1 + extraHpRate)
        end

    end

    if keys.waveHp then
        waveHp = keys.waveHp
    end

    if keys.waveAtk then
        waveAtk = keys.waveAtk
    end

    if keys.waveDef then
        waveDef = keys.waveDef
    end

    local enemyPackHp = enemyPack.hp
    local enemyPackAtk = enemyPack.atk
    local enemyPackPhyDef = enemyPack.phyDef
    local enemyPackMagDef = enemyPack.magDef

    local enemyTypeHp = EnemyHpRate[enemyType]
    local enemyTypeAtk = EnemyAtkRate[enemyType]
    local enemyTypeDef = EnemyDefRate[enemyType]

    if keys.notApplyEnemyTypeRate then
        enemyTypeHp = 1
        enemyTypeAtk = 1
        enemyTypeDef = 1
    end

    local name = enemyPack.name

    local diffHeatHpRate = 1
    local diffHeatAtkRate = 1

    local totalHp = waveHp * enemyPackHp * enemyTypeHp * diffHpRate * diffMultiplier * diffHeatHpRate
    -- gdebug('totalHp = '..totalHp)
    -- gdebug('waveHp = '..waveHp)
    -- gdebug('enemyPackHp = '..enemyPackHp)
    -- gdebug('enemyTypeHp = '..enemyTypeHp)
    -- gdebug('diffHpRate = '..diffHpRate)
    -- gdebug('diffMultiplier = '..diffMultiplier)
    -- gdebug('diffHeatHpRate = '..diffHeatHpRate)
    local totalAtk = waveAtk * enemyPackAtk * enemyTypeAtk * diffAtkRate * diffMultiplier * diffHeatAtkRate
    local totalphyDef = waveDef * enemyPackPhyDef * enemyTypeDef * diffDefRate * diffMultiplier
    local totalmagDef = waveDef * enemyPackMagDef * enemyTypeDef * diffDefRate * diffMultiplier

    if keys.bTeamEnemy then
        local playerNum = #fc.getAlivePlayers()
        playerNum = math.clamp(playerNum, 1, 4)
        totalHp = totalHp * TeamEnemyHpRate[playerNum]
        totalAtk = totalAtk * TeamEnemyAtkRate[playerNum]
        totalphyDef = totalphyDef * TeamEnemyDefRate[playerNum]
        totalmagDef = totalmagDef * TeamEnemyDefRate[playerNum]
    end


    if keys.bFinalBoss then
        totalAtk = totalAtk * FINAL_BOSS_ATK_RATE
    end

    if waveNum then
        totalHp = totalHp + chapter.diffAddWaveHp[diffNum] * waveNum
        totalAtk = totalAtk + chapter.diffAddWaveAtk[diffNum] * waveNum
        totalphyDef = totalphyDef + chapter.diffAddWaveDef[diffNum] * waveNum
        totalmagDef = totalmagDef + chapter.diffAddWaveDef[diffNum] * waveNum
    end

    -- gdebug('totalphyDef: %.2f',totalphyDef)

    if enemyPack.name == '骷髅奇兵' then
        totalHp = (0.5 + waveNum * 0.1) * gm.chapter.hpRate[diffNum] ^ 0.5
    end

    keys.hp = totalHp
    keys.atk = totalAtk
    keys.phyDef = totalphyDef
    keys.magDef = totalmagDef

    if gm.chaosMode == 1 then
        ChapterChaos.processEnemyStats(keys, self.diffNum, gm.chapter.id)
    end

    local diffAcc = chapter.diffAcc[diffNum]
    local diffEvade = chapter.diffEvade[diffNum]
    local diffNerfDef = chapter.diffNerfDef[diffNum]

    local waveSpeedPct
    if isChallenger then
        waveSpeedPct = 0
    else
        waveSpeedPct = chapter.waveSpeedPct[waveNum]
    end
    local diffCritEvade = chapter.diffCritEvade[diffNum]
    local diffCritResist = chapter.diffCritResist[diffNum]

    keys.acc = diffAcc
    keys.evade = diffEvade
    keys.block = 0
    keys.nerfPhyDef = diffNerfDef
    keys.nerfMagDef = diffNerfDef
    keys.waveSpeedPct = waveSpeedPct
    keys.critEvade = diffCritEvade
    keys.critResist = diffCritResist
    local diffPhyMagResist = chapter.diffPhyMagResist[diffNum]
    local diffDmgDefResist = chapter.diffDmgDefResist[diffNum]
    keys.phyResist = diffPhyMagResist * enemyPackPhyDef * enemyTypeDef
    keys.magResist = diffPhyMagResist * enemyPackMagDef * enemyTypeDef
    keys.dmgRate = diffDmgDefResist
    keys.defRate = diffDmgDefResist
    keys.kickBackResist = chapter.kickBackResist[diffNum]

    -- if localEnv then
    --     gdebug('diffAcc: ' .. diffAcc)
    --     gdebug('diffEvade: ' .. diffEvade)
    --     gdebug('diffNerfDef: ' .. diffNerfDef)
    --     gdebug('diffCritEvade: ' .. diffCritEvade)
    --     gdebug('diffCritResist: ' .. diffCritResist)
    --     gdebug('diffPhyMagResist: ' .. diffPhyMagResist)
    --     gdebug('diffDmgDefResist: ' .. diffDmgDefResist)
    -- end

    if not isChallenger then
        local waveGoldReward = WaveRewardGold[waveNum]
        local waveExpReward = WaveRewardExp[waveNum]
        local crystalReward = WaveRewardLumber[waveNum]
        local enemyRewardRate = EnemyRewardRate[enemyPack.eType]
        local totalGoldReward = waveGoldReward * enemyRewardRate * math.randomReal(0.9, 1.1)
        local totalExpReward = waveExpReward * enemyRewardRate
        keys.goldReward = totalGoldReward
        keys.expReward = totalExpReward
        if enemyPack.eType == ENEMY_TYPE_HEAVY then
            keys.crystalReward = crystalReward
        end
    end

    return keys
end
--------------------------------------------------------------------------------------
function mt:makeEndlessEnemyStats(keys)

    local enemyPack = keys.enemyPack
    local enemyType = enemyPack.eType
    local waveNum = keys.waveNum
    local diffNum = keys.diffNum
    local diffMultiplier = keys.diffMultiplier or 1
    local chapter = gm.chapter
    local isChallenger = keys.isChallenger
    local diffHpRate = chapter.hpRate[diffNum]
    local diffAtkRate = chapter.atkRate[diffNum]
    local diffDefRate = chapter.defRate[diffNum]

    local waveHp
    local waveAtk
    local waveDef

    if waveNum then
        waveHp = EndlessWaveHp[waveNum]
        waveAtk = EndlessWaveAtk[waveNum]
        waveDef = EndlessWaveDef[waveNum]
    end

    if keys.waveHp then
        waveHp = keys.waveHp
    end

    if keys.waveAtk then
        waveAtk = keys.waveAtk
    end

    if keys.waveDef then
        waveDef = keys.waveDef
    end

    local enemyPackHp = enemyPack.hp
    local enemyPackAtk = enemyPack.atk
    local enemyPackPhyDef = enemyPack.phyDef
    local enemyPackMagDef = enemyPack.magDef

    local enemyTypeHp = EndlessHpRate[enemyType]
    local enemyTypeAtk = EndlessAtkRate[enemyType]
    local enemyTypeDef = EndlessDefRate[enemyType]

    if keys.notApplyEnemyTypeRate then
        enemyTypeHp = 1
        enemyTypeAtk = 1
        enemyTypeDef = 1
    end

    local name = enemyPack.name

    local diffHeatHpRate = 1
    local diffHeatAtkRate = 1

    local totalHp = waveHp * enemyPackHp * enemyTypeHp * diffHpRate * diffMultiplier * diffHeatHpRate
    local totalAtk = waveAtk * enemyPackAtk * enemyTypeAtk * diffAtkRate * diffMultiplier * diffHeatAtkRate
    local totalphyDef = waveDef * enemyPackPhyDef * enemyTypeDef * diffDefRate * diffMultiplier
    local totalmagDef = waveDef * enemyPackMagDef * enemyTypeDef * diffDefRate * diffMultiplier

    if keys.bTeamEnemy then
        local playerNum = #fc.getAlivePlayers()
        playerNum = math.clamp(playerNum, 1, 4)
        totalHp = totalHp * TeamEnemyHpRate[playerNum]
        totalAtk = totalAtk * TeamEnemyAtkRate[playerNum]
        totalphyDef = totalphyDef * TeamEnemyDefRate[playerNum]
        totalmagDef = totalmagDef * TeamEnemyDefRate[playerNum]
    end

    -- gdebug('totalphyDef: %.2f',totalphyDef)

    keys.hp = totalHp
    keys.atk = totalAtk
    keys.phyDef = totalphyDef
    keys.magDef = totalmagDef

    local diffAcc = chapter.diffAcc[diffNum]
    local diffEvade = chapter.diffEvade[diffNum]
    local diffNerfDef = chapter.diffNerfDef[diffNum]

    local waveSpeedPct
    if isChallenger then
        waveSpeedPct = 0
    else
        waveSpeedPct = chapter.waveSpeedPct[waveNum]
    end
    local diffCritEvade = chapter.diffCritEvade[diffNum]
    local diffCritResist = chapter.diffCritResist[diffNum]
    keys.acc = diffAcc
    keys.evade = diffEvade
    keys.block = 0
    keys.nerfPhyDef = diffNerfDef
    keys.nerfMagDef = diffNerfDef
    keys.waveSpeedPct = waveSpeedPct
    keys.critEvade = diffCritEvade
    keys.critResist = diffCritResist
    local diffPhyMagResist = chapter.diffPhyMagResist[diffNum]
    local diffDmgDefResist = chapter.diffDmgDefResist[diffNum]
    keys.phyResist = diffPhyMagResist * enemyPackPhyDef * enemyTypeDef
    keys.magResist = diffPhyMagResist * enemyPackMagDef * enemyTypeDef
    keys.dmgRate = diffDmgDefResist
    keys.defRate = diffDmgDefResist

    keys.kickBackResist = chapter.kickBackResist[diffNum]

    return keys
end
--------------------------------------------------------------------------------------
function mt:onEnemyTestCast(keys)
    local eventKeys = keys.eventKeys
    local cdSkill = eventKeys.cdSkill
    if cdSkill:isInCd() then
        -- gdebug('敌人施法还在cd中')
        return
    end

    local unit = eventKeys.enemy

    if unit:isDead() then
        return
    end

    local enemyPack = unit.enemyPack
    local enemyCastCount = unit.enemyCastCount

    -- local skillOrderList = unit.skillOrderList
    -- local skillOrderLenth = #skillOrderList
    -- local currentSkillId = (enemyCastCount % skillOrderLenth) + 1
    -- gdebug('currentSkillId: ' .. currentSkillId)
    -- local castSkillName = skillOrderList[currentSkillId]
    local castSkillName = unit:getNextCastSkill()
    -- gdebug('onEnemyTestCast currentSkillName: ' .. castSkillName)

    local castSkill = unit:getSkill(castSkillName)
    local tgtKeys = castSkill:searchTarget()
    if tgtKeys then
        xpcall(function()
            castSkill:onCast(tgtKeys)
        end, traceError)

        if unit.bRandomBoss then
            as.flowText.makeClassicFlowText({
                text = str.format('|cffffff00%s|r', castSkillName),
                point = unit:getloc(),
                size = 15,
                speed = 90,
                angle = math.random(70, 90),
                fadeTime = 2,
                time = 3.5,
            })
        end

    else
        cdSkill:setInCd(1)
        return
    end

    local cd = castSkill:getEnemySkillCd()
    cd = math.randomReal(cd * 0.9, cd * 1.1)

    if unit.bTeamEnemy then
        local playerNumber = #fc.getAlivePlayers()
        cd = cd * (1 - TeamEnemyCdSpeed[playerNumber])
        -- gdebug('team enemy cd is reduced to : ' .. (1 - TeamEnemyCdSpeed[playerNumber]))
    end

    local scareBuff = unit:hasBuff('恐惧')
    if scareBuff then
        cd = cd -- + scareBuff.keys.upRate5
    end

    cdSkill:setInCd(cd)
    -- if not test.testingEnemyAllySkill then
    --     cdSkill:setInCd(cd)
    -- else
    --     gdebug('set enemy skill short cd ')
    --     cdSkill:setInCd(8)
    -- end

    castSkill:setInCd()
    unit.enemyCastCount = unit.enemyCastCount + 1

end
--------------------------------------------------------------------------------------
function mt:onEnemyDie(keys)
    local eventKeys = keys.eventKeys
    local enemy = keys.u
    local killer = keys.killer
    if killer then
        if killer.eType == ENEMY_TYPE_ELITE then
            return
        end
    end

    local enemyCount = enemy.enemyCount
    self:updateEnemyNum(enemyCount * -1)
    table.removeTarget(self.enemies, enemy)

    if killer and killer.player then
        -- local player = killer.player
        -- local kickDir = killer:getloc() / enemy:getloc()
        -- enemy:kicked(kickDir, 2000, 0, 0.2)

        -- if player then
        --     if player.hero then
        --         player.hero:onKillEnemy(keys)
        --     end
        -- end

    end

    if enemy.onReward then
        xpcall(function()
            enemy.onReward(killer, enemy)
        end, traceError)

    end

    ac.wait(ms(2), function()
        enemy.fadeVal = 0
        if not enemy.removed then
            table.insert(self.fadeUnitList, enemy)
        end
    end)

    if not killer then
        gdebug('enemy died with no killer: ' .. enemy:getName())
    end

end
--------------------------------------------------------------------------------------
function mt.standardOnReward(killer, enemy)
    local enemyStats = enemy.enemyStats
    local baseGoldReward = enemyStats.goldReward or 0
    local baseExpReward = enemyStats.expReward or 0
    local baseCrystalReward = enemyStats.crystalReward or 0
    local baseKillCount = enemy.enemyCount or 0

    local pTarget = enemy.pTarget
    if not killer then
        killer = pTarget.maid
    end

    local pKiller = killer.player

    if not pTarget then
        gdebug('enemy died with no pTarget: ' .. enemy:getName())
        traceError()
        return
    end

    if enemy.bNoReward then
        return
    end

    local giveReward = function(player, rewardRate)
        local goldReward = (baseGoldReward + player:getStats(PST_EXTRA_ENEMY_GOLD) +
                               math.max(killer:getStats(ST_KILL_GOLD), 0)) *
                               (1 + player:getStats(PST_EXTRA_ENEMY_GOLD_PCT)) * rewardRate
        local expReward = baseExpReward * (1 + player:getStats(PST_EXTRA_ENEMY_EXP_PCT)) * rewardRate
        local crystalReward = baseCrystalReward * (1 + player:getStats(PST_EXTRA_ENEMY_LUMBER_PCT)) * rewardRate
        local killCount = baseKillCount * rewardRate

        if enemy.rewardMultiplier then
            goldReward = goldReward * enemy.rewardMultiplier
            expReward = expReward * enemy.rewardMultiplier
            crystalReward = crystalReward * enemy.rewardMultiplier
        end

        player:addGold(goldReward, enemy:getloc(), '杀敌金币')
        player:addLumber(crystalReward)
        player:addKill(killCount)

        player.hero:addExp(expReward)
    end

    if pTarget == pKiller then
        giveReward(pTarget, 1)
    else
        giveReward(pTarget, 0.2)
        giveReward(pKiller, 0.8)

    end

end
--------------------------------------------------------------------------------------
function mt:updateEnemyNum(num)
    self.enemyNum = self.enemyNum + num
    self.maxEnemyOnField = math.max(self.maxEnemyOnField, self.enemyNum)
    if gm.state == GAME_STATE_ENDLESS then
        GUI.TopInfo:updateBoard(self.enemyNum, self:getMaxEnemy(), self.endlessWaveNum)
    else
        GUI.TopInfo:updateBoard(self.enemyNum, self:getMaxEnemy(), math.min(self.waveNum, MAX_WAVE_NUM - 1),
            MAX_WAVE_NUM - 1)
    end

    local excessiveEnemy = math.max(self.enemyNum - 40, 0)

    local hideEffectChance = (1 - 1 / ((excessiveEnemy / 20) + 1)) * 100
    self.hideEffectChance = hideEffectChance

end
--------------------------------------------------------------------------------------
function mt:startModeNormal()
    self.waveMode = WAVE_MODE_NORMAL
end
--------------------------------------------------------------------------------------
function mt:startModeEndless()
    self.waveMode = WAVE_MODE_ENDLESS

    self.endlessWaveNum = 0
    self.endlessWaveCountdown = 0
    self.endlessWaveInterval = 20
    for _, player in ipairs(fc.getAlivePlayers()) do
        if player:hasArch([[C1-ENDLESS10]]) then
            player.hero:modStats(ST_DMG_RATE, 10)
        end
    end

    self.endlessMin = 0
    self.endlessSec = 0
    self.endlessMaxMin = 30

    ac.loop(ms(1), function(t)
        self.endlessSec = self.endlessSec + 1
        if self.endlessSec >= 59 then
            self.endlessSec = 0
            self.endlessMin = self.endlessMin + 1

            local leftMin = self.endlessMaxMin - self.endlessMin
            if leftMin > 0 then
                msg.notice(cst.ALL_PLAYERS, str.format('无尽模式还剩[|cffffff00%.0f|r]分钟', leftMin))
            else
                if not self.endlessEnd then
                    gm:enterGameState(GAME_STATE_POST_ENDLESS)
                    self.endlessEnd = true
                end
                t:remove()
            end

        end

    end)

end
--------------------------------------------------------------------------------------
function mt:onTickWaveEndless()
    if self.endlessEnd then
        return
    end

    if self.endlessWaveCountdown <= 0 or self.enemyNum <= 15 * #fc.getAlivePlayers() and
        (not fc.isInCd(self, '无尽刷波次冷却')) then
        fc.setInnerCd(self, '无尽刷波次冷却', 3)
        self:startNextEndlessWave()
    else
        self.endlessWaveCountdown = self.endlessWaveCountdown - gm.tickInterval
    end

    if self.tickCount % 60 == 0 then
        self:updateAtkOrders()
    end

end
--------------------------------------------------------------------------------------
function mt:startNextEndlessWave()
    self.endlessWaveNum = self.endlessWaveNum + 1
    for i = 1, #ENDLESS_CHIEVEMENT_WAVE_REQUIRE[1], 1 do
        if self.endlessWaveNum == ENDLESS_CHIEVEMENT_WAVE_REQUIRE[1][i] then
            for _, player in ipairs(fc.getAlivePlayers()) do
                local name = str.format('第%d章无尽%d波', gm.chapter.id, self.endlessWaveNum)
                player:tryUnlockArch(name)
            end
        end
    end
    self.endlessWaveCountdown = self.endlessWaveInterval

    local rngPoolNumber = math.random(#gm.chapter.endlessPoolSet)
    local poolSet = gm.chapter.endlessPoolSet[rngPoolNumber]

    --------------------------------------------------------------------------------------
    -- 生成小怪
    for _, pTarget in ipairs(fc.getAlivePlayers()) do
        for i = 1, 20 do

            ac.wait(ms(0.05 * i), function()
                local chapter = gm.chapter

                local enemyName = fc.rngSelect(poolSet[ENEMY_TYPE_NORMAL])
                local enemyPack = reg:getTableData('enemyData', enemyName)
                local enemyStats = self:makeEndlessEnemyStats({
                    enemyPack = enemyPack,
                    waveNum = self.endlessWaveNum,
                    diffNum = self.diffNum,
                })

                local enemy = self:createEnemy({
                    pTarget = pTarget,
                    enemyName = enemyName,
                    enemyStats = enemyStats,
                    bornPoint = pTarget:getRandomEnemyBornPoint(),
                    tgtPoint = gm.mapArea.centerPoint,
                })

                enemy.bTideEnemy = true
                enemy.onReward = mt.standardOnReward
                enemy.bNoReward = true

                fc.unitEffect({
                    model = [[Abilities\Spells\Undead\RaiseSkeletonWarrior\RaiseSkeleton.mdl]],
                    bind = 'origin',
                }, enemy)
            end)

        end
    end

    --------------------------------------------------------------------------------------
    -- 生成精英
    for _, pTarget in ipairs(fc.getAlivePlayers()) do
        for i = 1, 5 do

            ac.wait(ms(0.1 * i), function()
                local chapter = gm.chapter

                local enemyName = fc.rngSelect(poolSet[ENEMY_TYPE_ELITE])
                local enemyPack = reg:getTableData('enemyData', enemyName)
                local enemyStats = self:makeEndlessEnemyStats({
                    enemyPack = enemyPack,
                    waveNum = self.endlessWaveNum,
                    diffNum = self.diffNum,
                })

                local enemy = self:createEnemy({
                    pTarget = pTarget,
                    enemyName = enemyName,
                    enemyStats = enemyStats,
                    bornPoint = pTarget:getRandomEnemyBornPoint(),
                    tgtPoint = gm.mapArea.centerPoint,
                })

                enemy.onReward = mt.standardOnReward
                enemy.bNoReward = true

                fc.unitEffect({
                    model = [[Abilities\Spells\Undead\RaiseSkeletonWarrior\RaiseSkeleton.mdl]],
                    bind = 'origin',
                }, enemy)
            end)

        end
    end

    --------------------------------------------------------------------------------------
    -- 生成首领
    if self.endlessWaveNum % 5 == 0 then
        for _, pTarget in ipairs(fc.getAlivePlayers()) do
            for i = 1, 1 do

                ac.wait(ms(0.5), function()
                    local chapter = gm.chapter

                    local enemyName = fc.rngSelect(gm.chapter.endlessBossPool)
                    local enemyPack = reg:getTableData('enemyData', enemyName)
                    local enemyStats = self:makeEndlessEnemyStats({
                        enemyPack = enemyPack,
                        waveNum = self.endlessWaveNum,
                        diffNum = self.diffNum,
                    })

                    local enemy = self:createEnemy({
                        pTarget = pTarget,
                        enemyName = enemyName,
                        enemyStats = enemyStats,
                        bornPoint = pTarget:getRandomEnemyBornPoint(),
                        tgtPoint = gm.mapArea.centerPoint,
                    })

                    enemy.onReward = mt.standardOnReward
                    enemy.bNoReward = true

                    fc.unitEffect({
                        model = [[Abilities\Spells\Undead\RaiseSkeletonWarrior\RaiseSkeleton.mdl]],
                        bind = 'origin',
                    }, enemy)

                end)

            end
        end
    end

end
--------------------------------------------------------------------------------------
function mt:gameLoseFreezeEnemy()
    for i, enemy in ipairs(self.enemies) do
        enemy:pause()
        enemy.immuneCounter = enemy.immuneCounter + 99
    end
end
--------------------------------------------------------------------------------------
function mt:removeEnemy(enemy)
    if enemy.removed then
        print('enemy already removed: ' .. enemy:getName())
        return
    end

    enemy.bCleared = true
    table.removeTarget(self.enemies, enemy)
    local enemyCount = enemy.enemyCount
    self:updateEnemyNum(enemyCount * -1)

    enemy:remove()
end
--------------------------------------------------------------------------------------
function mt:clearPlayerAllEnemies(player)
    local enemyList = {}
    for _, enemy in ipairs(self.enemies) do
        enemyList[#enemyList + 1] = enemy
    end

    for _, enemy in ipairs(enemyList) do
        if enemy.pTarget == player and (not enemy.bTeamEnemy) then
            self:removeEnemy(enemy)
        end
    end

end
--------------------------------------------------------------------------------------
function mt:updateAtkOrders()
    for i, enemy in ipairs(self.enemies) do
        if enemy.chaseUnit and enemy.chaseUnit:isAlive() and (not enemy:hasBuff('恐惧')) then
            if enemy.chaseUnit.isFishing then
                local newTgt = nil
                local minDis = 99999
                for _, p in ipairs(fc.getAlivePlayers()) do
                    if p.hero and (not p.hero.isFishing) then
                        local dis = enemy:getloc() * p.hero:getloc()
                        if dis < minDis then
                            minDis = dis
                            newTgt = p.hero
                        end
                    end
                end

                if newTgt then
                    enemy.chaseUnit = newTgt
                    enemy:issuePointOrder('move', enemy.chaseUnit:getloc())
                else
                    enemy:issuePointOrder('move', gm.mapArea.centerPoint)
                end

            else
                enemy:issuePointOrder('move', enemy.chaseUnit:getloc())
            end

        end
    end
end
--------------------------------------------------------------------------------------
return mt
