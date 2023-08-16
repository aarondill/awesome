local icons = require("theme.icons")
local mat_icon = require("widget.material.icon")
local mat_list_item = require("widget.material.list-item")
local mat_slider = require("widget.material.slider")
local wibox = require("wibox")
local dpi = require("beautiful").xresources.apply_dpi
local awful = require("awful")
local bind = require("util.bind")
local gears = require("gears")

local slider = wibox.widget({
  read_only = true,
  widget = mat_slider,
})

local function free_handler(stdout)
  local mem_line = stdout:match("^Mem: [^\n]*")
  -- local total, used, free, shared, buff_cache, available =
  local total, used = mem_line:match("^Mem:%s*(%d+)%s*(%d+)%s*(%d+)%s*(%d+)%s*(%d+)%s*(%d+)")
  -- local swap_line = stdout:match("^Swap: [^\n]*")
  -- local total_swap, used_swap, free_swap = swap_line:match("^Swap:%s*(%d+)%s*(%d+)%s*(%d+)")

  slider:set_value(used / total * 100)
end

local timer = gears.timer.new({
  timeout = 1,
  call_now = true,
  callback = bind(awful.spawn.easy_async, "free", free_handler),
})
timer:start()

local ram_meter = wibox.widget({
  wibox.widget({
    icon = icons.memory,
    size = dpi(24),
    widget = mat_icon,
  }),
  slider,
  widget = mat_list_item,
})

return ram_meter
