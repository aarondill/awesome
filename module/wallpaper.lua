local ascreen = require("awful.screen")
local atag = require("awful.tag")
local capi = require("capi")
local gfilesystem = require("gears.filesystem")
local gtimer = require("gears.timer")
local path = require("util.path")
local wibox = require("wibox")

local function get_wp_path(num) ---@param num integer
  -- Set according to wallpaper directory
  local p = path.relative(gfilesystem.get_configuration_dir(), "wallpapers")
  local wp = string.format("%s/%d.jpg", p, num)
  local default = string.format("%s/%d.jpg", p, 1)

  if gfilesystem.file_readable(wp) then return wp end
  if gfilesystem.file_readable(default) then return default end
  return path.resolve(gfilesystem.get_themes_dir(), "default", "background.png")
end

capi.screen.connect_signal("request::wallpaper", function(s) ---@param s AwesomeScreenInstance
  if not s.selected_tag then return end
  local wp_path = get_wp_path(s.selected_tag.index)
  local ok, awallpaper = pcall(require, "awful.wallpaper")
  if not ok then return require("gears.wallpaper").maximized(wp_path, s) end
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
  if not tag.screen then return end
  return tag.screen:emit_signal("request::wallpaper")
end)
capi.screen.connect_signal("property::geometry", function(s) ---@param s AwesomeScreenInstance
  return s:emit_signal("request::wallpaper")
end)

local focused_screen = ascreen.focused() ---@type AwesomeScreenInstance?
if capi.awesome.version <= "v4.3" and focused_screen then
  -- This is not signaled for the first wallpaper in older versions
  -- PERF: This is an expensive operation. Wait until setup is done.
  gtimer.delayed_call(focused_screen.emit_signal, focused_screen, "request::wallpaper")
end
