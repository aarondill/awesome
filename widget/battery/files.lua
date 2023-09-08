local gtable = require("gears.table")
local list_directory = require("util.file.list_directory")
local parallel_async = require("util.parallel_async")
local read_async = require("util.file.read_async")
local source_path = require("util.source_path")
local PATH_TO_ICONS = source_path.dirname(1) .. "/icons/"

---@alias battery_info_types "capacity" | "status" | "power_now" | "energy_now" | "current_now" | "charge_now" | "charge_full" | "voltage_now" | "energy_full"
---@alias battery_info table<battery_info_types, string?>
---@alias path_info { path: string , match: string }
---@type { [battery_info_types]: path_info}
local battery_files = {
  capacity = { path = "/capacity", match = "(%d+)\n" },
  status = { path = "/status", match = "(.+)\n" },
  current_now = { path = "/current_now", match = "(%d+)\n" }, -- Replaced with power_now
  power_now = { path = "/power_now", match = "(%d+)\n" },
  energy_now = { path = "/energy_now", match = "(%d+)\n" },
  charge_now = { path = "/charge_now", match = "(%d+)\n" },
  charge_full = { path = "/charge_full", match = "(%d+)\n" },
  voltage_now = { path = "/voltage_now", match = "(%d+)\n" },
  energy_full = { path = "/energy_full", match = "(%d+)\n" },
}
local keys = gtable.keys(battery_files) ---@type string[]

---returns battery information
---@param battery_path string the path to the battery directory (sysfs)
---@param callback_fn fun(info: battery_info) the function to call when the data has been retrieved
local function get_battery_info(battery_path, callback_fn)
  parallel_async(keys, function(key, done)
    local battery_file = battery_files[key]
    read_async(battery_path .. battery_file.path, function(content, _)
      -- notifs.warn(tostring(error))
      done(content and content:match(battery_file.match))
    end)
  end, callback_fn)
end

---Find the first battery in the sysfs
---@param cb fun(path: string?)
local function find_battery_path(cb)
  local power_supply_dir = "/sys/class/power_supply/"
  list_directory(power_supply_dir, { match = "BAT.+" }, function(files)
    cb(power_supply_dir .. files[1])
  end)
end
---find an icon specific to this widget
---@param name string the filename of the icon, excluding the extension
---@param ext string? default is .svg
local function get_icon(name, ext)
  ext = ext or ".svg"
  return PATH_TO_ICONS .. name .. ext
end

return {
  get_battery_info = get_battery_info,
  find_battery_path = find_battery_path,
  get_icon = get_icon,
}
