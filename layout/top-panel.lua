local Battery = require("widget.battery")
local Brightness = require("widget.brightness")
local CPU = require("widget.cpu")
local LayoutBox = require("widget.layout-box")
local MediaControl = require("widget.media-control")
local QuakeButton = require("widget.quake-button")
local Run_prompt = require("widget.run-prompt")
local TagList = require("widget.tag-list.fancy")
local TaskList = require("widget.task-list")
local apps = require("configuration.apps")
local awful_wibar = require("awful.wibar")
local beautiful = require("beautiful")
local calendar_popup = require("awful.widget.calendar_popup")
local get_child_by_id = require("util.get_child_by_id")
local gstring = require("gears.string")
local icons = require("theme.icons")
local launcher = require("widget.launcher")
local make_clickable_if_prog = require("util.make_clickable_if_prog")
local spawn = require("util.spawn")
local suspend_listener = require("module.suspend-listener")
local wibox = require("wibox")
local dpi = require("beautiful").xresources.apply_dpi
local distro = require("widget.distro")
local get_screen = require("util.get_screen")

---@param args {screen: screen}
local TopPanel = function(args)
  local s = get_screen.get(args.screen) or get_screen.focused()
  assert(s, "Could not get screen!")
  local top_panel_height = beautiful.top_panel_height or dpi(32)
  local panel = awful_wibar.new({
    ontop = true,
    screen = s,
    height = top_panel_height,
    width = s.geometry.width,
    x = s.geometry.x,
    y = s.geometry.y,
    stretch = false,
    bg = beautiful.bg_normal,
    fg = beautiful.fg_normal,
    visible = true,
  })
  panel:struts({ top = top_panel_height })
  -- PERF: This (and the instantiations below) takes ~137 milliseconds. It's the main blocker, taking 65% of startup!
  panel:setup({
    layout = wibox.layout.align.horizontal,
    {
      layout = wibox.layout.fixed.horizontal,
      { widget = launcher, id = "launcher" },
      { widget = TagList.new({ screen = s }), id = "taglist" },
      { widget = Run_prompt(), id = "run_prompt" },
    },
    TaskList({ screen = s, max_width = dpi(150) }),
    {
      layout = wibox.layout.fixed.horizontal,
      MediaControl:new({
        play_icon = icons.play,
        stop_icon = icons.stop,
        pause_icon = icons.pause,
      }),
      { distro(), margins = dpi(4), widget = wibox.container.margin },
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
      {
        {
          -- 24h format: %H:%M
          -- 12h fornat: %I:%M %p
          -- dd/mm/yyyy: %d/%m/%Y
          format = table.concat({ '<span font="', gstring.xml_escape(beautiful.font), '">%I:%M %p</span>' }),
          refresh = 30, -- TRY to fix issues with refresh after suspend
          widget = wibox.widget.textclock,
          id = "textclock",
        },
        left = dpi(3),
        right = dpi(3),
        widget = wibox.container.margin,
        id = "clock_margin",
      },
      {
        Battery({ timeout = 15 }),
        margins = dpi(4),
        widget = wibox.container.margin,
        id = "battery_widget",
      },
      {
        CPU({
          timeout = 15,
          precision = 1,
          prefix = "",
          suffix = "%",
        }),
        widget = wibox.container.margin,
        left = dpi(2),
        right = dpi(2),
        top = dpi(4),
        bottom = dpi(4),
        id = "cpu_widget",
      },
      Brightness({
        step = 5,
        timeout = 10,
        levels = { 5, 25, 50, 75, 100 },
      }),
    },
  })
  s:connect_signal("property::geometry", function()
    panel.width = s.geometry.width
    panel.x = s.geometry.x
    panel.y = s.geometry.y
  end)

  local clock_widget = assert(get_child_by_id(panel, "clock_margin"), "clock_margin is missing!")
  local battery_widget = assert(get_child_by_id(panel, "battery_widget"), "battery_widget is missing!")
  local cpu_widget = assert(get_child_by_id(panel, "cpu_widget"), "cpu_widget is missing!")

  local month_calendar = calendar_popup.month({ start_sunday = true, week_numbers = false }):attach(clock_widget)

  suspend_listener.register_listener(function(is_before)
    if is_before then return end
    local textclock = get_child_by_id(panel, "textclock")
    if not textclock then return end
    return textclock:force_update() -- Update the time on suspend (incase >1 min has passed)
  end)

  -- Setup click click handler if calendar is installed
  make_clickable_if_prog(apps.default.calendar, clock_widget, panel.widget, function(_)
    -- Hide the calendar on click (won't hide otherwise)
    month_calendar.visible = false
    -- needed to ensure it reapears on next mouse-over
    month_calendar._calendar_clicked_on = false
    spawn.spawn(apps.default.calendar)
  end)

  -- Check if battery_manager is available
  make_clickable_if_prog(apps.default.battery_manager, battery_widget, panel.widget, function(_)
    spawn.spawn(apps.default.battery_manager)
  end)

  -- Check if system_manager is available
  make_clickable_if_prog(apps.default.system_manager, cpu_widget, panel.widget, function(_)
    spawn.spawn(apps.default.system_manager)
  end)

  return panel
end

return TopPanel
