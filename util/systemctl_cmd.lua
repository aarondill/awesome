local spawn = require("util.spawn")
---Run `systemctl cmd`, handling sudo and polkit
---@param cmd string? the command to run.
local function systemctl_cmd(cmd)
  cmd = cmd or "suspend-then-hibernate"
  local cb = function(_, code)
    -- Spawn without sudo if original fails
    if not code or code == 1 then spawn.nosn({ "systemctl", cmd }) end
  end
  -- Try with sudo incase no password is needed (for hibernate)
  local pid = spawn.nosn({ "sudo", "-n", "--", "systemctl", cmd }, { exit_callback = cb })
  if type(pid) == "string" then cb() end -- If sudo is not found
end

return systemctl_cmd
