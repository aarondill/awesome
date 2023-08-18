local require = require("util.rel_require")

local gears = require("gears")
local wibox = require("wibox")
local dpi = require("beautiful").xresources.apply_dpi
local clickable_container = require(..., "clickable-container") ---@module "widget.material.clickable-container"

local function build(imagebox, _)
  -- return wibox.container.margin(container, 6, 6, 6, 6)
  return wibox.widget({
    wibox.widget({
      wibox.widget({
        imagebox,
        top = dpi(6),
        left = dpi(6),
        right = dpi(6),
        bottom = dpi(6),
        widget = wibox.container.margin,
      }),
      shape = gears.shape.circle,
      widget = clickable_container,
    }),
    top = dpi(6),
    left = dpi(6),
    right = dpi(6),
    bottom = dpi(6),
    widget = wibox.container.margin,
  })
end

return build
