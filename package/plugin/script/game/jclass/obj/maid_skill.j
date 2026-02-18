#ifndef MaidSkillDef
#define MaidSkillDef
#include "YDWEBase.j"

library CustomMaidSkill initializer MaidSkillInit requires YDWEBase


  <? local slk = require 'slk' ?>

  function MaidSkillInit takes nothing returns nothing
    <?
    
    
    for i, skillDefine in pairs(G_MaidSkillDefine) do
      local skillName = skillDefine.Name
      local skillId = 'm' .. string.format('%03d', i)
      local obj = slk.ability.ANcl:new(skillId)
      obj.Name = skillName
      obj.Art = skillDefine.Art
      obj.hero = 0 --非英雄技能
      obj.DataA1 = 0 --引导持续时间
      obj.DataB1 = skillDefine.DataB1 --技能模式
      obj.DataC1 = skillDefine.DataC1 --施法圆心指示器
      obj.DataD1 = 0 --施法持续时间
      obj.DataE1 = 0 --使其他技能无效
      obj.DataF1 = skillDefine.DataF1 --命令ID
      obj.Hotkey = skillDefine.HotKey
      obj.Art = skillDefine.Art
      obj.Buttonpos = skillDefine.Buttonpos
      obj.Buttonpos2 = skillDefine.Buttonpos2
      obj.EffectArt = ""
      obj.TargetArt = ""
      obj.CasterArt = ""
      obj.Animnames = skillDefine.Animnames
      obj.levels = 1
      obj.race = "human"
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
