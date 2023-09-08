local require = require("util.rel_require")

local clickable_container = require(..., "clickable-container") ---@module "widget.material.clickable-container"
local wibox = require("wibox")
local dpi = require("beautiful").xresources.apply_dpi

local function build(imagebox)
  -- return wibox.container.margin(container, 6, 6, 6, 6)
  return wibox.widget({
    {
      imagebox,
      margins = dpi(5),
      widget = wibox.container.margin,
    },
    widget = clickable_container,
  })
end

return build
