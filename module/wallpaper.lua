local gears = require("gears")
local awful = require("awful")

-- Set according to wallpaper directory
local path = gears.filesystem.get_configuration_dir() .. "wallpapers"
-- Other variables
local default = path .. "/1.jpg"
if not gears.filesystem.file_readable(default) then
	default = gears.filesystem.get_themes_dir() .. "default/background.png"
end

local function get_wp_path(num)
	local wp = string.format("%s/%s.jpg", path, tostring(num))
	if gears.filesystem.file_readable(wp) then
		return wp
	else
		return default
	end
end
-- On all screens:
-- Set wallpaper on first tab (else it would be empty at start up)
gears.wallpaper.maximized(get_wp_path(1), nil)
local function set_wallpaper(tag)
	-- And if selected
	if tag and tag.selected then
		-- Set wallpaper
		gears.wallpaper.maximized(get_wp_path(tag.index), tag.screen.index)
	end
end

awful.tag.attached_connect_signal(nil, "property::selected", set_wallpaper)
screen.connect_signal("property::geometry", function()
	set_wallpaper(awful.screen.focused().selected_tag)
end)
