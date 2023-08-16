-- BACKLIGHT

-- ===================================================================
-- Initialization
-- ===================================================================

local awful = require("awful")
local beautiful = require("beautiful")
local gears = require("gears")
local read_async = require("util.file.read_async")
local wibox = require("wibox")
local dpi = beautiful.xresources.apply_dpi

local offsetx = dpi(56)
local offsety = dpi(256)
local screen = awful.screen.focused()

-- ===================================================================
-- Appearance & Functionality
-- ===================================================================

-- create the backlight_adjust component
local backlight_adjust = wibox({
  screen = awful.screen.focused(),
  x = screen.geometry.width - offsetx,
  y = (screen.geometry.height / 2) - (offsety / 2),
  width = dpi(48),
  height = offsety,
  bg = beautiful.hud_panel_bg,
  shape = gears.shape.rounded_rect,
  visible = false,
  ontop = true,
})

local backlight_bar = wibox.widget({
  widget = wibox.widget.progressbar,
  shape = gears.shape.rounded_bar,
  color = beautiful.hud_slider_fg,
  background_color = beautiful.hud_slider_bg,
  max_value = 100,
  value = 0,
})

backlight_adjust:setup({
  layout = wibox.layout.align.vertical,
  {
    wibox.container.margin(backlight_bar, dpi(20), dpi(20), dpi(20), dpi(20)),
    forced_height = offsety,
    direction = "east",
    layout = wibox.container.rotate,
  },
})

-- create a 4 second timer to hide the volume adjust
-- component whenever the timer is started
local hide_backlight_adjust = gears.timer({
  timeout = 4,
  autostart = true,
  callback = function()
    backlight_adjust.visible = false
  end,
})

--HACK:
local EXPONENTIAL_SCALE_FACTOR = 4
-- show backlight-adjust when "backlight_change" signal is emitted
awesome.connect_signal("widget::backlight_changed", function()
  -- set new brightness value
  read_async("/sys/class/backlight/intel_backlight/actual_brightness", function(brightness_str, _)
    if not brightness_str then return end
    local backlight_brightness = tonumber(brightness_str)
    read_async("/sys/class/backlight/intel_backlight/max_brightness", function(max_brightness_str, _)
      if not max_brightness_str then return end
      local max_brightness = tonumber(max_brightness_str)
      local backlight_level = backlight_brightness * 100 / max_brightness
      backlight_level = (backlight_level ^ (1 / EXPONENTIAL_SCALE_FACTOR))
        * (100 / (100 ^ (1 / EXPONENTIAL_SCALE_FACTOR)))
      backlight_bar.value = backlight_level
    end)
  end)

  -- make backlight_adjust component visible
  if backlight_adjust.visible then
    hide_backlight_adjust:again()
  else
    backlight_adjust.visible = true
    hide_backlight_adjust:start()
  end
end)
