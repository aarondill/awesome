local capi = { awesome = awesome }
local awful_spawn = require("awful.spawn")

---@class SpawnOptions
---@field start_callback? fun(client: table) The callback to call when the application starts.
---This is passed the client object (https://awesomewm.org/doc/api/classes/client.html)
-- Note: this only works if the application implements startup notifications and sn_rules are enabled
---@field exit_callback? fun()
---The callback to call when the application exits.
---@field sn_rules? table|boolean The rules to apply to the window when the application starts.
---These are enabled by default. Pass false to disable startup notification detection.
---Note: this only works if the application implements startup notifications
---@field inherit_stdin? boolean Whether the command should inherit the stdin of awesome.
---If true, stdin_fd will be returned, else stdin_fd will be nil
---This defaults to false to prevent it from taking control of the underlying terminal
---@field inherit_stdout? boolean Whether the command should inherit the stdout of awesome.
---If true, stdout_fd will be returned, else stdout_fd will be nil
---@field inherit_stderr? boolean Whether the command should inherit the stderr of awesome.
---If true, stderr_fd will be returned, else stderr_fd will be nil
---@field env? table|false A table of environment variables to apply to the command.
---If false, the command will be started with an empty environment
---If nil, the command will inherit awesome's environment

---A wrapper around awesome.spawn
---This can be used as a drop in replacement for awful.spawn, when only the command is passed, otherwise:
---```lua
---awful.spawn(command, sn_rules, callback) == spawn(command, { sn_rules = sn_rules, start_callback = callback })
---````
---If there was an error spawning the command, the first returned value will be the error message (a string) and all other values will be nil
---@param cmd string|string[]
---@param opts SpawnOptions?
---@return integer|string pid_or_error the pid of the process if the process was started successfully, else a string error message
---@return string? snid
---@return integer? stdin_fd the file descriptor of the stdin of the command. This is only returned if the inherit_stdin is false (note: inherit_stdin defaults to false)
---@return integer? stdout_fd the file descriptor of the stdout of the command. This is only returned if inherit_stdout is false
---This can be read using awful.spawn.read_lines, example from spawn.lua:
---```lua
---awful.spawn.read_lines(Gio.UnixInputStream.new(stdout_fd, true), stdout_callback, stdout_done_callback, true)
---```
---@return string? stderr_fd the file descriptor of the stderr of the command. This is only returned if inherit_stderr is false
---This can be read using awful.spawn.read_lines, example from spawn.lua:
---```lua
---awful.spawn.read_lines(Gio.UnixInputStream.new(stderr_fd, true), stderr_callback, stderr_done_callback, true)
---```
---
---Note: start_callback only works when opts.sn_rules is given
---@source Modified from /usr/share/awesome/lib/awful/spawn.lua
local function spawn(cmd, opts)
	if not cmd or #cmd == 0 then
		error("No command specified.", 2)
		return -1 -- Should never happen
	end
	opts = opts or {}
	local start_callback, exit_callback = opts.start_callback, opts.exit_callback
	local use_sn = opts.sn_rules ~= false
	local return_stdin = opts.inherit_stdin == nil and true or not opts.inherit_stdin
	local return_stdout = not opts.inherit_stdout
	local return_stderr = not opts.inherit_stderr
	local env_table = opts.env == false and {} or opts.env
	local pid_or_error, snid, stdin, stdout, stderr =
		capi.awesome.spawn(cmd, use_sn, return_stdin, return_stdout, return_stderr, exit_callback, env_table)
	if snid then -- The snid will be nil in case of failure
		local sn_rules = type(opts.sn_rules) ~= "boolean" and opts.sn_rules or {}
		if awful_spawn.snid_buffer then -- else fail silently
			awful_spawn.snid_buffer[snid] = { sn_rules, { start_callback } }
		end
	end
	return pid_or_error, snid, stdin, stdout, stderr
end

return spawn