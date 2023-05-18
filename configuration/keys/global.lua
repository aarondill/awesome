local awful = require("awful")
local gears = require("gears")
require("awful.autofocus")
local beautiful = require("beautiful")
local hotkeys_popup = require("awful.hotkeys_popup").widget

local modkey = require("configuration.keys.mod").modKey
local altkey = require("configuration.keys.mod").altKey
local apps = require("configuration.apps")
-- Key bindings
local globalKeys = gears.table.join(
	-- Hotkeys
	awful.key({ modkey }, "F1", hotkeys_popup.show_help, { description = "Show help", group = "awesome" }),
	awful.key({ modkey }, "s", hotkeys_popup.show_help, { description = "show help", group = "awesome" }),

	-- Client management
	awful.key({ modkey }, "j", function()
		awful.client.focus.byidx(1)
	end, { description = "focus next by index", group = "client" }),
	awful.key({ modkey }, "k", function()
		awful.client.focus.byidx(-1)
	end, { description = "focus previous by index", group = "client" }),

	awful.key({ modkey }, "r", function()
		awful.spawn(apps.default.rofi)
	end, { description = "Main menu", group = "awesome" }),
	awful.key({ altkey }, "space", function()
		awful.spawn(apps.default.rofi)
	end, { description = "Main menu", group = "awesome" }),
	awful.key({ modkey }, "p", function()
		awful.spawn(apps.default.rofi)
	end, { description = "Main menu", group = "awesome" }),

	-- Tag management
	awful.key({ altkey, "Control" }, "Up", awful.tag.viewprev, { description = "view previous", group = "tag" }),
	awful.key({ altkey, "Control" }, "Down", awful.tag.viewnext, { description = "view next", group = "tag" }),
	awful.key({ modkey }, "Left", awful.tag.viewprev, { description = "view previous", group = "tag" }),
	awful.key({ modkey }, "Right", awful.tag.viewnext, { description = "view next", group = "tag" }),
	awful.key({ modkey }, "Escape", awful.tag.history.restore, { description = "go back", group = "tag" }),

	-- Layout management

	awful.key({ modkey, "Shift" }, "j", function()
		awful.client.swap.byidx(1)
	end, { description = "swap with next client by index", group = "client" }),
	awful.key({ modkey, "Shift" }, "k", function()
		awful.client.swap.byidx(-1)
	end, { description = "swap with previous client by index", group = "client" }),
	awful.key({ modkey, "Control" }, "j", function()
		awful.screen.focus_relative(1)
	end, { description = "focus the next screen", group = "screen" }),
	awful.key({ modkey, "Control" }, "k", function()
		awful.screen.focus_relative(-1)
	end, { description = "focus the previous screen", group = "screen" }),
	awful.key({ modkey }, "u", awful.client.urgent.jumpto, { description = "jump to urgent client", group = "client" }),

	awful.key({ altkey }, "Tab", function()
		--awful.client.focus.history.previous()
		awful.client.focus.byidx(1)
		if client.focus then
			client.focus:raise()
		end
	end, { description = "Switch to next window", group = "client" }),
	awful.key({ altkey, "Shift" }, "Tab", function()
		--awful.client.focus.history.previous()
		awful.client.focus.byidx(-1)
		if client.focus then
			client.focus:raise()
		end
	end, { description = "Switch to previous window", group = "client" }),

	-- Programms
	awful.key({ modkey }, "Return", function()
		awful.spawn(apps.default.terminal)
	end, { description = "open a terminal", group = "launcher" }),

	awful.key({ modkey }, "Delete", function()
		awful.spawn(apps.default.lock)
	end, { description = "Lock the screen", group = "awesome" }),

	awful.key({}, "Print", function()
		awful.spawn_with_shell(apps.default.region_screenshot)
	end, { description = "Mark an area and screenshot it to your clipboard", group = "screenshots (clipboard)" }),

	awful.key({ modkey, "Control" }, "r", awesome.restart, { description = "reload awesome", group = "awesome" }),
	awful.key({ modkey, "Shift" }, "q", awesome.quit, { description = "quit awesome", group = "awesome" }),

	awful.key({ modkey }, "e", function()
		awful.spawn(apps.default.editor)
	end, { description = "Open an editor", group = "launcher" }),
	awful.key({ modkey }, "b", function()
		awful.spawn(apps.default.browser)
	end, { description = "Open a browser", group = "launcher" }),
	-- Standard program
	awful.key({ modkey }, "x", function()
		awful.spawn(apps.default.terminal)
	end, { description = "Open a terminal", group = "launcher" }),

	awful.key({ modkey }, "l", function()
		awful.tag.incmwfact(0.05)
	end, { description = "increase master width factor", group = "layout" }),
	awful.key({ modkey }, "h", function()
		awful.tag.incmwfact(-0.05)
	end, { description = "decrease master width factor", group = "layout" }),
	awful.key({ modkey, "Shift" }, "h", function()
		awful.tag.incnmaster(1, nil, true)
	end, { description = "increase the number of master clients", group = "layout" }),
	awful.key({ modkey, "Shift" }, "l", function()
		awful.tag.incnmaster(-1, nil, true)
	end, { description = "decrease the number of master clients", group = "layout" }),
	awful.key({ modkey, "Control" }, "h", function()
		awful.tag.incncol(1, nil, true)
	end, { description = "increase the number of columns", group = "layout" }),
	awful.key({ modkey, "Control" }, "l", function()
		awful.tag.incncol(-1, nil, true)
	end, { description = "decrease the number of columns", group = "layout" }),
	awful.key({ modkey }, "space", function()
		awful.layout.inc(1)
	end, { description = "select next", group = "layout" }),
	awful.key({ modkey, "Shift" }, "space", function()
		awful.layout.inc(-1)
	end, { description = "select previous", group = "layout" }),

	awful.key({ modkey, "Control" }, "n", function()
		local c = awful.client.restore()
		-- Focus restored client
		if c then
			c:emit_signal("request::activate", "key.unminimize", { raise = true })
		end
	end, { description = "restore minimized", group = "client" }),

	-- Brightness
	awful.key({}, "XF86MonBrightnessUp", function()
		awful.spawn("brightnessctl set 10%+")
	end, { description = "+10%", group = "hotkeys" }),
	awful.key({}, "XF86MonBrightnessDown", function()
		awful.spawn("brightnessctl set 10%-")
	end, { description = "-10%", group = "hotkeys" }),
	-- ALSA volume control
	awful.key({}, "XF86AudioRaiseVolume", function()
		awful.spawn("amixer -D pulse sset Master 5%+")
	end, { description = "volume up", group = "hotkeys" }),
	awful.key({}, "XF86AudioLowerVolume", function()
		awful.spawn("amixer -D pulse sset Master 5%-")
	end, { description = "volume down", group = "hotkeys" }),
	awful.key({}, "XF86AudioMute", function()
		awful.spawn("amixer -D pulse set Master 1+ toggle")
	end, { description = "toggle mute", group = "hotkeys" }),

	awful.key({}, "XF86AudioNext", function()
		--
	end, { description = "Next Audio Track (Unimplimented)", group = "hotkeys" }),
	awful.key({}, "XF86PowerDown", function()
		--
	end, { description = "Power Down (Unimplimented)", group = "hotkeys" }),
	awful.key({}, "XF86PowerOff", function()
		-- HACK:
		_G.exit_screen_show()
	end, { description = "Open Poweroff Menu", group = "hotkeys" }),

	-- Custom hotkeys
	-- Emoji Picker
	awful.key({ modkey }, "a", function()
		awful.spawn_with_shell("ibus emoji")
	end, { description = "Open the ibus emoji picker to copy an emoji to your clipboard", group = "hotkeys" })
)

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it works on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, 9 do
	-- Hack to only show tags 1 and 9 in the shortcut window (mod+s)
	local descr_view, descr_toggle, descr_move, descr_toggle_focus
	if i == 1 or i == 9 then
		descr_view = { description = "view tag #", group = "tag" }
		descr_toggle = { description = "toggle tag #", group = "tag" }
		descr_move = { description = "move focused client to tag #", group = "tag" }
		descr_toggle_focus = { description = "toggle focused client on tag #", group = "tag" }
	end
	globalKeys = gears.table.join(
		globalKeys,
		-- View tag only.
		awful.key({ modkey }, "#" .. i + 9, function()
			local screen = awful.screen.focused()
			local tag = screen.tags[i]
			if tag then
				tag:view_only()
			end
		end, descr_view),
		-- Toggle tag display.
		awful.key({ modkey, "Control" }, "#" .. i + 9, function()
			local screen = awful.screen.focused()
			local tag = screen.tags[i]
			if tag then
				awful.tag.viewtoggle(tag)
			end
		end, descr_toggle),
		-- Move client to tag.
		awful.key({ modkey, "Shift" }, "#" .. i + 9, function()
			if _G.client.focus then
				local tag = _G.client.focus.screen.tags[i]
				if tag then
					_G.client.focus:move_to_tag(tag)
				end
			end
		end, descr_move),
		-- Toggle tag on focused client.
		awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9, function()
			if _G.client.focus then
				local tag = _G.client.focus.screen.tags[i]
				if tag then
					_G.client.focus:toggle_tag(tag)
				end
			end
		end, descr_toggle_focus)
	)
end

return globalKeys
