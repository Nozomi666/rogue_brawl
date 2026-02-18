GUI = {}
screenRatio = 1

GUI.fadeAnimPanelList = {}

print('[Init] - GUI awake')

require('game.game_ui.ui_helper')
uiHelper.autoAdjustWindowSize()

require('game.game_ui.lib.progress_bar')
require('game.game_ui.lib.hp_bar')
require('game.game_ui.lib.hero_hp_bar')
require('game.game_ui.lib.boss_hp_bar')
require('game.game_ui.lib.final_hp_bar')
require('game.game_ui.lib.challenge_enemy_title')
require('game.game_ui.lib.eliteEnemy_hp_bar')
require('game.game_ui.lib.debuff_timer')
require('game.game_ui.lib.skill_tipbox')
require('game.game_ui.lib.flowtext_number')

local prefix = 'game.game_ui.components.arch_panel.'


local prefix = 'game.game_ui.components.game_panel.'
require(prefix .. 'origin_ui')
require(prefix .. 'player_chat')
require(prefix .. 'top_info')

require(prefix .. 'top_left_war3')

require(prefix .. 'pick_bless_btn')


require(prefix .. 'resource_gold')
require(prefix .. 'resource_crystal')
require(prefix .. 'resource_kill')
require(prefix .. 'resource_roll')
-- require(prefix .. 'fight_power')
-- require(prefix .. 'maid_btn')
require(prefix .. 'ground_item_info')
require(prefix .. 'skill_btn')
require(prefix .. 'enemy_skills')


require(prefix .. 'multiUsePanel')
require(prefix .. 'multiUseButton')
require(prefix .. 'multiUseRemoveButton')


require(prefix .. 'not_enough_resource')


require(prefix .. 'revive_time')
require(prefix .. 'unit_info')
require(prefix .. 'unit_info_act')
require(prefix .. 'hp_info')
require(prefix .. 'mp_info')

require('game.game_ui.components.game_panel.game_message')


local prefix = 'game.game_ui.components.'
local toolboxClass = require(prefix .. 'tool_box')
toolbox = toolboxClass.create()
extraToolbox = {}
for i = 1, 6 do
    extraToolbox[i] = toolboxClass.create()
end

topToolbox = toolboxClass.create()

require(prefix .. 'inventory_info_act')
require(prefix .. 'fps')
require(prefix .. 'stats_detail')
require(prefix .. 'stats_detail_panel')
require(prefix .. 'stats_detail_panel_btn')
-- require(prefix .. 'mini_map')
require(prefix .. 'platform_logo')

require('game.game_ui.components.game_panel.dragging_item')
require('game.game_ui.components.game_panel.custom_pickbox')


local prefix = 'game.game_ui.components.pick_panel.'
require(prefix .. 'pick_bless_panel')
require(prefix .. 'pick_bless_moving_icon')


local prefix = 'game.game_ui.func.'
require(prefix .. 'sequence_frame')

local prefix = 'game.game_ui.components.arch_panel.'

GUI.setSkillIconPos = function()
    --------------------------------------------------------------------------------------
    -- 技能栏
    local r = 0.031
    local r2 = 0.042
    local dx = 0.0364
    local dy = -0.0486

    for i = 0, 2 do
        for j = 0, 3 do
            local f = dz.DzFrameGetCommandBarButton(i, j)
            dz.DzFrameSetSize(f, r, r2)
            dz.DzFrameShow(f, true)
        end
    end

    dz.DzFrameSetPoint(dz.DzFrameGetCommandBarButton(0, 0), 0, dz.DzGetGameUI(), 4, 0.182, -0.1525)
    dz.DzFrameSetPoint(dz.DzFrameGetCommandBarButton(0, 1), 0, dz.DzFrameGetCommandBarButton(0, 0), 0, dx, 0.00)
    dz.DzFrameSetPoint(dz.DzFrameGetCommandBarButton(0, 2), 0, dz.DzFrameGetCommandBarButton(0, 1), 0, dx, 0.00)
    dz.DzFrameSetPoint(dz.DzFrameGetCommandBarButton(0, 3), 0, dz.DzFrameGetCommandBarButton(0, 2), 0, dx, 0.00)
    dz.DzFrameSetPoint(dz.DzFrameGetCommandBarButton(1, 0), 0, dz.DzFrameGetCommandBarButton(0, 0), 0, 0.00, dy)
    dz.DzFrameSetPoint(dz.DzFrameGetCommandBarButton(1, 1), 0, dz.DzFrameGetCommandBarButton(1, 0), 0, dx, 0.00)
    dz.DzFrameSetPoint(dz.DzFrameGetCommandBarButton(1, 2), 0, dz.DzFrameGetCommandBarButton(1, 1), 0, dx, 0.00)
    dz.DzFrameSetPoint(dz.DzFrameGetCommandBarButton(1, 3), 0, dz.DzFrameGetCommandBarButton(1, 2), 0, dx, 0.00)
    dz.DzFrameSetPoint(dz.DzFrameGetCommandBarButton(2, 0), 0, dz.DzFrameGetCommandBarButton(1, 0), 0, 0.00, dy)
    dz.DzFrameSetPoint(dz.DzFrameGetCommandBarButton(2, 1), 0, dz.DzFrameGetCommandBarButton(2, 0), 0, dx, 0.00)
    dz.DzFrameSetPoint(dz.DzFrameGetCommandBarButton(2, 2), 0, dz.DzFrameGetCommandBarButton(2, 1), 0, dx, 0.00)
    dz.DzFrameSetPoint(dz.DzFrameGetCommandBarButton(2, 3), 0, dz.DzFrameGetCommandBarButton(2, 2), 0, dx, 0.00)
end
--------------------------------------------------------------------------------------
function code.customMiniMap()
    print('called customMiniMapcustomMiniMapcustomMiniMap')
    local miniMap = dz.DzFrameGetMinimap()
    dz.DzFrameClearAllPoints(miniMap)
    dz.DzFrameSetSize(miniMap, 0.097, 0.125)
    dz.DzFrameSetPoint(miniMap, 6, dz.DzGetGameUI(), 6, 0.0698, 0.0066)
    dz.DzFrameShow(miniMap, true)

    dz.DzFrameEditBlackBorders(0.01, 0)

    --------------------------------------------------------------------------------------
    -- 物品栏
    local r = 0.0255
    local r2 = 0.036

    for i = 0, 5 do
        dz.DzFrameClearAllPoints(dz.DzFrameGetItemBarButton(i))
        dz.DzFrameSetSize(dz.DzFrameGetItemBarButton(i), r, r2)
    end

    dz.DzFrameSetAbsolutePoint(dz.DzFrameGetItemBarButton(0), 0, 0.4965, 0.128)
    dz.DzFrameSetPoint(dz.DzFrameGetItemBarButton(1), 3, dz.DzFrameGetItemBarButton(0), 5, 0.0077, 0.00)
    dz.DzFrameSetPoint(dz.DzFrameGetItemBarButton(2), 1, dz.DzFrameGetItemBarButton(0), 7, 0.00, -0.0071)
    dz.DzFrameSetPoint(dz.DzFrameGetItemBarButton(3), 1, dz.DzFrameGetItemBarButton(1), 7, 0.00, -0.0071)
    dz.DzFrameSetPoint(dz.DzFrameGetItemBarButton(4), 1, dz.DzFrameGetItemBarButton(2), 7, 0.00, -0.0071)
    dz.DzFrameSetPoint(dz.DzFrameGetItemBarButton(5), 1, dz.DzFrameGetItemBarButton(3), 7, 0.00, -0.0071)

    GUI.setSkillIconPos()

end

-- -- 伤害面板最后加载 垫在最后面
-- ui.dmgBoard:new()
