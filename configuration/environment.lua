local gfile = require("gears.filesystem")
local glib = require("util.lgi.GLib")
local handle_error = require("util.handle_error")
local path = require("util.path")

---@param env string
---@param val string?
---@param overwrite boolean? default to true
---@return boolean changed
local function setenv(env, val, overwrite)
  if overwrite == nil then overwrite = true end
  if not val then
    if not os.getenv(env) then return false end
    glib.unsetenv(env)
    return true
  end
  return glib.setenv(env, val, overwrite)
end

local function setup_environment()
  local deps_bindir = path.resolve(gfile.get_configuration_dir(), "deps", ".bin")
  -- A default PATH. If $PATH is unset, there's bigger problems.
  local pathvar = os.getenv("PATH") or table.concat({ "/usr/bin", "/bin", "/usr/sbin", "/sbin" }, path.delimiter)
  pathvar = table.concat({ deps_bindir, pathvar }, path.delimiter)
  setenv("PATH", pathvar) -- Set the PATH environment variable to include /deps/.bin/

  setenv("GTK_THEME", "Yaru:dark") -- Prefer dark theme
  setenv("GTK_IM_MODULE", "xim") -- Fix for browsers
  setenv("QT_IM_MODULE", "xim") -- Not sure if this works or not, but whatever
  setenv("XMODIFIERS", "@im=ibus")
  setenv("XDG_CURRENT_DESKTOP", "GNOME:AWESOME")
  setenv("QT_QPA_PLATFORMTHEME", "gtk2")
  setenv("QT_STYLE_OVERRIDE", "gtk2")
  setenv("SHLVL", "0") -- Fix terminals opened in AwesomeWM
  setenv("NO_AT_BRIDGE", "1") -- Don't try to connect to an accessibility bus
  setenv("_JAVA_AWT_WM_NONREPARENTING", "1") -- expose awesome as a non-reparenting window to java
  setenv("ZEITGEIST_LOG_DIRECT_READ", "1") -- Fix a bug in diodon
end

return handle_error(setup_environment)
