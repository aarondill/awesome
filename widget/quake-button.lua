local IconButton = require("widget.material.icon-button")
local awful = require("awful")
local bind = require("util.bind")
local gears = require("gears")
local icons = require("theme.icons")
local wibox = require("wibox")

-- Create an imagebox widget which will contain an icon indicating which layout we're using.
-- We need one layoutbox per screen.
local QuakeButton = function()
  local imgbox = wibox.widget.imagebox(icons.term or icons.power)
  local iconbutton = IconButton(imgbox)
  iconbutton:buttons(gears.table.join(awful.button({}, 1, bind.with_args(awesome.emit_signal, "quake::toggle"))))
  -- Not supported yet:
  -- local imgbox = layoutBox:get_children_by_id("imagebox")[1]
  -- imgbox:set_stylesheet([[ svg{ color: white; } ]])

  return iconbutton
end
return QuakeButton
