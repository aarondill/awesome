local rel_require = require("util.rel_require")
local has_key = rel_require(..., "has_key") ---@module "util.tables.has_key"
---Gets the value at the keypath. Returns nil if the keypath does not exist
---@param tbl table
---@param ... unknown a keypath to get
---@return unknown|nil
return function(tbl, ...)
  local has, v = has_key(tbl, ...)
  return (has or nil) and v
end
