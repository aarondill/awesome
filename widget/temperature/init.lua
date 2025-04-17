local gtimer = require("gears.timer")
local icons = require("theme.icons")
local lgi = require("lgi")
local mat_icon = require("widget.material.icon")
local read_async = require("util.file.read_async")
local wibox = require("wibox")
local dpi = require("beautiful").xresources.apply_dpi
local Gio = lgi.Gio

local textbox = wibox.widget({
  text = "unknown",
  widget = wibox.widget.textbox,
})

local file = Gio.File.new_for_path("/sys/class/thermal/thermal_zone0/temp")
gtimer.new({
  timeout = 5,
  call_now = true,
  autostart = true,
  callback = function()
    return read_async(file, function(content)
      if not content then return end
      local temp = assert(tonumber(content))
      local celsius = temp / 1000
      local farenheit = celsius * 1.8 + 32
      textbox:set_text(string.format("%.2f", farenheit))
    end)
  end,
})

local temperature_meter = wibox.widget({
  {
    icon = icons.thermometer,
    size = dpi(24),
    widget = mat_icon,
  },
  textbox,
  layout = wibox.layout.fixed.horizontal,
})

return temperature_meter
