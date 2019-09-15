util = {}

local Object = {}
function Object:new (o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end
util.Object = Object

function util.match(pattern,switch)
	local case = switch;
	local default = switch.default or error "no default case";
	for i=1, #pattern do
    if case then
      case = case[pattern[i]];
    else break;
    end
	end
	return case or default;
end

function util.map(f,...)
  local arg = {...}
  if #arg == 1 and type(arg[1]) == "table" then
    arg = arg[1]
  end
  local res = {}
  for i in ipairs(arg) do
    res[i] = f(arg[i])
  end
  return res
end

return util
