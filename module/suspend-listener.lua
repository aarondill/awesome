local lgi = require("lgi")
local Gio = lgi.require("Gio")
local capi = require("capi")

local M = {}
M.callbacks_before = {
  strong = {},
  weak = setmetatable({}, { __mode = "k" }),
}
M.callbacks_after = {
  strong = {},
  weak = setmetatable({}, { __mode = "k" }),
}

local function handler(_bus, _sender, _object, _interface, _signal, params)
  -- "signals are sent right before (with the argument True) and
  -- after (with the argument False) the system goes down for
  -- reboot/poweroff, resp. suspend/hibernate."
  local before_sleep = params[1]
  local type = before_sleep and "before" or "after"
  for cb in pairs(M["callbacks_" .. type].strong) do
    cb(type)
  end
  for cb in pairs(M["callbacks_" .. type].weak) do
    cb(type)
  end
end

local bus = nil
local function listen_to_signals()
  if bus then return end
  bus = lgi.Gio.bus_get_sync(Gio.BusType.SYSTEM) -- This *needs* to be scope leaked above! The subscription will be lost if the bus is GCed
  local sender = "org.freedesktop.login1"
  local interface = "org.freedesktop.login1.Manager"
  local object = "/org/freedesktop/login1"
  local member = "PrepareForSleep"
  bus:signal_subscribe(sender, interface, member, object, nil, Gio.DBusSignalFlags.NONE, handler)
end

---Register a callback
---@param cb fun(when: 'before'|'after')
---@param before boolean? register for before sleep? false means after wake. default: false
---@param weak boolean? weakly register callback?
---@return boolean
M.register_listener = function(cb, before, weak)
  local type = before and "before" or "after"
  local t = M["callbacks_" .. type][weak and "weak" or "strong"]
  if t[cb] then return false end
  t[cb] = true
  listen_to_signals() -- Ensure we are connected to dbus!
  return true
end
M.unregister_listener = function(cb, before, weak)
  local type = before and "before" or "after"
  local t = M["callbacks_" .. type][weak and "weak" or "strong"]
  if not t[cb] then return false end
  t[cb] = nil
  return true
end

return M
