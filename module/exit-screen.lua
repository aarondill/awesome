local apps = require("configuration.apps")
local awful = require("awful")
local beautiful = require("beautiful")
local clickable_container = require("widget.material.clickable-container")
local gears = require("gears")
local icons = require("theme.icons")
local wibox = require("wibox")
local dpi = require("beautiful").xresources.apply_dpi
local handle_error = require("util.handle_error")
local spawn = require("util.spawn")

-- Appearance
local icon_size = beautiful.exit_screen_icon_size or dpi(140)

---Build a clickable button for the exit screen
---@param icon string the path to the icon to show
---@param text string the text to display under the button
---@param on_release function? passed to connect_signal button::release.
---Passing this ensures only the icon/margin is clickable, rather than the caption below.
---@return table button the button widget to show on the exit_screen
local function buildButton(icon, text, on_release)
  local imagebox = wibox.widget({
    widget = wibox.container.margin,
    margins = dpi(16),
    wibox.widget.imagebox(icon),
  })
  local clickable = wibox.widget({
    widget = clickable_container,
    shape = gears.shape.circle,
    forced_width = icon_size,
    forced_height = icon_size,
    imagebox,
  })
  local widget = wibox.widget({
    {
      widget = wibox.container.margin,
      left = dpi(24),
      right = dpi(24),
      clickable,
    },
    gears.table.crush({
      widget = wibox.widget.textbox,
      text = text,
      valign = "center",
    }, awesome.version <= "v4.3" and { align = "center" } or { halign = "center" }),
    layout = wibox.layout.fixed.vertical,
  })

  if on_release then clickable:connect_signal("button::release", on_release) end

  return widget
end

-- Get screen geometry
local screen_geometry = awful.screen.focused().geometry

-- Create the widget
local exit_screen = wibox({
  screen = 1,
  x = screen_geometry.x,
  y = screen_geometry.y,
  visible = false,
  ontop = true,
  type = "splash",
  height = screen_geometry.height,
  width = screen_geometry.width,
})
screen.connect_signal("property::geometry", function()
  local s = screen[1]
  exit_screen.width = s.geometry.width
  exit_screen.x = s.geometry.x
  exit_screen.y = s.geometry.y
end)

exit_screen.bg = beautiful.background.hue_800 .. "dd"
exit_screen.fg = beautiful.exit_screen_fg or beautiful.wibar_fg or "#FEFEFE"

local exit_screen_grabber

local function exit_screen_hide()
  awful.keygrabber.stop(exit_screen_grabber)
  exit_screen.visible = false
end

---@param systemctl_cmd string?
local function suspend_command(systemctl_cmd)
  systemctl_cmd = systemctl_cmd or "suspend-then-hibernate"
  exit_screen_hide()
  spawn(apps.default.lock, { sn_rules = false }) -- This doesn't block
  local cb = function(_, code)
    -- Spawn without sudo if original fails
    if not code or code == 1 then spawn({ "systemctl", systemctl_cmd }, { sn_rules = false }) end
  end
  -- Try with sudo incase no password is needed (for hibernate)
  local pid = spawn({ "sudo", "-n", "--", "systemctl", systemctl_cmd }, { sn_rules = false, exit_callback = cb })
  if type(pid) == "string" then cb() end -- If sudo is not found
end
local function exit_command()
  exit_screen_hide()
  awesome.quit(0)
end
local function lock_command()
  exit_screen_hide()
  spawn(apps.default.lock, { sn_rules = false })
end
local function poweroff_command()
  exit_screen_hide()
  spawn("poweroff", { sn_rules = false })
end
local function reboot_command()
  exit_screen_hide()
  spawn("reboot", { sn_rules = false })
end

local poweroff = buildButton(icons.power, "Poweroff (p)", handle_error(poweroff_command))
local reboot = buildButton(icons.restart, "Restart (r)", handle_error(reboot_command))
local suspend = buildButton(icons.sleep, "Suspend (s)", handle_error(suspend_command))
local exit = buildButton(icons.logout, "Exit AWM (e)", handle_error(exit_command))
local lock = buildButton(icons.lock, "Lock (l)", handle_error(lock_command))

local function exit_screen_show()
  exit_screen_grabber = awful.keygrabber.run(handle_error(function(mods, key, event)
    if event == "release" or not #mods == 0 then return false end

    if key == "s" then
      suspend_command()
    elseif key == "e" then
      exit_command()
    elseif key == "l" then
      lock_command()
    elseif key == "p" then
      poweroff_command()
    elseif key == "r" then
      reboot_command()
    elseif key == "Escape" or key == "q" or key == "x" then
      exit_screen_hide()
    end
  end))
  exit_screen.visible = true
end

exit_screen:buttons(gears.table.join(
  -- Middle click - Hide exit_screen
  awful.button({}, 2, function()
    exit_screen_hide()
  end),
  -- Right click - Hide exit_screen
  awful.button({}, 3, function()
    exit_screen_hide()
  end)
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
