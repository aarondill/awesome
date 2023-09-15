-- Default widget requirements
local base = require("wibox.widget.base")
local gtable = require("gears.table")

-- Commons requirements
local wibox = require("wibox")

-- Local declarations

local Icon = {}

function Icon:layout(_, width, height)
  if not self._private.icon then return {} end
  if not self._private.size then return end
  return {
    base.place_widget_at(
      self._private.imagebox,
      width / 2 - self._private.size / 2,
      height / 2 - self._private.size / 2,
      self._private.size,
      self._private.size
    ),
  }
end

function Icon:fit(_, width, height)
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

function Icon:set_size(size)
  self._private.size = size
  self:emit_signal("widget::layout_changed")
end
function Icon:get_size()
  return self._private.size
end

local function new(icon, size)
  local ret = base.make_widget(nil, nil, { enable_properties = true })
  gtable.crush(ret, Icon, true)
  ret._private.icon = icon
  ret._private.imagebox = wibox.widget.imagebox(icon)
  ret._private.size = size
  return ret
end
return new
