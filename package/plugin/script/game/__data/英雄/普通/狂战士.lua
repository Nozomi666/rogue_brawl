local mt = {}
mt.__index = mt

mt.name = '狂战士'
mt.range = 500

mt.model = [[units\nightelf\Huntress\Huntress.mdx]]
mt.modelSize = 1.4


--------------------------------------------------------------------------------------
-- custom hero stats field


--------------------------------------------------------------------------------------
reg:initHero(mt)

return mt

