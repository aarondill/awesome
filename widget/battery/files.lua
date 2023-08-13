local gfilesystem = require("gears.filesystem")
local list_directory = require("util.file.list_directory")
local read_async = require("util.file.read_async")
local PATH_TO_ICONS = gfilesystem.get_configuration_dir() .. "widget/battery/icons/"
---@class battery_info
---@field status string?
---@field capacity number?

---@type table<string, {path:string, match:string}>
local battery_files = {
  capacity = { path = "/capacity", match = "(%d+)\n" },
  status = { path = "/status", match = "(.+)\n" },
}
---Get the battery stat from battery_files
---@param battery_path string path to the sysfs folder
---@param stat string battery_files[stat]
---@param ret table a table to store the result in. It will be stored in ret[stat]
---@param cb any
---@param cb_args any
local function get_battery_stat(battery_path, stat, ret, cb, cb_args)
  local battery_file = battery_files[stat]
  read_async(battery_path .. battery_file.path, function(content)
    ret[stat] = content:match(battery_file.match)
    cb(table.unpack(cb_args))
  end)
end
---returns battery information
---@param battery_path string the path to the battery directory (sysfs)
---@param callback_fn fun(info: battery_info) the function to call when the data has been retrieved
local function get_battery_info(battery_path, callback_fn)
  local ret = {}
  local args
  for k, _ in pairs(battery_files) do
    local t_args = { battery_path, k, ret }
    if not args then
      -- If args is not yet defined, then this is the inner (last) table, which should call the callback function
      table.insert(t_args, callback_fn)
      table.insert(t_args, { ret })
    else
      -- If args is already defined, then we will eventually call the callback function, we just need to pass those args to the get_battery_stat function
      table.insert(t_args, get_battery_stat)
      table.insert(t_args, args)
    end
    args = t_args
  end
  if args then
    get_battery_stat(table.unpack(args))
  else
    callback_fn(ret)
  end
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
