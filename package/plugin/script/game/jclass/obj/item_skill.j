#ifndef ItemSkillDef
#define ItemSkillDef
#include "YDWEBase.j"

library CustomItemSkill initializer ItemSkillInit requires YDWEBase


  <? local slk = require 'slk' ?>

  function ItemSkillInit takes nothing returns nothing
    <?
    
    
    for i, skillDefine in pairs(G_ItemSkillDefine) do
      local originName = skillDefine.Origin
      local skillName = skillDefine.Name
      local skillId = 'q' .. string.format('%03d', i)
      local obj = slk.ability.ANcl:new(skillId)
      obj.Name = skillName
      obj.Art = skillDefine.Art
      obj.hero = 0 --非英雄技能
      obj.item = 1 --物品技能
      obj.DataA1 = 0 --引导持续时间
      obj.DataB1 = 0
      obj.DataC1 = 1
      obj.DataD1 = 0 --施法持续时间
      obj.DataE1 = 0 --使其他技能无效
      obj.DataF1 = "magicleash"
      obj.Hotkey = ""
      obj.EffectArt = ""
      obj.TargetArt = ""
      obj.CasterArt = ""
      obj.Animnames = skillDefine.Animnames
      obj.levels = 1
      obj.race = "nightelf"
      obj.targs1 = skillDefine.targs1
      obj.Rng1 = skillDefine.Rng1
      obj.Area1 = skillDefine.Area1
      obj.Ubertip = skillName
      obj.Tip = skillName
    end

    ?>
    return
  endfunction

endlibrary

#endif
