-- MODULE AUTO-START
-- Run all the apps listed in configuration/apps.lua as run_on_start_up only once when awesome start
local DEBUG = require("configuration").DEBUG

local awful = require("awful")
local naughty = require("naughty")
local beautiful = require("beautiful")
local apps = require("configuration.apps")

---@param cmd_str string the thing to run
---@return integer? pid of the process or nil if error
local function run_once(cmd_str)
	-- best case senario, just one command. Run.
	---@type table
	local cmd = { cmd_str }
	-- Contains space, run in shell just in case
	if cmd_str:find(" ") then
		-- run in sh for memory performance
		cmd = { "sh", "-c", cmd_str }
	end
	if DEBUG then
		naughty.notify({
			text = table.concat(cmd, " "),
			title = "Startup App",
			presets = naughty.config.presets.info,
			timeout = 0,
		})
	end

	local pid = awful.spawn.easy_async(
		cmd,
		---@param _ string
		---@param stderr string
		---@param exitreason "exit"|"signal"
		---@param exitcode integer
		function(_, stderr, exitreason, exitcode)
			if exitreason == "exit" and exitcode == 0 then
				return
			end
			if exitreason == "exit" and exitcode == 127 then
				-- Command not found.
				-- I don't want a warning.
				-- Remove this to send notifications for missing commands.
				return nil
			end
			local text = ""
			if exitreason == "signal" then
				local signame = tostring(awesome.unix_signal[exitcode])
				text = string.format("killed with signal: %d (%s)", tostring(exitcode), signame)
			else
				local no_end_nl = stderr:gsub("\n$", "")
				text = string.format("exit code: %d" .. "\n" .. "Stderr: %s", exitcode, no_end_nl)
			end
			naughty.notify({
				presets = naughty.config.presets.warn,
				icon = beautiful.icon_noti_error,
				title = string.format('Error while starting "%s".', table.concat(cmd, " ")),
				text = text,
				timeout = 0,
			})
		end
	)
	if type(pid) ~= "number" then
		return nil
	end
	return pid
end

local processes = {}

for _, app in ipairs(apps.run_on_start_up) do
	local pid = run_once(app)
	if pid then
		processes[#processes + 1] = pid
	end
end
-- Kill them all on exit
awesome.connect_signal("exit", function(_)
	for _, pid in ipairs(processes) do
		-- killing -p means sending a signal to every process in the process group p. Awesome makes sure to spawn processes in a new session, so this works.
		local suc = awesome.kill(-pid, 15) -- SIGTERM
		if not suc then
			io.stderr:write("Failed to kill pid " .. pid)
		end
	end
	processes = {} -- They're all dead. Doesn't matter because the table is lost anyways, but yk.
end)
