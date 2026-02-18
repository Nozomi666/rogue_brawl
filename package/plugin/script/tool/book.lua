local mt = {}
mt.__index = mt

mt.page = 1
mt.pageMax = 1
mt.cellPerPage = 99
mt.list = nil

--------------------------------------------------------------------------------------
function mt.new(list, cellPerPage)
    local o = {}
    setmetatable(o, mt)

    o.cellPerPage = cellPerPage

    if list then
        o:setList(list)
    end

    return o
end
--------------------------------------------------------------------------------------
function mt:setList(list)
    if self.list == list then
        return
    end
    -- gdebug('#list = '..#list)
    self.list = list
    self:resetPage()
end
--------------------------------------------------------------------------------------
function mt:resetPage()
    local list = self.list
    local cellPerPage = self.cellPerPage
    if not list then
        return
    end

    local pageMax = 1 + math.floor((math.max(#list - 1, 0)) / cellPerPage)

    self.page = 1
    self.pageMax = pageMax

end
--------------------------------------------------------------------------------------
function mt:updateMaxPage()
    local list = self.list
    local cellPerPage = self.cellPerPage
    if not list then
        return
    end

    local pageMax = 1 + math.floor((math.max(#list - 1, 0)) / cellPerPage)
    self.pageMax = pageMax
end
--------------------------------------------------------------------------------------
function mt:getCurrentPage()
    local list = self.list
    local cellPerPage = self.cellPerPage
    local page = self.page
    local cands = {}

    if not list then
        return cands
    end

    for i = 1, cellPerPage do
        local entryId = i + (page - 1) * cellPerPage
        local entry = list[entryId]
        if entry then
            cands[#cands + 1] = entry
        end
        
    end

    return cands
end
--------------------------------------------------------------------------------------
function mt:pageLeft()
    self.page = math.max(1, self.page - 1)
    return self.page
end
--------------------------------------------------------------------------------------
function mt:pageRight()
    self.page = math.min(self.pageMax, self.page + 1)
    return self.page
end
--------------------------------------------------------------------------------------
function mt:changePage(amt)
    self.page = math.clamp(self.page + amt, 1, self.pageMax)
end
--------------------------------------------------------------------------------------
function mt:getPageText()
    return str.format('第%d/%d页', self.page, self.pageMax)
end
--------------------------------------------------------------------------------------
function mt:getPageSize()
    return self.cellPerPage
end

--------------------------------------------------------------------------------------
return mt
