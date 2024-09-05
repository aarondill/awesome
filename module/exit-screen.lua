local abutton = require("awful.button")
local akeygrabber = require("awful.keygrabber")
local beautiful = require("beautiful")
local bind = require("util.bind")
local clickable_container = require("widget.material.clickable-container")
local compat = require("util.awesome.compat")
local exit_screen_conf = require("configuration.exit-screen")
local gshape = require("gears.shape")
local gtable = require("gears.table")
local gtimer = require("gears.timer")
local notifs = require("util.notifs")
local screen = require("util.types.screen")
local spawn = require("util.spawn")
local stream = require("stream")
local strings = require("util.strings")
local wibox = require("wibox")
local dpi = require("beautiful").xresources.apply_dpi
local GLib = require("lgi").GLib

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

local M = { disabled = false }

-- Appearance
local icon_size = beautiful.exit_screen_icon_size or dpi(140)

-- Create the widget
M.exit_screen = wibox({
  visible = false,
  ontop = true,
  type = "splash",
})

local uptime_textbox = wibox.widget({
  text = "Loading...",
  font = beautiful.title_font,
  valign = "center",
  [compat.widget.halign] = "center",
  widget = wibox.widget.textbox,
})
local function update_uptime()
  spawn.async_success("uptime -p", function(stdout)
    local uptime = strings.trim(stdout:match("up (.*)\n"))
    uptime_textbox:set_markup(("<b>Uptime</b>: %s"):format(GLib.markup_escape_text(uptime, -1)))
  end)
end
local uptime_timer = gtimer.new({ timeout = 30, callback = update_uptime })

local exit_screen_grabber
function M.hide()
  akeygrabber.stop(exit_screen_grabber)
  uptime_timer:stop()
  M.exit_screen.visible = false
end
---@param button ExitScreenButton
---@param type 'key'|'click'
local function run_cmd(button, type)
  M.hide() -- Always hide the exit screen first!
  if not button.cmd then return end
  return button:cmd(type)
end

---Build a clickable button for the exit screen
---@param button ExitScreenButton
---@return table button_widget the button widget to show on the exit_screen
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
      wibox.widget.imagebox(button.icon),
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

local function update_wibox_screen(s) ---@param s AwesomeScreenInstance?
  if not s and M.exit_screen.screen.valid then return end -- no s given and we have a valid screen already
  s = s or screen.focused() or screen.primary() -- Switch to focused screen if previous screen was removed
  if not s or not s.valid then return end
  if M.exit_screen.screen ~= s then
    if M.exit_screen.screen then -- Ensure the screen is good
      M.exit_screen.screen:disconnect_signal("property::geometry", update_wibox_screen)
    end
    s:connect_signal("property::geometry", update_wibox_screen)
  end
  local screen_geometry = s.geometry
  M.exit_screen:geometry({
    x = screen_geometry.x,
    y = screen_geometry.y,
    height = screen_geometry.height,
    width = screen_geometry.width,
  })
  M.exit_screen.screen = s
  M.exit_screen:emit_signal("widget::redraw_needed")
end

local bg = exit_screen_conf.bg or beautiful.exit_screen_bg or beautiful.wibar_bg or beautiful.bg_normal or "#000000"

local opacity = exit_screen_conf.opacity or beautiful.exit_screen_opacity or 0.62
-- Convert a 0-1 number to hexadecimal
local alpha = type(opacity) == "number" and string.format("%X", math.floor(opacity * 255)) or opacity
M.exit_screen.bg = bg:find("^#%x+$") and bg:match("^#......") .. alpha or bg -- light transparency if we can parse it, else give up
M.exit_screen.fg = exit_screen_conf.fg
  or beautiful.exit_screen_fg
  or beautiful.wibar_fg
  or beautiful.fg_normal
  or "#FEFEFE"

function M.enable() M.disabled = false end
---@param toggle boolean? default: true
function M.disable(toggle)
  if toggle == nil then toggle = true end
  if not toggle and M.disabled then return end -- already disabled
  M.disabled = not M.disabled -- toggle it
end

---@param opts? {screen?: screen}
function M.show(opts)
  if M.disabled then return notifs.warn("exit screen is disabled!") end -- exit screen is disabled
  do -- get the uptime. Do this first because it's async!!
    uptime_timer:emit_signal("timeout") -- force an update
    uptime_timer:start()
  end
  opts = opts or {}
  local s = screen.get(opts.screen) or screen.focused()
  update_wibox_screen(s)
  ---@param mods string[]
  ---@param key string
  ---@param event "release"|"press"
  exit_screen_grabber = akeygrabber.run(function(mods, key, event)
    if event == "release" or not #mods == 0 then return false end -- this isn't my event!
    -- if exit_screen.screen ~= screen.focused() then return false end -- ignore non-focused events

    for _, button in ipairs(exit_screen_conf.buttons) do
      if key == button[2] then
        run_cmd(button, "key") -- call the cmd
        return true -- we handled this event
      end
    end

    if exit_screen_conf.exit_keys == true or gtable.hasitem(exit_screen_conf.exit_keys, key) then
      M.hide()
      return true -- we handled this event
    end

    return false -- we didn't handle this event
  end)
  M.exit_screen.visible = true
end

M.exit_screen:buttons(gtable.join(
  -- Middle click - Hide exit_screen
  abutton({}, 2, M.hide),
  -- Right click - Hide exit_screen
  abutton({}, 3, M.hide)
))

-- Item placement
M.exit_screen:setup({
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
  nil, -- No bottom
  expand = "none",
  layout = wibox.layout.align.vertical,
})

return M
