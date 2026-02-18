#ifndef ItemSkillDefineDef 
#define ItemSkillDefineDef 

library ItemSkillDefine 

  <? 
  
  G_ItemSkillDefine = {
  ["1"] = {
    Name = "物品空技能",
    Origin = "Aefk",
    Art = "ReplaceableTextures\\CommandButtons\\BTNPickUpItem.blp",
    targs1 = "wall",
    Cool1 = "0",
    Rng1 = 0,
    Area1 = 0
  }
}
  
  ?> 
  function ItemSkillDefineInit takes nothing returns nothing 
  endfunction 

endlibrary 

#endif 
