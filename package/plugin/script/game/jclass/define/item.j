#ifndef ItemDefineDef 
#define ItemDefineDef 

library ItemDefine 

    <? 
  
    G_ItemDefine ={
  ["1"] = {
    Name = "威能宝石",
    abilList = "q001",
    Art = "ReplaceableTextures\\CommandButtons\\BTNqiyizhongzi.blp",
    file = "Objects\\InventoryItems\\TreasureChest\\treasurechest.mdl",
    scale = "1",
    powerup = 0,
    uses = 1,
    usable = 1,
    colorR = 255,
    colorG = 255,
    colorB = 255
  },
  ["2"] = {
    Name = "上锁的格子",
    abilList = "q001",
    Art = "ReplaceableTextures\\CommandButtons\\BTNqiyizhongzi.blp",
    file = "Objects\\InventoryItems\\TreasureChest\\treasurechest.mdl",
    scale = "1",
    powerup = 0,
    uses = 0,
    usable = 0,
    colorR = 255,
    colorG = 255,
    colorB = 255
  }
}

  
    ?> 
    function ItemDefineInit takes nothing returns nothing 
    endfunction 

endlibrary 

#endif 
