local mt = {}

BLESS_DOUBLE_CRIT_BASE_CHANCE = 0.04
BLESS_TRIPLE_CRIT_BASE_CHANCE = 0.01

BLESS_CLASS_ARROW = fc.makeConstId({
    name = '|cff6AFB92箭术|r',
    actuallyName = 'jianshu',
    -- appearChance = ST_ARROW_BLESS_CHANCE,
    comboType = COMBO_TYPE_MASTERY,
    dmgType = ST_ARROW_DMG,
    tempArt = [[huoyanzhijian]],
    poolName = 'bless_pool_arrow',
})

reg:addToPool('bless_class', BLESS_CLASS_ARROW)

BLESS_CLASS_SUMMON = fc.makeConstId({
    name = '|cff6ad9fb召唤|r',
    actuallyName = 'jianshu',
    -- appearChance = ST_ARROW_BLESS_CHANCE,
    comboType = COMBO_TYPE_MASTERY,
    dmgType = ST_SUMMON_DMG,
    tempArt = [[xunmengzhiling]],
    poolName = 'bless_pool_summon',
})

reg:addToPool('bless_class', BLESS_CLASS_SUMMON)

BLESS_CLASS_ARCANE = fc.makeConstId({
    name = '|cffd96afb秘法|r',
    actuallyName = 'jianshu',
    -- appearChance = ST_ARROW_BLESS_CHANCE,
    comboType = COMBO_TYPE_MASTERY,
    dmgType = ST_ARCANE_DMG,
    tempArt = [[jihancuilian]],
    poolName = 'bless_pool_arcane',
})

reg:addToPool('bless_class', BLESS_CLASS_ARCANE)

BLESS_CLASS_MISSILE = fc.makeConstId({
    name = '|cfffbcd6a飞弹|r',
    actuallyName = 'jianshu',
    -- appearChance = ST_ARROW_BLESS_CHANCE,
    comboType = COMBO_TYPE_MASTERY,
    dmgType = ST_MISSILE_DMG,
    tempArt = [[anyingfeidan]],
    poolName = 'bless_pool_missile',
})

reg:addToPool('bless_class', BLESS_CLASS_MISSILE)

BLESS_CLASS_SUPPORT = fc.makeConstId({
    name = '|cffFFFFF4辅助|r',
    actuallyName = 'fuzhu',
    tempArt = [[minjiezhufu]],
    poolName = 'bless_pool_support',
})

reg:addToPool('bless_class', BLESS_CLASS_SUPPORT)

BLESS_CLASS_ATTACK = fc.makeConstId({
    name = '|cfff8816c攻击|r',
    actuallyName = 'fuzhu',
    tempArt = [[jisuwuqi]],
    poolName = 'bless_pool_attack',
})

reg:addToPool('bless_class', BLESS_CLASS_ATTACK)

-- BLESS_CLASS_UNIQUE = fc.makeConstId({
--     name = '|cfffddf66独特|r',
--     actuallyName = 'dute',
-- })

BLESS_CLASS_OTHER = fc.makeConstId({
    name = '|cfffddf66玩家的非本源羁绊|r', -- 需要在别处后续处理
})
