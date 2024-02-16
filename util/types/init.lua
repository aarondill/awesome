local M = require("util.metainit")(..., { ---@diagnostic disable: assign-type-mismatch
  assertions = nil, ---@module "util.types.assertions"
  init = nil, ---@module "util.types.init"
  iscallable = nil, ---@module "util.types.iscallable"
  screen = nil, ---@module "util.types.screen"
  serialize_table = nil, ---@module "util.types.serialize_table"
}) ---@diagnostic enable: assign-type-mismatch
return M
