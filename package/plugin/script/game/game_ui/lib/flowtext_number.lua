--------------------------------------------------------------------------------------
class.flowtext_number = extends(class.panel) {

    elementList = linked.create(),

    new = function(parent, texture, w, h)

        local height = 200

        local panel = class.panel.new(parent, nil, 0, 0, w, h)
        -- 改变panel对象的类
        panel.__index = class.flowtext_number
        panel.actualTexture = panel:add_texture(texture, 0, 0, w, h)


        class.flowtext_number.elementList:add(panel)
        panel.animProgress = 0

        return panel
    end,

    updateAllBoard = function()

        local elementList = class.flowtext_number.elementList
        local element = elementList:at(1)

        -- gdebug('updateAllBoard, elemlist size: %d', #elementList)
        local count = 0
        while element do

            count = count + 1

            element.animProgress = element.animProgress + 0.03

            if element.is_show then
                if element.animProgress > 0.5 then
                    element:set_alpha(1 - (element.animProgress - 0.5) / 0.5)
                end
    
                fc.setFramePos(element.actualTexture, ANCHOR.TOP_CENTER, element.actualTexture, ANCHOR.TOP_CENTER, 0, -1)
            end

            if element.animProgress > 1 then
                elementList:remove(element)
                element:destroy()
            end

            element = elementList:next(element)
        end
        -- print('update all hpbar')
    end,

}
--------------------------------------------------------------------------------------
local mt = class.flowtext_number
--------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------
