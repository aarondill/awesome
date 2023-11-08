local ascreen = require("awful.screen")
local atag = require("awful.tag")
local capi = require("capi")
local gfilesystem = require("gears.filesystem")
local gtimer = require("gears.timer")
local wibox = require("wibox")

local function get_wp_path(num) ---@param num integer
  -- Set according to wallpaper directory
  local path = gfilesystem.get_configuration_dir() .. "wallpapers"
  local wp = string.format("%s/%d.jpg", path, num)
  local default = string.format("%s/%d.jpg", path, 1)

  if gfilesystem.file_readable(wp) then return wp end
  if gfilesystem.file_readable(default) then return default end
  return gfilesystem.get_themes_dir() .. "default/background.png"
end

local function set_wp(s) ---@param s AwesomeScreenInstance
  if not s or not s.selected_tag then return end
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
end

capi.screen.connect_signal("request::wallpaper", function(s) ---@param s AwesomeScreenInstance
  --PERF: Delay the call until the next iteration to avoid slowing startup
  --Also avoids freezeing the interface when switching tags, allowing user input to continue being processed
  return gtimer.delayed_call(set_wp, s)
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
  focused_screen:emit_signal("request::wallpaper")
end
