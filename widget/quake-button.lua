local IconButton = require("widget.material.icon-button")
local abutton = require("awful.button")
local bind = require("util.bind")
local capi = require("capi")
local icons = require("theme.icons")
local open = require("configuration.apps.open")
local tables = require("util.tables")
local wibox = require("wibox")

local QuakeButton = function()
  ---@type IconButton
  local iconbutton = wibox.widget({
    image = icons.term or icons.power,
    widget = IconButton,
  })
  local open_terminal = bind.with_args(open.terminal)
  iconbutton:buttons(tables.join(
    abutton({}, 1, bind.with_args(capi.awesome.emit_signal, "quake::toggle")),
    abutton({}, 2, bind.with_args(capi.awesome.emit_signal, "quake::kill")),
    abutton({}, 3, open_terminal) -- open a new terminal on right click
  ))
  return iconbutton
end
return QuakeButton
