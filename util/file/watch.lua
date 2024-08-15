local Gio = require("lgi").Gio
local handle_error = require("util.handle_error")
local iscallable = require("util.types.iscallable")

---@alias FileWatcherHandler fun(type: GFileMonitorEvent, path1: string, path2: string?)
---A common interface for implementing file watch functions
---@param path string the file path to watch
---@param method "monitor" | "monitor_directory" | "monitor_file" the file watch method to call (monitor_*)
---See https://docs.gtk.org/gio/flags.FileMonitorFlags.html
---@param flags GFileMonitorFlags[]? the flags to pass to the file watch method. nil corresponds to G_FILE_MONITOR_NONE
---@param cb FileWatcherHandler
---@return GFileMonitor? monitor Make sure this is not garbage collected!
---@return userdata? error error if monitor ir nil
local function watch_common(path, method, flags, cb)
  if not iscallable(cb) then error("callback must be a function", 2) end
  if type(method) ~= "string" then error("method must be a string", 2) end
  if type(path) ~= "string" then error("path must be a string", 2) end

  local file = Gio.File.new_for_path(path)
  if not file[method] then error("method " .. method .. " does not exist", 2) end

  local flag_int = Gio.FileMonitorFlags["NONE"]
  if flags then
    for _, flag in ipairs(flags) do
      if Gio.FileMonitorFlags[flag] then
        flag_int = flag_int | Gio.FileMonitorFlags[flag] -- bitwise AND
      end
    end
  end

  local monitor, error = file[method](file, flags or Gio.FileMonitorFlags.NONE)
  if not monitor then return nil, error end
  ---@param type GFileMonitorEvent can't guarentee, but best I can do
  monitor.on_changed:connect(handle_error(function(_, file1, file2, type)
    local path1 = file1:get_path() ---@type string
    ---Only if using the deprecated flag G_FILE_MONITOR_SEND_MOVED flag and event_type is G_FILE_MONITOR_EVENT_MOVED
    local path2 = file2 and file2:get_path() ---@type string?
    return cb(type, path1, path2) ---path2 is likely nil
  end))
  return monitor, nil
end

return watch_common
