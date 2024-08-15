local gfile = require("gears.filesystem")
local GLib = require("lgi").GLib
local handle_error = require("util.handle_error")
local path = require("util.path")

---@param env string
---@param val (string|false)? Note: if false or nil is passed, unsets
---@param overwrite boolean? default to true
---@return boolean changed
local function setenv(env, val, overwrite)
  if overwrite == nil then overwrite = true end
  if val then return GLib.setenv(env, val, overwrite) end
  if not os.getenv(env) then return false end
  GLib.unsetenv(env)
  return true
end

---@param env table<string, (string|false)?> remember that `nil` keys aren't accessable!
---@param overwrite boolean? default to true
---@return boolean changed
local function setenv_tbl(env, overwrite)
  local changed = false
  for k, v in pairs(env) do
    if setenv(k, v, overwrite) then changed = true end
  end
  return changed
end

---@param progs string[]
---@return string?, string?
local function first_in_path(progs)
  for _, p in ipairs(progs) do
    local ppath = GLib.find_program_in_path(p)
    if ppath then return p, ppath end
  end
end

local function setup_environment()
  local deps_bindir = path.resolve(gfile.get_configuration_dir(), "deps", ".bin")
  -- A default PATH. If $PATH is unset, there's bigger problems.
  local pathvar = os.getenv("PATH") or table.concat({ "/usr/bin", "/bin", "/usr/sbin", "/sbin" }, path.delimiter)
  pathvar = table.concat({ deps_bindir, pathvar }, path.delimiter)

  local ibus = first_in_path({ "ibus", "fcitx" }) -- IBUS --

  return setenv_tbl({
    GTK_IM_MODULE = ibus, -- Fix for browsers
    QT_IM_MODULE = ibus, -- Not sure if this works or not, but whatever
    XMODIFIERS = ibus and ("@im=" .. ibus),
    PATH = pathvar, -- Set the PATH environment variable to include /deps/.bin/
    GTK_THEME = "Yaru:dark", -- Prefer dark theme
    XDG_CURRENT_DESKTOP = "GNOME:AWESOME",
    QT_QPA_PLATFORMTHEME = "gtk2",
    QT_STYLE_OVERRIDE = "gtk2",
    SHLVL = false, -- Fix terminals opened in AwesomeWM
    NO_AT_BRIDGE = "1", -- Don't try to connect to an accessibility bus
    _JAVA_AWT_WM_NONREPARENTING = "1", -- expose awesome as a non-reparenting window to java
    ZEITGEIST_LOG_DIRECT_READ = "1", -- Fix a bug in diodon
  })
end

return handle_error(setup_environment)
