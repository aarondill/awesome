local require = require("util.rel_require")

local ascreen = require("awful.screen")
local ataglist = require("awful.widget.taglist")
local clickable_container = require("widget.material.clickable-container")
local wibox = require("wibox")
local dpi = require("beautiful").xresources.apply_dpi
local compat = require("util.awesome.compat")
local gtable = require("gears.table")

local M = { mt = {} }

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

local this_path = ...
function M.new(opts)
  opts = opts or {}
  opts.screen = opts.screen or ascreen.focused() -- If no screen is passed, use the focused screen
  local overrides = {
    filter = ataglist.filter.all,
    buttons = require(this_path, "buttons"),
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
  }
  return ataglist(gtable.join(opts, overrides))
end
function M.mt:__call(...) return M.new(...) end
return setmetatable(M, M.mt)
