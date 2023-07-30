local gears = require("gears")
local awful = require("awful")
local wibox = require("wibox")

local get_wp_path
do
	-- Set according to wallpaper directory
	local path = gears.filesystem.get_configuration_dir() .. "wallpapers"
	-- Other variables
	local default = path .. "/1.jpg"
	if not gears.filesystem.file_readable(default) then
		default = gears.filesystem.get_themes_dir() .. "default/background.png"
	end

	get_wp_path = function(num)
		local wp = string.format("%s/%s.jpg", path, tostring(num))
		if gears.filesystem.file_readable(wp) then
			return wp
		else
			return default
		end
	end
end

screen.connect_signal("request::wallpaper", function(s)
  --stylua: ignore
	if not s.selected_tag then return end
	local wp_path = get_wp_path(s.selected_tag.index)
	if awesome.version <= "v4.3" then
		gears.wallpaper.maximized(wp_path, screen)
	else
		awful.wallpaper({
			screen = s,
			widget = {
				horizontal_fit_policy = "fit",
				vertical_fit_policy = "fit",
				image = wp_path,
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
