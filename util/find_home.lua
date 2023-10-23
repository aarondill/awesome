local home_cached

--- Finds a valid HOME for the user
--- Tries to handle the case where HOME is unset
--- Use the gears.filesystem.get_xdg_* functions instead if possible
--- Calls io.popen if HOME is unset, but caches the result, so only one call will be made.
local function find_home()
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
  return home
end
return find_home
