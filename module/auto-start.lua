-- MODULE AUTO-START
-- Run all the apps listed in configuration/apps.lua as run_on_start_up only once when awesome start

local awful = require("awful")
local apps = require("configuration.apps")

local function run_once(cmd)
	local findme = cmd
	if type(cmd) == "table" then
		findme = cmd[1]
	elseif type(cmd) ~= "string" then
		error("cmd must be a table or a string")
	end
	local firstspace = findme:find(" ")
	if firstspace then
		findme = findme:sub(0, firstspace - 1)
		awful.spawn.with_shell(string.format("pgrep -u $USER -x %s > /dev/null || { %s; }", findme, cmd))
	else
		-- best case senario, just one command. Exec directly.
		awful.spawn.with_shell(string.format("pgrep -u $USER -x %s > /dev/null || exec %s", findme, cmd))
	end
end

for _, app in ipairs(apps.run_on_start_up) do
	run_once(app)
end
