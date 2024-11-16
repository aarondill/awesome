local aplacement = require("awful.placement")
local ascreen = require("awful.screen")
local desktop = require("widget.desktop")
local gtable = require("gears.table")
local gtimer = require("gears.timer")
local tbl_deep_extend = require("util.tables.deep_extend")
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
---@field fg? string
---@field bg? string

local instances = setmetatable({}, { __mode = "k" }) ---@type table<CountdownWidget, true>
function CountdownWidget.new(opts)
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

  self:connect_signal("property::visible", function() self:update() end)
  self:update() -- The initial update

  instances[self] = true
  return self
end

---@param u string
---@param n integer
local function unit(u, n) return ("%d %s%s"):format(n, u, (n == 1 and "" or "s")) end
function CountdownWidget:get_time_remaining(t) ---@param t integer
  local diff = os.difftime(t, os.time())
  if diff < 0 then return "Time's up!" end

  --- Calculate the time remaining
  local years = math.floor(diff / 60 / 60 / 24 / 365)
  diff = diff % (60 * 60 * 24 * 365)
  local days = math.floor(diff / 60 / 60 / 24)
  diff = diff % (60 * 60 * 24)
  local hours = math.floor(diff / 60 / 60)
  diff = diff % (60 * 60)
  local minutes = math.floor(diff / 60)
  diff = diff % 60
  local seconds = math.floor(diff)

  local units = { "year", "day", "hour", "minute", "second" }
  local fmt = { years, days, hours, minutes, seconds }
  local fmt_len = #fmt

  --- Remove leading zeros
  for i, val in ipairs(fmt) do
    if val ~= 0 then break end
    fmt[i], units[i] = nil, nil
  end

  --- Add units
  local formatted = {}
  for i = 1, fmt_len do
    local val = fmt[i]
    if val then
      local formatted_unit = unit(units[i], val)
      table.insert(formatted, formatted_unit)
    end
  end

  return table.concat(formatted, "\n")
end

---Call repeatedly to update the widget (like render)
function CountdownWidget:update()
  if not self.visible then return end
  local end_time, event = self.end_time, self.event
  local diff_str = self:get_time_remaining(end_time)

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
