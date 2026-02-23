local mt = {}
mt.__index = mt

mt.name = '传奇盗贼'
mt.objId = 1
mt.range = 700
mt.art = [[ReplaceableTextures\CommandButtons\BTNArcher.blp]]
--------------------------------------------------------------------------------------
mt.bulletModel = [[Abilities\Weapons\MoonPriestessMissile\MoonPriestessMissile.mdl]]
mt.bulletHeight = 50
mt.bulletSize = 1
mt.bulletOffsetX = 100
mt.bulletSpeed = 1500
mt.bulletHitRange = 80
mt.bulletAngle = 0
mt.fixedBulletHeight = true
--------------------------------------------------------------------------------------
mt.mainStatsType = ST_AGI

mt.baseStr = 10
mt.baseAgi = 10
mt.baseInt = 10

mt.growStr = 0
mt.growAgi = 0
mt.growInt = 0
mt.talentName = '初心箭术'
--------------------------------------------------------------------------------------
-- custom hero stats field

--------------------------------------------------------------------------------------
reg:initHero(mt)

return mt

