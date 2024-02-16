local M = require("util.metainit")(..., { ---@diagnostic disable: assign-type-mismatch
  concat_command = nil, ---@module "util.command.concat_command"
  shell_escape = nil, ---@module "util.command.shell_escape"
  systemctl = nil, ---@module "util.command.systemctl"
  xdg_user_dir = nil, ---@module "util.command.xdg_user_dir"
}) ---@diagnostic enable: assign-type-mismatch
return M
