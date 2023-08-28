local default_theme = require("theme.default-theme")
local gfile = require("gears.filesystem")
local system_default_ok, system_default = pcall(dofile, gfile.get_themes_dir() .. "default/theme.lua")
local theme_dir = gfile.get_configuration_dir() .. "/theme"

local final_theme = system_default_ok and system_default or {}
if type(final_theme) ~= "table" then final_theme = {} end
default_theme(final_theme, theme_dir)
return final_theme
