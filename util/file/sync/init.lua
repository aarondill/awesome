local M = require("util.metainit")(..., { ---@diagnostic disable: assign-type-mismatch
  exists = nil, ---@module 'util.file.sync.exists'
  file_type = nil, ---@module 'util.file.sync.file_type'
  ls = nil, ---@module 'util.file.sync.ls'
  write_sync = nil, ---@module 'util.file.sync.write_sync'
}) ---@diagnostic enable: assign-type-mismatch
return M
