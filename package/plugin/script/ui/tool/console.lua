local japi = require 'jass.japi'
local console = {}
JAPI_Console = console

local types = {
    ['小地图按钮']  = 'FrameGetMinimapButton',
    ['小地图']      = 'FrameGetMinimap',
    ['头像模型']    = 'FrameGetPortrait',
	['技能按钮']    = 'FrameGetCommandBarButton',
	['物品按钮']	= 'FrameGetItemBarButton',
    ['头像图标']    = 'FrameGetHeroBarButton',
    ['血条']        = 'FrameGetHeroHPBar',
    ['蓝条']        = 'FrameGetHeroManaBar',
	['提示框']      = 'FrameGetTooltip',
	['控制台'] 		= 'FrameGetSimpleConsole',
	['物品栏背景'] 	= 'FrameGetItemBackground',
	['物品栏背景图片'] 	= 'FrameGetItemBackgroundTexture',
	['物品栏'] 	= 'FrameGetItemBar',
    ['聊天消息']    = 'FrameGetChatMessage',
    ['单位消息']    = 'FrameGetUnitMessage',

	--只有施放技能后 才能获取有效的模型对象
	['按钮冷却模型'] = 'FrameGetButtonCooldownModel',
    --
    ['Base'] = game_ui,
    ["经验条"] = japi.SimpleFrameFindByName("SimpleHeroLevelBar", 0),
    ["经验条名字"] = japi.SimpleFontStringFindByName("SimpleClassValue", 0),
    ["英雄称谓"] = japi.SimpleFontStringFindByName("SimpleNameValue", 0),
    ["面板"] = japi.SimpleFrameFindByName("SimpleInfoPanelUnitDetail", 0),
    ["三围框架"] = japi.SimpleFrameFindByName("SimpleInfoPanelIconHero", 6),
    ["文本框架"] = japi.SimpleFrameFindByName("SimpleInfoPanelIconHeroText", 6),
    ["攻击图标"] = japi.SimpleTextureFindByName("InfoPanelIconBackdrop", 0),
    ["攻击名字"] = japi.SimpleFontStringFindByName("InfoPanelIconLabel", 0),
    ["攻击数值"] = japi.SimpleFontStringFindByName("InfoPanelIconValue", 0),
    ["攻击2图标"] = japi.SimpleTextureFindByName("InfoPanelIconBackdrop", 1),
    ["攻击2名字"] = japi.SimpleFontStringFindByName("InfoPanelIconLabel", 1),
    ["攻击2数值"] = japi.SimpleFontStringFindByName("InfoPanelIconValue", 1),
    ["护甲图标"] = japi.SimpleTextureFindByName("InfoPanelIconBackdrop", 2),
    ["护甲名字"] = japi.SimpleFontStringFindByName("InfoPanelIconLabel", 2),
    ["护甲数值"] = japi.SimpleFontStringFindByName("InfoPanelIconValue", 2),
    ["力量名字"] = japi.SimpleFontStringFindByName("InfoPanelIconHeroStrengthLabel", 6),
    ["敏捷名字"] = japi.SimpleFontStringFindByName("InfoPanelIconHeroAgilityLabel", 6),
    ["智力名字"] = japi.SimpleFontStringFindByName("InfoPanelIconHeroIntellectLabel", 6),
    ["力量数值"] = japi.SimpleFontStringFindByName("InfoPanelIconHeroStrengthValue", 6),
    ["敏捷数值"] = japi.SimpleFontStringFindByName("InfoPanelIconHeroAgilityValue", 6),
    ["智力数值"] = japi.SimpleFontStringFindByName("InfoPanelIconHeroIntellectValue", 6),
    ["生命周期"] = japi.SimpleFrameFindByName("SimpleProgressIndicator", 0),

    ["物品标题"] = japi.SimpleFontStringFindByName("SimpleItemNameValue", 3),
    ["物品说明"] = japi.SimpleFontStringFindByName("SimpleItemDescriptionValue", 3),

    ["联盟资源栏框架"] = japi.SimpleFrameFindByName("SimpleInfoPanelIconAlly", 7),
    ["联盟资源栏文本"] = japi.SimpleFontStringFindByName("InfoPanelIconAllyTitle", 7),
    ["联盟黄金图标"] = japi.SimpleTextureFindByName("InfoPanelIconAllyGoldIcon", 7),
    ["联盟木材图标"] = japi.SimpleTextureFindByName("InfoPanelIconAllyWoodIcon", 7),
    ["联盟食物图标"] = japi.SimpleTextureFindByName("InfoPanelIconAllyFoodIcon", 7),
    ["联盟黄金数值"] = japi.SimpleFontStringFindByName("InfoPanelIconAllyGoldValue", 7),
    ["联盟木材数值"] = japi.SimpleFontStringFindByName("InfoPanelIconAllyWoodValue", 7),
    ["联盟食物数值"] = japi.SimpleFontStringFindByName("InfoPanelIconAllyFoodValue", 7),
    ["资源栏黄金文字"] = japi.SimpleFontStringFindByName("ResourceBarGoldText",0),
    ["资源栏木材文字"] = japi.SimpleFontStringFindByName("ResourceBarLumberText",0),
    ["资源栏食物文字"] = japi.SimpleFontStringFindByName("ResourceBarSupplyText",0),
    ["资源栏维修费文字"] = japi.SimpleFontStringFindByName("ResourceBarUpkeepText",0),
    ["资源栏框架"] = japi.SimpleFrameFindByName("ResourceBarFrame", 0),

    ["左上角任务菜单"] = japi.SimpleFrameFindByName("UpperButtonBarQuestsButton",0),
    ["左上角按钮菜单"] = japi.SimpleFrameFindByName("UpperButtonBarMenuButton",0),
    ["左上角聊天按钮"] = japi.SimpleFrameFindByName("UpperButtonBarChatButton",0),
    ["左上角盟友按钮"] = japi.SimpleFrameFindByName("UpperButtonBarAlliesButton",0),
    --["左上角盟友按钮"] = japi.SimpleFrameFindByName("DzSimpleFrameFindByName",0),
}


--[[
    1.27貌似无法直接获取到BUFF栏UI，只能通过 "特殊" 方法 "伪" 获取BUFF栏UI
    BUFF栏UI是在面板框架 SimpleInfoPanelUnitDetail 下的
    因此可以将 SimpleInfoPanelUnitDetail 下的其他UI锚点清除掉之后只剩下BUFF栏UI
    通过移动 SimpleInfoPanelUnitDetail 来达到移动BUFF栏的效果
]]


local controls = {}
local game_ui = japi.GetGameUI()
console.types = types

console.get = function (name,...)
    local args = {...}
    local row = args[1]
    local column = args[2]
    local func_name = types[name]
	if func_name == nil then 
		print(name,'函数名是空的')
        return 
    end 
    local key = string.format('%s%s%s',name,tostring(row or ''),tostring(column or ''))
    local object = controls[key]
    if object == nil then 
        local control_id = japi[func_name](row,column)
		if control_id == nil or control_id == 0 then 
			print('获取id是0',name, control_id)
            return 
        end 
        object = extends(class.panel){
            _id = control_id,
            w = 0,
            h = 0,
        }
        if name == '血条' or name == '蓝条' then 
            object.set_position = function (self,x,y)
                self.x = x
                self.y = y
                x =  (x + self.w / 2) / 1920 * 0.8
                y = (1080 - y) / 1080 * 0.6
                japi.FrameSetPoint(self._id,1,game_ui,6,x,y)
            end
        elseif name == '头像模型' then
            -- object = extends(class.model2){
            --     _id = control_id,
            --     w = 0,
            --     h = 0,
            -- }
            object.set_position = function (self,x,y)
                self.x = x
                self.y = y
                x =  x / 1920 * 0.8
                y = (1080 - y - self.h) / 1080 * 0.6
                japi.FrameSetPoint(self._id,6,game_ui,6,x,y)
            end
        elseif name == '小地图' then
            object.w = 1920*(0.15/0.8) - 20
            object.h = 1080*(0.15/0.6) - 16
            object.x = 18
            object.y = 1080 - object.h -10

            object.set_position = function (self,x,y)
                self.x = x
                self.y = y
                local ax =  x / 1920 * 0.8
                local ay = (1080 - y - self.h) / 1080 * 0.6
                local bx = (x + self.w) / 1920 * 0.8
                local by = (1080 - y) / 1080 * 0.6
                japi.FrameSetPoint(self._id,6,game_ui,6,ax,ay)
                japi.FrameSetPoint(self._id,2,game_ui,6,bx,by)
            end
        elseif name == '技能按钮' then 
            object.w = 94
            object.h = 70
            object.row = row 
            object.column = column
            object.x = 1480+2 + column * (94 + 11) 
            object.y = 834+8 + (2 - row) * (70 + 8) 
            object.origin_x = object.x 
            object.origin_y = object.y
            object._id = japi[func_name](2 - row,column)
			object.set_cooldown_size = function (self,size)
				japi.FrameSetButtonCooldownModelSize(self._id,size)
            end
		elseif name == '物品按钮' then 
            object.num = row
            object.w = 78
            object.h = 59
            object.x = 1237 + row % 2 * (78 + 18)
            object.y = 878 + math.floor(row / 2) * (59 + 10)
            object.origin_x = object.x 
            object.origin_y = object.y

			object.set_cooldown_size = function (self,size)
				japi.FrameSetButtonCooldownModelSize(self._id,size)
            end

		elseif name == '聊天消息' then
            object.set_position = function (self,x,y)
                self.x = x
                self.y = y
                x =  x / 1920 * 0.8
                y =  -y / 1080 * 0.6
                japi.FrameSetPoint(self._id,0,game_ui,0,x,y)
            end
        elseif name == '单位消息' then
            object.set_position = function (self,x,y)
                self.x = x
                self.y = y
                x =  x / 1920 * 0.8
                y =  -y / 1080 * 0.6
                japi.FrameSetPoint(self._id,0,game_ui,0,x,y)
            end
        elseif name == '提示框' then 
            object.set_position = function (self,x,y)
                self.x = x
                self.y = y
                x =  (x - self.w * 1.5) / 1920 * 0.8
                y =  -y / 1080 * 0.6
                japi.FrameSetPoint(self._id,8,game_ui,1,x,y)
			end
		elseif name == '按钮冷却模型' then 
			object = extends(class.model)(object)
        end 
        controls[key] = object
    end 
    return object
end 

ac.loop(1,function(timer)
    --移除资源栏
        -- local panel_1 = types['资源栏框架']
        -- japi.DzFrameClearAllPoints(panel_1)
        -- japi.DzFrameSetPoint( panel_1, 0, japi.DzGetGameUI(), 0, 1920/1920*0.8, 0/1080*0.6 )
        -- japi.DzFrameSetSize( panel_1, 1/1920*0.8, 1/1080*0.6 )
        -- local panel_2 = types['资源栏黄金文字']
        -- japi.DzFrameClearAllPoints(panel_2)
        -- japi.DzFrameSetPoint( panel_2, 0, japi.DzGetGameUI(), 0, 1920/1920*0.8, 0/1080*0.6 )
        -- japi.DzFrameSetSize( panel_2, 1/1920*0.8, 1/1080*0.6 )
        -- local panel_2 = types ["资源栏木材文字"]
        -- japi.DzFrameClearAllPoints(panel_2)
        -- japi.DzFrameSetPoint( panel_2, 0, japi.DzGetGameUI(), 0, 1920/1920*0.8, 0/1080*0.6 )
        -- japi.DzFrameSetSize( panel_2, 1/1920*0.8, 1/1080*0.6 )
        -- local panel_2 = types["资源栏食物文字"]
        -- japi.DzFrameClearAllPoints(panel_2)
        -- japi.DzFrameSetPoint( panel_2, 0, japi.DzGetGameUI(), 0, 1920/1920*0.8, 0/1080*0.6 )
        -- japi.DzFrameSetSize( panel_2, 1/1920*0.8, 1/1080*0.6 )
    local panel_2 = types ["资源栏维修费文字"]
    japi.DzFrameClearAllPoints(panel_2)
    japi.DzFrameSetPoint( panel_2, 0, japi.DzGetGameUI(), 0, 1920/1920*0.8, 0/1080*0.6 )
    japi.DzFrameSetSize( panel_2, 1/1920*0.8, 1/1080*0.6 )

    
--[[     --移除英雄头像
    local panel_3 = japi.DzFrameGetHeroBarButton(0)
    japi.DzFrameClearAllPoints(panel_3)
    japi.DzFrameSetPoint( panel_3, 0, japi.DzGetGameUI(), 0, 1920/1920*0.8, 0/1080*0.6 )
    japi.DzFrameSetSize( panel_3, 1/1920*0.8, 1/1080*0.6 )
    local panel_3 = japi.DzFrameGetHeroHPBar(0)         --血条
    japi.DzFrameClearAllPoints(panel_3)
    japi.DzFrameSetPoint( panel_3, 0, japi.DzGetGameUI(), 0, 1920/1920*0.8, 0/1080*0.6 )
    japi.DzFrameSetSize( panel_3, 1/1920*0.8, 1/1080*0.6 )
    local panel_3 = japi.DzFrameGetHeroManaBar(0)       --蓝条
    japi.DzFrameClearAllPoints(panel_3)
    japi.DzFrameSetPoint( panel_3, 0, japi.DzGetGameUI(), 0, 1920/1920*0.8, 0/1080*0.6 )
    japi.DzFrameSetSize( panel_3, 1/1920*0.8, 1/1080*0.6 ) ]]

--[[     --清除F10等
    local panel_3 = types["左上角任务菜单"]
    japi.DzFrameClearAllPoints(panel_3)
    japi.DzFrameSetPoint( panel_3, 0, japi.DzGetGameUI(), 0, 1920/1920*0.8, 0/1080*0.6 )
    japi.DzFrameSetSize( panel_3, 1/1920*0.8, 1/1080*0.6 )
    local panel_3 = types["左上角按钮菜单"]
    japi.DzFrameClearAllPoints(panel_3)
    japi.DzFrameSetPoint( panel_3, 0, japi.DzGetGameUI(), 0, 1920/1920*0.8, 0/1080*0.6 )
    japi.DzFrameSetSize( panel_3, 1/1920*0.8, 1/1080*0.6 )
    local panel_3 = types["左上角聊天按钮"]
    japi.DzFrameClearAllPoints(panel_3)
    japi.DzFrameSetPoint( panel_3, 0, japi.DzGetGameUI(), 0, 1920/1920*0.8, 0/1080*0.6 )
    japi.DzFrameSetSize( panel_3, 1/1920*0.8, 1/1080*0.6 )
    local panel_3 = types["左上角盟友按钮"]
    japi.DzFrameClearAllPoints(panel_3)
    japi.DzFrameSetPoint( panel_3, 0, japi.DzGetGameUI(), 0, 1920/1920*0.8, 0/1080*0.6 )
    japi.DzFrameSetSize( panel_3, 1/1920*0.8, 1/1080*0.6 )
 ]]
    --
    timer:remove()
end)





return console