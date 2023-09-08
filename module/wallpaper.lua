local ascreen = require("awful.screen")
local atag = require("awful.tag")
local gfilesystem = require("gears.filesystem")
local wibox = require("wibox")

local get_wp_path
do
  -- Set according to wallpaper directory
  local path = gfilesystem.get_configuration_dir() .. "wallpapers"
  -- Other variables
  local default = path .. "/1.jpg"
  if not gfilesystem.file_readable(default) then default = gfilesystem.get_themes_dir() .. "default/background.png" end

  get_wp_path = function(num)
    local wp = string.format("%s/%s.jpg", path, tostring(num))
    if gfilesystem.file_readable(wp) then
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
  local has_awall, awallpaper = pcall(require, "awful.wallpaper")
  if has_awall then
    awallpaper({
      screen = s,
      widget = {
        horizontal_fit_policy = "fit",
        vertical_fit_policy = "fit",
        image = wp_path,
        widget = wibox.widget.imagebox,
      },
    })
  else
    require("gears.wallpaper").maximized(wp_path, s)
  end
end)

atag.attached_connect_signal(nil, "property::selected", function(tag)
  if tag.screen then tag.screen:emit_signal("request::wallpaper") end
end)
screen.connect_signal("property::geometry", function(s)
  s:emit_signal("request::wallpaper")
end)

if awesome.version <= "v4.3" and ascreen.focused() then
  -- This is not signalled for the first wallpaper in older versions
  ascreen.focused():emit_signal("request::wallpaper")
end
