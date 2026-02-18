--------------------------------------------------------------------------------------
class.enemy_skills = extends(class.panel) {

    new = function(parent)
        -- 底图是一张黑色的图片 这个可以写死
        local panel = class.panel.new(parent, '', 1, 1, 1, 1)
        -- 改变panel对象的类
        panel.__index = class.enemy_skills
        panel:construct()
        panel:draw()
        panel:show()
        return panel
    end,

}
local mt = class.enemy_skills
------------------------------------------------------------------------------------
function mt:measure()
    self.w1 = 180
    self.h1 = 20

    self.w2 = 72
    self.h2 = 72

end
--------------------------------------------------------------------------------------
function mt:draw()
    self:measure()

    --------------------------------------------------------------------------------------
    -- 文本
    local title = self.title
    title:set_control_size(200, 10)
    fc.setFramePos(title, ANCHOR.TOP_LEFT, MAIN_UI, ANCHOR.CENTER, 422, 475.5)

    --------------------------------------------------------------------------------------
    -- 按钮
    local btnId = 1
    for i = 1, 2 do
        for j = 1, 4 do
            local skillBtn = self.skillBtn[btnId]
            skillBtn:set_control_size(self.w2, self.h2)
            fc.setFrameGridPos(skillBtn, ANCHOR.TOP_LEFT, title, ANCHOR.TOP_RIGHT, -36, -25, -87, 87, i, j)
            btnId = btnId + 1
        end
    end

end
--------------------------------------------------------------------------------------
function mt:construct()

    --------------------------------------------------------------------------------------
    local title = self:add_text('|cffca9bff技能：|r', 0, 0, 1, 1, 10, 'left')
    self.title = title
    title:hide()

    --------------------------------------------------------------------------------------
    -- 按钮
    self.skillBtn = {}
    for i = 1, 8 do

        --------------------------------------------------------------------------------------
        -- 按钮本体
        local skillBtn = class.button.new(self, [[ReplaceableTextures\CommandButtons\BTNControlMagic.blp]], 0, 0, 1, 1)
        self.skillBtn[i] = skillBtn

        function skillBtn:on_button_mouse_enter()
            self.parent:showSkillInfo(skillBtn)
        end

        function skillBtn:on_button_mouse_leave()
            toolbox:hide()
        end

    end

    for i = 1, 8 do
        self.skillBtn[i]:hide()
    end

end
--------------------------------------------------------------------------------------
function mt:update(unit)

    for i = 1, 8 do
        self.skillBtn[i]:hide()
    end

    if not unit.skill then
        return
    end

    self:draw()

    local c = 1
    for i, skillName in ipairs(unit.skill) do
        if i > 8 then
            return
        end
        local skill = unit:getSkill(skillName)
        if skill then
            local art = skill.art
            if not art then
                art = [[ReplaceableTextures\CommandButtons\BTNlingqiaodayouhun.blp]]
            end

            local skillBtn = self.skillBtn[c]
            skillBtn.skill = skill
            skillBtn:set_normal_image(art)
            skillBtn:show()
            c = c + 1
        end

    end

end
--------------------------------------------------------------------------------------
function mt:showSkillInfo(skillBtn)
    local skill = skillBtn.skill
    local title = skill.title
    local tip = skill:getTip()
    if skill.getEnemySkillTip then
        tip = skill:getEnemySkillTip()
    end

    toolbox:tooltip(title, tip)

    fc.setFramePos(toolbox, ANCHOR.BOT_RIGHT, skillBtn, ANCHOR.BOT_LEFT, -10, 0)
    toolbox:show()
end
------------------------------------------------------------------------------------
GUI.EnemySkills = mt.create()
GUI.EnemySkills:show()
--------------------------------------------------------------------------------------
return mt
