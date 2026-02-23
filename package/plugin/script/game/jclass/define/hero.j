#ifndef HeroDefineDef 
#define HeroDefineDef 

library HeroDefine 

    <? 
  
    G_HeroDefine = {
  ["1"] = {
    name = "盗贼",
    art = "ReplaceableTextures\\CommandButtons\\BTNBandit.blp",
    model = "units\\creeps\\BanditSpearThrower\\BanditSpearThrower.mdl",
    modelSize = "1.25",
    atkType1 = "pierce",
    weapType = "instant"
  }
}
  
    ?> 
    function HeroDefineInit takes nothing returns nothing 
    endfunction 

endlibrary 

#endif 
