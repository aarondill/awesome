local aplacement = require("awful.placement")
local capi = require("capi")
local gtimer = require("gears.timer")
local quake = require("module.quake")
local stream = require("stream")
local wibox = require("wibox")
local widgets = require("util.awesome.widgets")
---@class AwesomeScreenInstance
---@field activate_box? table injected field for use in Activate Linux box

---@param s AwesomeScreenInstance
local function create_widgets(s)
  local w = wibox.widget({
    widget = wibox.container.margin,
    {
      widget = wibox.widget.textbox,
      id = "textbox",
      valign = "middle",
      text = table.concat({
        "Activate Linux",
        "Go to Settings to activate Linux.",
      }, "\n"),
    },
  })
  local textbox = assert(widgets.get_by_id(w, "textbox"), "Check textbox id!")
  local width, height = textbox:get_preferred_size(s)
  local box = wibox({
    type = "utility",
    fg = "#7C7E93",
    bg = "#00000000",
    width = math.min(width, s.workarea.width), -- crop to workarea size if too big
    height = math.min(height, s.workarea.height), -- crop to workarea size if too big
    widget = w,
  })
  aplacement.bottom_right(box, {
    honor_padding = true,
    honor_workarea = true,
    margins = { right = 8, bottom = 8 },
  })
  return box
end

local pending_changes = {} ---@type table<AwesomeScreenInstance, true>

local function handler(s) ---@param s AwesomeScreenInstance
  pending_changes[s] = nil
  if not s.valid then return end
  --- get the number of visible clients
  --- we don't want to show the message if any clients are visible
  local num_clients = stream
    .new(s.clients)
    :filter(function(c) return c.valid end)
    :filter(function(c) return not c.hidden end)
    :filter(function(c) return not quake:client_is_quake(c) end)
    :count()
  local box = s.activate_box --- reuse the box if possible
  if num_clients > 0 then -- hide the message
    if box then box.visible = false end
    return
  end
  box = box or create_widgets(s)
  s.activate_box = box
  box.visible = true
end

---@param tag AwesomeTagInstance|AwesomeClientInstance
local function callback(tag)
  local s = tag.screen
  if not s or pending_changes[s] then return end
  pending_changes[s] = true
  return gtimer.delayed_call(handler, s)
end

local compat = require("util.awesome.compat")
capi.client.connect_signal(compat.signal.manage, callback)
capi.client.connect_signal(compat.signal.unmanage, callback)
capi.client.connect_signal("property::hidden", callback)
capi.client.connect_signal("property::minimized", callback)
capi.client.connect_signal("property::fullscreen", callback)
capi.client.connect_signal("tagged", callback)
capi.tag.connect_signal("property::selected", callback)
capi.tag.connect_signal("property::layout", callback)
capi.tag.connect_signal("property::useless_gap", callback)
