local watch = require("util.file.watch")
---@param path string the file path to watch
---See https://docs.gtk.org/gio/flags.FileMonitorFlags.html
---@param flags GioFileMonitorFlags[]? the flags to pass to the file watch method. nil corresponds to G_FILE_MONITOR_NONE
---@param cb GioFileWatcherHandler the function to call when the file changes
local function watch_file(path, flags, cb)
  if type(cb) ~= "function" then error("callback must be a function", 2) end
  if type(path) ~= "string" then error("path must be a string", 2) end
  watch(path, "monitor_file", flags, cb)
end
return watch_file
