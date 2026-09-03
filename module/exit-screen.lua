local abutton = require("awful.button")
local akey = require("awful.key")
local akeygrabber = require("awful.keygrabber")
local beautiful = require("beautiful")
local bind = require("util.bind")
local capi = require("capi")
local clickable_container = require("widget.material.clickable-container")
local compat = require("util.awesome.compat")
local exit_screen_conf = require("configuration.exit-screen")
local gshape = require("gears.shape")
local gtimer = require("gears.timer")
local mat_icon = require("widget.material.icon")
local notifs = require("util.notifs")
local screen = require("util.types.screen")
local spawn = require("util.spawn")
local stream = require("stream")
local strings = require("util.strings")
local wibox = require("wibox")
local widgets = require("util.awesome.widgets")
local dpi = require("beautiful").xresources.apply_dpi
local GLib = require("lgi").GLib
local tables = require("util.tables")

local M = {}

---@class ExitScreenConf
---if `true` then any unrecognized keys will exit
---@field exit_keys string[]|true
---@field buttons ExitScreenButton[]
---@field opacity number|string? A number between 0-1 or a hexadecimal number between 00-FF. Note: this overrides the theme
---@field fg string? A 6-digit hex color starting with #. Note: this overrides the theme
---@field bg string? A 6-digit hex color starting with #. Note: this overrides the theme

---@class ExitScreenButton
---@field [1] string the display text of the button (note: the key will be appended)
---@field [2]? string the key to be pressed
---@field cmd? fun(self: ExitScreenButton, type: 'click'|'key'): any
---@field icon? string The path to the icon to be displayed

M.disabled = false

-- Appearance
local icon_size = beautiful.exit_screen_icon_size or dpi(140)

---@param button ExitScreenButton
---@param type 'key'|'click'
local function run_cmd(button, type)
  M.hide() -- Always hide the exit screen first!
  if not button.cmd then return end
  return button:cmd(type)
end

---Build a clickable button for the exit screen
---@param button ExitScreenButton
---@return widget button_widget the button widget to show on the exit_screen
local function buildButton(button)
  local title = button[1] or "<No Text Provided>"
  local k = button[2]
  local text = k and ("%s (%s)"):format(title, k) or title
  local clickable = wibox.widget({
    widget = clickable_container,
    shape = gshape.circle,
    forced_width = icon_size,
    forced_height = icon_size,
    {
      widget = wibox.container.margin,
      margins = dpi(16),
      {
        image = button.icon,
        widget = mat_icon,
      },
    },
  })
  clickable:connect_signal("button::release", bind.with_args(run_cmd, button, "click"))
  return wibox.widget({
    {
      widget = wibox.container.margin,
      left = dpi(24),
      right = dpi(24),
      clickable,
    },
    {
      widget = wibox.widget.textbox,
      text = text,
      valign = "center",
      [compat.widget.halign] = "center",
    },
    layout = wibox.layout.fixed.vertical,
  })
end

---@type { wibox: wibox, timer: gears.timer }?
local _exit_screen
--- Call to set exit_screen
function M._lazy_init()
  if _exit_screen then return _exit_screen end
  -- Create the widget
  local box = wibox({
    visible = false,
    ontop = true,
    type = "splash",
  })

  ---@type widget.textbox
  local uptime_textbox = wibox.widget({
    text = "Loading...",
    font = beautiful.title_font,
    valign = "center",
    [compat.widget.halign] = "center",
    widget = wibox.widget.textbox,
  })
  local function update_uptime()
    spawn.async_success({ "uptime", "-p" }, function(stdout)
      local uptime = strings.trim(stdout:match("up (.*)\n"))
      uptime_textbox:set_markup(("<b>Uptime</b>: %s"):format(GLib.markup_escape_text(uptime, -1)))
    end)
  end

  ---@type widget
  local inhibit_textbox = wibox.widget({
    {
      {
        { -- Header
          text = "Systemd Inhibitors",
          font = beautiful.title_font,
          [compat.widget.halign] = "center",
          widget = wibox.widget.textbox,
        },
        {
          id = "textbox",
          text = "Loading...",
          font = "monospace", -- This *has* to be monospace!
          valign = "center",
          widget = wibox.widget.textbox,
        },
        layout = wibox.layout.fixed.vertical,
      },
      widget = wibox.container.margin,
      bottom = dpi(16),
    },
    [compat.widget.halign] = "center",
    widget = wibox.container.place,
  })
  local function update_inhibit()
    local pid = spawn.async_success({ "systemd-inhibit", "--list" }, function(stdout)
      local output = stdout:match("^(.+)\n%d inhibitors listed%.\n$") or stdout --- Remove the last two lines (blank and number)
      local textbox = assert(widgets.get_by_id(inhibit_textbox, "textbox")) ---@cast textbox widget.textbox
      textbox:set_text(output)
    end)
    inhibit_textbox.visible = not not pid -- hide if systemd-inhibit didn't spawn
  end

  ---@type gears.timer
  local update_timer = gtimer.new({
    timeout = 30,
    callback = function()
      update_inhibit()
      update_uptime()
    end,
  })
  local bg = exit_screen_conf.bg or beautiful.exit_screen_bg or beautiful.wibar_bg or beautiful.bg_normal or "#000000"

  local opacity = exit_screen_conf.opacity or beautiful.exit_screen_opacity or 0.62
  -- Convert a 0-1 number to hexadecimal
  local alpha = type(opacity) == "number" and string.format("%X", math.floor(opacity * 255)) or opacity
  box.bg = bg:find("^#%x+$") and bg:match("^#......") .. alpha or bg -- light transparency if we can parse it, else give up
  box.fg = exit_screen_conf.fg or beautiful.exit_screen_fg or beautiful.wibar_fg or beautiful.fg_normal or "#FEFEFE"

  box:buttons(tables.join(
    -- Middle click - Hide exit_screen
    abutton({}, 2, M.hide),
    -- Right click M.- Hide exit_screen
    abutton({}, 3, M.hide)
  ))

  box:setup({
    nil, -- No top
    {
      nil, -- No left
      {
        uptime_textbox,
        { -- This should be centered
          layout = wibox.layout.fixed.horizontal,
          stream.new(exit_screen_conf.buttons):map(buildButton):unpack(),
        },
        nil, -- No bottom
        layout = wibox.layout.align.vertical,
      },
      nil, -- No right
      expand = "none",
      layout = wibox.layout.align.horizontal,
    },
    inhibit_textbox, -- No bottom
    expand = "none",
    layout = wibox.layout.align.vertical,
  })
  _exit_screen = { wibox = box, timer = update_timer }
  return _exit_screen
end

local exit_screen_grabber
function M.hide()
  local m = M._lazy_init()
  akeygrabber.stop(exit_screen_grabber)
  m.timer:stop()
  m.wibox.visible = false
end

-- The list of modifiers from https://awesomewm.org/doc/api/classes/awful.keygrabber.html#awful.keygrabber.run
local modifier_keys = {
  "Mod4",
  "Super_L",
  "Super_R",
  "Control",
  "Control_L",
  "Control_R",
  "Shift",
  "Shift_L",
  "Shift_R",
  "Mod1",
  "Alt_L",
  "Alt_R",
}

---@param s AwesomeScreenInstance?
local function update_wibox_screen(s)
  local exit_screen = M._lazy_init().wibox
  if not s and exit_screen.screen.valid then return end -- no s given and we have a valid screen already
  s = s or screen.focused() or screen.primary() -- Switch to focused screen if previous screen was removed
  if not s or not s.valid then return end
  if exit_screen.screen ~= s then
    if exit_screen.screen then -- Ensure the screen is good
      exit_screen.screen:disconnect_signal("property::geometry", update_wibox_screen)
    end
    s:connect_signal("property::geometry", update_wibox_screen)
  end
  local screen_geometry = s.geometry
  exit_screen:geometry({
    x = screen_geometry.x,
    y = screen_geometry.y,
    height = screen_geometry.height,
    width = screen_geometry.width,
  })
  exit_screen.screen = s
  exit_screen:emit_signal("widget::redraw_needed")
end

---@param opts? {screen?: screen}
function M.show(opts)
  if M.disabled then return notifs.warn("exit screen is disabled!") end -- exit screen is disabled
  local m = M._lazy_init()
  do -- get the uptime. Do this first because it's async!!
    m.timer:emit_signal("timeout") -- force an update
    m.timer:start()
  end
  opts = opts or {}
  local s = screen.get(opts.screen) or screen.focused()
  update_wibox_screen(s)
  ---@param mods string[]
  ---@param key string
  ---@param event "release"|"press"
  exit_screen_grabber = akeygrabber.run(function(mods, key, event)
    mods = stream.new(mods):except(function(mod) return tables.contains(akey.ignore_modifiers, mod) end):toarray()
    if event == "release" or #mods ~= 0 then return false end -- this isn't my event!
    if tables.contains(modifier_keys, key) then return false end -- ignore modifier key presses
    -- if exit_screen.screen ~= screen.focused() then return false end -- ignore non-focused events

    for _, button in ipairs(exit_screen_conf.buttons) do
      if key == button[2] then
        run_cmd(button, "key") -- call the cmd
        return true -- we handled this event
      end
    end

    if exit_screen_conf.exit_keys == true or tables.contains(exit_screen_conf.exit_keys, key) then
      M.hide()
      return true -- we handled this event
    end

    return false -- we didn't handle this event
  end)
  m.wibox.visible = true
end

capi.awesome.connect_signal("exit_screen::show", M.show)
capi.awesome.connect_signal("exit_screen::hide", M.hide)

function M.enable() M.disabled = false end
---@param toggle boolean? default: true
function M.disable(toggle)
  if toggle == nil then toggle = true end
  if not toggle and M.disabled then return end -- already disabled
  M.disabled = not M.disabled -- toggle it
end

capi.awesome.connect_signal("exit_screen::enable", M.enable)
capi.awesome.connect_signal("exit_screen::disable", M.disable)
return M
