local GLib = require("util.lgi").GLib
local require = require("util.rel_require")
---@diagnostic disable: assign-type-mismatch -- To allow nil values
local M = {
  tildify = nil, ---@module 'util.path.tildify'
  untildify = nil, ---@module 'util.path.untildify'
  get_filepath = nil, ---@module 'util.path.get_filepath'
  join = nil, ---@module 'util.path.join'
  is_absolute = nil, ---@module 'util.path.is_absolute'
  normalize = nil, ---@module 'util.path.normalize'
  resolve = nil, ---@module 'util.path.resolve'
  relative = nil, ---@module 'util.path.relative'
  basename = nil, ---@module 'util.path.basename'
  dirname = nil, ---@module 'util.path.dirname'
  extname = nil, ---@module 'util.path.extname'
}
---@diagnostic enable: assign-type-mismatch
local this_path = ... ---@type string
setmetatable(M, {
  __index = function(_, key)
    local m = require(this_path, key, false) -- No TCO!
    return m
  end,
})

---The directory separator as a string. This is “/” on UNIX machines and “\" under Windows.
M.sep = GLib.DIR_SEPARATOR_S
---The search path separator as a string. This is “:” on UNIX machines and “;” under Windows.
M.delimiter = GLib.SEARCHPATH_SEPARATOR_S
---The path to the root directory
---'/' on unix. 'C:\' on windows, where C is the current drive
M.root = M.normalize(M.sep, true)

return M
