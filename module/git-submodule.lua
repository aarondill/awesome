local gears = require("gears")
local naughty = require("naughty")

-- NEVER use io.popen. But, I *need* this to be synchronous so the modules are available later in the code.
-- So, this is a rare exception. This command should only take a long time the first time it is called.
if io.popen then
	local file = assert(
		-- -C=run in this directory, since lua doesn't support 'cd'ing
		io.popen(string.format("git -C '%s' submodule update --init", gears.filesystem.get_configuration_dir()), "r")
	)
	local fline = file:read("l") -- Consumes the first line
	if fline then
		naughty.notify({ text = "Updating git submodules" })
		naughty.notify({ text = tostring(fline) })
	end
	for line in file:lines("l") do
		-- Give a progress notification on each line
		naughty.notify({ text = tostring(line) })
	end
	file:close()
end
