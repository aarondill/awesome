-- MODULE AUTO-START
-- Run all the apps listed in configuration/apps.lua as run_on_startup only once when awesome start
local debug_autostart_failures = require("configuration").debug_autostart_failures

local apps = require("configuration.apps")
local capi = require("capi")
local notifs = require("util.notifs")
local spawn = require("util.spawn")

--- A map of cmds to pids
---@type table<CommandProvider, integer>
local processes = {}

local function err(cmd, e)
  notifs.warn(tostring(e), {
    title = ('Error while starting "%s".'):format(type(cmd) == "table" and table.concat(cmd, " ") or cmd),
    timeout = 0,
  })
end

local function get_warning(exitreason, exitcode)
  if exitreason == "exit" then return string.format("exit code: %d", exitcode) end
  -- Segfault:
  if exitcode == capi.awesome.unix_signal.SIGSEGV then return "Segfaulted!" end
  local signame = tostring(capi.awesome.unix_signal[exitcode])
  return string.format("killed with signal: %d (%s)", tostring(exitcode), signame)
end
---@param cmd CommandProvider the thing to run
---@return integer? pid of the process or nil if error
local function run_once(cmd)
  if not cmd then return nil end
  local info = spawn.nosn(cmd, {
    exit_callback_err = function(exitreason, exitcode)
      -- Command not found. I don't want a warning.
      -- Remove this to send notifications for missing commands.
      if exitreason == "exit" and exitcode == 127 and not debug_autostart_failures then return end
      return err(cmd, get_warning(exitreason, exitcode))
    end,
    on_failure_callback = debug_autostart_failures
        and function(e)
          -- Something went wrong. Likely isn't installed. This would be where you notify if you want to when a command is not found.
          return err(cmd, e)
        end
      or nil,
  })
  if info then return info.pid end
end

capi.awesome.connect_signal("startup", function()
  for _, app in ipairs(apps.run_on_startup) do
    processes[app] = run_once(app)
  end
end)
-- Kill them all on exit
capi.awesome.connect_signal("exit", function(_)
  for _, pid in pairs(processes) do
    -- killing -p means sending a signal to every process in the process group p. Awesome makes sure to spawn processes in a new session, so this works.
    capi.awesome.kill(-pid, capi.awesome.unix_signal.SIGTERM or 15) -- SIGTERM
  end
  processes = {} -- They're all dead. Doesn't matter because the table is lost anyways, but yk.
end)
return processes
