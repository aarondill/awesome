local rel_require = require("util.rel_require")
local clone = rel_require(..., "clone") ---@module "util.tables.clone"
---Concat all arguments into a copy of t1, returns a new table.
---@param t1 unknown[]
---@param ... unknown
---@return (unknown[]|{n: integer}) joined a new table containing the concatenation
return function(t1, ...)
  local res = clone(t1)
  local tn = #res
  for n = 1, select("#", ...) do
    local arg = select(n, ...)
    res[tn + 1] = arg
    tn = tn + 1
  end
  res.n = tn
  return res
end
