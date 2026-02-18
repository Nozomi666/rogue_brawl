local prefix = 'game.__data.章节.'
require(prefix .. '通用设定')
require(prefix .. '章节1')



fc.getChapterById = function(id)
    local chapterList = reg:getPool('chapters')
    return chapterList[id]
end
