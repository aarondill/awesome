local path = require("util.path")
local require = require("util.rel_require")

local Gio = require("lgi").Gio
local capi = require("capi")
local gfile = require("gears.filesystem")
local gtimer = require("gears.timer")
local notifs = require("util.notifs")
local spawn = require("util.spawn")

local config_file_dir = require(..., "conffile_dir") ---@module "configuration.apps.conffile_dir"

--- The compositor module. Includes functions to control the compositor process.
--- Note: This module is *not* intended to support multiple compositor processes. Also note that *Xorg* doesn't support multiple compositor processes.
local compositor = {}
compositor.pid_file = os.tmpname() -- A unique filename to use for the pid of *this* AwesomeWM process. Note that this *should* support multiple Xorg/AwesomeWM processes.

local runtime = os.getenv("XDG_RUNTIME_DIR") or ("/run/user/" .. assert(Gio.Credentials.new():get_unix_user()))
local log_file = path.join(runtime, "/picom", (os.getenv("DISPLAY") or "picom") .. ".log")
assert(gfile.make_parent_directories(log_file))
compositor.cmd = {
  "picom",
  "--config",
  config_file_dir .. "/picom.conf",
  "--write-pid-path",
  compositor.pid_file,
  "--log-file",
  log_file,
}
---@param reason "exit"|"signal"
---@param code integer
---@param output_signals boolean? Whether to output on a signal. Defaults to true.
---@return string? msg a human readable error message.
local function exit_msg(reason, code, output_signals)
  if reason == "exit" then
    if code == 0 then return end -- Exited successfully.
    return ("exited with a code of %d!"):format(code)
  end -- After this, reason must be "signal"
  if code == capi.awesome.unix_signal["SIGSEGV"] then return "segfaulted!" end --- Segfault should be treated specially!
  if not output_signals then return end -- No output for signals other than SIGSEGV.

  local signame = capi.awesome.unix_signal[code] -- Get the name of the signal
  return ("exited with signal %s"):format(signame or code) --- Name if available, else signal number.
end
---This is a private function. Do not call it directly.
---Note: This expects you to check if the compositor is running before calling!
---@return boolean success
---@return string? error error message if failed
function compositor._spawn()
  local info, err = spawn.nosn(compositor.cmd, {
    exit_callback_err = function(reason, code)
      local msg = exit_msg(reason, code, false)
      if not msg then return end
      notifs.warn(msg, { title = "Compositor Crash!", timeout = 45 })
    end,
  })
  if not info then return false, err end
  return true, nil
end
---This is a private function. Do not call it directly.
---@param force boolean? kill with SIGKILL. Not recommended. Default false (SIGTERM).
---@return boolean stopped true if the compositor was stopped, false otherwise
---@return string? error error message if failed
function compositor._stop(force)
  local pid = compositor.get_pid()
  if not pid then return false, "Could not find compositor PID" end
  local sig = force and capi.awesome.unix_signal["SIGKILL"] -- SIGKILL. Stop. Now.
    or capi.awesome.unix_signal["SIGTERM"] -- SIGTERM. Ask Nicely to Stop.
    or 15 -- Default value for SIGTERM incase something went wrong.
  local suc = capi.awesome.kill(pid, sig)
  if not suc then return false, "Could not stop compositor." end
  return true
end

---@return integer? pid pid of the compositor. Nil if not found.
---Note that this is the pid of the last running compositor. If the compositor is stopped, this will return an invalid pid.
---Use compositor.is_running to get the status of the compositor (Also returns the pid if running).
function compositor.get_pid()
  local f = io.open(compositor.pid_file, "r") --- SYNCHRONOUS! This can freeze the GUI. Then again, so will starting/stopping the compositor
  if not f then return nil end
  local pid = f:read("l") -- read only one line.
  f:close()
  local pnum = tonumber(pid) -- if pid is nil, tonumber returns nil. Also, if invalid number, returns nil.
  if not pnum or pnum % 1 ~= 0 then return nil end -- Not an integer! Invalid PID!
  return pnum
end
---@return boolean running true if the compositor is running, false otherwise
---@return integer? pid pid of the compositor. If the compositor is running.
function compositor.is_running()
  local pid = compositor.get_pid()
  if not pid then return false end
  local suc = capi.awesome.kill(pid, 0) -- zero means just check if it exists!
  if not suc then return false end
  return true, pid
end
---Toggle the compositor
---@return boolean success true if the compositor was toggled successfully, false otherwise
---@return string? error error message if failed
function compositor.toggle()
  if compositor.is_running() then return compositor._stop() end
  return compositor._spawn()
end
---Spawn the compositor
---@param force boolean? If true, spawn the compositor even if already running. This will almost definitely error!
---@return boolean success
---@return string? error error message if failed
function compositor.spawn(force)
  if not force and compositor.is_running() then return false, "Compositor is already running" end
  return compositor._spawn()
end
compositor.start = compositor.spawn --- Alias start to spawn for symetry with compositor.stop
---Stop the compositor if running
---@param force boolean? If true, kill -9 the compositor.
---@return boolean success true if the compositor was stopped, false otherwise
---@return string? error error message if failed
function compositor.stop(force)
  if not compositor.is_running() then return false, "Can't stop compositor, not running." end
  return compositor._stop(force)
end
compositor.kill = compositor.stop --- Alias kill to stop for symetry with compositor.spawn

---Starts the compositor -- takes precations to avoid starting it if it would be a bad idea (ie, in a VM)
---Calling this multiple times is not suggested, but shouldn't break anything.
function compositor.autostart()
  local get_stream = require("util.file.stream_async")
  return get_stream("/proc/cpuinfo", function(stream)
    if not stream then return end -- likely file doesn't exist
    return stream:each_line(function(line)
      if not line or not line:match("[^\n]flags%s*:") then return true end -- This isn't the line we're looking for
      -- if contains the hypervisor flag (we are in a VM) then don't start the compositor.
      if line:match("[^\n]flags%s*:.*%shypervisor%s") then return false end
      gtimer.delayed_call(compositor.start) -- Start the compositor
      return false -- Stop looping
    end, function()
      return stream:close() -- Cleanup after ourselves
    end)
  end)
end

capi.awesome.connect_signal("exit", function()
  compositor.stop() -- Stop the compositor on exit - should happen anyways, but lets clean up
  os.remove(compositor.pid_file) -- cleanup the file on exit
end)

return compositor
