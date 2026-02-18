


local mt = {}
mt.__index = mt

mt.callback = {
    -- 装备商店
    ['A049'] = {
        act = as.shop.buyEquip,
        gold = 400,
        lv = 1,
        shot = 1,
    },
    ['A04A'] = {
        act = as.shop.buyEquip,
        gold = 3600,
        lv = 3,
        shot = 1,
        rewardChance = 0.005,
    },
    ['A04B'] = {
        act = as.shop.buyEquip,
        gold = 32000,
        lv = 5,
        shot = 1,
        rewardChance = 0.02,
    },
    -- 十连
    ['A09C'] = {
        act = as.shop.buyEquip,
        gold = 400,
        lv = 1,
        shot = 10,
    },
    ['A09D'] = {
        act = as.shop.buyEquip,
        gold = 3600,
        lv = 3,
        shot = 10,
        rewardChance = 0.005,
    },
    ['A09E'] = {
        act = as.shop.buyEquip,
        gold = 32000,
        lv = 5,
        shot = 10,
        rewardChance = 0.02,
    },
    -- 技能商店
    ['A04C'] = {
        act = npc.skillShop.refreshSkillBook,
        lumb = 20,
        drawLv = 1,
        drawClass = cst.ST_STR,
    },
    ['A04D'] = {
        act = npc.skillShop.refreshSkillBook,
        lumb = 20,
        drawLv = 1,
        drawClass = cst.ST_AGI,
    },
    ['A04E'] = {
        act = npc.skillShop.refreshSkillBook,
        lumb = 20,
        drawLv = 1,
        drawClass = cst.ST_INT,
    },
    ['A04G'] = {
        act = npc.skillShop.refreshSkillBook,
        lumb = 100,
        drawLv = 2,
        drawClass = cst.ST_STR,
    },
    ['A04F'] = {
        act = npc.skillShop.refreshSkillBook,
        lumb = 100,
        drawLv = 2,
        drawClass = cst.ST_AGI,
    },
    ['A04T'] = {
        act = npc.skillShop.refreshSkillBook,
        lumb = 100,
        drawLv = 2,
        drawClass = cst.ST_INT,
    },
    ['A04U'] = {
        act = npc.skillShop.refreshSkillBook,
        lumb = 10,
        drawLv = 1,
        drawClass = cst.ST_ALL,
    },
    ['A04V'] = {
        act = npc.skillShop.refreshSkillBook,
        lumb = 50,
        drawLv = 2,
        drawClass = cst.ST_ALL,
    },

    -- 英雄按钮
    ['A05S'] = {
        act = as.hero.tryDeleteSkill,
    },
    ['A0A5'] = {
        act = as.maid.tryHoldMerge,
    },

    -- 科技
    ['R002'] = {
        act = as.player.heroTech,
    },
    ['R003'] = {
        act = as.player.heroTech,
    },

    ['R001'] = {
        act = as.player.goldTechFin,
    },
    ['R004'] = {
        act = as.player.goldTechFin,
    },

    ['R005'] = {
        act = as.player.lumTechFin,
    },
    ['R006'] = {
        act = as.player.lumTechFin,
    },

    -- 购买转职
    ['A05P'] = {
        act = as.shop.buyUpclass,
        gold = 1500,
        lum = 100,
        lv = 1,
    },
    ['A05Q'] = {
        act = as.shop.buyUpclass,
        gold = 4000,
        lum = 200,
        lv = 2,
    },
    ['A05R'] = {
        act = as.shop.buyUpclass,
        gold = 10000,
        lum = 300,
        lv = 3,
    },
    ['A0DA'] = {
        act = as.shop.buyUpclass,
        gold = 30000,
        lum = 400,
        lv = 4,
    },

    --购买解锁技能
    -- ['A0FG'] = {
    --     act = as.shop.buyUnlockSkill,
    --     gold = 2500,
    --     slot = 7,
    -- },
    -- ['A0FH'] = {
    --     act = as.shop.buyUnlockSkill,
    --     gold = 10000,
    --     slot = 8,
    -- },
}

-- not flex skill
function mt:castSpell(keys)
    local act = keys.cfg.act

    if act then
        act(keys.u, keys)
    end

end



return mt
