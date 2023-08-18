local require = require("util.rel_require")

local default = require(..., "default") ---@module "configuration.apps.default"
local open = require(..., "open") ---@module "configuration.apps.open"
local run_on_startup = require(..., "run_on_startup") ---@module "configuration.apps.run_on_startup"
return {
  default = default,
  open = open,
  run_on_startup = run_on_startup,
}
