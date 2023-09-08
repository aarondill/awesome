local IconButton = require("widget.material.icon-button")
local awful = require("awful")
local bind = require("util.bind")
local gtable = require("gears.table")
local icons = require("theme.icons")
local open = require("configuration.apps.open")
local wibox = require("wibox")

local QuakeButton = function()
  local imgbox = wibox.widget.imagebox(icons.term or icons.power)
  local iconbutton = IconButton(imgbox)
  local open_terminal = bind.with_args(open.terminal)
  iconbutton:buttons(gtable.join(
    awful.button({}, 1, bind.with_args(awesome.emit_signal, "quake::toggle")),
    awful.button({}, 2, open_terminal), -- open a new terminal on middle click
    awful.button({}, 3, open_terminal) -- open a new terminal on right click
  ))
  -- Not supported yet:
  -- local imgbox = layoutBox:get_children_by_id("imagebox")[1]
  -- imgbox:set_stylesheet([[ svg{ color: white; } ]])

  return iconbutton
end
return QuakeButton
