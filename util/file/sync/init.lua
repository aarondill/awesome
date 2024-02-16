local require = require("util.rel_require")
---@diagnostic disable: assign-type-mismatch -- To allow nil values
local M = {
  exists = nil, ---@module 'util.file.sync.exists'
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
