local gtimer = require("gears.timer")
local icons = require("theme.icons")
local mat_icon = require("widget.material.icon")
local mat_slider = require("widget.material.slider")
local spawn = require("util.spawn")
local wibox = require("wibox")
local dpi = require("beautiful").xresources.apply_dpi

local slider = wibox.widget({
  read_only = true,
  widget = mat_slider,
})

local function free_handler(stdout)
  local mem_line = stdout:match("Mem: [^\n]*")
  -- local total, used, free, shared, buff_cache, available =
  local total, _, _, _, _, available = mem_line:match("^Mem:%s*(%d+)%s*(%d+)%s*(%d+)%s*(%d+)%s*(%d+)%s*(%d+)")
  -- local swap_line = stdout:match("Swap: [^\n]*")
  -- local total_swap, used_swap, free_swap = swap_line:match("^Swap:%s*(%d+)%s*(%d+)%s*(%d+)")

  slider:set_value(math.floor((total - available) / total * 100))
end

local timer = gtimer.new({
  timeout = 1,
  call_now = true,
  callback = function() spawn.easy_async("free", free_handler) end,
})
timer:start()

local ram_meter = wibox.widget({
  {
    icon = icons.memory,
    size = dpi(24),
    widget = mat_icon,
  },
  slider,
  widget = wibox.layout.fixed.horizontal,
  forced_width = dpi(20),
})
return ram_meter
