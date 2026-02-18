--------------------------------------------------------------------------------------
class.stats_detail = extends(class.panel) {

    new = function(parent)
        -- 底图是一张黑色的图片 这个可以写死
        local panel = class.panel.new(parent, '', 1, 1, 356, 540, true)
        -- 改变panel对象的类
        panel.__index = class.stats_detail
        panel:construct()
        panel:draw()
        panel:show()

        -- panel.scroll_button:set_width(32)
        -- panel.scroll_button:set_height(32)
        -- panel.scroll_button:set_control_size(16, 64)
        -- panel.scroll_button.h = 36
        panel.scroll_interval_y = 64
        -- panel:add_scroll_button()
        return panel
    end,

}
local mt = class.stats_detail
--------------------------------------------------------------------------------------
local presentBlock = {}
--------------------------------------------------------------------------------------
presentBlock[#presentBlock + 1] = {
    title = '进攻属性',
    listLeft = {ST_PHY_CRIT_CHANCE, ST_PHY_CRIT_RATE, ST_PHY_RATE, ST_ATK_NERF_PHY_DEF, ST_PHY_PENETRATE, ST_ACC,
                ST_DMG_RATE, ST_ATK_DMG, ST_FINAL_DMG_PCT},
    listRight = {ST_MAG_CRIT_CHANCE, ST_MAG_CRIT_RATE, ST_MAG_RATE, ST_ATK_NERF_MAG_DEF, ST_MAG_PENETRATE, ST_MP_REGEN,
                 ST_CHARGE_SPEED, ST_SKILL_DMG, ST_MULTI_ATK_CHANCE, ST_MULTI_ATK_COUNT},
}
--------------------------------------------------------------------------------------
presentBlock[#presentBlock + 1] = {
    title = '防御属性',
    listLeft = {ST_PHY_DEF, ST_MAG_DEF, ST_HP_REGEN, ST_ATK_LIFE_STEAL, ST_CAST_HEAL, ST_CRIT_EVADE, ST_DEF_RATE},
    listRight = {ST_HEAL_RATE, ST_HEALED_RATE, ST_EVADE, ST_BLOCK, ST_CRIT_RESIST, ST_ATK_LIFE_STEAL_PCT,
                 ST_FINAL_REDUCE_DMG_PCT},
}
--------------------------------------------------------------------------------------
presentBlock[#presentBlock + 1] = {
    title = '百分比属性',
    listLeft = {ST_STR_PCT, ST_AGI_PCT, ST_INT_PCT},
    listRight = {ST_ATK_PCT, ST_HP_MAX_PCT},
}
--------------------------------------------------------------------------------------
presentBlock[#presentBlock + 1] = {
    title = '成长属性',
    listLeft = {ST_GROW_STR, ST_GROW_AGI, ST_GROW_INT, ST_GROW_ATK, ST_KILL_STR, ST_KILL_AGI, ST_KILL_INT, ST_KILL_ATK,
                ST_KILL_STR_PCT, ST_KILL_AGI_PCT, ST_KILL_INT_PCT, ST_GROW_STATS_LV_UP_RATE},
    listRight = {ST_GROW_STR_PCT, ST_GROW_AGI_PCT, ST_GROW_INT_PCT, ST_GROW_ATK_PCT, ST_SEC_STR, ST_SEC_AGI, ST_SEC_INT,
                 ST_SEC_ATK},
    -- listRight = {ST_GROW_STR_PCT, ST_GROW_AGI_PCT, ST_GROW_INT_PCT, ST_KILL_STR_PCT, ST_KILL_AGI_PCT, ST_KILL_INT_PCT},
}
--------------------------------------------------------------------------------------
presentBlock[#presentBlock + 1] = {
    title = '其他属性',
    listLeft = {PST_GOLD_RATE, PST_LUMBER_RATE, PST_TOWER_REWARD_STATS_PCT},
    listRight = {PST_KILL_RATE, ST_EXP_RATE, PST_TOWER_REWARD_RESOURCE_PCT},
}
--------------------------------------------------------------------------------------
presentBlock[#presentBlock + 1] = {
    title = '特殊属性',
    listLeft = {ST_POSION_DMG_PCT, ST_FIRE_DMG_PCT, ST_THUNDER_DMG_PCT, ST_SHADOW_DMG_PCT, ST_ICE_DMG_PCT,
                ST_HOLY_DMG_PCT, ST_ICE_SLOW_PCT},
    listRight = {ST_ORB_DMG_PCT, ST_BOMB_DMG, ST_ARROW_DMG, ST_BLAST_DMG, ST_MISSILE_DMG, ST_BOUNCE_BLESS_DMG},
}
--------------------------------------------------------------------------------------
local updateStatsList = {}
--------------------------------------------------------------------------------------
function mt:draw()

end
--------------------------------------------------------------------------------------
function mt:construct()

    local blockX = 30
    local blockY = 30
    local y2 = 40

    for i, block in ipairs(presentBlock) do
        local title = class.text:builder{
            parent = self,
            x = 120,
            y = blockY,
            w = 100,
            h = 10,
            text = str.format('|cffedfd8f%s|r', block.title),
            align = 'top',
            font_size = 11,
        }

        for j, statsType in ipairs(block.listLeft) do
            local text = class.text:builder{
                parent = self,
                x = 30,
                y = blockY + y2 + 26 * (j - 1),
                w = 100,
                h = 10,
                text = cst:getConstName(statsType),
                align = 'topleft',
                font_size = 9,
            }

            local valText = class.text:builder{
                parent = self,
                x = 30 + 30,
                y = blockY + y2 + 26 * (j - 1),
                w = 100,
                h = 10,
                text = "0",
                align = 'topright',
                font_size = 9,
            }
            table.insert(updateStatsList, {
                statsType = statsType,
                valText = valText,
            })
        end

        for j, statsType in ipairs(block.listRight) do
            local text = class.text:builder{
                parent = self,
                x = 180,
                y = blockY + y2 + 26 * (j - 1),
                w = 100,
                h = 10,
                text = cst:getConstName(statsType),
                align = 'topleft',
                font_size = 9,
            }

            local valText = class.text:builder{
                parent = self,
                x = 220,
                y = blockY + y2 + 26 * (j - 1),
                w = 100,
                h = 10,
                text = "0",
                align = 'topright',
                font_size = 9,
            }
            table.insert(updateStatsList, {
                statsType = statsType,
                valText = valText,
            })
        end

        blockY = blockY + 70 + 25 * math.max(#block.listLeft, #block.listRight)
    end

    -- reg:addToPool('ui_render_list', self)
end
--------------------------------------------------------------------------------------
function mt:update()
    local player = fc.getLocalPlayer()
    local hero = player.hero
    if not hero then
        return
    end

    for i, pack in ipairs(updateStatsList) do
        local statsType = pack.statsType
        local valText = pack.valText
        local val = hero:getStats(statsType)

        local output
        if cst:getConstTag(statsType, 'isPct') then
            output = str.format(' %.0f%%', hero:getStats(statsType))
        else
            output = str.format('%.0f', hero:getStats(statsType))
        end

        valText:set_text(output)
    end

end
--------------------------------------------------------------------------------------
function mt:on_panel_scroll(is_up)
    -- SetCameraField(CAMERA_FIELD_ANGLE_OF_ATTACK, YDUserDataGet(player, GetLocalPlayer(), "镜头X角度", real), 0.00)
    -- SetCameraField(CAMERA_FIELD_TARGET_DISTANCE, YDUserDataGet(player, GetLocalPlayer(), "镜头距离", real),
    --     YDUserDataGet(player, GetLocalPlayer(), "镜头缩放平滑", real))
end

------------------------------------------------------------------------------------
-- GUI.StatsDetail = mt.create()
-- GUI.StatsDetail:show()
--------------------------------------------------------------------------------------
return mt
