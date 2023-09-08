local awful = require("awful")
local clickable_container = require("widget.material.clickable-container")
local gears = require("gears")
local wibox = require("wibox")
local dpi = require("beautiful").xresources.apply_dpi

-- Create an imagebox widget which will contain an icon indicating which layout we're using.
-- We need one layoutbox per screen.
local LayoutBox = function(s)
  local layoutBox = awful.widget.layoutbox(awesome.version <= "v4.3" and s or { screen = s })
  layoutBox:buttons(gears.table.join(
    awful.button({}, 1, function()
      awful.layout.inc(1)
    end),
    awful.button({}, 3, function()
      awful.layout.inc(-1)
    end),
    awful.button({}, 4, function()
      awful.layout.inc(1)
    end),
    awful.button({}, 5, function()
      awful.layout.inc(-1)
    end)
  ))
  -- Not supported yet:
  -- local imgbox = layoutBox:get_children_by_id("imagebox")[1]
  -- imgbox:set_stylesheet([[ svg{ color: white; } ]])

  return wibox.widget({
    {
      layoutBox,
      margins = dpi(5),
      widget = wibox.container.margin,
    },
    widget = clickable_container,
  })
end
return LayoutBox
