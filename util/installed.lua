local awful = require("awful")
local naughty = require("naughty")

-- State to ensure only one notification is sent
local has_notified = false

---Check if a program is available and pass it to the callback.
---Uses which to find the executable. Will only when which itself is installed.
---@param program string? the program to check. If nil, will not be checked.
---@param cb fun(path: string?) run with the path if found, or nil if not found.
local function installed(program, cb)
	awful.spawn.easy_async({ "which", program }, function(stdout, _, exitreason, exitcode)
		-- If command not found
		if exitreason == "exit" and exitcode == 127 then
			if not has_notified then
				naughty.notify({
					preset = naughty.config.presets.warn,
					title = "Could not find 'which'",
					text = "Please ensure 'which' is installed have a better experience.",
				})
			end
		end

		if exitreason == "exit" and exitcode == 0 then
			cb(stdout)
		else
			cb(nil)
		end
	end)
end

return installed
