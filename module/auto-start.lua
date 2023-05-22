-- MODULE AUTO-START
-- Run all the apps listed in configuration/apps.lua as run_on_start_up only once when awesome start

local awful = require("awful")
local apps = require("configuration.apps")

--- Runs the command "once". If cmd is a table where tbl[2] == true, it will be run in a shell, else it will be exec'ed in the shell
local function run_once(cmd)
	local findme = cmd
	local in_shell = false
	if type(cmd) == "table" then
		findme = cmd[1]
		if #cmd >= 2 then
			in_shell = (cmd[2] and true) or false
		end
	elseif type(cmd) ~= "string" then
		error("cmd must be a table or a string")
	end
	local firstspace = findme:find(" ")
  --stylua: ignore
	if firstspace then findme = findme:sub(0, firstspace - 1) end

	if in_shell then
		awful.spawn.with_shell(string.format("pgrep -u $USER -x %s >/dev/null || { %s; }", findme, cmd))
	else
		awful.spawn.with_shell(string.format("pgrep -u $USER -x %s >/dev/null || exec %s", findme, cmd))
	end
end

for _, app in ipairs(apps.run_on_start_up) do
	run_once(app)
end
