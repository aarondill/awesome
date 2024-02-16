local bind = require("util.bind")
local capi = require("capi")
local icons = require("theme.icons")
local open = require("configuration.apps.open")
local systemctl = require("util.command.systemctl")

local function suspend_command()
  open.lock()
  return systemctl("suspend-then-hibernate")
end

local M = { ---@type ExitScreenConf
  -- exit_keys = { "Escape", "q", "x" },
  exit_keys = true,
  buttons = {
    { "Poweroff", "p", cmd = bind.with_args(systemctl, "poweroff"), icon = icons.power },
    { "Restart", "r", cmd = bind.with_args(systemctl, "reboot"), icon = icons.restart },
    { "Suspend-Then-Hibernate", "s", cmd = suspend_command, icon = icons.sleep },
    { "Exit AWM", "e", cmd = bind.with_args(capi.awesome.quit, 0), icon = icons.logout },
    { "Lock", "l", cmd = open.lock, icon = icons.lock },
  },
}

return M
