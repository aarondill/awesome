local assertions = require("util.types.assertions")
--- return a new array containing the concatenation of all of its
--- parameters. Array parameters have their values shallow-copied
--- to the final array. All parameters are must be tables, or else
-- an error is thrown.
---@param ... table a set of tables to join together
---@return table joined a new table containing the concatenation
return function(...)
  local t = {}
  local tn = 0
  for n = 1, select("#", ...) do
    local arg = select(n, ...)
    assertions.type(arg, "table", "argument " .. n)
    local alen = arg.n or #arg
    for i = 1, alen do
      t[tn + i] = arg[i]
    end
    tn = tn + alen
  end
  t.n = tn
  return t
end
