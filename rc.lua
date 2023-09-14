-- awesome_mode: api-level=9999:screen=on
---@diagnostic disable-next-line  :undefined-global
local capi = { client = client }
local awful = require("awful")
local beautiful = require("beautiful")
local compat = require("util.compat")
local gfile = require("gears.filesystem")
-- Enable hotkeys help widget for VIM and other apps
-- when client with a matching name is opened:
-- Don't show the tmux keymaps
package.loaded["awful.hotkeys_popup.keys.tmux"] = {}
require("awful.hotkeys_popup.keys")

-- If LuaRocks is installed, make sure that packages installed through it are
-- found (e.g. lgi). If LuaRocks is not installed, do nothing.
pcall(require, "luarocks.loader")

pcall(require, "awful.autofocus") -- Depreciated in V5

-- Add configuration directory to package.?path so awesome --config FILE works right
local conf_dir = gfile.get_configuration_dir():sub(1, -2) -- Remove slash
local this_dir = (debug.getinfo(1, "S").source:sub(2):match("^(.*)/.-$") or ".")
local utils_path = this_dir .. "/util/package_path.lua"
if gfile.file_readable(utils_path) then
  local util_package_path = dofile(utils_path)
  package.loaded["util.package_path"] = util_package_path -- cache it for later
  util_package_path.add_to_path(conf_dir)
  util_package_path.add_to_path(this_dir)
end

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
require("module.quake") -- Should prob be before decorate-client, and keys.global, as they both require it.
require("module.auto-start")
require("module.inhibit-power-key")
require("module.decorate-client")
require("module.exit-screen")

-- Setup all configurations
require("configuration.rofi_dynamic") -- Async setup of rofi for current theme
require("configuration.client")
require("widget.launcher") -- Sets up menubar.utils.term
awful.layout.layouts = require("configuration").layouts
root.keys(require("configuration.keys.global"))

-- Different tags for each wallpaper
require("module.wallpaper")

-- Disable mouse snapping
awful.mouse.snap.edge_enabled = false
awful.mouse.snap.client_enabled = false
awful.mouse.drag_to_tag.enabled = false

-- Signal function to execute when a new client appears.
capi.client.connect_signal(compat.signal.manage, function(c)
  -- Set the windows at the slave,
  -- i.e. put it at the end of others instead of setting it master.
  if not awesome.startup then awful.client.setslave(c) end

  if awesome.startup and not c.size_hints.user_position and not c.size_hints.program_position then
    -- Prevent clients from being unreachable after screen count changes.
    awful.placement.no_offscreen(c)
  end
end)

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
require("gears.timer")({
  timeout = 30,
  autostart = true,
  callback = require("util.bind").bind(collectgarbage, "collect"),
})
