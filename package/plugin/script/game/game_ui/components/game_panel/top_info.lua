--------------------------------------------------------------------------------------
class.top_info = extends(class.panel) {

    new = function(parent)
        -- 底图是一张黑色的图片 这个可以写死
        local panel = class.panel.new(parent, [[top_info_base.tga]], 1, 1, 270, 90)
        -- 改变panel对象的类
        panel.__index = class.top_info
        panel:construct()
        panel:draw()
        panel:show()
        return panel
    end,

}
local mt = class.top_info
------------------------------------------------------------------------------------
function mt:measure()
    self.x1 = -0.532
    self.y1 = 0.01

    self.x2 = -0.465
    self.y2 = 0.01

    self.x3 = -0.527
    self.y3 = 0.045

    self.x4 = -0.488
    self.y4 = 0.048
end
--------------------------------------------------------------------------------------
function mt:draw()
    self:measure()
    fc.setFramePosPct(self, ANCHOR.TOP_CENTER, MAIN_UI, ANCHOR.CENTER, 0, -0.5)
    --------------------------------------------------------------------------------------
    -- 敌人数量
    local enemyNumTip = self.enemyNumTip
    enemyNumTip:set_control_size(15, 15)
    fc.setFramePosPct(enemyNumTip, ANCHOR.TOP_LEFT, MAIN_UI, ANCHOR.TOP_RIGHT, self.x4, self.y4)
    --------------------------------------------------------------------------------------
    -- 难度
    local currentDiff = self.currentDiff
    currentDiff:set_control_size(15, 15)
    fc.setFramePosPct(currentDiff, ANCHOR.TOP_LEFT, MAIN_UI, ANCHOR.TOP_RIGHT, self.x1, self.y1)

    --------------------------------------------------------------------------------------
    -- 波次
    local currentWave = self.currentWave
    currentWave:set_control_size(15, 15)
    fc.setFramePosPct(currentWave, ANCHOR.TOP_LEFT, MAIN_UI, ANCHOR.TOP_RIGHT, self.x2, self.y2)

    --------------------------------------------------------------------------------------
    -- 无尽tag
    local endlessText = self.endlessText
    endlessText:set_control_size(15, 15)
    fc.setFramePosPct(endlessText, ANCHOR.TOP_LEFT, MAIN_UI, ANCHOR.TOP_RIGHT, self.x2 + 0.013, self.y2)

    --------------------------------------------------------------------------------------
    -- 敌人数量进度条底
    local EnemyNumBackGround = self.EnemyNumBackGround
    EnemyNumBackGround:set_control_size(162, 20)
    fc.setFramePosPct(EnemyNumBackGround, ANCHOR.TOP_LEFT, MAIN_UI, ANCHOR.TOP_RIGHT, self.x3, self.y3)

    --------------------------------------------------------------------------------------
    -- 敌人数量进度条外框
    local EnemyNumFrame = self.EnemyNumFrame
    EnemyNumFrame:set_control_size(162, 20)
    fc.setFramePosPct(EnemyNumFrame, ANCHOR.TOP_LEFT, MAIN_UI, ANCHOR.TOP_RIGHT, self.x3, self.y3)

    --------------------------------------------------------------------------------------
    -- 敌人数量进度条实时
    local EnemyNumCurrentProgressBar = self.EnemyNumCurrentProgressBar
    EnemyNumCurrentProgressBar:set_control_size(162, 20)
    fc.setFramePosPct(EnemyNumCurrentProgressBar, ANCHOR.TOP_LEFT, MAIN_UI, ANCHOR.TOP_RIGHT, self.x3, self.y3)

    --------------------------------------------------------------------------------------
    -- 场地效果
    local fieldBtn = self.fieldBtn
    fieldBtn:set_control_size(90, 40)
    fc.setFramePos(fieldBtn, ANCHOR.TOP_LEFT, self, ANCHOR.BOT_CENTER, -90, -18)

    --------------------------------------------------------------------------------------
    -- 查看热度
    local heatBtn = self.heatBtn
    heatBtn:set_control_size(90, 40)
    fc.setFramePos(heatBtn, ANCHOR.TOP_LEFT, self, ANCHOR.BOT_CENTER, 10, -18)

end
--------------------------------------------------------------------------------------
function mt:construct()
    --------------------------------------------------------------------------------------
    -- 难度
    local currentDiff = self:add_text('', 0, 0, 1, 1, 10, 'topleft')
    self.currentDiff = currentDiff
    --------------------------------------------------------------------------------------
    -- 波次
    local currentWave = self:add_text('', 0, 0, 1, 1, 10, 'topleft')
    self.currentWave = currentWave

    --------------------------------------------------------------------------------------
    -- 敌人数量进度条底
    local EnemyNumBackGround = self:add_texture([[guaiwushuliangxuetiaodi.tga]], 0, 0, 1, 1)
    self.EnemyNumBackGround = EnemyNumBackGround

    --------------------------------------------------------------------------------------
    -- 敌人数量进度条外框
    local EnemyNumFrame = self:add_texture([[guaiwushuliangxuetiaokuang.tga]], 0, 0, 1, 1)
    self.EnemyNumFrame = EnemyNumFrame

    --------------------------------------------------------------------------------------
    -- 敌人数量进度条底
    local EnemyNumCurrentProgressBar = self:add_texture([[lvsetiao.tga]], 0, 0, 1, 1)
    self.EnemyNumCurrentProgressBar = EnemyNumCurrentProgressBar
    -- 敌人数量
    --------------------------------------------------------------------------------------
    local enemyNumTip = self:add_text('', 0, 0, 1, 1, 10, 'center')
    self.enemyNumTip = enemyNumTip
    local endlessText = self:add_text('', 0, 0, 1, 1, 8, 'center')
    self.endlessText = endlessText
    --------------------------------------------------------------------------------------
    -- reg:addToPool('ui_render_list', self)

    --------------------------------------------------------------------------------------
    local fieldBtn = self:add_button([[changdixiaoguo1.tga]], 0, 0, 1, 1)
    self.fieldBtn = fieldBtn
    fieldBtn:set_hover_image([[changdixiaoguo2.tga]])
    function fieldBtn:on_button_clicked()
        self.parent:toggleFieldTip()
    end
    fieldBtn:hide()

    --------------------------------------------------------------------------------------
    local heatBtn = self:add_button([[chakanreli1.tga]], 0, 0, 1, 1)
    self.heatBtn = heatBtn
    heatBtn:set_hover_image([[chakanreli2.tga]])
    function heatBtn:on_button_clicked()
        self.parent:toggleHeatTip()
    end
    heatBtn:hide()

end
--------------------------------------------------------------------------------------
function mt:toggleFieldTip()

    if not gm.fieldEffect then
        return
    end

    if topToolbox.is_show and topToolbox.currentShow == self.fieldBtn then
        topToolbox:hide()
        return
    end

    topToolbox.currentShow = self.fieldBtn

    local title = str.format('|cffffcc00本局场地效果：|r%s', gm.fieldEffect.name)
    local tip = gm.fieldEffect.tip
    topToolbox:tooltip(title, tip)
    fc.setFramePos(topToolbox, ANCHOR.TOP_CENTER, self, ANCHOR.BOT_CENTER, 0, 30)
    topToolbox:show()

end
--------------------------------------------------------------------------------------
function mt:toggleHeatTip()

    if topToolbox.is_show and topToolbox.currentShow == self.heatBtn then
        topToolbox:hide()
        return
    end

    topToolbox.currentShow = self.heatBtn

    local title = ''
    local tip = ''

    title = str.format('|cffffcc00本局地狱热度：|r%d', EnemyManager.diffHeatLv)
    tip = '|cffff3300敌人词缀 ↓|r|n|n'

    for i, affix in ipairs(EnemyManager.affixList) do
        if i > 1 then
            tip = tip .. '\n\n'
        end

        tip = tip .. str.format([[|cffff7300%s：|r%s]], affix.title, affix.normalTip)
    end

    if EnemyManager.diffHeatLv <= 0 then
        title = '|cff949494未开启地狱模式|r'
        tip = '|cff949494暂无热度|r'
    end

    topToolbox:tooltip(title, tip)
    fc.setFramePos(topToolbox, ANCHOR.TOP_CENTER, self, ANCHOR.BOT_CENTER, 0, 30)
    topToolbox:show()

end
--------------------------------------------------------------------------------------
function mt:updateBoard(enemyNum, maxNum, waveNum, maxWaveNum)
    self.enemyNumTip:set_text(string.format('%d/%d', enemyNum, maxNum))
    self.currentDiff:set_text(string.format('%d-%d', gm.chapter.id, EnemyManager.diffNum))
    if EnemyManager.diffHeatMode == true then
        self.currentDiff:set_text(string.format('|cffff0000%d-%d|r', gm.chapter.id, EnemyManager.diffNum))
    end
    
    self:set_normal_image([[top_info_base.tga]])
        self.currentWave:set_text(string.format('%d/%d', waveNum, maxWaveNum))
        fc.setFramePosPct(self.currentWave, ANCHOR.TOP_LEFT, MAIN_UI, ANCHOR.TOP_RIGHT, self.x2, self.y2)
        self.endlessText:hide()

    if EnemyManager.huntMode then
        self.currentDiff:set_text(string.format('N/A'))
        self.currentDiff:set_text(string.format('狩猎模式'))
    end

    local rate1 = math.max(0.001, enemyNum / maxNum)
    local pic = [[]]
    if rate1 <= 1 / 3 then
        pic = [[lvsetiao.tga]]
    elseif rate1 > 1 / 3 and rate1 <= 2 / 3 then
        pic = [[chengsetiao.tga]]
    else
        pic = [[hongsetiao.tga]]
    end
    -- set_normal_image
    if rate1 > 1 then
        rate1 = 1
    end
    self.EnemyNumCurrentProgressBar:set_normal_image(pic)
    self.EnemyNumCurrentProgressBar:set_control_size(162 * rate1, 20)

end
------------------------------------------------------------------------------------
GUI.TopInfo = mt.create()
GUI.TopInfo:show()
--------------------------------------------------------------------------------------
return mt
