astar = require "astar"

function printPath()
  local map = astar.Map:new{
    lvl = {
      {0,0,0,0,0,0,0,0,0,1,0,0,0,0},
      {0,0,0,0,0,0,0,0,0,1,0,0,0,0},
      {0,0,0,0,0,0,0,0,0,1,0,0,3,0},
      {0,0,0,0,0,0,0,0,0,1,0,0,0,0},
      {0,0,0,0,0,0,0,0,0,0,0,0,0,0},
      {0,0,2,0,0,0,0,0,0,1,0,0,0,0},
      {0,0,0,0,0,0,0,0,0,1,0,0,0,0},
      {0,0,0,0,0,0,0,0,0,1,0,0,0,0},
      {0,0,0,0,0,0,0,0,0,0,1,0,0,0},
      {0,0,0,0,0,0,0,0,0,0,0,1,0,0},
    },
    width = 14,
    height = 10,
    printCase = {
      [0] = " ",
      [1] = "#",
      [2] = "S",
      [3] = "F",
      [4] = ".",
      [5] = "o",
      default = " "
    },
  }
  local startp = {x=3,y=6}
  local endp = {x = 13, y = 3}
  local start = tile(startp.x,startp.y,endp)

	local t = astar.findPath(map, start, endp)
	local l = 0

	if t == nil then print "Path not found"
	else
		while t.parent ~= nil do
			if map.lvl[t.y][t.x] == 4 then
				map.lvl[t.y][t.x] = 5
			end
			t = t.parent
			l = l+1
		end
	end
  print(map)
end

printPath()
