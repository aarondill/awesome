---Much of this came from awful.spawn!
local awful_spawn = require("awful.spawn")
local capi = require("capi")
local gtable = require("gears.table")
local iscallable = require("util.types.iscallable")
local lgi = require("util.lgi")
local write_outputstream = require("util.file.write_outputstream")
local Gio = lgi.Gio
local GLib = lgi.GLib

---@alias Command string|string[]|SpawnOptions
---@alias CommandProvider Command | fun(opts: SpawnOptions): Command?

local spawn = {}

---@class (exact) SpawnInfo
---@field pid integer the pid of the process if the process was started successfully, else a string error message
---@field snid string? startup notification ID
---@field stdin_fd integer? the file descriptor of the stdin of the command. This is only returned if the inherit_stdin is false (note: inherit_stdin defaults to false)
---the file descriptor of the stdout of the command. This is only returned if inherit_stdout is false
---This can be read using awful.spawn.read_lines, example from spawn.lua:
---```lua
---awful.spawn.read_lines(Gio.UnixInputStream.new(stdout_fd, true), stdout_callback, stdout_done_callback, true)
---```
---@field stdout_fd integer?
---the file descriptor of the stderr of the command. This is only returned if inherit_stderr is false
---This can be read using awful.spawn.read_lines, example from spawn.lua:
---```lua
---awful.spawn.read_lines(Gio.UnixInputStream.new(stderr_fd, true), stderr_callback, stderr_done_callback, true)
---```
---@field stderr_fd integer?
---@field cmd string|string[] the command spawned. This is after normalization has taken place.
---@field opts SpawnOptions the options used to spawn the command. This is after normalization has taken place.

---- Spawn Functions
---@alias exit_callback_func fun(reason: "exit"|"signal", code: integer)

---@param exit_cb? exit_callback_func
---@param on_err? exit_callback_func
---@param on_suc? exit_callback_func
---@return exit_callback_func?
local function gen_exit_cb(exit_cb, on_err, on_suc)
  -- If there's no error callback and no success callback, just return the exit callback
  if not on_err and not on_suc then return exit_cb end

  return function(reason, code)
    if spawn.is_normal_exit(reason, code) then
      if on_suc then on_suc(reason, code) end
    else
      if on_err then on_err(reason, code) end
    end
    if exit_cb then return exit_cb(reason, code) end
  end
end

---Normalizes cmd and opts. Handles the case where cmd is a function, and moves any options from cmd to opts.
---Clones both cmd and opts, so after this function is called, they are safe to modify
---Note: returned cmd may be empty
---@param cmd CommandProvider
---@param opts SpawnOptions?
---@return (string|string[])? cmd A command
---@return SpawnOptions opts SpawnOptions
local function normalize_command(cmd, opts)
  opts = opts and gtable.clone(opts, false) or {} -- Clone the user supplied options so they can be modified
  if cmd and iscallable(cmd) then
    -- Call the user's command with the current set of options
    -- Note that the user may modify this table, or return options in the returned command
    cmd = cmd(opts)
  end
  assert(type(cmd) ~= "function", "cmd is a function! expected Command.")

  if not cmd or #cmd == 0 then return nil, opts end -- 3 is caller of spawn.spawn

  --- Remove any non-numeric keys from cmd and apply them to opts instead
  --- Note: this process clones the cmd if it is a table (otherwise it won't matter)
  if type(cmd) == "table" then
    local new_cmd = {}
    for k, v in pairs(cmd) do
      if type(k) == "number" then
        new_cmd[k] = v
      else
        opts[k] = v
      end
    end
    cmd = new_cmd
  end

  return cmd, opts
end

---@class SpawnOptions
---The callback to call when the application starts.
---This is passed the client object (https://awesomewm.org/doc/api/classes/client.html)
---Note: this only works if the application implements startup notifications and sn_rules are enabled
---@field start_callback? fun(client: AwesomeClientInstance)
---The callback to call when the application exits.
---code is the exit status or the signal that killed the application depending on reason
---@field exit_callback? exit_callback_func
---The callback to call when the application exits with an error. See spawn.is_normal_exit.
---code is the exit status or the signal that killed the application depending on reason
---@field exit_callback_err? exit_callback_func
---The callback to call when the application exits successfully. See spawn.is_normal_exit.
---@field exit_callback_suc? exit_callback_func
---Called on spawning failure. Permits one to avoid checking the return value.
---@field on_failure_callback? fun(error: string)
---Called on spawning success. Permits one to avoid checking the return value.
---@field on_success_callback? fun(info: SpawnInfo)
---The rules to apply to the window when the application starts.
---These are enabled by default. Pass false to disable startup notification detection.
---Note: this only works if the application implements startup notifications
---@field sn_rules? table|boolean
---Whether the command should inherit the stdin of awesome.
---If false, stdin_fd will be returned, else stdin_fd will be nil
---@field inherit_stdin? boolean default true
---Whether the command should inherit the stdout of awesome.
---If false, stdout_fd will be returned, else stdout_fd will be nil
---@field inherit_stdout? boolean default true
---Whether the command should inherit the stderr of awesome.
---If false, stderr_fd will be returned, else stderr_fd will be nil
---@field inherit_stderr? boolean default true
---A table of environment variables to apply to the command.
---If false, the command will be started with an empty environment
---If nil, the command will inherit awesome's environment
---@field env? table|false
---@field stdin_string string?
---A string to input to the stdin of the command.

---A wrapper around awesome.spawn
---This can be used as a drop in replacement for awful.spawn, when only the command is passed, otherwise:
---```lua
---awful.spawn(command, sn_rules, callback) == spawn(command, { sn_rules = sn_rules, start_callback = callback })
---````
---NOTE: The return types of the above functions are different!
---
---If there was an error spawning the command, the first returned value will be nil and the second the error message (a string)
---
---@param cmd CommandProvider
---@param opts SpawnOptions?
---@return SpawnInfo? info_or_error the info about the process if the process was started successfully
---@return string? error_message An error message if something went wrong
---
---Note: start_callback only works when opts.sn_rules is given
---@see Modified from /usr/share/awesome/lib/awful/spawn.lua
function spawn.spawn(cmd, opts)
  local function handle_inherit_default(v) ---@param v boolean?
    return (v ~= nil or false) and not v -- nil->false, else->not v
  end
  local ncmd, nopts = normalize_command(cmd, opts)
  if not ncmd then return end
  cmd, opts = ncmd, nopts

  local exit_callback = gen_exit_cb(opts.exit_callback, opts.exit_callback_err, opts.exit_callback_suc)
  local use_sn = opts.sn_rules ~= false
  local return_stdin_user = handle_inherit_default(opts.inherit_stdin)
  local return_stdin = return_stdin_user or not not opts.stdin_string
  local return_stdout = handle_inherit_default(opts.inherit_stdout)
  local return_stderr = handle_inherit_default(opts.inherit_stderr)
  local env_table = opts.env == false and {} or opts.env ---@cast env_table table
  local pid_or_error, snid, stdin, stdout, stderr =
    capi.awesome.spawn(cmd, use_sn, return_stdin, return_stdout, return_stderr, exit_callback, env_table)
  if type(pid_or_error) == "string" then
    if opts.on_failure_callback then -- Call the user's callback if one exists
      opts.on_failure_callback(pid_or_error)
    end
    return nil, pid_or_error
  end
  if opts.stdin_string then --
    ---@type GOutputStream
    local stream = Gio.UnixOutputStream.new(stdin, not return_stdin_user) -- Don't close stdin on close stream, if we return to user. otherwise, close it now.
    write_outputstream(stream, opts.stdin_string, function() -- Write string to stdin
      return stream:close() -- Close sync to ensure command exits if waiting for stdin.
    end)
  end

  if snid then -- The snid will be nil in case of failure
    if awful_spawn.snid_buffer then -- else fail silently
      local sn_rules = type(opts.sn_rules) ~= "boolean" and opts.sn_rules or {}
      awful_spawn.snid_buffer[snid] = { sn_rules, { opts.start_callback } } -- Cheat by using awful.spawn's snid detection code instead.
    end
  end

  ---@type SpawnInfo
  local info = {
    pid = pid_or_error,
    snid = snid,
    stdin_fd = return_stdin_user and stdin or nil, -- Handle actual return
    stdout_fd = stdout,
    stderr_fd = stderr,
    cmd = cmd,
    opts = opts,
  }

  if opts.on_success_callback then -- Call the user's callback if one exists
    opts.on_success_callback(info)
  end
  return info
end

---See spawn.spawn and spawn.noninteractive for more information
---Stops Awesome from waiting for the process to startup.
---@param cmd CommandProvider
---@param opts SpawnOptions?
---@return SpawnInfo?, string?
---@see Modified from /usr/share/awesome/lib/awful/spawn.lua
function spawn.nosn(cmd, opts)
  opts = opts or {}
  opts.sn_rules = opts.sn_rules or false
  return spawn.spawn(cmd, opts)
end

--- Spawn a program using the shell.
---This calls `cmd` with `$SHELL -c` (via `awful.util.shell`).
---@param cmd string The command.
---@return SpawnInfo?, string?
function spawn.with_shell(cmd, opts)
  if not cmd or cmd == "" then error("No command specified.", 2) end
  return spawn.nosn({ require("awful.util").shell, "-c", cmd }, opts)
end

----- Asynchronous Functions:
local function get_end_of_file_func()
  -- API changes, bug fixes and lots of fun. Figure out how a EOF is signalled.
  -- No idea when this API changed, but some versions expect a string,
  -- others a table with some special(?) entries
  local suc, d = pcall(Gio.MemoryInputStream.new_from_data, "")
  if not suc then d = Gio.MemoryInputStream.new_from_data({}) end
  local input = Gio.DataInputStream.new(d)
  local line, length = input:read_line()
  if not line then
    return function(arg)
      return not arg -- Fixed in 2016: NULL on the C side is transformed to nil in Lua
    end
  end

  assert(tostring(line) == "", "Cannot determine how to detect EOF")

  if #line ~= length then
    -- "Historic" behaviour for end-of-file:
    -- - NULL is turned into an empty string
    -- - The length variable is not initialized
    -- It's highly unlikely that the uninitialized variable has value zero.
    return function(arg1, arg2) -- Use this hack to detect EOF.
      return #arg1 ~= arg2
    end
  end

  -- The above uninitialized variable was fixed and thus length is always 0 when line is NULL in C.
  -- We cannot tell apart an empty line and EOF in this case.
  require("gears.debug").print_warning("Cannot reliably detect EOF on an GIOInputStream with this LGI version")
  return function(arg) return tostring(arg) == "" end
end
local end_of_file = get_end_of_file_func()

---@param cb fun(line: string) called with each line read
---@param done fun(error: userdata?) called when done
local function read_lines_handler(stream, cb, done)
  if not stream then error("stream is nil") end
  if not cb and not done then error("no callback specified!") end
  return stream:read_line_async(GLib.PRIORITY_DEFAULT, nil, function(obj, res)
    local line, length = obj:read_line_finish(res)
    -- Error
    if type(length) ~= "number" then
      print("Error in read_lines:", tostring(length))
      if not done then return end
      return done(length)
    end
    if end_of_file(line, length) then
      if not done then return end
      return done()
    end
    if cb then cb(tostring(line) or "") end

    -- Read the next line
    return read_lines_handler(stream, cb, done)
  end)
end
--- Read lines from a Gio input stream
---@param input_stream GInputStream The input stream to read from.
---@param line_callback fun(line: string) Function that is called with each line read, e.g. `line_callback(line_from_stream)`.
---@param done_callback? fun(error: userdata?) Function that is called when the operation finishes (e.g. due to end of file).
---@param close boolean? Should the stream be closed after end-of-file? default true
---@return nil
function spawn.read_lines(input_stream, line_callback, done_callback, close)
  if done_callback and not iscallable(done_callback) then error("done_callback must be callable") end
  if line_callback and not iscallable(line_callback) then error("line_callback must be callable") end
  close = close == nil and true or close ---@cast close boolean
  local stream = Gio.DataInputStream.new(input_stream)
  local function done()
    if close then stream:close() end
    stream:set_buffer_size(0)
    if done_callback then done_callback() end
  end
  return read_lines_handler(stream, line_callback, done)
end
---@class LineCallbacks
---@field stdout? fun(line: string) called with each line read from stdout
---@field stderr? fun(line: string) called with each line read from stderr
---@field done? fun(error: userdata?) called when done
---@field output_done? fun(error: userdata?) called when done. Note: this is deprecated and is only for compatibility with awful.spawn.with_line_callback
---@field exit? fun(reason: "exit"|"signal", code: integer) called when exited. Note: this is deprecated and is only for compatibility with awful.spawn.with_line_callback

---@param cmd CommandProvider
---@param callbacks LineCallbacks?
---@param opts SpawnOptions?
---@return integer? pid
---@return string? error
---@return SpawnInfo? info only if no error
function spawn.with_lines(cmd, callbacks, opts)
  callbacks = callbacks or {}
  opts = opts or {}
  local stdout_callback, stderr_callback = callbacks.stdout, callbacks.stderr
  local done_callback = callbacks.done or callbacks.output_done

  local new_opts = gtable.join(opts, { -- Clones opts
    sn_rules = false,
    inherit_stdin = true,
    inherit_stdout = not stdout_callback,
    inherit_stderr = not stderr_callback,
  })
  new_opts.exit_callback = opts.exit_callback or callbacks.exit ---For reverse compatibility with awful.spawn.with_line_callback

  local info, err = spawn.spawn(cmd, new_opts)
  if not info then return nil, err end -- Error
  local stdout, stderr = info.stdout_fd, info.stderr_fd
  -- Don't mess with my options.
  if stdout_callback then assert(stdout, "You must not provide an cmd.inherit_stdout while using spawn.with_lines") end
  if stderr_callback then assert(stderr, "You must not provide an cmd.inherit_stderr while using spawn.with_lines") end

  local streams_left = 0
  streams_left = streams_left + (stdout_callback and 1 or 0)
  streams_left = streams_left + (stderr_callback and 1 or 0)

  local function step_done()
    streams_left = streams_left - 1
    if streams_left > 0 then return end
    if done_callback then return done_callback() end
  end

  if stdout_callback then spawn.read_lines(Gio.UnixInputStream.new(stdout, true), stdout_callback, step_done, true) end
  if stderr_callback then spawn.read_lines(Gio.UnixInputStream.new(stderr, true), stderr_callback, step_done, true) end
  return info.pid, nil, info
end
spawn.with_line_callback = spawn.with_lines -- Backwards compatability with awful.spawn.with_line_callback
--- Asynchronously spawn a program and capture its output. (wraps `spawn.with_line_callback`).
---@param cmd CommandProvider what to run.
---@param callback fun(stdout: string, stderr: string, reason: "exit"|"signal", code: integer)
---@param opts SpawnOptions?
---@return integer? pid
---@return string? error
---@return SpawnInfo? info only if no error
function spawn.async(cmd, callback, opts)
  opts = opts and gtable.clone(opts, false) or {} -- Clone opts, since we modify it in a moment
  local stdout, stderr = "", ""
  local exitcode, exitreason
  local function done_callback() return callback(stdout, stderr, exitreason, exitcode) end

  local exit_callback_fired = false
  local output_done_callback_fired = false
  local function exit_callback(reason, code)
    exitcode = code
    exitreason = reason
    exit_callback_fired = true
    if output_done_callback_fired then return done_callback() end
  end
  opts.exit_callback = exit_callback
  local pid, err, info = spawn.with_lines(cmd, {
    stdout = function(str) stdout = stdout .. str .. "\n" end,
    stderr = function(str) stderr = stderr .. str .. "\n" end,
    done = function()
      output_done_callback_fired = true
      if exit_callback_fired then return done_callback() end
    end,
  }, opts)
  if info then
    local ok = info.opts.exit_callback == exit_callback
    assert(ok, "You must not provide a cmd.exit_callback while using spawn.async!")
  end
  return pid, err, info
end
spawn.easy_async = spawn.async -- Backwards compatability with awful.spawn.easy_async

--- Utils for parsing
---@param reason "exit"|"signal"|string Used in exit_callback or on_failure_callback. Note: in on_failure_callback this will always return false.
---@param code integer? The exit code in exit_callback
spawn.is_normal_exit = function(reason, code)
  if not reason or not code then return false end -- If either is not provided, this is not a normal exit (used in on_failure_callback)
  if reason ~= "exit" and reason ~= "signal" then return false end -- If the reason is not 'exit' or 'signal' then this is not a normal exit (likely an error message from on_failure_callback)
  local sigterm = capi.awesome.unix_signal["SIGTERM"] or 15
  if reason == "signal" and code == sigterm then return true end -- If exited from sigterm, this is normal
  if reason == "exit" then return code == 0 end -- if exited with code, is normal if code is 0, else not normal
  return false -- Exited with signal other than SIGTERM. This is likely not normal!
end

setmetatable(spawn, {
  __call = function(_, ...) return spawn.spawn(...) end,
})

return spawn
