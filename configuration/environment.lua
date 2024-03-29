local has_posix, posix = pcall(require, "posix.stdlib")
local gfile = require("gears.filesystem")
local handle_error = require("util.handle_error")
local notifs = require("util.notifs")
local path = require("util.path")

local function setenv()
  local deps_bindir = path.resolve(gfile.get_configuration_dir(), "deps", ".bin")
  -- A default PATH. If $PATH is unset, there's bigger problems.
  local pathvar = os.getenv("PATH") or table.concat({ "/usr/bin", "/bin", "/usr/sbin", "/sbin" }, path.delimiter)
  pathvar = table.concat({ deps_bindir, pathvar }, path.delimiter)
  posix.setenv("PATH", pathvar) -- Set the PATH environment variable to include /deps/.bin/

  posix.setenv("GTK_THEME", "Yaru:dark") -- Prefer dark theme
  posix.setenv("GTK_IM_MODULE", "xim") -- Fix for browsers
  posix.setenv("QT_IM_MODULE", "xim") -- Not sure if this works or not, but whatever
  posix.setenv("XMODIFIERS", "@im=ibus")
  posix.setenv("XDG_CURRENT_DESKTOP", "GNOME:AWESOME")
  posix.setenv("QT_QPA_PLATFORMTHEME", "gtk2")
  posix.setenv("QT_STYLE_OVERRIDE", "gtk2")
  posix.setenv("SHLVL", "0") -- Fix terminals opened in AwesomeWM
  posix.setenv("NO_AT_BRIDGE", "1") -- Don't try to connect to an accessibility bus
  posix.setenv("_JAVA_AWT_WM_NONREPARENTING", "1") -- expose awesome as a non-reparenting window to java
  posix.setenv("ZEITGEIST_LOG_DIRECT_READ", "1") -- Fix a bug in diodon
end

if not has_posix then
  notifs.warn("Could not find luaposix.stdlib! Please ensure it's available at posix.stdlib.", {
    title = "Warning: ",
    timeout = 0,
  })
  -- If no posix module is available, return an empty function
  return function() end
end
return handle_error(setenv)
