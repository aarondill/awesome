local bind = require("util.bind")
local stream = require("stream")
---Concat elements of a table with a format
---@generic V :unknown
---@param t V[]
---@param format (string|fun(v: V): string)? the format for each element
---@param separator string? the separator between each formatted element
---@return string
return function(t, separator, format)
  if not format then return table.concat(t, separator) end
  --- Either call format(v) or string.format(format, v)
  local mapper = type(format) == "function" and format or bind.with_start_args(string.format, format)
  return stream.new(t):map(mapper):join(separator)
end
