local normalize_path = require("util.normalize_path")
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
  local ret = #home == 0 and "." or normalize_path(home)
  home_cached = ret
  return ret
end

--- Finds a valid HOME for the user
--- Tries to handle the case where HOME is unset
--- Use the gears.filesystem.get_xdg_* functions instead if possible
--- Calls io.popen if HOME is unset, but caches the result, so only one call will be made.
---@param path string? a file to find under $HOME
---@return string home
local function find_home(path)
  local home = get_and_cache_home()
  if not path then return home end
  return normalize_path(("%s/%s"):format(home, path))
end
return find_home
