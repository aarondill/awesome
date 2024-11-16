local beautiful = require("beautiful")
local capi = require("capi")
local gtable = require("gears.table")
local gtimer = require("gears.timer")
local quake = require("module.quake")
local screen = require("util.types.screen")
local stream = require("stream")
local wibox = require("wibox")

---@class DesktopWidget
---@field visible boolean
local DesktopWidget = {}
---@class (exact) DesktopWidgetOpts
---@field widget widget
---@field screen AwesomeScreenInstance
---@field fg? string
---@field bg? string

---Map of screen to widgets
local instances = setmetatable({}, { __mode = "k" }) ---@type table<AwesomeScreenInstance, table<DesktopWidget, true>>
local function insert_instance(s, widget)
  --- Weak ref to avoid memory leaks
  instances[s] = instances[s] or setmetatable({}, { __mode = "k" }) ---@type table<DesktopWidget, true>
  local scr_instances = instances[s]
  scr_instances[widget] = true
end

local pending_changes = {} ---@type table<AwesomeScreenInstance, true>
---@param s AwesomeScreenInstance
local function handler(s)
  pending_changes[s] = nil
  if not s.valid then return end

  local scr_instances = instances[s]
  --- No instances for this screen, we don't care about it
  if not scr_instances then return end

  --- get the number of visible clients
  --- we don't want to show the message if any clients are visible
  local num_clients = stream
    .new(s.clients)
    :filter(function(c) return c.valid and not c.hidden end)
    :except(quake.client_is_quake)
    :count()
  local visible = num_clients == 0
  for widget in pairs(scr_instances) do
    widget.visible = visible
  end
end

---@param o AwesomeTagInstance|AwesomeClientInstance|AwesomeScreenInstance
local function callback(o)
  local s = screen.get(o)
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

---@param opts DesktopWidgetOpts
function DesktopWidget.new(opts)
  local self = wibox({
    type = "utility",
    screen = opts.screen,
    input_passthrough = true,
    widget = opts.widget,
    ontop = false,
    fg = opts.fg or beautiful.bg_focus, --or "#7C7E93",
    bg = opts.bg or "#00000000", -- Default to transparent
    visible = false, -- If true, then the widget may render over clients on startup.
  })
  insert_instance(opts.screen, self)
  gtable.crush(self, DesktopWidget) -- DON'T USE a metatable here, it breaks __index
  callback(opts.screen) -- Check if this widget should be visible
  return self
end

return DesktopWidget
