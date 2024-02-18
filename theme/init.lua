local beautiful = require("beautiful")
local capi = require("capi")
local default_theme = require("theme.default-theme")
local gfile = require("gears.filesystem")
local path = require("util.path")
local system_default_ok, system_default = pcall(dofile, path.resolve(gfile.get_themes_dir(), "default", "theme.lua"))
local theme_dir = path.join(gfile.get_configuration_dir(), "theme")

local final_theme = system_default_ok and system_default or {}
if type(final_theme) ~= "table" then final_theme = {} end
default_theme(final_theme, theme_dir)
beautiful.init(final_theme) -- Set the theme to our newly calculated theme

-- Enable sloppy focus, so that focus follows mouse.
capi.client.connect_signal("mouse::enter", function(c)
  return c:emit_signal("request::activate", "mouse_enter", { raise = true })
end)

-- Make the focused window have a glowing border
local function focus_handler(c) ---@param c AwesomeClientInstance
  local compat = require("util.awesome.compat")
  if capi.client.focus == c then
    c.border_color = compat.beautiful.get_border_focus(beautiful)
  else
    c.border_color = compat.beautiful.get_border_normal(beautiful)
  end
end
capi.client.connect_signal("focus", focus_handler)
capi.client.connect_signal("unfocus", focus_handler)

return final_theme
