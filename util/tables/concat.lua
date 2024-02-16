local rel_require = require("util.rel_require")
local map_val = rel_require(..., "map_val") ---@module 'util.tables.map_val'
---Concat elements of a table with a format
---@generic V :unknown
---@param t V[]
---@param format (string|fun(v: V): string)? the format for each element
---@param separator string? the separator between each formatted element
---@return string
local function concat(t, separator, format)
  if not format then return table.concat(t, separator) end
  if type(format) == "function" then -- call format on each element and join
    return table.concat(map_val(t, format), separator)
  end
  local ret = {}
  for k, v in ipairs(t) do
    ret[k] = format:format(v)
  end
  return table.concat(ret, separator)
end
return concat
