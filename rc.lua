--TODO:
--Clock is *not* clickable (open calendar?)
--Fix tags
--  Remove icons on tags
--  9 tags please
-- Fix tag icons!
--   Their sizes are off bc they came from the default config. Try to find the source of the tile one.
--Fix client decoratations - widget to toggle
--  Onclick: toggle all clients, *except* if request_no_titlebars
--  Ensure the above is already handled by configuration/client/titlebar.lua
--Remove unused code
--  Keep the widgets for the sake of convenience
--  Remove many of the images found in theme/icons
--Handle power button. SUPPRESS it!
--Implement audio foward, back, PlayPause
--Remove exitscreen global functions.
--Improve all widgets that came with TitusTech's clone.
--  Return functions, take args, default programs, etc...
--  These don't work (I think)
--    Tempurature - WORKS? test.
--    Volumne - works? patterns?
--    WiFi - spawns defined program, needs fixed. Defined interface. relies on iw - not stable
--    Bluetooth - Not even exists.
--    Hard-Drive - Relies on `df`, and only checks /home
--    Package updater - relies on pamac - not even debian supported.
--    RAM - Uses glob, by accident. External process, can be simplified?
--Make the package widget work with apt (dpkg?) (or any given package).
--  Accept an argument for commands/hooks
--    apt-get -q -y --ignore-hold --allow-change-held-packages --allow-unauthenticated ---simulate dist-upgrade | /bin/grep  ^Inst | wc -l --> 'updates'
--    /usr/lib/update-notifier/apt-check 2>&1 --> 'security_updates;regular_updates'
--Use /sys files in battery widget to remove dependency on acpi
--  Credit original creator! (I'm gonna take much of his code)
--Manage auto-start apps better?
--  Make array of arrays instead of strings for safer argument handling
--    Allow strings, but prefer arrays
--  send notification if not found -->
--    make script that takes parameter.
--    Complicated string.format?
--Notification utils for consistency
--Further seperate top-panel into files for each widget
--   Especially the ones that have placeholders which get replaced
--Custom theme?
--More wallpapers :)

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
