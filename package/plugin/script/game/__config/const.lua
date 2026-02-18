--------------------------------------------------------------------------------------
GAME_VERSION = '0.0.1'
PROCESS_SELECTOR_WAY = 0
--------------------------------------------------------------------------------------
MAP_DEBUG_MODE = true
MAP_DEEP_DEBUG = false
MAP_TRACE_BACK = false
--------------------------------------------------------------------------------------
TESTING_SERVER = true
TEST_MAP_LV = 40
TEST_ARCH_OVER_LIMIT = true
--------------------------------------------------------------------------------------
TESTING_SERVER_START_UNIX_TIME = 1738909316
GENERAL_START_UNIX_TIME = 1740459600 -- 上线前记得调

EARLIEST_WEEK_UNIX_TIME = 1745884800 -- 最早开始记录游戏周数

if TESTING_SERVER then
    GENERAL_START_UNIX_TIME = TESTING_SERVER_START_UNIX_TIME
end

if not localEnv then
    MAP_DEBUG_MODE = false
end
--------------------------------------------------------------------------------------
STR_RATE_HP = 0
STR_RATE_HP_REGEN = 0
STR_RATE_HP_PCT = 0.01 * 0.1
STR_RATE_PHY_DMG = 0.01 * 0.1

AGI_RATE_ATK_SPD = 0.01 * 0.1
AGI_RATE_ATK_DMG = 0.01 * 0.1

INT_RATE_SKILL_DMG = 0.01 * 0.1
INT_RATE_MAG_DMG = 0.01 * 0.1

INT_RATE_SPE_ATK = 1
INT_RATE_CHARGE_1 = 1
INT_RATE_CHARGE_2 = 100000
INT_RATE_MAG_RATE_1 = 1
INT_RATE_MAG_RATE_2 = 100000

MAIN_RATE_ATK = 0

--------------------------------------------------------------------------------------
AMP_RATE_PHY_1 = 20
AMP_RATE_PHY_2 = 2000

AMP_RATE_MAG_1 = 20
AMP_RATE_MAG_2 = 2000

AMP_RATE_SUMMON_1 = 20
AMP_RATE_SUMMON_2 = 2000

AMP_RATE_CRIT_1 = 10
AMP_RATE_CRIT_2 = 1000

AMP_RATE_PHYMAG_1 = 10
AMP_RATE_PHYMAG_2 = 1000

AMP_RATE_DMG_1 = 10
AMP_RATE_DMG_2 = 1000

AMP_RATE_CONTROL_1 = 5
AMP_RATE_CONTROL_2 = 1000

MAX_ATK_SPEED = 10

MAX_WAVE_NUM = 31
MAX_AURA_RADIUS = 99999

UNIT_DEFAULT_MOVE_SPEED = 330

MIN_MOVE_SPEED = 100

BOSS_ENEMY_COUNT = 10
--------------------------------------------------------------------------------------
FRAME_INTERVAL_NORMAL = 0.03
FRAME_INTERVAL_UI = 0.06
SHOCK_WAVE_FRAME_INTERVAL = 2
GAME_TICK_INTERVAL = 0.05
--------------------------------------------------------------------------------------
UI_LEVEL_HERO_HP_GUI = 2
--------------------------------------------------------------------------------------

DEFAULT_AURA_AOE = 1500

SKILL_BTN_HOTKEY = {
    [1] = 'Q',
    [2] = 'W',
    [3] = 'E',
    [4] = 'R',
    [5] = 'A',
    [6] = 'S',
    [7] = 'D',
    [8] = 'F',
    [9] = 'Z',
    [10] = 'X',
    [11] = 'C',
    [12] = 'V',
}

RESOURCE_ICON_GOLD = [[gold_icon.tga]]
RESOURCE_ICON_LUMBER = [[crystal_icon.tga]]
RESOURCE_ICON_POPULATION = [[UI\Feedback\Resources\ResourceSupply.blp]]
RESOURCE_ICON_KILL = [[kill_icon.tga]]

ART_NOT_ENOUGH_GOLD = [[not_enough_gold.tga]]
ART_NOT_ENOUGH_LUMBER = [[not_enough_crystal.tga]]
ART_NOT_ENOUGH_KILL = [[not_enough_kill.tga]]

--------------------------------------------------------------------------------------
local mt = {}
cst = mt

mt.counter = 0
mt.keys = {}
mt.skillCounter = 0
mt.skillKeys = {}
--------------------------------------------------------------------------------------
local function makeConstId(keys)
    mt.counter = mt.counter + 1
    mt.keys[mt.counter] = keys

    return mt.counter
end
fc.makeConstId = makeConstId
--------------------------------------------------------------------------------------
local function makeSkillId(keys)
    mt.skillCounter = mt.skillCounter + 1
    mt.skillKeys[mt.skillCounter] = keys
    return mt.skillCounter
end
fc.makeSkillId = makeSkillId
--------------------------------------------------------------------------------------
function mt:getConstKeys(constId)
    return mt.keys[constId]
end

--------------------------------------------------------------------------------------
function mt:getConstName(constId)
    if not mt.keys[constId] then
        return
    end

    return mt.keys[constId].name
end
--------------------------------------------------------------------------------------
function mt:getConstTag(constId, tag)
    if not mt.keys[constId] then
        return
    end

    return mt.keys[constId][tag]
end
--------------------------------------------------------------------------------------
function mt:getConstActuallyName(constId)
    if not mt.keys[constId] then
        return
    end

    return mt.keys[constId].actuallyName
end
--------------------------------------------------------------------------------------
-- 修改时绿字，获取时白*百分比+绿

ST_ATK = makeConstId({
    name = '攻击力',
    textColor = '|cfff8d664',
    updateUI = true,
})

ST_BLOCK = makeConstId({
    name = '格挡',
    textColor = '|cfff8d664',
    updateUI = true,
})

ST_STR = makeConstId({
    name = '力量',
    textColor = '|cffff8080',
    updateUI = true,
})
ST_AGI = makeConstId({
    name = '敏捷',
    textColor = '|cff99cc00',
    updateUI = true,
})
ST_INT = makeConstId({
    name = '智力',
    textColor = '|cff33cccc',
    updateUI = true,
})

ST_MOVE_SPEED = makeConstId({
    name = '移速',
})

ST_SLOW_RESIST = makeConstId({
    name = '减速抗性',
    isPct = true,
})


ST_MAIN = makeConstId({
    name = '主属性',
})
ST_SIDE = makeConstId({
    name = '次属性',
})
ST_ALL = makeConstId({
    name = '所有属性',
    textColor = '|cffffcc00',
})

ST_RANDOM = makeConstId({
    name = '随机属性', -- 是forloop，效率比较低
})

ST_ACC = makeConstId({
    name = '命中',
})

ST_EVADE = makeConstId({
    name = '闪避',
})

--------------------------------------------------------------------------------------
-- 修改时白字，获取时白*百分比
ST_ATK_LIFE_STEAL = makeConstId({
    name = '攻击吸血',
})


--------------------------------------------------------------------------------------
-- 白字

ST_BASE_ATK = makeConstId({
    name = '基础攻击力',
    updateUI = true,
})

ST_BASE_HP_MAX = makeConstId({
    name = '基础血量上限',
    updateUI = true,
})

ST_BASE_BLOCK = makeConstId({
    name = '基础格挡',
    updateUI = true,
})

ST_BASE_STR = makeConstId({
    name = '基础力量',
    updateUI = true,
})
ST_BASE_AGI = makeConstId({
    name = '基础敏捷',
    updateUI = true,
})
ST_BASE_INT = makeConstId({
    name = '基础智力',
    updateUI = true,
})

ST_BASE_MAIN = makeConstId({
    name = '基础主属性',
})
ST_BASE_SIDE = makeConstId({
    name = '基础次属性',
})
ST_BASE_ALL = makeConstId({
    name = '基础全属性',
})

ST_BASE_ATK_LIFE_STEAL = makeConstId({
    name = '基础攻击吸血',
})

ST_BASE_MOVE_SPEED = makeConstId({
    name = '移速',
})

ST_BASE_PHY_DEF = makeConstId({
    name = '护甲',
})

ST_BASE_MAG_DEF = makeConstId({
    name = '魔抗',
})

ST_BASE_PHY_DEF_PCT = makeConstId({
    name = '护甲',
    isPct = true,
})

ST_BASE_MAG_DEF_PCT = makeConstId({
    name = '魔抗',
    isPct = true,
})

ST_BASE_DOUBLE_DEF = makeConstId({
    name = '基础护甲，魔抗',
})
--------------------------------------------------------------------------------------
-- 绿字
ST_BONUS_ATK = makeConstId({
    name = '额外攻击力',
    textColor = '|cfff8d664',
    updateUI = true,
})

ST_BONUS_PHY_DEF = makeConstId({
    name = '额外护甲',
    textColor = '|cfff8d664',
    updateUI = true,
})

ST_BONUS_MAG_DEF = makeConstId({
    name = '额外魔抗',
    textColor = '|cfff8d664',
    updateUI = true,
})

ST_BONUS_HP_MAX = makeConstId({
    name = '额外血量上限',
})

ST_BONUS_MOVE_SPEED = makeConstId({
    name = '额外移速',
})

ST_BONUS_STR = makeConstId({
    name = '额外力量',
    textColor = '|cffff8080',
    updateUI = true,
})
ST_BONUS_AGI = makeConstId({
    name = '额外敏捷',
    textColor = '|cff99cc00',
    updateUI = true,
})
ST_BONUS_INT = makeConstId({
    name = '额外智力',
    textColor = '|cff33cccc',
    updateUI = true,
})

ST_BONUS_MAIN = makeConstId({
    name = '额外主属性',
})
ST_BONUS_SIDE = makeConstId({
    name = '额外次属性',
})
ST_BONUS_ALL = makeConstId({
    name = '额外全属性',
})


--------------------------------------------------------------------------------------
-- 乘算性质的改动白字百分比
ST_BASE_ATK_PCT = makeConstId({
    name = '白字攻击',
    isPct = true,
})

ST_BASE_HP_MAX_PCT = makeConstId({
    name = '白字生命',
    isPct = true,
})

--------------------------------------------------------------------------------------
-- 百分比

ST_ATK_PCT = makeConstId({
    name = '攻击力加成',
    isPct = true,
})

ST_PHY_DEF_PCT = makeConstId({
    name = '护甲',
    isPct = true,
})

ST_MAG_DEF_PCT = makeConstId({
    name = '魔抗',
    isPct = true,
})

ST_BLOCK_PCT = makeConstId({
    name = '格挡',
    isPct = true,
})

ST_STR_PCT = makeConstId({
    name = '力量加成',
    isPct = true,
})
ST_AGI_PCT = makeConstId({
    name = '敏捷加成',
    isPct = true,
})
ST_INT_PCT = makeConstId({
    name = '智力加成',
    isPct = true,
})

ST_MAIN_PCT = makeConstId({
    name = '主属性加成',
    isPct = true,
})
ST_SIDE_PCT = makeConstId({
    name = '次属性加成',
    isPct = true,
})
ST_ALL_PCT = makeConstId({
    name = '全属性加成',
    isPct = true,
})

ST_AURA_AOE_PCT = makeConstId({
    name = '光环范围',
    isPct = true,
})

ST_MOVE_SPEED_PCT = makeConstId({
    name = '移速',
    isPct = true,
})

ST_ATK_LIFE_STEAL_PCT = makeConstId({
    name = '攻击回血增幅',
    isPct = true,
})

ST_HP = makeConstId({
    name = '生命',
})

ST_HP_PCT = makeConstId({
    name = '生命百分比',
    isPct = true,
})

ST_HP_MAX = makeConstId({
    name = '生命上限',
})

ST_HP_MAX_PCT = makeConstId({
    name = '生命上限',
    isPct = true,
})

ST_BASE_HP_REGEN = makeConstId({
    name = '基础每秒回血',
})

ST_BONUS_HP_REGEN = makeConstId({
    name = '额外每秒回血',
})

ST_HP_REGEN = makeConstId({
    name = '每秒回血',
})

ST_HP_REGEN_PCT = makeConstId({
    name = '每秒回血',
    isPct = true,
})

ST_MP = makeConstId({
    name = '魔法',
})

ST_MP_REGEN = makeConstId({
    name = '每秒回蓝',
})

ST_MP_REGEN_PCT = makeConstId({
    name = '魔法恢复速率',
    isPct = true,
})

ST_MP_PCT = makeConstId({
    name = '魔法百分比',
    isPct = true,
})

ST_MP_MAX = makeConstId({
    name = '魔法上限',
})

ST_MP_MAX_PCT = makeConstId({
    name = '魔法上限',
    isPct = true,
})

ST_FINAL_DMG_PCT = makeConstId({
    name = '最终伤害',
    isPct = true,
})

ST_FINAL_REDUCE_DMG_PCT = makeConstId({
    name = '最终减伤',
    isPct = true,
})

ST_SKILL_DMG = makeConstId({
    name = '技能伤害',
    isPct = true,
})
ST_ATK_DMG = makeConstId({
    name = '攻击伤害',
    isPct = true,
})
ST_ATK_SPEED = makeConstId({
    name = '攻速',
    isPct = true,
})

ST_ATK_INTERVAL = makeConstId({
    name = '攻击间隔', -- read only
})

ST_ATK_INTERVAL_REDUCE = makeConstId({
    name = '攻击间隔',
    negateSign = true,
})

ST_PHY_DEF = makeConstId({
    name = '护甲',
    updateUI = true,
})

ST_ATK_CRIT_RATE = makeConstId({
    name = '攻击暴伤',
    isPct = true,
})

ST_ATK_DEF_RATE = makeConstId({
    name = '攻击减伤系数',
    x100 = true,
})

ST_SKILL_DEF_RATE = makeConstId({
    name = '技能减伤系数',
    x100 = true,
})

ST_SKILL_CRIT_RATE = makeConstId({
    name = '技能暴伤',
    isPct = true,
})

ST_MAG_DEF = makeConstId({
    name = '魔抗',
})

ST_PURE_DEF = makeConstId({
    name = '真伤抗性',
})

ST_RECEIVE_EXTRA_DMG = makeConstId({
    name = '受到额外伤害',
    isPct = true,
})

ST_RECEIVE_EXTRA_PHY_DMG = makeConstId({
    name = '受到额外物理伤害',
    isPct = true,
})

ST_RECEIVE_EXTRA_MAG_DMG = makeConstId({
    name = '受到额外魔法伤害',
    isPct = true,
})

ST_PHY_RATE = makeConstId({
    name = '物理强度',
    isPct = true,
})
ST_PHY_RESIST = makeConstId({
    name = '物伤抗性',
    isPct = true,
})
ST_MAG_RATE = makeConstId({
    name = '魔法强度',
    isPct = true,
})
ST_MAG_RESIST = makeConstId({
    name = '法伤抗性',
    isPct = true,
})
ST_ATK_RATE = makeConstId({
    name = '攻击增伤',
    isPct = true,
})

ST_SLOW_SPEED = makeConstId({
    name = '减速',
    isPct = true,
})
ST_SLOW_TIME = makeConstId({
    name = '减速时长',
    isPct = true,
})

ST_DMG_REDUCTION = makeConstId({
    name = '减伤',
    isPct = true,
})

ST_SKILL_RATE = makeConstId({
    name = '技能增伤',
    isPct = true,
})
ST_SUMMON_RATE = makeConstId({
    name = '召唤强度',
    isPct = true,
})
ST_SUMMON_AMP = makeConstId({
    name = '真实召唤增强', -- 根据[ST_SUMMON_RATE]计算，只读
    isPct = true,
})

ST_SUMMON_TIME = makeConstId({
    name = '召唤持续时间',
    isPct = true,
})

ST_SUMMON_ATK_SPEED = makeConstId({
    name = '召唤攻速',
    isPct = true,
})

ST_CD_SPEED = makeConstId({
    name = '冷却加速',
    isPct = true,
})

ST_CD_AMP = makeConstId({
    name = '真实冷却缩减', -- 根据[ST_CD_SPEED]计算，只读
    isPct = true,
})

ST_PHY_PENETRATE = makeConstId({
    name = '护甲穿透系数',
    isPct = true,
})

ST_MAG_PENETRATE = makeConstId({
    name = '魔抗穿透系数',
    isPct = true,
})

ST_PHY_CRIT_CHANCE = makeConstId({
    name = '物理暴率',
    isPct = true,
})

ST_MAG_CRIT_CHANCE = makeConstId({
    name = '法术暴率',
    isPct = true,
})

ST_CRIT_CHANCE = makeConstId({
    name = '暴击几率',
    isPct = true,
})

--------------------------------------------------------------------------------------
ST_PHY_CRIT_RATE = makeConstId({
    name = '物理暴伤',
    isPct = true,
})

ST_MAG_CRIT_RATE = makeConstId({
    name = '法术暴伤',
    isPct = true,
})

ST_CRIT_RATE = makeConstId({
    name = '暴击伤害',
    isPct = true,
})

--------------------------------------------------------------------------------------
ST_CREEP_DMG_RATE = makeConstId({
    name = '小兵增伤',
    isPct = true,
})

ST_ELITE_DMG_RATE = makeConstId({
    name = '精英增伤',
    isPct = true,
})

ST_BOSS_DMG_RATE = makeConstId({
    name = '首领增伤',
    isPct = true,
})

ST_CHALLENGE_DMG_RATE = makeConstId({
    name = '挑战怪增伤',
    isPct = true,
})

ST_CHALLENGE_DMG_RATE_PHY = makeConstId({
    name = '挑战怪物理增伤',
    isPct = true,
})

ST_CHALLENGE_DMG_RATE_MAG = makeConstId({
    name = '挑战怪魔法增伤',
    isPct = true,
})

ST_TOWER_DMG_RATE = makeConstId({
    name = '魔塔怪增伤',
    isPct = true,
})

ST_TOWER_DMG_RATE_PHY = makeConstId({
    name = '试炼怪物理增伤',
    isPct = true,
})

ST_TOWER_DMG_RATE_MAG = makeConstId({
    name = '试炼怪魔法增伤',
    isPct = true,
})

ST_SHIELD_BREAK_RATE = makeConstId({
    name = '破盾效率',
    isPct = true,
})

ST_SHIELD_BREAK_RATE_PHY = makeConstId({
    name = '物理破盾效率',
    isPct = true,
})

ST_SHIELD_BREAK_RATE_MAG = makeConstId({
    name = '魔法破盾效率',
    isPct = true,
})

ST_SHIELD_AMT = makeConstId({
    name = '护盾值',
})

ST_SHIELD_MAX_RECORD = makeConstId({
    name = '护盾最大记录数',
})
--------------------------------------------------------------------------------------

PST_GOLD_RATE = makeConstId({
    name = '金币获取率',
    isPct = true,
    isPlayerStats = true,
})

PST_LUMBER_RATE = makeConstId({
    name = '木材获取率',
    isPct = true,
    isPlayerStats = true,
})

PST_KILL_RATE = makeConstId({
    name = '杀敌获取率',
    isPct = true,
    isPlayerStats = true,
})

ST_EXP_RATE = makeConstId({
    name = '经验获取率',
    isPct = true,
})

ST_POWER_UP_RATE = makeConstId({
    name = '战场掉落物属性加成',
    isPct = true,
})

ST_HEAL_RATE = makeConstId({
    name = '给予治疗强度',
})

ST_HEALED_RATE = makeConstId({
    name = '获得治疗强度',
})

ST_BASE_RANGE = makeConstId({
    name = '基础射程',
})

ST_RANGE = makeConstId({
    name = '射程',
})

ST_EXTRA_RANGE = makeConstId({
    name = '射程', -- 绿字
})

ST_RANGE_PCT = makeConstId({
    name = '射程',
    isPct = true,
})

ST_ATK_NERF_PHY_DEF = makeConstId({
    name = '攻击减甲',
})

ST_ATK_NERF_MAG_DEF = makeConstId({
    name = '攻击减抗',
})

ST_MULTI_ATK_CHANCE = makeConstId({
    name = '连击箭几率',
    isPct = true,
})

ST_MULTI_ATK_COUNT = makeConstId({
    name = '连击箭数量',
})

ST_MULTI_ATK_DMG = makeConstId({
    name = '连击箭伤害',
    isPct = true,
})

ST_SPLIT_ATK_CHANCE = makeConstId({
    name = '多重箭几率',
    isPct = true,
})

ST_SPLIT_ATK_COUNT = makeConstId({
    name = '多重箭数量',
})

ST_SPLIT_ATK_DMG = makeConstId({
    name = '多重箭伤害',
    isPct = true,
})

ST_BOUNCE_ATK_CHANCE = makeConstId({
    name = '弹射箭几率',
    isPct = true,
})

ST_BOUNCE_ATK_COUNT = makeConstId({
    name = '弹射箭数量',
})

ST_BOUNCE_ATK_DMG = makeConstId({
    name = '弹射箭伤害',
    isPct = true,
})

ST_ARROW_RANGE = makeConstId({
    name = '箭术射程',
    isPct = true,
})

ST_ARROW_SIZE = makeConstId({
    name = '箭术尺寸',
    isPct = true,
})

ST_ARROW_SPEED = makeConstId({
    name = '箭术射速',
    isPct = true,
})

ST_ARROW_HIT_RANGE = makeConstId({
    name = '箭术碰撞体积',
    isPct = true,
})

ST_DMG_RATE = makeConstId({
    name = '伤害系数',
    isPct = true,
})

ST_DEF_RATE = makeConstId({
    name = '减伤系数',
    isPct = true,
})

ST_CRIT_EVADE = makeConstId({
    name = '暴击闪避',
    isPct = true,
})
ST_CRIT_RESIST = makeConstId({
    name = '暴击抗性',
    isPct = true,
})

ST_DEBUFF_ACC = makeConstId({
    name = '减益命中',
})
ST_DEBUFF_EVADE = makeConstId({
    name = '减益闪避',
})

ST_DEBUFF_APPLY = makeConstId({
    name = '对敌减益延时',
    isPct = true,
})
ST_DEBUFF_GET = makeConstId({
    name = '受到减益延时',
    isPct = true,
})

ST_CONTROL_RATE = makeConstId({
    name = '控制时长',
    isPct = true,
})
ST_CONTROL_RESIST = makeConstId({
    name = '控制抵抗',
    isPct = true,
})

ST_REVIVE_TIME_PCT = makeConstId({
    name = '复活加速',
    isPct = true,
})

ST_REVIVE_IMMUNE_TIME_PCT = makeConstId({
    name = '复活无敌时间',
    isPct = true,
})

ST_DASH_RANGE = makeConstId({
    name = '突进距离',
})


-- 命中闪避
ST_ACC = makeConstId({
    name = '命中加成',
})

ST_EVADE = makeConstId({
    name = '闪避',
})

ST_ITEM_RATE = makeConstId({
    name = '物品掉落系数',
})

ST_CHALLENGE_CD_REDUCE = makeConstId({
    name = '挑战冷却缩减',
    isPct = true,
})

ST_IGNORE_PHY_DEF = makeConstId({
    name = '护甲忽视',
})

ST_IGNORE_MAG_DEF = makeConstId({
    name = '魔抗忽视',
})
--------------------------------------------------------------------------------------
-- read onlay
ST_TRUE_ITEM_RATE = makeConstId({
    name = '物品掉率增加',
    isPct = true,
})

ST_DASH_CD_REDUCE = makeConstId({
    name = '突进冷却时间减少',
    isPct = true,
})

ST_ATK_SPLASH_DMG = makeConstId({
    name = '英雄普攻溅射伤害',
    isPct = true,
})

ST_ATK_SPLASH_AOE = makeConstId({
    name = '英雄普攻溅射范围',
})

--------------------------------------------------------------------------------------
-- 每秒属性
ST_SEC_STR = makeConstId({
    name = '每秒力量',
    showFloat = true,
})

ST_SEC_AGI = makeConstId({
    name = '每秒敏捷',
    showFloat = true,
})

ST_SEC_INT = makeConstId({
    name = '每秒智力',
    showFloat = true,
})

ST_SEC_MAIN = makeConstId({
    name = '每秒主属性',
    showFloat = true,
})

ST_SEC_ALL = makeConstId({
    name = '每秒全属性',
    showFloat = true,
})

ST_SEC_ATK = makeConstId({
    name = '每秒攻击',
    showFloat = true,
})

ST_SEC_BASE_ATK = makeConstId({
    name = '每秒白字攻击',
})

ST_SEC_HP_MAX = makeConstId({
    name = '每秒生命',
    showFloat = true,
})

PST_SEC_GOLD = makeConstId({
    name = '每秒金币',
    showFloat = true,
    isPlayerStats = true,
})

PST_SEC_GOLD_PCT = makeConstId({
    name = '每秒金币增幅',
    isPct = true,
    isPlayerStats = true,
})

ST_SEC_EXP = makeConstId({
    name = '每秒经验',
    showFloat = true,
})
ST_SEC_LUMBER = makeConstId({
    name = '每秒木材',
    showFloat = true,
})
ST_SEC_KILL = makeConstId({
    name = '每秒杀敌数',
    showFloat = true,
})

--------------------------------------------------------------------------------------
-- 成长属性
ST_GROW_STR = makeConstId({
    name = '升级力量',
    showFloat = true,
})

ST_GROW_AGI = makeConstId({
    name = '升级敏捷',
    showFloat = true,
})

ST_GROW_INT = makeConstId({
    name = '升级智力',
    showFloat = true,
})

ST_GROW_MAIN = makeConstId({
    name = '升级主属性',
    showFloat = true,
})

ST_GROW_ALL = makeConstId({
    name = '升级全属性',
    showFloat = true,
})

ST_GROW_ATK = makeConstId({
    name = '升级攻击',
    showFloat = true,
})

ST_GROW_HP_MAX = makeConstId({
    name = '升级生命',
    showFloat = true,
})

--------------------------------------------------------------------------------------
-- 成长属性%
ST_GROW_STR_PCT = makeConstId({
    name = '升级力量',
    isPct = true,
})

ST_GROW_AGI_PCT = makeConstId({
    name = '升级敏捷',
    isPct = true,
})

ST_GROW_INT_PCT = makeConstId({
    name = '升级智力',
    isPct = true,
})

ST_GROW_MAIN_PCT = makeConstId({
    name = '升级主属性',
    isPct = true,
})

ST_GROW_ALL_PCT = makeConstId({
    name = '升级全属性',
    isPct = true,
})

ST_GROW_ATK_PCT = makeConstId({
    name = '升级攻击',
    isPct = true,
})

ST_GROW_HP_MAX_PCT = makeConstId({
    name = '升级生命',
    isPct = true,
})

ST_KNOCK_BACK_RESIST = makeConstId({
    name = '击退抗性',
    isPct = true,
})

--------------------------------------------------------------------------------------
-- 杀敌属性
ST_KILL_STR = makeConstId({
    name = '杀敌力量',
    showFloat = true,
})

ST_KILL_AGI = makeConstId({
    name = '杀敌敏捷',
    showFloat = true,
})

ST_KILL_INT = makeConstId({
    name = '杀敌智力',
    showFloat = true,
})

ST_KILL_MAIN = makeConstId({
    name = '杀敌主属性',
    showFloat = true,
})

ST_KILL_ALL = makeConstId({
    name = '杀敌全属性',
    showFloat = true,
})

ST_KILL_ATK = makeConstId({
    name = '杀敌攻击',
    showFloat = true,
})

ST_KILL_HP_MAX = makeConstId({
    name = '杀敌生命',
    showFloat = true,
})

ST_KILL_GOLD = makeConstId({
    name = '杀敌金币',
    showFloat = true,
})

ST_KILL_EXP = makeConstId({
    name = '杀敌经验',
    showFloat = true,
})

ST_KILL_PHY_DEF = makeConstId({
    name = '杀敌护甲',
})

--------------------------------------------------------------------------------------
-- 杀敌属性%
ST_KILL_STR_PCT = makeConstId({
    name = '杀敌力量增幅',
    isPct = true,
})

ST_KILL_AGI_PCT = makeConstId({
    name = '杀敌敏捷增幅',
    isPct = true,
})

ST_KILL_INT_PCT = makeConstId({
    name = '杀敌智力增幅',
    isPct = true,
})

ST_KILL_MAIN_PCT = makeConstId({
    name = '杀敌主属性增幅',
    isPct = true,
})

ST_KILL_ALL_PCT = makeConstId({
    name = '杀敌全属性增幅',
    isPct = true,
})

ST_KILL_ATK_PCT = makeConstId({
    name = '杀敌攻击增幅',
    isPct = true,
})

ST_KILL_HP_MAX_PCT = makeConstId({
    name = '杀敌生命',
    isPct = true,
})

ST_KILL_GOLD_PCT = makeConstId({
    name = '杀敌金币',
    isPct = true,
})

ST_KILL_EXP_PCT = makeConstId({
    name = '杀敌经验',
    isPct = true,
})

-- 玩家属性
RES_GOLD = makeConstId({
    name = '金币',
    color = [[|cffffff00]],
    isPlayerStats = true,
})
RES_LUMBER = makeConstId({
    name = '木材',
    color = [[|cff49cf4f]],
    isPlayerStats = true,
})
RES_KILL = makeConstId({
    name = '杀敌数',
    color = [[|cffff8080]],
    isPlayerStats = true,
})
RES_ROLL = makeConstId({
    name = '重铸点数',
    isPlayerStats = true,
})

PST_ENEMY_MAX = makeConstId({
    name = '敌人上限',
})

PST_EXTRA_GOLD_ENEMY_NUM = makeConstId({
    name = '额外金币挑战怪',
    isPlayerStats = true,
})
PST_EXTRA_LUMBER_ENEMY_NUM = makeConstId({
    name = '额外木材挑战怪',
    isPlayerStats = true,
})

PST_EXTRA_ENEMY_NUM_PCT = makeConstId({
    name = '额外敌人数量',
    isPct = true,
    isPlayerStats = true,
})

PST_FLOAT_ENEMY_NUM = makeConstId({
    name = '额外敌人数量（小数）',
    isPlayerStats = true,
})

PST_EXTRA_ENEMY_LUMBER = makeConstId({
    name = '额外敌人木材',
    isPlayerStats = true,
})

PST_EXTRA_ENEMY_GOLD = makeConstId({
    name = '额外敌人金钱',
    isPlayerStats = true,
})

PST_EXTRA_ENEMY_GOLD_PCT = makeConstId({
    name = '额外敌人金钱',
    isPct = true,
    isPlayerStats = true,
})

PST_EXTRA_ENEMY_EXP_PCT = makeConstId({
    name = '额外敌人经验',
    isPct = true,
    isPlayerStats = true,
})


PST_EXTRA_ENEMY_LUMBER_PCT = makeConstId({
    name = '杀敌木材',
    isPct = true,
    isPlayerStats = true,
})

PST_TOWER_REWARD_STATS_PCT = makeConstId({
    name = '魔塔属性加成',
    isPct = true,
    isPlayerStats = true,
})

PST_TOWER_REWARD_RESOURCE_PCT = makeConstId({
    name = '魔塔资源加成',
    isPct = true,
    isPlayerStats = true,
})

--------------------------------------------------------------------------------------
-- 伤害类型
DMG_TYPE_PHYSICAL = makeConstId({
    name = '物理',
})
DMG_TYPE_MAGICAL = makeConstId({
    name = '魔法',
})
DMG_TYPE_PURE = makeConstId({
    name = '真实',
})
DMG_TYPE_FIX = makeConstId({
    name = '直接',
})
DMG_TYPE_AUTO = makeConstId({
    name = '自适应',
})
DMG_TYPE_MIX = makeConstId({
    name = '混合',
})

-- buff名称
mt.BUFF_STUN = '眩晕'
mt.BUFF_FREEZE = '冰冻'
mt.BUFF_SILENCE = '沉默'
mt.BUFF_ROOT = '缠绕'
mt.BUFF_LOCK = '禁锢'
mt.BUFF_IMMUNE = '免疫'
mt.BUFF_SUMMON = '召唤物'
mt.BUFF_CONTROL_RESIST = '控制免疫'
mt.BUFF_CAMP_REGEN = '集营恢复'
mt.BUFF_PAUSE = '暂停'
mt.BUFF_ENERGY_LOCK = '缚能'
mt.BUFF_FULL_ENERGY = '持续满能'

-- 单位事件

UNIT_EVENT_ON_ATK = makeConstId({
    name = '攻击事件',
})
UNIT_EVENT_ON_ATKED = makeConstId({
    name = '被攻击事件',
})
UNIT_EVENT_BEFORE_DIE = makeConstId({
    name = '预亡语事件',
})
UNIT_EVENT_ON_DIE = makeConstId({
    name = '亡语事件',
})
UNIT_EVENT_ON_REVIVE = makeConstId({
    name = '复活事件',
})
UNIT_EVENT_ON_EVERY_SECOND = makeConstId({
    name = '每秒事件',
})
UNIT_EVENT_ON_REDUCE_DMG = makeConstId({
    name = '减伤事件',
})
UNIT_EVENT_ON_DEAL_DMG = makeConstId({
    name = '造成伤害事件',
})
UNIT_EVENT_ON_SLOW_ENEMY = makeConstId({
    name = '减速事件',
})
UNIT_EVENT_ON_FREEZE = makeConstId({
    name = '造成冻结事件',
})
UNIT_EVENT_ON_TAKE_DMG = makeConstId({
    name = '接受伤害事件',
})
UNIT_EVENT_BEFORE_LAUNCH_ATK = makeConstId({
    name = '攻击前触发事件（计算攻击伤害前）',
})
UNIT_EVENT_ON_LAUNCH_ATK = makeConstId({
    name = '攻击触发事件（计算攻击伤害后）',
})
UNIT_EVENT_ON_SPLIT_ATK = makeConstId({
    name = '分裂箭击中',
})
UNIT_EVENT_ON_CAST_SPELL = makeConstId({
    name = '施法事件',
})
UNIT_EVENT_ON_DASH_START = makeConstId({
    name = '冲刺开始事件',
})
UNIT_EVENT_ON_DASH_END = makeConstId({
    name = '冲刺结束事件',
})
UNIT_EVENT_ON_APPLY_STUN = makeConstId({
    name = '眩晕事件',
})
UNIT_EVENT_ON_ROUND_START = makeConstId({
    name = '回合开始事件',
})
UNIT_EVENT_ON_ROUND_END = makeConstId({
    name = '回合结束事件',
})
UNIT_EVENT_ON_KILL = makeConstId({
    name = '杀敌事件',
})
UNIT_EVENT_DMG_CALC = makeConstId({
    name = '伤害计算事件',
})
UNIT_EVENT_DMG_CALC_AFTER_CRIT = makeConstId({
    name = '伤害计算事件（暴击后）',
})
UNIT_EVENT_DMG_VERY_BEGINNING = makeConstId({
    name = '伤害事件（最早阶段）',
})
UNIT_EVENT_ON_EVADE = makeConstId({
    name = '闪避事件',
})
UNIT_EVENT_ON_APPLY_BUFF = makeConstId({
    name = '施加buff事件',
})
UNIT_EVENT_ON_RECEIVE_BUFF = makeConstId({
    name = '接受buff事件',
})
UNIT_EVENT_ON_SUMMON = makeConstId({
    name = '生成召唤单位事件',
})
UNIT_EVENT_ON_PICK = makeConstId({
    name = '选择单位事件',
})
UNIT_EVENT_ON_LV_UP = makeConstId({
    name = '升级事件',
})

UNIT_EVENT_REWARD_TOWER = makeConstId({
    name = '爬塔奖励事件',
})

UNIT_EVENT_ON_GET_GOLD = makeConstId({
    name = '获得金币事件',
})

UNIT_EVENT_ON_GET_LUMBER = makeConstId({
    name = '获得木材事件',
})

UNIT_EVENT_ON_GET_KILL = makeConstId({
    name = '获得杀敌事件',
})

UNIT_EVENT_ON_BUY_KILL_REWARD = makeConstId({
    name = '购买杀敌兑换事件',
})

UNIT_EVENT_ON_REGEN = makeConstId({
    name = '回血事件',
})

UNIT_EVENT_ON_ATK_REGEN = makeConstId({
    name = '攻击回血事件',
})

UNIT_EVENT_ON_LEARN_SKILL = makeConstId({
    name = '英雄学习技能事件',
})

--------------------------------------------------------------------------------------
PLAYER_EVENT_ON_GET_GOLD = makeConstId({
    name = '玩家获取金币事件',
})

PLAYER_EVENT_HERO_BORN = makeConstId({
    name = '玩家英雄出生事件',
})

PLAYER_EVENT_ON_KILL = makeConstId({
    name = '玩家击杀单位事件',
})

PLAYER_EVENT_ON_ENDLESS_START = makeConstId({
    name = '无尽开始事件',
})

UNIT_EVENT_ON_HERO_HP_REDUCE = makeConstId({
    name = '生命值减少事件',
})

UNIT_EVENT_ON_BREAK_SHIELD = makeConstId({
    name = '破盾事件',
})
UNIT_EVENT_ON_SHIELD_BROKEN = makeConstId({
    name = '被破盾事件',
})

UNIT_EVENT_ON_TAKE_DMG_BEFORE_CALC = makeConstId({
    name = '接受伤害事件（伤害计算时点前）',
})

UNIT_EVENT_ON_GET_EXP = makeConstId({
    name = '经验获取事件',
})

UNIT_EVENT_BEFORE_DEAL_DAMAGE = makeConstId({
    name = '造成伤害事件（最终计算时点前）',
})


--------------------------------------------------------------------------------------
-- 流派相关
UNIT_EVENT_ON_TRIGGER_BLESS = makeConstId({
    name = '触发赐福事件',
})


mt.RNG_STATS = {mt.ST_STR, mt.ST_AGI, mt.ST_INT}

mt.THREE_STATS = {mt.ST_STR, mt.ST_AGI, mt.ST_INT}

mt.EQUIP_RARE_COLOR = {
    [1] = [[|cffc5c5c5]],
    [2] = [[|cff85ec80]],
    [3] = [[|cff57c2ff]],
    [4] = [[|cffba76ff]],
    [5] = [[|cfff7ea99]],
    [6] = [[|cfffaee4e]],
    [7] = [[|cfff7a712]],
    [8] = [[|cffe73131]],
    [9] = [[|cfff52b78]],
    [10] = [[|cfff8e09a]],
}

mt.MAX_EQUIP_LV = 10
mt.MAX_BODY_REFORM_LV = 8

-- 投掷物种类
mt.BULLET_FOLLOW_TARGET = makeConstId()
mt.BULLET_SHOCK_WAVE = makeConstId()
mt.BULLET_MOON_ARROW = makeConstId()
mt.BULLET_BACK_TURN = makeConstId()
mt.BULLET_SPIN = makeConstId()
mt.BULLET_THROW = makeConstId()
mt.BULLET_CUSTOM = makeConstId()

-- class tag
mt.TAG_SKILL_SHOP = 'SKILL_SHOP'

-- 伤害字体
mt.FLOW_TEXT = {}

for i = 1, 7 do
    mt.FLOW_TEXT[i] = {}
    for j = 0, 10 do
        mt.FLOW_TEXT[i][j] = string.format('war3mapimported\\z%d (%d).mdx', i, j)
    end
end

-- 蓝色
for i = 0, 9 do
    mt.FLOW_TEXT[3][i] = string.format('overtext_blue_%d.mdx', i)
end
mt.FLOW_TEXT[3][10] = [[overtext_textures_blue_bj.mdx]]
mt.FLOW_TEXT[3][11] = [[overtext_textures_blue_1.mdx]]
mt.FLOW_TEXT[3][12] = [[overtext_textures_blue_2.mdx]]
mt.FLOW_TEXT[3][13] = [[overtext_textures_blue_3.mdx]]

-- 黄色
for i = 0, 9 do
    mt.FLOW_TEXT[1][i] = string.format('overtext_yellow_%d.mdx', i)
end
mt.FLOW_TEXT[1][10] = [[overtext_textures_yellow_bj.mdx]]
mt.FLOW_TEXT[1][11] = [[overtext_textures_yellow_1.mdx]]
mt.FLOW_TEXT[1][12] = [[overtext_textures_yellow_2.mdx]]
mt.FLOW_TEXT[1][13] = [[overtext_textures_yellow_3.mdx]]

-- 粉色
for i = 0, 9 do
    mt.FLOW_TEXT[7][i] = string.format('overtext_pink_%d.mdx', i)
end
mt.FLOW_TEXT[7][10] = [[overtext_textures_pink_bj.mdx]]
mt.FLOW_TEXT[7][11] = [[overtext_textures_pink_1.mdx]]
mt.FLOW_TEXT[7][12] = [[overtext_textures_pink_2.mdx]]
mt.FLOW_TEXT[7][13] = [[overtext_textures_pink_3.mdx]]

-- 绿色
for i = 0, 9 do
    mt.FLOW_TEXT[2][i] = string.format('overtext_green_%d.mdx', i)
end
mt.FLOW_TEXT[2][10] = [[overtext_textures_green_plus.mdx]]

-- 橙色
for i = 0, 9 do
    mt.FLOW_TEXT[5][i] = string.format('overtext_orange_%d.mdx', i)
end
mt.FLOW_TEXT[5][10] = [[overtext_textures_orange_bj.mdx]]
mt.FLOW_TEXT[5][11] = [[overtext_textures_orange_1.mdx]]
mt.FLOW_TEXT[5][12] = [[overtext_textures_orange_2.mdx]]
mt.FLOW_TEXT[5][13] = [[overtext_textures_orange_3.mdx]]

-- 红色
for i = 0, 9 do
    mt.FLOW_TEXT[4][i] = string.format('overtext_red_%d.mdx', i)
end

-- atk type
mt.NOT_ATTACK = false
mt.IS_ATTACK = true

mt.COLOR_CODE = {
    R = '|r',
    STR = '|cffff8080',
    AGI = '|cff99cc00',
    INT = '|cff33cccc',
    PAS = '|cff33cccc',
    ACT = '|cff98ee51',
    ATK = '|cffffb66c',
    MAGIC = '|cff6ba6ff',
    DEBUFF = '|cffffcc00',
    NUM = '|cffffcc00',
    ALL = '|cffffffcc',

    DANGER = '|cffff8080',

    STR_RATE = '|r[|cffff8080力量|r]×',
    HP_RATE = '|r[|cffff80d9最大生命|r]×',
    AGI_RATE = '|r[|cff99cc00敏捷|r]×',
    INT_RATE = '|r[|cff33cccc智力|r]×',
    ATK_RATE = '|r[|cffffb66c攻击力|r]×',
    MAIN_RATE = '|r[|cffffcc99主|r|cffffe54d属|r|cffffff00性|r]×',
    AST_RATE = '|r[|cffffffcc全|r|cffcce6e5属|r|cff99ccff性|r]×',
    CAST_HEAL = '|r[|cffcb9ef0充能回血|r]×',

    PHY = '|cffffd884',
    MAG = '|cffa9c7ff',
    MIX = '|cfff59edf',

    HINT = '|cffffffcc',
}

mt.COLOR_GRAY = '|cffc0c0c0'
mt.COLOR_LIME = '|cff49d648'
mt.COLOR_TEAL = '|cff00ffd5'
mt.COLOR_ORANGE = '|cffffcc00'
mt.COLOR_YELLOW = '|cffffff00'
mt.COLOR_WOOD = '|cff16a32e'
mt.COLOR_COIN = '|cffcc99ff'
mt.COLOR_SEA = '|cff99ccff'

convertColor = function(name)
    return cst.COLOR_CODE[name]
end

mt.PICK_BOX_HOT_KEY = {
    NULL = 0,
}

mt.PLAYER_ENEMY = nil
mt.ALL_PLAYERS = 'ALL PLAYER'

mt.PLAYER_9 = nil
mt.COMPUTER_ALLY_PLAYER = nil
mt.NEUTRAL_AGGRESSIVE = nil -- 在player初始化时加载
mt.NEUTRAL_PASSIVE = nil -- 在player初始化时加载

-- test
local point = require 'ac.point'
mt.TEST_LOC = point:new(-7500, 8000)
mt.TEST_LOC2 = point:new(9000, -9000)


mt.BTN_PREFIX_ACTIVE = [[ReplaceableTextures\CommandButtons\BTN]]
mt.BTN_PREFIX_PASSIVE = [[ReplaceableTextures\CommandButtonsDisabled\DISBTN]]
mt.BTN_PREFIX_DARK = [[ReplaceableTextures\CommandButtonsDisabled\DISBTN]]

mt.ARCH_TYPE_BOOL = 'bool'
mt.ARCH_TYPE_NUM = 'num'

mt.ROMAN = {
    [1] = 'I',
    [2] = 'II',
    [3] = 'III',
    [4] = 'IV',
    [5] = 'V',
    [6] = 'VI',
    [7] = 'VII',
    [8] = 'VIII',
}

mt.commandSkillBtnLevel = {
    [1] = 'ReplaceableTextures\\CommandButtons\\BTND%s.blp',
    [2] = 'ReplaceableTextures\\CommandButtons\\BTNC%s.blp',
    [3] = 'ReplaceableTextures\\CommandButtons\\BTNB%s.blp',
    [4] = 'ReplaceableTextures\\CommandButtons\\BTNA%s.blp',
    [5] = 'ReplaceableTextures\\CommandButtons\\BTNS%s.blp',
    [6] = 'ReplaceableTextures\\CommandButtons\\BTNSS%s.blp',
}

TEMPLATE_BTN_PATH = [[ReplaceableTextures\CommandButtons\BTNShoveler.blp]]

ART_NOT_ENOUGH_GOLD = [[not_enough_gold.tga]]
ART_NOT_ENOUGH_LUMBER = [[not_enough_crystal.tga]]
ART_NOT_ENOUGH_KILL = [[not_enough_kill.tga]]

SKILL_TARGET_PASSIVE = 0
SKILL_TARGET_UNIT = 1
SKILL_TARGET_POINT = 3
SKILL_TARGET_NONE = 4

SKILL_TYPE_NO_FLAG = 0
SKILL_TYPE_HERO_TALENT = 1
SKILL_TYPE_BLESS = 2
SKILL_TYPE_CUSTOM = 3
SKILL_TYPE_ENEMY = 4
SKILL_TYPE_CHAPTER_AREA = 5
SKILL_TYPE_RELIC = 6

GAME_STATE_PREGAME = 0
GAME_STATE_NORMAL = 1
GAME_STATE_REST_AFTER_FINAL_BOSS = 2
GAME_STATE_ENDLESS = 3
GAME_STATE_FINISH = 4
GAME_STATE_HUNT_MODE_END = 5
GAME_STATE_POST_ENDLESS = 6

ENEMY_TYPE_NORMAL = 1
ENEMY_TYPE_ELITE = 2
ENEMY_TYPE_BOSS = 3


WAVE_MODE_NORMAL = 1
WAVE_MODE_ENDLESS = 2

SOUND_RADIUS_NORMAL = 1500
SOUND_RADIUS_LARGE = 10000


PLATFORM_SIGN_TOTAL = 0
PLATFORM_SIGN_TOTAL_CONTINUOUS_HIGHEST = 1
PLATFORM_SIGN_CURRENT_CONTINUOUS_HIGHEST = 2

PROGRESS_ART = {}
for i = 1, 100 do
    PROGRESS_ART[i] = str.format([[war3mapimported\lvse123_000%02d.blp]], 100 - i)
end
PROGRESS_ART[1] = [[war3mapimported\lvse123_00000.blp]]

CLIENT_ONLINE = 1
CLIENT_REPLY = 2
CLIENT_WATCHING = 3

ENDLESS_CHIEVEMENT_WAVE_REQUIRE = {
    [1] = {10, 20, 30, 40, 50, 60, 70, 80, 90, 100, 110, 120, 140, 160, 180, 200},
}

EQUIP_RES_ROLL_COST_BY_RARE = {
    [6] = 1,
    [7] = 1,
    [8] = 1,
    [9] = 1,
    [10] = 1,
}

--------------------------------------------------------------------------------------
MOVE_TYPE_FIXED = 0x01
MOVE_TYPE_NORMAL = 0x02
MOVE_TYPE_WIND_WALK = 0x10
MOVE_TYPE_FLY = 0x04

STORE_ITEM_TYPE_NB = 1
STORE_ITEM_TYPE_UR = 2
STORE_ITEM_TYPE_SSR = 3
STORE_ITEM_TYPE_POINT = 4

QQ_LINK = [[https://qm.qq.com/q/8WBfhIyc9y]]

WAVE_STATE_NORMAL = 2
WAVE_STATE_FINAL_BOSS = 2
WAVE_STATE_ENDLESS = 3

return mt
