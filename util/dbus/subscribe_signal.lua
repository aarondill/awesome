local Gio = require("lgi").Gio
local assertions = require("util.types.assertions")
local iscallable = require("util.types.iscallable")
local M = {}
---@class (exact) SubscribeID
---@field id integer
---@field bus GDBusConnection
---@field callback GDBusSignalCallback

---@class (exact) SubscribeConf
---@field sender string
---@field interface string
---@field member string
---@field object string
---@field bus? GDBusConnection
---@field callback GDBusSignalCallback

---Subscribe to a DBus signal
---@param signal SubscribeConf
---@return SubscribeID
---NOTE: when the bus gets GCed, the subscription will end!
function M.subscribe(signal)
  assertions.type(signal, "table", "signal")
  local sender, interface, member, object, callback =
    signal.sender, signal.interface, signal.member, signal.object, signal.callback

  assertions.type(sender, "string", "sender")
  assertions.type(interface, "string", "interface")
  assertions.type(member, "string", "member")
  assertions.type(object, "string", "object")
  if not iscallable(callback) then
    error(("%s: expected type %s, but got %s."):format("callback", "callable", type(callback)))
  end
  local bus = signal.bus or Gio.bus_get_sync(Gio.BusType.SYSTEM)
  local id = bus:signal_subscribe(sender, interface, member, object, nil, Gio.DBusSignalFlags.NONE, callback)
  return { id = id, bus = bus, callback = callback } -- The subscription will be lost if the bus is GCed
end

---Unsubscribe from a DBus signal
---@param subid SubscribeID
function M.unsubscribe(subid)
  assertions.type(subid, "table", "subid")
  assertions.type(subid.id, "number", "subid.id")
  assert(subid.bus, "subid must contain a Dbus bus")
  local bus, id = subid.bus, subid.id
  return bus:signal_unsubscribe(id) -- Remove the subscription.
end

return M
