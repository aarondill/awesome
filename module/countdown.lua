local aplacement = require("awful.placement")
local ascreen = require("awful.screen")
local desktop = require("widget.desktop")
local gtable = require("gears.table")
local gtimer = require("gears.timer")
local tables = require("util.tables")
local wibox = require("wibox")
local widgets = require("util.awesome.widgets")

local GLib = require("lgi").GLib
--- only show countdown on my computer
--- This is specific to my computer, so I'm not going to make it configurable
if GLib.get_user_name() ~= "aaron" then return end

---@class CountdownWidget :CountdownWidgetOpts
local CountdownWidget = {
  widget = nil, ---@type widget
  visible = nil, ---@type boolean
}

---@class CountdownWidgetOpts
---@field screen AwesomeScreenInstance
---@field end_time number
---@field event string
---@field units? table<string, integer>
---@field fg? string
---@field bg? string

local instances = setmetatable({}, { __mode = "k" }) ---@type table<CountdownWidget, true>
---@param opts CountdownWidgetOpts?
---@return CountdownWidget
function CountdownWidget.new(opts)
  opts = opts or {}
  local self = desktop.new({
    screen = opts.screen,
    fg = opts.fg,
    bg = opts.bg,
    widget = wibox.widget({
      widget = wibox.container.margin,
      {
        widget = wibox.widget.textbox,
        id = "textbox",
        valign = "middle",
      },
    }),
  })
  gtable.crush(self, CountdownWidget) -- DON'T USE a metatable here, it breaks __index
  gtable.crush(self, opts)
  instances[self] = true
  return self
end

---@param num number
---@param dec_places? integer
---@return number
local function round(num, dec_places) --
  local mult = 10 ^ (dec_places or 0)
  num = num * mult
  local res = num >= 0 and math.floor(num + 0.5) or math.ceil(num - 0.5)
  return res / mult
end

---@param u string
---@param n integer
local function unit(u, n) return ("%s %s%s"):format(n, u, (n == 1 and "" or "s")) end
---@param units? table<string, integer>
function CountdownWidget:get_time_remaining(t, units) ---@param t integer
  local diff = os.difftime(t, os.time())
  if diff < 0 then return "Time's up!" end

  --- Calculate the time remaining
  units = units or { year = 365 * 24 * 60 * 60, day = 24 * 60 * 60, hour = 60 * 60, minute = 60, second = 1 }
  local unit_names_sorted = gtable.keys(units)
  table.sort(unit_names_sorted, function(a, b) return units[a] > units[b] end)

  ---@type table<string, number>
  local unit_counts = {}
  for _, unit_name in ipairs(unit_names_sorted) do
    local unit_sec = units[unit_name]
    local unit_count = math.floor(diff / unit_sec)
    unit_counts[unit_name] = unit_count
    diff = diff - (unit_count * unit_sec)
  end

  ---@type number[]
  local fmt = tables.map_val(unit_names_sorted, function(unit_name) return unit_counts[unit_name] end)
  --- Add units
  local formatted = {}
  --- Remove leading zeros
  local has_found_non_zero = false
  for i, val in ipairs(fmt) do
    if has_found_non_zero or val ~= 0 then
      has_found_non_zero = true
      local formatted_unit = unit(unit_names_sorted[i], val)
      table.insert(formatted, formatted_unit)
    end
  end
  -- If there are no non-zero values, show the fraction of the last unit (rounded to 2 decimal places)
  if #formatted == 0 then
    local u = unit_names_sorted[#unit_names_sorted]
    local v = round(diff / units[u], 2)
    return unit(u, v)
  end

  return table.concat(formatted, "\n")
end

---Call repeatedly to update the widget (like render)
function CountdownWidget:update()
  if not self.visible then return end
  local end_time, event = self.end_time, self.event
  local diff_str = self:get_time_remaining(end_time, self.units)

  local w = self.widget ---@type widget
  local textbox = widgets.get_by_id(w, "textbox")
  assert(textbox, "Check textbox widget id!")
  textbox.text = table.concat({
    ("Time until %s:"):format(event),
    diff_str,
  }, "\n")

  local width, height = textbox:get_preferred_size(self.screen)
  self.width = math.min(width, self.screen.workarea.width) -- crop to workarea size if too big
  self.height = math.min(height, self.screen.workarea.height) -- crop to workarea size if too big
  aplacement.top_right(self, {
    honor_padding = true,
    honor_workarea = true,
    margins = { right = 8 },
  })
end

--- Update all countdowns every 0.5 seconds
gtimer.new({
  timeout = 0.5,
  autostart = true,
  callback = function()
    for w in pairs(instances) do
      w:update()
    end
  end,
})

local GRADUATION_DATE = os.time({ min = 30, hour = 19, month = 5, day = 16, year = 2025 })
---@class AwesomeScreenInstance
---@field countdown CountdownWidget
ascreen.connect_for_each_screen(function(s) ---@param s AwesomeScreenInstance
  ---Assignment is required to avoid garbage collection
  s.countdown = CountdownWidget.new({ end_time = GRADUATION_DATE, event = "Graduation", screen = s })
end)
