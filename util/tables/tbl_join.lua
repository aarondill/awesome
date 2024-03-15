local assertions = require("util.types.assertions")
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
    assertions.type(arg, "table", "argument " .. n)
    local alen = arg.n or #arg
    table.move(arg, 1, alen, tn + 1, t)
    tn = tn + alen
  end
  t.n = tn
  return t
end