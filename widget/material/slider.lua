-- Default widget requirements
local base = require("wibox.widget.base")
local gtable = require("gears.table")
local setmetatable = setmetatable
local dpi = require("beautiful").xresources.apply_dpi

-- Commons requirements
local beautiful = require("beautiful")
local gshape = require("gears.shape")
local wibox = require("wibox")
-- Local declarations

local mat_slider = { mt = {} }

function mat_slider:set_value(value)
  if self._private.value ~= value then
    self._private.value = value
    self._private.progress_bar:set_value(self._private.value)
    self._private.slider:set_value(self._private.value)
    self:emit_signal("property::value")
    --self:emit_signal('widget::layout_changed')
  end
end

function mat_slider:get_value() return self._private.value end

function mat_slider:set_read_only(value)
  if self._private.read_only ~= value then
    self._private.read_only = value
    self:emit_signal("property::read_only")
    self:emit_signal("widget::layout_changed")
  end
end

function mat_slider:get_read_only() return self._private.read_only end

function mat_slider:layout(_, width, height)
  local layout = {}
  table.insert(layout, base.place_widget_at(self._private.progress_bar, 0, dpi(21), width, height - dpi(42)))
  if not self._private.read_only then
    table.insert(layout, base.place_widget_at(self._private.slider, 0, dpi(6), width, height - dpi(12)))
  end
  return layout
end

function mat_slider:draw(_, _, _, _)
  if self._private.read_only then self._private.slider.forced_height = 0 end
end

function mat_slider:fit(_, width, height) return width, height end

local function new(args)
  local ret = base.make_widget(nil, nil, {
    enable_properties = true,
  })

  gtable.crush(ret._private, args or {})

  gtable.crush(ret, mat_slider, true)

  ret._private.progress_bar = wibox.widget({
    max_value = 100,
    value = 25,
    forced_height = dpi(6),
    paddings = 0,
    shape = gshape.rounded_rect,
    background_color = beautiful.bg_normal,
    color = beautiful.fg.hue_900,
    widget = wibox.widget.progressbar,
  })

  ret._private.slider = wibox.widget({
    forced_height = dpi(8),
    bar_shape = gshape.rounded_rect,
    bar_height = 0,
    bar_color = beautiful.fg.hue_900,
    handle_color = beautiful.fg.hue_300,
    handle_shape = gshape.circle,
    handle_border_color = "#00000012",
    handle_border_width = dpi(3),
    value = 25,
    widget = wibox.widget.slider,
  })

  ret._private.slider:connect_signal("property::value", function() ret:set_value(ret._private.slider.value) end)

  ret._private.read_only = false

  return ret
end

function mat_slider.mt:__call(...) return new(...) end

--@DOC_widget_COMMON@

--@DOC_object_COMMON@

return setmetatable(mat_slider, mat_slider.mt)
