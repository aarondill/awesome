local bind = require("util.bind")
local spawn = require("util.spawn")
---Run `systemctl cmd`, handling sudo and polkit
---@param cmd string? the command to run.
local function systemctl(cmd)
  cmd = cmd or "suspend-then-hibernate"
  local spawner = bind.with_args(spawn.nosn, { "systemctl", cmd })
  -- Try with sudo incase no password is needed (for hibernate)
  return spawn.nosn({ "sudo", "-n", "--", "systemctl", cmd }, {
    exit_callback_err = spawner, -- Spawn without sudo if original fails
    on_failure_callback = spawner,
  })
end

return systemctl
