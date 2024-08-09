local GLib = require("lgi").GLib
local path = require("util.path")

local home_cached = nil
---Finds a valid HOME for the user
---Note: absolute paths will still be appended to home. IE: `/file`, `./file`, and `file` are all equivalent.
---@param file string? a file to find under $HOME
---@param force_nocache boolean? force the cache to be cleared, always finding a new value for HOME. Note this may invoke file operations, and is not recommended.
---@return string home
local function get_home(file, force_nocache)
  if force_nocache == true then home_cached = nil end
  local home = home_cached or GLib.get_home_dir()
  home_cached = home
  if not file then return home end
  return path.resolve(home, file)
end
return get_home
