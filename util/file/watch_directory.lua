local iscallable = require("util.iscallable")
local require = require("util.rel_require")

local watch = require(..., "watch") ---@module "util.file.watch"
---@param path string the file path to watch
---See https://docs.gtk.org/gio/flags.FileMonitorFlags.html
---@param flags GioFileMonitorFlags[]? the flags to pass to the file watch method. nil corresponds to G_FILE_MONITOR_NONE
---@param cb GioFileWatcherHandler the function to call when the directory changes
---@return GioFileMonitor? monitor Make sure this is not garbage collected!
---@return userdata? error error if monitor ir nil
local function watch_directory(path, flags, cb)
  assert(iscallable(cb))
  assert(type(path) ~= "string", "path must be a string")
  return watch(path, "monitor_directory", flags, cb)
end
return watch_directory
