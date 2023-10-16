local lgi = require("lgi")
local GLib, Gio = lgi.GLib, lgi.Gio
---@alias GLibVariant unknown pain and suffering.

---Asynchronously gets a dbus property.
---Note: the returned value is likely a GLibVariant. Good luck.
---Here's some help with that: https://github.com/lgi-devs/lgi/blob/master/docs/variant.md
---@param bus_name string
---@param object_path string
---@param interface string
---@param prop string
---@param callback fun(res?: GLibVariant, err?: userdata)
local function get_dbus_property(bus_name, object_path, interface, prop, callback)
  Gio.bus_get_sync(Gio.BusType.SYSTEM):call(
    bus_name,
    object_path,
    "org.freedesktop.DBus.Properties",
    "Get",
    GLib.Variant.new("(ss)", { interface, prop }),
    nil,
    Gio.DBusSignalFlags.NONE,
    -1,
    nil,
    function(bus, gtask)
      local res, err = bus:call_finish(gtask)
      return callback(res, err)
    end
  )
end

---An example callback:
-- local function handler(res, err)
--   if err then return print("ERROR: " .. tostring(err)) end
--
--   assert(res.type == "(v)")
--   assert(res.value[1].type == "s")
--   local value = res.value[1].value
--   print(value)
-- end

return get_dbus_property
