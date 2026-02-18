local mt = {}

mt.binKey = {}

--------------------------------------------------------------------------------------
mt.xor = function(text1, text2)

    local long, short
    local textInBit = ''

    if str.len(text1) > str.len(text2) then
        long = text1
        short = text2
    else
        long = text2
        short = text1
    end

    for i = 1, str.len(short) do
        if str.sub(long, i, i) == str.sub(short, i, i) then
            textInBit = textInBit .. '0'
        else
            textInBit = textInBit .. '1'
        end
    end

    for i = str.len(short) + 1, str.len(long) do
        textInBit = textInBit .. str.sub(long, i, i)
    end

    return textInBit
end
--------------------------------------------------------------------------------------
mt.getKey = function(platformId, keyName)
    if not keyName then
        keyName = 'kayazakura'
    end
    -- gdebug('keyname: ' .. keyName)
    local hashedId = math.abs(HashString(platformId .. keyName))
    local hashString = tostring(hashedId)

    if str.len(hashString) < 8 then
        for i = 1, 8 - str.len(hashString) do
            hashString = hashString .. '0'
        end

    end

    return hashString
end
--------------------------------------------------------------------------------------
mt.toBin = function(key)

    if mt.binKey[key] then
        return mt.binKey[key]
    end

    local after = ''

    for i = 1, str.len(key) do
        if tonumber(str.sub(key, i, i)) % 2 == 0 then
            after = after .. '0'
        else
            after = after .. '1'
        end
    end

    mt.binKey[key] = after

    return after
end
--------------------------------------------------------------------------------------
mt.encryptBit8 = function(plainText, key, round)

    local hashedId = math.abs(StringHash(key .. round))
    -- gdebug('hashid origin: ' .. hashedId)
    -- gdebug('hashid pading: ' .. str.format('%06d', hashedId))
    local hashString = tostring(hashedId)

    if str.len(hashString) < 6 then
        for i = 1, 6 - str.len(hashString) do
            hashString = hashString .. '0'
        end
    end


    local mixText = ''

    for i = 1, 6 do
        local mixBit = str.sub(plainText, i, i)
        if tonumber(str.sub(hashString, i, i)) % 2 == 0 then
            if mixBit == '0' then
                mixBit = '1'
            else
                mixBit = '0'
            end
        end

        mixText = mixText .. mixBit
    end

    return str.sub(mt.xor(mixText, mt.toBin(key)), 1, 6)
end
--------------------------------------------------------------------------------------
mt.decryptBit8 = function(cypherText, key, round)

    cypherText = str.sub(mt.xor(cypherText, mt.toBin(key)), 1, 6)

    local hashedId = math.abs(StringHash(key .. round))
    local hashString = tostring(hashedId)

    if str.len(hashString) < 6 then
        for i = 1, 6 - str.len(hashString) do
            hashString = hashString .. '0'
        end
    end
    -- gdebug('hashid origin: ' .. hashedId)
    -- gdebug('hashid pading: ' .. str.format('%06d', hashedId))

    local plainText = ''

    for i = 1, 6 do
        local mixBit = str.sub(cypherText, i, i)
        if tonumber(str.sub(hashString, i, i)) % 2 == 0 then
            if mixBit == '0' then
                mixBit = '1'
            else
                mixBit = '0'
            end
        end

        plainText = plainText .. mixBit
    end

    return plainText
end
--------------------------------------------------------------------------------------

mt.encryptBase64 = function(plainText, key)
    local textInBit = ''
    local encodedStr = ''
    local encodedChar
    local strLen = str.len(plainText)
    local shiftKey = code.B2R('00000000000' .. key)
    for i = 1, strLen do
        local num = tonumber(code.S2G(str.sub(plainText, i, i)))
        local bit = code.R2B(num)
        local bitCut = str.sub(bit, 12, 19)

        textInBit = textInBit .. bitCut
    end

    if str.len(plainText) % 3 == 2 then
        textInBit = textInBit .. '00'
    elseif str.len(plainText) % 3 == 1 then
        textInBit = textInBit .. '0000'
    end

    -- gdebug('encypted in bit: ' .. textInBit)

    for i = 1, str.len(textInBit) / 6 do

        local encodedBit = str.sub(textInBit, 6 * (i - 1) + 1, 6 * i)

        -- gdebug('before encryptBit8: ' .. encodedBit)
        encodedBit = mt.encryptBit8(encodedBit, key, i)
        -- gdebug('after encryptBit8: ' .. encodedBit)

        encodedBit = '0000000000000' .. encodedBit
        if encodedBit ~= '0000000000000000000' then
            local numText = code.B2R(encodedBit)
            numText = str.format('%04d', numText)
            encodedChar = code.G2S(numText)
        else
            encodedChar = 'c'
        end

        encodedStr = encodedStr .. encodedChar
    end

    if str.len(plainText) % 3 == 2 then
        encodedStr = encodedStr .. 'a'
    elseif str.len(plainText) % 3 == 1 then
        encodedStr = encodedStr .. 'aa'
    end

    return encodedStr
end
--------------------------------------------------------------------------------------
mt.decryptBase64 = function(cypherText, key)
    local textInBit = ''
    local textInBit2 = ''
    local encodedStr = ''

    for i = 1, str.len(cypherText) do
        local num = tonumber(code.S2G(str.sub(cypherText, i, i)))
        local bit = code.R2B(num)
        local bitCut = str.sub(bit, 14, 19)

        if tonumber(num) ~= 66 then
            if tonumber(num) ~= 68 then
                textInBit = textInBit .. bitCut
            else
                textInBit = textInBit .. '000000'
            end
        else
            textInBit = textInBit .. '00'
        end
    end

    for i = 1, str.len(textInBit) / 6 do
        local encodedBit = str.sub(textInBit, 6 * (i - 1) + 1, 6 * i)
        -- gdebug('before decryptBit8: ' .. encodedBit)
        encodedBit = mt.decryptBit8(encodedBit, key, i)
        -- gdebug('after decryptBit8: ' .. encodedBit)
        textInBit2 = textInBit2 .. encodedBit
    end

    -- gdebug('decypted in bit: ' .. textInBit)
    -- gdebug('decypted in bit2: ' .. textInBit2)
    textInBit = textInBit2

    for i = 1, str.len(textInBit) / 8 do
        local encodedBit = str.sub(textInBit, 8 * (i - 1) + 1, 8 * i)

        encodedBit = '00000000000' .. encodedBit
        local numText = code.B2R(encodedBit)
        numText = str.format('%04d', numText)

        local encodedChar = code.G2S(numText)
        encodedStr = encodedStr .. encodedChar
    end

    return encodedStr
end
--------------------------------------------------------------------------------------
mt.getHmac = function(msg, key)
    -- plainGdebug('getHmac: ')
    -- plainGdebug('key: ' .. key)
    -- plainGdebug('msg: ' .. msg)
    -- plainGdebug('StringHash: ' .. StringHash(key .. msg))
    -- plainGdebug('abs StringHash: ' .. math.abs(StringHash(key .. msg)))
    -- plainGdebug('tostring: ' .. tostring(math.abs(StringHash(key .. msg))))
    return tostring(math.abs(StringHash(key .. msg)))
end
--------------------------------------------------------------------------------------
mt.encapMsg = function(msg, key)
    local hmac = mt.getHmac(msg, key)
    local head = code.G2S(str.format('%04d', str.len(hmac)))
    local encaped = head .. hmac .. msg
    return encaped, hmac
end
--------------------------------------------------------------------------------------
mt.decapMsg = function(msg, key)
    local head = str.sub(msg, 1, 1)
    local num = tonumber(code.S2G(head))
    local hmac = str.sub(msg, 2, 2 + num - 1)
    local bodyMsg = str.sub(msg, 2 + num, str.len(msg))

    -- plainGdebug('head: ' .. head)
    -- plainGdebug('num: ' .. num)
    -- plainGdebug('hmac: ' .. hmac)
    -- plainGdebug('bodyMsg: ' .. bodyMsg)


    return bodyMsg, hmac
end
--------------------------------------------------------------------------------------

return mt
