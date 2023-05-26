local gtable = require("gears.table")
local gfile = require("gears.filesystem")
local system_default_ok, system_default = pcall(dofile, gfile.get_themes_dir() .. "default/theme.lua")
local default_theme = require("theme.default-theme")
local theme = require("theme.titus-theme")

local final_theme = {}
gtable.crush(final_theme, (system_default_ok and system_default) or {})
gtable.crush(final_theme, default_theme.theme)
gtable.crush(final_theme, theme.theme)
default_theme.awesome_overrides(final_theme)
theme.awesome_overrides(final_theme)

return final_theme
