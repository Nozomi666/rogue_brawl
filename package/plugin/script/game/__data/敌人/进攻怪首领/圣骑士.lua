
local name = '圣骑士'

local mt = {

    name = name,

    unitType = 'w023',
    skill = {'圣骑士护甲光环'},
    eType = ENEMY_TYPE_BOSS,

    hp =  15,
    atk = 1,
    phyDef = 1,
    magDef = 1,

    moveSpeed = 250,
    range = 100,
    
    enemyCount = 1,



}


--------------------------------------------------------------------------------------
as.dataRegister:initTableData('enemyData', mt)