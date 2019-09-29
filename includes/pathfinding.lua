--- source: https://code.google.com/archive/p/cs2d-moba-engin33r/source
_map = map
_tile = tile
_neighbours = {}

function init_map()
	local xsize,ysize = _map('xsize')+1,_map('ysize')+1
	
	local function neighbors(next)
		local near = {}		
		if next.x ~= 0 then
			if _tile(next.x-1,next.y,"walkable") then
				table.insert(near,{x=next.x-1,y=next.y})
			end
		end		
		if next.x ~= xsize -1 then
			if _tile(next.x+1,next.y,"walkable") then
				table.insert(near,{x=next.x+1,y=next.y})
			end
		end		
		if next.y ~= 0 then
			if _tile(next.x,next.y-1,"walkable") then
				table.insert(near,{x=next.x,y=next.y-1})
			end
		end		
		if next.y ~= ysize -1 then
			if _tile(next.x,next.y+1,"walkable") then
				table.insert(near,{x=next.x,y=next.y+1})
			end
		end			
		--print('x: '..next.x.." y: "..next.y)
		--print('Number of neighbours '..#near)		
		return near
	end
	
	local map_ = {}
	
	local xmax,ymax = _map("xsize"),_map("ysize")
	for j=0,ymax do
		map_[j] = {}
		for i = 0, xmax do
			local w 	
			if _tile(i,j,"walkable") then w=0 else w= 1 end
			map_[j][i] = w
			local t = {x=i,y=j}
			_neighbours[j*xsize+i+1] = neighbors(t)					
		end		
	end
	return map_
end

local xsize = _map("xsize")+1
print("xsize: " ..xsize)
local ysize = _map("ysize")+1

local map_ = init_map()

function table.find(t, x)
	for _,v in ipairs(t) do if x == v then return _ end end
end

function pqueue(initial, cmp)
	cmp = cmp or function(a,b) return a<b end
	return setmetatable({unpack(initial or {})}, {
		__index = {
			push = function(self, v)
				table.insert(self, v)
				local next = #self
				local prev = math.floor(next/2)
												
				while next > 1 and cmp(self[next],self[prev]) do
					-- swap up
					self[next], self[prev] = self[prev], self[next]
					next = prev
					prev = math.floor(next/2)
				end
				self[next] = v
				self.size = self.size + 1
			end,
			size = 0,
			pop = function(self)
				if #self < 2 then
					self.size = self.size - 1
					return table.remove(self)
				end
				local r = self[1]
				self[1] = table.remove(self)
				local root = 1
				if #self > 1 then
					local size = #self
					local v = self[root]
					while root < size do
						local child = 2*root
						if child < size then
							if child+1 < size and cmp(self[child+1],self[child]) then child = child + 1 end
							if cmp(self[child], self[root]) then
								-- swap down
								self[root], self[child] = self[child], self[root]
								root = child
							else
								self[root] = v
								break
							end
						else
							self[root] = v
							break
						end
					end
				end
				self.size = self.size - 1
				return r
			end,
			
			print = function(self)
				for i,v in ipairs(self) do
					print(i.." "..unpack(v))
				end
			end}})		
			
end

local function dist(point, goal)
	-- simple euclidean distance as our heuristic function
	return (goal.x - point.x)^2 + (goal.y - point.y)^2
end

local h = function(start,finish) return math.abs(start.x-finish.x) + math.abs(start.y-finish.y) end

-- our graph is the strongly connected rectangular mesh
function search(start, goal)	
	if not tile(start.x,start.y,"walkable") then
		print("Invalid start node")
		return {}
	end
	
	if not tile(goal.x,goal.y,"walkable") then
		print("Invalid finish node")
		return {}
	end

	local this = start
	local g_, h_, f_
	local visited , graph, path = {}, pqueue({}, function(a, b)
		return g_[a]+h(a, goal) < g_[b]+h(b, goal)
	end), {}

	-- add nodes into graph
	graph:push(start)

	g_, h_, f_ =
		{[start] = 0},
		{[start] = h(start, goal)},
		{[start] = h(start, goal)}

	while graph.size > 0 do
		this = graph:pop()
	
		-- end condition
		if this.x == goal.x and this.y == goal.y then
			function backtrace(this)
				if path[this] then
					local p = backtrace(path[this])
					table.insert(p, this)
					return p
				else
					return {this}
				end
			end
			return backtrace(this)
		end
		
		visited[this] = true
		for _,next in ipairs(_neighbours[this.y*xsize+this.x+1]) do
			if not visited[next] then
				local gscore = g_[this] + dist(this, next)				
				local advance
				local push  = false
				if not table.find(graph, next) then
					advance = true
					push = true
				elseif gscore < g_[next] then
					advance = true
				else
					advance = false
				end
				if advance then
					path[next] = this
					g_[next] = gscore
					h_[next] = h(next, goal)
					f_[next] = g_[next] + h_[next]
				end
				if push then				
					graph:push(next)				
				end				
			end
		end
	end
end