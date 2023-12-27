local compat = require("util.compat")
local get_child_by_id = require("util.get_child_by_id")
local require = require("util.rel_require")
local tags = require("util.tags")

local aclient = require("awful.client")
local alayout = require("awful.layout")
local apps = require("configuration.apps")
local ascreen = require("awful.screen")
local atag = require("awful.tag")
local awful_key = require("awful.key")
local bind = require("util.bind")
local capi = require("capi")
local gtable = require("gears.table")
local mod = require(..., "mod") ---@module "configuration.keys.mod"
local notifs = require("util.notifs")
local spawn = require("util.spawn")
local hotkeys_popup = require("awful.hotkeys_popup").widget

---A typed helper around awful_key.new -- Note: specific to this file
---@param modKeys string[]
---@param key string
---@param press? fun(): any
---@param release? (fun(): any)|aKeyDataTable
---@param data? aKeyDataTable
local gkey = function(modKeys, key, press, release, data)
  return awful_key.new(modKeys, key, press, release, data)
end

local modkey, altkey = mod.modKey, mod.altKey

local setup_next_spawned_handler
-- A scope block to ensure that these values can only be referenced by setup_next_spawned_handler
do
  --- The tag to move the next spawned window to.
  local next_spawned_tag = nil ---@type AwesomeTagInstance?
  local next_should_jump = true ---@type boolean?
  ---@param c AwesomeClientInstance
  local function next_spawned_handler(c) ---@return nil
    local t = next_spawned_tag
    next_spawned_tag = nil
    if not t then return end -- If no tag, the stop (this has already been called)
    -- Move the client to the indicated tag
    c:move_to_tag(t)
    if next_should_jump then c:jump_to() end -- Follow/Focus the client.
  end
  ---A function to be used in a keymapping that will ensure the next window spawned is moved to tag i (on focused screen)
  ---@param i integer
  ---@param should_jump boolean? default true
  function setup_next_spawned_handler(i, should_jump)
    next_spawned_tag = tags.get_tag(i)
    next_should_jump = should_jump == nil and true or should_jump
    return capi.client.connect_signal(compat.signal.manage, next_spawned_handler)
  end
end
-- Key bindings
local globalKeys = gtable.join(
  -- Hotkeys
  gkey({ modkey }, "F1", hotkeys_popup.show_help, { description = "Show help", group = "awesome" }),
  gkey({ modkey }, "s", hotkeys_popup.show_help, { description = "Show help", group = "awesome" }),

  -- Client management
  gkey({ modkey }, "j", function()
    aclient.focus.byidx(1)
  end, { description = "Focus next by index", group = "client" }),
  gkey({ modkey }, "k", function()
    aclient.focus.byidx(-1)
  end, { description = "Focus previous by index", group = "client" }),

  gkey({ modkey }, "r", apps.open.rofi, { description = "Main Menu", group = "awesome" }),
  gkey({ altkey }, "space", apps.open.rofi, { description = "Main Menu", group = "awesome" }),
  gkey({ modkey }, "p", apps.open.rofi, { description = "Main Menu", group = "awesome" }),
  gkey({ modkey }, "w", bind.with_args(apps.open.rofi, "window"), { description = "Window Picker", group = "awesome" }),

  -- Tag management
  gkey({ modkey }, "Right", atag.viewnext, { description = "View next", group = "tag" }),
  gkey({ modkey }, "Left", atag.viewprev, { description = "View previous", group = "tag" }),
  gkey({ modkey }, "Tab", atag.viewnext, { description = "View next", group = "tag" }),
  gkey({ modkey, "Shift" }, "Tab", atag.viewprev, { description = "View previous", group = "tag" }),
  gkey({ modkey }, "Escape", atag.history.restore, { description = "Go back", group = "tag" }),

  -- Layout management

  gkey({ modkey, "Shift" }, "j", function()
    aclient.swap.byidx(1)
  end, { description = "Swap with next client by index", group = "client" }),
  gkey({ modkey, "Shift" }, "k", function()
    aclient.swap.byidx(-1)
  end, { description = "Swap with previous client by index", group = "client" }),
  gkey({ modkey, "Control" }, "j", function()
    ascreen.focus_relative(1)
  end, { description = "Focus the next screen", group = "screen" }),
  gkey({ modkey, "Control" }, "k", function()
    ascreen.focus_relative(-1)
  end, { description = "Focus the previous screen", group = "screen" }),
  gkey({ modkey }, "u", aclient.urgent.jumpto, { description = "Jump to urgent client", group = "client" }),

  gkey({ altkey }, "Tab", function()
    --aclient.focus.history.previous()
    aclient.focus.byidx(1)
    if capi.client.focus then capi.client.focus:raise() end
  end, { description = "Switch to next window", group = "client" }),
  gkey({ altkey, "Shift" }, "Tab", function()
    --aclient.focus.history.previous()
    aclient.focus.byidx(-1)
    if capi.client.focus then capi.client.focus:raise() end
  end, { description = "Switch to previous window", group = "client" }),

  -- Programs
  gkey({ modkey }, "Delete", apps.open.lock, { description = "Lock the screen", group = "awesome" }),

  gkey({ modkey, "Control" }, "r", capi.awesome.restart, { description = "Reload awesome", group = "awesome" }),
  gkey({ modkey, "Shift" }, "q", capi.awesome.quit, { description = "Quit awesome", group = "awesome" }),

  gkey({ modkey, "Shift" }, "c", function()
    -- This is dynamic so it doesn't require compositor before needed (thusly creating a tempfile)
    -- The file will be cleaned up, but it's better to avoid creating it if not needed.
    return require("configuration.apps.compositor").toggle()
  end, { description = "Start/Stop Compositor", group = "awesome" }),

  --- Note: this should really only be needed while setting a new configuration
  gkey({ modkey, "Shift" }, "Print", function()
    return require("module.autorandr").toggle_listener()
  end, { description = "Start/Stop autorandr", group = "awesome" }),

  gkey({}, "Print", function()
    return spawn.async(apps.default.region_screenshot, function(_, stderr, reason, code)
      if not spawn.is_normal_exit(reason, code) then return end
      local path = stderr:match("flameshot: info: Capture saved as ([^\n]*)") ---@type string?
      if not path then return end
      return spawn.nosn({ "xclip", "-selection", "clipboard" }, { -- Copy to clipboard using xclip
        stdin_string = path,
        exit_callback_err = function(_, xcode)
          return notifs.info(("Copying screenshot path to clipboard failed. Exit code: %d"):format(xcode))
        end,
        on_failure_callback = function(err)
          local msg = ("Xclip must be installed to copy to clipboard.\nError: "):format(err)
          return notifs.warn_once(msg, { title = "xclip failed to spawn!" })
        end,
      })
    end)
  end, { description = "Mark an area and screenshot it to your clipboard", group = "launcher" }),
  gkey({ modkey }, "e", apps.open.editor, { description = "Open an editor", group = "launcher" }),
  gkey({ modkey }, "b", apps.open.browser, { description = "Open a browser", group = "launcher" }),
  gkey({ modkey }, "Return", apps.open.terminal, { description = "Open a terminal", group = "launcher" }),
  gkey({ modkey }, "x", apps.open.terminal, { description = "Open a terminal", group = "launcher" }),
  gkey(
    { modkey },
    "F12",
    bind(capi.awesome.emit_signal, "quake::toggle"),
    { description = "Open a quake terminal", group = "launcher" }
  ),
  gkey({ modkey }, "l", function()
    return atag.incmwfact(0.05)
  end, { description = "Increase master width factor", group = "layout" }),
  gkey({ modkey }, "h", function()
    return atag.incmwfact(-0.05)
  end, { description = "Decrease master width factor", group = "layout" }),
  gkey({ modkey, "Shift" }, "h", function()
    return atag.incnmaster(1, nil, true)
  end, { description = "Increase the number of master clients", group = "layout" }),
  gkey({ modkey, "Shift" }, "l", function()
    return atag.incnmaster(-1, nil, true)
  end, { description = "Decrease the number of master clients", group = "layout" }),
  gkey({ modkey, "Control" }, "h", function()
    return atag.incncol(1, nil, true)
  end, { description = "Increase the number of columns", group = "layout" }),
  gkey({ modkey, "Control" }, "l", function()
    return atag.incncol(-1, nil, true)
  end, { description = "Decrease the number of columns", group = "layout" }),

  gkey({ modkey }, "=", function()
    return atag.incgap(5)
  end, { description = "Increase the gaps between windows", group = "layout" }),
  gkey({ modkey, "Shift" }, "=", function()
    return atag.incgap(1)
  end, { description = "Increase the gaps between windows by 1", group = "layout" }),

  gkey({ modkey }, "-", function()
    -- if <5, set to 0
    for _ = 1, 5 do
      atag.incgap(-1)
    end
  end, { description = "Decrease the gaps between windows", group = "layout" }),
  gkey({ modkey, "Shift" }, "-", function()
    return atag.incgap(-1)
  end, { description = "Decrease the gaps between windows by 1", group = "layout" }),

  gkey({ modkey }, "space", function()
    return alayout.inc(1)
  end, { description = "Select next", group = "layout" }),
  gkey({ modkey, "Shift" }, "space", function()
    return alayout.inc(-1)
  end, { description = "Select previous", group = "layout" }),

  gkey({ modkey, "Control" }, "n", function()
    local c = aclient.restore()
    -- Focus restored client
    if c then return c:emit_signal("request::activate", "key.unminimize", { raise = true }) end
  end, { description = "Restore minimized", group = "client" }),

  -- Brightness
  gkey({}, "XF86MonBrightnessUp", function()
    return spawn.nosn(apps.default.brightness.up)
  end, { description = "Brightness up", group = "hotkeys" }),
  gkey({}, "XF86MonBrightnessDown", function()
    return spawn.nosn(apps.default.brightness.down)
  end, { description = "Brightness down", group = "hotkeys" }),
  -- volume control
  gkey({}, "XF86AudioRaiseVolume", function()
    return spawn.nosn(apps.default.volume.up)
  end, { description = "Volume up", group = "hotkeys" }),
  gkey({}, "XF86AudioLowerVolume", function()
    return spawn.nosn(apps.default.volume.down)
  end, { description = "Volume down", group = "hotkeys" }),
  gkey({}, "XF86AudioMute", function()
    return spawn.nosn(apps.default.volume.toggle_mute)
  end, { description = "Toggle mute", group = "hotkeys" }),

  gkey({}, "XF86AudioPlay", function()
    return spawn.nosn({ "playerctl", "play-pause" })
  end, { description = "Play/Pause Audio Track", group = "hotkeys" }),
  gkey({}, "XF86AudioNext", function()
    return spawn.nosn({ "playerctl", "next" })
  end, { description = "Next Audio Track", group = "hotkeys" }),
  gkey({}, "XF86AudioPrev", function()
    return spawn.nosn({ "playerctl", "previous" })
  end, { description = "Previous Audio Track", group = "hotkeys" }),
  gkey({}, "XF86PowerDown", function()
    return require("module.exit-screen").show()
  end, { description = "Open Poweroff Menu", group = "hotkeys" }),
  gkey({}, "XF86PowerOff", function()
    return require("module.exit-screen").show()
  end, { description = "Open Poweroff Menu", group = "hotkeys" }),

  -- Custom hotkeys
  -- Emoji Picker
  gkey({ modkey }, "a", function()
    return spawn({ "ibus", "emoji" })
  end, { description = "Open the ibus emoji picker to copy an emoji to your clipboard", group = "hotkeys" }),
  gkey({ modkey, "Shift" }, "`", function()
    local s = ascreen.focused() ---@type AwesomeScreenInstance?
    local tl = s and get_child_by_id(s.top_panel, "taglist")
    if not tl then return end
    tl.visible = not tl.visible
  end, { description = "Toggle the taglist visiblity", group = "hotkeys" })
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
  local num = "#" .. i + 9
  globalKeys = gtable.join(
    globalKeys,
    -- View tag only.
    gkey({ modkey }, num, bind.with_args(tags.show_tag, i), descr_view),
    -- Toggle tag display.
    gkey({ modkey, "Control" }, num, bind.with_args(tags.show_tag, i, true), descr_toggle),
    -- Move client to tag.
    gkey({ modkey, "Shift" }, num, function()
      local c = capi.client.focus
      local tag = c and tags.get_tag(i, c)
      if not c or not tag then return end
      if tag then return c:move_to_tag(tag) end
    end, descr_move),
    -- Move client to tag and focus
    gkey({ modkey, "Control", "Shift" }, num, function()
      local c = capi.client.focus
      local tag = c and tags.get_tag(i, c)
      if not c or not tag then return end
      c:move_to_tag(tag)
      return c:jump_to()
    end, descr_move_view),
    -- Toggle tag on focused client.
    gkey({ modkey, "Control", altkey }, num, function()
      local c = capi.client.focus
      local tag = c and tags.get_tag(i, c)
      if not c or not tag then return end
      return c:toggle_tag(tag)
    end, descr_toggle_focus),
    -- Move next spawned window to tag.
    gkey({ modkey, altkey }, num, bind.with_args(setup_next_spawned_handler, i), descr_next_spawned),
    -- Move next spawned window to tag. Don't focus.
    gkey(
      { modkey, "Shift", altkey },
      num,
      bind.with_args(setup_next_spawned_handler, i, false),
      descr_next_spawned_no_jump
    )
  )
end

return globalKeys
