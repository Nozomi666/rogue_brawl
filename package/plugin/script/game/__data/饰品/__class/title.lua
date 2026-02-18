-- extend accs part
local list = reg:getPool('title')

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

        gdebug('toggle title')
        if isAdd then
            gdebug('toggle title add')
            -- local eff = {
            --     model = mt.model,
            --     bind = 'overhead',
            --     time = -1,
            -- }
            -- hero.titleEffect = fc.unitEffect(eff, hero)
            -- hero.titleEffectCfg = eff

            if hero.titleEffect then
                as.effect:setHeight(hero.titleEffect, 9999)
                fc.removeEffect(hero.titleEffect)
                hero.titleEffect = nil
            end

            if hero.titleEffectTimer then
                hero.titleEffectTimer:remove()
                hero.titleEffectTimer = nil
            end

            local eff = {
                model = mt.model,
                time = -1,
                size = 1.75,
            }
            local height = 230
            if mt.offsetY then
                height = height + mt.offsetY
            end
            -- hero.titleEffect = fc.pointEffect(eff, fc.polarPoint(hero:getloc(), 230, 90))
            hero.titleEffect = fc.pointEffect(eff, hero:getloc())
            as.effect:setHeight(hero.titleEffect, height)

            hero.titleEffectTimer = ac.loop(ms(0.03), function(t)
                if hero:isDead() then
                    as.effect:setHeight(hero.titleEffect, 9999)
                else
                    -- as.effect:setHeight(hero.titleEffect, 0)
                    as.effect:setHeight(hero.titleEffect, height)
                    as.effect:moveEffect(hero.titleEffect, hero:getloc())
                    -- as.effect:moveEffect(hero.titleEffect, fc.polarPoint(hero:getloc(), 230, 90))
                end

            end)

        else
            if hero.titleEffect then
                as.effect:setHeight(hero.titleEffect, 9999)
                fc.removeEffect(hero.titleEffect)
                hero.titleEffect = nil
            end

            if hero.titleEffectTimer then
                hero.titleEffectTimer:remove()
                hero.titleEffectTimer = nil
            end

        end

        if exe then
            exe(self, isAdd)
        end
    end

end
--------------------------------------------------------------------------------------
