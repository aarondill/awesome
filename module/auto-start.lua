-- MODULE AUTO-START
-- Run all the apps listed in configuration/apps.lua as run_on_start_up only once when awesome start

local awful = require("awful")
local apps = require("configuration.apps")

---@param cmd_str string the thing to run
local function run_once(cmd_str)
	-- best case senario, just one command. Run.
	---@type string|table
	local cmd = cmd_str
	-- Contains space, run in shell just in case
	if cmd_str:find(" ") then
		-- run in sh for memory performance
		cmd = { "sh", "-c", cmd_str }
	end

	return awful.spawn(cmd, false)
end

local processes = {}

for _, app in ipairs(apps.run_on_start_up) do
	processes[#processes + 1] = run_once(app)
end
-- Kill them all on exit
awesome.connect_signal("exit", function(_)
	for _, pid in ipairs(processes) do
		awesome.kill(pid, 15) -- SIGTERM
	end
	processes = {} -- They're all dead. Doesn't matter because the table is lost anyways, but yk.
end)
