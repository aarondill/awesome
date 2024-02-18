local assertions = require("util.types.assertions")
local gfilesystem = require("gears.filesystem")
local gstring = require("gears.string")
local path = require("util.path")
local Gio = require("util.lgi").Gio
local cache = {} ---@type table<string, string>
local defaults = {
  CONFIG = ".config",
  DATA = path.join(".local", "share"),
  STATE = path.join(".local", "state"),
  CACHE = ".cache",

  DESKTOP = "Desktop",
  DOWNLOAD = "Downloads",
  TEMPLATES = "Templates",
  PUBLICSHARE = "Public",
  DOCUMENTS = "Documents",
  MUSIC = "Music",
  PICTURES = "Pictures",
  VIDEOS = "Videos",
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
    local exec = path.join(conf, "scripts", "xdg-user-dir")
    local flags = { "STDOUT_PIPE", "STDERR_SILENCE" } ---@type GSubprocessFlags[]
    local process = (Gio.Subprocess.new({ exec, dir }, flags))
    if not process then return "" end
    local stdout = assert(process:communicate())
    if stdout:get_size() > 0 then return stdout.data or "" end
  end

  -- Defaults
  if defaults[dir] then return path.join(path.get_home(), defaults[dir]) end

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
  assertions.type(dir, "string", "dir")
  dir = dir:upper()
  if gstring.startswith(dir, "XDG_") then -- Turn XDG_CONFIG_HOME to CONFIG
    if gstring.endswith(dir, "_HOME") then
      dir = dir:sub(3, -(1 + ("_HOME"):len()))
    elseif gstring.endswith(dir, "_DIR") then
      dir = dir:sub(3, -(1 + ("_DIR"):len()))
    else
      return error(("Invalid xdg directory: '%s'"):format(dir), 2)
    end
  end
  if cache[dir] then return cache[dir] end
  local res = get_xdg_user_dir_impl(dir)
  cache[dir] = res
  return res
end

return get_xdg_user_dir
