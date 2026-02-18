local mt = test

--------------------------------------------------------------------------------------
function mt:refreshChallenge(keys)
    local p = keys.p

    local challengeList = p.challengeList
    for _, challenge in ipairs(challengeList) do
        challenge.currentCd = 1
    end

end
--------------------------------------------------------------------------------------
test.act['refreshchallenge'] = mt.refreshChallenge