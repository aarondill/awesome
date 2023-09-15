local gtimer = require("gears.timer")
local handle_error = require("util.handle_error")
local icons = require("theme.icons")
local mat_icon = require("widget.material.icon")
local read_async = require("util.file.read_async")
local wibox = require("wibox")
local dpi = require("beautiful").xresources.apply_dpi

local function escape_pattern(str)
  -- Taken from gears.string.quote_pattern
  -- All special characters escaped in a string: %%, %^, %$, ...
  local patternchars = "[" .. ("%^$().[]*+-?"):gsub("(.)", "%%%1") .. "]"
  return str:gsub(patternchars, "%%%1")
end

---@class CPUWidgetConfig
---What to show before the percentage (default: '').
---@field prefix string?
---What to show after the percentage (default: '%').
---@field suffix string?
---The number of decimal places to display in the percentage (default: 0).
---@field precision integer?
---How often to update the widget in seconds (default: 15).
---@field timeout integer?

---@return integer cpu_idle_time
---@return integer cpu_total
local function parse_proc_stat(content)
  local rem = content:match("^cpu%s+([^\n]*)")
  if not rem then return 0, 0 end
  local user, nice, system, idle, iowait, irq, softirq, steal, guest, guest_nice
  -- find values, even if not exist
  user, rem = rem:match("(%d+)(.*)")
  nice, rem = rem:match("(%d+)(.*)")
  system, rem = rem:match("(%d+)(.*)")
  idle, rem = rem:match("(%d+)(.*)")
  iowait, rem = rem:match("(%d+)(.*)")
  irq, rem = rem:match("(%d+)(.*)")
  softirq, rem = rem:match("(%d+)(.*)")
  steal, rem = rem:match("(%d+)(.*)")
  guest, rem = rem:match("(%d+)(.*)")
  guest_nice, rem = rem:match("(%d+)(.*)")

  local cpu_total = user + nice + system + idle + iowait + irq + softirq + steal + guest + guest_nice
  -- return user, nice, system, idle, iowait, irq, softirq, steal, guest, guest_nice, cpu_total
  return idle, cpu_total
end

---Create a new CPU usage widget
---@param args CPUWidgetConfig?
---@return table
function CPU(args)
  args = args or {}
  local cpu_total_prev = 0
  local idle_prev = 0

  local format = string.format(
    "%s%%.%df%s",
    escape_pattern(args.prefix or ""),
    args.precision or 0,
    escape_pattern(args.suffix or "%")
  )

  local text_box = wibox.widget({
    widget = wibox.widget.textbox,
    text = string.format(format, 0),
  })

  local file_callback = function(content, _)
    if not content then return end
    local idle, cpu_total = parse_proc_stat(content)

    -- Get the delta between two reads
    local diff_cpu = cpu_total - cpu_total_prev
    -- Get the idle time delta
    local diff_idle = idle - idle_prev
    -- Calc time spent working
    local cpu_used = diff_cpu - diff_idle
    -- Calc percentage
    local cpu_usage = 100 * cpu_used / diff_cpu

    -- Round to percentage
    text_box:set_text(string.format(format, cpu_usage))

    cpu_total_prev = cpu_total
    idle_prev = idle
    collectgarbage("collect")
  end

  gtimer.new({
    autostart = true,
    call_now = true,
    timeout = args.timeout or 15,
    callback = function()
      read_async("/proc/stat", handle_error(file_callback))
    end,
  })

  local cpu_meter = wibox.widget({
    {
      icon = icons.chart,
      widget = mat_icon,
    },
    text_box,
    spacing = dpi(2),
    layout = wibox.layout.fixed.horizontal,
  })

  return cpu_meter
end
return CPU
