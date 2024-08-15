local lgi = require("lgi")
local Gio, GLib = lgi.Gio, lgi.GLib
local M = {}

---Asynchronously gets a dbus property.
---Note: the returned value is likely a GVariant. Good luck.
---Here's some help with that: https://github.com/lgi-devs/lgi/blob/master/docs/variant.md
---@param bus_name string
---@param object_path string
---@param interface string
---@param prop string
---@param callback fun(res?: GVariant, err?: userdata)
function M.get(bus_name, object_path, interface, prop, callback)
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
---Asynchronously gets a dbus property.
---Note: the returned value is likely a GVariant. Good luck.
---Here's some help with that: https://github.com/lgi-devs/lgi/blob/master/docs/variant.md
---@param bus_name string
---@param object_path string
---@param interface string
---@param callback fun(res?: GVariant, err?: userdata)
function M.get_all(bus_name, object_path, interface, callback)
  Gio.bus_get_sync(Gio.BusType.SYSTEM):call(
    bus_name,
    object_path,
    "org.freedesktop.DBus.Properties",
    "GetAll",
    GLib.Variant.new("(s)", { interface }),
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

return M
