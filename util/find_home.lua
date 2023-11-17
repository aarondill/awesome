local path = require("util.path")
local home_cached ---@type string? -- Don't directly access. Use get_and_cache_home

local function get_and_cache_home()
  if home_cached then return home_cached end

  local home = os.getenv("HOME")
  if not home then
    local file = assert(io.popen([[ getent passwd "${USER:-$(id -nu)}" | cut -d: -f6 ]]))
    home = file:read("l") ---@type string
    file:close()
  end
  ---Remove trailing slashes
  local ret = #home == 0 and "." or path.normalize(home)
  home_cached = ret
  return ret
end

--- Finds a valid HOME for the user
--- Tries to handle the case where HOME is unset
--- Use the gears.filesystem.get_xdg_* functions instead if possible
--- Calls io.popen if HOME is unset, but caches the result, so only one call will be made.
--- Note: absolute paths will still be appended to home. IE: `/file`, `./file`, and `file` are all equivalent.
---@param file string? a file to find under $HOME
---@return string home
local function find_home(file)
  local home = get_and_cache_home()
  if not file then return home end
  return path.normalize(("%s/%s"):format(home, file))
end
return find_home
