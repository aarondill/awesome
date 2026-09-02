local bind = require("util.bind")
local capi = require("capi")
local icons = require("theme.icons")
local open = require("configuration.apps.open")
local systemctl = require("util.command.systemctl")

local function lock_then_sysctl(cmd)
  return function()
    open.lock()
    return systemctl(cmd)
  end
end

local M = { ---@type ExitScreenConf
  exit_keys = { "Escape", "q", "x" },
  -- exit_keys = true,
  buttons = {
    { "Poweroff", "p", cmd = bind.with_args(systemctl, "poweroff"), icon = icons.power },
    { "Restart", "r", cmd = bind.with_args(systemctl, "reboot"), icon = icons.restart },
    { "Suspend-Then-Hibernate", "s", cmd = lock_then_sysctl("suspend-then-hibernate"), icon = icons.sleep },
    { "Hibernate", "h", cmd = lock_then_sysctl("hibernate"), icon = icons.bed },
    { "Exit AWM", "e", cmd = bind.with_args(capi.awesome.quit, 0), icon = icons.logout },
    { "Lock", "l", cmd = open.lock, icon = icons.lock },
  },
}

return M
