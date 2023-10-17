local bind = require("util.bind")
local spawn = require("util.spawn")
---Run `systemctl cmd`, handling sudo and polkit
---@param cmd string? the command to run.
local function systemctl_cmd(cmd)
  cmd = cmd or "suspend-then-hibernate"
  local spawner = bind.with_args(spawn.nosn, { "systemctl", cmd })
  -- Try with sudo incase no password is needed (for hibernate)
  return spawn.nosn({ "sudo", "-n", "--", "systemctl", cmd }, {
    exit_callback = function(reason, code)
      -- Spawn without sudo if original fails
      if not spawn.is_normal_exit(reason, code) then spawner() end
    end,
    on_failure_callback = spawner,
  })
end

return systemctl_cmd
