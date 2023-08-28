local default_theme = require("theme.default-theme")
local gfile = require("gears.filesystem")
local gtable = require("gears.table")
local theme = require("theme.titus-theme")
local system_default_ok, system_default = pcall(dofile, gfile.get_themes_dir() .. "default/theme.lua")

local final_theme = {}
gtable.crush(final_theme, (system_default_ok and system_default) or {})
gtable.crush(final_theme, default_theme)
gtable.crush(final_theme, theme)
return final_theme
