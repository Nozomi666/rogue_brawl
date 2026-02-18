--------------------------------------------------------------------------------------
class.challengeEnemyTitle = extends(class.panel) {
    -- challenge_enemy_title
    barList = linked.create(),

    new = function(parent,path, ownerUnit)
        return
        -- local height = 200
        -- -- local base = [[challengeEnemyTitle\jinbi.tga]]
        -- local w = 105
        -- local h = 52.5

        -- local base = str.format([[challengeEnemyTitle\%s.tga]],path)
        -- local panel = class.panel.new(parent, base, 0, 0, w, h)
        -- -- 改变panel对象的类
        -- panel.ownerUnit = ownerUnit
        -- -- panel:set_level(UI_LEVEL_HERO_HP_GUI)

        -- return panel
    end,
}
--------------------------------------------------------------------------------------
local mt = class.challengeEnemyTitle
