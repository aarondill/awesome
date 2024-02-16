local abutton = require("awful.button")
local alayout = require("awful.layout")
local alayoutbox = require("awful.widget.layoutbox")
local capi = require("capi")
local clickable_container = require("widget.material.clickable-container")
local gtable = require("gears.table")
local wibox = require("wibox")
local dpi = require("beautiful").xresources.apply_dpi
local bind = require("util.bind")
local compat = require("util.awesome.compat")

-- Create an imagebox widget which will contain an icon indicating which layout we're using.
-- We need one layoutbox per screen.
local LayoutBox = function(s)
  local layoutBox = alayoutbox(compat.widget.get_layoutbox_args({ screen = s }))
  local up = bind.with_args(alayout.inc, 1)
  local down = bind.with_args(alayout.inc, -1)
  local tile = function()
    local t = capi.mouse.screen.selected_tag
    if not t then return end
    -- this won't work as expected if layouts[1] is floating, but there's no easy fix
    if alayout.get() ~= t.layouts[1] then return alayout.set(t.layouts[1]) end
    return alayout.set(alayout.suit.floating)
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
      abutton({}, 1, up),
      abutton({}, 2, tile),
      abutton({}, 3, down),
      abutton({}, 4, up),
      abutton({}, 5, down)
    ),
  })
end
return LayoutBox
