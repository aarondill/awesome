local aplacement = require("awful.placement")
local ascreen = require("awful.screen")
local desktop = require("widget.desktop")
local gtable = require("gears.table")
local wibox = require("wibox")
local widgets = require("util.awesome.widgets")

---@class ActivateWidget :ActivateWidgetOpts
---@field visible boolean
--- @field widget widget
local ActivateWidget = {}

---@class ActivateWidgetOpts
---@field screen AwesomeScreenInstance

---@param opts ActivateWidgetOpts
function ActivateWidget.new(opts)
  local self = desktop.new({
    screen = opts.screen,
    widget = wibox.widget({
      widget = wibox.container.margin,
      {
        widget = wibox.widget.textbox,
        id = "textbox",
        valign = "middle",
        text = table.concat({
          "Activate Linux",
          "Go to Settings to activate Linux.",
        }, "\n"),
      },
    }),
  })
  gtable.crush(self, ActivateWidget) -- DON'T USE a metatable here, it breaks __index

  self:connect_signal("property::visible", function() self:update() end)
  self:update() -- The initial update

  return self
end
function ActivateWidget:update()
  if not self.visible then return end
  local w = self.widget ---@type widget
  local textbox = assert(widgets.get_by_id(w, "textbox"), "Check textbox id!")
  local width, height = textbox:get_preferred_size(self.screen)
  self.width = math.min(width, self.screen.workarea.width) -- crop to workarea size if too big
  self.height = math.min(height, self.screen.workarea.height) -- crop to workarea size if too big
  aplacement.bottom_right(self, {
    honor_padding = true,
    honor_workarea = true,
    margins = { right = 8, bottom = 8 },
  })
end

---@class AwesomeScreenInstance
---@field activate_box? ActivateWidget injected field for use in Activate Linux box
ascreen.connect_for_each_screen(function(s) ---@param s AwesomeScreenInstance
  ---Assignment is required to avoid garbage collection
  s.activate_box = ActivateWidget.new({ screen = s })
end)
