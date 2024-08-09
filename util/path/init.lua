local GLib = require("lgi").GLib
local metainit = require("util.metainit")
local new_file_for_path = require("util.file.new_file_for_path")

---@diagnostic disable: assign-type-mismatch
local M = metainit(..., {
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
  get_home = nil, ---@module 'util.path.get_home'
}) ---@diagnostic enable: assign-type-mismatch

---The directory separator as a string. This is “/” on UNIX machines and “\" under Windows.
M.sep = GLib.DIR_SEPARATOR_S
---The search path separator as a string. This is “:” on UNIX machines and “;” under Windows.
M.delimiter = GLib.SEARCHPATH_SEPARATOR_S
---The path to the root directory
---'/' on unix. 'C:\' on windows, where C is the current drive
M.root = new_file_for_path(GLib.DIR_SEPARATOR_S):get_path() or GLib.DIR_SEPARATOR_S

return M
