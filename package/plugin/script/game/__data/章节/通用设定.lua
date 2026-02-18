WAVE_INTERVAL = 50
WAVE_REST_TIME = 5

EnemyHpRate = {
    [ENEMY_TYPE_NORMAL] = 1,
    [ENEMY_TYPE_ELITE] = 5,
    [ENEMY_TYPE_BOSS] = 30,
}

EnemyAtkRate = {
    [ENEMY_TYPE_NORMAL] = 0.8,
    [ENEMY_TYPE_ELITE] = 2,
    [ENEMY_TYPE_BOSS] = 3,
}

FINAL_BOSS_ATK_RATE = 0.33

EnemyDefRate = {
    [ENEMY_TYPE_NORMAL] = 1,
    [ENEMY_TYPE_ELITE] = 1.5,
    [ENEMY_TYPE_BOSS] = 2.5,
}

EnemyRewardRate = {
    [ENEMY_TYPE_NORMAL] = 1,
    [ENEMY_TYPE_ELITE] = 3,
    [ENEMY_TYPE_BOSS] = 10,
}

EndlessHpRate = {
    [ENEMY_TYPE_NORMAL] = 1,
    [ENEMY_TYPE_ELITE] = 6,
    [ENEMY_TYPE_BOSS] = 20,
}

EndlessAtkRate = {
    [ENEMY_TYPE_NORMAL] = 1,
    [ENEMY_TYPE_ELITE] = 2,
    [ENEMY_TYPE_BOSS] = 3,
}

EndlessDefRate = {
    [ENEMY_TYPE_NORMAL] = 1,
    [ENEMY_TYPE_ELITE] = 1.5,
    [ENEMY_TYPE_BOSS] = 2,
}

TeamEnemyHpRate = {
    [0] = 1,
    [1] = 1,
    [2] = 1.6,
    [3] = 2.2,
    [4] = 3,
}

TeamEnemyAtkRate = {
    [0] = 1,
    [1] = 1,
    [2] = 1.1,
    [3] = 1.2,
    [4] = 1.3,
}

TeamEnemyDefRate = {
    [0] = 1,
    [1] = 1,
    [2] = 1.2,
    [3] = 1.4,
    [4] = 1.6,
}

TeamEnemyCdSpeed = {
    [0] = 0,
    [1] = 0,
    [2] = 0.05,
    [3] = 0.1,
    [4] = 0.15,
}

TeamLateEnemyNumNerf = {
    [0] = 0,
    [1] = 0,
    [2] = 0.1,
    [3] = 0.2,
    [4] = 0.3,
}

TeamLateEnemyHpRate = {
    [0] = 0,
    [1] = 0,
    [2] = 0.05,
    [3] = 0.1,
    [4] = 0.15,
}

EnemyAppearChance = {}
table.multiInsert(EnemyAppearChance, ENEMY_TYPE_NORMAL, 100)

--------------------------------------------------------------------------------------
-- 金币奖励
WaveRewardGold = {}
WaveRewardGold[1] = 15
for i = 2, 18 do
    WaveRewardGold[i] = WaveRewardGold[i - 1] + 5
end
for i = 19, MAX_WAVE_NUM do
    WaveRewardGold[i] = WaveRewardGold[i - 1]
end


--------------------------------------------------------------------------------------
-- 钻石奖励
WaveRewardLumber = {}
WaveRewardLumber[1] = 5
for i = 2, MAX_WAVE_NUM do
    WaveRewardLumber[i] = WaveRewardLumber[i - 1] + 1
end


--------------------------------------------------------------------------------------
-- 经验奖励
WaveRewardExp = {}
WaveRewardExp[1] = 8
for i = 2, 7 do
    WaveRewardExp[i] = WaveRewardExp[i - 1] + 2
end

for i = 8, MAX_WAVE_NUM do
    WaveRewardExp[i] = WaveRewardExp[i - 1]
end

--------------------------------------------------------------------------------------
-- 敌人数量
WaveEnemyPerSec = {}
for i = 1, 2 do
    WaveEnemyPerSec[i] = 0.6
end
for i = 3, 5 do
    WaveEnemyPerSec[i] = 0.8
end
for i = 6, 10 do
    WaveEnemyPerSec[i] = 1
end
for i = 11, 15 do
    WaveEnemyPerSec[i] = 1.5
end
WaveEnemyPerSec[16] = 3
WaveEnemyPerSec[17] = 3
WaveEnemyPerSec[18] = 3
WaveEnemyPerSec[19] = 2
WaveEnemyPerSec[20] = 2

WaveEnemyPerSec[21] = 5
WaveEnemyPerSec[22] = 4
WaveEnemyPerSec[23] = 3
WaveEnemyPerSec[24] = 2.5
WaveEnemyPerSec[25] = 2.5

WaveEnemyPerSec[26] = 3
WaveEnemyPerSec[27] = 4
WaveEnemyPerSec[28] = 4
WaveEnemyPerSec[29] = 3
WaveEnemyPerSec[30] = 5
WaveEnemyPerSec[31] = 5


StandardWaveHp = fc.createGrowTable({
    baseVal = 90,
    lastVal = 1.1,
    rateLv = 180,
    rateFix = 180,
    maxLv = MAX_WAVE_NUM,
})

local stepRate = {}
for i = 1, 8 do
    stepRate[i] = 1
end
for i = 9, 16 do
    stepRate[i] = 1.33
end
for i = 17, 24 do
    stepRate[i] = stepRate[16] * 1.33
end
for i = 25, 28 do
    stepRate[i] = stepRate[24] * 1.33
end
stepRate[29] = stepRate[28] * 1.2
stepRate[30] = stepRate[29] * 1.2

for i = 1, 30 do
    StandardWaveHp[i] = StandardWaveHp[i] * stepRate[i]
    -- gdebug('StandardHp[%d]: %.0f', i, StandardWaveHp[i])
end

StandardWaveHp[31] = StandardWaveHp[30]
--------------------------------------------------------------------------------------
StandardWaveAtk = fc.createGrowTable({
    baseVal = 20,
    lastVal = 1.2,
    rateLv = 0,
    rateFix = 30,
    maxLv = MAX_WAVE_NUM,
})
StandardWaveAtk[31] = StandardWaveAtk[30]
--------------------------------------------------------------------------------------
StandardWaveDef = fc.createGrowTable({
    baseVal = 2,
    lastVal = 1.05,
    rateLv = 0.5,
    rateFix = 1,
    maxLv = MAX_WAVE_NUM,
})
-- --------------------------------------------------------------------------------------
-- for i = 1, MAX_WAVE_NUM do
--     gdebug('标准怪数值')
--     gdebug('wave[%d],hp: %.0f, atk: %.0f, def: %.0f', i, StandardWaveHp[i], StandardWaveAtk[i], StandardWaveDef[i])
-- end
--------------------------------------------------------------------------------------
StandardWaveSpeedPct = fc.createGrowTable({
    baseVal = 1,
    lastVal = 1,
    rateLv = 0.05,
    rateFix = 0.5,
    maxLv = MAX_WAVE_NUM,
    multiRate = 0.01,
})

StandardWaveGoldChallengeRewards = fc.createGrowTable({
    baseVal = 200,
    lastVal = 1.03,
    rateLv = 50,
    rateFix = 100,
    maxLv = MAX_WAVE_NUM,
})

for i = 1, MAX_WAVE_NUM do
    StandardWaveGoldChallengeRewards[i] = math.ceil(StandardWaveGoldChallengeRewards[i] / 10) * 10
end

StandardWaveCrystalChallengeRewards = fc.createGrowTable({
    baseVal = 2,
    lastVal = 1,
    rateLv = 0,
    rateFix = 0.5,
    maxLv = MAX_WAVE_NUM,
})

for i = 1, MAX_WAVE_NUM do
    StandardWaveCrystalChallengeRewards[i] = math.ceil(StandardWaveCrystalChallengeRewards[i] / 10) * 10
end

--------------------------------------------------------------------------------------
EndlessWaveHp = fc.createGrowTable({
    baseVal = 200000,
    -- lastVal = 1.125,
    lastVal = 1.085,
    rateLv = 0,
    rateFix = 80000,
    maxLv = 1000,
})
--------------------------------------------------------------------------------------
EndlessWaveAtk = fc.createGrowTable({
    baseVal = 20000,
    lastVal = 1.045,
    rateLv = 0,
    rateFix = 5000,
    maxLv = 1000,
})
--------------------------------------------------------------------------------------
EndlessWaveDef = fc.createGrowTable({
    baseVal = 300,
    lastVal = 1,
    rateLv = 0,
    rateFix = 25,
    maxLv = 1000,
})

--------------------------------------------------------------------------------------
DEFAULT_CONTROL_RESIST_ELITE = 0.3
DEFAULT_CONTROL_RESIST_BOSS = 0.6
