#ifndef ItemEquipDef
#define ItemEquipDef
#include "YDWEBase.j"

library ItemEquip requires YDWEBase

  globals
    integer array udg_EquipModel_1 
    integer array udg_EquipModel_2
    integer array udg_EquipModel_3
    integer array udg_EquipModel_4
    integer array udg_EquipModel_5
    integer array udg_EquipModel_6
    integer array udg_EquipModel_7
    integer array udg_EquipModel_8
    integer array udg_EquipModel_9
    integer array udg_EquipModel_10
  endglobals

  <?
  
  local slk = require 'slk'

  local usable = 'A045'
  

  ?>
  function ItemEquipInit takes nothing returns nothing

    
    <?
    
    local namePrefix = {'1', '2', '3','4','5','6','7','8','9','10'}
    local file = {
        [[Objects\InventoryItems\TreasureChest\treasurechest.mdl]],
        [[Objects\InventoryItems\TreasureChest\treasurechest.mdl]],
        [[Objects\InventoryItems\TreasureChest\treasurechest.mdl]],
        [[Objects\InventoryItems\TreasureChest\treasurechest.mdl]],
        [[Objects\InventoryItems\TreasureChest\treasurechest.mdl]],
        [[Objects\InventoryItems\TreasureChest\treasurechest.mdl]],
        [[Objects\InventoryItems\TreasureChest\treasurechest.mdl]],
        [[Objects\InventoryItems\TreasureChest\treasurechest.mdl]],
        [[Objects\InventoryItems\TreasureChest\treasurechest.mdl]],
        [[Objects\InventoryItems\TreasureChest\treasurechest.mdl]],
    }

    local art = {
        [[ReplaceableTextures\CommandButtons\BTNCrystalBall.blp]],
        [[ReplaceableTextures\CommandButtons\BTNCrystalBall.blp]],
        [[ReplaceableTextures\CommandButtons\BTNCrystalBall.blp]],
        [[ReplaceableTextures\CommandButtons\BTNCrystalBall.blp]],
        [[ReplaceableTextures\CommandButtons\BTNCrystalBall.blp]],
        [[ReplaceableTextures\CommandButtons\BTNCrystalBall.blp]],
        [[ReplaceableTextures\CommandButtons\BTNCrystalBall.blp]],
        [[ReplaceableTextures\CommandButtons\BTNCrystalBall.blp]],
        [[ReplaceableTextures\CommandButtons\BTNCrystalBall.blp]],
        [[ReplaceableTextures\CommandButtons\BTNCrystalBall.blp]],
    }
    local color = {
      {155, 155, 155},
      {0, 155, 255},
      {55, 255, 155},
      {155, 255, 105},

      {255, 255, 255},
      {255, 55, 255},
      {255, 100, 155},
      {255, 55, 55},
      {255, 205, 55},
      {248, 154, 224},
    }

    local scale = {1, 1, 1,1,1,1,1,1,1,1}
    local num = {20, 20, 20, 20, 20, 30, 30, 30, 40, 40}
    local goldcost = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0}
    
    for k = 1, 10 do
      local counter = 0
      for i = 1, num[k] do
      
        --local objName = string.format('%s [%s级] [%s]', namePrefix[i] .. data.name, i, pack.element[1])
        local objName = string.format('%s级装备模板 %03d', namePrefix[k], i)
        
        --namePrefix[i] .. pack.name 

        counter = counter + 1
        local obj = slk.item.sres:new('Equip'..namePrefix[k] .. counter)--创建ID i2=玩家索引 i3=槽位 i7=英雄索引   
        obj.Name = objName
        obj.Tip = '装备模板'  
        obj.Description = '装备模板' 
        obj.Ubertip = '装备模板' 
        obj.Art = art[k]
        obj.file = file[k]
        obj.goldcost = goldcost[k]
        obj.uses = 0
        obj.perishable = 0
        obj.class = 'Permanent'
        obj.scale = scale[k]
        obj.colorR = color[k][1]
        obj.colorB = color[k][2]
        obj.colorG = color[k][3]
        obj.abilList = ''

        if k >= 6 then
          obj.usable = 1
          obj.abilList = 'A03K'
        else
          obj.usable = 0
        end


        if k == 1 then
          ?>                                                
          set udg_EquipModel_1[<?=counter?>] = YDWEConverAbilcodeToInt('<?= obj:get_id() ?>')
          <?
        elseif k == 2 then
          ?>                                                
          set udg_EquipModel_2[<?=counter?>] = YDWEConverAbilcodeToInt('<?= obj:get_id() ?>')
          <?
        elseif k == 3 then  
          ?>                                                
          set udg_EquipModel_3[<?=counter?>] = YDWEConverAbilcodeToInt('<?= obj:get_id() ?>')
          <?
        elseif k == 4 then  
          ?>                                                
          set udg_EquipModel_4[<?=counter?>] = YDWEConverAbilcodeToInt('<?= obj:get_id() ?>')
          <?
        elseif k == 5 then  
          ?>                                                
          set udg_EquipModel_5[<?=counter?>] = YDWEConverAbilcodeToInt('<?= obj:get_id() ?>')
          <?
        elseif k == 6 then  
          ?>                                                
          set udg_EquipModel_6[<?=counter?>] = YDWEConverAbilcodeToInt('<?= obj:get_id() ?>')
          <?
        elseif k == 7 then  
          ?>                                                
          set udg_EquipModel_7[<?=counter?>] = YDWEConverAbilcodeToInt('<?= obj:get_id() ?>')
          <?
        elseif k == 8 then  
          ?>                                                
          set udg_EquipModel_8[<?=counter?>] = YDWEConverAbilcodeToInt('<?= obj:get_id() ?>')
          <?
        elseif k == 9 then  
          ?>                                                
          set udg_EquipModel_9[<?=counter?>] = YDWEConverAbilcodeToInt('<?= obj:get_id() ?>')
          <?
        elseif k == 10 then  
          ?>                                                
          set udg_EquipModel_10[<?=counter?>] = YDWEConverAbilcodeToInt('<?= obj:get_id() ?>')
          <?
        end
      end

    end

    ?>
    return
  endfunction

endlibrary

#endif
