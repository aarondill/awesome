local gears = require("gears")
local awful = require("awful")
local wibox = require("wibox")

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
screen.connect_signal("request::wallpaper", function(s)
	if s.selected_tag then
		awful.wallpaper({
			screen = s,
			widget = {
				horizontal_fit_policy = "fit",
				vertical_fit_policy = "fit",
				image = get_wp_path(s.selected_tag.index),
				widget = wibox.widget.imagebox,
			},
		})
	end
end)
awful.tag.attached_connect_signal(nil, "property::selected", function(tag)
	tag.screen:emit_signal("request::wallpaper")
end)
screen.connect_signal("property::geometry", function(s)
	s:emit_signal("request::wallpaper")
end)
