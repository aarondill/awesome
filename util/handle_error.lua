local naughty = require("naughty")
---Run func and notify on error
---Not typed because generics can't handle it properly
local function handle_error(func)
	return function(...)
		local ok, val_or_err = pcall(func, ...)
		if ok then
			return val_or_err
		end

		naughty.notify({
			preset = naughty.config.presets.critical,
			title = "Something went terribly wrong",
			text = tostring(val_or_err),
		})
		return nil
	end
end

return handle_error
