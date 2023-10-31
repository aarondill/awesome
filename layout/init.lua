local require = require("util.rel_require")

local awful = require("awful")
local top_panel = require(..., "top-panel") ---@module "layout.top-panel"

---@class AwesomeScreenInstance
---@field top_panel widget an injected field that represents the top panel for that screen.

-- Create a wibox for each screen and add it
awful.screen.connect_for_each_screen(function(s)
  s.top_panel = top_panel(s) -- Create the Top bar
end)
