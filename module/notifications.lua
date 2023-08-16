local gears = require("gears")
local naughty = require("naughty")
local notifs = require("util.notifs")
local dpi = require("beautiful").xresources.apply_dpi
local list_directory = require("util.file.list_directory")

-- Icon directories have to be hard coded.
naughty.config.icon_formats = { "ico", "icon", "jpg", "png", "svg" }
naughty.config.icon_dirs = { "/usr/share/pixmaps/", "/usr/share/icons/Yaru/", "/usr/share/icons/hicolor/" }
-- Async. Could miss first few notifications, but hopefully is done before too many notifications.
list_directory("/usr/share/icons", function(names, _)
  if names then gears.table.merge(naughty.config.icon_dirs, names) end
end)

-- Naughty presets
naughty.config.padding = 8
naughty.config.spacing = 8

naughty.config.defaults.timeout = 5
naughty.config.defaults.screen = 1
naughty.config.defaults.position = "bottom_left"
naughty.config.defaults.margin = dpi(08)
naughty.config.defaults.ontop = true
naughty.config.defaults.font = "Roboto Regular 10"
naughty.config.defaults.icon = nil
-- This *MUST* be defined, otherwise naughty.notify has some weird behavior when searching for icons without a given size.
naughty.config.defaults.icon_size = dpi(24)
naughty.config.defaults.shape = gears.shape.rounded_rect
naughty.config.defaults.border_width = 0
naughty.config.defaults.hover_timeout = nil

-- Error handling
if awesome.startup_errors then
  notifs.critical(tostring(awesome.startup_errors), {
    title = "Oops, there were errors during startup!",
  })
end

do
  local in_error = false
  awesome.connect_signal("debug::error", function(err)
    if in_error then return end
    in_error = true

    notifs.critical(tostring(err) .. "\n" .. debug.traceback(nil, 2), {
      title = "Oops, an error happened!",
    })
    in_error = false
  end)
end

---@param hint string String with a hint on what to use instead of the deprecated functionality.
---@param see string? The name of the newer API (default nil)
---@param args table? The args to gears.depreciate? I think?
awesome.connect_signal("debug::deprecate", function(hint, see, args)
  local msg = string.format("%s: %s\n%s", hint, see or "", debug.traceback(nil, 2))

  notifs.warn(msg)
end)
