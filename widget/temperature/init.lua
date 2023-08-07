local icons = require("theme.icons")
local mat_icon = require("widget.material.icon")
local mat_list_item = require("widget.material.list-item")
local watch = require("awful.widget.watch")
local wibox = require("wibox")
local dpi = require("beautiful").xresources.apply_dpi

local textbox = wibox.widget({
  text = "unknown",
  widget = wibox.widget.textbox,
})

watch("cat /sys/class/thermal/thermal_zone0/temp", 5, function(_, stdout)
  local temp = stdout:match("(%d+)")
  textbox:set_text(string.format("%.2f", temp / 1000))
  collectgarbage("collect")
end)

local temperature_meter = wibox.widget({
  wibox.widget({
    icon = icons.thermometer,
    size = dpi(24),
    widget = mat_icon,
  }),
  textbox,
  widget = mat_list_item,
})

return temperature_meter
