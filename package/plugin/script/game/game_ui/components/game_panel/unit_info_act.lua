--------------------------------------------------------------------------------------
local message = require 'jass.message'
local ui_damage_panel = japi.SimpleFrameFindByName("SimpleInfoPanelIconDamage", 0) -- 没有攻击力
--------------------------------------------------------------------------------------
local mt = class.unit_info
mt.expDelayVal = 0
--------------------------------------------------------------------------------------
local getColoredBonus = function(val)
    local bonusString
    if val == 0 then
        bonusString = ''
    elseif val > 0 then
        bonusString = str.format('|cff51ff00+%s|r', ConvertBigNumberToText(val))
    else
        bonusString = str.format('|cffff0000%s|r', ConvertBigNumberToText(val))
    end
    return bonusString
end
--------------------------------------------------------------------------------------
function mt:updateBoardFast()

    local u = mt.expHero
    if not u then
        return
    end

    if u.type == 'hero' then
        local nowExp = u.exp
        local nowExpBase = u.expChart[u.lv]
        local nextExp = u.expChart[u.lv + 1]

        local showNow = nowExp - nowExpBase
        local showNext = nextExp - nowExpBase
        if u.lv == u:getMaxLv() then
            -- showNow =nowExp
            showNext = u.expChart[u.lv]
            showNow = math.min(nowExp, showNext)
        end
        mt.expDelayVal = math.lerp(mt.expDelayVal, showNow / showNext, 0.3)
        -- msg.notice(cst.ALL_PLAYERS, 'expDelayVal = ' .. mt.expDelayVal)
        self.expBar:setVal(mt.expDelayVal, 1)

    end
end
--------------------------------------------------------------------------------------
function mt:updateBoard(u)

    self.unitName:set_text(str.format('%s', u:getName()))
    -- gdebug('unit info update: ' .. u:getName())

    -- atk
    local atkWhite = u:getStats(ST_BASE_ATK)
    local atkGreen = u:getStats(ST_ATK) - atkWhite

    -- self.atkTitle:set_text(str.format('|cffffcc00攻击: |r(+%.0f%%)', u:getStats(ST_ATK_PCT)))
    self.atkTitle:set_text(str.format('|cffffdd55攻击力：|r'))
    self.atkTip:set_text(string.format('%s %s', ConvertBigNumberToText(atkWhite), getColoredBonus(math.floor(atkGreen))))

    -- arm
    local arm = u:getStats(ST_PHY_DEF)
    local armWhite = u:getStats(ST_BASE_PHY_DEF)
    local armGreen = arm - armWhite

    -- self.defTitle:set_text(str.format('|cffffcc00护甲：|r(+%.0f%%)', u:getStats(ST_ATK_PCT)))
    self.defTitle:set_text(str.format('|cff99ccff护甲:|r'))
    self.defTip:set_text(string.format('%s %s', ConvertBigNumberToText(armWhite), getColoredBonus(math.floor(armGreen))))

    if u.type == 'hero' then
        -- heroStatsBoard
        local statsWhite = math.floor(u:getStats(ST_BASE_STR))
        local statsGreen = math.floor(u:getStats(ST_STR) - statsWhite)
        self.strTip:set_text(string.format('%s %s', ConvertBigNumberToText(statsWhite), getColoredBonus(statsGreen)))

        local statsWhite = math.floor(u:getStats(ST_BASE_AGI))
        local statsGreen = math.floor(u:getStats(ST_AGI) - statsWhite)
        self.agiTip:set_text(string.format('%s %s', ConvertBigNumberToText(statsWhite), getColoredBonus(statsGreen)))

        local statsWhite = math.floor(u:getStats(ST_BASE_INT))
        local statsGreen = math.floor(u:getStats(ST_INT) - statsWhite)
        self.intTip:set_text(string.format('%s %s', ConvertBigNumberToText(statsWhite), getColoredBonus(statsGreen)))

        self.strTitle:set_text(str.format('|cffff8080力量：|r'))
        self.agiTitle:set_text(str.format('|cff99cc00敏捷：|r'))
        self.intTitle:set_text(str.format('|cff33cccc智力：|r'))

        -- self.heroIcon:set_normal_image(u.heroIconTexture)
        self.heroIcon:set_normal_image([[IcoStr.tga]])

        local nowExp = u.exp
        local nowExpBase = u.expChart[u.lv]
        local nextExp = u.expChart[u.lv + 1]

        local showNow = nowExp - nowExpBase
        local showNext = nextExp - nowExpBase
        self.expTip:set_text(str.format('等级%d  %.0f/%.0f', u.lv, showNow, showNext))
        -- self.expTip:set_text(str.format('等级%d', u.lv))
        -- self.expBar:setVal(showNow, showNext)

    end

    -- hp
    local hpText = GUI.HpInfo.hpText
    local hp = u:getStats(ST_HP)
    local hpMax = u:getStats(ST_HP_MAX)
    local hpTip = str.format('|cff66ff00%s / %s|r', ConvertBigNumberToText(hp), ConvertBigNumberToText(hpMax))
    hpText:set_text(hpTip)
    if u.bHideHpText then
        hpText:set_text('')
    end

    -- mp
    local mpText = GUI.MpInfo.mpText
    local mp = u:getStats(ST_MP)
    local mpMax = u:getStats(ST_MP_MAX)
    local mpTip = str.format('|cff55ddff%s / %s|r', ConvertBigNumberToText(mp), ConvertBigNumberToText(mpMax))
    mpText:set_text(mpTip)
    if u.bHideHpText or mpMax <= 0 then
        mpText:set_text('')
    end

end
--------------------------------------------------------------------------------------
function mt:update()

    self = GUI.UnitInfo

    -- local list = message.get_select_list()
    -- if list and #list > 1 then
    --     self:hide()
    --     return
    -- end

    local uj = japi.GetRealSelectUnit()
    if uj == 0 then
        self:hide()
        return
    end

    -- print('当前玩家选择了' .. GetUnitName(uj))
    local u = as.unit:uj2t(uj)
    self:updateBoard(u)
    mt.expHero = u

    if u.type == 'hero' then
        self.heroInfo:hide()
        GUI.EnemySkills:hide()
    else
        self.heroInfo:hide()
        GUI.EnemySkills:update(u)
        GUI.EnemySkills:show()
    end

    self:show(u)
    -- if japi.FrameIsShow(ui_damage_panel) then
    --     self:show(u)
    -- else
    --     self:hide()
    -- end
end
--------------------------------------------------------------------------------------
local atkList = {}
table.insert(atkList, ST_ATK)
table.insert(atkList, ST_ATK_SPEED)
table.insert(atkList, ST_ACC)
table.insert(atkList, ST_RANGE)
table.insert(atkList, ST_MP_REGEN)
table.insert(atkList, ST_PHY_RATE)
table.insert(atkList, ST_MAG_RATE)
table.insert(atkList, ST_PHY_CRIT_CHANCE)
table.insert(atkList, ST_PHY_CRIT_RATE)
table.insert(atkList, ST_MAG_CRIT_CHANCE)
table.insert(atkList, ST_MAG_CRIT_RATE)
table.insert(atkList, ST_DMG_RATE)
--------------------------------------------------------------------------------------
local defList = {}
table.insert(defList, ST_MOVE_SPEED)
table.insert(defList, ST_PHY_DEF)
table.insert(defList, ST_MAG_DEF)
table.insert(defList, ST_HP_REGEN)
table.insert(defList, ST_BLOCK)
table.insert(defList, ST_EVADE)
table.insert(defList, ST_CRIT_EVADE)
table.insert(defList, ST_CRIT_RESIST)
table.insert(defList, ST_KNOCK_BACK_RESIST)
table.insert(defList, ST_DEF_RATE)
table.insert(defList, ST_FINAL_REDUCE_DMG_PCT)
--------------------------------------------------------------------------------------
function mt:convertStatsListToWord(unit, presnetList)
    local c = 0

    local output = ''

    for i, stName in ipairs(presnetList) do
        if i > 1 then
            output = str.format('%s\n', output)
        end
        local color = '|cffffdc50'
        if c % 2 == 1 then
            color = '|cffdeff49'
        end

        if cst:getConstTag(stName, 'isPct') then
            output = output ..
                         str.format('%s%s:|r %.0f%%', color, cst:getConstName(stName), unit:getStats(stName) * 100)
        elseif cst:getConstTag(stName, 'x100') then
            output = output .. str.format('%s%s:|r %.0f', color, cst:getConstName(stName), unit:getStats(stName) * 100)
        else
            output = output .. str.format('%s%s:|r %.0f', color, cst:getConstName(stName), unit:getStats(stName))
        end

        if stName == ST_ATK_SPEED then
            if unit:getStats(stName) >= 10.01 then
                local phyConvert = (unit:getStats(ST_ATK_SPEED) - 10) / 10
                output = output .. str.format(' +> 攻击增伤%.0f%%', phyConvert * 100)
            end

        end

        if stName == ST_PHY_DEF then
            output = output .. str.format(' -> 减伤%.2f%%', ConvertPhyMagDefReduce(unit:getStats(stName)) * 100)
        elseif stName == ST_MAG_DEF then
            output = output .. str.format(' -> 魔法减伤%.2f%%', ConvertPhyMagDefReduce(unit:getStats(stName)) * 100)
        elseif stName == ST_PURE_DEF and localEnv then
            output = output .. str.format(' -> 真实减伤%.2f%%', ConvertPhyMagDefReduce(unit:getStats(stName)) * 100)
        elseif stName == ST_DEF_RATE and localEnv then
            output = output ..
                         str.format(' -> 额外减伤%.2f%%', ConvertDefRateReduce(unit:getStats(stName) * 100) * 100)
        end

        c = c + 1
    end

    return output
end
--------------------------------------------------------------------------------------
function mt:showAtkInfo()
    local unit = as.unit:uj2t(japi.GetRealSelectUnit())
    if not unit then
        return
    end

    local title = str.format('%s - 【|cfff78d9f进攻属性|r】', unit:getName())
    local tip = mt:convertStatsListToWord(unit, atkList)

    toolbox:tooltip(title, tip)
    toolbox:moveToDefault()
    toolbox:show()
end
--------------------------------------------------------------------------------------
function mt:showDefInfo()
    local unit = as.unit:uj2t(japi.GetRealSelectUnit())
    if not unit then
        return
    end

    local title = str.format('%s - 【|cff00ffea防御属性|r】', unit:getName())
    local tip = mt:convertStatsListToWord(unit, defList)

    toolbox:tooltip(title, tip)
    toolbox:moveToDefault()
    toolbox:show()
end
--------------------------------------------------------------------------------------
function mt:showHeroInfo()
    local unit = as.unit:uj2t(japi.GetRealSelectUnit())
    if not unit then
        return
    end

    if not unit.getMainStatsType then
        return
    end

    local prim = unit:getMainStatsType()
    local tip
    tip =
        [[|cffff9900力量：|r|n- 每点增加0.1%生命加成|n- 每点增加0.1%物理伤害|n|n|cff99cc00敏捷：|r|n- 每点增加0.1%攻击速度|n- 每点增加0.1%攻击伤害|n|n|cff00ccff智力：|r|n- 每点增加0.1%技能伤害|n- 每点增加0.1%魔法伤害]]

    local title = str.format('%s - 【|cffd55bb0英雄属性|r】', unit:getName())
    -- local tip = mt:convertStatsListToWord(unit, heroList)

    toolbox:tooltip(title, tip)
    toolbox:moveToDefault()
    toolbox:show()
end
--------------------------------------------------------------------------------------
