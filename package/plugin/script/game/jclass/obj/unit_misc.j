#ifndef UnitDefMisc
#define UnitDefMisc
#include "YDWEBase.j"

library CustomUnit requires YDWEBase


  <? local slk = require 'slk' ?>

  function UnitInit takes nothing returns nothing
    <?
    
    
    for i, unitDefine in pairs(G_UnitMiscDefine) do
      local heroName = unitDefine.name
      
      -- 定义单位
      local heroId = 'w' .. string.format('%03d', i)
      local obj = slk.unit.hfoo:new(heroId)  
      obj.Name = heroName
      obj.Tip = heroName
      -- obj.isbldg = 1
      obj.file = unitDefine.model
      obj.Upgrade = ""
      obj.upgrades = ""
      obj.abilList = ""
      obj.unitSound = ""
      obj.BuildingSoundLabel = ""
      obj.modelScale = unitDefine.modelSize
      obj.scale = unitDefine.scale
      obj.unitSadow = ""
      obj.buildingShadow = ""
      obj.shadowH = 180
      obj.shadowW = 180
      obj.shadowX = 75
      obj.shadowY = 75
      obj.uberSplat = ""
      obj.castpt = 0.3
      obj.castbsw = 0.15
      obj.orientInterp = 4
      obj.run = 300
      obj.walk = 300
      obj.movetp = "foot"
      obj.spd = 300
      obj.turnRate = 0.5
      obj.defType = "normal"
      obj.acquire = 900
      obj.defUp = 0
      obj.def = 0
      obj.armor = "Flesh"
      obj.targType = "ground"
      obj.Missileart = unitDefine.missleArt
      obj.Missilespeed = unitDefine.missileSpeed
      obj.atkType1 = "normal"
      obj.Missilearc = unitDefine.missileArc
      obj.MissileHoming = 1
      obj.weapTp1 = unitDefine.weapType
      obj.weapType1 = unitDefine.weapType1
      obj.Art = "ReplaceableTextures\\CommandButtons\\BTNPriest.blp"
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
      obj.regenHP = 0
      obj.targType = "ground,structure"
      obj.unitShadow = ""
      obj.walk = unitDefine.walk or 300
      obj.run = unitDefine.walk or 300
      obj.collision = 0

      if unitDefine.isFly == 1 then
          obj.unitShadow = "ShadowFlyer"
          obj.shadowH = 80
          obj.shadowW = 80
          obj.shadowX = 60
          obj.shadowY = 60
      end

    end

    ?>
    return
  endfunction

endlibrary

#endif
