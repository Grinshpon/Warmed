love.window.setTitle "Warcry Map Editor";
love.graphics.setDefaultFilter("nearest","nearest");

--temporary
love.window.setMode(1920,1920,{resizable=false});
love.graphics.setNewFont(--[["Font/uni05_53.ttf",--]]25);

util = require "util"

local tileset
local quad
local selected = 1

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
    for i in ipairs(layer) do
      res = res..tab(3).."{ "
        for j in ipairs(layer[i]) do
          res = res..tostring(layer[i][j])..", "
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

--[[
  for i in ipairs(self.data) do
    res = res..tab..tab.."{ "
    for j in ipairs(self.data[i]) do
      res = res.."{"
      for k in ipairs(self.data[i][j]) do
        res = res..tostring(self.data[i][j][k])..","
      end
      res = res.."}, "
    end
    res = res.." },\n"
  end
--]]

function file_exists(name)
 local f=io.open(name,"r")
 if f~=nil then io.close(f) return true else return false end
end

selectCase = {
  ['1'] = function() selected = 1 end,
  ['2'] = function() selected = 2 end,
  ['3'] = function() selected = 3 end,
  ['4'] = function() selected = 4 end,
  default = function() end
}
function love.keypressed(key)
  util.match({key}, selectCase)()
end

function love.load(arg)
  --temp
  for i in ipairs(arg) do
    print(tostring(i)..": "..arg[1])
  end

  local file
  if arg[1] then
    if file_exists(arg[1]..".lua") then
      Map = require(arg[1])
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
    file = io.open(arg[1]..".lua", "w")
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
    file = io.open("untitled.lua", "w")
  end
  io.output(file)
  io.write(show(Map))
  io.close(file)

  tileset = love.graphics.newImage("Tiles/basic_tiles.png")
  quad = {
    love.graphics.newQuad(0,0,8,8, tileset:getDimensions()),
    love.graphics.newQuad(8,0,8,8, tileset:getDimensions()),
    love.graphics.newQuad(0,8,8,8, tileset:getDimensions()),
    love.graphics.newQuad(8,8,8,8, tileset:getDimensions())
  }
end

function love.update(dt)
end

function love.draw()
  -- temp
  love.graphics.draw(tileset, quad[1], 0,0,   0, 10,10)
  love.graphics.draw(tileset, quad[2], 0,80,  0, 10,10)
  love.graphics.draw(tileset, quad[3], 80,0,  0, 10,10)
  love.graphics.draw(tileset, quad[4], 80,80, 0, 10,10)
  --
  love.graphics.rectangle("fill", 0, 1820, 100,100)
  love.graphics.draw(tileset, quad[selected], 10, 1830, 0, 10,10)
  local x,y = love.mouse.getPosition()
  local mx,my = math.floor(x/10), math.floor(y/10)
  -- multiple selection rectangle: love.graphics.rectangle("line", l,w, mousex, mousey)
  love.graphics.setLineWidth(3)
  love.graphics.rectangle("line", 80*(math.floor(x/80)),80*(math.floor(y/80)), 80,80)
  love.graphics.print("("..tostring(mx)..", "..tostring(my)..")", 110, 1830)
  love.graphics.print("background:  [1]  [2]  [3]  [4]    terrain:  [q]  [w]  [e]  [r]    entities:  [a]  [s]  [d]  [f]", 110, 1875)
end
