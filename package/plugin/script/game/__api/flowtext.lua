local mt = {}

local normalDmgTxtSize = 1
local critDmgTxtSize = 1.2
as.flowText = mt
--------------------------------------------------------------------------------------
function mt.printImmune(u, tgt)
    if u.removed or tgt.removed then
        return
    end

    if gm.bGameLost then
        return
    end

    -- mt.makeClassicFlowText({
    --     text = '|cfffff0ac免疫|r',
    --     point = fc.polarPoint(tgt:getloc(), math.random(20, 100), math.random(360)),
    --     size = 12,
    --     speed = 90,
    --     angle = math.random(40, 60),
    --     fadeTime = 1,
    --     time = 2
    -- })

    local hideText = as.player:getLocalPlayer().flowtextOff

    local point = as.point:getUnitLoc(tgt)
    local dest = as.point:polarPoint(point, math.random(50, 100),
        as.util:angleBetweenUnits(u, tgt) + math.random(-15, 15))
    -- local size, interval = 1, 40

    local eff = {
        model = hideText and '' or [[Mianyi.mdx]],
        size = 4.5,
        mustShow = true,
        isText = true,
    }
    as.effect:pointEffect(eff, dest)

end
--------------------------------------------------------------------------------------
function mt.printEvade(u, tgt)
    if u.removed or tgt.removed then
        return
    end

    -- mt.makeClassicFlowText({
    --     text = '|cffacffff闪避|r',
    --     point = fc.polarPoint(tgt:getloc(), math.random(20, 100), math.random(360)),
    --     size = 10,
    --     speed = 90,
    --     angle = math.random(40, 60),
    --     fadeTime = 1,
    --     time = 2
    -- })

    local hideText = as.player:getLocalPlayer().flowtextOff

    local point = as.point:getUnitLoc(tgt)
    local dest = as.point:polarPoint(point, math.random(50, 100),
        as.util:angleBetweenUnits(u, tgt) + math.random(-15, 15))
    local size, interval = 1, 40

    local place = as.point:polarPoint(dest, interval * 0, 0)
    local eff = {
        model = hideText and '' or [[shan.mdx]],
        size = size,
    }
    as.effect:pointEffect(eff, place)

    place = as.point:polarPoint(dest, interval * 1, 0)
    eff = {
        model = hideText and '' or [[bi.mdx]],
        size = size,
    }
    as.effect:pointEffect(eff, place)

end
--------------------------------------------------------------------------------------
function mt.printDmg(u, tgt, dmg, dmgType, isCrit)
    if u.removed or tgt.removed then
        return
    end

    if ALL_PLAYER_OFF_DMG_TEXT then
        return
    end

    local hideText = as.player:getLocalPlayer().flowtextOff
    -- if localEnv then
    --     hideText = false
    -- end

    -- if not isCrit then

    --     local space1 = math.random(20, 100)
    --     local space2 = math.random(360)
    --     local ang = math.random(75, 105)

    --     if not hideText then
    --         mt.makeClassicFlowText({
    --             text = str.format('|cffffffff%s|r', ConvertBigNumberToText(dmg)),
    --             -- point = fc.polarPoint(tgt:getloc(), 60, 30),
    --             point = fc.polarPoint(tgt:getloc(), space1, space2),
    --             size = 10,
    --             speed = 90,
    --             angle = ang,
    --             fadeTime = 1,
    --             time = 2,
    --         })
    --     end

    --     return
    -- end

    if (not isCrit) and (not localEnv) then
        if not (GetPlayerController(tgt:getJPlayer()) == MAP_CONTROL_USER) then
            return
        end
    end

    local showVal = dmg
    local postFix = nil

    if showVal >= 1000000000 then
        showVal = showVal // 100000000
        postFix = 12

    elseif showVal >= 100000 then
        showVal = showVal // 10000
        postFix = 11
    end

    showVal = str.format('%.0f', showVal)

    local len = string.len(showVal)

    local point = as.point:getUnitLoc(tgt)
    local dest = as.point:polarPoint(point, math.random(50, 100),
        as.util:angleBetweenUnits(u, tgt) + math.random(-15, 15))

    local color, size, interval
    local p
    interval = 23.5

    if not (GetPlayerController(tgt:getJPlayer()) == MAP_CONTROL_USER) then
        -- enemy damaged
        p = u:getPlayer()
        -- if p.flowtextOff == true then
        --     return
        -- end

        if dmgType == DMG_TYPE_PHYSICAL then
            if not isCrit then
                color = 1
                size = normalDmgTxtSize
                interval = 25
            else
                color = 5
                size = critDmgTxtSize
                interval = 35
            end

        else
            if not isCrit then
                color = 3
                size = normalDmgTxtSize
                interval = 25
            else
                color = 7
                size = critDmgTxtSize
                interval = 35
            end
        end

        -- if p.flowTextCount > 10 then
        --     return
        -- end
        -- p.flowTextCount = p.flowTextCount + 1

    else
        -- player damaged
        p = tgt:getPlayer()
        -- if p.flowtextOff == true then
        --     return
        -- end

        color = 4
        if not isCrit then
            size = normalDmgTxtSize
            interval = 30
        else
            size = critDmgTxtSize
            interval = 40
        end

        interval = 35

    end

    -- color = 4
    -- interval = 30

    for i = 1, len do
        local num = tonumber(str.sub(showVal, i, i))
        local place = as.point:polarPoint(dest, interval * i, 0)
        local eff = {
            model = hideText and '' or cst.FLOW_TEXT[color][num],
            size = size,
            mustShow = true,
            isText = true,
        }
        as.effect:pointEffect(eff, place)
    end

    if postFix then
        local place = as.point:polarPoint(dest, interval * (len + 1), 0)
        local eff = {
            model = hideText and '' or cst.FLOW_TEXT[color][postFix],
            size = size,
            mustShow = true,
            isText = true,
        }
        as.effect:pointEffect(eff, place)
    end

    if isCrit then
        local place = as.point:polarPoint(dest, interval * -0.3, 0)
        local eff = {
            model = hideText and '' or cst.FLOW_TEXT[color][10],
            size = size * 1,
            mustShow = true,
            isText = true,
        }
        as.effect:pointEffect(eff, place)
    end

end
--------------------------------------------------------------------------------------
function mt.printHeal(u, tgt, dmg, dmgType, isCrit)

    if u.removed or tgt.removed then
        return
    end

    if dmg < 1 then
        return
    end

    -- if (GetPlayerController(tgt:getJPlayer()) == MAP_CONTROL_USER) then
    --     local p = u:getPlayer()
    --     if p.flowTextCount > 10 then
    --         return
    --     end
    --     p.flowTextCount = p.flowTextCount + 1
    -- end

    local color = 2
    local size = normalDmgTxtSize
    local interval = 25

    local dest = tgt:getloc()
    local showVal = dmg
    local postFix = nil
    local hideText = as.player:getLocalPlayer().flowtextOff

    -- if showVal >= 1000000000 then
    --     showVal = showVal // 100000000
    --     postFix = 12

    -- elseif showVal >= 100000 then
    --     showVal = showVal // 10000
    --     postFix = 11
    -- end

    showVal = str.format('%.0f', showVal)

    local len = string.len(showVal)

    local place = as.point:polarPoint(dest, interval * -0.3, 0)
    local eff = {
        model = hideText and '' or cst.FLOW_TEXT[color][10],
        size = size * 1,
        mustShow = true,
        isText = true,
    }
    as.effect:pointEffect(eff, place)

    for i = 1, len do
        local num = tonumber(str.sub(showVal, i, i))
        local place = as.point:polarPoint(dest, interval * i, 0)
        local eff = {
            model = hideText and '' or cst.FLOW_TEXT[color][num],
            size = size,
            mustShow = true,
            isText = true,
        }
        as.effect:pointEffect(eff, place)
    end

    if postFix then
        local place = as.point:polarPoint(dest, interval * (len + 1), 0)
        local eff = {
            model = hideText and '' or cst.FLOW_TEXT[color][postFix],
            size = size,
            mustShow = true,
            isText = true,
        }
        as.effect:pointEffect(eff, place)
    end

end
--------------------------------------------------------------------------------------
function mt.printGold(dest, amt)

    --gdebug('printGold 1111')
    if ALL_PLAYER_OFF_RES_TEXT then
        return
    end
    --gdebug('printGold 2222')
    local showVal = amt
    local hideText = as.player:getLocalPlayer().flowEcoTextOff
    showVal = str.format('%.0f', showVal)
    local len = string.len(showVal)
    local interval = 28
    local size = 1.2

    local screenLv = glo.udg_playerCameraLv[as.player:getLocalPlayer().id]
    interval = 5 + (interval - 5) * (0 + (screenLv / 24))

    -- dest = fc.polarPoint(dest, 50, math.random(235, 305))
    dest = fc.polarPoint(dest, 50, 90)
    local place = as.point:polarPoint(dest, 3 + (18 - 3) * (0 + (screenLv / 24)), 0)
    -- local eff = {
    --     model = hideText and '' or cst.FLOW_TEXT[6][10],
    --     size = size,
    --     mustShow = true,
    --     isText = true,
    -- }
    -- as.effect:pointEffect(eff, place)

    -- local flowTextUI = class.flowtext_number.add_child(MAIN_UI, 'Dawn_gold1.blp', 24, 24)

    if not hideText then
        -- gdebug('printGold 3333')
        local flowTextUI = class.flowtext_number.add_child(MAIN_UI, [[gold_icon.tga]], 24, 24)

        flowTextUI:set_world_position(place[1], place[2], 0)

        for i = 1, len do
            local num = tonumber(str.sub(showVal, i, i))

            local texture = str.format('Dawn_G%d.blp', num)
            local place = as.point:polarPoint(dest, interval * (i + 1), 0)
            -- local eff = {
            --     model = hideText and '' or cst.FLOW_TEXT[6][num],
            --     size = size,
            --     mustShow = true,
            --     isText = true,
            -- }
            -- as.effect:pointEffect(eff, place)
            local flowTextUI = class.flowtext_number.add_child(MAIN_UI, texture, 24, 24)
            flowTextUI:set_world_position(place[1], place[2], 0)
            flowTextUI:hide()

        end
    end

end
--------------------------------------------------------------------------------------
function mt.printLumber(dest, amt)

    if true then
        return
    end

    if amt < 1 then
        return
    end

    if ALL_PLAYER_OFF_RES_TEXT then
        return
    end

    local showVal = amt
    local hideText = as.player:getLocalPlayer().flowEcoTextOff
    showVal = str.format('%.0f', showVal)
    local len = string.len(showVal)
    local interval = 28
    local size = 1.2

    dest = fc.polarPoint(dest, 50, math.random(235, 305))
    local place = as.point:polarPoint(dest, interval * 0 + 18, 0)
    -- local eff = {
    --     model = hideText and '' or cst.FLOW_TEXT[6][10],
    --     size = size,
    --     mustShow = true,
    --     isText = true,
    -- }
    -- as.effect:pointEffect(eff, place)

    -- local flowTextUI = class.flowtext_number.add_child(MAIN_UI, 'dawn_zy1.blp', 24, 24)
    if not hideText then
        local flowTextUI = class.flowtext_number.add_child(MAIN_UI, 'ResourceLumber.tga', 24, 24)

        flowTextUI:set_world_position(place[1], place[2], 0)

        for i = 1, len do
            local num = tonumber(str.sub(showVal, i, i))

            local texture = str.format('Dawn_%dz.tga', num)
            local place = as.point:polarPoint(dest, interval * (i + 1), 0)
            -- local eff = {
            --     model = hideText and '' or cst.FLOW_TEXT[6][num],
            --     size = size,
            --     mustShow = true,
            --     isText = true,
            -- }
            -- as.effect:pointEffect(eff, place)
            local flowTextUI = class.flowtext_number.add_child(MAIN_UI, texture, 24, 24)
            flowTextUI:set_world_position(place[1], place[2], 0)

        end
    end

end
--------------------------------------------------------------------------------------
function mt.printCrystal(dest, amt)

    if true then
        return
    end
    local showVal = amt
    local hideText = as.player:getLocalPlayer().flowEcoTextOff
    showVal = str.format('%.0f', showVal)
    local len = string.len(showVal)
    local interval = 28
    local size = 1.2

    dest = fc.polarPoint(dest, 100, math.random(75, 105))
    local place = as.point:polarPoint(dest, interval * 0 + 18, 0)
    -- local eff = {
    --     model = hideText and '' or cst.FLOW_TEXT[6][10],
    --     size = size,
    --     mustShow = true,
    --     isText = true,
    -- }
    -- as.effect:pointEffect(eff, place)

    local flowTextUI = class.flowtext_number.add_child(MAIN_UI, 'dawn_sj1.tga', 24, 24)
    flowTextUI:set_world_position(place[1], place[2], 0)

    for i = 1, len do
        local num = tonumber(str.sub(showVal, i, i))

        local texture = str.format('Dawn_cj_%dz.tga', num)
        local place = as.point:polarPoint(dest, interval * (i + 1), 0)
        -- local eff = {
        --     model = hideText and '' or cst.FLOW_TEXT[6][num],
        --     size = size,
        --     mustShow = true,
        --     isText = true,
        -- }
        -- as.effect:pointEffect(eff, place)
        local flowTextUI = class.flowtext_number.add_child(MAIN_UI, texture, 24, 24)
        flowTextUI:set_world_position(place[1], place[2], 0)

    end

end
--------------------------------------------------------------------------------------
-- keys = {
--     text,     文本
--     point,    出现位置
--     size,     大小
--     speed,    出现速度
--     angle,    角度
--     fadeTime, 渐隐时间
--     time,     持续时间
-- }
function mt.makeClassicFlowText(keys)
    local x, y = keys.point:get()
    CreateTextTagLocBJ(keys.text, glo.udg_mapCenter, 0, keys.size, 0, 100, 100, 0)
    SetTextTagPos(bj_lastCreatedTextTag, x, y, 0)
    SetTextTagPermanent(GetLastCreatedTextTag(), false)
    SetTextTagVelocityBJ(GetLastCreatedTextTag(), keys.speed, keys.angle)
    if keys.fadeTime > 0 then
        SetTextTagFadepoint(GetLastCreatedTextTag(), keys.fadeTime)
    end
    if keys.time > 0 then
        SetTextTagLifespan(GetLastCreatedTextTag(), keys.time)
    end
    local flowtext = GetLastCreatedTextTag()
    if keys.isLocal then
        ShowTextTagForceBJ(false, GetLastCreatedTextTag(), GetPlayersAll())
        ShowTextTagForceBJ(true, GetLastCreatedTextTag(), as.player:getLocalPlayer().flowTextHandle)
    end
    if keys.time > 0 then
        ac.timer(ms(keys.time + 0.01), 1, function()
            DestroyTextTag(flowtext)
        end)
    end

    return flowtext
end
--------------------------------------------------------------------------------------
return mt
