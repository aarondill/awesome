local awful = require("awful")
local beautiful = require("beautiful")
require("awful.autofocus")
-- Enable hotkeys help widget for VIM and other apps
-- when client with a matching name is opened:
require("awful.hotkeys_popup.keys")

-- Theme
beautiful.init(require("theme"))

-- Layout
require("layout")

-- Init all modules
require("module.notifications")
require("module.auto-start")
require("module.decorate-client")
-- Backdrop causes bugs on some gtk3 applications
-- require("module.backdrop")
require("module.exit-screen")
require("module.quake-terminal")

-- Setup all configurations
require("configuration.client")
require("configuration.tags")
root.keys(require("configuration.keys.global"))

-- Different tags for each wallpaper
require("module.wallpaper")

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
_G.client.connect_signal("mouse::enter", function(c)
	c:emit_signal("request::activate", "mouse_enter", { raise = true })
end)

-- Make the focused window have a glowing border
_G.client.connect_signal("focus", function(c)
	c.border_color = beautiful.border_focus
end)
_G.client.connect_signal("unfocus", function(c)
	c.border_color = beautiful.border_normal
end)
