local require = require("util.rel_require")
local modPath = ...
return setmetatable({
  compositor = nil, ---@module "configuration.apps.compositor"
  default = nil, ---@module "configuration.apps.default"
  open = nil, ---@module "configuration.apps.open"
  run_on_startup = nil, ---@module "configuration.apps.run_on_startup"
}, {
  __index = function(_, key)
    local mod = require(modPath, key, false)
    return mod
  end,
})
