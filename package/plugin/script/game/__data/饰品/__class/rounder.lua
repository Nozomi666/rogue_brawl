
-- extend accs part



local list = reg:getPool('rounder')

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
                bind = mt.bind or 'chest',
                time = -1,
            }
            hero.rounderEffect = fc.unitEffect(eff, hero)
            hero.rounderEffectCfg = eff
        else
            if hero.rounderEffect then
                fc.removeEffect(hero.rounderEffect)
                hero.rounderEffect = nil
            end
        end

        if exe then
            exe(self, isAdd)
        end
    end

end
--------------------------------------------------------------------------------------
