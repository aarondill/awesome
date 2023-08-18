local require = require("util.rel_require")
local M = {
  read_async = require(..., "read_async"), ---@module "util.file.read_async"
  write_async = require(..., "write_async"), ---@module "util.file.write_async"
  append_async = require(..., "append_async"), ---@module "util.file.append_async"
  basename = require(..., "basename"), ---@module "util.file.basename"
  exists = require(..., "exists"), ---@module "util.file.exists"
  scan_directory = require(..., "scan_directory"), ---@module "util.file.scan_directory"
  list_directory = require(..., "list_directory"), ---@module "util.file.list_directory"
  watch = require(..., "watch"), ---@module "util.file.watch"
  watch_directory = require(..., "watch_directory"), ---@module "util.file.watch_directory"
  watch_file = require(..., "watch_file"), ---@module "util.file.watch_file"
}
local import_path = ({ ... })[1]
return setmetatable(M, { -- Just incase I forget to update the init table
  __index = function(_, key)
    local mod = require(import_path, key, false) -- mod is nil if not found
    return mod
  end,
})
