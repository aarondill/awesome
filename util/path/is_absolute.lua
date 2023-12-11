local lgi = require("util.lgi")
local GLib = lgi.GLib
---@param path string
---@return boolean
local function is_absolute(path)
  return GLib.path_is_absolute(path)
end
return is_absolute
