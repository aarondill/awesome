local Battery = require("widget.battery")
local Brightness = require("widget.brightness")
local CPU = require("widget.cpu")
local LayoutBox = require("widget.layout-box")
local MediaControl = require("widget.media-control")
local QuakeButton = require("widget.quake-button")
local Run_prompt = require("widget.run-prompt")
local TagList = require("widget.tag-list")
local TaskList = require("widget.task-list")
local apps = require("configuration.apps")
local beautiful = require("beautiful")
local calendar_popup = require("awful.widget.calendar_popup")
local clickable_container = require("widget.material.clickable-container")
local icons = require("theme.icons")
local launcher = require("widget.launcher")
local make_clickable_if_prog = require("util.make_clickable_if_prog")
local spawn = require("util.spawn")
local wibox = require("wibox")
local dpi = require("beautiful").xresources.apply_dpi

local TopPanel = function(s)
  local panel = wibox({
    ontop = true,
    screen = s,
    height = dpi(32),
    width = s.geometry.width,
    x = s.geometry.x,
    y = s.geometry.y,
    stretch = false,
    bg = beautiful.bg_normal,
    fg = beautiful.fg_normal,
  })
  panel:struts({ top = dpi(32) })
  local clock_widget = wibox.widget({
    {
      -- 24h format: %H:%M
      -- 12h fornat: %I:%M %p
      -- dd/mm/yyyy: %d/%m/%Y
      format = '<span font="Roboto Mono 12">%I:%M %p</span>',
      refresh = 30, -- TRY to fix issues with refresh after suspend
      widget = wibox.widget.textclock,
    },
    left = dpi(13),
    right = dpi(13),
    top = dpi(9),
    bottom = dpi(9),
    widget = wibox.container.margin,
  })
  local month_calendar = calendar_popup.month({ start_sunday = true, week_numbers = false }):attach(clock_widget)

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
      { widget = launcher },
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
      {
        {
          horizontal = true,
          base_size = dpi(20),
          -- forced_height = dpi(20),
          widget = wibox.widget.systray,
        },
        left = dpi(3),
        right = dpi(3),
        top = dpi(6),
        bottom = dpi(3),
        widget = wibox.container.margin,
      },
      -- Layout box
      LayoutBox(s),
      { widget = QuakeButton },
      -- Clock
      clock_widget,
      battery_widget,
      cpu_widget,
      {
        Brightness({
          step = 5,
          timeout = 10,
          levels = { 5, 25, 50, 75, 100 },
        }),
        widget = clickable_container,
      },
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
    spawn.noninteractive(apps.default.calendar)
  end)

  -- Check if battery_manager is available
  make_clickable_if_prog(apps.default.battery_manager, battery_widget, panel.widget, function(_)
    spawn.noninteractive(apps.default.battery_manager)
  end)

  -- Check if system_manager is available
  make_clickable_if_prog(apps.default.system_manager, cpu_widget, panel.widget, function(_)
    spawn.noninteractive(apps.default.system_manager)
  end)

  return panel
end

return TopPanel
