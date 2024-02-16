---@diagnostic disable: assign-type-mismatch -- To allow nil values
local M = require("util.metainit")(..., {
  append_async = nil, ---@module "util.file.append_async"
  sync = nil, ---@module "util.file.sync"
  list_directory = nil, ---@module "util.file.list_directory"
  read_async = nil, ---@module "util.file.read_async"
  scan_directory = nil, ---@module "util.file.scan_directory"
  watch = nil, ---@module "util.file.watch"
  watch_directory = nil, ---@module "util.file.watch_directory"
  watch_file = nil, ---@module "util.file.watch_file"
  write_async = nil, ---@module "util.file.write_async"
})
---@diagnostic enable: assign-type-mismatch
return M
