local mt = {}

function mt.playToPlayer(sound, p, base, flow, interrupt)

    local pitch = mt.rngSoundPitch(sound, base, flow)

    if as.player:getLocalPlayer() == p or p == cst.ALL_PLAYERS then
        if interrupt then
            StopSoundBJ(sound, false)
        end

        SetSoundPitch(sound, pitch)
        PlaySoundBJ(sound)
    end
end

function mt.playToLocal(sound, base, interrupt)
    local pitch = base
    if interrupt then
        StopSoundBJ(sound, false)
    end

    SetSoundPitch(sound, pitch)
    PlaySoundBJ(sound)
end

function mt.playToPoint(sound, point, range, base, flow, interrupt)
    local pitch = mt.rngSoundPitch(sound, base, flow)
    local screenPoint = ac.point:new(GetCameraTargetPositionX(), GetCameraTargetPositionY(), 0)
    if screenPoint * point < range then
        if interrupt then
            StopSoundBJ(sound, false)
        end

        SetSoundPitch(sound, pitch)
        PlaySoundBJ(sound)
    end

end

function mt.playToAll(sound, base, flow, interrupt)
    local pitch = mt.rngSoundPitch(sound, base, flow)

    if interrupt then
        StopSoundBJ(sound, false)
    end

    SetSoundPitch(sound, pitch)
    PlaySoundBJ(sound)
end

function mt.rngSoundPitch(sound, base, flow)
    base = base or 1
    flow = flow or 0

    return base + math.randomReal(flow * -1, flow)
end

return mt
