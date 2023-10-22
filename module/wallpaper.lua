local capi = require("capi")
local require = require("util.rel_require")

local ascreen = require("awful.screen")
local atag = require("awful.tag")
local gfilesystem = require("gears.filesystem")
local wibox = require("wibox")

local function get_wp_path(num) ---@param num integer
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

capi.screen.connect_signal("request::wallpaper", function(s) ---@param s AwesomeScreenInstance
  if not s.selected_tag then return end
  local wp_path = get_wp_path(s.selected_tag.index)
  local awallpaper = require("awful.wallpaper", nil, false) ---@module "awful.wallpaper"
  if not awallpaper then return require("gears.wallpaper").maximized(wp_path, s) end
  return awallpaper({
    screen = s,
    widget = {
      horizontal_fit_policy = "fit",
      vertical_fit_policy = "fit",
      image = wp_path,
      widget = wibox.widget.imagebox,
    },
  })
end)

atag.attached_connect_signal(nil, "property::selected", function(tag) ---@param tag AwesomeTagInstance
  if tag.screen then tag.screen:emit_signal("request::wallpaper") end
end)
capi.screen.connect_signal("property::geometry", function(s) ---@param s AwesomeScreenInstance
  s:emit_signal("request::wallpaper")
end)

local focused_screen = ascreen.focused() ---@type AwesomeScreenInstance
if capi.awesome.version <= "v4.3" and focused_screen then
  -- This is not signaled for the first wallpaper in older versions
  focused_screen:emit_signal("request::wallpaper")
end
