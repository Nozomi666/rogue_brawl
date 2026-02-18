#ifndef MaidSkillDefineDef 
#define MaidSkillDefineDef 

library MaidSkillDefine 

  <? 
  
  G_MaidSkillDefine = {
  ["1"] = {
    Name = "拾起物品",
    DataF1 = "ambush",
    DataB1 = 2,
    DataC1 = 3,
    HotKey = "Q",
    Buttonpos = 0,
    Buttonpos2 = 0,
    Art = "ReplaceableTextures\\CommandButtons\\BTNPickUpItem.blp",
    targs1 = "enemies,vulnerable,friend",
    Animnames = "spell",
    Rng1 = 3000,
    Area1 = 300
  },
  ["2"] = {
    Name = "丢弃物品",
    DataF1 = "ancestralspirit",
    DataB1 = 2,
    DataC1 = 1,
    HotKey = "W",
    Buttonpos = 1,
    Buttonpos2 = 0,
    Art = "ReplaceableTextures\\CommandButtons\\BTNAttackGround.blp",
    targs1 = "enemies,vulnerable,friend",
    Animnames = "spell",
    Rng1 = 3000,
    Area1 = 0
  },
  ["3"] = {
    Name = "合成物品",
    DataF1 = "ancestralspirittarget",
    DataB1 = 0,
    DataC1 = 1,
    HotKey = "E",
    Buttonpos = 2,
    Buttonpos2 = 0,
    Art = "ReplaceableTextures\\CommandButtons\\BTNMagicImmunity.blp",
    targs1 = "enemies,vulnerable,friend",
    Animnames = "spell",
    Rng1 = 3000,
    Area1 = 0
  },
  ["4"] = {
    Name = "合成物品（地面）",
    DataF1 = "animatedead",
    DataB1 = 2,
    DataC1 = 3,
    HotKey = "R",
    Buttonpos = 3,
    Buttonpos2 = 0,
    Art = "ReplaceableTextures\\CommandButtons\\BTNMagicImmunity.blp",
    targs1 = "enemies,vulnerable,friend",
    Animnames = "spell",
    Rng1 = 3000,
    Area1 = 300
  },
  ["5"] = {
    Name = "停止",
    DataF1 = "stop",
    DataB1 = 0,
    DataC1 = 1,
    HotKey = "S",
    Buttonpos = 1,
    Buttonpos2 = 0,
    Art = "ReplaceableTextures\\CommandButtons\\BTNfangyu.blp",
    targs1 = "enemies,vulnerable,friend",
    Animnames = "stand",
    Rng1 = 3000,
    Area1 = 0
  },
  ["6"] = {
    Name = "整理物品",
    DataF1 = "auraunholy",
    DataB1 = 0,
    DataC1 = 1,
    HotKey = "V",
    Buttonpos = 3,
    Buttonpos2 = 2,
    Art = "ReplaceableTextures\\CommandButtons\\BTNCallToArms.blp",
    targs1 = "enemies,vulnerable,friend",
    Animnames = "stand",
    Rng1 = 3000,
    Area1 = 0
  }
}
  
  ?> 
  function MaidSkillDefineInit takes nothing returns nothing 
  endfunction 

endlibrary 

#endif 
