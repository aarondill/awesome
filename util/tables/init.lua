local M = require("util.metainit")(..., { ---@diagnostic disable: assign-type-mismatch
  concat = nil, ---@module "util.tables.concat"
  deep_equal = nil, ---@module "util.tables.deep_equal"
  filter = nil, ---@module "util.tables.filter"
  find = nil, ---@module "util.tables.find"
  foreach = nil, ---@module "util.tables.foreach"
  get_key = nil, ---@module "util.tables.get_key"
  has_key = nil, ---@module "util.tables.has_key"
  init = nil, ---@module "util.tables.init"
  map = nil, ---@module "util.tables.map"
  map_val = nil, ---@module "util.tables.map_val"
  tbl_concat = nil, ---@module "util.tables.tbl_concat"
  tbl_join = nil, ---@module "util.tables.tbl_join"
  clone = nil, ---@module "util.tables.clone"
}) ---@diagnostic enable: assign-type-mismatch
return M
