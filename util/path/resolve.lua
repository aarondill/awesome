local require = require("util.rel_require")

local init = require(..., "init") ---@module "util.path"
local join = require(..., "join") ---@module 'util.path.join'
local normalize = require(..., "normalize") ---@module 'util.path.normalize'

---exactly equivalent to path.normalize(path.join(...), true)
---Except that if no path is passed, the result is the root, instead of the empty string.
---Returns a normalized absolute path
---@param ... string
---@return string
local function resolve(...)
  local p = normalize(join(...), true)
  return p ~= "" and p or init.root
end
return resolve
