local aplacement = require("awful.placement")
local ascreen = require("awful.screen")
local capi = require("capi")
local gtimer = require("gears.timer")
local handle_error = require("util.handle_error")
local quake = require("module.quake")
local screen = require("util.types.screen")
local stream = require("stream")
local wibox = require("wibox")
local widgets = require("util.awesome.widgets")
---@alias wibox table
---@class AwesomeScreenInstance
---@field countdown_widget? CountdownWidget

local GLib = require("lgi").GLib
--- only show countdown on my computer
--- This is specific to my computer, so I'm not going to make it configurable
if GLib.get_user_name() ~= "aaron" then return end

local pending_changes = {} ---@type table<AwesomeScreenInstance, true>
local handler = handle_error(function(s) ---@param s AwesomeScreenInstance
  pending_changes[s] = nil
  if not s.valid then return end
  --- get the number of visible clients
  --- we don't want to show the message if any clients are visible
  local num_clients = stream
    .new(s.clients)
    :filter(function(c) return c.valid and not c.hidden end)
    :except(quake.client_is_quake)
    :count()
  local instance = s.countdown_widget
  if not instance then return end
  if num_clients > 0 then
    instance:hide()
  else
    instance:show(s)
  end
end)
gtimer.new({
  timeout = 0.5,
  autostart = true,
  callback = function() return stream.new(screen.iterator()):foreach(handler) end,
})

---@param tag AwesomeTagInstance|AwesomeClientInstance
local function callback(tag)
  local s = tag.screen
  if not s or pending_changes[s] then return end
  pending_changes[s] = true
  return gtimer.delayed_call(handler, s)
end

local compat = require("util.awesome.compat")
capi.client.connect_signal(compat.signal.manage, callback) -- Used on startup / when a client is added
capi.client.connect_signal(compat.signal.unmanage, callback) -- Used to update when a client is removed
capi.client.connect_signal("property::hidden", callback) -- Used to update when a client is hidden
capi.client.connect_signal("property::minimized", callback) -- Used to update when a client is minimized
capi.client.connect_signal("tagged", callback) -- Used to update when a client is moved *onto* a tag (on the new tag)
capi.tag.connect_signal("untagged", callback) -- Used to update when a client is moved *off* of a tag (on the old tag)
capi.tag.connect_signal("property::selected", callback) -- Used to update when a tag is selected

---@class CountdownWidget
local CountdownWidget = {
  cached_box = nil, ---@type wibox?
  end_time = 0, ---@type number
  event = "countdown", ---@type string
  fg = "#7C7E93", ---@type string
  bg = "#00000000", ---@type string
}
function CountdownWidget.new(opts)
  local self = setmetatable(
    { end_time = opts.end_time, event = opts.event, color = opts.color, background = opts.background },
    { __index = CountdownWidget }
  )
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

function CountdownWidget:hide()
  if not self.cached_box then return end
  self.cached_box.visible = false
end
---Call repeatedly to update the widget (like render)
function CountdownWidget:show(s)
  local box = self:box(s)
  box.visible = true
end

function CountdownWidget:box(s) ---@param s AwesomeScreenInstance
  self.cached_box = self.cached_box
    or wibox({
      type = "utility",
      screen = s,
      input_passthrough = true,
      widget = wibox.widget({
        widget = wibox.container.margin,
        {
          widget = wibox.widget.textbox,
          id = "textbox",
          valign = "middle",
        },
      }),
    })
  local box = assert(self.cached_box)

  local end_time, event = self.end_time, self.event
  local fg, bg = self.fg, self.bg
  local diff_str = self:get_time_remaining(end_time)

  local w = box.widget ---@type widget
  aplacement.top_right(box, {
    honor_padding = true,
    honor_workarea = true,
    margins = { right = 8, bottom = 8 },
  })
  local textbox = assert(widgets.get_by_id(w, "textbox"), "Check textbox id!")
  textbox.text = table.concat({
    ("Time until %s:"):format(event),
    diff_str,
  }, "\n")

  local width, height = textbox:get_preferred_size(s)
  box.width = math.min(width, s.workarea.width) -- crop to workarea size if too big
  box.height = math.min(height, s.workarea.height) -- crop to workarea size if too big
  box.fg, box.bg = fg, bg

  return box
end

local GRADUATION_DATE = os.time({ min = 30, hour = 19, month = 5, day = 16, year = 2025 })
ascreen.connect_for_each_screen(function(s) ---@param s AwesomeScreenInstance
  --- NOTE: Only one countdown widget per screen is allowed
  --- Yes, I know this is hacky. I don't want to fix it.
  s.countdown_widget = CountdownWidget.new({ end_time = GRADUATION_DATE, event = "Graduation" })
end)
