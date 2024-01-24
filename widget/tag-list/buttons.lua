local abutton = require("awful.button")
local atag = require("awful.tag")
local capi = require("capi")
local gtable = require("gears.table")
local modkey = require("configuration.keys.mod").modKey
local throttle = require("util.throttle")
local delay = require("configuration").tag_throttle_delay

return gtable.join(
  abutton.new({}, 1, function(t) ---@param t AwesomeTagInstance
    t:view_only()
  end),
  abutton.new({ modkey }, 1, function(t) ---@param t AwesomeTagInstance
    if capi.client.focus then capi.client.focus:move_to_tag(t) end
    t:view_only()
  end),
  ---@param t AwesomeTagInstance
  abutton.new({}, 2, function(t) -- middle click
    if not capi.client.focus then return end
    capi.client.focus:move_to_tag(t)
    t:view_only()
  end),
  abutton.new({}, 3, atag.viewtoggle),
  abutton.new({ modkey }, 3, function(t) ---@param t AwesomeTagInstance
    if not capi.client.focus then return end
    capi.client.focus:toggle_tag(t)
  end),
  abutton.new(
    {},
    4,
    throttle(function(t) ---@param t AwesomeTagInstance
      atag.viewprev(t.screen)
    end, delay)
  ),
  abutton.new(
    {},
    5,
    throttle(function(t) ---@param t AwesomeTagInstance
      atag.viewnext(t.screen)
    end, delay)
  )
)
