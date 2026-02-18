#ifndef ItemDef
#define ItemDef
#include "YDWEBase.j"

globals
   hashtable udg_HTItemModel= null
endglobals

library CustomItem initializer ItemInit requires YDWEBase


  <? local slk = require 'slk' ?>

  function ItemInit takes nothing returns nothing

    local hashtable hxb = InitHashtable()

    set udg_HTItemModel = hxb

    <?
    
    
    for i, itemDefine in pairs(G_ItemDefine) do
      local itemName = itemDefine.Name
      
      -- 定义造塔物品
      local itemId = '物品' .. i
      local obj = slk.item.tsct:new(itemId)  
      obj.Name = itemName
      obj.Description = itemName
      obj.Tip = itemName
      obj.UberTip = obj:get_id()
      obj.abilList = itemDefine.abilList
      obj.Art = itemDefine.Art
      obj.file = itemDefine.file
      obj.scale = itemDefine.scale
      obj.powerup = itemDefine.powerup
      obj.uses = itemDefine.uses
      obj.usable = itemDefine.usable
      obj.colorR = itemDefine.colorR
      obj.colorG = itemDefine.colorG
      obj.colorB = itemDefine.colorB

      ?>
      call SaveStr( hxb, StringHash("CItem"), StringHash(<?= '\"' ..itemName ..'\"'?>),  <?= '\"' .. obj:get_id() .. '\"' ?> )
      <?

    end



    ?>
    return
  endfunction

endlibrary

#endif
