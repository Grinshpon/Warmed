local astar = {}

util = require "util"

local Map = {}
Map = util.Object:new{
	lvl = nil,
	width = 0,
	height = 0,
  printCase = nil,
	__tostring = function(self)
		local s = "+"
		for _=1,self.width do
			s = s.."-"
		end
		s = s.."+\n"
		for i in pairs(self.lvl) do
			s = s.."|"
			for j in pairs(self.lvl[i]) do
				local t = self.lvl[i][j]
  			s = s..util.match({t},self.printCase)
			end
			s = s.."|\n"
		end
		s = s.."+"
		for _=1,self.width do
			s = s.."-"
		end
		s = s.."+"
		return s
	end
}
astar.Map = Map

function ch_dist(x1,y1,x2,y2) -- chebyshev distance
	local dx = math.abs(x2-x1)
	local dy = math.abs(y2-y1)
	if dx > dy then
		return dx
	else
		return dy
	end
end

function mh_dist(x1,y1,x2,y2) -- manhattan distance
	return math.abs(x2-x1) + math.abs(y2-y1)
end

function eu_dist(x1,y1,x2,y2) -- euclidean distance
	return math.pow(x2-x1,2) + math.pow(y2-y1,2)
end

function dist(...)
	return mh_dist(...) -- manhattan distance (while still allowing diagonal movement) seems to lead to the best result
end

local Tile = util.Object:new{
	x = 0,
	y = 0,
	G = 0,
	H = 0,
	F = 0,
	parent = nil,
	list = "",
}
Tile.__tostring = function(self)
	return "Tile: {x="..tostring(self.x)..", y="..tostring(self.y)..", G="..tostring(self.G)..", H="..tostring(self.H)..", F="..tostring(self.F).."}"
end

function tile(tx,ty,end_point,g)
	t = Tile:new{
		x = tx,
		y = ty,
	}
	t.G = g or 0
	t.H = dist(t.x,t.y,end_point.x,end_point.y)
	t.F = t.G + t.H
	return t
end

function Tile:link(tile)
	tile.parent = self
end

function addOpen(openList, t)
	t.list = "open"
	table.insert(openList,t)
end
function addClose(openList, closeList, t,i)
	t.list = "close"
	table.insert(closeList,t)
	table.remove(openList,i)
	return t
end
function findOpen(openList, x,y)
	for i in pairs(openList) do
		if openList[i].x == x and openList[i].y == y
		then return i
		end
	end
	return -1
end
function findClose(closeList, x,y)
	for i in pairs(closeList) do
		if closeList[i].x == x and closeList[i].y == y
		then return true
		end
	end
	return false
end

function newCurrent(openList, closeList)
	local m, mi = -1, 0
	for i in pairs(openList) do
		if m == -1 or openList[i].F < m then
			m = openList[i].F
			mi = i
		end
	end
	if m == -1 then
		return nil
	else
		return addClose(openList, closeList, openList[mi],mi)
	end
end

function surrounding(openList, closeList, map, t, end_point)
	for y=-1,1 do
		for x=-1,1 do
			local nx, ny = t.x+x,t.y+y
			if not ((x == 0 and y == 0) or (nx < 1) or (ny < 1) or (nx > map.width) or (ny > map.height) or findClose(closeList, nx,ny)) then
				local p = map.lvl[ny][nx]
				if p == 0 or p == 3 or p == 4 then
					local ni = findOpen(openList, nx,ny)
					local nu = nil
					if ni == -1 then
						nu = tile(nx,ny,end_point,t.G+1)
						t:link(nu)
						addOpen(openList, nu)
					else
						nu = openList[ni]
						if nu.G > t.G+1 then
							t:link(nu)
							nu.G = t.G+1
							nu.F = nu.G+nu.H
						elseif nu.F > t.F then
							t:link(nu)
							nu.G = t.G+1
							nu.F = nu.G+nu.H
						end
					end
					if nu.x == end_point.x and nu.y == end_point.y then
						return nu
					end
					if p == 0 then
						map.lvl[ny][nx] = 4
					end
				end
			end
		end
	end
end

function astar.findPath(map, start_point, end_point) --TODO: instead of modifying map, return path from start to end
  local openList = {}
  local closeList = {}

	local cur = start_point
	addOpen(openList, cur)
	cur = newCurrent(openList, closeList)
	local f = surrounding(openList, closeList, map, cur, end_point)
	while f == nil do
		cur = newCurrent(openList, closeList)
		if cur == nil then f = nil; break; end
		f = surrounding(openList, closeList, map, cur, end_point)
	end
	return f
end

return astar
