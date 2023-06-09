-- awesome_mode: api-level=9999:screen=on
local gears = require("gears")
local awful = require("awful")
local beautiful = require("beautiful")
-- Enable hotkeys help widget for VIM and other apps
-- when client with a matching name is opened:
-- Don't show the tmux keymaps
package.loaded["awful.hotkeys_popup.keys.tmux"] = {}
require("awful.hotkeys_popup.keys")

-- If LuaRocks is installed, make sure that packages installed through it are
-- found (e.g. lgi). If LuaRocks is not installed, do nothing.
pcall(require, "luarocks.loader")

pcall(require, "awful.autofocus") -- Depreciated in V5

-- -- Add configuration directory to package.?path so awesome --config FILE works right
local conf_dir = gears.filesystem.get_configuration_dir():sub(1, -2) -- Remove slash
package.path = string.format("%s/?.lua;%s/?/init.lua;%s", conf_dir, conf_dir, package.path)
package.cpath = string.format("%s/?.so;%s", conf_dir, package.cpath)

-- Theme
beautiful.init(require("theme"))
require("module.notifications")

require("module.git-submodule")

-- Set environment variables. (ONLY for POSIX systems)
require("configuration.environment")()

-- Layout
require("layout")

-- Init all modules
require("module.auto-start")
require("module.inhibit-power-key")
require("module.decorate-client")
require("module.exit-screen")
require("module.tags")

-- Setup all configurations
require("configuration.client")
awful.layout.layouts = require("configuration.layouts")
root.keys(require("configuration.keys.global"))

-- Different tags for each wallpaper
require("module.wallpaper")
-- Keep selected tag on restart
require("module.persistent-tag")

-- Disable mouse snapping
awful.mouse.snap.edge_enabled = false
awful.mouse.snap.client_enabled = false
awful.mouse.drag_to_tag.enabled = false

-- Signal function to execute when a new client appears.
client.connect_signal("manage", function(c)
	-- Set the windows at the slave,
	-- i.e. put it at the end of others instead of setting it master.
	if not awesome.startup then
		awful.client.setslave(c)
	end

	if awesome.startup and not c.size_hints.user_position and not c.size_hints.program_position then
		-- Prevent clients from being unreachable after screen count changes.
		awful.placement.no_offscreen(c)
	end
end)

-- Enable sloppy focus, so that focus follows mouse.
client.connect_signal("mouse::enter", function(c)
	c:emit_signal("request::activate", "mouse_enter", { raise = true })
end)

-- Make the focused window have a glowing border
client.connect_signal("focus", function(c)
	c.border_color = beautiful.border_focus
end)
client.connect_signal("unfocus", function(c)
	c.border_color = beautiful.border_normal
end)
