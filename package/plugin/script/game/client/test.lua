local mt = test
--------------------------------------------------------------------------------------
function mt:post(keys)
    local p = keys.p
    local u = p.hero
    
    gdebug('call post')
    local url = 'http://localhost:8080/legend-ranger/game-win'


    local platformId = '1234567'
    local gameChapter = 1
    local diffNum = 1

    local param = ''
    param = param .. str.format('platformId=%s',platformId)
    param = param .. str.format('&gameChapter=%s',gameChapter)
    param = param .. str.format('&diffNum=%s',diffNum)


    post_message(url, param, function (result)
        print('post url: ' .. url)
        print('post param: ' .. param)
        print('post result: ')
        print(result)
    end)

end
--------------------------------------------------------------------------------------
test.act['post'] = mt.post