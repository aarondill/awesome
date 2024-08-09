local lgi = require("lgi")
local GLib = lgi.GLib
---Gets the dirname
---@param path string
---@return string
local function dirname(path) return GLib.path_get_dirname(path) end
return dirname
