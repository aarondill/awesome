local abutton = require("awful.button")
local amouse = require("awful.mouse")
local gtable = require("gears.table")

local modkey = require("configuration.keys.mod").modKey

return gtable.join(
  abutton({}, 1, function(c)
    c:emit_signal("request::activate", "mouse_click", { raise = true })
  end),
  abutton({ modkey }, 1, function(c)
    c:emit_signal("request::activate", "mouse_click", { raise = true })
    amouse.client.move(c)
  end),
  abutton({ modkey }, 3, function(c)
    c:emit_signal("request::activate", "mouse_click", { raise = true })
    amouse.client.resize(c)
  end),

  -- ctrl+super+drag = resize client
  abutton({ modkey, "Control" }, 1, function(c)
    c:emit_signal("request::activate", "mouse_click", { raise = true })
    amouse.client.resize(c)
  end)
)
