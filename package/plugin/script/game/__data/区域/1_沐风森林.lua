local name = '沐风森林'
--------------------------------------------------------------------------------------
local mt = {

    name = name,
    path = [[mufengsenlin.tga]],
    startX = -2455,
    startY = -2196,
    length = 4500,

    -- rewardAnchor = {
    --     [1] = ac.point:new(-8112, 10240),
    --     [2] = ac.point:new(-4272, 8224),
    --     [3] = ac.point:new(-5808, 4224),
    --     [4] = ac.point:new(-10096, 5632),
    -- },

    reward_point_main = {
        [1] = ac.point:new(-6000,-6700),
        [2] = ac.point:new(-2900, -6700),
        [3] = ac.point:new(300, -6700),
        [4] = ac.point:new(4000, -6700),
    },

    reward_point_equip = {
        [1] = ac.point:new(-6000,-6700),
        [2] = ac.point:new(-2900, -6700),
        [3] = ac.point:new(300, -6700),
        [4] = ac.point:new(4000, -6700),
    },

    shop_point_1 = {
        [1] = ac.point:new(-8809, 10300),
        [2] = ac.point:new(-6468, 10300),
        [3] = ac.point:new(-8464, 5542),
        [4] = ac.point:new(-6468, 5542),
    },

    shop_point_2 = {
        [1] = ac.point:new(-8472, 10300),
        [2] = ac.point:new(-6780, 10300),
        [3] = ac.point:new(-8472, 5542),
        [4] = ac.point:new(-6780, 5542),
    },

    fish_point = {
        [1] = ac.point:new(-6816, 11200),
        [2] = ac.point:new(-6688, 10944),
        [3] = ac.point:new(-6304, 10944),
        [4] = ac.point:new(-6208, 11200),
        [5] = ac.point:new(-6520, 11236),
    },

    enemy_born_point = {
        [1] = ac.point:new(-6000, -3150),
        [2] = ac.point:new(-2680, -3150),
        [3] = ac.point:new(600, -3150),
        [4] = ac.point:new(3960, -3150),
    },

    base_center = {
        [1] = ac.point:new(-6000, -6050),
        [2] = ac.point:new(-2680, -6050),
        [3] = ac.point:new(600, -6050),
        [4] = ac.point:new(3960, -6050),
    },

    miniMapPath = [[minimap_1.tga]],

    testPoint = ac.point:new(-9000, 9000),

    normalBgmList = {{
        name = 'gg_snd_bgm_chapter_1_normal_1',
        length = 153,
    }, {
        name = 'gg_snd_bgm_chapter_1_normal_2',
        length = 224,
    }, {
        name = 'gg_snd_bgm_chapter_1_normal_3',
        length = 84,
    }},
    bossBgm = {
        name = 'gg_snd_bgm_chapter_1_boss',
        length = 300,
    },
    finalBossBgm = {
        name = 'gg_snd_bgm_chapter_1_final_boss',
        length = 115,
    },

    fieldCard = [[FieldEffect\cp_1_card_base.tga]],

}
--------------------------------------------------------------------------------------
mt.__index = mt
MapArea:onRegister(mt)

return mt
