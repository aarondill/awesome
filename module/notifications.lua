local naughty = require("naughty")
local gears = require("gears")
local awful = require("awful")
local dpi = require("beautiful").xresources.apply_dpi

-- Icon directories have to be hard coded.
naughty.config.icon_dirs = {
	"/usr/share/pixmaps/",
	"/usr/share/icons/Yaru",
	"/usr/share/icons/hicolor",
}
-- Async. Could miss first few notifications, but hopefully is done before too many notifications.
awful.spawn.easy_async("find /usr/share/icons -maxdepth 1 -mindepth 1 -type d -print", function(stdout, _, _, exitcode)
  -- stylua: ignore
	if exitcode ~= 0 then return end
	for line in stdout:gmatch("(.-)\n") do
		table.insert(naughty.config.icon_dirs, line)
	end
end)

-- Naughty presets
naughty.config.padding = 8
naughty.config.spacing = 8

naughty.config.defaults.timeout = 5
naughty.config.defaults.screen = 1
naughty.config.defaults.position = "bottom_left"
naughty.config.defaults.margin = dpi(16)
naughty.config.defaults.ontop = true
naughty.config.defaults.font = "Roboto Regular 10"
naughty.config.defaults.icon = nil
naughty.config.defaults.icon_size = dpi(32)
naughty.config.defaults.shape = gears.shape.rounded_rect
naughty.config.defaults.border_width = 0
naughty.config.defaults.hover_timeout = nil

-- Error handling
if awesome.startup_errors then
	naughty.notify({
		preset = naughty.config.presets.critical,
		title = "Oops, there were errors during startup!",
		text = awesome.startup_errors,
	})
end

do
	local in_error = false
	awesome.connect_signal("debug::error", function(err)
		if in_error then
			return
		end
		in_error = true

		naughty.notify({
			preset = naughty.config.presets.critical,
			title = "Oops, an error happened!",
			text = tostring(err) .. "\n" .. debug.traceback(nil, 2),
		})
		in_error = false
	end)
end

---@param hint string String with a hint on what to use instead of the deprecated functionality.
---@param see string? The name of the newer API (default nil)
---@param args table? The args to gears.depreciate? I think?
awesome.connect_signal("debug::deprecate", function(hint, see, args)
	local msg = string.format("%s: %s\n%s", hint, see or "", debug.traceback(nil, 2))

	naughty.notify({ preset = naughty.config.presets.warn, text = msg })
end)
