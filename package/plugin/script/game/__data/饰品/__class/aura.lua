
-- extend accs part



local list = reg:getPool('heroAura')

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
                bind = 'origin',
                time = -1,
            }
            hero.auraEffect = fc.unitEffect(eff, hero)
            hero.auraEffectCfg = eff
        else
            if hero.auraEffect then
                fc.removeEffect(hero.auraEffect)
                hero.auraEffect = nil
            end
        end

        if exe then
            exe(self, isAdd)
        end
    end

end
--------------------------------------------------------------------------------------
