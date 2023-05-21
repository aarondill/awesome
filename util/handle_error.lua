local naughty = require("naughty")
---Run func and notify on error
---Not typed because generics can't handle it properly
local function handle_error(func, ...)
	local ok, err = pcall(func, ...)
	if not ok then
		naughty.notify({
			preset = naughty.config.presets.critical,
			title = "Something went terribly wrong",
			text = tostring(err),
		})
	end
end

return handle_error
