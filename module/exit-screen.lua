local abutton = require("awful.button")
local akeygrabber = require("awful.keygrabber")
local apps = require("configuration.apps")
local beautiful = require("beautiful")
local capi = require("capi")
local clickable_container = require("widget.material.clickable-container")
local gshape = require("gears.shape")
local gtable = require("gears.table")
local handle_error = require("util.handle_error")
local icons = require("theme.icons")
local systemctl_cmd = require("util.systemctl_cmd")
local wibox = require("wibox")
local dpi = require("beautiful").xresources.apply_dpi
local bind = require("util.bind")
local compat = require("util.compat")
local tables = require("util.tables")

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
---@param key ExitScreenKey
---@param type 'key'|'click'
local function run_cmd(key, type)
  exit_screen_hide() -- Always hide the exit screen first!
  if not key.cmd then return end
  return key:cmd(type)
end

---Build a clickable button for the exit screen
---@param key ExitScreenKey
---@return table button the button widget to show on the exit_screen
local function buildButton(key)
  local title = key[1] or "<No Text Provided>"
  local k = key[2]
  local text = k and ("%s (%s)"):format(title, k) or title
  local clickable = wibox.widget({
    widget = clickable_container,
    shape = gshape.circle,
    forced_width = icon_size,
    forced_height = icon_size,
    {
      widget = wibox.container.margin,
      margins = dpi(16),
      wibox.widget.imagebox(key.icon),
    },
  })
  clickable:connect_signal("button::release", bind.with_args(run_cmd, key, "click"))
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
  if not s then return end
  if exit_screen.screen ~= s then
    if exit_screen.screen then -- Ensure the screen is good
      exit_screen.screen:disconnect_signal("property::geometry", update_wibox_screen)
    end
    s:connect_signal("property::geometry", update_wibox_screen)
  end
  local screen_geometry = s.geometry
  exit_screen.x = screen_geometry.x
  exit_screen.y = screen_geometry.y
  exit_screen.height = screen_geometry.height
  exit_screen.width = screen_geometry.width
  exit_screen.screen = s
end

capi.screen.connect_signal("primary_changed", function(s) ---@param s AwesomeScreenInstance
  ---This handler gets called twice. Once on the old screen and once on the new screen
  ---If this is the old screen, ignore it, wait until the new screen is called.
  if s ~= capi.screen.primary then return end
  return update_wibox_screen(s)
end)
update_wibox_screen(capi.screen.primary)

local bg = beautiful.exit_screen_bg or beautiful.wibar_bg or beautiful.bg_normal or "#000000"
exit_screen.bg = bg:match("^#......") .. "DD" -- light transparency
exit_screen.fg = beautiful.exit_screen_fg or beautiful.wibar_fg or beautiful.fg_normal or "#FEFEFE"

local function suspend_command()
  apps.open.lock()
  return systemctl_cmd("suspend-then-hibernate")
end

---@class ExitScreenKey
---@field [1] string the display text of the button (note: the key will be appended)
---@field [2]? string the key to be pressed
---@field cmd? fun(self: ExitScreenKey, type: 'click'|'key'): any
---@field icon? string The path to the icon to be displayed

---@type string[]|true
---Note: if exit_keys is `true` then any unrecognized keys will exit
local exit_keys = true --- { "Escape", "q", "x" }
local keys = { ---@type ExitScreenKey[]
  { "Poweroff", "p", cmd = bind.with_args(systemctl_cmd, "poweroff"), icon = icons.power },
  { "Restart", "r", cmd = bind.with_args(systemctl_cmd, "reboot"), icon = icons.restart },
  { "Suspend-Then-Hibernate", "s", cmd = suspend_command, icon = icons.sleep },
  { "Exit AWM", "e", cmd = bind.with_args(capi.awesome.quit, 0), icon = icons.logout },
  { "Lock", "l", cmd = apps.open.lock, icon = icons.lock },
}
local buttons = tables.map(keys, buildButton) -- Note: keeps order of keys array

local function exit_screen_show()
  exit_screen_grabber = akeygrabber.run(handle_error(function(mods, key, event)
    if event == "release" or not #mods == 0 then return false end -- this isn't my event!

    for _, v in ipairs(keys) do
      if key == v[2] then
        run_cmd(v, "key") -- call the cmd
        return true -- we handled this event
      end
    end

    if exit_keys == true or gtable.hasitem(exit_keys, key) then
      exit_screen_hide()
      return true -- we handled this event
    end

    return false -- we didn't handle this event
  end))
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
