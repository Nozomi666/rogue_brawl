
-- extend accs part



local list = reg:getPool('wings')

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
                bind = 'chest',
                time = -1,
            }
            hero.wingsEffect = fc.unitEffect(eff, hero)
            hero.wingsEffectCfg = eff
        else
            if hero.wingsEffect then
                fc.removeEffect(hero.wingsEffect)
                hero.wingsEffect = nil
            end
        end

        if exe then
            exe(self, isAdd)
        end
    end

end
--------------------------------------------------------------------------------------
