-- Default widget requirements
local base = require("wibox.widget.base")
local gtable = require("gears.table")
local imagebox = require("wibox.widget.imagebox")
local load_surface = require("util.load_surface")

-- Local declarations

---@class _icon_private
---@field icon (string|CairoSurface)?
---@field imagebox widget.imagebox
---@field size integer?
---@field last_size integer? Last size the icon was rendered at
---@field render_empty boolean

---@class IconWidget: widget
---@field private _private _icon_private
local Icon = {}

---@param width integer
---@param height integer
function Icon:layout(_, width, height)
  if not self._private.icon then return {} end
  local size = math.min(width, height)
  if self._private.size then
    size = math.min(size, self._private.size) -- if we don't have enough space, use all of it
  end

  -- Only reload if the size is bigger. Scaling down is not lossy, but scaling up will cause blurry icons
  if not self._private.last_size or size > self._private.last_size then self:_reload_surface(size) end
  self._private.last_size = size

  return {
    base.place_widget_at(
      self._private.imagebox,
      width / 2 - size / 2, --
      height / 2 - size / 2,
      width,
      height
    ),
  }
end

function Icon:fit(_, width, height)
  if not self._private.icon and not self._private.render_empty then return 0, 0 end
  local min = math.min(width, height)
  if self._private.size then min = math.min(min, self._private.size) end
  return min, min
end

--- Reload the surface from the file to scale it properly
--- Note that this is almost certainly expensive
---@param size integer | nil
function Icon:_reload_surface(size)
  local surf
  local icon = self._private.icon
  if type(icon) == "string" then
    surf = load_surface(icon, size)
  else
    surf = self._private.icon
  end
  self._private.imagebox:set_image(surf)
end

function Icon:set_icon(icon)
  -- Don't skip if it didn't change cause the file may have changed
  if icon == "" then icon = nil end
  self._private.icon = icon
  self:_reload_surface(self._private.size)
  self:emit_signal("widget::layout_changed")
  self:emit_signal("widget::redraw_needed")
end
function Icon:get_icon() return self._private.icon end
-- alias icon to image
Icon.set_image = Icon.set_icon
Icon.get_image = Icon.get_icon

function Icon:set_size(size)
  if self._private.size == size then return end
  self._private.size = size
  self:emit_signal("widget::layout_changed")
end
function Icon:get_size() return self._private.size end

function Icon:set_render_empty(render_empty)
  self._private.render_empty = render_empty
  self:emit_signal("widget::layout_changed")
end
function Icon:get_render_empty() return self._private.render_empty end

---Creates a widget to hold an icon with a given size
---The icon will be centered in a square of size
---@param icon string? The icon to create (passed to wibox.widget.imagebox)
---@param size integer? The size of the icon. If nil, all space will be used
---@param render_empty boolean? Whether to show empty icons(default: true)
---@return unknown
local function new(icon, size, render_empty)
  render_empty = render_empty == nil and true or render_empty ---@cast render_empty -nil
  local ret = base.make_widget(nil, nil, { enable_properties = true }) ---@type IconWidget
  gtable.crush(ret, Icon, true)
  ---@diagnostic disable-next-line: invisible
  gtable.crush(ret._private, {
    imagebox = imagebox(),
    size = size,
    render_empty = render_empty,
  })
  ret:set_icon(icon)
  return ret
end
return new
