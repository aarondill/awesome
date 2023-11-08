local abutton = require("awful.button")
local atag = require("awful.tag")
local capi = require("capi")
local gtable = require("gears.table")
local modkey = require("configuration.keys.mod").modKey

return gtable.join(
  abutton({}, 1, function(t)
    t:view_only()
  end),
  abutton({ modkey }, 1, function(t)
    if capi.client.focus then capi.client.focus:move_to_tag(t) end
    t:view_only()
  end),
  abutton({}, 3, atag.viewtoggle),
  abutton({ modkey }, 3, function(t)
    if capi.client.focus then capi.client.focus:toggle_tag(t) end
  end),
  abutton({}, 4, function(t)
    atag.viewprev(t.screen)
  end),
  abutton({}, 5, function(t)
    atag.viewnext(t.screen)
  end)
)
