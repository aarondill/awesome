local M = {}
local naughty = require("naughty")
local gears = require("gears")

---naughty.notify with default error styles
---@param args table same as naughty.notify
function M.err(args)
	naughty.notify(gears.table.crush({
		preset = naughty.config.presets.critical,
	}, args))
end

return M
