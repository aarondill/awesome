local require = require("util.rel_require")

local ascreen = require("awful.screen")
local atag = require("awful.tag")
local gfilesystem = require("gears.filesystem")
local wibox = require("wibox")

local function get_wp_path(num)
  -- Set according to wallpaper directory
  local path = gfilesystem.get_configuration_dir() .. "wallpapers"
  local wp = string.format("%s/%d.jpg", path, num)
  local default = string.format("%s/%d.jpg", path, 1)
  if gfilesystem.file_readable(wp) then
    return wp
  elseif gfilesystem.file_readable(default) then
    return default
  else
    return gfilesystem.get_themes_dir() .. "default/background.png"
  end
end

screen.connect_signal("request::wallpaper", function(s)
  --stylua: ignore
	if not s.selected_tag then return end
  local wp_path = get_wp_path(s.selected_tag.index)
  local awallpaper = require("awful.wallpaper", nil, false)
  if awallpaper then
    return awallpaper({
      screen = s,
      widget = {
        horizontal_fit_policy = "fit",
        vertical_fit_policy = "fit",
        image = wp_path,
        widget = wibox.widget.imagebox,
      },
    })
  end
  require("gears.wallpaper").maximized(wp_path, s)
end)

atag.attached_connect_signal(nil, "property::selected", function(tag)
  if tag.screen then tag.screen:emit_signal("request::wallpaper") end
end)
screen.connect_signal("property::geometry", function(s)
  s:emit_signal("request::wallpaper")
end)

if awesome.version <= "v4.3" and ascreen.focused() then
  -- This is not signaled for the first wallpaper in older versions
  ascreen.focused():emit_signal("request::wallpaper")
end
