local skillName = '圣骑士护甲光环'

local mt = {
    -- 名称
    name = skillName,

    -- 技能图标
    art = [[ReplaceableTextures\CommandButtons\BTNDevourMagic.blp]],

    -- 技能说明
    title = [[圣骑士护甲光环]],
    tip = [[增加周围1000范围友军30%的护甲]],

    -- 技能类型
    skillType = SKILL_TYPE_ENEMY,

    -- 施放类型
    targetType = SKILL_TARGET_PASSIVE,
    showHotKey = false,
}
mt.__index = mt
--------------------------------------------------------------------------------------
function mt:onSwitch(isAdd)
    local u = self.unit
    local p = u.player
    if isAdd then
        u:addAura({
            name = skillName,
            lv = 1,
            aoe = 1000,
            toAlly = true,
            toEnemy = false,
            effKeys = nil,
            filter = nil,
        })
    else
        u:removeAura(skillName)
    end
end
--------------------------------------------------------------------------------------
reg:initSkill(mt)
--------------------------------------------------------------------------------------
-- buff
--------------------------------------------------------------------------------------
local buffName = skillName

local buff = {
    name = buffName,

    effect = {},

    multiple = false,
    differentApplierStackable = false,
}

local mt = buff
mt.__index = mt
--------------------------------------------------------------------------------------
function mt:onSwitch(isAdd)
    local u = self.owner
    local rate = 0.3
    if isAdd then
    else
        rate = rate * -1
    end
    u:modStats(ST_PHY_DEF_PCT, rate)
end
--------------------------------------------------------------------------------------
reg:initBuff(buff)
