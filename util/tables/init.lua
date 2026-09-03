local M = require("util.metainit")(..., { ---@diagnostic disable: assign-type-mismatch
  deep_equal = nil, ---@module "util.tables.deep_equal"
  filter = nil, ---@module "util.tables.filter"
  find = nil, ---@module "util.tables.find"
  init = nil, ---@module "util.tables.init"
  concat = nil, ---@module "util.tables.concat"
  join = nil, ---@module "util.tables.join"
  clone = nil, ---@module "util.tables.clone"
  deep_extend = nil, ---@module "util.tables.deep_extend"
  extend = nil, ---@module "util.tables.extend"
  is_array = nil, ---@module "util.tables.is_array"
}) ---@diagnostic enable: assign-type-mismatch
return M
