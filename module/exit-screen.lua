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
local compat = require("util.compat")

-- Appearance
local icon_size = beautiful.exit_screen_icon_size or dpi(140)

---Build a clickable button for the exit screen
---@param icon string the path to the icon to show
---@param text string the text to display under the button
---@param on_release function? passed to connect_signal button::release.
---Passing this ensures only the icon/margin is clickable, rather than the caption below.
---@return table button the button widget to show on the exit_screen
local function buildButton(icon, text, on_release)
  local clickable = wibox.widget({
    widget = clickable_container,
    shape = gshape.circle,
    forced_width = icon_size,
    forced_height = icon_size,
    {
      widget = wibox.container.margin,
      margins = dpi(16),
      wibox.widget.imagebox(icon),
    },
  })
  local widget = wibox.widget({
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

  if on_release then clickable:connect_signal("button::release", on_release) end

  return widget
end

-- Create the widget
local exit_screen = wibox({
  visible = false,
  ontop = true,
  type = "splash",
})
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

capi.screen.connect_signal("primary_changed", update_wibox_screen)
update_wibox_screen(capi.screen.primary)

local bg = beautiful.exit_screen_bg or beautiful.wibar_bg or beautiful.bg_normal or "#000000"
exit_screen.bg = bg:match("^#......") .. "DD" -- light transparency
exit_screen.fg = beautiful.exit_screen_fg or beautiful.wibar_fg or beautiful.fg_normal or "#FEFEFE"

local exit_screen_grabber

local function exit_screen_hide()
  akeygrabber.stop(exit_screen_grabber)
  exit_screen.visible = false
end

local function exit_command()
  exit_screen_hide()
  capi.awesome.quit(0)
end
local function lock_command()
  exit_screen_hide()
  apps.open.lock()
end
local function suspend_command()
  exit_screen_hide()
  apps.open.lock() -- This doesn't block
  systemctl_cmd("suspend-then-hibernate")
end
local function poweroff_command()
  exit_screen_hide()
  systemctl_cmd("poweroff")
end
local function reboot_command()
  exit_screen_hide()
  systemctl_cmd("reboot")
end

local poweroff = buildButton(icons.power, "Poweroff (p)", handle_error(poweroff_command))
local reboot = buildButton(icons.restart, "Restart (r)", handle_error(reboot_command))
local suspend = buildButton(icons.sleep, "Suspend-Then-Hibernate (s)", handle_error(suspend_command))
local exit = buildButton(icons.logout, "Exit AWM (e)", handle_error(exit_command))
local lock = buildButton(icons.lock, "Lock (l)", handle_error(lock_command))

local function exit_screen_show()
  exit_screen_grabber = akeygrabber.run(handle_error(function(mods, key, event)
    if event == "release" or not #mods == 0 then return false end

    if key == "s" then
      return suspend_command()
    elseif key == "e" then
      return exit_command()
    elseif key == "l" then
      return lock_command()
    elseif key == "p" then
      return poweroff_command()
    elseif key == "r" then
      return reboot_command()
    elseif key == "Escape" or key == "q" or key == "x" then
      return exit_screen_hide()
    end
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
      poweroff,
      reboot,
      suspend,
      exit,
      lock,
      layout = wibox.layout.fixed.horizontal,
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
