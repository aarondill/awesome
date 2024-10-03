local atag = require("awful.tag")
local capi = require("capi")
local gfilesystem = require("gears.filesystem")
local gtimer = require("gears.timer")
local path = require("util.path")
local wibox = require("wibox")
local cairo = require("lgi").cairo
local GdkPixbuf = require("lgi").GdkPixbuf
local tables = require("util.tables")
--- Place in a module so it can be changed at runtime
local M = {
  --- Note: This is directly related to the amount of memory AwesomeWM will use
  QUALITY_REDUCTION = 2 / 3,
}

local function get_wp_path(num) ---@param num integer
  -- Set according to wallpaper directory
  local p = path.resolve(gfilesystem.get_configuration_dir(), "wallpapers")
  local wp = string.format("%s/%d.jpg", p, num)
  local default = string.format("%s/%d.jpg", p, 1)

  if gfilesystem.file_readable(wp) then return wp end
  if gfilesystem.file_readable(default) then return default end
  return path.resolve(gfilesystem.get_themes_dir(), "default", "background.png")
end

local function get_geometry(s) ---@param s AwesomeScreenInstance
  if s and s.geometry then return s.geometry end
  local width, height = capi.root.size()
  return { x = 0, y = 0, width = width, height = height }
end

---@class AwesomeScreenInstance
---@field _wallpaper? table A table describing the last wallpaper set on the screen. This is an injected field!

capi.screen.connect_signal("request::wallpaper", function(s) ---@param s AwesomeScreenInstance
  if not s.selected_tag then return end
  local wp_path = get_wp_path(s.selected_tag.index)

  --- A reimplementation of surface.load_uncached_silently which scales down the image
  local geom = get_geometry(s)
  local aspect_w = math.floor(M.QUALITY_REDUCTION * geom.width)
  local aspect_h = math.floor(M.QUALITY_REDUCTION * geom.height)

  local new_wallpaper = { wp_path, geom, aspect_w, aspect_h }
  -- The wallpaper (and size) hasn't changed. Don't modify it.
  if tables.deep_equal(s._wallpaper, new_wallpaper) then return end
  s._wallpaper = new_wallpaper

  local pixbuf, err = GdkPixbuf.Pixbuf.new_from_file_at_scale(wp_path, aspect_w, aspect_h, true)
  if not pixbuf then error("No pixbuf could be created: " .. tostring(err)) end
  local _surface = capi.awesome.pixbuf_to_surface(pixbuf._native, wp_path)
  local surf = cairo.Surface:is_type_of(_surface) and _surface or cairo.Surface(_surface, true)

  if pcall(require, "awful.wallpaper") then
    require("awful.wallpaper")({
      screen = s,
      widget = {
        horizontal_fit_policy = "fit",
        vertical_fit_policy = "fit",
        image = surf,
        widget = wibox.widget.imagebox,
      },
    })
  else
    require("gears.wallpaper").maximized(surf, s)
    surf:finish()
  end
  --PERF: Collect the previous wallpaper (Cairo Surface)
  --Since these can be very high resolution images,
  --we save a lot of memory by collecting them.

  ---@diagnostic disable-next-line: cast-local-type -- it's nil! They can't be accessed anymore
  surf, _surface, pixbuf, geom = nil, nil, nil, nil -- No more references
  return collectgarbage("collect")
end)

atag.attached_connect_signal(nil, "property::selected", function(tag) ---@param tag AwesomeTagInstance
  if not tag.screen then return end
  return tag.screen:emit_signal("request::wallpaper")
end)
capi.screen.connect_signal("property::geometry", function(s) ---@param s AwesomeScreenInstance
  return s:emit_signal("request::wallpaper")
end)

if capi.awesome.version <= "v4.3" then
  -- This is not signaled for the first wallpaper in older versions
  -- PERF: This is an expensive operation. Wait until setup is done.
  gtimer.delayed_call(function()
    for s in capi.screen do
      s:emit_signal("request::wallpaper")
    end
  end)
end
return M
