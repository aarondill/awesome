local abutton = require("awful.button")
local akeygrabber = require("awful.keygrabber")
local ascreen = require("awful.screen")
local beautiful = require("beautiful")
local bind = require("util.bind")
local clickable_container = require("widget.material.clickable-container")
local compat = require("util.compat")
local exit_screen_conf = require("configuration.exit-screen")
local get_screen = require("util.get_screen")
local gshape = require("gears.shape")
local gtable = require("gears.table")
local handle_error = require("util.handle_error")
local tables = require("util.tables")
local wibox = require("wibox")
local dpi = require("beautiful").xresources.apply_dpi
local capi = require("capi")

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

-- Appearance
local icon_size = beautiful.exit_screen_icon_size or dpi(140)

-- Create the widget
local exit_screen = wibox({
  visible = false,
  ontop = true,
  type = "splash",
})
local exit_screen_grabber
local function exit_screen_hide()
  akeygrabber.stop(exit_screen_grabber)
  exit_screen.visible = false
end
---@param button ExitScreenButton
---@param type 'key'|'click'
local function run_cmd(button, type)
  exit_screen_hide() -- Always hide the exit screen first!
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
  if not s and exit_screen.screen.valid then return end -- no s given and we have a valid screen already
  s = s or get_screen.focused() or get_screen.primary() -- Switch to focused screen if previous screen was removed
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

local bg = exit_screen_conf.bg or beautiful.exit_screen_bg or beautiful.wibar_bg or beautiful.bg_normal or "#000000"

local opacity = exit_screen_conf.opacity or beautiful.exit_screen_opacity or 0.62
-- Convert a 0-1 number to hexadecimal
local alpha = type(opacity) == "number" and string.format("%X", math.floor(opacity * 255)) or opacity
exit_screen.bg = bg:find("^#%x+$") and bg:match("^#......") .. alpha or bg -- light transparency if we can parse it, else give up
exit_screen.fg = exit_screen_conf.fg
  or beautiful.exit_screen_fg
  or beautiful.wibar_fg
  or beautiful.fg_normal
  or "#FEFEFE"

local buttons = tables.map(exit_screen_conf.buttons, buildButton) -- Note: keeps order of buttons array

---@param opts? {screen?: screen}
local function exit_screen_show(opts)
  opts = opts or {}
  local screen = get_screen.get(opts.screen) or get_screen.focused()
  update_wibox_screen(screen)
  ---@param mods string[]
  ---@param key string
  ---@param event "release"|"press"
  exit_screen_grabber = akeygrabber.run(function(mods, key, event)
    if event == "release" or not #mods == 0 then return false end -- this isn't my event!
    -- if exit_screen.screen ~= get_screen.focused() then return false end -- ignore non-focused events

    for _, button in ipairs(exit_screen_conf.buttons) do
      if key == button[2] then
        run_cmd(button, "key") -- call the cmd
        return true -- we handled this event
      end
    end

    if exit_screen_conf.exit_keys == true or gtable.hasitem(exit_screen_conf.exit_keys, key) then
      exit_screen_hide()
      return true -- we handled this event
    end

    return false -- we didn't handle this event
  end)
  exit_screen.visible = true
end

exit_screen:buttons(gtable.join(
  -- Middle click - Hide exit_screen
  abutton({}, 2, exit_screen_hide),
  -- Right click - Hide exit_screen
  abutton({}, 3, exit_screen_hide)
))
-- Item placement
exit_screen:setup({
  nil, -- No top
  {
    nil, -- No left
    { -- This should be centered
      layout = wibox.layout.fixed.horizontal,
      table.unpack(buttons), -- Note: this must be last!
    },
    nil, -- No right
    expand = "none",
    layout = wibox.layout.align.horizontal,
  },
  nil, -- No bottom
  expand = "none",
  layout = wibox.layout.align.vertical,
})

return { show = exit_screen_show, hide = exit_screen_hide }
