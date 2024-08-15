local Gio = require("lgi").Gio
local await = require("await")
local parallel_async = require("util.parallel_async")
local properties = require("util.dbus.properties")
local properties_changed = require("util.dbus.properties_changed")
local tables = require("util.tables")
local M = {}
---Index with the widget!
---@type table<table, SubscribeID>
local upower_listeners = setmetatable({}, { __mode = "k" })

---@param callback fun(bat_path?: string, err?: GError): unknown?
local function find_battery(callback)
  return coroutine.wrap(function()
    ---@type GDBusConnection, GAsyncResult
    local bus, gtask = await(function(resolve)
      local name, path, iname = "org.freedesktop.UPower", "/org/freedesktop/UPower", "org.freedesktop.UPower"
      return Gio.bus_get_sync(Gio.BusType.SYSTEM)
        :call(name, path, iname, "EnumerateDevices", nil, nil, 0, -1, nil, resolve)
    end)
    local result, err = bus:call_finish(gtask)
    if not result or err then return callback(nil, err) end
    local devices = result[1] --[[ @as string[] ]]
    ---@type table<string?, boolean>
    local res = await(function(resolve)
      return parallel_async(devices, function(dev, done)
        return properties.get_all("org.freedesktop.UPower", dev, "org.freedesktop.UPower.Device", function(v_props)
          local props = v_props[1] --[[ @as table<string, unknown> ]]
          local Type, PowerSupply = props.Type, props.PowerSupply
          assert(type(Type) == "number", "type is not a number") ---@cast Type number
          assert(type(PowerSupply) == "boolean", "power_supply is not a boolean") ---@cast PowerSupply boolean
          local is_battery = Type == 2
          local is_laptop_battery = is_battery and PowerSupply
          return done(is_laptop_battery)
        end)
      end, resolve)
    end)
    local _, bat = tables.find(res, function(is_battery) return is_battery end)
    return callback(bat, nil)
  end)()
end

---@param widget any
---@param callback fun(changed: {State: string}): any?
function M.subscribe_state(widget, callback)
  return find_battery(function(bat_path) -- DBus Object path to battery
    if not bat_path then return end
    upower_listeners[widget] = properties_changed.subscribe("org.freedesktop.UPower", bat_path, callback, "State")
  end)
end
return M
