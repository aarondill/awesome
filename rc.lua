--TODO:
--Remove icons on tags
--9 tags please
--Fix client decoratations - widget to toggle
--Remove unused code
--Use /sys files in battery widget to remove dependency on acpi

local awful = require("awful")
local beautiful = require("beautiful")
-- Enable hotkeys help widget for VIM and other apps
-- when client with a matching name is opened:
require("awful.hotkeys_popup.keys")

-- If LuaRocks is installed, make sure that packages installed through it are
-- found (e.g. lgi). If LuaRocks is not installed, do nothing.
pcall(require, "luarocks.loader")

-- Theme
beautiful.init(require("theme"))
require("module.notifications")

-- Set environment variables. (ONLY for POSIX systems)
require("configuration.environment")()

-- Make caps lock like ctrl
awful.spawn("setxkbmap -option 'caps:ctrl_modifier'", false)

-- Layout
require("layout")

-- Init all modules
require("module.auto-start")
require("module.decorate-client")
-- Backdrop causes bugs on some gtk3 applications
-- require("module.backdrop")
require("module.exit-screen")

-- Setup all configurations
require("configuration.client")
require("configuration.tags")
root.keys(require("configuration.keys.global"))

-- Different tags for each wallpaper
require("module.wallpaper")
-- Keep selected tag on restart
require("module.persistent-tag")

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
