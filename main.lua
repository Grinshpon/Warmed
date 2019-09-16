love.window.setTitle "Warcry Map Editor";
love.graphics.setDefaultFilter("nearest","nearest");

--temporary
love.window.setMode(1920,1920,{resizable=false});
love.graphics.setNewFont(--[["Font/uni05_53.ttf",--]]25);

util = require "util"

local file

local tileset
local quad
local selected = 1
local placeCase

local Camera
function offsetx(x)
  return x-Camera.x
end
function offsety(y)
  return y-Camera.y
end
function coffsetx(x)
  return x+Camera.x
end
function coffsety(y)
  return y+Camera.y
end
function translate(x,y)
  Camera.x = Camera.x - x
  Camera.y = Camera.y - y
end

local Map
function show(self)
  function tab(x)
    if not x then return "  "
    else
      local res = ""
      for i=1,x do
        res = res.."  "
      end
      return res
    end
  end
  local res = "local Map = {}\nMap = {\n"
  res = res..tab().."name = \""..self.name.."\",\n"
  res = res..tab().."data = {\n"
  function showData(layer, name)
    res = res..tab(2)..name.." = {\n"
    for i in pairs(layer) do
      res = res..tab(3).."["..tostring(i).."] = { "
        for j in pairs(layer[i]) do
          res = res.."["..tostring(j).."] = "..tostring(layer[i][j])..", "
        end
      res = res.."},\n"
    end
    res = res..tab(2).."},\n"
  end
  showData(self.data.background, "background")
  showData(self.data.terrain, "terrain")
  showData(self.data.entities, "entities")

  res = res..tab().."},\n"
  res = res..tab().."width = "..tostring(self.width)..",\n"
  res = res..tab().."height = "..tostring(self.height)..",\n"
  res = res.."}\nreturn Map\n"
  return res
end

function file_exists(name)
 local f=io.open(name,"r")
 if f~=nil then io.close(f) return true else return false end
end


local keysDown
local selectCase = {
  ['1']     = function() selected = 1 end,
  ['2']     = function() selected = 2 end,
  ['3']     = function() selected = 3 end,
  ['4']     = function() selected = 4 end,
  ['up']    = function() if not keysDown.up    then keysDown.up = true;    end end,
  ['down']  = function() if not keysDown.down  then keysDown.down = true;  end end,
  ['left']  = function() if not keysDown.left  then keysDown.left = true;  end end,
  ['right'] = function() if not keysDown.right then keysDown.right = true; end end,
  default = function() end
}

local releaseCase = {
  ['up']    = function() if keysDown.up    then keysDown.up = false;    end end,
  ['down']  = function() if keysDown.down  then keysDown.down = false;  end end,
  ['left']  = function() if keysDown.left  then keysDown.left = false;  end end,
  ['right'] = function() if keysDown.right then keysDown.right = false; end end,
  default = function() end
}

function love.keypressed(key)
  util.match({key}, selectCase)()
end

function love.keyreleased(key)
  util.match({key}, releaseCase)()
end

function love.load(arg)
  --[[
  for i in ipairs(arg) do
    print(tostring(i)..": "..arg[1])
  end
--]]

  keysDown = {
    up = false,
    down = false,
    left = false,
    right = false
  }

  if arg[1] then
    if file_exists("maps/"..arg[1]..".lua") then
      Map = require("maps/"..arg[1])
    else
      Map = {
        name = arg[1],
        data = {
          background = {{}},
          terrain = {{}},
          entities = {{}},
        },
        width = 0,
        height = 0,
      }
    end
    file = io.open("maps/"..arg[1]..".lua", "w")
  else
    Map = {
      name = "untitled",
      data = { -- for testing, replace with empty/defaults
        background = {{}},
        terrain = {{}},
        entities = {{}},
      },
      width = 0,
      height = 0,
    }
    file = io.open("maps/untitled.lua", "w")
  end

  Camera = {x = 0, y = 0 --[[, scale = 1.0--]]}

  tileset = love.graphics.newImage("Tiles/basic_tiles.png")
  quad = {
    love.graphics.newQuad(0,0,8,8, tileset:getDimensions()),
    love.graphics.newQuad(8,0,8,8, tileset:getDimensions()),
    love.graphics.newQuad(0,8,8,8, tileset:getDimensions()),
    love.graphics.newQuad(8,8,8,8, tileset:getDimensions())
  }

  placeCase = {
    [1] = Map.data.background,
    [2] = Map.data.background,
    [3] = Map.data.background,
    [4] = Map.data.background,
    ['q'] = Map.data.terrain,
    ['w'] = Map.data.terrain,
    ['e'] = Map.data.terrain,
    ['r'] = Map.data.terrain,
    ['a'] = Map.data.entities,
    ['s'] = Map.data.entities,
    ['d'] = Map.data.entities,
    ['f'] = Map.data.entities,
    default = {},
  }

end

local transCase = {
  ['up']    = function() translate(0,-5) end,
  ['down']  = function() translate(0,5)  end,
  ['left']  = function() translate(-5,0) end,
  ['right'] = function() translate(5,0)  end,
  default = function() end
}

function love.update(dt)
  for k,v in pairs(keysDown) do
    if v then util.match({k}, transCase)() end
  end
end


function love.mousepressed(x,y,button, _istouch)
  if button == 1 and x >= 0 and y >= 0 then
    x = math.floor(offsetx(x)/80)+1
    y = math.floor(offsety(y)/80)+1
    print(x,y)
    local layer = util.match({selected}, placeCase)
    if not layer[y] then
      layer[y] = {}
      for i=1,x do
        layer[y][i] = 0
      end
    end
    layer[y][x] = selected
  end
end

function love.draw()
  -- temp
  --love.graphics.draw(tileset, quad[1], 0,0,   0, 10,10)
  --love.graphics.draw(tileset, quad[2], 0,80,  0, 10,10)
  --love.graphics.draw(tileset, quad[3], 80,0,  0, 10,10)
  love.graphics.draw(tileset, quad[4], coffsetx(80),coffsety(80), 0, 10,10)
  --
  love.graphics.rectangle("fill", 0, 1820, 100,100)
  love.graphics.draw(tileset, quad[selected], 10, 1830, 0, 10,10)
  local x,y = love.mouse.getPosition()
  x,y = offsetx(x), offsety(y)
  local mx,my = math.floor(x/10), math.floor(y/10)
  -- multiple selection rectangle: love.graphics.rectangle("line", l,w, mousex, mousey)
  love.graphics.setLineWidth(3)
  love.graphics.rectangle("line", coffsetx(80*(math.floor(x/80))),coffsety(80*(math.floor(y/80))), 80,80)
  love.graphics.print("("..tostring(mx)..", "..tostring(my)..")", 110, 1830)
  love.graphics.print("background:  [1]  [2]  [3]  [4]    terrain:  [q]  [w]  [e]  [r]    entities:  [a]  [s]  [d]  [f]", 110, 1875)
end

function love.quit()
  io.output(file)
  io.write(show(Map))
  io.close(file)
end
