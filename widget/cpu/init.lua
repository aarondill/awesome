local gstring = require("gears.string")
local gtimer = require("gears.timer")
local icons = require("theme.icons")
local mat_icon = require("widget.material.icon")
local read_async = require("util.file.read_async")
local wibox = require("wibox")
local dpi = require("beautiful").xresources.apply_dpi
local bind = require("util.bind")

-- All special characters escaped in a string: %%, %^, %$, ...
local patternchars = table.concat({ "[", ("%^$().[]*+-?"):gsub("(.)", "%%%1"), "]" })
-- Taken from gears.string.quote_pattern
local function escape_pattern(str) return str:gsub(patternchars, "%%%1") end

---@class CPUWidgetConfig
---What to show before the percentage (default: '').
---@field prefix string?
---What to show after the percentage (default: '%').
---@field suffix string?
---The number of decimal places to display in the percentage (default: 0).
---@field precision integer?
---How often to update the widget in seconds (default: 15).
---@field timeout integer?

---@class proc_stat_info
---@field user integer?
---@field nice integer?
---@field system integer?
---@field idle integer?
---@field iowait integer?
---@field irq integer?
---@field softirq integer?
---@field steal integer?

---@param content string
---@return proc_stat_info
local function parse_proc_stat(content)
  local rem = content:match("^cpu%s+([^\n]*)")
  local ret = {} ---@type proc_stat_info
  if not rem then return ret end
  local vals = gstring.split(rem, " ")
  for i, name in ipairs({ "user", "nice", "system", "idle", "iowait", "irq", "softirq", "steal" }) do
    ret[name] = tonumber(vals[i]) -- Generate ret from the list of header names
  end
  return ret
end

---@param proc_info proc_stat_info
---@return { total: integer, idle: integer }
local function get_cpu_time(proc_info)
  local user, nice, system, idle, iowait, irq, softirq, steal =
    proc_info.user or 0,
    proc_info.nice or 0,
    proc_info.system or 0,
    proc_info.idle or 0,
    proc_info.iowait or 0,
    proc_info.irq or 0,
    proc_info.softirq or 0,
    proc_info.steal or 0
  local total_idle = idle + iowait
  local total_nonidle = user + nice + system + irq + softirq + steal
  local total = total_idle + total_nonidle
  return { total = total, idle = total_idle }
end

---Create a new CPU usage widget
---@param args CPUWidgetConfig?
---@return table
local function CPU(args)
  args = args or {}

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
  local prev = { total = 0, idle = 0 }

  ---@param content string
  local file_callback = function(content, _err, _path)
    --- See: http://stackoverflow.com/questions/23367857/accurate-calculation-of-cpu-usage-given-in-percentage-in-linux
    if not content or content == "" then return end
    local proc_info = parse_proc_stat(content)
    local time = get_cpu_time(proc_info)

    local cpu_usage = ((time.total - prev.total) - (time.idle - prev.idle)) / (time.total - prev.total) * 100
    cpu_usage = cpu_usage ~= cpu_usage and -1 or cpu_usage -- NaN is -1
    cpu_usage = cpu_usage == math.huge and -1 or cpu_usage -- Inf is -1
    cpu_usage = cpu_usage == -math.huge and -1 or cpu_usage -- -Inf is -1

    -- Round to percentage
    text_box:set_text(string.format(format, cpu_usage))
    prev = time
    collectgarbage("collect")
  end

  gtimer.new({
    autostart = true,
    call_now = true,
    timeout = args.timeout or 15,
    callback = bind.with_args(read_async, "/proc/stat", file_callback),
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
