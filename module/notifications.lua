local capi = require("capi")
local gtable = require("gears.table")
local gtimer = require("gears.timer")
local list_directory = require("util.file.list_directory")
local naughty = require("naughty")

-- Icon directories have to be hard coded.
naughty.config.icon_formats = { "ico", "icon", "jpg", "png", "svg" }
naughty.config.icon_dirs = { "/usr/share/pixmaps/", "/usr/share/icons/Yaru/", "/usr/share/icons/hicolor/" }
-- Async. Could miss first few notifications, but hopefully is done before too many notifications.
list_directory("/usr/share/icons", function(names, _)
  if not names then return end
  return gtable.merge(naughty.config.icon_dirs, names)
end)

-- Naughty presets
naughty.config.padding = 8
naughty.config.spacing = 8

naughty.config.defaults.timeout = 5
-- naughty.config.defaults.screen = 1
naughty.config.defaults.position = "bottom_left"
naughty.config.defaults.ontop = true
naughty.config.defaults.hover_timeout = nil

-- Error handling
gtimer.delayed_call(function()
  if capi.awesome.startup_errors then
    local notifs = require("util.notifs")
    notifs.critical(tostring(capi.awesome.startup_errors), {
      title = "Oops, there were errors during startup!",
    })
  end
end)

do
  local in_error = false
  capi.awesome.connect_signal("debug::error", function(err)
    local notifs = require("util.notifs")
    if in_error then return end
    in_error = true

    local msg = table.concat({ tostring(err), debug.traceback(nil, 2) }, "\n")
    notifs.critical(msg, { title = "Oops, an error happened!" })
    in_error = false
  end)
end

---@param hint string String with a hint on what to use instead of the deprecated functionality.
---@param see string? The name of the newer API (default nil)
---@param args table? The args to gears.depreciate? I think?
capi.awesome.connect_signal("debug::deprecate", function(hint, see, args)
  local notifs = require("util.notifs")
  local msg = string.format("%s: %s\n%s", hint, see or "", debug.traceback(nil, 2))
  notifs.warn(msg)
end)
