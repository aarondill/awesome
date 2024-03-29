local IconButton = require("widget.material.icon-button")
local abutton = require("awful.button")
local bind = require("util.bind")
local capi = require("capi")
local gtable = require("gears.table")
local icons = require("theme.icons")
local open = require("configuration.apps.open")
local wibox = require("wibox")

local QuakeButton = function()
  local iconbutton = wibox.widget({
    image = icons.term or icons.power,
    widget = IconButton,
  })
  local open_terminal = bind.with_args(open.terminal)
  iconbutton:buttons(gtable.join(
    abutton({}, 1, bind.with_args(capi.awesome.emit_signal, "quake::toggle")),
    abutton({}, 2, bind.with_args(capi.awesome.emit_signal, "quake::kill")),
    abutton({}, 3, open_terminal) -- open a new terminal on right click
  ))
  -- Not supported yet:
  -- local imgbox = layoutBox:get_children_by_id("imagebox")[1]
  -- imgbox:set_stylesheet([[ svg{ color: white; } ]])

  return iconbutton
end
return QuakeButton
