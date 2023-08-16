local Battery = require("widget.battery")
local CPU = require("widget.cpu")
local LayoutBox = require("widget.layout-box")
local MediaControl = require("widget.media-control")
local Run_prompt = require("widget.run-prompt")
local TagList = require("widget.tag-list")
local TaskList = require("widget.task-list")
local apps = require("configuration.apps")
local awful = require("awful")
local beautiful = require("beautiful")
local launcher = require("widget.launcher")
local make_clickable_if_prog = require("util.make_clickable_if_prog")
local mat_clickable_cont = require("widget.material.clickable-container")
local notifs = require("util.notifs")
local spawn = require("util.spawn")
local wibox = require("wibox")
local dpi = require("beautiful").xresources.apply_dpi
local has_brightness, Brightness = pcall(require, "widget.brightness")
local icons = require("theme.icons")

local brightness_widget = nil
if awesome.version <= "v4.3" and has_brightness then -- HACK: broken in awesome-git
  brightness_widget = mat_clickable_cont(Brightness({
    step = 5,
    timeout = 10,
    levels = { 5, 25, 50, 75, 100 },
  }))
else
  notifs.info("Brightness is broken in awesome-git")
end

-- Titus - Horizontal Tray
local systray = wibox.widget.systray()
systray:set_horizontal(true)
systray:set_base_size(dpi(20))
-- systray.forced_height = dpi(20)

-- Clock / Calendar 24h format
-- local textclock = wibox.widget.textclock('<span font="Roboto Mono bold 9">%d.%m.%Y\n     %H:%M</span>')
-- Clock / Calendar 12AM/PM fornat
local textclock = wibox.widget.textclock('<span font="Roboto Mono 12">%I:%M %p</span>')
-- textclock.forced_height = 36

-- Add a calendar (credits to kylekewley for the original code)
local month_calendar = awful.widget.calendar_popup.month({
  start_sunday = true,
  week_numbers = false,
})

local clock_widget = wibox.container.margin(textclock, dpi(13), dpi(13), dpi(9), dpi(8))
month_calendar:attach(clock_widget)

local TopPanel = function(s)
  local panel = wibox({
    ontop = true,
    screen = s,
    height = dpi(32),
    width = s.geometry.width,
    x = s.geometry.x,
    y = s.geometry.y,
    stretch = false,
    bg = (beautiful.background or {}).hue_800,
    fg = beautiful.fg_normal,
  })

  panel:struts({
    top = dpi(32),
  })

  -- Empty widget to replace with the battery when it's ready
  local battery_widget = Battery({ timeout = 15 })
  local cpu_widget = CPU({
    timeout = 15,
    precision = 1,
    prefix = "",
    suffix = "%",
  })
  panel:setup({
    layout = wibox.layout.align.horizontal,
    {
      layout = wibox.layout.fixed.horizontal,
      launcher(s),
      TagList(s),
      Run_prompt(s),
    },
    TaskList({ screen = s, max_width = dpi(150) }),
    {
      layout = wibox.layout.fixed.horizontal,
      MediaControl:new({
        play_icon = icons.play,
        stop_icon = icons.stop,
        pause_icon = icons.pause,
      }),
      wibox.container.margin(systray, dpi(3), dpi(3), dpi(6), dpi(3)),
      -- Layout box
      LayoutBox(s),
      -- Clock
      clock_widget,
      battery_widget,
      cpu_widget,
      brightness_widget,
    },
  })
  s:connect_signal("property::geometry", function()
    panel.width = s.geometry.width
    panel.x = s.geometry.x
    panel.y = s.geometry.y
  end)

  -- Setup click click handler if calendar is installed
  make_clickable_if_prog(apps.default.calendar, clock_widget, panel.widget, function(_)
    -- Hide the calendar on click (won't hide otherwise)
    month_calendar.visible = false
    -- needed to ensure it reapears on next mouse-over
    month_calendar._calendar_clicked_on = false
    spawn(apps.default.calendar, {
      inherit_stderr = false,
      inherit_stdout = false,
    })
  end)

  -- Check if battery_manager is available
  make_clickable_if_prog(apps.default.battery_manager, battery_widget, panel.widget, function(_)
    spawn(apps.default.battery_manager, {
      inherit_stderr = false,
      inherit_stdout = false,
    })
  end)

  -- Check if system_manager is available
  make_clickable_if_prog(apps.default.system_manager, cpu_widget, panel.widget, function(_)
    spawn(apps.default.system_manager, {
      inherit_stderr = false,
      inherit_stdout = false,
    })
  end)

  return panel
end

return TopPanel
