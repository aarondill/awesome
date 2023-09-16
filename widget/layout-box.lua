local awful = require("awful")
local capi = require("capi")
local clickable_container = require("widget.material.clickable-container")
local gtable = require("gears.table")
local wibox = require("wibox")
local dpi = require("beautiful").xresources.apply_dpi
local bind = require("util.bind")
local compat = require("util.compat")

-- Create an imagebox widget which will contain an icon indicating which layout we're using.
-- We need one layoutbox per screen.
local LayoutBox = function(s)
  local layoutBox = awful.widget.layoutbox(compat.widget.get_layoutbox_args({ screen = s }))
  local up = bind.with_args(awful.layout.inc, 1)
  local down = bind.with_args(awful.layout.inc, -1)
  local tile = function()
    local t = capi.mouse.screen.selected_tag
    -- this won't work as expected if layouts[1] is floating, but there's no easy fix
    if awful.layout.get() ~= t.layouts[1] then
      awful.layout.set(t.layouts[1])
    else
      awful.layout.set(awful.layout.suit.floating)
    end
  end
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
    buttons = gtable.join(
      awful.button({}, 1, up),
      awful.button({}, 2, tile),
      awful.button({}, 3, down),
      awful.button({}, 4, up),
      awful.button({}, 5, down)
    ),
  })
end
return LayoutBox
