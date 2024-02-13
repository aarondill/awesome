-- Default widget requirements
local base = require("wibox.widget.base")
local gtable = require("gears.table")
local imagebox = require("wibox.widget.imagebox")

-- Local declarations

local Icon = {}

function Icon:layout(_, width, height)
  if not self._private.icon then return {} end
  if not self._private.size then return { base.place_widget_at(self._private.imagebox, 0, 0, width, height) } end
  return {
    base.place_widget_at(
      self._private.imagebox,
      width / 2 - self._private.size / 2,
      height / 2 - self._private.size / 2,
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

function Icon:set_icon(icon)
  self._private.icon = icon
  self._private.imagebox:set_image(icon)
end
function Icon:get_icon()
  return self._private.icon
end
-- alias icon to image
Icon.set_image = Icon.set_icon
Icon.get_image = Icon.get_icon

function Icon:set_size(size)
  self._private.size = size
  self:emit_signal("widget::layout_changed")
end
function Icon:get_size()
  return self._private.size
end

function Icon:set_render_empty(render_empty)
  self._private.render_empty = render_empty
  self:emit_signal("widget::layout_changed")
end
function Icon:get_render_empty()
  return self._private.render_empty
end

---Creates a widget to hold an icon with a given size
---The icon will be centered in a square of size
---@param icon string? The icon to create (passed to wibox.widget.imagebox)
---@param size integer? The size of the icon. If nil, all space will be used
---@param render_empty boolean? Whether to show empty icons(default: true)
---@return unknown
local function new(icon, size, render_empty)
  render_empty = render_empty == nil and true or render_empty
  local ret = base.make_widget(nil, nil, { enable_properties = true })
  gtable.crush(ret, Icon, true)
  ret._private.icon = icon
  ret._private.imagebox = imagebox(icon)
  ret._private.size = size
  ret._private.render_empty = render_empty
  return ret
end
return new
