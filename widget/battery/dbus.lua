local Gio = require("util.lgi.Gio")
local gtable = require("gears.table")
local parallel_async = require("util.parallel_async")
local properties = require("util.dbus.properties")
local properties_changed = require("util.dbus.properties_changed")
local tables = require("util.tables")
local M = {}
---Index with the widget!
---@type table<table, SubscribeID>
local upower_listeners = setmetatable({}, { __mode = "k" })

---@param callback fun(bat_path?: string, err?: string): unknown?
local function find_battery(callback)
  Gio.bus_get_sync(Gio.BusType.SYSTEM):call(
    "org.freedesktop.UPower",
    "/org/freedesktop/UPower",
    "org.freedesktop.UPower",
    "EnumerateDevices",
    nil,
    nil,
    0,
    -1,
    nil,
    function(bus, gtask)
      local result, err = bus:call_finish(gtask)
      if err then return callback(nil, err) end
      local devices = result[1] --[[ @as string[] ]]
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
      end, function(res) ---@param res table<string?, boolean>
        local _, bat = tables.find(res, function(is_battery) return is_battery end)
        return callback(bat, nil)
      end)
    end
  )
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
