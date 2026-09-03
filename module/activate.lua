local aplacement = require("awful.placement")
local ascreen = require("awful.screen")
local capi = require("capi")
local desktop = require("widget.desktop")
local tables = require("util.tables")
local wibox = require("wibox")
local widgets = require("util.awesome.widgets")

---@class ActivateWidget :DesktopWidget
---@field visible boolean
---@field widget widget
local ActivateWidget = {}

---@param s AwesomeScreenInstance
---@return ActivateWidget
function ActivateWidget.new(s)
  local self = desktop.new({
    screen = s,
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
  tables.rawcrush(self, ActivateWidget) ---@cast self ActivateWidget
  return self
end
function ActivateWidget:update()
  if not self.visible then return end
  local w = self.widget
  local textbox = assert(widgets.get_by_id(w, "textbox"), "Check textbox id!") ---@cast textbox widget.textbox
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
  s.activate_box = ActivateWidget.new(s)
end)
capi.screen.connect_signal("property::geometry", function(s) ---@param s AwesomeScreenInstance
  s.activate_box:update()
end)
