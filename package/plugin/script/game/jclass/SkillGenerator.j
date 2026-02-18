#ifndef SkillModelGenerator
#define SkillModelGenerator
#include "YDWEBase.j"

globals
   hashtable udg_HTSkillModel= null
endglobals

library SkillSystem initializer MakeSkillModel requires YDWEBase

<?local slk = require 'slk' ?>
<?FlexSkillTable = {} ?>


  function MakeSkillModel takes nothing returns nothing
    local hashtable hxb = InitHashtable()
    local unit dummy = CreateUnit( Player(0), 'Hblm', 0.00, 0.00, bj_UNIT_FACING )

 
    set udg_HTSkillModel = hxb

    <? 

    local sl = 0
    local key = {}
    local idkey = {}
    local skillId = 0
    key[1] = 'Q'
    key[2] = 'W'
    key[3] = 'E'
    key[4] = 'R'
    key[5] = 'X'
    key[6] = ''
    key[7] = 'F'
    key[8] = 'V'

    --对单位
    idkey[1] = {}
    idkey[1][1] = "thunderbolt"
    idkey[1][2] = "holybolt"
    idkey[1][3] = "invisibility"
    idkey[1][4] = "slow"
    idkey[1][5] = "spiritlink"
    idkey[1][6] = "ensnare"
    idkey[1][7] = "polymorph"
    idkey[1][8] = "magicleash"

    --对友单位（废弃）
    idkey[2] = {}
    idkey[2][1] = "antimagicshell"
    idkey[2][2] = "spiritlink" 
    idkey[2][3] = "rejuvination"
    idkey[2][4] = "shadowstrike"
    idkey[2][5] = "healingwave"
    idkey[2][6] = "entanglingroots"
    idkey[2][7] = "creepthunderbolt"
    idkey[2][8] = "unholyfrenzy"

    --对目标点ID命令
    idkey[3] = {}
    idkey[3][1] = "flamestrike"
    idkey[3][2] = "farsight"
    idkey[3][3] = "deathanddecay"
    idkey[3][4] = "forceofnature"
    idkey[3][5] = "shockwave"
    idkey[3][6] = "ward"
    idkey[3][7] = "dispel"
    idkey[3][8] = "rainoffire"

    --无目标
    idkey[4] = {}
    idkey[4][1] = "fanofknives"
    idkey[4][2] = "windwalk"
    idkey[4][3] = "spiritwolf"
    idkey[4][4] = "stomp"
    idkey[4][5] = "roar"
    idkey[4][6] = "scout"
    idkey[4][7] = "starfall"
    idkey[4][8] = "resurrection"
    idkey[4][9] = "waterelemental"
    idkey[4][10] = "berserk"
    idkey[4][11] = "stoneform"
    idkey[4][12] = "root"

    local strName = {}
    strName[1] = '对人'
    strName[2] = '对友' -- 废弃
    strName[3] = '对点'
    strName[4] = '对空'

    local orderType = {}
    orderType[1] = 1
    orderType[2] = 1
    orderType[3] = 2
    orderType[4] = 0

    -- 被动技能
    for i2 = 1,sl do
       for i3 = 1, 8 do

          butx = i3 - 1
          buty = 2
          if i3 > 4 then
            butx = i3 - 5
            buty = 1
          end
  
          for i7 = 1, 1 do

          skillId = skillId + 1
            local obj = slk.ability.Asth:new('FlexSkill'..skillId)--创建ID i2=玩家索引 i3=槽位 i7=英雄索引   
                obj.Buttonpos = 0
                obj.Ubertip = "暂无学习任何技能"
                obj.Tip = "系统技能"
                obj.race = "naga"
                obj.EditorSuffix = "玩家"..i2.."的"..i7.."英雄的"..i3.."被动"
                obj.levels = 2
                obj.Requires = ""
                obj.Hotkey = key[i3] --快捷键
                obj.Buttonpos = butx
                obj.Buttonpos2 = buty
                obj.Untip = "p"
                obj.Unubertip = i3          
            ?>
            call YDWESaveAbilityHandle(hxb,StringHash(I2S(<?= i2 ?>) + I2S(<?= i7 ?>)),StringHash(I2S(<?= i3 ?>) + "0"), YDWEConverAbilcodeToInt('<?= obj:get_id() ?>'))
            call UnitAddAbility( dummy, '<?= obj:get_id() ?>' )
            <?
            end    
        end
    end

    -- 主动技能
    local x,y,z = 0,0,0

    for i4 = 1, sl do
      for i5 = 1, 8 do
        for i6 =1,4 do
          if i6 ~= 2 then
            strname = strName[i6]

            butx = i5 - 1
            buty = 2 

            if i5 > 4 then
              butx = i5 - 5
              buty = 1
            end

            idml = idkey[i6][i5]
              for i7 = 1,1 do
              
                z = z + 1
                if (z >= 10) then
                  z = 0
                  y = y + 1
                if (y >= 10) then
                  y = 0
                  x = x + 1
                end
              end

            skillId = skillId + 1
            local obj = slk.ability.ANcl:new('FlexSkill'..skillId) --i4=玩家索引 i7=英雄索引 i5=技能索引 i6=技能类别
              obj.hero =0 --非英雄技能
              obj.DataA1 = 0 --引导持续时间
              obj.DataB1 = orderType[i6] --技能模式
              if i6 == 3 then
                obj.DataC1 = 15 --施法圆心指示器
              else
                obj.DataC1 = 13 --无指示器
              end
              
              obj.DataE1 = 0 --使其他技能无效
              obj.DataF1 = idml --命令ID
              obj.Hotkey = key[i5] --快捷键
              obj.Rng1 = 800 --距离
              obj.Area1 = 350 --距离
              obj.Art =  "ReplaceableTextures\\CommandButtons\\BTNWispSplode.blp"
              obj.Buttonpos = butx
              obj.Buttonpos2 = buty
              obj.EffectArt = ""
              obj.TargetArt = ""
              obj.CasterArt = ""
              obj.Animnames = "spell"
              obj.levels = 2
              obj.race = "naga" --分类
              obj.Ubertip = "暂无学习任何技能"
              obj.Tip = "系统技能"
              obj.EditorSuffix = "玩家"..i4.."的"..i7.."英雄的"..i5.."-"..strname
              obj.Requires = ""
              obj.Unubertip = i5
              obj.targs1 = "enemies,vulnerable,,friend"
              obj.Untip = "1"
                      
              ?>
                //call YDWESaveAbilityHandle(hxb,StringHash(I2S(<?= i4 ?>) + I2S(<?= i7 ?>)),StringHash(I2S(<?= i5 ?>) + I2S(<?= 0 ?>)), YDWEConverAbilcodeToInt('<?= obj:get_id() ?>'))
                call YDWESaveAbilityHandle(hxb,StringHash(I2S(<?= i4 ?>) + I2S(<?= i7 ?>)),StringHash(I2S(<?= i5 ?>) + I2S(<?= i6 ?>)), YDWEConverAbilcodeToInt('<?= obj:get_id() ?>'))
                call UnitAddAbility( dummy, '<?= obj:get_id() ?>' )
              <? 
          end  
        end
      end
    end
  end

  --商店模板技能
  local x,y,z = 0,0,0
  local btnX = {}
  local btnY = {}
  local playerIdMin, playerIdMax, btnIdMin, btnIdMax, btnClass

  btnX[1] = 0
  btnX[2] = 1
  btnX[3] = 2
  btnX[4] = 3
  btnX[5] = 0
  btnX[6] = 1
  btnX[7] = 2
  btnX[8] = 3
  btnX[9] = 0 
  btnX[10] = 1
  btnX[11] = 2
  btnX[12] = 3

  btnY[1] = 0
  btnY[2] = 0
  btnY[3] = 0
  btnY[4] = 0
  btnY[5] = 1
  btnY[6] = 1
  btnY[7] = 1
  btnY[8] = 1
  btnY[9] = 2
  btnY[10] = 2
  btnY[11] = 2
  btnY[12] = 2

  key[1] = 'Q'
  key[2] = 'W'
  key[3] = 'E'
  key[4] = 'R'
  key[5] = 'A'
  key[6] = 'S'
  key[7] = 'D'
  key[8] = 'F'
  key[9] = 'Z'
  key[10] = 'X'
  key[11] = 'C'
  key[12] = 'V'


  --无目标
  local accskey= {}
  accskey[1] = "vengeanceon"
  accskey[2] = "windwalk"
  accskey[3] = "whirlwind"
  accskey[4] = "webon"
  accskey[5] = "weboff"
  accskey[6] = "web"
  accskey[7] = "wateryminion"
  accskey[8] = "waterelemental"
  accskey[9] = "vengeanceoff"
  accskey[10] = "ward"
  accskey[11] = "voodoo"
  accskey[12] = "volcano"




  ------------------------------------------------------------------------------------------------------------------------------ 装备商店
  playerIdMin, playerIdMax = 1, 4
  btnIdMin, btnIdMax = 1, 12
  btnClass = "EquipShop"
  
  for btnId = btnIdMin, btnIdMax do
    for playerId = playerIdMin, playerIdMax do
      butx = btnX[btnId]
      buty = btnY[btnId]
      idml = idkey[4][btnId]

      skillId = skillId + 1
      local obj = slk.ability.ANcl:new('ShopSkill'..skillId) --playerId=玩家索引 btnId=槽位索引
        obj.hero =0 --非英雄技能
        obj.DataA1 = 0 --引导持续时间
        obj.DataB1 = 0 --技能模式
        obj.DataC1 = 13 --技能模式

        
        obj.DataE1 = 0 --使其他技能无效
        obj.DataF1 = idml --命令ID
        obj.Hotkey = key[btnId]
        obj.Rng1 = 800 --距离
        obj.Area1 = 350 --距离
        obj.Art =  "ReplaceableTextures\\CommandButtons\\BTNStaffOfSanctuary.blp"
        obj.Buttonpos = butx
        obj.Buttonpos2 = buty 
        obj.EffectArt = ""
        obj.TargetArt = ""
        obj.CasterArt = ""
        obj.levels = 2
        obj.race = "naga" --分类
        obj.Ubertip = "空"
        obj.Name = btnClass
        obj.Tip = "模板"
        obj.Untip = btnId
        obj.EditorSuffix = "玩家"..playerId.."的"..btnId.."槽位"
        obj.Requires = ""
        obj.targs1 = ""
        obj.Untip = "4"      
        
        ?>
        call SaveInteger(hxb,StringHash(<?= '\"' .. btnClass .. '\"' ?>),StringHash(I2S(<?= playerId ?>) + "@" + I2S(<?= btnId ?>)), YDWEConverAbilcodeToInt('<?= obj:get_id() ?>'))
        <?
    end
  end
  ------------------------------------------------------------------------------------------------------------------------------ 装备商店结束

  

  --无目标
--local accskey= {}
 -- accskey[1] = "vengeanceon"
  --accskey[2] = "windwalk"
  --accskey[3] = "whirlwind"
  --accskey[4] = "webon"
  --accskey[5] = "weboff"
  --accskey[6] = "web"
  --accskey[7] = "wateryminion"
  --accskey[8] = "waterelemental"
  --accskey[9] = "vengeanceoff"
  --accskey[10] = "ward"
  --accskey[11] = "voodoo"
  --accskey[12] = "volcano"
      

  ?>
  call RemoveUnit(dummy)
  return
  endfunction

endlibrary

#endif
