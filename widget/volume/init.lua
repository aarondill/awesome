local icons = require("theme.icons")
local mat_icon_button = require("widget.material.icon-button")
local mat_list_item = require("widget.material.list-item")
local mat_slider = require("widget.material.slider")
local spawn = require("util.spawn")
local watch = require("awful.widget.watch")
local wibox = require("wibox")

local slider = wibox.widget({
  read_only = false,
  widget = mat_slider,
})

slider:connect_signal("property::value", function()
  spawn.noninteractive_nosn({ "amixer", "-D", "pulse", "sset", "Master", slider.value .. "%" })
end)

watch("amixer -D pulse sget Master", 1, function(_, stdout)
  -- local mute = string.match(stdout, "%[(o%D%D?)%]")
  local volume = string.match(stdout, "(%d?%d?%d)%%")
  slider:set_value(tonumber(volume))
  collectgarbage("collect")
end)

local icon = wibox.widget({
  image = icons.volume,
  widget = wibox.widget.imagebox,
})

local button = mat_icon_button(icon)

local volume_setting = wibox.widget({
  button,
  slider,
  widget = mat_list_item,
})

return volume_setting
