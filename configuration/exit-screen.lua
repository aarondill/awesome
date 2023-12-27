local bind = require("util.bind")
local capi = require("capi")
local icons = require("theme.icons")
local open = require("configuration.apps.open")
local systemctl_cmd = require("util.systemctl_cmd")

local function suspend_command()
  open.lock()
  return systemctl_cmd("suspend-then-hibernate")
end

local M = { ---@type ExitScreenConf
  -- exit_keys = { "Escape", "q", "x" },
  exit_keys = true,
  buttons = {
    { "Poweroff", "p", cmd = bind.with_args(systemctl_cmd, "poweroff"), icon = icons.power },
    { "Restart", "r", cmd = bind.with_args(systemctl_cmd, "reboot"), icon = icons.restart },
    { "Suspend-Then-Hibernate", "s", cmd = suspend_command, icon = icons.sleep },
    { "Exit AWM", "e", cmd = bind.with_args(capi.awesome.quit, 0), icon = icons.logout },
    { "Lock", "l", cmd = open.lock, icon = icons.lock },
  },
}

return M
