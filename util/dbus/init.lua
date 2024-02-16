---@diagnostic disable: assign-type-mismatch -- To allow nil values
local M = require("util.metainit")(..., {
  get_prop = nil, ---@module "util.dbus.get_prop"
  create_inhibitor = nil, ---@module "util.dbus.create_inhibitor"
  subscribe_signal = nil, ---@module "util.dbus.subscribe_signal"
  properties_changed = nil, ---@module "util.dbus.properties_changed"
})
---@diagnostic enable: assign-type-mismatch
return M
