local assert_util = require("util.assert_util")
local find_home = require("util.find_home")
local gfilesystem = require("gears.filesystem")
local cache = {} ---@type table<string, string>
local defaults = {
  CONFIG = "/.config",
  DATA = "/.local/share",
  STATE = "/.local/state",
  CACHE = "/.cache",

  DESKTOP = "/Desktop",
  DOWNLOAD = "/Downloads",
  TEMPLATES = "/Templates",
  PUBLICSHARE = "/Public",
  DOCUMENTS = "/Documents",
  MUSIC = "/Music",
  PICTURES = "/Pictures",
  VIDEOS = "/Videos",
}

---@param dir string
---@return string
local function get_xdg_user_dir_impl(dir)
  -- Environment
  -- Technically, only _HOME should be set, but we are trying to support all setups
  -- (also, the xdg-user-dir command uses the _DIR commands if they are in the environment)
  local env_val = os.getenv("XDG_" .. dir .. "_HOME") or os.getenv("XDG_" .. dir .. "_DIR")
  if env_val then return env_val end

  -- `xdg-user-dir` command
  do
    local conf = gfilesystem.get_configuration_dir()
    local cmd = string.format("exec '%sscripts/xdg-user-dir' '%s'", conf, dir)
    local f = io.popen(cmd)
    if not f then return "" end
    local result = f:read("*a")
    f:close()
    if result and #result > 0 then return result end
  end

  -- Defaults
  if defaults[dir] then return find_home() .. defaults[dir] end

  -- -- Manual case - We shouldn't reach this.
  -- local s = dir:sub(1, 1) .. string.lower(dir:sub(2))
  -- return find_home() .. s
  return "" -- Absolute worst case.
end

---Finds the xdg_user_dir using the xdg-user-dir program
---Uses io.popen, but caches values
---dir should be in capital letters
---@param dir string the XDG_USER_DIR to search for
local function get_xdg_user_dir(dir)
  assert_util.type(dir, "string", "dir")
  dir = string.upper(dir)
  if cache[dir] then return cache[dir] end
  local res = get_xdg_user_dir_impl(dir)
  cache[dir] = res
  return res
end

return get_xdg_user_dir
