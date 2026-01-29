local notifs = require("util.notifs")
local spawn = require("util.spawn")
local strings = require("util.strings")
---Run `systemctl cmd`, handling sudo and polkit
---@param cmd string? the command to run.
---@param notify_on_fail? boolean? Whether to notify on failure. Default: true
local function systemctl(cmd, notify_on_fail)
  cmd = cmd or "suspend-then-hibernate"
  local spawner = function()
    spawn.async({ "systemctl", cmd }, function(_stdout, stderr, reason, code)
      if spawn.is_normal_exit(reason, code) then return end -- Success
      if notify_on_fail == false then return end
      notifs.warn(strings.trim(stderr), {
        title = "systemctl",
        timeout = 10,
      })
    end, { sn_rules = false })
  end
  -- Try with sudo incase no password is needed (for hibernate)
  return spawn.nosn({ "sudo", "-n", "--", "systemctl", cmd }, {
    exit_callback_err = spawner, -- Spawn without sudo if original fails
    on_failure_callback = spawner,
  })
end

return systemctl
