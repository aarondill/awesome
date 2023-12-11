local lgi = require("util.lgi")
local GLib = lgi.GLib
---Joins paths with slashes.
---Usage: path.join({'directory', 'file'}) OR path.join('directory', 'file')
---@param tbl string|string[] note: if a table is passed, remaining arguments are ignored
---@param ... string
---@return string
local function join(tbl, ...)
  tbl = type(tbl) == "table" and tbl or { tbl, ... }
  return GLib.build_filenamev(tbl)
end
return join
