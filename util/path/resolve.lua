local require = require("util.rel_require")

local join = require(..., "join") ---@module 'util.path.join'
local normalize = require(..., "normalize") ---@module 'util.path.normalize'

---exactly equivalent to path.normalize(path.join(...), true)
---Returns a normalized absolute path
---@param ... string
---@return string
local function resolve(...)
  return normalize(join(...), true)
end
return resolve
