require 'base.init'
str = string

jass = require 'jass.common'
hook = require 'jass.hook'
slk = require 'jass.slk'
glo = require 'jass.globals'
japi = require 'jass.japi'
code = require 'jass.code'
dz = require 'jass.dzapi'
dbg = require 'jass.debug'
message = require 'jass.message'

code.Gb2312_Init()

require('game.__config.prestart')

-- 加载jass
print('[Init] - custom game init')

as = {}
npc = {}
cg = {}

--------------------------------------------------------------------------------------
-- 批量生成物编
-- code.ItemkSkillBookInit()
-- code.MakeSkillModel()
code.ItemEquipInit()
-- code.CharmStoneInit()

--------------------------------------------------------------------------------------
-- 运行全局变量？
-- ConditionalTriggerExecute(glo.gg_trg_Cfg___Glo_Val)



-- 工具
require 'ac.utility'
require 'ac.selector'
book = require 'tool.book'

ac.point = require 'ac.point'
as.util = require 'as.utility'
require 'as.lv_chart'
linked = require 'tool.linked'
require 'tool.泄露检测_1_22'


--------------------------------------------------------------------------------------
-- handle数据表
require 'as.table_registry'

-- 常数
algo = require('game.__api.algorithms')
enc = require 'tool.enc'
require('game.__config.define')
require('game.__config.const')
require('game.__config.arch_storage')
sef = require('game.__config.sef')

-- 游戏内api
ac.lightning = require 'ac.lightning'
ac.lightning.init()

require 'game.__api.code'
sound = require 'game.__api.sound'
require 'game.__api.summon'
as.ability = require 'game.__api.ability'
as.command = require 'game.__api.command'
as.message = require 'game.__api.message'
msg = as.message
require 'game.__api.misc'

-- 加载数据
as.dataRegister = require 'game.__data.registry'
reg = as.dataRegister
require('game.__config.combo_setting')

as.test = require 'game.__api.test_custom'
test = as.test
require('game.client')

require 'game.class.custom.player'

require 'game.class.base.buff'
require 'game.class.base.weight_pool'
require 'game.class.base.item'

as.point = require 'ac.point'
as.effect = require 'as.effect'
as.castHelper = require 'game.class.cast_helper'
as.flowText = require 'game.__api.flowtext'


as.accs = require 'game.class.manager.accs'
as.accsManager = require 'game.class.manager.accs_manager'

-- 游戏管理
require 'game.class.manager.event_manager'
require 'game.class.manager.projectile_manger'


require 'game.__data'
require 'game.game_ui'

-- 循环器
require 'game.class.manager.loop_manager'

hotfix = require '热更新'

require 'game.script.awake'
require 'game.__api.test_hotkeys'
