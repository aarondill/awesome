local source_path = require("util.source_path")
local metatable = {} -- Use one metatable for all the tables
function metatable:__index(key)
  local missing_msg = "Module is missing the %s key! This is required for metainit to function properly"
  assert(type(self.__module) == "string", missing_msg:format("__module"))
  assert(type(self.__filename) == "string", missing_msg:format("__filename"))
  local rel_require = require("util.rel_require")
  local m = rel_require(self.__module, key, false, self.__filename) -- No TCO!
  -- local msg = ("Requiring key: %s.%s: %s"):format(self.__module, key, m)
  -- require("naughty").notify({ text = msg })
  return m
end

---Usage: M=metainit(..., M) return M. You can initialize M with types (but assign nil)
---Note: TCO can't be used!
---Injects __module into the module table and sets the metatable to allow relative imports
---@generic M
---@param module string The current module name (pass `...`)
---@param M M The module table to use
---@param allow_existing boolean? If true, allow keys to exist in the module table. [Default: false]
---@return M
local function metainit(module, M, allow_existing)
  local msg = "Module table has keys set! This is likely an error. If this is intentional, pass allow_existing."
  assert(allow_existing or #M == 0, msg)
  M.__module = module ---@diagnostic disable-line: inject-field -- We have to store this somewhere
  M.__filename = source_path.filename(2) ---@diagnostic disable-line: inject-field -- We have to store this somewhere
  return setmetatable(M, metatable)
end

return metainit
