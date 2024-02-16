local assert_util = require("util.assert_util")
--- return a new array containing the concatenation of all of its
--- parameters. Array parameters have their values shallow-copied
--- to the final array. All parameters are must be tables, or else
-- an error is thrown.
---@param ... table[] a set of table to join together
---@return table joined a new table containing the concatenation
return function(...)
  local t = {}
  local tn = 0
  for n = 1, select("#", ...) do
    local arg = select(n, ...)
    assert_util.type(arg, "table", "argument " .. n)
    for argn = 1, (arg.n or #arg) do
      local v = arg[argn]
      tn = tn + 1
      t[tn] = v
    end
  end
  t.n = tn
  return t
end
