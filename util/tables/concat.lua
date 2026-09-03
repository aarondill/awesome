local rel_require = require("util.rel_require")
local tbl_join = rel_require(..., "tbl_join") ---@module "util.tables.tbl_join"
---Concat all arguments into a copy of t1, returns a new table.
---@param t1 unknown[]
---@param ... unknown
---@return table joined a new table containing the concatenation
return function(t1, ...)
  local t2 = table.pack(...)
  return tbl_join(t1, t2)
end
