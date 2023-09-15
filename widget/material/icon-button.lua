local require = require("util.rel_require")

local clickable_container = require(..., "clickable-container") ---@module "widget.material.clickable-container"
local gtable = require("gears.table")
local wibox = require("wibox")
local dpi = require("beautiful").xresources.apply_dpi

local IconButton = {}

---@param img string the path to the image
---@return boolean success
function IconButton:set_image(img)
  return self:get_children_by_id("iconbox")[1]:set_image(img)
end
function IconButton:get_image()
  return self:get_children_by_id("iconbox")[1]:get_image()
end
-- alias icon to image
IconButton.set_icon = IconButton.set_image
IconButton.get_icon = IconButton.get_image

for _, v in pairs({ "margins", "left", "right", "top", "bottom" }) do
  for _, t in ipairs({ "set", "get" }) do
    local method = string.format("%s_%s", t, v)
    IconButton[method] = function(self, m)
      local margin = self:get_children_by_id("margin")[1]
      return margin[method](margin, m)
    end
  end
end

---@param children table[]
---Note: ensure that the iconbox has an id="iconbox"
function IconButton:set_children(children)
  if #children <= 0 then return {} end
  return self:get_children_by_id("margin")[1]:set_children(children)
end
function IconButton:get_children() ---@return table[] children
  return self:get_children_by_id("margin")[1]:get_children()
end

--- Creates a button with the path specified
--- Ensure to call :buttons() to setup the button
---@param img? string|userdata
---@param margins? integer
---@param buttons? unknown[]
---@return clickable_container
local function new(img, margins, buttons)
  local ret = wibox.widget({
    {
      {
        image = img,
        id = "iconbox",
        widget = wibox.widget.imagebox,
      },
      id = "margin",
      margins = margins or dpi(5),
      widget = wibox.container.margin,
    },
    buttons = buttons,
    widget = clickable_container,
  })
  gtable.crush(ret, IconButton, true)

  return ret
end

return new
