local compat = require("util.compat")
local require = require("util.rel_require")
local tags = require("util.tags")

local apps = require("configuration.apps")
local awful = require("awful")
local bind = require("util.bind")
local capi = require("capi")
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
local setup_next_spawned_handler
-- A scope block to ensure that these values can only be referenced by setup_next_spawned_handler
do
  --- The tag to move the next spawned window to.
  local next_spawned_tag = nil ---@type AwesomeTagInstance?
  local next_should_jump = true ---@type boolean?
  ---@param c AwesomeClientInstance
  local function next_spawned_handler(c) ---@return nil
    -- Don't do it again! Only the first one!
    capi.client.disconnect_signal(compat.signal.manage, next_spawned_handler)
    if not next_spawned_tag then
      return notifs.warn("next_spawned_handler was called with a nil tag. This is probably a bug!") and nil
    end
    -- Move the client to the indicated tag
    c:move_to_tag(next_spawned_tag)
    if next_should_jump then c:jump_to() end -- Follow/Focus the client.
    next_spawned_tag = nil -- Ensure we can ID bugs if they occur
    return nil
  end
  ---A function to be used in a keymapping that will ensure the next window spawned is moved to tag i (on focused screen)
  ---@param i integer
  ---@param should_jump boolean? default true
  function setup_next_spawned_handler(i, should_jump)
    next_spawned_tag = tags.get_tag(i)
    next_should_jump = should_jump == nil and true or should_jump
    capi.client.connect_signal(compat.signal.manage, next_spawned_handler)
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
  awful.key({ modkey, "Shift" }, "c", function()
    -- This is dynamic so it doesn't require compositor before needed (thusly creating a tempfile)
    -- The file will be cleaned up, but it's better to avoid creating it if not needed.
    require("configuration.apps.compositor").toggle()
  end, { description = "Start/Stop Compositor", group = "awesome" }),

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
  local descr_view, descr_toggle, descr_move, descr_move_view, descr_toggle_focus, descr_next_spawned, descr_next_spawned_no_jump
  if i == 1 or i == 9 then
    descr_view = { description = "View tag #", group = "tag" }
    descr_toggle = { description = "Toggle tag #", group = "tag" }
    descr_move = { description = "Move focused client to tag #", group = "tag" }
    descr_move_view = { description = "Move focused client to tag # and view it", group = "tag" }
    descr_toggle_focus = { description = "Toggle focused client on tag #", group = "tag" }
    descr_next_spawned = { description = "Move the next spawned client to tag #", group = "tag" }
    descr_next_spawned_no_jump = { description = "Move the next spawned client to tag #;don't focus", group = "tag" }
  end
  globalKeys = gtable.join(
    globalKeys,
    -- View tag only.
    awful.key({ modkey }, "#" .. i + 9, bind.with_args(tags.show_tag, i), descr_view),
    -- Toggle tag display.
    awful.key({ modkey, "Control" }, "#" .. i + 9, bind.with_args(tags.show_tag, i, true), descr_toggle),
    -- Move client to tag.
    awful.key({ modkey, "Shift" }, "#" .. i + 9, function()
      local c = capi.client.focus
      local tag = c and tags.get_tag(i, c)
      if not c or not tag then return end
      if tag then c:move_to_tag(tag) end
    end, descr_move),
    -- Move client to tag and focus
    awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9, function()
      local c = capi.client.focus
      local tag = c and tags.get_tag(i, c)
      if not c or not tag then return end
      c:move_to_tag(tag)
      c:jump_to()
    end, descr_move_view),
    -- Toggle tag on focused client.
    awful.key({ modkey, "Control", altkey }, "#" .. i + 9, function()
      local c = capi.client.focus
      local tag = c and tags.get_tag(i, c)
      if not c or not tag then return end
      c:toggle_tag(tag)
    end, descr_toggle_focus),
    -- Move next spawned window to tag.
    awful.key({ modkey, altkey }, "#" .. i + 9, bind.with_args(setup_next_spawned_handler, i), descr_next_spawned),
    -- Move next spawned window to tag. Don't focus.
    awful.key(
      { modkey, "Shift", altkey },
      "#" .. i + 9,
      bind.with_args(setup_next_spawned_handler, i, false),
      descr_next_spawned_no_jump
    )
  )
end

return globalKeys
