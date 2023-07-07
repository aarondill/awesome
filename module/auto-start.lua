-- MODULE AUTO-START
-- Run all the apps listed in configuration/apps.lua as run_on_start_up only once when awesome start
local DEBUG = require("configuration").DEBUG

local awful = require("awful")
local gears = require("gears")
local naughty = require("naughty")
local beautiful = require("beautiful")
local apps = require("configuration.apps")
local serialize_table = require("util.serialize_table")
local file_write = require("util.async_file_write")

--- Directory for logging failed(?) application's output
--- This *MUST* end in a slash
local log_dir = gears.filesystem.get_cache_dir() .. "auto-start" .. "/"
--- A map of cmds to pids
local processes = {}

local function err(cmd, e)
	naughty.notify({
		presets = naughty.config.presets.warn,
		icon = beautiful.icon_noti_error,
		title = string.format('Error while starting "%s".', type(cmd) == "table" and table.concat(cmd, " ") or cmd),
		text = tostring(e),
		timeout = 0,
	})
end

---@param cmd string|string[] the thing to run
---@return integer? pid of the process or nil if error
local function run_once(cmd)
	if not cmd then
		return nil
	end
	---@type string|string[]
	if not type(cmd) == "string" and not type(cmd) == "table" then
		error("Startup apps must be string or table")
	end

	--- Used in log to ensure that the date matches the *start* date, not the *end* date
	local CMD_DATE = os.date() ---@cast CMD_DATE string
	local pid = awful.spawn.easy_async(
		cmd,
		---@param stdout string
		---@param stderr string
		---@param exitreason "exit"|"signal"
		---@param exitcode integer
		function(stdout, stderr, exitreason, exitcode)
			if exitreason == "exit" and exitcode == 0 then
				return
			end
			if exitreason == "exit" and exitcode == 127 and not DEBUG then
				-- Command not found.
				-- I don't want a warning.
				-- Remove this to send notifications for missing commands.
				return nil
			end

			--- The pid of the process. Don't assume this exists. Race Conditions.
			local pid = processes[cmd]
			--- Files to write to. These may be nil.
			local log_file_stdout, log_file_stderr
			if pid then
				log_file_stdout = log_dir .. pid .. "-stdout.log"
				log_file_stderr = log_dir .. pid .. "-stderr.log"
			end
			if log_file_stdout and log_file_stderr then
				--- Header for the log file
				local header = ([[Command: %s
Date: %s
----------------------------------------
]]):format(type(cmd) == "table" and serialize_table(cmd) or cmd, CMD_DATE)
				-- Ensure it exists!
				gears.filesystem.make_parent_directories(log_file_stdout)
				gears.filesystem.make_parent_directories(log_file_stderr)
				-- *Async* write.
				file_write(log_file_stdout, header .. stdout)
				file_write(log_file_stderr, header .. stderr)
			end

			local text = ""
			if exitreason == "signal" then
				if exitcode == awesome.unix_signal.SIGSEGV then -- Segfault
					text = "Segfaulted!"
				else
					local signame = tostring(awesome.unix_signal[exitcode])
					text = string.format("killed with signal: %d (%s)", tostring(exitcode), signame)
				end
			else
				text = string.format("exit code: %d", exitcode)
			end
			if log_file_stdout and log_file_stderr then
				text = text .. "\n" .. ("Logs are available at: %s and %s"):format(log_file_stdout, log_file_stderr)
			end
			err(cmd, text)
		end
	)
	if type(pid) == "number" then
		return pid
	elseif DEBUG then
		-- Something went wrong. Likely isn't installed. This would be where you notify if you want to when a command is not found.
		err(cmd, pid)
	end
	return nil
end

for _, app in ipairs(apps.run_on_start_up) do
	local pid = run_once(app)
	if pid then
		processes[app] = pid
	end
end
-- Kill them all on exit
awesome.connect_signal("exit", function(_)
	for _, pid in pairs(processes) do
		-- killing -p means sending a signal to every process in the process group p. Awesome makes sure to spawn processes in a new session, so this works.
		local suc = awesome.kill(-pid, 15) -- SIGTERM
		if not suc then
			-- Can't notify because shutting down
			io.stderr:write("Failed to kill pid " .. pid)
		end
	end
	processes = {} -- They're all dead. Doesn't matter because the table is lost anyways, but yk.
end)
