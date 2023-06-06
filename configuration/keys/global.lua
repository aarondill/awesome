local awful = require("awful")
local gears = require("gears")
local hotkeys_popup = require("awful.hotkeys_popup").widget

local modkey = require("configuration.keys.mod").modKey
local altkey = require("configuration.keys.mod").altKey
local apps = require("configuration.apps")
-- Key bindings
local globalKeys = gears.table.join(
	-- Hotkeys
	awful.key({ modkey }, "F1", hotkeys_popup.show_help, { description = "Show help", group = "awesome" }),
	awful.key({ modkey }, "s", hotkeys_popup.show_help, { description = "Show help", group = "awesome" }),

	-- Client management
	awful.key({ modkey }, "j", function()
		awful.client.focus.byidx(1)
	end, { description = "Focus next by index", group = "client" }),
	awful.key({ modkey }, "k", function()
		awful.client.focus.byidx(-1)
	end, { description = "Focus previous by index", group = "client" }),

	awful.key({ modkey }, "r", function()
		awful.spawn(apps.default.rofi)
	end, { description = "Main Menu", group = "awesome" }),
	awful.key({ altkey }, "space", function()
		awful.spawn(apps.default.rofi)
	end, { description = "Main Menu", group = "awesome" }),
	awful.key({ modkey }, "p", function()
		awful.spawn(apps.default.rofi)
	end, { description = "Main Menu", group = "awesome" }),
	awful.key({ modkey }, "w", function()
		awful.spawn(apps.default.rofi_window)
	end, { description = "Window Picker", group = "awesome" }),

	-- Tag management
	awful.key({ modkey }, "Right", awful.tag.viewnext, { description = "View next", group = "tag" }),
	awful.key({ modkey }, "Left", awful.tag.viewprev, { description = "View previous", group = "tag" }),
	awful.key({ modkey }, "Tab", awful.tag.viewnext, { description = "View next", group = "tag" }),
	awful.key({ modkey, "Shift" }, "Tab", awful.tag.viewprev, { description = "View previous", group = "tag" }),
	awful.key({ modkey }, "Escape", awful.tag.history.restore, { description = "Go back", group = "tag" }),

	-- Layout management

	awful.key({ modkey, "Shift" }, "j", function()
		awful.client.swap.byidx(1)
	end, { description = "Swap with next client by index", group = "client" }),
	awful.key({ modkey, "Shift" }, "k", function()
		awful.client.swap.byidx(-1)
	end, { description = "Swap with previous client by index", group = "client" }),
	awful.key({ modkey, "Control" }, "j", function()
		awful.screen.focus_relative(1)
	end, { description = "Focus the next screen", group = "screen" }),
	awful.key({ modkey, "Control" }, "k", function()
		awful.screen.focus_relative(-1)
	end, { description = "Focus the previous screen", group = "screen" }),
	awful.key({ modkey }, "u", awful.client.urgent.jumpto, { description = "Jump to urgent client", group = "client" }),

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

	-- Programs
	awful.key({ modkey }, "Delete", function()
		awful.spawn(apps.default.lock, false)
	end, { description = "Lock the screen", group = "awesome" }),

	awful.key({ modkey, "Control" }, "r", awesome.restart, { description = "Reload awesome", group = "awesome" }),
	awful.key({ modkey, "Shift" }, "q", awesome.quit, { description = "Quit awesome", group = "awesome" }),

	awful.key({}, "Print", function()
		awful.spawn.with_shell(apps.default.region_screenshot)
	end, { description = "Mark an area and screenshot it to your clipboard", group = "launcher" }),
	awful.key({ modkey }, "e", function()
		awful.spawn(apps.default.editor)
	end, { description = "Open an editor", group = "launcher" }),
	awful.key({ modkey }, "b", function()
		awful.spawn(apps.default.browser)
	end, { description = "Open a browser", group = "launcher" }),
	awful.key({ modkey }, "Return", function()
		awful.spawn(apps.default.terminal)
	end, { description = "Open a terminal", group = "launcher" }),
	awful.key({ modkey }, "x", function()
		awful.spawn(apps.default.terminal)
	end, { description = "Open a terminal", group = "launcher" }),

	awful.key({ modkey }, "l", function()
		awful.tag.incmwfact(0.05)
	end, { description = "Increase master width factor", group = "layout" }),
	awful.key({ modkey }, "h", function()
		awful.tag.incmwfact(-0.05)
	end, { description = "Decrease master width factor", group = "layout" }),
	awful.key({ modkey, "Shift" }, "h", function()
		awful.tag.incnmaster(1, nil, true)
	end, { description = "Increase the number of master clients", group = "layout" }),
	awful.key({ modkey, "Shift" }, "l", function()
		awful.tag.incnmaster(-1, nil, true)
	end, { description = "Decrease the number of master clients", group = "layout" }),
	awful.key({ modkey, "Control" }, "h", function()
		awful.tag.incncol(1, nil, true)
	end, { description = "Increase the number of columns", group = "layout" }),
	awful.key({ modkey, "Control" }, "l", function()
		awful.tag.incncol(-1, nil, true)
	end, { description = "Decrease the number of columns", group = "layout" }),

	awful.key({ modkey }, "=", function()
		awful.tag.incgap(5)
	end, { description = "Increase the gaps between windows", group = "layout" }),
	awful.key({ modkey, "Shift" }, "=", function()
		awful.tag.incgap(1)
	end, { description = "Increase the gaps between windows by 1", group = "layout" }),

	awful.key({ modkey }, "-", function()
    -- if <5, set to 0
    --stylua: ignore
		for _ = 1, 5 do awful.tag.incgap(-1) end
	end, { description = "Decrease the gaps between windows", group = "layout" }),
	awful.key({ modkey, "Shift" }, "-", function()
		awful.tag.incgap(-1)
	end, { description = "Decrease the gaps between windows by 1", group = "layout" }),

	awful.key({ modkey }, "space", function()
		awful.layout.inc(1)
	end, { description = "Select next", group = "layout" }),
	awful.key({ modkey, "Shift" }, "space", function()
		awful.layout.inc(-1)
	end, { description = "Select previous", group = "layout" }),

	awful.key({ modkey, "Control" }, "n", function()
		local c = awful.client.restore()
		-- Focus restored client
		if c then
			c:emit_signal("request::activate", "key.unminimize", { raise = true })
		end
	end, { description = "Restore minimized", group = "client" }),

	-- Brightness
	awful.key({}, "XF86MonBrightnessUp", function()
		awful.spawn(apps.default.brightness.up, false)
	end, { description = "Brightness up", group = "hotkeys" }),
	awful.key({}, "XF86MonBrightnessDown", function()
		awful.spawn(apps.default.brightness.down, false)
	end, { description = "Brightness down", group = "hotkeys" }),
	-- volume control
	awful.key({}, "XF86AudioRaiseVolume", function()
		awful.spawn(apps.default.volume.up, false)
	end, { description = "Volume up", group = "hotkeys" }),
	awful.key({}, "XF86AudioLowerVolume", function()
		awful.spawn(apps.default.volume.down, false)
	end, { description = "Volume down", group = "hotkeys" }),
	awful.key({}, "XF86AudioMute", function()
		awful.spawn(apps.default.volume.toggle_mute, false)
	end, { description = "Toggle mute", group = "hotkeys" }),

	awful.key({}, "XF86AudioNext", function()
		--
	end, { description = "Next Audio Track (Unimplimented)", group = "hotkeys" }),
	awful.key({}, "XF86AudioPrev", function()
		--
	end, { description = "Previous Audio Track (Unimplimented)", group = "hotkeys" }),
	awful.key({}, "XF86PowerDown", function()
		require("module.exit-screen").show()
	end, { description = "Open Poweroff Menu", group = "hotkeys" }),
	awful.key({}, "XF86PowerOff", function()
		require("module.exit-screen").show()
	end, { description = "Open Poweroff Menu", group = "hotkeys" }),

	-- Custom hotkeys
	-- Emoji Picker
	awful.key({ modkey }, "a", function()
		awful.spawn.with_shell("ibus emoji")
	end, { description = "Open the ibus emoji picker to copy an emoji to your clipboard", group = "hotkeys" })
)

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it works on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, 9 do
	-- Hack to only show tags 1 and 9 in the shortcut window (mod+s)
	local descr_view, descr_toggle, descr_move, descr_toggle_focus
	if i == 1 or i == 9 then
		descr_view = { description = "View tag #", group = "tag" }
		descr_toggle = { description = "Toggle tag #", group = "tag" }
		descr_move = { description = "Move focused client to tag #", group = "tag" }
		descr_toggle_focus = { description = "Toggle focused client on tag #", group = "tag" }
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
			if client.focus then
				local tag = client.focus.screen.tags[i]
				if tag then
					client.focus:move_to_tag(tag)
				end
			end
		end, descr_move),
		-- Toggle tag on focused client.
		awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9, function()
			if client.focus then
				local tag = client.focus.screen.tags[i]
				if tag then
					client.focus:toggle_tag(tag)
				end
			end
		end, descr_toggle_focus)
	)
end

return globalKeys
