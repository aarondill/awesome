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
IconButton.set_icon = IconButton.set_image -- alias icon to image

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
function IconButton:set_children(children) -- allow set own iconbox
  if #children > 0 then
    return self:get_children_by_id("margin")[1]:set_children(children)
  else
    return false
  end
end

local function new(img, margins)
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
    widget = clickable_container,
  })
  gtable.crush(ret, IconButton, true)

  return ret
end

return new
