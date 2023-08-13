local gfilesystem = require("gears.filesystem")
local list_directory = require("util.file.list_directory")
local read_async = require("util.file.read_async")
local PATH_TO_ICONS = gfilesystem.get_configuration_dir() .. "widget/battery/icons/"
---@class battery_info
---@field status string?
---@field percentage number?

---returns battery information
---@param battery_path string the path to the battery directory (sysfs)
---@param callback_fn fun(info: battery_info) the function to call when the data has been retrieved
local function get_battery_info(battery_path, callback_fn)
  local ret = {}
  local function get_capacity(stdout)
    ret.capacity = stdout:match("(%d+)\n")
    callback_fn(ret)
  end
  local function get_status(stdout)
    ret.status = stdout:match("(.+)\n")
    read_async(battery_path .. "/capacity", get_capacity)
  end
  read_async(battery_path .. "/status", get_status)
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
