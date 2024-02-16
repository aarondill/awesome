-- awesome_mode: api-level=9999:screen=on
local beautiful = require("beautiful")
local gfile = require("gears.filesystem")
-- Enable hotkeys help widget for VIM and other apps
-- when client with a matching name is opened:
-- Don't show the tmux keymaps
package.loaded["awful.hotkeys_popup.keys.tmux"] = {}
require("awful.hotkeys_popup.keys")

-- If LuaRocks is installed, make sure that packages installed through it are
-- found (e.g. lgi). If LuaRocks is not installed, do nothing.
pcall(require, "luarocks.loader")

if not pcall(require, "awful.permissions") then -- Added to replace awful.autofocus
  pcall(require, "awful.autofocus") -- Depreciated in V5
end
-- Ignore the $SHELL environment variable
require("awful.util").shell = gfile.file_executable("/bin/bash") and "/bin/bash" or "/bin/sh"

-- Add configuration directory to package.?path so awesome --config FILE works right
local dirsep = require("lgi").GLib.DIR_SEPARATOR_S ---@type string

local conf_dir = gfile.get_configuration_dir()
local this_dir = (debug.getinfo(1, "S").source:sub(2):match("^(.*)" .. dirsep .. ".-$") or ".") -- Should be same as conf_dir
package.path = table.concat({ -- Make sure the following require will work!
  package.path,
  table.concat({ this_dir, "?.lua" }, dirsep),
  table.concat({ this_dir, "?", "init.lua" }, dirsep),
}, ";")
local path = require("util.path")
local util_package_path = require("util.package_path")
util_package_path.add_to_both({ -- Note: this table is reversed, because each path gets prepended
  conf_dir,
  path.join(this_dir, "deps"), -- Add /deps to package.[c]path
  this_dir,
}, true)
local deps_path = require("deps")
util_package_path.add_to_path(deps_path.path)
util_package_path.add_to_cpath(deps_path.cpath)

util_package_path.dedupe() -- Remove any duplicate path segments -- especially the above concat

-- Load these *local* packages *After* fixing package.path
local capi = require("capi")
local compat = require("util.awesome.compat")

-- Set environment variables. (ONLY for POSIX systems)
require("configuration.environment")()

-- Theme
beautiful.init(require("theme")) -- Import the theme BEFORE layout/widgets!

require("module.notifications")
require("module.git-submodule") -- Import *after* notifications for nice status messages

-- Layout
require("layout")

require("module.tags") -- Setup tags
require("module.persistent-tag") -- Keep selected tag on restart

-- Init all modules
require("util.dir_require")("module")
require("module.autorandr").start_listener() -- Ensure this is after submodules

-- Setup all configurations
-- require("configuration.apps.compositor").autostart() -- Start the compositor on startup
require("configuration.rofi_dynamic")() -- Async setup of rofi for current theme
require("widget.launcher") -- Sets up menubar.utils.term
capi.root.keys(require("configuration.keys.global"))

-- Different tags for each wallpaper
require("module.wallpaper")

-- Disable mouse snapping
local amouse = require("awful.mouse")
amouse.snap.edge_enabled = false
amouse.snap.client_enabled = false
amouse.drag_to_tag.enabled = false

-- Enable sloppy focus, so that focus follows mouse.
capi.client.connect_signal("mouse::enter", function(c)
  c:emit_signal("request::activate", "mouse_enter", { raise = true })
end)

-- Make the focused window have a glowing border
capi.client.connect_signal("focus", function(c)
  c.border_color = compat.beautiful.get_border_focus(beautiful)
end)
capi.client.connect_signal("unfocus", function(c)
  c.border_color = compat.beautiful.get_border_normal(beautiful)
end)

-- Run garbage collector regularly to prevent memory leaks
_G.collectgarbagetimer = require("gears.timer").new({
  timeout = 30,
  autostart = true,
  callback = require("util.bind").with_args(collectgarbage, "collect"),
})
