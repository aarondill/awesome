local GLib = require("util.lgi").GLib
local path = require("util.path")

--- Finds a valid HOME for the user
--- Note: absolute paths will still be appended to home. IE: `/file`, `./file`, and `file` are all equivalent.
---@param file string? a file to find under $HOME
---@return string home
local function find_home(file)
  local home = GLib.get_home_dir()
  if not file then return home end
  return path.resolve(home, file)
end
return find_home
