local require = require("util.rel_require")

local clickable_container = require(..., "clickable-container") ---@module "widget.material.clickable-container"
local gtable = require("gears.table")
local wibox = require("wibox")
local dpi = require("beautiful").xresources.apply_dpi

local IconButton = {}

---@param img string the path to the image
---@return boolean success
function IconButton:set_image(img) return self._private.iconbox:set_image(img) end
function IconButton:get_image() return self._private.iconbox:get_image() end
-- alias icon to image
IconButton.set_icon = IconButton.set_image
IconButton.get_icon = IconButton.get_image

for _, v in pairs({ "margins", "left", "right", "top", "bottom" }) do
  for _, t in ipairs({ "set", "get" }) do
    local method = string.format("%s_%s", t, v)
    IconButton[method] = function(self, m)
      local margin = self._private.margin
      return margin[method](margin, m)
    end
  end
end

--- Creates a button with the path specified
--- Ensure to call :buttons() to setup the button
---@param img? string|userdata
---@param margins? integer
---@param buttons? unknown[]
---@return clickable_container
local function new(img, margins, buttons)
  local iconbox = wibox.widget.imagebox(img)
  local margin = wibox.container.margin(iconbox)
  local container = clickable_container(margin, buttons)

  local ret = wibox.widget.base.make_widget(container, nil, { enable_properties = true })
  gtable.crush(ret, IconButton, true)

  ret._private.iconbox = iconbox
  ret._private.margin = margin
  ret._private.container = container
  margin:set_margins(margins or dpi(5))

  return ret
end

return new
