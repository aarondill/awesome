local gfilesystem = require("gears.filesystem")
local list_directory = require("util.file.list_directory")
local read_async = require("util.file.read_async")
local PATH_TO_ICONS = gfilesystem.get_configuration_dir() .. "widget/battery/icons/"

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

---Get the battery stat from battery_files
---@param battery_path string path to the sysfs folder
---@param stat string battery_files[stat]
---@param ret table a table to store the result in. It will be stored in ret[stat]
---@param done_tbl boolean[] A table to store true in when done
---@param index integer
---@param cb function
local function get_battery_stat(battery_path, done_tbl, index, stat, ret, cb)
  local battery_file = battery_files[stat]
  read_async(battery_path .. battery_file.path, function(content)
    if content then ret[stat] = content:match(battery_file.match) end
    done_tbl[index] = true
    local is_done = true
    for _, v in ipairs(done_tbl) do
      if v == false then
        is_done = false
        break
      end
    end
    if is_done then
      done_tbl[index] = false -- Reduce the chance of race conditions, subsequent calculations will return false
      cb(ret)
    end
  end)
end
---returns battery information
---@param battery_path string the path to the battery directory (sysfs)
---@param callback_fn fun(info: battery_info) the function to call when the data has been retrieved
local function get_battery_info(battery_path, callback_fn)
  local ret, done = {}, {}
  local has_run = false
  for k, _ in pairs(battery_files) do
    local index = #done + 1 -- Assign an order to them.
    done[index] = false
    get_battery_stat(battery_path, done, index, k, ret, callback_fn)
    has_run = true
  end
  if not has_run then callback_fn(ret) end
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
