#ifndef UnitHeroDef
#define UnitHeroDef
#include "YDWEBase.j"

library UnitHero requires YDWEBase


  <? local slk = require 'slk' ?>

  function UnitHeroInit takes nothing returns nothing
    <?
    
    for i, heroDefine in pairs(G_HeroDefine) do
      local heroName = heroDefine.name
      
      -- 定义英雄单位
      local heroId = 'X' .. string.format('%03d', i)
      local obj = slk.unit.Hblm:new(heroId)  
      obj.Name = heroName
      obj.Tip = heroName
      -- obj.isbldg = 1
      obj.file = heroDefine.model
      obj.Upgrade = ""
      obj.upgrades = ""
      obj.abilList = ""
      obj.heroAbilList = ""
      obj.unitSound = ""
      obj.BuildingSoundLabel = ""
      obj.modelScale = heroDefine.modelSize
      obj.scale = 1.5
      obj.unitSadow = "Shadow"
      obj.buildingShadow = ""
      obj.shadowH = 180
      obj.shadowW = 180
      obj.shadowX = 75
      obj.shadowY = 75
      obj.uberSplat = ""
      obj.castpt = 0.3
      obj.castbsw = 0.15
      obj.orientInterp = 4
      obj.movetp = "foot"
      obj.spd = 300
      obj.turnRate = 0.5
      obj.defType = "hero"
      obj.acquire = 2000
      obj.defUp = 0
      obj.def = 0
      obj.armor = "Flesh"
      obj.targType = "ground"
      obj.Missileart = ""
      obj.Missilespeed = 0
      obj.Missilearc = 0
      obj.MissileHoming = 1
      obj.weapTp1 = heroDefine.weapType
      obj.weapType1 = heroDefine.weapType1
      obj.atkType1 = heroDefine.atkType1
      obj.Art = heroDefine.art
      obj.type = ""
      obj.targs1 = "ground,structure,debris,air,item,ward"
      obj.backSw1 = 0.3
      obj.dmgpt1 = 0.15
      obj.rangeN1 = 800
      obj.RngBuff1 = 250
      obj.sides1 = 1
      obj.dice1 = 1
      obj.cool1 = 1
      obj.weapsOn = 1
      obj.HP = 100
      obj.targType = "ground,structure"
      obj.unitShadow = ""
      obj.launchZ = 100
      obj.impactZ = 60
      obj.Propernames = heroName


    end

    ?>
    return
  endfunction

endlibrary

#endif
