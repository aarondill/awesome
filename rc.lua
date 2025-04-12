-- awesome_mode: api-level=9999:screen=on
-- If LuaRocks is installed, make sure that packages installed through it are
-- found (e.g. lgi). If LuaRocks is not installed, do nothing.
pcall(require, "luarocks.loader")

if not pcall(require, "lgi") then error("LGI is required to run this configuration") end

local GLib = require("lgi").GLib
-- Ensure we start in the home directory (as soon as we can)
-- Note that lua has no way to chdir, so we have to wait until lgi is available, then we can chdir
GLib.chdir(GLib.get_home_dir())

local gfile = require("gears.filesystem")
-- Enable hotkeys help widget for VIM and other apps
-- when client with a matching name is opened:
-- Don't show the tmux keymaps
package.loaded["awful.hotkeys_popup.keys.tmux"] = {}
require("awful.hotkeys_popup.keys")

if not pcall(require, "awful.permissions") then -- Added to replace awful.autofocus
  pcall(require, "awful.autofocus") -- Depreciated in V5
end
-- Ignore the $SHELL environment variable
require("awful.util").shell = gfile.file_executable("/bin/bash") and "/bin/bash" or "/bin/sh"

-- Add configuration directory to package.?path so awesome --config FILE works right
local dirsep = GLib.DIR_SEPARATOR_S

local conf_dir = gfile.get_configuration_dir()
local this_dir = (debug.getinfo(1, "S").source:sub(2):match("^(.*)" .. dirsep .. ".-$") or ".") -- Should be same as conf_dir
package.path = table.concat({ -- Make sure the following require will work!
  package.path,
  table.concat({ this_dir, "?.lua" }, dirsep),
  table.concat({ this_dir, "?", "init.lua" }, dirsep),
}, ";")
local util_package_path = require("util.package_path")
-- Note: this table is reversed, because each path gets prepended
util_package_path.add_to_both({ conf_dir, this_dir }, true)
local deps_path = require("deps")
util_package_path.add_to_path(deps_path.path)
util_package_path.add_to_cpath(deps_path.cpath)

util_package_path.dedupe() -- Remove any duplicate path segments -- especially the above concat

-- Load these *local* packages *After* fixing package.path

require("configuration.environment")() -- Set environment variables. This should be done before spawning *any* child processes!
require("theme") -- Import the theme BEFORE layout/widgets!
require("layout") -- Set up the layout -- this may be needed before modules
require("util.dir_require")("module") -- Init all modules

-- Setup all configurations
-- require("configuration.apps.compositor").autostart() -- Start the compositor on startup
require("gears.timer").delayed_call(function()
  require("configuration.rofi_dynamic")() -- Setup of rofi for current theme (sync)
end)
require("widget.launcher") -- Sets up menubar.utils.term
require("configuration.keys.global") -- Setup the global keys

-- Disable mouse snapping
local amouse = require("awful.mouse")
amouse.snap.edge_enabled = false
amouse.snap.client_enabled = false
amouse.drag_to_tag.enabled = false
