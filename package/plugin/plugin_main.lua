
local path = ''

local bool, res = pcall(require, 'path')
console = require 'jass.console'

print = console.write 

if res then 
    console.enable = true
    print('本地路径----')
    localEnv = true

else 
    print('地图内路径')
end
print('初始化')
xpcall(function ()
    -- local jass = require 'jass.common'

    -- local TriggerAddAction = jass.TriggerAddAction 
    -- rawset(jass, 'TriggerAddAction', function (trg, action)
    --     local ret = TriggerAddAction(trg, function ()
            
    --         action()
    --     end) 
    --     return ret 
    -- end)

    require 'script'
end, function (msg)
    print(msg, '\n', debug.traceback())
end)

local japi = require 'jass.japi'

japi.SetOwner('问号')


