local dzapi = require 'jass.dzapi'

local mt = {}
arch = mt

mt.maxSlot = {}

mt.maxSlotNum = 10
mt.maxSlotBool = 190

mt.archData = {
    [1] = {},
    [2] = {},
    [3] = {},
    [4] = {},
}
mt.platformIdTable = {
    [1] = nil,
    [2] = nil,
    [3] = nil,
    [4] = nil,
}
--------------------------------------------------------------------------------------
mt.getPlayerPlatformId = function(pHandle)
    local pId = GetConvertedPlayerId(pHandle)

    return mt.platformIdTable[pId]
    -- return 10000
end

--------------------------------------------------------------------------------------
mt._loadData = function(pHandle, archName)
    if (not pHandle) or (not archName) then
        gdebug('load data fail, no phandle or archname ')
        return ''
    end

    local data = code.loadServerString(pHandle, archName)

    if str.len(data) == 0 then
        gdebug('load data empty, str length 0')
        return ''
    end

    local platformId = mt.getPlayerPlatformId(pHandle)

    if platformId == nil then
        gdebug('platform id is nil, return do not load')
        BJDebugMsg('有玩家读取平台ID失败，请勿开始本局游戏以避免丢档。' ..
                       GetPlayerName(pHandle))
    end

    local key = enc.getKey(platformId, archName)
    local pName = GetPlayerName(pHandle)

    local cypherData, hmacGet = enc.decapMsg(data, key)
    local hmacMake = enc.getHmac(cypherData, key)

    -- gdebug('hmacGet: ' .. hmacGet)

    -- gdebug('hmacMake: ' .. hmacMake)

    -- 长情久伴丶#5982
    local platformName = japi.RequestExtraStringData(81, pHandle, nil, nil, false, 0, 0, 0)
    if localEnv then
        platformName = [[WorldEdit]]
    end
    if ARCH_WHITE_LIST[platformName] then
        gdebug('trigger ignore hmac')
        hmacGet = 0
        hmacMake = 0
    end

    if hmacGet ~= hmacMake then
        BJDebugMsg(str.format('存档错误：验证玩家 [%s] 档位 [%s] 数据完整性失败。', pName, archName))
        fc.setAttr(pHandle, archName .. 'loadFail', true)
        -- DisplayTimedTextToPlayer(pHandle, 0, 0, 60, '|cffff0000警告：|r继续游戏可能造成存档丢失。')

        xpcall(function()
            print('pName: ')
            print(pName)

            print('archName: ')
            print(archName)

            print('data: ')
            print(data)

            print('key: ')
            print(key)

            print('cypherData: ')
            print(cypherData)

            print('hmacGet: ')
            print(hmacGet)

            print('hmacMake: ')
            print(hmacMake)

            local plainData = enc.decryptBase64(cypherData, key)
            print('plain data: ')
            print(plainData)
        end, traceError)

        return ''
    end

    local plainData = enc.decryptBase64(cypherData, key)

    -- gdebug('plain data: ')
    -- gdebug(plainData)

    -- gdebug('load data success: ' .. plainData)

    return plainData
end
--------------------------------------------------------------------------------------
mt.saveData = function(pHandle, archName, data)
    if (not pHandle) or (not archName) or (not data) then
        return false
    end

    local platformId = mt.getPlayerPlatformId(pHandle)
    local pName = GetPlayerName(pHandle)

    if platformId == nil then
        gdebug('platform id is nil, return do not load')
        BJDebugMsg('储存错误；有玩家读取平台ID失败，请勿开始本局游戏以避免丢档。' ..
                       GetPlayerName(pHandle))
    end

    local key = enc.getKey(platformId, archName)
    local cypherData = enc.encryptBase64(data, key)

    local encaped = enc.encapMsg(cypherData, key)

    local hmacMake = enc.getHmac(cypherData, key)
    local cypherDataDecap, hmacGet = enc.decapMsg(encaped, key)

    if hmacMake ~= hmacGet then
        BJDebugMsg(str.format('存档错误：校验玩家 [%s] 档位 [%s] 新生成的数据完整性失败。',
            pName, archName))
        DisplayTimedTextToPlayer(pHandle, 0, 0, 60, '|cffff0000注意：|r请将相关情况报告给作者。')
        print(str.format('-----------CRITICAL ERROR-----------'))
        print('playername: ', pName)
        print('archName: ', archName)
        -- print('key: ', key)
        print('cypherData: ', cypherData)
        print('encaped: ', encaped)
        print('hmacMake: ', hmacMake)
        print('hmacGet: ', hmacGet)
        -- print('cypherDataDecap: ', cypherDataDecap)
        return
    end

    if fc.getAttr(pHandle, archName .. 'loadFail') then
        BJDebugMsg(str.format(
            '未储存玩家 [%s] 档位 [%s] 新生成的数据，因为加载时验证完整性失败。', pName,
            archName))
        return
    end

    code.saveServerString(pHandle, archName, encaped)
end
--------------------------------------------------------------------------------------
mt.loadNum = function(pHandle, archName)

    gdebug('load num arch list : ' .. archName)
    local msg = mt._loadData(pHandle, archName)
    local pName = GetPlayerName(pHandle)
    local maxSlot = mt.maxSlotNum

    for i = 1, maxSlot do
        mt.saveArch(pHandle, archName, i, 0)
    end

    if str.len(msg) == 0 then
        return true
    end

    if str.len(msg) % 3 ~= 0 then
        BJDebugMsg(str.format('存档错误：验证玩家 [%s] 档位 [%s] 数字存档完整性失败。', pName,
            archName))
        return false
    end

    if str.len(msg) / 3 > maxSlot then
        BJDebugMsg(str.format('存档错误：验证玩家 [%s] 档位 [%s] 数字存档完整性失败。', pName,
            archName))
        return false
    end

    local index = 1
    for i = 1, str.len(msg) / 3 do
        local chunk = str.sub(msg, index, index + 2)
        plainGdebug('load chunck: ' .. chunk)
        local num = code.s2R(chunk)
        gdebug('load num: ' .. num)

        mt.saveArch(pHandle, archName, i, num)

        index = index + 3
    end

    return true
end
--------------------------------------------------------------------------------------
mt.saveNum = function(pHandle, archName)
    local maxSlot = mt.maxSlotNum
    local msg = ''

    for i = 1, maxSlot do
        local data = mt.loadArch(pHandle, archName, i)
        if not data then
            data = 0
        end

        data = tonumber(data)
        if data > 778687 then
            data = 778687
        end

        local chunk = code.R2s(data)
        msg = msg .. chunk
        plainGdebug('save chunck: ' .. chunk)
    end

    mt.saveData(pHandle, archName, msg)

end
--------------------------------------------------------------------------------------
mt.loadBool = function(pHandle, archName)

    gdebug('load bool arch list : ' .. archName)

    local maxSlot = mt.maxSlotBool
    local msg = mt._loadData(pHandle, archName)
    local pName = GetPlayerName(pHandle)

    if str.len(msg) == 0 then
        return true
    end

    if str.len(msg) % 3 ~= 0 then
        print('load bool fail 1')
        BJDebugMsg(str.format('存档错误：验证玩家 [%s] 档位 [%s] 真值存档完整性失败。', pName,
            archName))
        return false
    end

    if str.len(msg) / 3 > maxSlot then
        print('load bool fail 2')
        BJDebugMsg(str.format('存档错误：验证玩家 [%s] 档位 [%s] 真值存档完整性失败。', pName,
            archName))
        return false
    end

    local index = 1
    local slot = 1
    for i = 1, str.len(msg) / 3 do
        local chunk = str.sub(msg, index, index + 2)
        -- gdebug('load chunck: ' .. chunk)
        local num = code.s2R(chunk)
        -- gdebug('load num: ' .. num)

        local bools = code.R2B(num)
        -- gdebug('load bools: ' .. num)

        for j = 1, str.len(bools) do
            if str.sub(bools, j, j) == '1' then
                mt.saveArch(pHandle, archName, slot, true)
            else
                mt.saveArch(pHandle, archName, slot, false)
            end
            slot = slot + 1
        end

        index = index + 3
    end

    return true
end
--------------------------------------------------------------------------------------
mt.saveBool = function(pHandle, archName)
    local maxSlot = mt.maxSlotNum
    local msg = ''

    local slot = 1
    for i = 1, maxSlot do

        local bools = ''
        for j = 1, 19 do
            local data = mt.loadArch(pHandle, archName, slot)
            if data then
                bools = bools .. '1'
            else
                bools = bools .. '0'
            end
            slot = slot + 1
        end

        gdebug('save bools: ' .. bools)
        local num = code.B2R(bools)
        gdebug('save num: ' .. num)
        local chunk = code.R2s(num)
        plainGdebug('save chunck: ' .. chunk)
        msg = msg .. chunk
    end

    mt.saveData(pHandle, archName, msg)
end
--------------------------------------------------------------------------------------
mt.loadArch = function(pHandle, archName, archSlot)
    local pId = GetConvertedPlayerId(pHandle)
    if not mt.archData[pId][archName] then
        mt.archData[pId][archName] = {}
    end

    return mt.archData[pId][archName][archSlot] or nil
end
--------------------------------------------------------------------------------------
mt.saveArch = function(pHandle, archName, archSlot, archVal)
    local pId = GetConvertedPlayerId(pHandle)
    if not mt.archData[pId][archName] then
        mt.archData[pId][archName] = {}
    end

    mt.archData[pId][archName][archSlot] = archVal
end
--------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------
return mt
