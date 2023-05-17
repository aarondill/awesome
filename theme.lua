local beautiful = require("beautiful")
local fs = require("gears.filesystem")
local naughty = require("naughty")
local util = require("util")
---Sets the theme based on themeName, or else the default theme
---@param themeName string? naame of the theme (directory)
return function(themeName)
	-- System default theme
	local path = fs.get_themes_dir() .. "default/theme.lua"
	-- Themes define colours, icons, font and wallpapers.
	if themeName then
		local theme = fs.get_configuration_dir() .. "themes/" .. themeName .. "/theme.lua"
		if fs.file_readable(theme) then
			path = theme
		else
			util.err({
				text = "Could not load theme '" .. themeName .. "'",
				title = "Themes",
			})
		end
	end

	beautiful.init(path)

	beautiful.useless_gap = 3
	beautiful.gap_single_client = true
end
