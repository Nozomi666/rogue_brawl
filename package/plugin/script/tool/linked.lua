local setmetatable = setmetatable
local math = math

local list = {}
setmetatable(list, list)

local mt = {}

-- 结构
mt.type = 'list'

-- 记录第一个位置
mt._first = nil

-- 记录最后一个位置
mt._last = nil

-- 记录长度
mt._len = 0

-- 反向表
mt._hash = nil

-- 添加元素
--	[位置]
function mt:add(data, pos)
	if self:find(data) then
		return
	end
	local len = #self
	local hash = self._hash

	-- 调整位置参数
	if not pos or pos > len + 1 then
		pos = len + 1
	elseif pos < 0 then
		pos = 0
	end

	-- 找到当前要插入的位置
	local last_data = self:at(pos - 1)
	local next_data = self:next(last_data)

	-- 与上个元素关联
	if last_data then
		self[last_data] = data
		hash[data] = last_data
	else
		self._first = data
		hash[data] = data
	end

	-- 与下个元素关联
	if next_data then
		self[data] = next_data
		hash[next_data] = data
	else
		self._last = data
		self[data] = nil
	end

	-- 长度 +1
	self._len = self._len + 1
	return self
end

-- 移除元素
function mt:remove(this_data)
	-- 先进行初步查找
	if not self:find(this_data) then
		return false
	end
	local hash = self._hash
	-- 查找下个值与上个值
	local next_data = self[this_data]
	local last_data = hash[this_data]
	if last_data == this_data then
		last_data = nil
	end
	if next_data then
		hash[next_data] = last_data or next_data
	else
		self._last = last_data
	end
	if last_data then
		self[last_data] = next_data
	else
		self._first = next_data
	end
	self._len = self._len - 1
	-- 从哈希表中清除
	hash[this_data] = nil
	return true

end

-- 清空链表
function mt:clear()
	self._first = nil
	self._last = nil
	self._len = 0
	self._hash = {}
end

-- 根据下标取链表元素
function mt:at(index)
	if not index or index <= 0 then
		return
	end
	local size = #self
	local data = nil
	if(index > size)then
		index = size
	end
	for i = 1, index do
		data = self:next(data)
	end
	return data
end

-- 找元素
function mt:find(data)
	return self._hash[data]
end

-- 挑出元素
function mt:pick(f)
	local pu
	for u in pairs(self) do
		if not pu or f(u, pu) then
			pu = u
		end
	end
	return pu
end

-- 遍历方法
function mt:next(data)
	local next_data
	if data then
		next_data = self[data]
	else
		next_data = self._first
	end
	if next_data then
		-- 返回当前遍历到的数据与上一个遍历的数据
		return next_data, data
	end
end

-- 遍历方法
function mt:getAll(cb)
	local res = {}
	for value in pairs(self) do
		if cb == nil or cb(value) then
			res[#res+1] = value
		end
	end
	return res
end

list.__index = mt

-- 遍历
function list:__pairs()
	return list.next, self, nil
end

-- 弱键
list.__mode = 'k'

-- 获取链表长度
function list:__len()
	return self._len
end

---@class linked

-- 创建链表
function list.create()
	--- @type linked
	local self = setmetatable({}, list)
	self._hash = {}
	return self
end

return list
