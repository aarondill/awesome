---@diagnostic disable-next-line :undefined-global
local capi = { awesome = awesome, client = client }
local require = require("util.rel_require")

local apps = require("configuration.apps")
local awful = require("awful")
local bind = require("util.bind")
local gtable = require("gears.table")
local mod = require(..., "mod") ---@module "configuration.keys.mod"
local notifs = require("util.notifs")
local spawn = require("util.spawn")
local hotkeys_popup = require("awful.hotkeys_popup").widget

local modkey, altkey = mod.modKey, mod.altKey

local function open_main_menu()
  local pid_or_err = spawn.noninteractive(apps.default.rofi)
  -- The return value will be a string in case of failure
  if type(pid_or_err) == "string" then
    local s = awful.screen.focused()
    if s and s.run_promptbox then s.run_promptbox:run() end
  end
end
-- Key bindings
local globalKeys = gtable.join(
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

  awful.key({ modkey }, "r", open_main_menu, { description = "Main Menu", group = "awesome" }),
  awful.key({ altkey }, "space", open_main_menu, { description = "Main Menu", group = "awesome" }),
  awful.key({ modkey }, "p", open_main_menu, { description = "Main Menu", group = "awesome" }),
  awful.key({ modkey }, "w", function()
    local pid_or_err = spawn(apps.default.rofi_window)
    if type(pid_or_err) == "string" then notifs.critical("Rofi is required to open the window picker.") end
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
    if capi.client.focus then capi.client.focus:raise() end
  end, { description = "Switch to next window", group = "client" }),
  awful.key({ altkey, "Shift" }, "Tab", function()
    --awful.client.focus.history.previous()
    awful.client.focus.byidx(-1)
    if capi.client.focus then capi.client.focus:raise() end
  end, { description = "Switch to previous window", group = "client" }),

  -- Programs
  awful.key({ modkey }, "Delete", apps.open.lock, { description = "Lock the screen", group = "awesome" }),

  awful.key({ modkey, "Control" }, "r", capi.awesome.restart, { description = "Reload awesome", group = "awesome" }),
  awful.key({ modkey, "Shift" }, "q", capi.awesome.quit, { description = "Quit awesome", group = "awesome" }),

  awful.key({}, "Print", function()
    spawn(apps.default.region_screenshot)
  end, { description = "Mark an area and screenshot it to your clipboard", group = "launcher" }),
  awful.key({ modkey }, "e", apps.open.editor, { description = "Open an editor", group = "launcher" }),
  awful.key({ modkey }, "b", apps.open.browser, { description = "Open a browser", group = "launcher" }),
  awful.key({ modkey }, "Return", apps.open.terminal, { description = "Open a terminal", group = "launcher" }),
  awful.key({ modkey }, "x", apps.open.terminal, { description = "Open a terminal", group = "launcher" }),
  awful.key(
    { modkey },
    "F12",
    bind(capi.awesome.emit_signal, "quake::toggle"),
    { description = "Open a quake terminal", group = "launcher" }
  ),
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
    if c then c:emit_signal("request::activate", "key.unminimize", { raise = true }) end
  end, { description = "Restore minimized", group = "client" }),

  -- Brightness
  awful.key({}, "XF86MonBrightnessUp", function()
    -- local pid, _, stdin, stdout, stderr =
    spawn.noninteractive(apps.default.brightness.up, { sn_rules = false })
  end, { description = "Brightness up", group = "hotkeys" }),
  awful.key({}, "XF86MonBrightnessDown", function()
    -- local pid, _, stdin, stdout, stderr =
    spawn.noninteractive(apps.default.brightness.down, { sn_rules = false })
  end, { description = "Brightness down", group = "hotkeys" }),
  -- volume control
  awful.key({}, "XF86AudioRaiseVolume", function()
    -- local pid, _, stdin, stdout, stderr =
    spawn.noninteractive(apps.default.volume.up, { sn_rules = false })
  end, { description = "Volume up", group = "hotkeys" }),
  awful.key({}, "XF86AudioLowerVolume", function()
    -- local pid, _, stdin, stdout, stderr =
    spawn.noninteractive(apps.default.volume.down, { sn_rules = false })
  end, { description = "Volume down", group = "hotkeys" }),
  awful.key({}, "XF86AudioMute", function()
    -- local pid, _, stdin, stdout, stderr =
    spawn.noninteractive(apps.default.volume.toggle_mute, { sn_rules = false })
  end, { description = "Toggle mute", group = "hotkeys" }),

  awful.key({}, "XF86AudioPlay", function()
    spawn.noninteractive({ "playerctl", "play-pause" }, { sn_rules = false })
  end, { description = "Play/Pause Audio Track", group = "hotkeys" }),
  awful.key({}, "XF86AudioNext", function()
    spawn.noninteractive({ "playerctl", "next" }, { sn_rules = false })
  end, { description = "Next Audio Track", group = "hotkeys" }),
  awful.key({}, "XF86AudioPrev", function()
    spawn.noninteractive({ "playerctl", "previous" }, { sn_rules = false })
  end, { description = "Previous Audio Track", group = "hotkeys" }),
  awful.key({}, "XF86PowerDown", function()
    require("module.exit-screen").show()
  end, { description = "Open Poweroff Menu", group = "hotkeys" }),
  awful.key({}, "XF86PowerOff", function()
    require("module.exit-screen").show()
  end, { description = "Open Poweroff Menu", group = "hotkeys" }),

  -- Custom hotkeys
  -- Emoji Picker
  awful.key({ modkey }, "a", function()
    spawn({ "ibus", "emoji" })
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
  globalKeys = gtable.join(
    globalKeys,
    -- View tag only.
    awful.key({ modkey }, "#" .. i + 9, function()
      local screen = awful.screen.focused()
      local tag = screen.tags[i]
      if tag then tag:view_only() end
    end, descr_view),
    -- Toggle tag display.
    awful.key({ modkey, "Control" }, "#" .. i + 9, function()
      local screen = awful.screen.focused()
      local tag = screen.tags[i]
      if tag then awful.tag.viewtoggle(tag) end
    end, descr_toggle),
    -- Move client to tag.
    awful.key({ modkey, "Shift" }, "#" .. i + 9, function()
      if capi.client.focus then
        local tag = capi.client.focus.screen.tags[i]
        if tag then capi.client.focus:move_to_tag(tag) end
      end
    end, descr_move),
    -- Toggle tag on focused client.
    awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9, function()
      if capi.client.focus then
        local tag = capi.client.focus.screen.tags[i]
        if tag then capi.client.focus:toggle_tag(tag) end
      end
    end, descr_toggle_focus)
  )
end

return globalKeys
