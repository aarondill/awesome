local require = require("util.rel_require")
---@diagnostic disable: assign-type-mismatch -- To allow nil values
local M = {
  append_async = nil, ---@module "util.file.append_async"
  basename = nil, ---@module "util.file.basename"
  exists = nil, ---@module "util.file.exists"
  list_directory = nil, ---@module "util.file.list_directory"
  read_async = nil, ---@module "util.file.read_async"
  scan_directory = nil, ---@module "util.file.scan_directory"
  watch = nil, ---@module "util.file.watch"
  watch_directory = nil, ---@module "util.file.watch_directory"
  watch_file = nil, ---@module "util.file.watch_file"
  write_async = nil, ---@module "util.file.write_async"
}
---@diagnostic enable: assign-type-mismatch
assert(#M == 0, "Tag list module has keys set. This is a bug! Use the metatable!")

local this_path = ...
return setmetatable(M, {
  __index = function(_, key)
    local m = require(this_path, key, false) -- No TCO!
    return m
  end,
})
