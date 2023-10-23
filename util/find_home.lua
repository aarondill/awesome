local home_cached

--- Finds a valid HOME for the user
--- Tries to handle the case where HOME is unset
--- Use the gears.filesystem.get_xdg_* functions instead if possible
--- Calls io.popen if HOME is unset, but caches the result, so only one call will be made.
---@param path string? a file to find under $HOME
---@return string home
local function find_home(path)
  if home_cached then return home_cached end

  local home = os.getenv("HOME")
  if not home then
    local file = assert(io.popen([[ getent passwd "${USER:-$(id -nu)}" | cut -d: -f6 ]]))
    home = file:read("l")
    file:close()
  end
  ---@type string
  home = string.match(home, "^(.*)/?$") or "."
  home_cached = home
  if not path then return home end
  --- Do *slight* normalization
  local ret = (("%s/%s"):format(home, path):gsub("//", "/"):gsub("/./", "/"))
  return ret:len() == 0 and "." or ret
end
return find_home
