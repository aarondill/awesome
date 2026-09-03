local require = require("util.rel_require")

local clickable_container = require(..., "clickable-container") ---@module "widget.material.clickable-container"
local gtable = require("gears.table")
local mat_icon = require(..., "icon") ---@module "widget.material.icon"
local wibox = require("wibox")
local dpi = require("beautiful").xresources.apply_dpi

---@class _IconButtonPrivate
---@field iconbox IconWidget
---@field margin wibox.container.margin

---@class IconButton : widget
---@field private _private _IconButtonPrivate
local IconButton = {}

---@param img string the path to the image
function IconButton:set_image(img) return self._private.iconbox:set_image(img) end
IconButton.set_icon = IconButton.set_image -- alias icon to image

function IconButton:set_margins(m) return self._private.margin:set_margins(m) end ---@param m integer
function IconButton:set_left(m) return self._private.margin:set_left(m) end ---@param m integer
function IconButton:set_right(m) return self._private.margin:set_right(m) end ---@param m integer
function IconButton:set_top(m) return self._private.margin:set_top(m) end ---@param m integer
function IconButton:set_bottom(m) return self._private.margin:set_bottom(m) end ---@param m integer

--- Creates a button with the path specified
--- Ensure to call :buttons() to setup the button
---@param img? string
---@param margins? integer
---@param buttons? AwesomeButton[]
---@return IconButton
local function new(img, margins, buttons)
  local iconbox = mat_icon(img)
  local margin = wibox.container.margin(iconbox)
  local container = clickable_container(margin, buttons)

  ---@type widget
  local ret = wibox.widget.base.make_widget(container, nil, { enable_properties = true })
  gtable.crush(ret, IconButton, true) ---@cast ret IconButton
  ---@diagnostic disable-next-line: invisible
  gtable.crush(ret._private, { iconbox = iconbox, margin = margin }, true)
  ret:set_margins(margins or dpi(5))
  return ret
end

return new
