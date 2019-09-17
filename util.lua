util = {}

local Object = {}
function Object:new (o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end
util.Object = Object

function util.new(t)
  return function(data)
    for k,v in pairs(t) do
      if not ((type(v) == "table" and data[k].__typeof == v) or v == type(data[k])) then
        --print(type(v), data[k].__typeof ~= v, v ~= type(data[k]))
        error "mismatched types in declaration"
      end
    end
    data.__typeof = t
    setmetatable(data,t)
    return data
  end
end

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
