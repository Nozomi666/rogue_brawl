-- extend accs part
local list = reg:getPool('maidSkin')

for _, mt in ipairs(list) do

    --------------------------------------------------------------------------------------
    local exe = mt.onToggle
    function mt:onToggle(isAdd)

        local p = self.p
        local maid = p.maid
        local hero = p.hero

        if isAdd then

            if mt.replaceUnitType then
                local replaceUnitType = mt.replaceUnitType
                dz.DzSetUnitID(maid.handle, ID(replaceUnitType))
                japi.SetUnitModel(maid.handle, mt.model)
                japi.SetUnitName(maid.handle, mt.name)
                japi.SetUnitScale(maid.handle, 1, 1, 1)
            else
                dz.DzSetUnitID(maid.handle, ID([[e001]]))
                japi.SetUnitModel(maid.handle, mt.model)
                japi.SetUnitName(maid.handle, mt.name)

                if mt.modelSize then
                    SetUnitScale(maid.handle, mt.modelSize, mt.modelSize, mt.modelSize)
                else
                    SetUnitScale(maid.handle, 1, 1, 1)
                end

            end

        else
            dz.DzSetUnitID(maid.handle, ID([[e001]]))
            japi.SetUnitModel(maid.handle, [[1 (37).mdl]])
            japi.SetUnitName(maid.handle, [[助手]])
            SetUnitScale(maid.handle, 1, 1, 1)
        end

        if exe then
            exe(self, isAdd)
        end

    end

end
--------------------------------------------------------------------------------------
