local mt = {

    id = 1,
    name = '章节1',

    mapAreaName = '沐风森林',
    maxDiff = 4,
}
--------------------------------------------------------------------------------------
mt.enemyPool = {
    [ENEMY_TYPE_NORMAL] = {'普通小怪'},
}

mt.finalBoss = '血色领主' -- 看情况调用

mt.bossPool = {'丛林长者'} -- 看情况调用

mt.endlessPoolSet = { -- 看情况调用

    [1] = {
        [ENEMY_TYPE_NORMAL] = {'丛林蜘蛛', '淬毒蜘蛛'},
        [ENEMY_TYPE_ELITE] = {'血浴之母'},
    },
    [2] = {
        [ENEMY_TYPE_NORMAL] = {'熊怪战士', '熊怪萨满'},
        [ENEMY_TYPE_ELITE] = {'熊怪长老'},
    },
}

mt.endlessBossPool = {'恐怖之狼'} -- 看情况调用

--------------------------------------------------------------------------------------
-- 难度名称
mt.diffName = {}
for i = 1, mt.maxDiff do
    mt.diffName[i] = str.format('%d-%d', mt.id, i)
end

mt.diffName[1] = str.format('简单')
mt.diffName[2] = str.format('普通')
mt.diffName[3] = str.format('困难')
mt.diffName[4] = str.format('地狱')

--------------------------------------------------------------------------------------
mt.maxWaveNum = {
    [1] = 30,
    [2] = 30,
    [3] = 30,
    [4] = 30,
    [5] = 30,
    [6] = 30,
    [7] = 30,
    [8] = 30,
    [9] = 30,
    [10] = 30,
    [11] = 30,
    [12] = 30,
}

--------------------------------------------------------------------------------------
-- 血量系数
local rateList = {}
mt.hpRate = rateList
rateList[1] = 0.35
rateList[2] = 0.5
rateList[3] = 0.75
rateList[4] = 1.3
rateList[5] = 2.4
rateList[6] = 4
rateList[7] = 6.5
rateList[8] = 10.5

--------------------------------------------------------------------------------------
-- 终末血量递增
local rateList = {}
mt.finalHpRaiseList = rateList
rateList[1] = 0
rateList[2] = 0
rateList[3] = 0
rateList[4] = 0
rateList[5] = 0
rateList[6] = 0.5
rateList[7] = 0.75
rateList[8] = 1
for i = 1, 8 do
    rateList[i] = rateList[i] / 10
end

--------------------------------------------------------------------------------------
-- 攻击系数
local rateList = {}
mt.atkRate = rateList
rateList[1] = 0.55
rateList[2] = 0.85
rateList[3] = 1.2
rateList[4] = 2
rateList[5] = 3
rateList[6] = 4.5
rateList[7] = 8
rateList[8] = 14
--------------------------------------------------------------------------------------
-- 防御系数
local rateList = {}
mt.defRate = rateList
rateList[1] = 0.75
rateList[2] = 1
rateList[3] = 1.4
rateList[4] = 2
rateList[5] = 2.8
rateList[6] = 4
rateList[7] = 5.5
rateList[8] = 7.5
--------------------------------------------------------------------------------------
local rateList = {}
mt.diffRate = rateList
rateList[1] = 1
rateList[2] = 2
rateList[3] = 3
rateList[4] = 4
rateList[5] = 5
rateList[6] = 6
rateList[7] = 7
rateList[8] = 8
--------------------------------------------------------------------------------------

mt.waveHp = StandardWaveHp
mt.waveAtk = StandardWaveAtk
mt.waveDef = StandardWaveDef
mt.waveSpeedPct = StandardWaveSpeedPct
--------------------------------------------------------------------------------------
-- mt.endlessWaveHp = fc.createGrowTable({
--     baseVal = 200000,
--     lastVal = 1.14,
--     rateLv = 0,
--     rateFix = 80000,
--     maxLv = 1000,
-- })
-- --------------------------------------------------------------------------------------
-- mt.endlessWaveAtk = fc.createGrowTable({
--     baseVal = 20000,
--     lastVal = 1.05,
--     rateLv = 0,
--     rateFix = 5000,
--     maxLv = 1000,
-- })
-- --------------------------------------------------------------------------------------
-- mt.endlessWaveDef = fc.createGrowTable({
--     baseVal = 300,
--     lastVal = 1,
--     rateLv = 0,
--     rateFix = 50,
--     maxLv = 1000,
-- })

--------------------------------------------------------------------------------------
-- 难度命中
mt.diffAcc = fc.createGrowTable({
    baseVal = 0,
    lastVal = 1,
    rateLv = 1,
    rateFix = 0,
    maxLv = mt.maxDiff,
})
--------------------------------------------------------------------------------------
-- 难度闪避
mt.diffEvade = fc.createGrowTable({
    baseVal = 0,
    lastVal = 0,
    rateLv = 0,
    rateFix = 0,
    maxLv = mt.maxDiff,
})

--------------------------------------------------------------------------------------
-- 难度破甲破抗
mt.diffNerfDef = fc.createGrowTable({
    baseVal = 0,
    lastVal = 1,
    rateLv = 0.5,
    rateFix = 0,
    maxLv = mt.maxDiff,
})

--------------------------------------------------------------------------------------
-- 难度暴击闪避
mt.diffCritEvade = fc.createGrowTable({
    baseVal = 0,
    lastVal = 1,
    rateLv = 0.5,
    rateFix = 0,
    maxLv = mt.maxDiff,
})

mt.diffCritEvade[7] = 15
mt.diffCritEvade[8] = 20

--------------------------------------------------------------------------------------
-- 难度暴击抗性
mt.diffCritResist = fc.createGrowTable({
    baseVal = 0,
    lastVal = 1,
    rateLv = 0,
    rateFix = 0,
    maxLv = mt.maxDiff,
})

mt.diffCritResist[7] = 50
mt.diffCritResist[8] = 75

--------------------------------------------------------------------------------------
-- 难度物理魔法抗性
mt.diffPhyMagResist = fc.createGrowTable({
    baseVal = 0,
    lastVal = 1,
    rateLv = 0,
    rateFix = 0,
    maxLv = mt.maxDiff,
})

mt.diffPhyMagResist[7] = 40
mt.diffPhyMagResist[8] = 60

--------------------------------------------------------------------------------------
-- 难度伤害防御系数
mt.diffDmgDefResist = fc.createGrowTable({
    baseVal = 0,
    lastVal = 1,
    rateLv = 0,
    rateFix = 0,
    maxLv = mt.maxDiff,
})

mt.diffDmgDefResist[7] = 40
mt.diffDmgDefResist[8] = 60
--------------------------------------------------------------------------------------
-- 难度额外每波血量
mt.diffAddWaveHp = {
    [1] = 0,
    [2] = 0,
    [3] = 0,
    [4] = 0,
    [5] = 0,
    [6] = 0,
    [7] = 0,
    [8] = 0,
}
--------------------------------------------------------------------------------------
-- 难度额外每波攻击
mt.diffAddWaveAtk = {
    [1] = 0,
    [2] = 0,
    [3] = 0,
    [4] = 0,
    [5] = 0,
    [6] = 0,
    [7] = 0,
    [8] = 0,
}
--------------------------------------------------------------------------------------
-- 难度额外每波护甲魔抗
mt.diffAddWaveDef = {
    [1] = 0,
    [2] = 0,
    [3] = 0,
    [4] = 0,
    [5] = 0,
    [6] = 0,
    [7] = 0,
    [8] = 0,
}
--------------------------------------------------------------------------------------
mt.kickBackResist = {
    [1] = 0,
    [2] = 0,
    [3] = 0,
    [4] = 0,
    [5] = 0,
    [6] = 0,
    [7] = 0,
    [8] = 0,
}


mt.hasHellMode = {
    [0] = false,
    [1] = false,
    [2] = false,
    [3] = false,
    [4] = false,
    [5] = true,
    [6] = true,
    [7] = true,
    [8] = true,
}

mt.hellModeMaxHeat = {
    [0] = 0,
    [1] = 0,
    [2] = 0,
    [3] = 0,
    [4] = 0,
    [5] = 80,
    [6] = 80,
    [7] = 80,
    [8] = 80,
}

--------------------------------------------------------------------------------------
-- as.dataRegister:initTableData('chapterData', mt)
reg:addToPool('chapters', mt)
