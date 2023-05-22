-- MODULE AUTO-START
-- Run all the apps listed in configuration/apps.lua as run_on_start_up only once when awesome start

local awful = require("awful")
local apps = require("configuration.apps")

local function run_once(cmd_str)
	local findme = cmd_str
	-- run in sh for memory performance
	local cmd = { "sh", "-c" }
	local base_string = "pgrep -u $USER -x %s > /dev/null ||"

	local firstspace = cmd_str:find(" ")
	if firstspace then
		findme = cmd_str:sub(0, firstspace - 1)
		table.insert(cmd, string.format(base_string .. " { %s; }", findme, cmd_str))
	else
		-- best case senario, just one command. Exec directly.
		table.insert(cmd, string.format(base_string .. " exec %s", findme, cmd_str))
	end

	awful.spawn(cmd, false)
end

for _, app in ipairs(apps.run_on_start_up) do
	run_once(app)
end
