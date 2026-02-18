
-- extend accs part



local list = reg:getPool('tail')

for _, mt in ipairs(list) do

    --------------------------------------------------------------------------------------
    local exe = mt.onToggle
    function mt:onToggle(isAdd)

        local p = self.p
        local maid = p.maid
        local hero = p.hero
        if not hero then
            return
        end
    
        if isAdd then
            local eff = {
                model = mt.model,
                bind = mt.bind,
                time = -1,
            }
            hero.tailEffect = fc.unitEffect(eff, hero)
            hero.tailEffectCfg = eff
        else
            if hero.tailEffect then
                fc.removeEffect(hero.tailEffect)
                hero.tailEffect = nil
            end
        end

        if exe then
            exe(self, isAdd)
        end
    end

end
--------------------------------------------------------------------------------------
