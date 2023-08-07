--- uses pacmac and *only* works with pacmac! (manjaro)
---
local awful = require("awful")
local clickable_container = require("widget.material.clickable-container")
local gears = require("gears")
local watch = require("awful.widget.watch")
local wibox = require("wibox")
local dpi = require("beautiful").xresources.apply_dpi
local spawn = require("util.spawn")

local PATH_TO_ICONS = gears.filesystem.get_configuration_dir() .. "widget/package-updater/icons/"
local updateAvailable = false
local numOfUpdatesAvailable

local widget = wibox.widget({
  {
    id = "icon",
    widget = wibox.widget.imagebox,
    resize = true,
  },
  layout = wibox.layout.align.horizontal,
})

local widget_button = clickable_container(wibox.container.margin(widget, dpi(14), dpi(14), dpi(4), dpi(4)))
widget_button:buttons(gears.table.join(awful.button({}, 1, nil, function()
  if updateAvailable then
    spawn("pamac-manager --updates", { sn_rules = false })
  else
    spawn("pamac-manager", { sn_rules = false })
  end
end)))

awful.tooltip({
  objects = { widget_button },
  mode = "outside",
  align = "right",
  timer_function = function()
    if updateAvailable then
      return numOfUpdatesAvailable .. " updates are available"
    else
      return "We are up-to-date!"
    end
  end,
  preferred_positions = { "right", "left", "top", "bottom" },
})

watch("pamac checkupdates", 60, function(_, stdout)
  numOfUpdatesAvailable = tonumber(stdout:match(".-\n"):match("%d*"))
  local widgetIconName = "package"
  updateAvailable = false
  if numOfUpdatesAvailable ~= nil then
    updateAvailable = true
    widgetIconName = "package-up"
  end
  widget.icon:set_image(PATH_TO_ICONS .. widgetIconName .. ".svg")
  collectgarbage("collect")
end, widget)

return widget_button
