
local name = '重型小怪'

local mt = {

    name = name,

    unitType = 'w006',
    -- skill = {'骨态重组'},
    eType = ENEMY_TYPE_NORMAL,

    hp =  1,
    atk = 1,
    phyDef = 1,
    magDef = 1,

    moveSpeed = 150,
    range = 100,
    
    enemyCount = 1,



}


--------------------------------------------------------------------------------------
as.dataRegister:initTableData('enemyData', mt)