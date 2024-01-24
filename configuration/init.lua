local require = require("util.rel_require")
---@diagnostic disable: assign-type-mismatch
local M = {
  apps = nil, ---@module "configuration.apps"
  keys = nil, ---@module "configuration.keys"
  layouts = nil, ---@module "configuration.layouts"
}
---@diagnostic enable: assign-type-mismatch

--- Send a notification if autostart fails
M.debug_autostart_failures = false ---@type boolean
--- throttle delay on tag changes (seconds)
M.tag_throttle_delay = 0.25 ---@type number

local this_path = ...
return setmetatable(M, {
  __index = function(_, key)
    local m = require(this_path, key, false) -- No TCO!
    return m
  end,
})
