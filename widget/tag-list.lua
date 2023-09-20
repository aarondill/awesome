local awful = require("awful")
local capi = require("capi")
local clickable_container = require("widget.material.clickable-container")
local gtable = require("gears.table")
local wibox = require("wibox")
local dpi = require("beautiful").xresources.apply_dpi
local modkey = require("configuration.keys.mod").modKey
local compat = require("util.compat")
local icon_template = {
  {
    id = "icon_role",
    widget = wibox.widget.imagebox,
  },
  id = "icon_margin_role",
  widget = wibox.container.margin,
  margins = dpi(6),
}
local text_template = {
  {
    id = "text_role",
    widget = wibox.widget.textbox,
    valign = "center",
    [compat.widget.halign] = "center",
  },
  id = "text_margin_role",
  widget = wibox.container.margin,
  left = dpi(6),
  right = dpi(6),
}

local TagList = function(s)
  return awful.widget.taglist({
    screen = s,
    filter = awful.widget.taglist.filter.all,
    buttons = gtable.join(
      awful.button({}, 1, function(t)
        t:view_only()
      end),
      awful.button({ modkey }, 1, function(t)
        if capi.client.focus then capi.client.focus:move_to_tag(t) end
        t:view_only()
      end),
      awful.button({}, 3, awful.tag.viewtoggle),
      awful.button({ modkey }, 3, function(t)
        if capi.client.focus then capi.client.focus:toggle_tag(t) end
      end),
      awful.button({}, 4, function(t)
        awful.tag.viewprev(t.screen)
      end),
      awful.button({}, 5, function(t)
        awful.tag.viewnext(t.screen)
      end)
    ),
    widget_template = {
      {
        {
          icon_template,
          text_template,
          layout = wibox.layout.fixed.horizontal,
        },
        widget = clickable_container,
      },
      id = "background_role",
      widget = wibox.container.background,
    },
  })
end
return TagList
